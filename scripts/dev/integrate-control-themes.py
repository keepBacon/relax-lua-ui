from pathlib import Path

p = Path('lib/RiftUI.luau')
s = p.read_text(encoding='utf-8')
modified = []
def once(old, new, label):
    global s
    n=s.count(old)
    if n!=1: raise RuntimeError(f"{label}: anchor count {n}")
    s=s.replace(old,new,1)
    modified.append(label)

once('--@@CALLBACK_SCHEDULER@@\n\n--@@RESOURCE_SCOPE@@',
     '--@@CALLBACK_SCHEDULER@@\n\n--@@CONTROL_THEMES@@\n\n--@@RESOURCE_SCOPE@@',
     'insert control skin runtime')

once('''\ttable.insert(self.Controls, control)
\tself.Hub:_record(self, kind, rawArgs or options, control)
\treturn control
end''',
     '''\ttable.insert(self.Controls, control)
\tself.Hub:_attachControlTheme(control)
\tself.Hub:_record(self, kind, rawArgs or options, control)
\treturn control
end''',
     'attach theme to existing control after construction')

once('''\tlocal themeName = (saved and saved.Theme) or options.ThemeName or "Graphite"''',
     '''\tlocal themeName = (saved and (saved.ColorTheme or saved.Theme)) or options.ColorTheme or options.ThemeName or "Graphite"''',
     'load saved color theme')

once('''\t\tThemeName = themeName,
\t\tToggleKey = toggleKey,''',
     '''\t\tThemeName = themeName,
\t\t_controlTheme = (saved and saved.ControlTheme == "Rounded") and "Rounded" or
\t\t\t(options.ControlTheme == "Rounded" and "Rounded" or "Default"),
\t\tToggleKey = toggleKey,''',
     'load control theme at startup')

once('''\tif self._themeControl then self._themeControl:Set(name, true) end
\tlocal data = self.SetupData or {}
\tdata.Theme = name''',
     '''\tif self._themeControl then self._themeControl:Set(name, true) end
\tlocal data = self.SetupData or {}
\tdata.Theme = name
\tdata.ColorTheme = name''',
     'persist renamed color theme without breaking existing setup')

once('''\tdata.Theme = self.ThemeName
\tdata.Studio = { Colors = colors, Background = self.Background }''',
     '''\tdata.Theme = self.ThemeName
\tdata.ColorTheme = self.ThemeName
\tdata.ControlTheme = self:GetControlTheme()
\tdata.Studio = { Colors = colors, Background = self.Background }''',
     'preserve theme preferences on theme-studio save')

once('''\t\tself._themeControl = ui:Dropdown({
\t\t\tName = "Theme",
\t\t\tOptions = themeNames,
\t\t\tDefault = self.ThemeName,
\t\t\tCallback = function(name)
\t\t\t\tif name ~= self.ThemeName then
\t\t\t\t\tself:SetTheme(name)
\t\t\t\tend
\t\t\tend,
\t\t})
\t\tlocal sound = self:GetUISounds()''',
     '''\t\tself._themeControl = ui:Dropdown({
\t\t\tName = "Color theme",
\t\t\tOptions = themeNames,
\t\t\tDefault = self.ThemeName,
\t\t\tCallback = function(name)
\t\t\t\tif name ~= self.ThemeName then
\t\t\t\t\tself:SetColorTheme(name)
\t\t\t\tend
\t\t\tend,
\t\t})
\t\tself._controlThemeControl = ui:Dropdown({
\t\t\tName = "Control theme",
\t\t\tOptions = { "Default", "Rounded" },
\t\t\tDefault = self:GetControlTheme(),
\t\t\tCallback = function(name)
\t\t\t\tself:SetControlTheme(name)
\t\t\tend,
\t\t})
\t\tlocal sound = self:GetUISounds()''',
     'replace old Theme selector with Color theme and Control theme')

