from pathlib import Path

src = Path("lib/RiftUI.luau")
s = src.read_text(encoding="utf-8")

def replace_exact(old, new, label):
    global s
    count = s.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected one occurrence, found {count}")
    s = s.replace(old, new, 1)

replace_exact(
    "}\n\nlocal function compileDictionary(dict)",
    "}\n\n--@@LOCALE_ZH@@\n\nlocal function compileDictionary(dict)",
    "locale insertion",
)
replace_exact(
    'function Hub:SetLanguage(code: string?, quiet: boolean?)\n\tcode = code or "en"\n',
    '''local function normalizeLanguage(code)
    if type(code) ~= "string" or code == "" then return "en" end
    local canonical = string.lower(code):gsub("_", "-")
    if canonical == "zh" or canonical:match("^zh%-") then return "zh" end
    return canonical
end

function Hub:SetLanguage(code: string?, quiet: boolean?)
    code = normalizeLanguage(code)
''',
    "locale normalization",
)
# CreateHub's saved/default choice must also recognize a region-qualified Chinese code.
replace_exact(
    'if language and language ~= "en" then self:SetLanguage(language, true) end',
    'if language and language ~= "en" then self:SetLanguage(language, true) end',
    "default locale existing path",
)
src.write_text(s, encoding="utf-8")

bundler = Path("scripts/bundle.mjs")
b = bundler.read_text(encoding="utf-8")
anchor = "  ['--@@BACKGROUND_PRESETS@@', 'lib/core/BackdropPresets.luau'],"
if b.count(anchor) != 1: raise RuntimeError("bundler anchor mismatch")
b = b.replace(anchor, anchor + "\n  ['--@@LOCALE_ZH@@', 'lib/core/Locales/zh.luau'],", 1)
bundler.write_text(b, encoding="utf-8")

docs = Path("src/docs/content.ts")
d = docs.read_text(encoding="utf-8")
old = 'Hub:SetLanguage(\\\\"es\\\\")\\\\nHub:SetLanguage(\\\\"en\\\\")\\\\nlocal translated'
# actual string embedded in JSON-style ts contains escaped quotes
if old not in d:
    raise RuntimeError("docs language example unavailable")
d = d.replace(old, 'Hub:SetLanguage(\\\\"zh\\\\")\\\\nHub:SetLanguage(\\\\"zh-CN\\\\")\\\\nHub:SetLanguage(\\\\"en\\\\")\\\\nlocal translated', 1)
old = "English, Spanish, Portuguese, German and French."
if d.count(old) != 1: raise RuntimeError("docs language list mismatch")
d = d.replace(old, "English, Spanish, Portuguese, German, French and Simplified Chinese.", 1)
docs.write_text(d, encoding="utf-8")
print("RiftUI Simplified Chinese language option integrated")
