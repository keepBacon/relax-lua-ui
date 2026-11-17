-- Vanta Owl self-only regression tests; deterministic Roblox stand-ins (Lua 5.1).
local function signal()
    local s={listeners={}}
    function s:Connect(fn)
        local c={active=true,fn=fn}
        function c:Disconnect()self.active=false end
        s.listeners[#s.listeners+1]=c
        return c
    end
    function s:Fire(...)
        for _,c in ipairs(s.listeners) do if c.active then c.fn(...) end end
    end
    return s
end
local all, methods={},{}
local mt={__index=function(o,k)
    if methods[k] then return methods[k] end
    for _,v in ipairs(all) do
        if not rawget(v,"destroyed") and rawget(v,"Parent")==o
            and rawget(v,"Name")==k then return v end
    end
end}
local function obj(class,name,parent)
    local v=setmetatable({
        ClassName=class,Name=name or class,Parent=parent,
        Destroying=signal(),destroyed=false
    },mt)
    all[#all+1]=v
    return v
end
function methods:FindFirstChild(name)
    for _,v in ipairs(all) do
        if not rawget(v,"destroyed") and rawget(v,"Parent")==self
            and rawget(v,"Name")==name then return v end
    end
end
function methods:FindFirstChildOfClass(class)
    for _,v in ipairs(all) do
        if not rawget(v,"destroyed") and rawget(v,"Parent")==self
            and rawget(v,"ClassName")==class then return v end
    end
end
function methods:WaitForChild(name)return assert(self:FindFirstChild(name),name) end
function methods:IsDescendantOf(parent)
    local p=rawget(self,"Parent")
    while p do if p==parent then return true end;p=rawget(p,"Parent") end
    return false
end
function methods:Destroy()
    if self.destroyed then return end
    self.destroyed=true
    self.Destroying:Fire()
    for _,v in ipairs(all) do
        if not rawget(v,"destroyed") and rawget(v,"Parent")==self then v:Destroy() end
    end
    self.Parent=nil
end
function methods:GetPropertyChangedSignal(k)
    if not self.propertySignals then self.propertySignals={} end
    if not self.propertySignals[k] then self.propertySignals[k]=signal() end
    return self.propertySignals[k]
end

Instance={new=function(class)return obj(class) end}
local function values(...)return {...}end
Color3={fromRGB=values}
Vector2={new=values}
Vector3={new=values}
UDim2={new=values,fromOffset=values,fromScale=values}
UDim={new=values}
ColorSequence={new=values}
ColorSequenceKeypoint={new=values}
NumberSequence={new=values}
NumberSequenceKeypoint={new=values}
TweenInfo={new=values}
Enum={
    Font={GothamBold="GothamBold",Michroma="Michroma"},
    TextXAlignment={Center="Center"},TextYAlignment={Center="Center"},
    TextTruncate={AtEnd="AtEnd"},ScaleType={Fit="Fit"},
    EasingStyle={Linear="Linear",Sine="Sine"},
    EasingDirection={Out="Out",InOut="InOut"},
    ApplyStrokeMode={Contextual="Contextual",Border="Border"},
    HumanoidDisplayDistanceType={None="None",Viewer="Viewer"},
}
math.clamp=function(x,lo,hi)return math.max(lo,math.min(x,hi)) end
task={spawn=function(f)f()end}
local textService={GetTextSize=function(_,name,size,font,bound)
    return {X=#name*8,Y=size}
end}
local tweenCancelled=0
local tweenCreated={}
local tweenService={Create=function(_,target,info,goal)
    local t={target=target,info=info,goal=goal,plays=0,cancels=0}
    function t:Play()self.plays=self.plays+1 end
    function t:Cancel()
        self.cancels=self.cancels+1
        tweenCancelled=tweenCancelled+1
    end
    tweenCreated[#tweenCreated+1]=t
    return t
end}
local frame=signal()
local playerAdded,playerLeaving=signal(),signal()
local localPlayer=obj("Player","Self")
localPlayer.Name="OwnUsername"
localPlayer.DisplayName="Owler"
localPlayer.UserId=1001
localPlayer.CharacterAdded=signal()
localPlayer.CharacterRemoving=signal()
local playerScripts=obj("PlayerScripts","PlayerScripts",localPlayer)
local playerGui=obj("PlayerGui","PlayerGui",localPlayer)
local friend=obj("Player","Friend")
friend.DisplayName="AnotherUser"
friend.CharacterAdded=signal()
friend.CharacterRemoving=signal()
local players={localPlayer,friend}
local ps={
    LocalPlayer=localPlayer,PlayerAdded=playerAdded,PlayerRemoving=playerLeaving,
    GetPlayers=function()return players end,
}
local function character(player,id)
    local char=obj("Model","Character"..id)
    local head=obj("Part","Head",char)
    head.Position={X=0}
    local hum=obj("Humanoid","Humanoid",char)
    hum.DisplayDistanceType=Enum.HumanoidDisplayDistanceType.Viewer
    hum.Health=100
    hum.HealthChanged=signal()
    player.Character=char
    return char,head,hum
end
local ch,head,hum=character(localPlayer,1)
local fchar,fhead=character(friend,1)
local obsolete=obj("BillboardGui","VantaOwlNameplate",fhead)
local vectorMeta={__sub=function(a,b)return {Magnitude=math.abs((a.X or 0)-(b.X or 0))}end}
workspace={CurrentCamera={CFrame={Position=setmetatable({X=0},vectorMeta)}}}
local fileWritten,requestCount,priorCleaned
priorCleaned=0
local env={__VANTA_OWL_CLEANUP=function()priorCleaned=priorCleaned+1 end}
getgenv=function()return env end
writefile=function(path,data)
    assert(path=="VantaUI_Owl_96.png")
    assert(data:sub(1,8)=="\137PNG\r\n\26\n")
    fileWritten=true
end
getcustomasset=function(path)
    assert(fileWritten and path=="VantaUI_Owl_96.png")
    return "customasset://vanta_owl_96"
end
game={
    GetService=function(_,name)
        if name=="Players" then return ps end
        if name=="RunService" then return {RenderStepped=frame} end
        if name=="TweenService" then return tweenService end
        if name=="TextService" then return textService end
        error("service "..name)
    end,
    HttpGet=function(_,url)
        requestCount=(requestCount or 0)+1
        assert(url:find("assets/owl/vanta_owl_96.png",1,true))
        return "\137PNG\r\n\26\n".."binary png bytes"
    end,
}
local mod=dofile("nameplate.lua")
local m=mod.new({Enabled=true})
assert(priorCleaned==1)
assert(obsolete.destroyed,"Previous all-player owl GUI must be removed")
assert(env.__VANTA_OWL_CLEANUP==nil)
assert(playerScripts:FindFirstChild("VantaUINameplateLifecycle")~=nil)
assert(m:GetOwlStatus()=="loaded")
assert(requestCount==1)
local ui=assert(m:GetBillboard())
assert(ui.Parent==head and ui.Adornee==head)
assert(ui.Enabled and ui.MaxDistance==60)
assert(ui.StudsOffsetWorldSpace[2]==2.5)
assert(m:GetBillboard(friend)==nil,"No extra plates for friends")
assert(fhead:FindFirstChild("VantaOwlNameplate")==nil)
assert(friend.CharacterAdded.listeners[1]==nil,"Do not subscribe to other players")
assert(hum.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.None)

local plate=ui.NameplateGroup.Plate
local content=assert(plate.Content)
local corner=assert(plate:FindFirstChildOfClass("UICorner"))
assert(corner.CornerRadius[1]==0.5 and corner.CornerRadius[2]==0)
assert(plate.BackgroundColor3[1]==5 and plate.BackgroundColor3[2]==5
    and plate.BackgroundColor3[3]==6)
assert(plate.BackgroundTransparency==0 and plate.BorderSizePixel==0)
assert(plate.Size[2]==44)
assert(plate:FindFirstChildOfClass("UIGradient")==nil,
    "Capsule fill must have no gradient")
assert(plate.OutlineLayer==nil and plate.FillLayer==nil)
assert(plate:FindFirstChild("OutlineLeftPoint")==nil)
assert(plate:FindFirstChild("SoftGlow")==nil)
local plateBorder=assert(plate.CrimsonBorderStroke)
assert(plateBorder.Thickness==2 and plateBorder.Transparency==0)
assert(plateBorder.ApplyStrokeMode==Enum.ApplyStrokeMode.Border)
assert(plateBorder.Color[1]==255 and plateBorder.Color[2]==255
    and plateBorder.Color[3]==255)
local borderGradient=assert(plateBorder.RotatingCrimsonBorder)
local borderStops=borderGradient.Color[1]
assert(#borderStops==5)
local positions={0,0.4,0.5,0.6,1}
for i=1,5 do
    assert(borderStops[i][1]==positions[i],"Border keypoint position")
    local rgb=borderStops[i][2]
    local r,g,b=90,10,28
    if i==3 then r,g,b=255,51,85 end
    assert(rgb[1]==r and rgb[2]==g and rgb[3]==b,"Border RGB")
end
assert(borderGradient.Rotation==0)
assert(#tweenCreated==2,"One stroke rotation and one name shine only")
local borderTween=tweenCreated[1]
assert(borderTween.target==borderGradient and borderTween.info[1]==3)
assert(borderTween.info[2]==Enum.EasingStyle.Linear)
assert(borderTween.info[4]==-1 and borderTween.info[5]==false)
assert(borderTween.goal.Rotation==360 and borderTween.plays==1)
for _,child in ipairs(all) do
    if child.Parent==plate then
        assert(child==corner or child==plateBorder or child==content,
            "Plate must contain only border, corner and content")
    end
end
assert(content.ZIndex==2 and content.BackgroundTransparency==1)
assert(content.Parent==plate)
local owlLeft=assert(content.LeftOwl)
local owlRight=assert(content.RightOwl)
assert(owlLeft.Image=="customasset://vanta_owl_96")
assert(owlRight.Image==owlLeft.Image)
assert(not content.LeftOwlFallback.Visible and not content.RightOwlFallback.Visible)
assert(owlLeft.Size[1]==30 and owlRight.Size[1]==30)
assert(owlLeft.Position[1]==18 and owlRight.Position[2]==-48)
assert(content.DisplayName.Text=="Owler")
assert(content.DisplayName.Font==Enum.Font.Michroma)
assert(content.DisplayName.TextSize==14)
assert(content.DisplayName.TextColor3[1]==255)
assert(content.DisplayName.TextXAlignment==Enum.TextXAlignment.Center)
local name=content.DisplayName
local crimson=assert(name.CrimsonNameGradient)
local outline=assert(name.NameOutlineStroke)
assert(plate:FindFirstChild("NameShineOverlay")==nil, "No redundant white overlay")
assert(name:FindFirstChild("ShineMask")==nil, "No secondary shine layer")
assert(outline.Thickness==1 and outline.Transparency==0.3)
assert(outline.Color[1]==26 and outline.Color[2]==0 and outline.Color[3]==8)
assert(outline.ApplyStrokeMode==Enum.ApplyStrokeMode.Contextual)
assert(name.TextYAlignment==Enum.TextYAlignment.Center)
assert(name.TextTruncate==Enum.TextTruncate.AtEnd)
assert(name.TextColor3[1]==255 and name.TextColor3[2]==255 and name.TextColor3[3]==255)
local stops=crimson.Color[1]
assert(#stops==5)
local positions={0,0.35,0.5,0.65,1}
for i=1,5 do
    assert(stops[i][1]==positions[i], "Exact red-white-red gradient keypoint")
    local rgb=stops[i][2]
    local r,g,b=255,26,61
    if i==3 then g,b=255,255 end
    assert(rgb[1]==r and rgb[2]==g and rgb[3]==b, "Exact keypoint RGB")
end
assert(crimson.Offset[1]==-1 and crimson.Offset[2]==0)
assert(crimson.Rotation==0)
assert(#tweenCreated==2, "Only rotating border and name shine")
local shineTween=tweenCreated[2]
assert(shineTween.target==crimson and shineTween.info[1]==1.4)
assert(shineTween.info[2]==Enum.EasingStyle.Sine)
assert(shineTween.info[3]==Enum.EasingDirection.InOut)
assert(shineTween.goal.Offset[1]==1 and shineTween.goal.Offset[2]==0)
assert(shineTween.plays==1)
assert(plate:FindFirstChild("TagChip")==nil)
assert(plate:FindFirstChild("HealthBar")==nil)
assert(plate:FindFirstChild("Avatar")==nil)
assert(plate.Size[1]==190 and plate.Size[2]==44)
assert(content.Size[1]==plate.Size[1] and content.Size[2]==44)
assert(name.Size[1]==190-2*30-76)
-- Name remains centered and correctly resizes without a second text layer.
localPlayer.DisplayName="SuperLongOwlDisplayName"
localPlayer:GetPropertyChangedSignal("DisplayName"):Fire()
assert(plate.Size[1]>190)
assert(content.Size[1]==plate.Size[1])
assert(plate.Position[1]==12)
assert(name.Text=="SuperLongOwlDisplayName")
assert(name.Size[1]==plate.Size[1]-2*30-76)
local fixedPosition=name.Position
local fixedColors=crimson.Color
-- 1.4s sweep finishes and resets immediately to (-1,0) for idle.
for i=1,24 do frame:Fire(0.06) end -- 1.44s
assert(shineTween.plays==1 and shineTween.cancels>=2)
assert(crimson.Offset[1]==-1 and crimson.Offset[2]==0,
    "White shine must be off-text immediately after sweep finishes")
-- No extra shine or white band for the 2.5s pause.
for i=1,40 do frame:Fire(0.06) end -- 3.84s
assert(shineTween.plays==1)
assert(crimson.Offset[1]==-1 and crimson.Offset[2]==0)
-- At 3.9s a new 1.4s sweep starts with the same single gradient.
for i=1,2 do frame:Fire(0.06) end -- 3.96s
assert(shineTween.plays==2)
assert(crimson.Offset[1]==-1 and crimson.Offset[2]==0)
assert(crimson.Color==fixedColors)
-- Across multiple cycles, never flash another color, change text position,
-- or create a leftover overlay.
for i=1,160 do frame:Fire(0.06) end
assert(shineTween.plays>=4)
assert(crimson.Color==fixedColors)
assert(name.Position==fixedPosition)
assert(outline.Transparency==0.3)
assert(plate:FindFirstChild("NameShineOverlay")==nil)
-- All animation belongs to the parent CanvasGroup and fades at distance.
workspace.CurrentCamera.CFrame.Position.X=50
frame:Fire(0.06)
assert(ui.NameplateGroup.GroupTransparency==0)
assert(name.Parent==content and content.Parent==plate)
local opacity=plate.BackgroundTransparency
assert(opacity>0 and plateBorder.Transparency==opacity,
    "Fill and animated border must fade together")
assert(name.TextTransparency==opacity and owlLeft.ImageTransparency==opacity)
assert(outline.Transparency>0.3)
workspace.CurrentCamera.CFrame.Position.X=0
frame:Fire(0.06)
assert(plate.BackgroundTransparency==0 and plateBorder.Transparency==0)
assert(name.TextTransparency==0 and outline.Transparency==0.3)
assert(ui.NameplateGroup.UIScale.Scale==1,"No distance-driven scale animation")
workspace.CurrentCamera.CFrame.Position.X=0
frame:Fire(0.06)

m:SetEnabled(false)
assert(not ui.Enabled and not m:IsEnabled())
assert(hum.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.Viewer)
m:SetEnabled(true)
assert(ui.Enabled and m:IsEnabled())
m:SetScale(130)
assert(ui.Size[1]>200)
m:SetHeight(3.2)
assert(ui.StudsOffsetWorldSpace[2]==3.2)
m:SetDistance(80)
assert(ui.MaxDistance==80)

localPlayer.CharacterRemoving:Fire(ch)
assert(m:GetBillboard()==nil)
assert(shineTween.cancels>=5)
assert(borderTween.cancels>=1,"Rotating border tween stops on removal")
assert(crimson.Offset[1]==-1 and crimson.Offset[2]==0,
    "Character removal must cancel and reset the name shine")
local newchar,newhead,newhum=character(localPlayer,2)
localPlayer.CharacterAdded:Fire(newchar)
local nextGui=assert(m:GetBillboard())
assert(nextGui.Adornee==newhead and nextGui.Parent==newhead)
assert(nextGui.Plate~=plate)
assert(nextGui.NameplateGroup.Plate.Content.LeftOwl.Image=="customasset://vanta_owl_96")
assert(nextGui.NameplateGroup.Plate.CrimsonBorderStroke.RotatingCrimsonBorder)
assert(nextGui.NameplateGroup.Plate.Content.DisplayName.CrimsonNameGradient.Offset[1]==-1)
assert(nextGui.NameplateGroup.Plate.Content.NameShineOverlay==nil)
assert(newhum.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.None)
friend.CharacterRemoving:Fire(fchar)
local f2=character(friend,2)
friend.CharacterAdded:Fire(f2)
assert(m:GetBillboard(friend)==nil)

local newer=mod.new({Enabled=false})
assert(m:GetBillboard()==nil)
assert(not newer:IsEnabled())
assert(newer:GetBillboard() and newer:GetBillboard().Enabled==false)
newer:Destroy()
assert(newer:GetBillboard()==nil)
assert(newhum.DisplayDistanceType==Enum.HumanoidDisplayDistanceType.Viewer)
assert(tweenCancelled>0)
-- Standalone wrapper must create same local-only controller.
local standalone=dofile("nameplate_standalone.lua")
assert(standalone:GetBillboard()~=nil)
assert(standalone:GetBillboard(friend)==nil)
playerLeaving:Fire(localPlayer)
assert(standalone:GetBillboard()==nil)
print("Vanta Owl: single black capsule, animated dark red border, 18px padded owls, centered red-white name shine and cleanup PASS")
