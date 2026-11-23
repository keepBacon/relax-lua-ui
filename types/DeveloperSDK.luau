--!strict
-- SPDX-License-Identifier: MPL-2.0
-- Relax UI R1-R3 developer API contracts. Editor-only type module:
-- local SDK = require(path.To.DeveloperSDK)
-- type DeveloperHub = SDK.DeveloperHub
-- These aliases do not create a second runtime or alter RiftUI internals.

export type Severity = "Info" | "Warning" | "Error"
export type Diagnostic = {
    Id: number,
    Time: number,
    Severity: Severity,
    Code: string,
    Message: string,
    Context: string?,
}
export type DeveloperStats = {
    Extensions: number,
    Scopes: number,
    Listeners: number,
    Diagnostics: number,
    Events: number,
    Faults: number,
}
export type ResourceScope = {
    Name: string,
    Closed: boolean,
    Own: (self: ResourceScope, resource: any) -> any,
    Connect: (self: ResourceScope, signal: any, callback: (...any) -> ()) -> any,
    Defer: (self: ResourceScope, callback: () -> ()) -> any,
    Close: (self: ResourceScope) -> boolean,
}
export type ExtensionDescriptor = {
    Version: string?,
    Start: (hub: any, scope: ResourceScope) -> any?,
    Stop: ((hub: any, scope: ResourceScope) -> ())?,
}
export type ExtensionInfo = {
    Name: string,
    Version: string,
    State: "Active" | "Starting",
}
export type ComponentView = {
    Set: ((self: ComponentView, value: any, silent: boolean?) -> (boolean?, string?))?,
    Get: ((self: ComponentView) -> any)?,
    Destroy: ((self: ComponentView) -> ())?,
}
export type ComponentContext = {
    Hub: any,
    Section: any,
    Frame: GuiObject,
    Control: any,
    Scope: ResourceScope,
    BindToken: (self: ComponentContext, instance: Instance, property: string,
        path: string, transform: ((any, any) -> any)?) -> (any?, string?),
    Connect: (self: ComponentContext, signal: any, callback: (...any) -> ()) -> any,
    OnDestroy: (self: ComponentContext, callback: () -> ()) -> any,
    Emit: (self: ComponentContext, value: any, silent: boolean?) -> (boolean, string?),
}
export type ComponentDescriptor = {
    Version: string?,
    Height: number?,
    Default: any?,
    Persist: boolean?,
    Validate: ((value: any, options: { [string]: any }, control: any) -> (boolean, string?))?,
    Render: (context: ComponentContext, options: { [string]: any }) -> ComponentView?,
}
export type ComponentInfo = {
    Name: string,
    Version: string,
    Instances: number,
}
export type Bounds = {
    X: number,
    Y: number,
    Width: number,
    Height: number,
}
export type TokenBinding = {
    Property: string,
    Path: string,
    Overridden: boolean,
}
export type VisualNode = {
    Name: string,
    Class: string,
    Path: string,
    Parent: string,
    ZIndex: number,
    Visible: boolean,
    EffectiveVisible: boolean,
    Hitbox: Bounds,
    EffectiveHitbox: Bounds,
    FullyClipped: boolean,
    ClippedBy: { string },
    TokenBindings: { TokenBinding },
    TokenState: string?,
}
export type SnapshotOptions = {
    MaxNodes: number?,
    Filter: string?,
    IncludeHidden: boolean?,
}
export type VisualTree = {
    Version: number,
    MaxNodes: number,
    Truncated: boolean,
    MatchedAtLeast: number,
    Nodes: { VisualNode },
}
export type DeveloperReport = {
    Version: number,
    Time: number,
    Tree: VisualTree,
    Stats: DeveloperStats,
    Diagnostics: { Diagnostic },
    Extensions: { string },
    Components: { string },
}
export type VisualInspector = {
    Destroyed: boolean,
    Selected: GuiObject?,
    SelectTarget: (self: VisualInspector, target: GuiObject) -> boolean,
    GetSnapshot: (self: VisualInspector) -> { [string]: any }?,
    Refresh: (self: VisualInspector) -> boolean,
    ExportTree: (self: VisualInspector, options: SnapshotOptions?) -> (VisualTree?, string?),
    ExportReport: (self: VisualInspector, options: SnapshotOptions?) -> (DeveloperReport?, string?),
    Close: (self: VisualInspector) -> (),
    Destroy: (self: VisualInspector) -> (),
}
export type DeveloperHub = {
    CreateDeveloperScope: (self: DeveloperHub, name: string?) -> (ResourceScope?, string?),
    RegisterExtension: (self: DeveloperHub, name: string,
        descriptor: ExtensionDescriptor) -> (boolean, ExtensionInfo | string),
    UnregisterExtension: (self: DeveloperHub, name: string) -> (boolean, string?),
    GetExtension: (self: DeveloperHub, name: string) -> ExtensionInfo?,
    ListExtensions: (self: DeveloperHub) -> { string },
    OnDeveloperEvent: (self: DeveloperHub, event: string,
        callback: (any, string, any) -> (), scope: ResourceScope?) -> (any?, string?),
    EmitDeveloperEvent: (self: DeveloperHub, event: string,
        payload: any?) -> (boolean, number | string),
    ReportDeveloperDiagnostic: (self: DeveloperHub, severity: Severity, code: string,
        message: string, context: string?) -> (Diagnostic?, string?),
    GetDeveloperDiagnostics: (self: DeveloperHub, severity: Severity?) -> { Diagnostic },
    ClearDeveloperDiagnostics: (self: DeveloperHub) -> (),
    GetDeveloperStats: (self: DeveloperHub) -> DeveloperStats,
    RegisterComponent: (self: DeveloperHub, name: string,
        descriptor: ComponentDescriptor, ownerScope: ResourceScope?) -> (boolean, ComponentInfo | string),
    UnregisterComponent: (self: DeveloperHub, name: string) -> (boolean, string?),
    GetComponent: (self: DeveloperHub, name: string) -> ComponentInfo?,
    ListComponents: (self: DeveloperHub) -> { string },
    GetVisualTreeSnapshot: (self: DeveloperHub,
        options: SnapshotOptions?) -> (VisualTree?, string?),
    CaptureDeveloperReport: (self: DeveloperHub,
        options: SnapshotOptions?) -> (DeveloperReport?, string?),
    OpenVisualInspector: (self: DeveloperHub, options: { [string]: any }?) -> VisualInspector?,
    CloseVisualInspector: (self: DeveloperHub) -> boolean,
}

return {}
