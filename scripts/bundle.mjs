// Assembles the Luau artifacts the simulator and executors load:
//   public/engine.luau  - the emulated Roblox client (engine/*.luau, each file in its own scope)
//   public/RiftUI.luau  - the library, with the generated Lucide index inlined
//   public/Loader.luau  - commit-aware executor entry point
import { readFileSync, readdirSync, writeFileSync, mkdirSync } from 'node:fs'
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import { revision } from './revision.mjs'

const root = join(dirname(fileURLToPath(import.meta.url)), '..')
mkdirSync(join(root, 'public'), { recursive: true })

const files = readdirSync(join(root, 'engine')).filter((f) => f.endsWith('.luau')).sort()
const parts = files.map((f) => {
  const src = readFileSync(join(root, 'engine', f), 'utf8')
  if (f.startsWith('00-') || f.startsWith('99-')) return `-- ${f}\n${src}`
  return `-- ${f}\ndo\n${src}\nend`
})
writeFileSync(join(root, 'public/engine.luau'), parts.join('\n'))

const icons = readFileSync(join(root, 'lib/generated/icons.luau'), 'utf8').replace(/^--.*\n/, '').replace(/^return /, '')
const build = revision()
let lib = readFileSync(join(root, 'lib/RiftUI.luau'), 'utf8').replace('Version = "dev", --@@VERSION@@', 'Version = ' + JSON.stringify(build.version) + ',')
for (const [marker, path] of [
  ['--@@MOTION@@', 'lib/core/Motion.luau'],
  ['--@@OVERLAY_STACK@@', 'lib/core/OverlayStack.luau'],
  ['--@@INPUT_FOCUS@@', 'lib/core/InputFocus.luau'],
  ['--@@CONTROL_STATES@@', 'lib/core/ControlStates.luau'],
  ['--@@CUSTOM_COMPONENTS@@', 'lib/core/CustomComponents.luau'],
  ['--@@POINTER_DRAG@@', 'lib/core/PointerDrag.luau'],
  ['--@@PANEL_RESIZE@@', 'lib/core/PanelResize.luau'],
  ['--@@CALLBACK_SCHEDULER@@', 'lib/core/CallbackScheduler.luau'],
  ['--@@CONTROL_THEMES@@', 'lib/core/ControlThemes.luau'],
  ['--@@DESIGN_TOKENS_V2@@', 'lib/core/DesignTokens.luau'],
  ['--@@MODULE_CARDS@@', 'lib/core/ModuleCards.luau'],
  ['--@@DATA_LINKS@@', 'lib/core/DataLinks.luau'],
  ['--@@CONTEXT_MENU@@', 'lib/core/ContextMenu.luau'],
  ['--@@SEARCH_SELECT@@', 'lib/core/SearchSelect.luau'],
  ['--@@ACCORDION@@', 'lib/core/Accordion.luau'],
  ['--@@EMPTY_STATE@@', 'lib/core/EmptyState.luau'],
  ['--@@INLINE_ACTION@@', 'lib/core/InlineAction.luau'],
  ['--@@FORM@@', 'lib/core/Form.luau'],
  ['--@@ADAPTIVE_COMMAND_BAR@@', 'lib/core/AdaptiveCommandBar.luau'],
  ['--@@MINI_CHARTS@@', 'lib/core/MiniCharts.luau'],
  ['--@@WIDGET_PRESETS@@', 'lib/core/WidgetPresets.luau'],
  ['--@@VISUAL_INSPECTOR@@', 'lib/core/VisualInspector.luau'],
  ['--@@COMPLEX_ORDER_LIST@@', 'lib/core/OrderList.luau'],
  ['--@@COMPLEX_DATA_TABLE@@', 'lib/core/DataTable.luau'],
  ['--@@COMPLEX_STATUS_LIST@@', 'lib/core/StatusList.luau'],
  ['--@@COMPLEX_EVENT_TIMELINE@@', 'lib/core/EventTimeline.luau'],
  ['--@@COMPLEX_TREE_VIEW@@', 'lib/core/TreeView.luau'],
  ['--@@COMPLEX_VIEWPORT@@', 'lib/core/ViewportPreview.luau'],
  ['--@@TOOLBAR_ORB@@', 'lib/core/ToolbarOrb.luau'],
  ['--@@DOCK_TAB_GROUPS@@', 'lib/core/DockTabGroups.luau'],
  ['--@@SUBTABS_RUNTIME@@', 'lib/core/SubTabs.luau'],
  ['--@@RESOURCE_SCOPE@@', 'lib/core/ResourceScope.luau'],
  ['--@@DEVELOPER_KIT@@', 'lib/core/DeveloperKit.luau'],
  ['--@@UI_SOUND@@', 'lib/core/UISound.luau'],
  ['--@@BACKGROUND_PRESETS@@', 'lib/core/BackdropPresets.luau'],
  ['--@@BACKGROUND_SWITCH@@', 'lib/core/BackgroundSwitch.luau'],
  ['--@@WEATHER_BACKDROP@@', 'lib/core/WeatherBackdrop.luau'],
  ['--@@LOCALE_ZH@@', 'lib/core/Locales/zh.luau'],
]) {
  if (!lib.includes(marker)) throw new Error(`RiftUI missing module marker ${marker}`)
  const moduleCode = readFileSync(join(root, path), 'utf8')
  // Constrain module-private locals to a lexical scope. This keeps the
  // published single-file chunk below Luau's 200 active-local limit without
  // moving public methods or changing the legacy API.
  const scoped = new Set([
    'lib/core/ModuleCards.luau',
    'lib/core/ContextMenu.luau',
    'lib/core/SearchSelect.luau',
    'lib/core/Accordion.luau',
    'lib/core/EmptyState.luau',
    'lib/core/InlineAction.luau',
    'lib/core/Form.luau',
    'lib/core/AdaptiveCommandBar.luau',
    'lib/core/MiniCharts.luau',
    'lib/core/WidgetPresets.luau',
    'lib/core/VisualInspector.luau',
    'lib/core/OverlayStack.luau',
    'lib/core/InputFocus.luau',
    'lib/core/ControlStates.luau',
    'lib/core/CustomComponents.luau',
    'lib/core/ControlThemes.luau',
    'lib/core/ToolbarOrb.luau',
    'lib/core/SubTabs.luau',
    'lib/core/UISound.luau',
    'lib/core/WeatherBackdrop.luau',
    'lib/core/StatusList.luau',
    'lib/core/BackgroundSwitch.luau',
    'lib/core/ResourceScope.luau',
    'lib/core/DeveloperKit.luau',
  ])
  lib = lib.replace(marker, scoped.has(path) ? `do\n${moduleCode}\nend` : moduleCode)
}
if (!lib.includes('--@@ICONS@@')) throw new Error('lib/RiftUI.luau is missing the --@@ICONS@@ marker')
writeFileSync(join(root, 'public/RiftUI.luau'), lib.replace('--@@ICONS@@', `local ICON_INDEX = ${icons.trim()}`))
writeFileSync(join(root, 'public/Loader.luau'), readFileSync(join(root, 'lib/Loader.luau'), 'utf8'))
console.log(`bundled loader, engine (${files.length} files) and RiftUI`)
