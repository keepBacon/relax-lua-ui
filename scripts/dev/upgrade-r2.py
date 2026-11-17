#!/usr/bin/env python3
"""One-time deterministic RiftUI R2 migration. All substitutions assert their anchors."""
from pathlib import Path
p = Path("lib/RiftUI.luau")
s = p.read_text(encoding="utf-8")

def once(old, new, label):
    global s
    count = s.count(old)
    if count != 1:
        raise RuntimeError(f"{label}: expected one anchor, found {count}")
    s = s.replace(old, new, 1)

def between(begin, end, body, label):
    global s
    if s.count(begin) != 1:
        raise RuntimeError(f"{label}: cannot find unique start")
    a = s.index(begin)
    b = s.index(end, a + len(begin))
    s = s[:a] + body + s[b:]

once("--@@CALLBACK_SCHEDULER@@\n\nfunction Hub:_record",
     "--@@CALLBACK_SCHEDULER@@\n\n--@@RESOURCE_SCOPE@@\n\n--@@UI_SOUND@@\n\n--@@BACKGROUND_PRESETS@@\n\nfunction Hub:_record", "runtime module markers")
once("local saved = readSetup(id)\n", "local saved = readSetup(id)\n", "saved options check")
once("\tself:_initRequirements(options.Requirements)\n",
     "\tself:SetUISounds((saved and saved.UISounds) or options.UISounds or options.Sounds or {})\n\tself:_initRequirements(options.Requirements)\n", "sound bootstrap")
once("""\tself:_connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
\t\tif self._open then self:_fitPanel(self._open, false) end
\tend)""",
     """\tself:_connect(gui:GetPropertyChangedSignal("AbsoluteSize"), function()
\t\tself:_requestPanelFit()
\tend)""", "coalesce resize")
once("""function Hub:_tileOffset(tab): number""",
     """function Hub:_requestPanelFit()
\tif self._panelFitPending or self._destroyed then return end
\tself._panelFitPending = true
\ttask.defer(function()
\t\tself._panelFitPending = false
\t\tif not self._destroyed and self._open then self:_fitPanel(self._open, false) end
\tend)
end

function Hub:_tileOffset(tab): number""", "resize scheduler")
once("""\t\tcol.Visible = not narrow or side == 1
\t\tcol.Size = narrow and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -9, 0, 0)""",
     """\t\tlocal visible = not narrow or side == 1
\t\tlocal size = narrow and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, -9, 0, 0)
\t\tif col.Visible ~= visible then col.Visible = visible end
\t\tif col.Size ~= size then col.Size = size end""", "avoid redundant column layout writes")
once("""\t\t\tsection.Frame.Parent = tab.Columns[narrow and 1 or section.Side + 1]
\t\t\tsection.Frame.LayoutOrder = i""",
     """\t\t\tlocal parent = tab.Columns[narrow and 1 or section.Side + 1]
\t\t\tif section.Frame.Parent ~= parent then section.Frame.Parent = parent end
\t\t\tif section.Frame.LayoutOrder ~= i then section.Frame.LayoutOrder = i end""", "avoid redundant reparenting")
once("""\tif animate then
\t\tself._panelFitTween = tween(self.PanelHolder, SETTLE, { Size = goalSize, Position = goalPos })
\telse
\t\tself.PanelHolder.Size = goalSize
\t\tself.PanelHolder.Position = goalPos
\tend""",
     """\tif animate then
\t\tself._panelFitTween = tween(self.PanelHolder, SETTLE, { Size = goalSize, Position = goalPos })
\telse
\t\tif self.PanelHolder.Size ~= goalSize then self.PanelHolder.Size = goalSize end
\t\tif self.PanelHolder.Position ~= goalPos then self.PanelHolder.Position = goalPos end
\tend""", "avoid redundant panel sizing")
once("""\tself._open = tab
\ttab:_setActive(true)""",
     """\tself._open = tab
\tself:PlayUISound("Tab")
\tif not previous then self:PlayUISound("WindowOpen") end
\ttab:_setActive(true)""", "tab sound")
once("""function Hub:Close()
\tlocal tab = self._open""",
     """function Hub:Close()
\tlocal tab = self._open""", "close anchor")
once("""\tself._open = nil
\ttab:_setActive(false)""",
     """\tself._open = nil
\tself:PlayUISound("WindowClose")
\ttab:_setActive(false)""", "close sound")
once("""\tself._popup = { Anchor = anchor, Frame = frame, Holder = holder, OnClose = onClose }""",
     """\tself._popup = { Anchor = anchor, Frame = frame, Holder = holder, OnClose = onClose }
\tself:PlayUISound("DropdownOpen")""", "popup sound")
once("""\tself._popup = nil
\tself._popupJustClosed = true""",
     """\tself._popup = nil
\tif not self._destroyed then self:PlayUISound("DropdownClose") end
\tself._popupJustClosed = true""", "popup close sound")
once("""\t\tc:_emit()
\tend)
\tfunction c:SetText""",
     """\t\thub:PlayUISound("Click")
\t\tc:_emit()
\tend)
\tfunction c:SetText""", "button click sound")
once("""\t\tif not silent then
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()
\t\treturn self.Value
\tend
\trender(false)
\thub:_connect(hit.MouseButton1Click, function()
\t\tc:Set(not c.Value)""",
     """\t\tif not silent then
\t\t\thub:PlayUISound(value and "ToggleOn" or "ToggleOff")
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()
\t\treturn self.Value
\tend
\trender(false)
\thub:_connect(hit.MouseButton1Click, function()
\t\tc:Set(not c.Value)""", "toggle sound")
once("""\t\tif self.Value == value then
\t\t\trender()
\t\t\treturn
\t\tend
\t\tself.Value = value
\t\trender()
\t\tif not silent then
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()""",
     """\t\tif self.Value == value then
\t\t\trender()
\t\t\treturn
\t\tend
\t\tself.Value = value
\t\trender()
\t\tif not silent then
\t\t\thub:PlayUISound("SliderTick")
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()""", "slider tick sound")
once("""\t\tself.Value = value
\t\tbox.Text = value
\t\tif not silent then
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()""",
     """\t\tself.Value = value
\t\tbox.Text = value
\t\tif not silent then
\t\t\thub:PlayUISound("InputSubmit")
\t\t\tself:_emit(value)
\t\tend
\tend
\tfunction c:Get()""", "input submit sound")
once("""\thub:_connect(box.Focused, function()
\t\ttween(boxStroke, FAST, { Color = themeColor(theme, "SubText") })
\tend)""",
     """\thub:_connect(box.Focused, function()
\t\thub:PlayUISound("InputFocus")
\t\ttween(boxStroke, FAST, { Color = themeColor(theme, "SubText") })
\tend)""", "input focus sound")
once("""\t\telse
\t\t\tself.Value = value
\t\tend
\t\trender()
\t\tif not silent then
\t\t\tself:_emit(self.Value)
\t\tend
\tend
\tfunction c:Get()""",
     """\t\telse
\t\t\tself.Value = value
\t\tend
\t\trender()
\t\tif not silent then
\t\t\thub:PlayUISound("Select")
\t\t\tself:_emit(self.Value)
\t\tend
\tend
\tfunction c:Get()""", "dropdown select sound")
once("""\tfor _, tw in self._themeTweens or {} do tw:Cancel() end
\tcancelHubMotion(self.Gui)""",
     """\tfor _, tw in self._themeTweens or {} do tw:Cancel() end
\tself:_releaseOwned()
\tcancelHubMotion(self.Gui)""", "release owned resources")

