#!/usr/bin/env python3
"""Static regression gates for launcher persistence, scrolling, and semantic page icons."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
source = (ROOT / "VortexionUI.lua").read_text(encoding="utf-8")

checks = {
    "disk-backed launcher position": (
        "VortexionLua_launcher_position.json" in source
        and "HttpService:JSONDecode(raw)" in source
        and "HttpService:JSONEncode({X = store.X, Y = store.Y})" in source
        and "saveLauncherPosition(self._launcherPosition, true)" in source
    ),
    "drag writes are not performed every pointer frame": (
        "saveLauncherPosition(self._launcherPosition, false)" in source
    ),
    "navigation canvas follows list size": (
        "navScroll.CanvasSize = UDim2.fromOffset(0, math.ceil(navLayout.AbsoluteContentSize.Y + 12))" in source
        and 'navLayout:GetPropertyChangedSignal("AbsoluteContentSize")' in source
    ),
    "page canvas follows content size": (
        "page.CanvasSize = UDim2.fromOffset(0, math.ceil(pageLayout.AbsoluteContentSize.Y + 32))" in source
        and 'pageLayout:GetPropertyChangedSignal("AbsoluteContentSize")' in source
        and "PageLayout=pageLayout" in source
    ),
    "Chinese and English page icon mapping": all(
        token in source for token in (
            '{"子弹追踪","zap"}', '{"碰撞箱","box"}', '{"静默","target"}',
            '{"ragebot","flame"}', '{"自瞄","crosshair"}', '{"感知","eye"}',
            '{"发电机","wrench"}', '{"刀具与手套","scissors"}',
            '{"农场","package"}', '{"大厅","home"}',
        )
    ),
    "distinct semantic vector icons": all(
        token in source for token in (
            "crosshair={", "flame={", "swords={", "scissors={", "package={",
        )
    ),
}
failed = [name for name, passed in checks.items() if not passed]
for name, passed in checks.items():
    print(("PASS" if passed else "FAIL") + " " + name)
if failed:
    raise SystemExit("Regression checks failed: " + ", ".join(failed))
