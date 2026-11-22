-- SPDX-License-Identifier: MPL-2.0
-- Design Tokens v2. Semantic palette + independent geometry, type, motion and
-- interaction states. No new RenderStepped loops or per-control polling.
do
    local semanticColors = {
        Surface0 = "Panel", Surface1 = "Field", Surface2 = "Tile",
        SurfaceActive = "TileActive",
        BorderSubtle = "PanelStroke", BorderStrong = "TileActiveStroke",
        TextPrimary = "Text", TextSecondary = "SubText", TextMuted = "Muted",
        Accent = "Accent", AccentText = "AccentText",
        Success = "Success", Warning = "Warning", Danger = "Danger",
        Focus = "Accent", Track = "Track", Knob = "Knob",
        DialogSurface = "Panel", DialogBodySurface = "Field",
        DialogIconSurface = "Field", DialogScrim = "Scrim",
        DialogBorder = "PanelStroke", DialogTitle = "Text",
        DialogBodyText = "SubText", DialogDetailText = "Muted",
        DialogIcon = "Text", DialogCloseIcon = "SubText",
        DialogButtonSurface = "Tile", DialogButtonText = "Text",
        DialogButtonBorder = "FieldStroke", DialogPrimarySurface = "Accent",
        DialogPrimaryText = "AccentText", DialogDangerText = "Danger",
        DialogErrorText = "Danger", LockShade = "Scrim", LockIcon = "Text",
        ButtonSurface = "Tile", ButtonHover = "TileHover",
        ButtonText = "Text", ButtonBorder = "TileStroke",
        InputSurface = "Field", InputText = "Text",
        InputBorder = "FieldStroke", PopupSurface = "Panel",
        PopupBorder = "PanelStroke", PopupItemSurface = "Tile",
        PopupItemText = "Text", PopupItemSelected = "TileActive",
    }
    local geometry = {
        Radius = { XS = 6, S = 8, M = 12, L = 16, Pill = 999 },
        Spacing = { XS = 4, S = 8, M = 12, L = 16, XL = 24 },
        Typography = {
            Head = { Size = 15, Weight = "SemiBold", LineHeight = 1.10 },
            Body = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            Meta = { Size = 11, Weight = "Medium", LineHeight = 1.20 },
            DialogTitle = { Size = 15, Weight = "SemiBold", LineHeight = 1.10 },
            DialogBody = { Size = 12, Weight = "Regular", LineHeight = 1.20 },
            DialogDetail = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            DialogButton = { Size = 12, Weight = "Medium", LineHeight = 1.10 },
            DialogError = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            ButtonLabel = { Size = 13, Weight = "Medium", LineHeight = 1.10 },
            ControlLabel = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            ControlDescription = { Size = 11, Weight = "Regular", LineHeight = 1.20 },
            PopupItem = { Size = 13, Weight = "Regular", LineHeight = 1.15 },
            ModuleTitle = { Size = 16, Weight = "SemiBold", LineHeight = 1.10 },
            ModuleSummary = { Size = 13, Weight = "Regular", LineHeight = 1.20 },
        },
        Components = {
            Dialog = {
                Width = 382, MinWidth = 260, MaxWidth = 460, MaxHeight = 600,
                MinViewportHeight = 210, EdgeInset = 16, Radius = 16,
                PaddingX = 18, PaddingY = 16, Gap = 10,
                HeadingHeight = 34, IconPlateSize = 32, IconPlateRadius = 10,
                IconSize = 18, CloseSize = 36, CloseIconSize = 17,
                TitleGap = 10, TitleTop = 2,
                BodyRadius = 10, BodyPaddingX = 12, BodyPaddingY = 10,
                BodyGap = 10, BodyMinHeight = 36, BodyMaxHeight = 170,
                BodyTransparency = .35, ScrimTransparency = .46,
                ButtonHeight = 36, ButtonGap = 7, ButtonMinWidth = 88,
                ButtonMaxWidth = 148, ButtonRadius = 9, MaxHorizontalButtons = 3,
                LockTransparency = .40, LockRadius = 8,
                LockPlateSize = 36, LockIconSize = 19,
            },
            Button = { Height = 28, RoundedExtraHeight = 2, Radius = 6,
                RoundedRadius = 12, PaddingX = 14, IconSize = 14 },
            Popup = { Width = 190, Radius = 10, EdgeInset = 8,
                Gap = 6, ItemHeight = 28, IconSize = 14 },
            Input = { Height = 26, Radius = 6, ChipHeight = 24,
                ChipRadius = 6 },
            ModuleCard = { SurfaceRadius = 10, HeaderHeight = 92,
                IconSize = 52, GlyphSize = 28, SwitchWidth = 34,
                SwitchHeight = 20, HitTarget = 44, ActionHitTarget = 40 },
        },
        Motion = {
            Mode = "Full",
            Fast = { Duration = .14, Easing = "Quint", Direction = "Out" },
            Control = { Duration = .20, Easing = "Quad", Direction = "Out" },
            Panel = { Duration = .32, Easing = "Quint", Direction = "Out" },
            Dismiss = { Duration = .16, Easing = "Quad", Direction = "In" },
            Ripple = { Duration = .52, Easing = "Quart", Direction = "Out" },
        },
        State = {
            Idle = { Surface = "Surface2", Text = "TextPrimary", Opacity = 1 },
            Hover = { Surface = "SurfaceActive", Text = "TextPrimary", Opacity = 1 },
            Pressed = { Surface = "SurfaceActive", Text = "Accent", Opacity = 1 },
            Focused = { Surface = "Surface1", Text = "Accent", Opacity = 1 },
            Disabled = { Surface = "Surface1", Text = "TextMuted", Opacity = .55 },
            Dragging = { Surface = "SurfaceActive", Text = "Accent", Opacity = 1 },
            Loading = { Surface = "Surface1", Text = "TextSecondary", Opacity = .8 },
            Error = { Surface = "Surface1", Text = "Danger", Opacity = 1 },
        },
    }
    local function deepCopy(value)
        -- Roblox Color3 is a value type; the headless engine represents it as
        -- a readonly table. Both cases must stay atomic, never be recursed.
        if typeof(value) ~= "table" or type(value) ~= "table" then return value end
        local out = {}
        for k, v in value do out[k] = deepCopy(v) end
        return out
    end
    -- Export independent snapshots: callers modifying the public catalog must
    -- never change the schema used by existing or future hubs.
    RiftUI.DesignTokensV2 = {
        Version = 2,
        ColorRoles = deepCopy(semanticColors),
        Radius = deepCopy(geometry.Radius),
        Spacing = deepCopy(geometry.Spacing),
        Typography = deepCopy(geometry.Typography),
        Components = deepCopy(geometry.Components),
        Motion = deepCopy(geometry.Motion),
        State = deepCopy(geometry.State),
    }
    local function defaults(theme, extensions)
        local colors = {}
        for role, legacy in semanticColors do colors[role] = theme[legacy] end
        local result = deepCopy(geometry)
        for name, component in extensions or {} do
            result.Components[name] = deepCopy(component)
        end
        result.Version = 2
        result.Color = colors
        return result
    end
    local function readColor(value)
        if typeof(value) == "Color3" then return value end
        if type(value) == "string" and string.match(value, "^#?%x%x%x%x%x%x$") then
            local ok, color = pcall(Color3.fromHex, value)
            if ok then return color end
        end
        return nil
    end
    local function validate(target, supplied, schema, group)
        if type(supplied) ~= "table" then return false, group .. " must be a table" end
        for key, value in supplied do
            local sample = schema[key]
            if sample == nil then return false, "unknown token: " .. group .. "." .. tostring(key) end
            local path = group .. "." .. tostring(key)
            if group == "Color" or typeof(sample) == "Color3" then
                local color = readColor(value)
                if not color then return false, path .. " must be Color3 or #RRGGBB" end
                target[key] = color
            elseif type(sample) == "table" then
                if type(value) ~= "table" then return false, path .. " must be a table" end
                target[key] = target[key] or {}
                local ok, err = validate(target[key], value, sample, path)
                if not ok then return false, err end
            elseif type(sample) == "number" then
                if type(value) ~= "number" or value ~= value or value == math.huge or value == -math.huge then
                    return false, path .. " requires a finite number"
                end
                local lo, hi = 0, 999
                if string.find(path, "Spacing.", 1, true) then hi = 64
                elseif string.find(path, "Typography.", 1, true) then
                    lo, hi = string.find(path, ".LineHeight", 1, true) and .8 or 10,
                        string.find(path, ".LineHeight", 1, true) and 2 or 32
                elseif string.find(path, "Motion.", 1, true) then hi = 3
                elseif string.find(path, "State.", 1, true) then hi = 1
                elseif string.find(path, "Components.", 1, true) then
                    if string.find(path, "Transparency", 1, true) then hi = 1
                    elseif string.find(path, "Radius", 1, true) then hi = 100
                    else hi = 999 end
                end
                if value < lo or value > hi then return false, path .. " outside allowed range" end
                target[key] = value
            elseif type(sample) == "boolean" then
                if type(value) ~= "boolean" then return false, path .. " requires a boolean" end
                target[key] = value
            elseif type(sample) == "string" then
                if type(value) ~= "string" then return false, path .. " requires a string" end
                if key == "Mode" and group == "Motion" then
                    if value ~= "Full" and value ~= "Reduced" and value ~= "Off" then
                        return false, path .. " must be Full, Reduced or Off"
                    end
                elseif key == "Weight" then
                    if value ~= "Regular" and value ~= "Medium" and value ~= "SemiBold" and value ~= "Bold" then
                        return false, path .. " invalid font weight"
                    end
                elseif key == "Easing" then
                    if value ~= "Quint" and value ~= "Quad" and value ~= "Quart" and value ~= "Linear" then
                        return false, path .. " invalid easing"
                    end
                elseif key == "Direction" then
                    if value ~= "In" and value ~= "Out" and value ~= "InOut" then
                        return false, path .. " invalid direction"
                    end
                elseif key == "Surface" or key == "Text" then
                    if semanticColors[value] == nil then
                        return false, path .. " unknown color role"
                    end
                end
                target[key] = value
            else
                return false, path .. " unsupported value type"
            end
        end
        return true
    end
    -- Extension schemas are hub-local and flat so existing token paths,
    -- ResetToken() and the JSON-compatible setup format stay unchanged.
    local function validateComponentExtension(name, fields, registered)
        if type(name) ~= "string" or #name > 48
            or not string.match(name, "^[%a_][%w_]*$") then
            return nil, "component token name must be an identifier (max 48 characters)"
        end
        if geometry.Components[name] or registered[name] then
            return nil, "component token group already exists: " .. name
        end
        if type(fields) ~= "table" or next(fields) == nil then
            return nil, "component token defaults must be a non-empty table"
        end
        local count = 0
        for key, value in fields do
            count += 1
            if count > 64 then return nil, "component token group exceeds 64 fields" end
            if type(key) ~= "string" or #key > 48
                or not string.match(key, "^[%a_][%w_]*$") then
                return nil, "component field name must be an identifier (max 48 characters)"
            end
            if type(value) == "table" and typeof(value) == "table" then
                return nil, "component token fields must be scalar (one nesting level)"
            end
        end
        local normalized = {}
        local ok, err = validate(normalized, fields, fields, "Components." .. name)
        if not ok then return nil, err end
        return normalized
    end

    local function mergeOverrides(previous, patch, palette, extensions)
        if type(patch) ~= "table" then return nil, "token overrides must be a table" end
        if patch.Version ~= nil and patch.Version ~= 2 then
            return nil, "unsupported design token version"
        end
        local nextOverrides = deepCopy(previous)
        local schema = defaults(palette, extensions)
        for group, source in patch do
            if group ~= "Version" then
                if type(schema[group]) ~= "table" then return nil, "unknown token group: " .. tostring(group) end
                nextOverrides[group] = nextOverrides[group] or {}
                local ok, err = validate(nextOverrides[group], source, schema[group], group)
                if not ok then return nil, err end
            end
        end
        return nextOverrides
    end
    local function mergeDeep(target, source)
        for key, value in source do
            if type(value) == "table" and typeof(value) == "table"
                and type(target[key]) == "table" then
                mergeDeep(target[key], value)
            else
                target[key] = deepCopy(value)
            end
        end
    end
    local function createTokens(theme, overrides, extensions)
        local result = defaults(theme, extensions)
        mergeDeep(result, overrides)
        return result
    end
    local function encodeTokenValues(value)
        if typeof(value) == "Color3" then return "#" .. value:ToHex() end
        if type(value) ~= "table" or typeof(value) ~= "table" then return value end
        local out = {}
        for key, nested in value do out[key] = encodeTokenValues(nested) end
        return out
    end
    local function storage(overrides)
        local result = { Version = 2 }
        for group, values in overrides do
            result[group] = encodeTokenValues(values)
        end
        return result
    end
    local function pathValue(tokens, path)
        if type(path) ~= "string" then return nil end
        local current = tokens
        local count = 0
        for key in string.gmatch(path, "[^%.]+") do
            count += 1
            if count > 4 or type(current) ~= "table" then return nil end
            current = current[key]
            if current == nil then return nil end
        end
        return current
    end
    -- Validate canonical leaf and nested override paths before selective reset.
    local function tokenPathParts(path, theme)
        if type(path) ~= "string" or string.sub(path, 1, 1) == "."
            or string.sub(path, -1) == "." or string.find(path, "..", 1, true) then
            return nil
        end
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        if #parts < 2 or #parts > 3 or pathValue(defaults(theme), path) == nil then return nil end
        return parts
    end
    local function assignToken(hub, inst, entry)
        if not inst or not inst.Parent then return false end
        local value = pathValue(hub.Tokens, entry.Path)
        if value == nil then return false end
        if entry.Property == "CornerRadius" and type(value) == "number" then
            value = UDim.new(0, value)
        elseif string.find(entry.Property, "Padding", 1, true) and type(value) == "number" then
            value = UDim.new(0, value)
        end
        if entry.Transform then
            local ok, mapped = pcall(entry.Transform, value, hub)
            if not ok then return false end
            value = mapped
        end
        return pcall(function() inst[entry.Property] = value end)
    end

    function Hub:_initDesignTokens(options, saved)
        local extensions = {}
        -- Custom component definitions provided at construction load before
        -- saved overrides, so named configs and persisted values resolve.
        for name, fields in type(options.TokenComponents) == "table"
            and options.TokenComponents or {} do
            local schema, err = validateComponentExtension(name, fields, extensions)
            if schema then extensions[name] = schema
            else warn("[RelaxUI Tokens] custom component ignored: " .. tostring(err)) end
        end
        self._tokenExtensions = extensions
        self._pendingComponentTokenOverrides = {}
        local overrides = {}
        for _, patch in { options.DesignTokens, saved and saved.DesignTokens } do
            if type(patch) == "table" then
                -- Preserve unknown custom component values until a script
                -- registers its schema after CreateHub. Built-ins keep strict
                -- validation; unknown top-level groups remain invalid.
                local recognized = deepCopy(patch)
                if type(recognized.Components) == "table" then
                    for name, values in recognized.Components do
                        if not geometry.Components[name] and not extensions[name] then
                            self._pendingComponentTokenOverrides[name] = deepCopy(values)
                            recognized.Components[name] = nil
                        end
                    end
                    if next(recognized.Components) == nil then recognized.Components = nil end
                end
                local nextValue = mergeOverrides(overrides, recognized, self.Theme, extensions)
                if nextValue then overrides = nextValue end
            end
        end
        self._designTokenOverrides = overrides
        self._tokenBindings = setmetatable({}, { __mode = "k" })
        self._tokenStateBindings = setmetatable({}, { __mode = "k" })
        self._designTokenListeners = {}
        self.Tokens = createTokens(self.Theme, overrides, extensions)
        self._motionMode = self.Tokens.Motion.Mode
    end

    function Hub:GetDesignTokens() return deepCopy(self.Tokens) end
    function Hub:GetDesignTokenOverrides()
        local result = storage(self._designTokenOverrides or {})
        for name, values in self._pendingComponentTokenOverrides or {} do
            result.Components = result.Components or {}
            result.Components[name] = deepCopy(values)
        end
        return result
    end
    function Hub:GetToken(path)
        return deepCopy(pathValue(self.Tokens, path))
    end
    Hub.ResolveToken = Hub.GetToken
    function Hub:GetRegisteredComponentTokens()
        return deepCopy(self._tokenExtensions or {})
    end
    function Hub:RegisterComponentTokens(name, fields)
        if self._destroyed then return false, "hub destroyed" end
        local extensions = self._tokenExtensions or {}
        local normalized, err = validateComponentExtension(name, fields, extensions)
        if not normalized then return false, err end
        local overrides = deepCopy(self._designTokenOverrides or {})
        local pending = self._pendingComponentTokenOverrides
            and self._pendingComponentTokenOverrides[name]
        if pending ~= nil then
            local nextValues = {}
            local ok, reason = validate(nextValues, pending, normalized,
                "Components." .. name)
            if ok then
                overrides.Components = overrides.Components or {}
                overrides.Components[name] = nextValues
            else
                -- An invalid saved value is not allowed to block the component
                -- itself; discard it instead of poisoning the token schema.
                warn("[RelaxUI Tokens] invalid saved component overrides: " .. tostring(reason))
            end
        end
        extensions[name] = normalized
        self._tokenExtensions = extensions
        self._designTokenOverrides = overrides
        if self._pendingComponentTokenOverrides then
            self._pendingComponentTokenOverrides[name] = nil
        end
        -- Keep the registration across Reinitialize() without storing schema
        -- metadata in user configs; other hubs still have isolated catalogs.
        -- Do not mutate a caller-owned options table shared by other hubs.
        self.Options = table.clone(self.Options)
        self.Options.TokenComponents = deepCopy(self.Options.TokenComponents or {})
        self.Options.TokenComponents[name] = deepCopy(normalized)
        self:_refreshDesignTokens()
        return true
    end
    function Hub:GetComponentTokens(name)
        if type(name) ~= "string" then return nil end
        return deepCopy(self.Tokens and self.Tokens.Components[name])
    end
    function Hub:WatchDesignTokens(callback)
        if self._destroyed then return nil, "hub destroyed" end
        if type(callback) ~= "function" then return nil, "callback must be a function" end
        local handle = { Connected = true }
        local hub = self
        self._designTokenListeners[handle] = callback
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            if hub._designTokenListeners then hub._designTokenListeners[self] = nil end
        end
        return handle
    end
    -- Subscribe to a single leaf or subtree, rather than triggering custom
    -- components for unrelated theme / geometry updates.
    local function equalTokenValues(a, b)
        if typeof(a) ~= "table" or typeof(b) ~= "table"
            or type(a) ~= "table" or type(b) ~= "table" then
            return a == b
        end
        for key, value in a do
            if not equalTokenValues(value, b[key]) then return false end
        end
        for key in b do
            if a[key] == nil then return false end
        end
        return true
    end
    function Hub:WatchToken(path, callback, immediate)
        if self._destroyed then return nil, "hub destroyed" end
        if type(path) ~= "string" or type(callback) ~= "function" then
            return nil, "token path and callback required"
        end
        local previous = self:GetToken(path)
        if previous == nil then return nil, "unknown token path" end
        local handle = self:WatchDesignTokens(function(tokens)
            local value = pathValue(tokens, path)
            if value == nil or equalTokenValues(previous, value) then return end
            previous = deepCopy(value)
            callback(deepCopy(previous), path)
        end)
        if immediate then
            local ok, err = pcall(callback, deepCopy(previous), path)
            if not ok then warn("[RelaxUI Tokens] WatchToken: " .. tostring(err)) end
        end
        return handle
    end
    function Hub:BindComponentTokens(inst, properties)
        if type(properties) ~= "table" then return nil, "properties must be a table" end
        local handles = {}
        for property, path in properties do
            local binding, err = self:BindToken(inst, property, path)
            if not binding then
                for _, prior in handles do prior:Disconnect() end
                return nil, err
            end
            table.insert(handles, binding)
        end
        local composite = { Connected = true }
        function composite:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            for _, binding in handles do binding:Disconnect() end
        end
        return composite
    end

    function Hub:_refreshDesignTokens()
        self.Tokens = createTokens(self.Theme, self._designTokenOverrides or {},
            self._tokenExtensions)
        self._motionMode = self.Tokens.Motion.Mode
        if self.Gui then self.Gui:SetAttribute("RelaxMotionMode", self._motionMode) end
        if self.RefreshControlTheme then self:RefreshControlTheme() end
        for inst, entries in self._tokenBindings or {} do
            if inst.Parent then
                for _, entry in entries do assignToken(self, inst, entry) end
            else
                for _, entry in entries do
                    if entry.Handle then entry.Handle.Connected = false end
                end
                self._tokenBindings[inst] = nil
            end
        end
        -- Stateful styling takes priority over ordinary property bindings.
        for inst, binding in self._tokenStateBindings or {} do
            if binding.Connected and inst.Parent then
                self:ApplyTokenState(inst, binding.State)
            else
                binding:Disconnect()
            end
        end
        -- Components with coupled geometry (responsive dialogs, popup lists)
        -- subscribe once. No per-control RenderStepped or background polling.
        for handle, callback in self._designTokenListeners or {} do
            if handle.Connected then
                local ok, err = pcall(callback, self.Tokens)
                if not ok then warn("[RelaxUI Tokens] refresh: " .. tostring(err)) end
            end
        end
    end

    function Hub:SetDesignTokens(patch, persist)
        if self._destroyed then return false, "hub destroyed" end
        local updated, err = mergeOverrides(self._designTokenOverrides or {}, patch,
            self.Theme, self._tokenExtensions)
        if not updated then return false, err end
        self._designTokenOverrides = updated
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", self:GetDesignTokenOverrides()) end
        return true
    end
    function Hub:ResetDesignTokens(persist)
        if self._destroyed then return false, "hub destroyed" end
        self._designTokenOverrides = {}
        self._pendingComponentTokenOverrides = {}
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", { Version = 2 }) end
        return true
    end
    function Hub:SetToken(path, value, persist)
        if type(path) ~= "string" then return false, "invalid token path" end
        local parts = {}
        for part in string.gmatch(path, "[^%.]+") do table.insert(parts, part) end
        if #parts < 2 or #parts > 3 then return false, "invalid token path" end
        local patch = {}
        local node = patch
        for i, part in parts do
            if i == #parts then node[part] = value
            else node[part] = {}; node = node[part] end
        end
        return self:SetDesignTokens(patch, persist)
    end
    -- Inspect and remove individual overrides without resetting the palette
    -- or other token values. Full nested roles may also be reset.
    function Hub:GetTokenOverride(path)
        local parts = tokenPathParts(path, self.Theme)
        if not parts then return nil end
        local node = self._designTokenOverrides or {}
        for _, key in parts do
            if type(node) ~= "table" then return nil end
            node = node[key]
            if node == nil then return nil end
        end
        return deepCopy(node)
    end
    function Hub:HasTokenOverride(path)
        return self:GetTokenOverride(path) ~= nil
    end
    function Hub:ResetToken(path, persist)
        if self._destroyed then return false, "hub destroyed" end
        local parts = tokenPathParts(path, self.Theme)
        if not parts then return false, "invalid token path" end
        local overrides = deepCopy(self._designTokenOverrides or {})
        local node, ancestors = overrides, {}
        for i = 1, #parts - 1 do
            local key = parts[i]
            if type(node[key]) ~= "table" then return true end
            table.insert(ancestors, { Node = node, Key = key })
            node = node[key]
        end
        if node[parts[#parts]] == nil then return true end
        node[parts[#parts]] = nil
        for i = #ancestors, 1, -1 do
            local entry = ancestors[i]
            if next(entry.Node[entry.Key]) ~= nil then break end
            entry.Node[entry.Key] = nil
        end
        self._designTokenOverrides = overrides
        self:_refreshDesignTokens()
        if persist ~= false then self:_savePref("DesignTokens", self:GetDesignTokenOverrides()) end
        return true
    end
    function Hub:GetMotionMode() return self._motionMode end
    function Hub:SetMotionMode(mode, persist)
        return self:SetDesignTokens({ Motion = { Mode = mode } }, persist)
    end
    function Hub:TokenTween(inst, preset, goals)
        local data = self:GetToken("Motion." .. tostring(preset or "Control"))
        if type(data) ~= "table" or type(data.Duration) ~= "number" then
            return nil, "unknown motion preset"
        end
        local easing = Enum.EasingStyle[data.Easing]
        local direction = Enum.EasingDirection[data.Direction]
        if self._motionMode == "Off" then
            cancelMotion(inst)
            for property, value in goals do setThemed(inst, property, value) end
            return nil
        end
        local duration = self._motionMode == "Reduced" and math.min(data.Duration, .06)
            or data.Duration
        return tween(inst, TweenInfo.new(duration, easing, direction), goals)
    end
    function Hub:BindToken(inst, property, path, transform)
        if self._destroyed then return nil, "hub destroyed" end
        if not inst or not inst:IsDescendantOf(self.Gui)
            or type(property) ~= "string" or type(path) ~= "string"
            or pathValue(self.Tokens, path) == nil then
            return nil, "invalid token binding"
        end
        if transform ~= nil and type(transform) ~= "function" then
            return nil, "transform must be a function"
        end
        local entries = self._tokenBindings[inst] or {}
        local entry = { Property = property, Path = path, Transform = transform }
        if not assignToken(self, inst, entry) then return nil, "token cannot be assigned to property" end
        -- Exactly one owner per instance/property: invalidate superseded handles.
        for i = #entries, 1, -1 do
            local previous = entries[i]
            if previous.Property == property then
                if previous.Handle then previous.Handle.Connected = false end
                table.remove(entries, i)
            end
        end
        self._tokenBindings[inst] = entries
        table.insert(entries, entry)
        local binding = { Connected = true }
        entry.Handle = binding
        local hub = self
        function binding:Disconnect()
            if not binding.Connected then return end
            binding.Connected = false
            local at = table.find(entries, entry)
            if at then table.remove(entries, at) end
            if #entries == 0 and hub._tokenBindings then hub._tokenBindings[inst] = nil end
        end
        return binding
    end
    function Hub:ApplyTokenState(inst, state)
        local spec = self.Tokens.State[state]
        if not inst or not spec then return false, "unknown control state" end
        local colors = self.Tokens.Color
        local ok = pcall(function()
            inst.BackgroundColor3 = colors[spec.Surface]
            inst.BackgroundTransparency = 1 - spec.Opacity
            if inst:IsA("TextButton") or inst:IsA("TextLabel") then
                inst.TextColor3 = colors[spec.Text]
            end
        end)
        return ok
    end

    -- Opt-in live semantic states; no input listeners and no per-frame work.
    function Hub:BindTokenState(inst, state)
        if self._destroyed then return nil, "hub destroyed" end
        if not inst or not inst:IsDescendantOf(self.Gui) then
            return nil, "state target must belong to this hub"
        end
        if type(state) ~= "string" or not self.Tokens.State[state] then
            return nil, "unknown control state"
        end
        local existing = self._tokenStateBindings[inst]
        if existing and existing.Connected then
            local ok, err = existing:SetState(state)
            if not ok then return nil, err end
            return existing
        end
        local hub = self
        local handle = { Connected = true, State = state }
        function handle:GetState() return self.State end
        function handle:SetState(nextState)
            if not self.Connected or hub._destroyed or not inst.Parent then
                return false, "state binding disconnected"
            end
            if type(nextState) ~= "string" or not hub.Tokens.State[nextState] then
                return false, "unknown control state"
            end
            local ok, err = hub:ApplyTokenState(inst, nextState)
            if not ok then return false, err end
            self.State = nextState
            return true
        end
        function handle:Disconnect()
            if not self.Connected then return end
            self.Connected = false
            if hub._tokenStateBindings and hub._tokenStateBindings[inst] == self then
                hub._tokenStateBindings[inst] = nil
            end
        end
        local ok, err = handle:SetState(state)
        if not ok then return nil, err end
        self._tokenStateBindings[inst] = handle
        return handle
    end

    -- GUI teardown invalidates retained handles before destroying Instances.
    function Hub:_disposeDesignTokens()
        for _, entries in self._tokenBindings or {} do
            for _, entry in entries do
                if entry.Handle then entry.Handle.Connected = false end
            end
        end
        for _, binding in self._tokenStateBindings or {} do binding.Connected = false end
        self._tokenBindings = nil
        self._tokenStateBindings = nil
        self._pendingComponentTokenOverrides = nil
        self._tokenExtensions = nil
        for handle in self._designTokenListeners or {} do handle.Connected = false end
        self._designTokenListeners = nil
    end

    function Hub:_bindDesignTokenShell()
        self.Gui:SetAttribute("RelaxMotionMode", self._motionMode)
        if self.Dock then
            self:BindToken(self.Dock, "BackgroundColor3", "Color.Surface0")
            self:BindToken(self.Dock:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.M")
        end
        if self.Panel then
            self:BindToken(self.Panel, "BackgroundColor3", "Color.Surface0")
            self:BindToken(self.Panel:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.L")
        end
        if self.PanelOutlineStroke then
            self:BindToken(self.PanelOutlineStroke, "Color", "Color.BorderSubtle")
        end
        if self.HeaderTitle then
            self:BindToken(self.HeaderTitle, "TextSize", "Typography.Head.Size")
        end
        if self.HeaderSub then
            self:BindToken(self.HeaderSub, "TextSize", "Typography.Meta.Size")
        end
        if self.Search then
            self:BindToken(self.Search, "TextSize", "Typography.Body.Size")
        end
        if self.Tooltip then
            self:BindToken(self.Tooltip:FindFirstChildOfClass("UICorner"), "CornerRadius", "Radius.S")
        end
    end
end