# Use preset asset IDs directly, no filesystem, keep old custom files intact.
once("""\tlocal ok, id = pcall(getcustomasset, bg.File)
\tif ok and id then""",
     """\tlocal ok, id
\tif bg.Asset and not secureAssets() then
\t\tok, id = true, bg.Asset
\telseif bg.File and hasAssets then
\t\tok, id = pcall(getcustomasset, bg.File)
\tend
\tif ok and id then""", "background direct asset support")
between("function Hub:_applyBackground()\n", "\nfunction Hub:_saveStudio(colors)",
"""function Hub:_applyBackground()
\t-- Crossfade background generations without replacing the panel or its controls.
\tlocal older = self._bgLayers or {}
\tfor _, stale in self._retiredBgLayers or {} do
\t\tcancelMotion(stale)
\t\tstale:Destroy()
\tend
\tself._retiredBgLayers = older
\tself._bgLayers = {}
\tlocal bg = self.Background
\tself.Dock.BackgroundTransparency = 0
\tif bg and (bg.Asset or (bg.File and hasAssets)) and not self.Stealth then
\t\tlocal panel = backgroundLayer(self.Panel, bg, self.Theme, 14, 0)
\t\tpanel.GroupTransparency = 1
\t\ttable.insert(self._bgLayers, panel)
\t\tif bg.Dock then
\t\t\tself.Dock.BackgroundTransparency = 1
\t\t\tlocal dock = backgroundLayer(self.DockHolder, bg, self.Theme, 12, 1, true)
\t\t\tdock.GroupTransparency = 1
\t\t\ttable.insert(self._bgLayers, dock)
\t\tend
\tend
\tfor _, layer in self._bgLayers do
\t\ttween(layer, SOFT, { GroupTransparency = 0 })
\tend
\tlocal retired = older
\tfor _, layer in retired do
\t\tif layer.Parent then tween(layer, SOFT, { GroupTransparency = 1 }) end
\tend
\tself._bgGeneration = (self._bgGeneration or 0) + 1
\tlocal generation = self._bgGeneration
\ttask.delay(SOFT.Time + 0.04, function()
\t\tfor _, layer in retired do
\t\t\tif layer.Parent then cancelMotion(layer); layer:Destroy() end
\t\tend
\t\tif not self._destroyed and self._bgGeneration == generation then
\t\t\tself._retiredBgLayers = nil
\t\tend
\tend)
end
""", "crossfade background")
between("function Hub:SetBackground(source)\n", "\n---------------------------------------------------------------- custom themes",
"""function Hub:SetBackground(source)
\tif self._destroyed then return false, "hub destroyed" end
\tself._backgroundRequest = (self._backgroundRequest or 0) + 1
\tlocal requestId = self._backgroundRequest
\tif source == nil or source == false or source == "" or source == "None" then
\t\tself.Background = nil
\telse
\t\tif type(source) == "string" or type(source) == "number" then
\t\t\tlocal asset, preset = resolveBackgroundPreset(source)
\t\t\tif not asset then return false, "unknown preset or asset ID" end
\t\t\tsource = { Asset = asset, BackgroundPreset = preset }
\t\tend
\t\tif type(source) ~= "table" then return false, "invalid background" end
\t\tif source.Preset and RiftUI.BackgroundPresets[source.Preset] and not (source.File or source.Url or source.Base64 or source.Asset) then
\t\t\tsource = { Asset = RiftUI.BackgroundPresets[source.Preset], BackgroundPreset = source.Preset,
\t\t\t\tOpacity = source.Opacity, Dim = source.Dim, Dock = source.Dock }
\t\tend
\t\tlocal asset = source.Asset and resolveBackgroundPreset(source.Asset)
\t\tlocal path, aspect
\t\tif not asset then
\t\t\tlocal ok, result, a = pcall(self._storeBackground, self, source)
\t\t\tif not ok then return false, tostring(result) end
\t\t\tpath, aspect = result, a
\t\tend
\t\tif self._destroyed or self._backgroundRequest ~= requestId then
\t\t\treturn false, "replaced by a newer background"
\t\tend
\t\tif self.Stealth and asset then return false, "image presets are disabled in stealth mode" end
\t\tlocal bg = placement(source, nil)
\t\tbg.File, bg.Asset = path, asset
\t\tbg.Aspect = aspect or 1
\t\tbg.BackgroundPreset = source.BackgroundPreset
\t\tbg.Url = source.Url
\t\tbg.Opacity = source.Opacity or (1 - (self._backgroundTransparency or .4))
\t\tbg.Dim = source.Dim or .55
\t\tbg.Dock = source.Dock == true
\t\tself.Background = bg
\tend
\tself:_applyBackground()
\tlocal studio = self.SetupData and self.SetupData.Studio
\tself:_saveStudio(studio and studio.Colors or {})
\treturn true
end
""", "background API")

