#!/bin/bash

MODE=${1:-"build"}

P='\033[38;2;48;255;106m'
D='\033[38;2;255;210;50m'
B='\033[38;2;50;231;255m'
E='\033[38;2;255;74;50m'
R='\033[0m'

{
    echo "-- Generated from package.json | build/build.sh"
    echo ""
    echo "return [["
    cat package.json
    echo "]]"
} > build/package.lua

if [ "$MODE" = "dev" ]; then
    INPUT=${2:-"./main.lua"}
    PREFIX="${D}[ DEV ]${R}"
else
    INPUT="src/Init.lua"
    PREFIX="${B}[ BUILD ]${R}"
fi

OUTPUT="dist/main.lua"
CONFIG="build/darklua.dev.config.json"

PKG=$(node -e "const p=require('./package.json');console.log(JSON.stringify({v:p.version||'',d:p.description||'',r:p.repository||'',s:p.discord||'',l:p.license||''}))")

[ $? -ne 0 ] && echo -e "${E}[ × ]${R} Failed to read package.json" && exit 1

VER=$(echo $PKG | node -pe "JSON.parse(require('fs').readFileSync(0,'utf-8')).v")
DATE=$(date '+%Y-%m-%d')

HEADER=$(cat build/header.lua | node -e "
const pkg=JSON.parse('$PKG');
let h=require('fs').readFileSync(0,'utf-8');
h=h.replace(/{{VERSION}}/g,'$VER')
   .replace(/{{BUILD_DATE}}/g,'$DATE')
   .replace(/{{DESCRIPTION}}/g,pkg.d)
   .replace(/{{REPOSITORY}}/g,pkg.r)
   .replace(/{{DISCORD}}/g,pkg.s)
   .replace(/{{LICENSE}}/g,pkg.l);
console.log(h);
")

START=$(date +%s%N)
DARKLUA_OUT=$(darklua process "$INPUT" dist/temp.lua --config "$CONFIG" 2>&1)
DARKLUA_EXIT=$?

if [ $DARKLUA_EXIT -ne 0 ]; then
    echo -e "${E}[ × ]${R} DarkLua failed"
    echo "$DARKLUA_OUT"
    rm -f dist/temp.lua
    exit 1
fi

END=$(date +%s%N)
TIME=$((($END - $START) / 1000000))

echo "$HEADER" > "$OUTPUT"
echo "" >> "$OUTPUT"
cat dist/temp.lua >> "$OUTPUT"
rm -f dist/temp.lua

# Runtime compatibility repair.
#
# Creator.lua historically treated `not writefile` as Studio and, in executor
# mode, blindly executed `loadstring(HttpGet(...))()`. If GitHub returned an
# error page / empty body, loadstring returned nil and the runtime crashed at
# the generated `)()` line. This post-build repair keeps the editable source
# layout untouched while making every compiled runtime deterministic:
#   • only actual Studio sessions use the server icon bridge
#   • executors always use the HTTP icon runtime path
#   • jsDelivr is preferred, raw GitHub is fallback
#   • the Footagesus icon runtime is pinned to a known-good commit
#   • nested icon pack URLs are routed through jsDelivr
#   • compile/runtime failures are validated instead of blindly called
node <<'NODE'
const fs = require('fs');
const file = 'dist/main.lua';
let source = fs.readFileSync(file, 'utf8');

const oldBlock = `local l="https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"

local m
if d:IsStudio()or not writefile then
m=a.load'b'
else
m=loadstring(
game.HttpGet and game:HttpGet(l)or h:GetAsync(l)
)()
end

m.SetIconsType"lucide"`;

const iconCommit = '46d30c19ba7bc601d6ec794a48dc3a89568b1eec';
const newBlock = `local l={
"https://cdn.jsdelivr.net/gh/Footagesus/Icons@${iconCommit}/Main-v2.lua",
"https://raw.githubusercontent.com/Footagesus/Icons/${iconCommit}/Main-v2.lua",
}

local m
if d:IsStudio()then
m=a.load'b'
else
local iconErrors={}
for _,iconUrl in ipairs(l)do
local fetchOk,iconSource=pcall(function()
return game.HttpGet and game:HttpGet(iconUrl)or h:GetAsync(iconUrl)
end)
if fetchOk and type(iconSource)=="string"and#iconSource>100 then
iconSource=iconSource:gsub("return request and true or false","return true",1)
iconSource=iconSource:gsub(
"https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/",
"https://cdn.jsdelivr.net/gh/Footagesus/Icons@${iconCommit}/"
)
local iconChunk,iconCompileError=loadstring(iconSource)
if type(iconChunk)=="function"then
local runOk,iconLibrary=pcall(iconChunk)
if runOk and type(iconLibrary)=="table"and type(iconLibrary.SetIconsType)=="function"then
m=iconLibrary
break
else
table.insert(iconErrors,"runtime: "..tostring(iconLibrary))
end
else
table.insert(iconErrors,"compile: "..tostring(iconCompileError))
end
else
table.insert(iconErrors,"fetch: "..tostring(iconUrl))
end
end
if type(m)~="table"then
error("[VantaUI] Failed to load Lucide icon runtime: "..table.concat(iconErrors," | "),0)
end
end

m.SetIconsType"lucide"`;

if (!source.includes(oldBlock)) {
    console.error('[ × ] VantaUI icon-loader signature changed; refusing to ship an unpatched runtime.');
    process.exit(1);
}

source = source.replace(oldBlock, newBlock);
fs.writeFileSync(file, source);
console.log('[ ✓ ] Applied resilient VantaUI icon-runtime loader');
NODE

PATCH_EXIT=$?
if [ $PATCH_EXIT -ne 0 ]; then
    echo -e "${E}[ × ]${R} Runtime compatibility repair failed"
    exit 1
fi

SIZE=$(($(wc -c < "$OUTPUT") / 1024))

echo ""
echo -e "[ $(date '+%H:%M:%S') ]"
echo -e "${P}[ ✓ ]${R} $PREFIX"
echo -e "${P}[ > ]${R} VantaUI Build completed successfully"
echo -e "${P}[ > ]${R} Version: ${VER}"
echo -e "${P}[ > ]${R} Time taken: ${TIME}ms"
echo -e "${P}[ > ]${R} Size: ${SIZE}KB"
echo -e "${P}[ > ]${R} Output file: ${OUTPUT}"
echo ""
