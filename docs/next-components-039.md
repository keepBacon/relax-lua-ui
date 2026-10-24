# Native component expansion v0.3.9

Reference review: Cascade, Starlight Interface Suite and WindUI (independent implementation, no source copied).
Target: native Roblox Luau ScreenGui, touch-first Android, no HTML or external component runtime.

## Android demo
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/loader_next_039.lua"))()
```

Versioned source: releases/VortexionUI_Next_0_3_9.lua; main module: VortexionUI_Next.lua.

## Newly supported Tab methods
| Method | Main arguments | Result |
| --- | --- | --- |
| CreateTextArea | Title, Default, Placeholder, Height, Callback | editable multiline text |
| CreateStepper | Title, Min/Max, Step, Decimals, Editable, Default, Callback | quantized number |
| CreateSegmentedControl | Title, Options/Values, Default, Callback | selected option |
| CreateChipGroup | Title, Options/Values, Multi, Default, Callback | selected value/ordered array |
| CreateAccordion | Title, Content, ContentHeight, DefaultOpen, Callback | inline expanded/collapsed |
| CreateCode | Title, Code/Content, Height, Callback | readonly code + optional Copy |
| CreateImage | Title, Image/Source, Height, Callback | native Roblox asset image |
| CreateStatus | Title, Description, Default, Callback | status pill |
| CreateRating | Title, Max, Default, Callback | star rating 0..Max |
| CreateKeyValue | Title, Items={{Key,Value}} | static property rows, SetValue(index,value) |
| CreateList | Title, Items={{Title,Description,Value,Callback}}, Callback | clickable action list |
| CreateTimeline | Title, Items={{Title,Description,Color}} | readonly vertical event timeline |
| CreateSearch | Title, Options/Items, MaxResults, OnQueryChanged, Callback | in-page search and selection |
| CreateTooltip | Title, Content, Height, Callback | touch-open inline help |

## Example
```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/keepBacon/relax-lua-ui/main/releases/VortexionUI_Next_0_3_9.lua"))()
local window = UI.CreateWindow({Title="VortexionLua",Transparency=0.1})
local tab = window:CreateTab("Components", {Selected=true})
local stepper = tab:CreateStepper({Title="Power",Min=0,Max=100,Step=5,Default=20})
tab:CreateSegmentedControl({Title="Quality",Options={"Comfort","Balanced","Realistic"},Default="Balanced"})
tab:CreateChipGroup({Title="Tags",Options={"Touch","Native","Sharp"},Multi=true})
tab:CreateSearch({Title="Find",Options={"Console","Editor","Settings"}})
stepper:SetValue(75)
```

Value components generally implement SetValue(value,quiet), GetValue(), and Set alias; quiet=true suppresses the Callback.
KeyValue exposes SetValue(rowIndex,newValue). Timeline returns its UI Frame.
No new library dependency is required. The 0.3.8 release and loader are retained as rollback.

## Verification limits
Static checks validate API symbols, immutable release content and loader version pinning.
Physical Android executor runtime, input focus, asset availability and clipboard capability need device acceptance.