# Theme cache: expensive property/color heuristics run once per live instance;
# future switches reuse explicit theme bindings and the discovered token index.
between("function Hub:_transitionTheme(name, overrides)\n", "\nfunction Hub:SetTheme(name: string)",
"""function Hub:_transitionTheme(name, overrides)
\tlocal nextTheme = buildTheme(name, overrides or self.Options.Theme)
\tlocal old = table.clone(self.Theme)
\tself._themeBindings = self._themeBindings or setmetatable({}, { __mode = "k" })
\tself._themeScanned = self._themeScanned or setmetatable({}, { __mode = "k" })
\tfor _, tw in self._themeTweens or {} do tw:Cancel() end
\tself._themeTweens = {}
\tfor _, inst in self.Gui:GetDescendants() do
\t\tlocal ancestor, skip = inst, false
\t\twhile ancestor and ancestor ~= self.Gui do
\t\t\tif ancestor:GetAttribute("ThemeSwatch") then skip = true break end
\t\t\tancestor = ancestor.Parent
\t\tend
\t\tif skip then continue end
\t\tlocal tokens = self._themeBindings[inst] or {}
\t\tlocal explicit = themeBindings[inst]
\t\tif not self._themeScanned[inst] then
\t\t\tfor _, prop in THEME_PROPERTIES do
\t\t\t\tlocal entry = explicit and explicit[prop]
\t\t\t\tif entry and entry._theme == self.Theme then
\t\t\t\t\ttokens[prop] = entry._key
\t\t\t\telse
\t\t\t\t\tlocal ok, value = pcall(function() return inst[prop] end)
\t\t\t\t\tif ok and typeof(value) == "Color3" then
\t\t\t\t\t\tfor _, key in THEME_TOKENS do
\t\t\t\t\t\t\tif value == old[key] then tokens[prop] = key break end
\t\t\t\t\t\tend
\t\t\t\t\tend
\t\t\t\tend
\t\t\tend
\t\t\tself._themeScanned[inst] = true
\t\tend
\t\tif explicit then
\t\t\tfor prop, binding in explicit do
\t\t\t\tif binding._theme == self.Theme then tokens[prop] = binding._key end
\t\t\tend
\t\tend
\t\tself._themeBindings[inst] = tokens
\t\tlocal goals = {}
\t\tfor prop, token in tokens do
\t\t\tif nextTheme[token] and nextTheme[token] ~= old[token] then goals[prop] = nextTheme[token] end
\t\tend
\t\tif next(goals) then table.insert(self._themeTweens, tween(inst, THEME_FADE, goals)) end
\tend
\tfor key, value in nextTheme do self.Theme[key] = value end
end
""", "theme binding cache")

