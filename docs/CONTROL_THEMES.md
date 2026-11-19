# RelaxUI visual themes (Luau)

The old **Theme** selector in Settings → Interface is now split into:

- **Color theme** (颜色主题): the existing Graphite / Ink / Slate / Ember etc. palette presets.
- **Control theme** (控件主题): **Default** (默认) or **Rounded** (圆润).

These settings are independent. The default control theme retains the original RiftUI widgets.

## Live switching

```luau
local Hub = Rift:CreateHub({
    Name = "RelaxUI",
    ColorTheme = "Graphite",
    ControlTheme = "Rounded",
})

Hub:SetColorTheme("Ink")
Hub:SetControlTheme("Default")
Hub:SetControlTheme("Rounded")
print(Hub:GetColorTheme(), Hub:GetControlTheme())
```

`SetTheme(name)` remains a supported compatibility alias for changing the **color theme**.
Switching control themes works on already-created controls; it does not replace the
controls or their Flag, Value, callback or saved setting data.

## Rounded control implementations

| Control | Actual rounded visual changes |
|---|---|
| Toggle | 38×22 pill switch with separate sliding thumb |
| Slider | 6px rounded track, circular knob, floating value bubble while dragging |
| RangeSlider | Thick rounded track and two rounded handles |
| Button | Taller rounded surface with subtle highlight and border |
| Dropdown / Keybind / PlayerPicker | Taller capsule selector |
| Segmented | Taller rounded track and separate sliding selection indicator |
| Input | Taller rounded field and focus indicator |
| ColorPicker | Larger round-edged swatch |
| Stepper | Wider and taller capsule with round buttons |
| Progress | Taller rounded progress bar |

The rounded style uses short transitions for graphic layers. Text-bearing parent
containers are not animated with `UIScale` to avoid the Roblox glyph jitter
that was previously fixed in panel open/close animations.

## Persistence

Preferences are saved under each hub's `setup.json` as `ColorTheme` and
`ControlTheme`; the legacy `Theme` field remains readable for migration.
Saved/exported config files include both choices, and load restores them.
Reinitialize preserves the active theme.

Existing scripts using `Hub:SetTheme(...)` or `ThemeName` continue working.
