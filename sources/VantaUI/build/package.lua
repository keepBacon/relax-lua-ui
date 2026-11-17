-- Generated from package.json | build/build.sh

return [[
{
    "name": "mrros3-vantaui",
    "version": "0.3.8",
    "private": false,
    "main": "./dist/main.lua",
    "repository": "https://github.com/MrRos3/VantaUI",
    "author": "MrRos3",
    "description": "VantaUI - polished AMOLED-first Roblox UI library by MrRos3",
    "license": "MIT",
    "scripts": {
        "dev": "bash build/build.sh dev $INPUT_FILE",
        "build": "bash build/build.sh build $INPUT_FILE",
        "live": "python3 -m http.server 8642",
        "watch": "chokidar . -i 'node_modules' -i 'dist' -i 'build' -c 'npm run dev --'",
        "live-build": "concurrently \"npm run live\" \"npm run watch --\"",
        "example-live-build": "INPUT_FILE=main_example.lua npm run live-build"
    },
    "keywords": [
        "roblox",
        "ui-library",
        "ui-design",
        "luau",
        "vantaui",
        "amoled"
    ],
    "devDependencies": {
        "chokidar-cli": "^3.0.0",
        "concurrently": "^9.2.0"
    }
}
]]