# UI settings. Sound settings persist in the existing Hub SetupData.
once("""\t\tui:Button({
\t\t\tName = "Open theme studio",""",
     """\t\tlocal sound = self:GetUISounds()
\t\tui:Toggle({
\t\t\tName = "UI sounds", Description = "Vanta-style interface feedback",
\t\t\tDefault = sound.Enabled,
\t\t\tCallback = function(on)
\t\t\t\tself:SetUISounds({ Enabled = on })
\t\t\t\tself:_savePref("UISounds", self:GetUISounds())
\t\t\tend,
\t\t})
\t\tui:Dropdown({
\t\t\tName = "UI sound preset", Options = { "Soft", "Minimal" },
\t\t\tDefault = sound.Preset,
\t\t\tCallback = function(name)
\t\t\t\tself:SetUISounds({ Preset = name })
\t\t\t\tself:_savePref("UISounds", self:GetUISounds())
\t\t\t\tself:PlayUISound("Select")
\t\t\tend,
\t\t})
\t\tui:Slider({
\t\t\tName = "UI sound volume", Min = 0, Max = 100, Step = 5,
\t\t\tDefault = math.floor(sound.Volume * 100),
\t\t\tSuffix = "%",
\t\t\tCallback = function(v)
\t\t\t\tself:SetUISounds({ Volume = v / 100 })
\t\t\t\tself:_savePref("UISounds", self:GetUISounds())
\t\t\tend,
\t\t})
\t\tlocal backgrounds = { "None" }
\t\tfor _, name in RiftUI.BackgroundPresetOrder do table.insert(backgrounds, name) end
\t\tui:Dropdown({
\t\t\tName = "Background preset", Options = backgrounds,
\t\t\tDefault = self.Background and self.Background.BackgroundPreset or "None",
\t\t\tCallback = function(name)
\t\t\t\tlocal ok, err = self:SetBackgroundPreset(name)
\t\t\t\tif not ok then self:Notify({ Title = "Background unavailable", Content = err, Duration = 4 }) end
\t\t\tend,
\t\t})
\t\tui:Slider({
\t\t\tName = "Background opacity", Min = 0, Max = 100, Step = 5,
\t\t\tDefault = math.floor((self.Background and self.Background.Opacity or .6) * 100),
\t\t\tSuffix = "%",
\t\t\tCallback = function(v) self:SetBackgroundTransparency(1 - v / 100) end,
\t\t})
\t\tui:Button({
\t\t\tName = "Open theme studio",""", "UI sound/background settings")

p.write_text(s, encoding="utf-8")

b = Path("scripts/bundle.mjs")
src = b.read_text(encoding="utf-8")
anchor = "  ['--@@CALLBACK_SCHEDULER@@', 'lib/core/CallbackScheduler.luau'],"
assert src.count(anchor) == 1, "bundler marker missing"
src = src.replace(anchor, anchor + "\n" +
    "  ['--@@RESOURCE_SCOPE@@', 'lib/core/ResourceScope.luau'],\n" +
    "  ['--@@UI_SOUND@@', 'lib/core/UISound.luau'],\n" +
    "  ['--@@BACKGROUND_PRESETS@@', 'lib/core/BackdropPresets.luau'],")
b.write_text(src, encoding="utf-8")
print("RiftUI R2 migration patched and ready for bundling")
