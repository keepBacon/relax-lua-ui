# RelaxUI — UI Background and Background Switching

Two complementary settings are available in **Settings → Interface** and **Settings → Background switching**.

## UI background

The original six FlowUI/AsterUI-style background presets remain available, now labeled
**UI background** (简体中文：**UI背景**). **UI background opacity** changes the picture's
opacity and preserves the existing theme-studio/custom-image functionality.

```luau
Hub:SetBackgroundPreset("Deep Violet")
Hub:SetBackgroundTransparency(0.4) -- 0 opaque; 1 transparent
Hub:SetBackgroundPreset("None")
```

## Background switching

Source switching accepts a built-in preset, Roblox image asset ID, local file, or direct
HTTP(S) image URL. URL/file images require the executor's file/custom-asset APIs, while
Roblox asset IDs use Roblox assets directly when not in secure/stealth mode.

```luau
Hub:SetBackgroundTransition("Crossfade") -- "Crossfade", "Fade", "Instant"
Hub:SwitchBackground("Amber Glow")
Hub:SwitchBackground("rbxassetid://136310484943077")
Hub:SwitchBackground("https://example.com/image.png")
Hub:SwitchBackground("myimages/background.png")
Hub:SwitchBackground(nil) -- remove image
```

`SetBackground(...)` and `SetBackgroundPreset(...)` remain supported. Background
transitions are applied only to background layers; no text-carrying GUI hierarchy is
recreated during a background switch. URL-loaded background images use a
content-addressed cache to prevent replacing a still-fading image.

### Transition behavior

| Mode | Behavior |
|---|---|
| Crossfade | Incoming image fades in while the previous image fades out. |
| Fade | Old image fades out, then the incoming image fades in. |
| Instant | Old image is removed and the new image is immediately visible. |

**Stable text animation:** Main-panel, child-window, authentication-card, dock and
command-palette open/close transitions avoid scaling or translating containers holding
text. Their panel/outline transparency effects remain animated.

The entry `p` still opens the full preview with the **DEMO** key gate.