once('''\tlocal data = { Flags = self:_flagValues(), Pins = {}, ToggleKey = self.ToggleKey.Name, Scale = self._scale, CommandKey = self.CommandKey.Name, SavedAt = os.time() }''',
     '''\tlocal data = { Flags = self:_flagValues(), Pins = {}, ToggleKey = self.ToggleKey.Name, Scale = self._scale,
\t\tColorTheme = self:GetColorTheme(), ControlTheme = self:GetControlTheme(),
\t\tCommandKey = self.CommandKey.Name, SavedAt = os.time() }''',
     'include color/control theme in exported config')

once('''\tif data.Scale then self:SetScale(data.Scale) end
\tfor _, tab in self.Tabs do''',
     '''\tif data.Scale then self:SetScale(data.Scale) end
\tif type(data.ColorTheme) == "string" then self:SetColorTheme(data.ColorTheme) end
\tif data.ControlTheme == "Default" or data.ControlTheme == "Rounded" then
\t\tself:SetControlTheme(data.ControlTheme)
\tend
\tfor _, tab in self.Tabs do''',
     'restore color/control theme from config')

once('''\tself._capturedDrag = nil
\tcancelHubCallbacks(self)''',
     '''\tself._capturedDrag = nil
\tself._skinEntries = nil
\tcancelHubCallbacks(self)''',
     'dispose control skin registry on hub destruction')

# Reinitialize uses SetupData from disk; ensure live unsaved mode wins.
once('''\t\tlocal rebuildOptions = table.clone(self.Options)
\t\trebuildOptions.Stealth = stealth''',
     '''\t\tlocal rebuildOptions = table.clone(self.Options)
\t\trebuildOptions.ControlTheme = self:GetControlTheme()
\t\trebuildOptions.ColorTheme = self:GetColorTheme()
\t\trebuildOptions.Stealth = stealth''',
     'preserve themes through reinitialization')

p.write_text(s,encoding='utf-8')

bundle = Path('scripts/bundle.mjs')
b = bundle.read_text(encoding='utf-8')
anchor = "  ['--@@CALLBACK_SCHEDULER@@', 'lib/core/CallbackScheduler.luau'],"
assert b.count(anchor)==1, 'bundle anchor missing'
b=b.replace(anchor,anchor+"\n  ['--@@CONTROL_THEMES@@', 'lib/core/ControlThemes.luau'],",1)
bundle.write_text(b,encoding='utf-8')

locale = Path('lib/core/Locales/zh.luau')
l=locale.read_text(encoding='utf-8')
marker='\t["Theme"] = "主题",'
assert l.count(marker)==1, 'locale old theme anchor'
l=l.replace(marker,'''\t["Color theme"] = "颜色主题",
\t["Control theme"] = "控件主题",
\t["Default"] = "默认",
\t["Rounded"] = "圆润",''',1)
locale.write_text(l,encoding='utf-8')

preview=Path('examples/showcase.luau')
v=preview.read_text(encoding='utf-8')
old='Look:Segmented({ Options = { "Graphite", "Ink", "Slate", "Ember" }, Default = Hub.ThemeName, Callback = function(name) Hub:SetTheme(name) end })'
assert v.count(old)==1,'preview theme anchor'
v=v.replace(old,'''Look:Dropdown({
\tName = "Color theme",
\tOptions = { "Graphite", "Ink", "Slate", "Ember" },
\tDefault = Hub:GetColorTheme(),
\tCallback = function(name) Hub:SetColorTheme(name) end,
})
Look:Dropdown({
\tName = "Control theme",
\tOptions = { "Default", "Rounded" },
\tDefault = Hub:GetControlTheme(),
\tCallback = function(name) Hub:SetControlTheme(name) end,
})''',1)
old='["UI sound volume"] = "音效音量",'
assert v.count(old)==1,'preview locale anchor'
v=v.replace(old,old+' ["Color theme"] = "颜色主题", ["Control theme"] = "控件主题",\n\t\t\t["Default"] = "默认", ["Rounded"] = "圆润",',1)
preview.write_text(v,encoding='utf-8')

print('Applied',len(modified),'verified runtime integration edits:',', '.join(modified))
