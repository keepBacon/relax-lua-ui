import assert from 'node:assert/strict'
import { readFileSync } from 'node:fs'
const read = p => readFileSync(new URL('../'+p, import.meta.url), 'utf8')
const runtime = read('lib/RiftUI.luau')
const bundle = read('public/RiftUI.luau')
const build = read('scripts/bundle.mjs')
const preview = read('public/RelaxUI_Preview.luau')
const modules = [
  ['ContextMenu', 'CONTEXT_MENU', ['Hub:OpenContextMenu', 'Hub:BindContextMenu', 'Section:ContextMenu']],
  ['SearchSelect', 'SEARCH_SELECT', ['Section:SearchSelect']],
  ['Accordion', 'ACCORDION', ['Section:Accordion']],
]
for(const [file, marker, methods] of modules){
  const source = read('lib/core/'+file+'.luau')
  assert.ok(runtime.includes('--@@'+marker+'@@'), 'missing marker for '+file)
  assert.ok(build.includes('lib/core/'+file+'.luau'), 'missing build map for '+file)
  assert.ok(bundle.includes(source.trim()), 'published bundle stale for '+file)
  assert.ok(!bundle.includes('--@@'+marker+'@@'), 'unexpanded public marker for '+file)
  for(const method of methods) assert.ok(source.includes('function '+method+'('), 'missing API '+method)
  assert.ok(preview.includes(':'+file+'('), 'instant preview missing '+file)
}
assert.match(read('lib/core/ContextMenu.luau'), /InputBegan/, 'mobile right click/long press absent')
assert.match(read('lib/core/ContextMenu.luau'), /task\.delay\(math\.clamp/, 'long press should be bounded')
assert.match(read('lib/core/ContextMenu.luau'), /Children/, 'nested submenu support missing')
assert.match(read('lib/core/SearchSelect.luau'), /local maxVisible = math\.clamp/, 'bounded selection viewport absent')
assert.match(read('lib/core/SearchSelect.luau'), /function c:SetOptions\(/, 'dynamic options absent')
assert.match(read('lib/core/SearchSelect.luau'), /function c:GetRecent\(/, 'recent selection history absent')
const selector = read('lib/core/SearchSelect.luau')
assert.match(selector, /tonumber\(options.Width\) or 176/, 'default menu must stay close to selector width')
assert.match(selector, /hub:_openPopup\(chip, pane, disconnectPopup, \{\s*Align = "Center",\s*Gap = 3,\s*PreferBelow = true/,
  'selector menu should be centered 3 logical px from the trigger, below when space allows')
assert.match(runtime, /function Hub:_openPopup\(anchor: GuiObject, frame: GuiObject, onClose, placement\)/,
  'popup manager must accept optional per-control placement')
assert.match(runtime, /if placement.Align == "Center" then/,
  'popup center alignment must be implemented')
assert.match(runtime, /local gap = math.clamp\(tonumber\(placement.Gap\) or 6, 0, 16\)/,
  'popup must apply optional spacing without changing legacy default')
assert.match(bundle, /Align = "Center",\s*Gap = 3,\s*PreferBelow = true/,
  'standalone release must contain SearchSelect placement')

const selectCode = read('lib/core/SearchSelect.luau')
const contextCode = read('lib/core/ContextMenu.luau')
const accordionCode = read('lib/core/Accordion.luau')
assert.match(selectCode, /function c:SetOptions\(source, silent\)/, 'SetOptions must allow pruning without callbacks')
assert.match(selectCode, /elseif self.Value ~= nil and not known\[self.Value\]/,
  'single select must clear values no longer in the option set')
assert.match(selectCode, /if not selectedItem or selectedItem.Disabled == true/,
  'disabled options must be rejected in the callback')
assert.match(selectCode, /local viewportHeight = optionsViewport.AbsoluteSize.Y/,
  'virtual row pool must account for viewport shrinkage')
assert.match(selectCode, /GetPropertyChangedSignal\("AbsoluteSize"\)/,
  'row pool must update after popup resize')
assert.match(contextCode, /os.clock\(\) - suppressed < \.3/,
  'long-press tap suppression must expire')
assert.match(contextCode, /local gestureConns = \{\}/,
  'global touch event connections are scoped to active gesture')
assert.match(contextCode, /UserInputService\.InputChanged:Connect/,
  'off-anchor movement must cancel pending long press')
assert.match(contextCode, /UserInputService\.InputEnded:Connect/,
  'off-anchor release must cancel pending long press')
assert.match(contextCode, /other ~= input and other\.UserInputType == Enum\.UserInputType\.Touch/,
  'multi-touch cancels context long press')
assert.match(contextCode, /for _, connection in gestureConns do connection:Disconnect\(\) end/,
  'temporary gesture listeners must be removed')
assert.match(accordionCode, /function c:MatchesSearch\(query\)/,
  'Accordion should match item titles and contents')
assert.match(accordionCode, /if searchPeek then/,
  'Accordion filtered search should temporarily take precedence over user expansion')
assert.match(accordionCode, /return searchMatches == nil or searchMatches\[id\] == true/,
  'Accordion search should expand only matched items')
assert.match(accordionCode, /RiftUI.Flags\[self.Flag\] = nil/,
  'destroyed Accordion must unregister its Flag')
assert.match(accordionCode, /table.remove\(hub._recipe, i\)/,
  'destroyed Accordion must not be replayed during reinitialize')
assert.match(runtime, /matched = control:MatchesSearch\(query\)/,
  'global search must consult Accordion contents')
assert.match(read('lib/core/Accordion.luau'), /function c:_setSearchPeek\(/, 'search peeking absent')
assert.match(read('lib/core/Accordion.luau'), /function c:SetItems\(/, 'dynamic item update absent')
assert.match(runtime, /SearchSelect = true, Accordion = true/, 'named configs should retain new controls')

assert.match(selector, /if popup and optionsViewport then c:_render\(\) end/,
  'multi-select changes should repaint without resetting scroll')
assert.match(selector, /local visibleCount = math.max\(1, math.min\(maxVisible, #filtered\)\)/,
  'filtered list determines popup height')
assert.match(selector, /local initialVisible = math.max\(1, math.min\(maxVisible, #self.Options\)\)/,
  'first popup height must match real option count')
assert.match(selector, /44 \+ initialVisible \* rowHeight \+ 10/,
  'initial popup height must match the adaptive height formula')
assert.match(selector, /hub:_placePopup\(hub\._popup, false\)/,
  'filter height changes must re-anchor the shared popup')
assert.match(contextCode, /self\._popup\.Frame ~= frame/,
  'context menu action must own the exact active popup')
assert.match(contextCode, /type\(options\.CanOpen\) == "function" and not options\.CanOpen\(\)/,
  'right-click and long-press ContextMenu opens must honor availability')
assert.match(contextCode, /CanOpen = function\(\) return c:IsAvailable\(\) end/,
  'Section context menu must apply the control Locked state to all gestures')
assert.match(contextCode, /if not c:IsAvailable\(\) then return end\s+c.Value = id/,
  'actions must not execute if the control locks after its popup opens')
assert.match(contextCode, /Align = "Left",\s*Gap = 3,\s*PreferBelow = true/,
  'context menu should follow its trigger')
assert.match(runtime, /AutomaticCanvasSize = Enum\.AutomaticSize\.None,[\s\S]*?Parent = page/,
  'page scrolling must use explicitly computed content canvas')
assert.match(runtime, /local function updateCanvas\(\)/,
  'dynamic nested content must synchronize page canvas')
assert.match(runtime, /layout:GetPropertyChangedSignal\("AbsoluteContentSize"\)/,
  'page canvas must respond to child list layout changes')
assert.match(accordionCode, /slot\.Content\.AbsoluteSize\.Y/,
  'accordion expansion must include actual content frame height')
assert.match(accordionCode, /self\.Tab:_syncCanvas\(\)/,
  'accordion reveal must synchronize page canvas before scrolling')
assert.match(selector, /optionsViewport\.ScrollingEnabled = overflow/,
  'non-overflowing selectors must not show a fake scrollbar')
assert.match(selector, /optionsViewport\.ScrollBarThickness = overflow and 3 or 0/,
  'selector scrollbar must be disabled when not scrollable')
assert.match(selector, /InnerScroll = optionsViewport/,
  'SearchSelect must own its scroll instead of competing with outer popup')
assert.match(runtime, /p\.Scroll\.ScrollingEnabled = outerScroll/,
  'shared popup viewport must not intercept nested selector scrolling')
assert.match(accordionCode, /local function revealExpanded\(slot\)/,
  'opening accordion must reveal the expanded item')
assert.match(accordionCode, /node:IsA\("ScrollingFrame"\)/,
  'expanded item must use nearest scroll viewport')
assert.match(accordionCode, /revealSerial \+= 1/,
  'late scroll operations must be cancellable')
assert.ok(preview.includes('string.upper(key) == "DEMO"'), 'do not bypass demo auth')
assert.match(read('.github/workflows/verify-subtabs-lune.yml'), /lune run tests\/p2-controls-lune/)

const emptyCode = read('lib/core/EmptyState.luau')
const inlineCode = read('lib/core/InlineAction.luau')
const formCode = read('lib/core/Form.luau')
const sharedState = read('lib/core/StatusList.luau')
for (const [file, marker, methods] of [
  ['EmptyState', 'EMPTY_STATE', ['Section:EmptyState', 'Section:Skeleton', 'Hub:_createDataState']],
  ['InlineAction', 'INLINE_ACTION', ['Section:InlineAction']],
  ['Form', 'FORM', ['Section:Form']],
]) {
  const source = read('lib/core/' + file + '.luau')
  assert.ok(runtime.includes('--@@' + marker + '@@'), 'missing source marker ' + file)
  assert.ok(build.includes('lib/core/' + file + '.luau'), 'missing bundle module ' + file)
  assert.ok(bundle.includes(source.trim()), 'published bundle outdated ' + file)
  for (const method of methods) assert.ok(source.includes('function ' + method + '('), 'missing API ' + method)
  assert.ok(preview.includes(':' + file + '('), 'interactive preview missing ' + file)
}
assert.match(emptyCode, /function view:Set\(mode, data\)/)
assert.match(emptyCode, /function view:Destroy\(\)/)
assert.match(emptyCode, /function Section:Skeleton\(options\)/)
assert.match(emptyCode, /Name = "SkeletonRows"/)
assert.doesNotMatch(emptyCode, /RenderStepped|Heartbeat|while true/, 'skeleton must have no idle loop')
assert.match(sharedState, /hub:_createDataState\(shell,/, 'StatusList must reuse the shared data-state presentation')
assert.match(inlineCode, /function c:SetActions\(newActions\)/)
assert.match(inlineCode, /function c:SetActionLocked\(id, locked, reason\)/)
assert.match(inlineCode, /hub:OpenContextMenu\(more, menuActions/, 'overflow must reuse popup manager')
assert.match(inlineCode, /local space = math.max\(42, width - reserve - 8\)/)
assert.match(formCode, /function c:Validate\(\)/)
assert.match(formCode, /function c:GetValues\(\)/)
assert.match(formCode, /function c:Reset\(silent\)/)
assert.match(formCode, /function c:Submit\(\)/)
assert.match(formCode, /function c:FinishSubmit\(success, message\)/)
assert.match(runtime, /Accordion = true, Form = true/, 'Form flags should save and restore')
assert.match(accordionCode, /function c:ExpandAll\(silent\)/)
assert.match(accordionCode, /function c:CollapseAll\(silent\)/)
assert.match(accordionCode, /function c:SetContent\(id, content\)/)
assert.match(accordionCode, /Name = "AccordionArrow"/)
assert.ok(preview.includes('string.upper(key) == "DEMO"'), 'DEMO must remain enforced')

console.log('P2 control wiring, release parity, preview, config and lifetime checks passed')
