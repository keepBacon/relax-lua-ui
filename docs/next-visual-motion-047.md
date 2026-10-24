# VortexionUI Next v0.4.7 — Aurora Glass and motion refinement

## Visual and motion changes
- Added an optional looping, muted Roblox `VideoFrame` backdrop behind the native interface. Configure it with `BackgroundVideoId` using a Roblox video asset ID; arbitrary HTTP/Raw GitHub URLs and chat attachment URLs are not valid VideoFrame sources.
- Added a tinted overlay and softened glass panels. Main window transparency defaults to 0.24 (configurable up to 0.55); content/header/sidebar translucency is slightly increased.
- Added background video play/pause lifecycle handling: pause/hide on minimize, resume on restore, retain playback time where supported, and stop/release on destroy.
- Refined the shared spring easing and default tween easing.
- Added subtle hover color and border feedback to control rows, responsive cards, dropdown options, navigation items, and primary buttons.
- Added a short spring response to the active navigation indicator and title icon, plus staggered page reveal and group expansion.
- Improved the Hero panel gradient and primary action button texture.
- Selected dropdown option hover state remains tied to the current selection to avoid stale hover colors.

## Background video setup
The uploaded 720p MP4 is prepared separately. To play it in Roblox, upload it through Roblox's video asset flow and set the resulting numeric asset ID:
```lua
local window = UI.CreateWindow({
    Transparency = 0.24,
    BackgroundVideoId = 1234567890, -- replace with your uploaded Roblox video asset ID
    BackgroundVideoEnabled = true,
    BackgroundVideoOverlayTransparency = 0.48,
})
```
Runtime toggle:
```lua
window:SetBackgroundVideo(1234567890, true)
window:SetBackgroundVideo(nil, false) -- disables playback
```

## Platform notes
- Roblox `VideoFrame` requires a Roblox-hosted video asset ID and valid permissions. This release cannot automatically upload a ChatGPT attachment or assign a raw MP4 URL to `VideoFrame.Video`.
- Lighting `BlurEffect` affects the 3D scene, not other ScreenGui layers.
- Static source checks passed. Actual Roblox/Android playback and frame-rate validation remain outstanding.
