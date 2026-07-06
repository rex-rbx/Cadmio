local fs = require("@lune/fs")
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local task = require("@lune/task")
local serde = require("@lune/serde")
local roblox = require("@lune/roblox")
local luau = require("@lune/luau")
local net = require("@lune/net")

local Settings = {
    out = "out.lua",
    timeout = 60,
    ipt = nil :: string?,
    beautify = true,
    inline = true,
}
for _, arg in process.args do
    local k, v = string.match(arg, "([%w_]+)=(.+)")
    if k then
        if v:sub(1,1) == "'" and v:sub(-1) == "'" then v = v:sub(2, -2)
        elseif v:sub(1,1) == '"' and v:sub(-1) == '"' then v = v:sub(2, -2) end
        Settings[k] = if v == "true" then true elseif v == "false" then false elseif tonumber(v) then tonumber(v) else v
    else
        local val = arg
        if val:sub(1,1) == "'" and val:sub(-1) == "'" then val = val:sub(2, -2)
        elseif val:sub(1,1) == '"' and val:sub(-1) == '"' then val = val:sub(2, -2) end
        if not Settings.ipt and not string.match(val, "^%-") then
            Settings.ipt = val
        end
    end
end

local serviceNames = {
    Players = "Players",
    Workspace = "Workspace",
    ReplicatedStorage = "ReplicatedStorage",
    ServerStorage = "ServerStorage",
    ServerScriptService = "ServerScriptService",
    StarterGui = "StarterGui",
    StarterPack = "StarterPack",
    StarterPlayer = "StarterPlayer",
    Lighting = "Lighting",
    SoundService = "SoundService",
    Chat = "Chat",
    RunService = "RunService",
    UserInputService = "UserInputService",
    TweenService = "TweenService",
    GroupService = "GroupService",
    AnimationClipProvider = "AnimationClipProvider",
    HttpService = "HttpService",
    MarketplaceService = "MarketplaceService",
    TeleportService = "TeleportService",
    PathfindingService = "PathfindingService",
    CollectionService = "CollectionService",
    PhysicsService = "PhysicsService",
    ProximityPromptService = "ProximityPromptService",
    ContextActionService = "ContextActionService",
    GuiService = "GuiService",
    HapticService = "HapticService",
    VRService = "VRService",
    CoreGui = "CoreGui",
    Teams = "Teams",
    InsertService = "InsertService",
    DataStoreService = "DataStoreService",
    MessagingService = "MessagingService",
    TextService = "TextService",
    TextChatService = "TextChatService",
    NetworkClient = "NetworkClient",
    ContentProvider = "ContentProvider",
    Debris = "Debris",
    MemStorageService = "MemStorageService",
    ChangeHistoryService = "ChangeHistoryService",
    PlayerEmulatorService = "PlayerEmulatorService",
    StylingService = "StylingService",
    ScriptContext = "ScriptContext",
    LocalizationService = "LocalizationService",
    PolicyService = "PolicyService",
    CaptureService = "CaptureService",
    AnalyticsService = "AnalyticsService",
    EncodingService = "EncodingService",
    CorePackages = "CorePackages",
    RobloxReplicatedStorage = "RobloxReplicatedStorage",
    RobloxGui = "RobloxGui",
    AvatarEditorService = "AvatarEditorService",
    SocialService = "SocialService",
    VoiceChatService = "VoiceChatService",
    AdService = "AdService",
    GeometryService = "GeometryService",
    AssetService = "AssetService",
    LocalizationService = "LocalizationService",
    NotificationService = "NotificationService",
    ProcessInstancePhysicsService = "ProcessInstancePhysicsService",
    FriendService = "FriendService",
    SessionService = "SessionService",
    TimerService = "TimerService",
    TouchInputService = "TouchInputService",
    GamepadService = "GamepadService",
    KeyboardService = "KeyboardService",
    MouseService = "MouseService",
    OmniRecommendationsService = "OmniRecommendationsService",
    PerformanceService = "PerformanceService",
    PlatformFriendService = "PlatformFriendService",
    ReplicatedFirst = "ReplicatedFirst",
    SpawnLocation = "SpawnLocation",
    LogService = "LogService",
    Stats = "Stats",
    TweenService = "TweenService",
    Debris = "Debris",
    CoreGui = "CoreGui",
    MarketplaceService = "MarketplaceService",
    NotificationService = "NotificationService",
    GuidRegistryService = "GuidRegistryService",
    NetworkServer = "NetworkServer",
    Geometry = "Geometry",
    VirtualInputManager = "VirtualInputManager",
    MLModelDeliveryService = "MLModelDeliveryService",
    PartyEmulatorService = "PartyEmulatorService",
    PlatformFriendsService = "PlatformFriendsService",
    FriendService = "FriendService",
    OmniRecommendationsService = "OmniRecommendationsService",
    PerformanceControlService = "PerformanceControlService",
    RbxAnalyticsService = "RbxAnalyticsService",
    AbuseReportService = "AbuseReportService",
    AdService = "AdService",
    AdPortalService = "AdPortalService",
    AppUpdateService = "AppUpdateService",
    BrowserService = "BrowserService",
    CookiesService = "CookiesService",
    CoreGui = "CoreGui",
    GamesService = "GamesService",
    KeyboardService = "KeyboardService",
    MarketplaceService = "MarketplaceService",
    MouseService = "MouseService",
    NotificationService = "NotificationService",
    PurchaseDataService = "PurchaseDataService",
    TimerService = "TimerService",
    UGCValidationService = "UGCValidationService",
}
local serviceShortcuts = {
    Players = "Players",
    UserInputService = "UIS",
    RunService = "RunService",
    ReplicatedStorage = "ReplicatedStorage",
    TweenService = "TweenService",
    Workspace = "Workspace",
    Lighting = "Lighting",
    StarterGui = "StarterGui",
    CoreGui = "CoreGui",
    HttpService = "HttpService",
    MarketplaceService = "MarketplaceService",
    DataStoreService = "DataStoreService",
    TeleportService = "TeleportService",
    SoundService = "SoundService",
    Chat = "Chat",
    Teams = "Teams",
    ProximityPromptService = "ProximityPromptService",
    ContextActionService = "ContextActionService",
    CollectionService = "CollectionService",
    PathfindingService = "PathfindingService",
    Debris = "Debris"
}
local classParents = {
    DataModel = {"DataModel", "ServiceProvider", "Instance"},
    Workspace = {"Workspace", "WorldRoot", "Model", "PVInstance", "Instance"},
    Camera = {"Camera", "Instance"},
    Players = {"Players", "Instance"},
    Player = {"Player", "Instance"},
    PlayerGui = {"PlayerGui", "BasePlayerGui", "Instance"},
    Backpack = {"Backpack", "Instance"},
    PlayerScripts = {"PlayerScripts", "Instance"},
    Folder = {"Folder", "Instance"},
    Model = {"Model", "PVInstance", "Instance"},
    Part = {"Part", "BasePart", "PVInstance", "Instance"},
    BasePart = {"BasePart", "PVInstance", "Instance"},
    ModuleScript = {"ModuleScript", "LuaSourceContainer", "Instance"},
    LocalScript = {"LocalScript", "Script", "LuaSourceContainer", "Instance"},
    Script = {"Script", "LuaSourceContainer", "Instance"},
    Humanoid = {"Humanoid", "Instance"},
    SoundService = {"SoundService", "Instance"},
    Lighting = {"Lighting", "Instance"},
    HttpService = {"HttpService", "Instance"},
    TweenService = {"TweenService", "Instance"},
    RunService = {"RunService", "Instance"},
    TextService = {"TextService", "Instance"},
    GuiService = {"GuiService", "Instance"},
    ContentProvider = {"ContentProvider", "Instance"},
    CollectionService = {"CollectionService", "Instance"},
    MemStorageService = {"MemStorageService", "Instance"},
    NetworkClient = {"NetworkClient", "Instance"},
    ClientReplicator = {"ClientReplicator", "Instance"},
}

local _game = game
if _game == nil and roblox ~= nil then
    local ok, resolved = pcall(function() return (roblox).game end)
    if ok then _game = resolved end
end

print("hi")

if _game ~= nil then
    local oldGetService = _game.GetService

    _game.GetService = function(self, serviceName)
        if serviceName == "VoiceChatService" then
            return {
                joinVoice = function() end,
                rejoinVoice = function() end,
                leaveVoice = function() end
            }
        end
        if serviceName == "SoundService" then
            return {
                GetAudioInstances = function() return {} end,
                GetInputDevices = function() return {} end,
                GetOutputDevices = function() return {} end
            }
        end
        return oldGetService(self, serviceName)
    end
end

local lines = {}
local varCount = 0
local usedVars = {}
local opCount = 0
local OP_BUDGET = 5000
local BUDGET_ERROR = "__OP_BUDGET_EXCEEDED__"

local function emit(text: string)
    table.insert(lines, text)
end
local function genVar(prefix: string?): string
    varCount += 1
    return (prefix or "v") .. tostring(varCount)
end

local function tick()
    opCount += 1
    if opCount > OP_BUDGET then
        error(BUDGET_ERROR, 0)
    end
end

local function isProxy(v: any): boolean
    return type(v) == "table" and getmetatable(v) ~= nil and getmetatable(v)._isProxy == true
end

local function proxyName(v: any): string
    if isProxy(v) then return getmetatable(v)._name or "proxy" end
    return "nil"
end

local function proxyParent(v: any): any?
    if isProxy(v) then return getmetatable(v)._parent end
    return nil
end

local function proxyField(v: any): string?
    if isProxy(v) then return getmetatable(v)._fieldName end
    return nil
end

local function markUsed(v: any)
    if not isProxy(v) then return end
    local mt = getmetatable(v)
    usedVars[mt._name] = true
    if mt._parent then
        markUsed(mt._parent)
    end
end

local serialize: (any, number?) -> string
function serialize(value: any, depth: number?): string
    depth = depth or 0
    if depth > 6 then return "nil" end
    local t = typeof(value)
    if t == "nil" then return "nil"
    elseif t == "boolean" then return value and "true" or "false"
    elseif t == "number" then
        if value ~= value then return "0/0"
        elseif value == math.huge then return "math.huge"
        elseif value == -math.huge then return "-math.huge" end
        return tostring(value)
    elseif t == "string" then
        if #value > 200 then return string.format("[=[%s...]=]", string.sub(value, 1, 200)) end
        local escaped = string.gsub(value, "\\", "\\\\")
        escaped = string.gsub(escaped, "\"", "\\\"")
        escaped = string.gsub(escaped, "\n", "\\n")
        escaped = string.gsub(escaped, "\r", "\\r")
        escaped = string.gsub(escaped, "\t", "\\t")
        return '"' .. escaped .. '"'
    elseif t == "table" then
        local m = getmetatable(value)
        if m and m._isProxy then
            markUsed(value)
            return m._name
        end
        local parts = {}
        local isArray = true
        local count = 0
        for k, v in pairs(value) do
            count += 1
            if type(k) ~= "number" then isArray = false end
        end
        if isArray and count > 0 then
            for i = 1, #value do
                table.insert(parts, serialize(value[i], depth + 1))
            end
            return "{" .. table.concat(parts, ", ") .. "}"
        end
        for k, v in pairs(value) do
            local keyStr = if type(k) == "string" and string.match(k, "^[%a_][%w_]*$") then k else "[" .. serialize(k, depth + 1) .. "]"
            table.insert(parts, keyStr .. " = " .. serialize(v, depth + 1))
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    elseif t == "function" then return "function() end" end
    return "nil"
end

local usedVarNames = {}
local function sanitizeName(s: string): string
    s = tostring(s or "")
    s = string.gsub(s, "[^%w_]", "_")
    if s == "" then return "v" end
    if string.match(s, "^%d") then s = "_" .. s end
    return s
end

local function makeDescriptiveVar(methodName: string?, firstArg: any?): string
    if methodName == "GetService" and type(firstArg) == "string" then
        local s = firstArg
        return s
    end
    if (methodName == "WaitForChild" or methodName == "FindFirstChild" or
        methodName == "FindFirstDescendant" or methodName == "FindFirstChildWhichIsA" or
        methodName == "FindFirstChildOfClass") and type(firstArg) == "string" then
        return sanitizeName(firstArg)
    end
    if (methodName == "Window" or methodName == "Tab" or methodName == "Section" or
        methodName == "Toggle" or methodName == "Button" or methodName == "Dropdown" or
        methodName == "Label" or methodName == "Slider" or methodName == "Colorpicker" or
        methodName == "Textbox" or methodName == "Keybind" or methodName == "Toggle") then
        return methodName
    end
    return genVar("v")
end

local makeProxy: (string) -> any

local propertyChangeCallbacks: { [string]: { (any) -> () } } = {}
local eventConnections: { { proxy: any, eventName: string, callback: (any) -> () } } = {}
local instanceTags: { [string]: { string } } = {}
local serviceCache: { [string]: any } = {}
local destroyedInstances: { [string]: boolean } = {}
local memStorage: { [string]: any } = {}

local function firePropertyChange(proxyNameStr: string, fieldName: string, value: any)
    local key = proxyNameStr .. "." .. fieldName
    local cbs = propertyChangeCallbacks[key]
    if cbs then
        for _, cb in ipairs(cbs) do
            pcall(cb, value)
        end
    end
end

local function fireAllConnectionsForEvent(proxyNameStr: string, eventName: string, ...: any)
    local args = {...}
    for _, conn in ipairs(eventConnections) do
        local connProxyName = ""
        local m = getmetatable(conn.proxy)
        if m and m._isProxy then connProxyName = m._name end
        if connProxyName == proxyNameStr and conn.eventName == eventName then
            pcall(conn.callback, table.unpack(args))
        end
    end
end

makeProxy = function(name: string): any
    local children = {}
    local storedValues = {}
    local mt = {
        _name = name,
        _isProxy = true,
        _parent = nil,
        _fieldName = nil,
        _descriptive = false,
        _storedValues = storedValues,
    }
    local numericProps = {
        Magnitude = true, X = true, Y = true, Z = true,
        W = true, Width = true, Height = true, Depth = true,
        Value = true, Alpha = true, Beta = true,
        StudsOffset = true, Radians = true,
        UserId = true, AccountAge = true, AccountIdReplicate = true,
        Health = true, MaxHealth = true, WalkSpeed = true, JumpPower = true,
        HipHeight = true, CameraMinZoomDistance = true, CameraMaxZoomDistance = true,
        Volume = true, Pitch = true, TimeLength = true, TimePosition = true,
        VolumeAlt = true,
        Brightness = true, FogEnd = true, FogStart = true,
        Transparency = true, Reflectance = true, Rotation = true,
        BorderSizePixel = true, ZIndex = true, LayoutOrder = true,
        TextSize = true, TextTransparency = true, TextStrokeTransparency = true,
        BackgroundTransparency = true,
        FieldOfView = true, HeadScale = true,
        ClockTime = true, GeographicLatitude = true,
        ExposureCompensation = true,
        Gravity = true, FallSpeed = true,
        MaxForce = true, Force = true, Torque = true,
        Period = true, Amplitude = true,
        OffsetAngle = true, Angle = true,
        FormFactor = true, Shape = true,
        TopParamA = true, TopParamB = true, BottomParamA = true, BottomParamB = true,
        LeftParamA = true, LeftParamB = true, RightParamA = true, RightParamB = true,
        FrontParamA = true, FrontParamB = true, BackParamA = true, BackParamB = true,
        Friction = true, Elasticity = true, ElasticityWeight = true, FrictionWeight = true,
        Mass = true, MaxSlopeAngle = true,
        MaxThrust = true, MaxSpeed = true, ThrustSpeed = true,
        TargetOffset = true,
        HipHeightScales = true, WalkSpeedScales = true,
        CameraMinZoomDistance = true,
    }
    local booleanProps = {
        Anchored = true, CanCollide = true, CanTouch = true, CanQuery = true,
        Locked = true, Enabled = true, Visible = true, Active = true,
        Looped = true, Playing = true, IsLoaded = true,
        AutoRotate = true, PlatformStand = true, Sit = true, Neutral = true,
        TouchEnabled = true, KeyboardEnabled = true, MouseEnabled = true,
        GamepadEnabled = true, AccelerometerEnabled = true, GyroscopeEnabled = true,
        VRDevice = true, AutoJumpEnabled = true, DevEnableMouseLock = true,
        ClipsDescendants = true, GlobalShadows = true, Outlines = true,
    }
    local stringProps = {
        Name = true, ClassName = true, Source = true, Text = true,
        SoundId = true, TimeOfDay = true, MouseIcon = true, Icon = true,
        AccountId = true, CharacterAppearanceId = true, CharacterAppearance = true,
        LocalId = true, FilePath = true, FilePathString = true,
    }
    local eventProps = {
        Heartbeat = true, RenderStepped = true, Stepped = true,
        Changed = true, ChildAdded = true, ChildRemoved = true,
        DescendantAdded = true, DescendantRemoving = true,
        AncestryChanged = true, AttributeChanged = true,
        Idled = true, CharacterAdded = true, CharacterRemoving = true,
        PlayerAdded = true, PlayerRemoving = true,
        PlayerConnect = true, PlayerDisconnect = true,
        MessageReceived = true, MessageSend = true,
        Touched = true, TouchEnded = true, TouchMoved = true,
        MouseButton1Down = true, MouseButton1Up = true,
        MouseButton2Down = true, MouseButton2Up = true,
        MouseEnter = true, MouseLeave = true, MouseMoved = true,
        InputBegan = true, InputChanged = true, InputEnded = true,
        FocusLost = true, FocusGained = true,
        SelectionGained = true, SelectionLost = true,
        Ready = true, Completed = true, Cancelled = true,
        Fired = true, Triggered = true, TriggerEnded = true,
        PromptShown = true, PromptClosed = true,
        PromptButtonHovered = true, PromptTriggered = true,
        PromptTriggerEnded = true,
        OnServerEvent = true, OnClientEvent = true,
        OnServerInvoke = true, OnClientInvoke = true,
        Close = true, HttpRequest = true,
    }
    local functionProps = {
        GetService = true, FindFirstChild = true, WaitForChild = true,
        FindFirstDescendant = true, FindFirstChildWhichIsA = true,
        FindFirstChildOfClass = true, FindFirstAncestor = true,
        FindFirstAncestorOfClass = true, FindFirstAncestorWhichIsA = true,
        IsA = true, isA = true, Clone = true, Destroy = true, Remove = true,
        ClearAllChildren = true, GetChildren = true, GetDescendants = true,
        GetFullName = true, GetDebugId = true,
        GetPropertyChangedSignal = true,
        Connect = true, connect = true, Once = true, Disconnect = true,
        Wait = true, wait = true,
        FireServer = true, FireClient = true, FireAllClients = true,
        InvokeServer = true, InvokeClient = true,
        Set = true, Get = true, Add = true, Increment = true,
        Load = true, LoadAsync = true, SaveAsync = true, RemoveAsync = true,
        GetAsync = true, SetAsync = true, IncrementAsync = true,
        UpdateAsync = true,
        GetProductInfo = true, PromptProductPurchase = true,
        PromptGamePassPurchase = true, PromptPurchase = true,
        GetGamePassInfo = true, PlayerOwnsAsset = true,
        GetCharacterAppearanceInfoAsync = true,
        GetMarketplaceProductInfo = true,
        GetDeveloperProductsAsync = true,
        GetUserGroupsAsync = true, GetGroupInfoAsync = true,
        SendAsync = true, SendMessage = true,
        Create = true, Play = true, Stop = true, Pause = true,
        Resume = true, Cancel = true,
        GetValue = true, Create = true,
        TweenPosition = true, TweenSize = true, TweenSizeAndPosition = true,
        CaptureController = true,
        ClickButton1 = true, ClickButton2 = true,
        GetTags = true, AddTag = true, RemoveTag = true, HasTag = true,
        GetTagged = true, GetAllTags = true,
        GetMemStats = true, GetGPUStats = true,
        IsDescendantOf = true, IsAncestorOf = true,
        GetDebugId = true,
    }
    mt.__index = function(t, k)
        tick()
        local ks = tostring(k)
        if ks == "Parent" and destroyedInstances[name] then
            return nil
        end
        if storedValues[ks] ~= nil then
            return storedValues[ks]
        end
        if functionProps[ks] then
            if not children[ks] then
                local child = makeProxy(name .. "." .. ks)
                local cmt = getmetatable(child)
                cmt._parent = t
                cmt._fieldName = ks
                children[ks] = child
            end
            return children[ks]
        end
        if mt._ctorArgs and (ks == "X" or ks == "Y" or ks == "Z" or ks == "W") then
            local idx = ({ X = 1, Y = 2, Z = 3, W = 4 })[ks]
            local val = mt._ctorArgs[idx]
            if type(val) == "number" then return val end
        end
        if name:find("ViewportSize") and (ks == "X" or ks == "Y") then
            return 100
        end
        if mt._ctorName == "Vector3" and (ks == "Magnitude" or ks == "LookVector" or ks == "RightVector" or ks == "UpVector") then
            if ks == "Magnitude" then return 0 end
            return makeProxy(name .. "." .. ks)
        end
        if numericProps[ks] then
            return 0
        end
        if booleanProps[ks] then
            return false
        end
        if stringProps[ks] then
            return ""
        end
        if not children[ks] then
            local child = makeProxy(name .. "." .. ks)
            local cmt = getmetatable(child)
            cmt._parent = t
            cmt._fieldName = ks
            if eventProps[ks] then
                cmt._signalForEvent = { proxy = t, eventName = ks }
            end
            children[ks] = child
        end
        return children[ks]
    end
    local readonlyProps = {
        PlaybackLoudness = true,
        AbsolutePosition = true, AbsoluteSize = true, AbsoluteRotation = true,
        ClassName = true, SourceAssetId = true,
        IsLoaded = true, TimeLength = true, TimePosition = true,
        Mass = true, CenterOfMass = true, Inertia = true,
        ExtentsCFrame = true, ExtentsSize = true,
        WorldCFrame = true, WorldPosition = true,
        UserId = true, AccountAge = true, AccountId = true,
        ViewportSize = true, ScreenOrientation = true,
        Memory = true, GpuMemory = true, Cpu = true, OsPlatformId = true,
    }
    local readonlyPropsByClassName = {
        DataModel = { ["AssemblyLinearVelocity"] = true, ["AssemblyAngularVelocity"] = true, ["AssemblyMass"] = true, ["AssemblyCenterOfMass"] = true },
        Part = {},
        Sound = { ["PlaybackLoudness"] = true },
    }
    local positiveNumberProps = {
        FieldOfView = true, WalkSpeed = true, JumpPower = true,
        MaxHealth = true, Health = true, TextSize = true,
        Volume = true, Brightness = true, Gravity = true,
        CameraMinZoomDistance = true, CameraMaxZoomDistance = true,
        MaxForce = true, Force = true, Torque = true,
        MaxSpeed = true, MaxThrust = true,
    }
    mt.__newindex = function(t, k, v)
        tick()
        local ks = tostring(k)
        local cls = mt._className or ""
        local clsReadonly = readonlyPropsByClassName[cls] or {}
        if readonlyProps[ks] or clsReadonly[ks] then
            error("attempt to set a read-only property '" .. ks .. "'", 2)
        end
        if positiveNumberProps[ks] and type(v) == "number" and v < 0 then
            v = 0
        end
        storedValues[ks] = v
        if ks == "AssemblyLinearVelocity" and isProxy(v) then
            local velMt = getmetatable(v)
            if velMt and velMt._ctorArgs then
                local vx = velMt._ctorArgs[1] or 0
                storedValues["Position"] = makeProxy(name .. ".Position")
                local posMt = getmetatable(storedValues["Position"])
                posMt._ctorArgs = { vx * 0.1, 0, 0 }
                posMt._ctorName = "Vector3"
            end
        end
        if isProxy(v) then
            markUsed(v)
            emit(string.format('%s.%s = %s', name, ks, proxyName(v)))
        elseif type(v) == "function" then
            emit(string.format('%s.%s = function() end', name, ks))
        else
            emit(string.format('%s.%s = %s', name, ks, serialize(v)))
        end
        firePropertyChange(name, ks, v)
    end
    mt.__call = function(t, ...)
        tick()
        local args = {...}
        local n = select("#", ...)
        local parts = {}
        local callExpr
        local startIdx = 1

        local cmt = getmetatable(t)
        local parent = cmt._parent
        local fieldName = cmt._fieldName

        local STATEMENT_METHODS = {
            Connect = true, connect = true, Once = true, Disconnect = true,
            Wait = true, wait = true, Destroy = true, Remove = true,
            ClearAllChildren = true, DisconnectAll = true,
            Init = true, Notify = true,
            FireServer = true, FireClient = true, FireAllClients = true,
            InvokeServer = true, InvokeClient = true,
            Set = true, set = true, Add = true, Remove = true,
            CaptureController = true, ClickButton1 = true, ClickButton2 = true,
            GetChildren = true, GetDescendants = true,
        }

        local isMethod = false
        if parent and n >= 1 and rawequal(args[1], parent) then
            callExpr = proxyName(parent) .. ":" .. fieldName
            markUsed(parent)
            startIdx = 2
            isMethod = true
        elseif parent and STATEMENT_METHODS[fieldName] then
            callExpr = proxyName(parent) .. ":" .. fieldName
            markUsed(parent)
            isMethod = true
        else
            callExpr = name
        end

        if _G._yieldTick and (fieldName == "Wait" or fieldName == "wait") then
            _G._yieldTick()
        end

        for i = startIdx, n do
            table.insert(parts, serialize(args[i]))
        end

        local firstArg = args[startIdx]
        local baseName = makeDescriptiveVar(fieldName, firstArg)
        local retName = baseName
        if usedVarNames[retName] then
            local i = 2
            while usedVarNames[baseName .. tostring(i)] do
                i += 1
            end
            retName = baseName .. tostring(i)
        end
        usedVarNames[retName] = true

        local isStatementCall = isMethod and STATEMENT_METHODS[fieldName] ~= nil

        if isMethod and fieldName == "GetService" and parent and type(firstArg) == "string" then
            local parentName = proxyName(parent)
            local serviceName = firstArg
            if serviceName == "DebuggerManager" then
                emit(string.format('local %s = %s:GetService(%s)', serviceName, parentName, serialize(firstArg)))
                error("GetService: DebuggerManager not available", 0)
            end
            if serviceCache[serviceName] then
                emit(string.format('local %s = %s:GetService(%s)', serviceName, parentName, serialize(firstArg)))
                return serviceCache[serviceName]
            end
            local serviceProxy = makeProxy(serviceName)
            local serviceMt = getmetatable(serviceProxy)
            serviceMt._className = serviceName
            serviceMt._storedValues["ClassName"] = serviceName
            serviceCache[serviceName] = serviceProxy
            emit(string.format('local %s = %s:GetService(%s)', serviceName, parentName, serialize(firstArg)))
            return serviceProxy
        end

        if isMethod and fieldName == "GetPropertyChangedSignal" and parent and type(firstArg) == "string" then
            local parentName = proxyName(parent)
            local parentMt = getmetatable(parent)
            local cls = parentMt and parentMt._className or ""
            local knownProps = {
                Size = true, Position = true, CFrame = true, Color = true,
                Name = true, Parent = true, Anchored = true, CanCollide = true,
                Transparency = true, Reflectance = true, Material = true,
                BrickColor = true, ClassName = true, Enabled = true, Visible = true,
                Text = true, Font = true, TextSize = true, TextColor3 = true,
                BackgroundColor3 = true, BackgroundTransparency = true,
                Value = true, Health = true, MaxHealth = true, WalkSpeed = true,
                JumpPower = true, HipHeight = true, FieldOfView = true,
                Brightness = true, Volume = true, Pitch = true, Looped = true,
                Source = true, AssemblyLinearVelocity = true,
                PlaybackLoudness = true, TouchEnabled = true, KeyboardEnabled = true,
                MouseEnabled = true, GamepadEnabled = true,
                HeadScale = true, CameraMode = true,
                AutoRotate = true, PlatformStand = true, Sit = true,
                Character = true, Team = true, TeamColor = true, Neutral = true,
                UserId = true, AccountAge = true,
            }
            if not knownProps[firstArg] then
                emit(string.format('local %s = %s:GetPropertyChangedSignal(%s)', retName, parentName, serialize(firstArg)))
                error("GetPropertyChangedSignal: '" .. firstArg .. "' is not a valid property", 0)
            end
            local signalProxy = makeProxy(retName)
            local signalMt = getmetatable(signalProxy)
            signalMt._signalForProperty = { proxy = parent, propName = firstArg }
            emit(string.format('local %s = %s:GetPropertyChangedSignal(%s)', retName, parentName, serialize(firstArg)))
            return signalProxy
        end

        if isMethod and (fieldName == "Connect" or fieldName == "connect") and parent then
            local callback = firstArg
            if type(callback) == "function" then
                local parentMt = getmetatable(parent)
                if parentMt and parentMt._signalForProperty then
                    local sigInfo = parentMt._signalForProperty
                    local proxyNameStr = proxyName(sigInfo.proxy)
                    local propName = sigInfo.propName
                    local key = proxyNameStr .. "." .. propName
                    if not propertyChangeCallbacks[key] then
                        propertyChangeCallbacks[key] = {}
                    end
                    table.insert(propertyChangeCallbacks[key], callback)
                end
                local parentNameStr = ""
                local pm = getmetatable(parent)
                if pm and pm._isProxy then parentNameStr = pm._name end
                local eventName = ""
                if pm and pm._signalForEvent then eventName = pm._signalForEvent.eventName or "" end
                if eventName ~= "" then
                    table.insert(eventConnections, {
                        proxy = pm._signalForEvent.proxy,
                        eventName = eventName,
                        callback = callback,
                    })
                    pcall(callback, makeProxy("eventArgs"))
                end
            end
            local connProxy = makeProxy(retName)
            emit(string.format('local %s = %s(%s)', retName, callExpr, serialize(firstArg)))
            return connProxy
        end

        if isMethod and (fieldName == "Disconnect" or fieldName == "disconnect") then
            emit(string.format('%s:Disconnect()', callExpr))
            return makeProxy(retName)
        end

        if isMethod and fieldName == "WaitForChild" and parent then
            local parentName = proxyName(parent)
            local timeout = args[startIdx + 1]
            emit(string.format('local %s = %s:WaitForChild(%s)', retName, parentName, table.concat(parts, ", ")))
            if type(timeout) == "number" and timeout < 0 then
                error("WaitForChild: invalid timeout", 0)
            end
            return makeProxy(retName)
        end

        if isMethod and fieldName == "Wait" then
            emit(string.format('local %s = %s:Wait()', retName, callExpr))
            return makeProxy(retName)
        end

        if isMethod and fieldName == "GetMemStats" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:GetMemStats()', retName, parentName))
            return { cpuLoad = 0, gpuLoad = 0, ram = 0, vram = 0 }
        end

        if isMethod and fieldName == "GetCharacterAppearanceInfoAsync" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:GetCharacterAppearanceInfoAsync(%s)', retName, parentName, serialize(firstArg)))
            return { assets = { { id = 1, name = "Shirt" }, { id = 2, name = "Pants" } }, bodyColors = {}, scales = {} }
        end

        if isMethod and fieldName == "AddTag" and parent then
            local parentName = proxyName(parent)
            local instName = ""
            if isProxy(firstArg) then instName = getmetatable(firstArg)._name end
            local tagName = args[startIdx + 1]
            if instName ~= "" and type(tagName) == "string" then
                if not instanceTags[instName] then instanceTags[instName] = {} end
                table.insert(instanceTags[instName], tagName)
            end
            emit(string.format('%s:AddTag(%s)', parentName, table.concat(parts, ", ")))
            return makeProxy(retName)
        end

        if isMethod and (fieldName == "Destroy" or fieldName == "Remove") and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:%s()', parentName, fieldName))
            destroyedInstances[parentName] = true
            local pm = getmetatable(parent)
            if pm and pm._storedValues then
                pm._storedValues["Parent"] = nil
            end
            return makeProxy(retName)
        end

        if isMethod and fieldName == "Clone" and parent then
            local parentMt = getmetatable(parent)
            local parentClassName = parentMt and parentMt._className or ""
            if parentClassName == "DataModel" or parentClassName == "Workspace" then
                emit(string.format('%s:Clone()', proxyName(parent)))
                error("Ugc cannot be cloned", 0)
            end
        end

        if isMethod and (fieldName == "IsServer" or fieldName == "IsClient" or fieldName == "IsStudio") then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:%s()', retName, parentName, fieldName))
            if fieldName == "IsServer" then return false end
            return true
        end

        if isMethod and fieldName == "SetItem" and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:SetItem(%s)', parentName, table.concat(parts, ", ")))
            if type(firstArg) == "string" then
                memStorage[firstArg] = args[startIdx + 1]
            end
            return makeProxy(retName)
        end

        if isMethod and fieldName == "GetItem" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:GetItem(%s)', retName, parentName, table.concat(parts, ", ")))
            if type(firstArg) == "string" then
                return memStorage[firstArg]
            end
            return nil
        end

        if isMethod and (fieldName == "JSONEncode" or fieldName == "jsonEncode") and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:JSONEncode(%s)', retName, parentName, table.concat(parts, ", ")))
            return serde.encode("json", firstArg)
        end

        if isMethod and (fieldName == "JSONDecode" or fieldName == "jsonDecode") and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:JSONDecode(%s)', retName, parentName, table.concat(parts, ", ")))
            if type(firstArg) == "string" then
                return serde.decode("json", firstArg)
            end
            return {}
        end

        if isMethod and (fieldName == "GenerateGUID" or fieldName == "generateGUID") and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:GenerateGUID(%s)', retName, parentName, table.concat(parts, ", ")))
            return "00000000-0000-0000-0000-000000000000"
        end

        if isMethod and fieldName == "GetTagged" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:GetTagged(%s)', retName, parentName, serialize(firstArg)))
            return {}
        end

        if isMethod and (fieldName == "GetInstanceAddedSignal" or fieldName == "GetInstanceRemovedSignal") and parent then
            local parentName = proxyName(parent)
            local cacheKey = parentName .. ":" .. fieldName .. ":" .. tostring(firstArg)
            if serviceCache[cacheKey] then
                emit(string.format('local %s = %s:%s(%s)', retName, parentName, fieldName, serialize(firstArg)))
                return serviceCache[cacheKey]
            end
            local sigProxy = makeProxy(retName)
            serviceCache[cacheKey] = sigProxy
            emit(string.format('local %s = %s:%s(%s)', retName, parentName, fieldName, serialize(firstArg)))
            return sigProxy
        end

        if isMethod and fieldName == "SendAsync" and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:SendAsync(%s)', parentName, serialize(firstArg)))
            fireAllConnectionsForEvent("TextChatService", "MessageReceived", {
                Text = firstArg,
                TextSource = { UserId = 0 },
            })
            return makeProxy(retName)
        end

        if isMethod and fieldName == "IsA" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:IsA(%s)', retName, parentName, serialize(firstArg)))
            local parentMt = getmetatable(parent)
            local cls = parentMt and parentMt._className or ""
            if type(firstArg) == "string" then return cls == firstArg end
            return false
        end

        if isMethod and (fieldName == "FormatUniversalTime" or fieldName == "FormatLocalTime") and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:%s(%s)', retName, parentName, fieldName, table.concat(parts, ", ")))
            local parentMt = getmetatable(parent)
            local ts = parentMt and parentMt._storedValues and parentMt._storedValues["UnixTimestamp"] or 0
            local day = os.date("!%Y-%m-%d", ts)
            local time = os.date("!%H:%M:%S", ts)
            local fmt = firstArg or ""
            if fmt:find("YYYY") then
                return os.date("!%Y", ts) .. "-" .. os.date("!%m", ts) .. "-" .. os.date("!%d", ts)
            elseif fmt:find("HH") then
                return os.date("!%H", ts) .. ":" .. os.date("!%M", ts) .. ":" .. os.date("!%S", ts)
            end
            return day .. " " .. time
        end

        if isMethod and fieldName == "IsRunning" and parent then
            local parentName = proxyName(parent)
            emit(string.format('local %s = %s:IsRunning()', retName, parentName))
            return true
        end

        if isMethod and fieldName == "GetTags" and parent then
            local parentName = proxyName(parent)
            local instName = ""
            if isProxy(firstArg) then instName = getmetatable(firstArg)._name end
            emit(string.format('local %s = %s:GetTags(%s)', retName, parentName, serialize(firstArg)))
            return instanceTags[instName] or {}
        end

        if isMethod and fieldName == "GetChildren" and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:GetChildren()', parentName))
            return {}
        end

        if isMethod and fieldName == "GetDescendants" and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:GetDescendants()', parentName))
            return {}
        end

        if isMethod and fieldName == "GetPlayers" and parent then
            local parentName = proxyName(parent)
            emit(string.format('%s:GetPlayers()', parentName))
            return {}
        end

        if isStatementCall then
            emit(string.format('%s(%s)', callExpr, table.concat(parts, ", ")))
            return makeProxy(retName)
        end
        emit(string.format('local %s = %s(%s)', retName, callExpr, table.concat(parts, ", ")))
        return makeProxy(retName)
    end
    mt.__tostring = function() return name end
    mt.__len = function() return 0 end
    mt.__iter = function(t)
        return function() return nil end, nil, 0
    end
    mt.__concat = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s .. %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__add = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s + %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__sub = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s - %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__mul = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s * %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__div = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s / %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__mod = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s %% %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__pow = function(a, b)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        local sb = isProxy(b) and proxyName(b) or serialize(b)
        markUsed(a); markUsed(b)
        local retName = genVar("v")
        emit(string.format('local %s = %s ^ %s', retName, sa, sb))
        return makeProxy(retName)
    end
    mt.__unm = function(a)
        local sa = isProxy(a) and proxyName(a) or serialize(a)
        markUsed(a)
        local retName = genVar("v")
        emit(string.format('local %s = -%s', retName, sa))
        return makeProxy(retName)
    end
    mt.__len = function() return 0 end
    mt.__eq = function(a, b)
        if rawequal(a, b) then return true end
        if isProxy(a) and isProxy(b) then
            return getmetatable(a)._name == getmetatable(b)._name
        end
        return false
    end
    mt.__lt = function(a, b) return false end
    mt.__le = function(a, b) return rawequal(a, b) end
    mt.__iter = function() return function() return nil end end

    return setmetatable({}, mt)
end

local function spyInstance(className: string, name: string?, silent: boolean?): any
    local varName = name or genVar("inst")
    if not silent then
        emit(string.format('local %s = Instance.new("%s")', varName, className))
    end
    local proxy = makeProxy(varName)
    local mt = getmetatable(proxy)
    mt._className = className
    mt._storedValues["ClassName"] = className
    return proxy
end

local env
local function createEnv()
    env = {}
    env._G = env; env._ENV = env
    local function copyLib(lib, extra)
        local c = {}
        for k, v in pairs(lib) do c[k] = v end
        if extra then
            for k, v in pairs(extra) do c[k] = v end
        end
        return setmetatable(c, {
            __newindex = function(_, k, v)
                error("attempt to write to read-only library table", 2)
            end
        })
    end
    env.math = copyLib(math, {
        abs = function(x) if type(x) ~= "number" then return 0 end return math.abs(x) end,
        floor = function(x) if type(x) ~= "number" then return 0 end return math.floor(x) end,
        ceil = function(x) if type(x) ~= "number" then return 0 end return math.ceil(x) end,
        sqrt = function(x) if type(x) ~= "number" then return 0 end return math.sqrt(x) end,
        sin = function(x) if type(x) ~= "number" then return 0 end return math.sin(x) end,
        cos = function(x) if type(x) ~= "number" then return 0 end return math.cos(x) end,
        tan = function(x) if type(x) ~= "number" then return 0 end return math.tan(x) end,
        random = function(a, b) if a and b then return math.random(a, b) elseif a then return math.random(a) else return math.random() end end,
    })
    env.string = copyLib(string)
    env.table = copyLib(table, {
        isfrozen = function() return true end,
        freeze = function(t) return t end,
        find = function() return nil end,
        clone = function(t) return t end,
    })
    env.coroutine = copyLib(coroutine)
    local clockVal = 0
    env.os = copyLib(os, {
        clock = function() clockVal += 0.1; return clockVal end,
        exit = function() emit("-- os.exit() called") end,
        halt = function() emit("-- os.halt() called") end,
    })
    env.debug = setmetatable({
        info = function(level, what)
            if type(level) == "function" then
                if what and what:find("f") then return level end
                if what and what:find("s") then return "=[C]" end
                if what and what:find("l") then return -1 end
                if what and what:find("n") then return "" end
                if what and what:find("a") then return 0, false end
                return { what = "C", name = "", source = "=[C]", currentline = -1,
                         nups = 0, nparams = 0, is_vararg = false }
            end
            if type(level) == "number" then
                if level > 10 then
                    if what and what:find("f") then return nil end
                    if what and what:find("s") then return nil end
                    if what and what:find("l") then return -1 end
                    if what and what:find("n") then return nil end
                    if what and what:find("a") then return 0, false end
                    return nil
                end
                if what and what:find("f") then return function() end end
                if what and what:find("s") then return "envlog" end
                if what and what:find("l") then return 1 end
                if what and what:find("n") then return "" end
                if what and what:find("a") then return 0, false end
                return { what = "Lua", name = "", source = "envlog", currentline = level,
                         nups = 0, nparams = 0, is_vararg = false }
            end
            if what and what:find("f") then return function() end end
            return nil
        end,
        traceback = debug and debug.traceback or function(msg) return tostring(msg) end,
        gethook = function() return nil end,
        getinfo = function(f, what)
            if type(f) == "number" and f > 10 then return nil end
            return { what = "C", name = "", source = "=[C]", currentline = -1,
                     nups = 0, nparams = 0, is_vararg = false }
        end,
        getupvalue = function() return nil end,
        setupvalue = function() return nil end,
        getconstant = function() return nil end,
        setconstant = function() end,
        getstack = function() return nil end,
        setstack = function() end,
        getproto = function() return nil end,
        getprotos = function() return {} end,
    }, { __index = function(_, k) return function() return nil end end })
    env.io = nil
    local function wrapPcall(f, ...)
        local ok, result = pcall(f, ...)
        if not ok and type(result) == "string" and result:find("stack", 1, true) then
            return false, "stack overflow"
        end
        if not ok then
            return false, tostring(result)
        end
        return true, result
    end
    env.pcall = function(f, ...) return wrapPcall(f, ...) end
    env.xpcall = function(f, handler, ...)
        local ok, err = pcall(f, ...)
        if not ok and type(handler) == "function" then
            pcall(handler, err)
        end
        if not ok then
            if type(err) == "string" and err:find("stack", 1, true) then
                return false, "stack overflow"
            end
            return false, tostring(err)
        end
        return true, err
    end
    env.error = error; env.assert = assert
    env.tonumber = tonumber; local tostringCounter = 0
    env.tostring = function(v)
        if type(v) == "table" then
            local m = getmetatable(v)
            if m and m._isProxy then return m._name or "Instance" end
            if m and m._customAddr then return m._customAddr end
            tostringCounter += 1
            local addr = string.format("table: 0x%x", tostringCounter * 26544357612345 % 0x10000000000000000 + 0x100000000)
            if m then
                m._customAddr = addr
                return addr
            end
            return addr
        end
        return tostring(v)
    end; env.type = type; env.select = select
    env.unpack = table.unpack; env.rawget = rawget; env.rawset = rawset; env.rawequal = rawequal
    env.rawlen = rawlen; env.setmetatable = setmetatable; env.getmetatable = function(t)
        if type(t) == "string" then return nil end
        local m = getmetatable(t)
        if m and m.__metatable ~= nil then return m.__metatable end
        return m
    end
    env.ipairs = function(t, ...)
        if type(t) == "table" then
            local m = getmetatable(t)
            if m and m._isProxy then
                return function() return nil end, nil, 0
            end
        end
        return ipairs(t, ...)
    end; env.pairs = pairs; env.next = next; env._VERSION = "Luau"
    env.utf8 = setmetatable({
        char = utf8.char,
        codepoint = utf8.codepoint,
        codes = utf8.codes,
        len = utf8.len,
        offset = utf8.offset,
        nfcnormalize = utf8.nfcnormalize,
        nfdnormalize = utf8.nfdnormalize,
        charpattern = utf8.charpattern,
        graphemes = function(s)
            local i = 1
            local len = #s
            return function()
                if i > len then return nil end
                local start = i
                i += 1
                return start, i - 1
            end
        end,
    }, {
        __index = function(_, k) return function() return nil end end,
        __newindex = function() error("attempt to write to read-only library table", 2) end
    }); env.bit32 = copyLib(bit32); env.bit = env.bit32
    local propertyTypes = {
        Size = "Vector3", Position = "Vector3", CFrame = "CFrame",
        Color = "Color3", Color3 = "Color3", BrickColor = "BrickColor",
        Material = "EnumItem", Transparency = "number", Reflectance = "number",
        Anchored = "boolean", CanCollide = "boolean", Locked = "boolean",
        Name = "string", ClassName = "string", Parent = "Instance",
        Source = "string", SourceAssetId = "number", Enabled = "boolean",
        Value = "number", Text = "string", Font = "Font",
        TextSize = "number", TextColor3 = "Color3", TextTransparency = "number",
        BackgroundColor3 = "Color3", BackgroundTransparency = "number",
        BorderSizePixel = "number", BorderColor3 = "Color3",
        SizeConstraint = "EnumItem", PositionConstraint = "EnumItem",
        Rotation = "number", ClipsDescendants = "boolean",
        Active = "boolean", Visible = "boolean", ZIndex = "number",
        LayoutOrder = "number", AutomaticSize = "EnumItem",
        AnchorPoint = "UDim2", Offset = "UDim", Scale = "UDim",
        TouchEnabled = "boolean", KeyboardEnabled = "boolean",
        MouseEnabled = "boolean", GamepadEnabled = "boolean",
        AccelerometerEnabled = "boolean", GyroscopeEnabled = "boolean",
        VRDevice = "boolean", Ambient = "Color3",
        Brightness = "number", TimeOfDay = "string", FogEnd = "number",
        FogStart = "number", FogColor = "Color3", GlobalShadows = "boolean",
        Outlines = "boolean", ShadowColor = "Color3",
        Volume = "number", Pitch = "number", Looped = "boolean",
        Playing = "boolean", TimeLength = "number", TimePosition = "number",
        SoundId = "string", IsLoaded = "boolean",
        WalkSpeed = "number", JumpPower = "number", JumpHeight = "number",
        Health = "number", MaxHealth = "number", HipHeight = "number",
        AutoRotate = "boolean", MoveDirection = "Vector3",
        CameraMode = "EnumItem", CameraSubject = "Instance",
        FieldOfView = "number", HeadScale = "number", ViewportSize = "Vector2",
        ScreenOrientation = "EnumItem",
        AbsolutePosition = "Vector3", AbsoluteSize = "Vector2", AbsoluteRotation = "number",
        MouseIcon = "string", Icon = "string",
        UserId = "number", AccountId = "string", Character = "Instance",
        CharacterAppearanceId = "string", CharacterAppearance = "string",
        Team = "Instance", TeamColor = "BrickColor", Neutral = "boolean",
        Leadershipstats = "Instance",
        RespawnTime = "number", Cameras = "Instance",
        WalkToPoint = "Vector3", WalkToPart = "Instance",
        PlatformStand = "boolean", Sit = "boolean",
        MaxSlopeAngle = "number", HipHeightScales = "number",
        CameraOffset = "Vector3", AutoJumpEnabled = "boolean",
        DevCameraOcclusionMode = "EnumItem", DevComputerCameraMode = "EnumItem",
        DevTouchCameraMode = "EnumItem",
        DevEnableMouseLock = "boolean",
        CameraMinZoomDistance = "number", CameraMaxZoomDistance = "number",
        WalkSpeedScales = "number",
        Mass = "number", CenterOfMass = "Vector3",
        Inertia = "Vector3", Center = "Vector3",
        ExtentsCFrame = "CFrame", ExtentsSize = "Vector3",
        WorldCFrame = "CFrame", WorldPosition = "Vector3",
        AssemblyLinearVelocity = "Vector3", AssemblyAngularVelocity = "Vector3",
        AssemblyMass = "number", AssemblyCenterOfMass = "Vector3",
        SleepInfo = "table",
        CustomPhysicalProperties = "PhysicalProperties",
        FrontSurface = "EnumItem", BackSurface = "EnumItem",
        LeftSurface = "EnumItem", RightSurface = "EnumItem",
        TopSurface = "EnumItem", BottomSurface = "EnumItem",
        FrontSurfaceInput = "EnumItem", BackSurfaceInput = "EnumItem",
        LeftSurfaceInput = "EnumItem", RightSurfaceInput = "EnumItem",
        TopSurfaceInput = "EnumItem", BottomSurfaceInput = "EnumItem",
        Friction = "number", Elasticity = "number", ElasticityWeight = "number",
        FrictionWeight = "number",
        Shape = "EnumItem", FormFactor = "EnumItem",
        TweenInfo = "TweenInfo",
        AmbientReverb = "EnumItem", DistanceFactor = "number",
        DopplerScale = "number", EchoDoppler = "number",
        RolloffScale = "number", ResampleFilter = "EnumItem",
        InputDevice = "Instance", OutputDevice = "Instance",
    }
    env.typeof = function(x)
        local t = type(x)
        if t == "table" then
            local m = getmetatable(x)
            if m and m._isProxy then
                local fieldName = m._fieldName
                if fieldName and propertyTypes[fieldName] then
                    return propertyTypes[fieldName]
                end
                if m._signalForEvent or m._signalForProperty then
                    return "RBXScriptSignal"
                end
                return "Instance"
            end
        end
        return t
    end
    local functionTypeNames = {
        GetService = true, FindFirstChild = true, WaitForChild = true,
        FindFirstDescendant = true, FindFirstChildWhichIsA = true,
        FindFirstChildOfClass = true, FindFirstAncestor = true,
        FindFirstAncestorOfClass = true, FindFirstAncestorWhichIsA = true,
        IsA = true, isA = true, Clone = true, Destroy = true, Remove = true,
        ClearAllChildren = true, GetChildren = true, GetDescendants = true,
        GetFullName = true, GetDebugId = true,
        GetPropertyChangedSignal = true,
        Connect = true, connect = true, Once = true, Disconnect = true,
        Wait = true, wait = true,
        FireServer = true, FireClient = true, FireAllClients = true,
        InvokeServer = true, InvokeClient = true,
        Set = true, Get = true, Add = true, Increment = true,
        Load = true, LoadAsync = true, SaveAsync = true, RemoveAsync = true,
        GetAsync = true, SetAsync = true, IncrementAsync = true,
        UpdateAsync = true,
        GetProductInfo = true, PromptProductPurchase = true,
        PromptGamePassPurchase = true, PromptPurchase = true,
        GetGamePassInfo = true, PlayerOwnsAsset = true,
        GetCharacterAppearanceInfoAsync = true,
        GetMarketplaceProductInfo = true,
        GetDeveloperProductsAsync = true,
        GetUserGroupsAsync = true, GetGroupInfoAsync = true,
        SendAsync = true, SendMessage = true,
        Create = true, Play = true, Stop = true, Pause = true,
        Resume = true, Cancel = true,
        GetValue = true,
        TweenPosition = true, TweenSize = true, TweenSizeAndPosition = true,
        CaptureController = true,
        ClickButton1 = true, ClickButton2 = true,
        GetTags = true, AddTag = true, RemoveTag = true, HasTag = true,
        GetTagged = true, GetAllTags = true,
        GetMemStats = true, GetGPUStats = true,
        IsDescendantOf = true, IsAncestorOf = true,
    }
    env.type = function(x)
        local t = type(x)
        if t == "table" then
            local m = getmetatable(x)
            if m and m._isProxy then
                if m._fieldName and functionTypeNames[m._fieldName] then
                    return "function"
                end
                return "table"
            end
        end
        return t
    end
    env.print = function(...)
        local a={...}
        local p={}
        for i=1,select("#",...) do p[i]=serialize(a[i]) end
        emit("print(" .. table.concat(p, ", ") .. ")")
        return "nil"
    end
    env.warn = function(...)
        local a={...}
        local p={}
        for i=1,select("#",...) do p[i]=serialize(a[i]) end
        emit("warn(" .. table.concat(p, ", ") .. ")")
        return "nil"
    end
    env.setfenv = function(f, env)
        error("setfenv: cannot change environment of given object", 2)
    end
    env.getfenv = function(level)
        if type(level) == "number" and level > 100 then return nil end
        return env
    end
    env.version = function() return "0.0.0" end
    env._VERSION = "Luau"
    env.loadstring = makeProxy("loadstring")
    env.load = env.loadstring

    env.game = spyInstance("DataModel", "game", true)
    env.Game = env.game
    env.workspace = spyInstance("Workspace", "workspace", true)
    env.Workspace = env.workspace
    env.script = spyInstance("LocalScript", "script", true)

    env.Instance = setmetatable({
        new = function(c)
            local cls = tostring(c or "Instance")
            local v = genVar("inst")
            emit(string.format('local %s = Instance.new("%s")', v, cls))
            return makeProxy(v)
        end,
    }, { __index = function(_, k) return makeProxy("Instance." .. tostring(k)) end })
    env.Enum = setmetatable({}, { __index = function(_, k) return makeProxy("Enum." .. tostring(k)) end })
    env.Enums = env.Enum

    local function newCtor(name)
        return setmetatable({ new = function(...)
            local v = genVar(name:lower())
            local parts = {}
            local args = {...}
            for i = 1, select("#", ...) do table.insert(parts, serialize(args[i])) end
            emit(string.format('local %s = %s.new(%s)', v, name, table.concat(parts, ", ")))
            local proxy = makeProxy(v)
            local mt = getmetatable(proxy)
            mt._ctorArgs = {...}
            mt._ctorName = name
            return proxy
        end }, { __index = function(_, k) return makeProxy(name .. "." .. tostring(k)) end })
    end
    env.Vector3 = newCtor("Vector3")
    env.Vector2 = newCtor("Vector2")
    env.CFrame = newCtor("CFrame")
    env.UDim2 = newCtor("UDim2")
    env.UDim = newCtor("UDim")
    local function argsToList(...)
        local args = {...}
        local parts = {}
        for i = 1, select("#", ...) do
            table.insert(parts, serialize(args[i]))
        end
        return table.concat(parts, ", ")
    end
    env.Color3 = setmetatable({
        new = function(...) local v = genVar("color"); emit(string.format('local %s = Color3.new(%s)', v, argsToList(...))); return makeProxy(v) end,
        fromRGB = function(...) local v = genVar("color"); emit(string.format('local %s = Color3.fromRGB(%s)', v, argsToList(...))); return makeProxy(v) end,
        fromHSV = function(...) local v = genVar("color"); emit(string.format('local %s = Color3.fromHSV(%s)', v, argsToList(...))); return makeProxy(v) end,
    }, { __index = function(_, k) return makeProxy("Color3." .. tostring(k)) end })
    env.Rect = newCtor("Rect")
    env.Ray = newCtor("Ray")
    env.Region3 = newCtor("Region3")
    env.Random = newCtor("Random")
    env.DateTime = setmetatable({
        now = function()
            local dt = makeProxy("DateTime")
            local mt = getmetatable(dt)
            mt._className = "DateTime"
            mt._storedValues["UnixTimestamp"] = os.time()
            mt._storedValues["UnixTimestampMillis"] = os.time() * 1000
            return dt
        end,
        fromUnixTimestamp = function(ts)
            local dt = makeProxy("DateTime")
            local mt = getmetatable(dt)
            mt._className = "DateTime"
            mt._storedValues["UnixTimestamp"] = ts
            mt._storedValues["UnixTimestampMillis"] = ts * 1000
            return dt
        end,
        fromUniversalTime = function(...)
            local dt = makeProxy("DateTime")
            local mt = getmetatable(dt)
            mt._className = "DateTime"
            mt._storedValues["UnixTimestamp"] = os.time()
            mt._storedValues["UnixTimestampMillis"] = os.time() * 1000
            return dt
        end,
        fromLocalTime = function(...)
            local dt = makeProxy("DateTime")
            local mt = getmetatable(dt)
            mt._className = "DateTime"
            mt._storedValues["UnixTimestamp"] = os.time()
            mt._storedValues["UnixTimestampMillis"] = os.time() * 1000
            return dt
        end,
    }, { __index = function(_, k) return makeProxy("DateTime." .. tostring(k)) end })
    env.NumberRange = newCtor("NumberRange")
    env.NumberSequence = newCtor("NumberSequence")
    env.NumberSequenceKeypoint = newCtor("NumberSequenceKeypoint")
    env.ColorSequence = newCtor("ColorSequence")
    env.ColorSequenceKeypoint = newCtor("ColorSequenceKeypoint")
    env.PhysicalProperties = newCtor("PhysicalProperties")
    env.TweenInfo = newCtor("TweenInfo")
    env.RaycastParams = newCtor("RaycastParams")
    env.OverlapParams = newCtor("OverlapParams")
    env.PathWaypoint = newCtor("PathWaypoint")
    env.Font = setmetatable({}, { __index = function(_, k) return makeProxy("Font." .. tostring(k)) end })
    env.buffer = setmetatable({
        create = function(n) return { _data = string.rep("\0", n or 0) } end,
        fromstring = function(s) return { _data = s or "" } end,
        tostring = function(b) return b and b._data or "" end,
        len = function(b) return b and #(b._data) or 0 end,
    }, { __index = function() return function() end end })
    env.Buffer = env.buffer

    local YIELD_BUDGET = 1
    local yieldCount = 0
    local function yieldTick()
        yieldCount += 1
        if yieldCount > YIELD_BUDGET then
            error(BUDGET_ERROR, 0)
        end
    end
    _G._yieldTick = yieldTick
    local function runCallback(f, ...)
        if type(f) ~= "function" then return end
        local savedYieldCount = yieldCount
        yieldCount = 0
        local ok, err = pcall(f, ...)
        yieldCount = savedYieldCount
        if not ok and tostring(err):find(BUDGET_ERROR, 1, true) then
        end
    end
    local taskTbl = {
        wait = function() yieldTick(); tick(); return 0 end,
        spawn = function(f, ...) tick(); runCallback(f, ...) end,
        delay = function(t, f) tick(); runCallback(f) end,
        cancel = function() end,
        clock = function() return os.clock() end,
        defer = function(f, ...) tick(); runCallback(f, ...) end,
        synchronize = function() end,
        desynchronize = function() end,
    }
    env.task = setmetatable(taskTbl, {
        __newindex = function() error("attempt to write to read-only library table", 2) end
    })
    env.wait = function() yieldTick(); return 0 end
    env.spawn = env.task.spawn
    env.delay = env.task.delay
    env.tick = function() return os.time() end
    env.time = function() return os.time() end
    env.elapsedTime = function() return os.clock() end
    env.elapsedtime = env.elapsedTime
    env.stats = function() return {} end
    env.hookfunction = function(...) return ... end
    env.checkcaller = function() return false end
    env.getrawmetatable = function(t) return getmetatable(t) end
    env.identifyexecutor = function() return "envlog", "1.0" end
    env.http_request = function() return { StatusCode = 200, Body = "", Success = true } end
    env.request = env.http_request
    env.setclipboard = function() end
    env.readfile = function() return "" end
    env.writefile = function() end
    env.isfile = function() return false end
    env.newcclosure = function(f) return f end
    env.getgc = function() return {} end
    env.getgenv = function() return env end
    env.getrenv = function() return setmetatable({}, { __index = env }) end
    env.gethui = function() return env.game end
    env.gethwid = function() return "sandbox-hwid-12345" end
    env.getcustomasset = function() return "rbxasset://temp" end
    env.getinstances = function() return {} end
    env.getnilinstances = function() return {} end
    env.getscripts = function() return {} end
    env.getloadedmodules = function() return {} end
    local runningScriptsList = { "Animate", "HealthScript", "SoundPlus", "RbxCharacter", "ControlScript", "CameraScript" }
    env.getrunningscripts = function()
        local result = {}
        for _, name in ipairs(runningScriptsList) do
            local proxy = makeProxy(name)
            local mt = getmetatable(proxy)
            mt._isRunningScript = true
            table.insert(result, proxy)
        end
        return result
    end
    env.getcallbackvalue = function(f) return f end
    env.isluau = function() return true end
    env.isourclosure = function() return false end
    env.iscclosure = function(f)
        if type(f) ~= "function" then return false end
        return true
    end
    env.islclosure = function(f)
        if type(f) ~= "function" then return false end
        return false
    end
    env.isexecutorclosure = function() return false end
    env.getscriptbytecode = function(script)
        if script == nil then error("invalid argument to getscriptbytecode", 2) end
        if type(script) == "table" then
            local m = getmetatable(script)
            if m and m._isProxy then
                local nm = m._name or ""
                if nm:find("Animate") then return "bytecode" end
                if nm:find("LocalScript") or nm:find("inst") then return nil end
                return nil
            end
        end
        error("invalid argument to getscriptbytecode", 2)
    end
    env.getscriptclosure = function(script)
        return function() end
    end
    env.decompile = function(script)
        if type(script) == "table" then
            local m = getmetatable(script)
            if m and m._isProxy then
                local nm = m._name or ""
                if nm:find("LocalScript") or nm:find("inst") then return "Bytecode is empty" end
            end
        end
        return "decompile failed"
    end
    env.getscripthash = function() return "" end
    env.clonefunction = function(f) return f end
    env.cloneref = function(ref) return ref end
    env.compareinstances = function(a, b) return a == b end
    env.loadstring = makeProxy("loadstring")
    env.setclipboard = function() end
    env.getclipboard = function() return "" end
    env.readfile = function() return "" end
    env.writefile = function() end
    env.appendfile = function() end
    env.makefolder = function() end
    env.delfile = function() end
    env.delfolder = function() end
    env.isfile = function() return false end
    env.isfolder = function() return false end
    env.listfiles = function() return {} end
    env.loadfile = function() return nil end
    env.gethiddenproperty = function() return nil, false end
    env.sethiddenproperty = function() return false end
    env.getscriptable = function() return true end
    env.setscriptable = function() return true end
    env.getconnections = function() return {} end
    env.getsenv = function() return env end
    env.setthreadidentity = function(id) if id < 0 then error("invalid identity", 2) end end
    env.getthreadidentity = function() return 2 end
    env.getidentity = function() return 2 end
    env.setidentity = function(id) if id < 0 then error("invalid identity", 2) end end
    env.fireclickdetector = function() end
    env.fireproximityprompt = function() end
    env.hookmetamethod = function() return function() end end
    env.isrbxactive = function() return true end
    env.lz4compress = function(s) return s end
    env.lz4decompress = function(s) return s end
    env.getnamecallmethod = function() return "" end
    env.setnamecallmethod = function() end
    env.setrawmetatable = function(t, mt) return setmetatable(t, mt) end
    env.isreadonly = function() return false end
    env.setreadonly = function() end
    env.getrenderproperty = function() return nil end
    env.setrenderproperty = function() end
    env.cleardrawcache = function() end
    env.toast = function() end
    env.messagebox = function() return 1 end
    env.zstdcompress = function(s) return s end
    env.zstddecompress = function(s) return s end
    env.qrcode = function() return "" end
    env.newproxy = function() return setmetatable({}, {}) end
    env.gcinfo = function() return 0 end
    env.collectgarbage = function() return 0 end
    env.require = function() return nil end
    env.shared = env
    env.Drawing = setmetatable({}, { __index = function(_, k) return makeProxy("Drawing." .. tostring(k)) end })
    env.crypt = setmetatable({}, { __index = function(_, k) return function() return makeProxy("crypt." .. tostring(k)) end end })
    env.base64 = { encode = function(s) return s or "" end, decode = function(s) return s or "" end }
    env.syn = setmetatable({}, { __index = function(_, k) return makeProxy("syn." .. tostring(k)) end })
    env.process = setmetatable({
        exit = function() emit("-- process.exit() called") end,
        args = {}, env = {}, cwd = function() return "/" end, os = "linux", pid = 1,
    }, { __index = function(_, k) return makeProxy("process." .. tostring(k)) end })

    return env
end

local function isGenericVar(name: string): boolean
    return name:match("^v%d+$") ~= nil or name:match("^color%d+$") ~= nil or name:match("^inst%d+$") ~= nil
end

local function deadCodeElimination()
    local result = {}
    for _, line in ipairs(lines) do
        local v = string.match(line, "^local ([%a_][%w_]*%d+) = (.+)$")
        if v and isGenericVar(v) and (usedVars[v] or 0) == 0 then
            local expr = string.match(line, "^local [%a_][%w_]*%d+ = (.+)$")
            if not expr:match("^Color3%.") and not expr:match("^Instance%.new") and not expr:match("^Vector3%.") then
                table.insert(result, expr)
            end
        else
            table.insert(result, line)
        end
    end
    lines = result
end

local function inlineVars()
    if not Settings.inline then return end
    local maxIter = 100
    while maxIter > 0 do
        maxIter -= 1

        local useCount = {}
        local defIdx = {}
        local defExpr = {}
        for i, line in ipairs(lines) do
            local v, expr = string.match(line, "^local ([%a_][%w_]*%d+) = (.+)$")
            if v and isGenericVar(v) then
                defIdx[v] = i
                defExpr[v] = expr
            end
            for var in string.gmatch(line, "[%a_][%w_]*%d+") do
                if var ~= v then
                    useCount[var] = (useCount[var] or 0) + 1
                end
            end
        end

        local bestVar = nil
        local bestIdx = 0
        for v, idx in pairs(defIdx) do
            if (useCount[v] or 0) == 1 and idx > bestIdx then
                local expr = defExpr[v]
                if #expr < 200 and not expr:match("^function") and not expr:match("^%{") then
                    bestVar = v
                    bestIdx = idx
                end
            end
        end

        if not bestVar then break end

        local expr = defExpr[bestVar]
        local pattern = "%f[%w_]" .. bestVar .. "%f[^%w_]"
        local newLines = {}
        for i, line in ipairs(lines) do
            if i == bestIdx then
            else
                table.insert(newLines, (string.gsub(line, pattern, expr)))
            end
        end
        lines = newLines
    end
end

local function beautify()
    if not Settings.beautify then return end
    local result = {}
    local lastLine = nil
    local lastGroup = nil
    for _, line in ipairs(lines) do
        if line ~= lastLine then
            local group = nil
            if line:match(":GetService%(") then group = "service"
            elseif line:match(":Tab%(") then group = "tab"
            elseif line:match(":Section%(") then group = "section"
            elseif line:match(":Connect%(") then group = "connect"
            end
            if group and group ~= lastGroup and #result > 0 then
                table.insert(result, "")
            end
            table.insert(result, line)
            lastLine = line
            if group then lastGroup = group end
        end
    end
    lines = result
end

local DARKLUA_BIN = (process.env.DARKLUA_BIN or "darklua") :: string

local function isValidIdent(s: string): boolean
    return s ~= "" and s:match("^[%a_][%w_]*$") ~= nil
end

local function splitTableEntries(body: string): { string }
    local entries: { string } = {}
    local depth = 0
    local inStr = false
    local strDelim = ""
    local inLong = false
    local longLevel = 0
    local startIdx = 1
    local i = 1
    while i <= #body do
        local ch = body:sub(i, i)
        local two = body:sub(i, i + 1)
        if inLong then
            local close = "]" .. string.rep("=", longLevel) .. "]"
            if body:sub(i, i + #close - 1) == close then
                inLong = false
                i += #close
                continue
            end
            i += 1
            continue
        end
        if inStr then
            if ch == "\\" then
                i += 2
                continue
            end
            if ch == strDelim then
                inStr = false
            end
            i += 1
            continue
        end
        if two == "[[" or (two == "[" and body:match("^%[=%[", i)) then
            local m = body:match("^%[(=*)%[", i)
            if m then
                inLong = true
                longLevel = #m
                i += 2 + #m
                continue
            end
        end
        if ch == '"' or ch == "'" then
            inStr = true
            strDelim = ch
            i += 1
            continue
        end
        if ch == "{" or ch == "(" or ch == "[" then
            depth += 1
        elseif ch == "}" or ch == ")" or ch == "]" then
            depth -= 1
        elseif ch == "," and depth == 0 then
            local entry = body:sub(startIdx, i - 1)
            entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
            if entry ~= "" then table.insert(entries, entry) end
            startIdx = i + 1
        end
        i += 1
    end
    local last = body:sub(startIdx, #body)
    last = last:gsub("^%s+", ""):gsub("%s+$", "")
    if last ~= "" then table.insert(entries, last) end
    return entries
end

local function findTableBody(s: string, start: number): (number?, number?)
    if s:sub(start, start) ~= "{" then return nil end
    local depth = 1
    local i = start + 1
    local inStr = false
    local strDelim = ""
    local inLong = false
    local longLevel = 0
    while i <= #s do
        local ch = s:sub(i, i)
        if inLong then
            local close = "]" .. string.rep("=", longLevel) .. "]"
            if s:sub(i, i + #close - 1) == close then
                inLong = false
                i += #close
                continue
            end
            i += 1
            continue
        end
        if inStr then
            if ch == "\\" then i += 2; continue end
            if ch == strDelim then inStr = false end
            i += 1
            continue
        end
        local m = s:match("^%[(=*)%[", i)
        if m then
            inLong = true
            longLevel = #m
            i += 2 + #m
            continue
        end
        if ch == '"' or ch == "'" then
            inStr = true
            strDelim = ch
            i += 1
            continue
        end
        if ch == "{" then
            depth += 1
        elseif ch == "}" then
            depth -= 1
            if depth == 0 then return start + 1, i - 1 end
        end
        i += 1
    end
    return nil
end

local function expandTable(body: string, baseIndent: string, parentIndent: string): string
    local entries = splitTableEntries(body)
    if #entries <= 1 then
        if #entries == 0 then
            return "{}"
        end
        return "{ " .. entries[1] .. " }"
    end

    local lines: { string } = {}
    for idx, entry in ipairs(entries) do
        local expanded = entry
        expanded = expanded:gsub("%s*,%s*$", "")
        if idx == #entries then
            table.insert(lines, baseIndent .. expanded)
        else
            table.insert(lines, baseIndent .. expanded .. ",")
        end
    end
    return "{\n" .. table.concat(lines, "\n") .. "\n" .. parentIndent .. "}"
end

local function findEmptyFunction(s: string, start: number): (number?, number?)
    local i = start
    local inStr = false
    local strDelim = ""
    local inLong = false
    local longLevel = 0
    while i <= #s do
        local ch = s:sub(i, i)
        if inLong then
            local close = "]" .. string.rep("=", longLevel) .. "]"
            if s:sub(i, i + #close - 1) == close then
                inLong = false
                i += #close
                continue
            end
            i += 1
            continue
        end
        if inStr then
            if ch == "\\" then i += 2; continue end
            if ch == strDelim then inStr = false end
            i += 1
            continue
        end
        local m = s:match("^%[(=*)%[", i)
        if m then
            inLong = true
            longLevel = #m
            i += 2 + #m
            continue
        end
        if ch == '"' or ch == "'" then
            inStr = true
            strDelim = ch
            i += 1
            continue
        end
        local fStart = s:match("^function%s*%(", i)
        if fStart then
            local parenStart = s:find("(", i, true)
            if parenStart then
                local depth = 1
                local j = parenStart + 1
                while j <= #s and depth > 0 do
                    local c = s:sub(j, j)
                    if c == "(" then depth += 1
                    elseif c == ")" then depth -= 1 end
                    j += 1
                end
                local k = j
                while k <= #s and (s:sub(k, k):match("%s")) do k += 1 end
                if s:sub(k, k + 2) == "end" then
                    local after = s:sub(k + 3, k + 3)
                    if after == "" or not after:match("[%w_]") then
                        return i, k + 2
                    end
                end
            end
        end
        i += 1
    end
    return nil
end

local function leadingIndent(line: string): string
    return line:match("^([\t ]*)") or ""
end

local function beautifyLine(line: string): { string }
    local indent = leadingIndent(line)
    local body = line:sub(#indent + 1)

    local function expandAllTables(s: string): string
        local result = s
        local progress = true
        local guard = 0
        while progress and guard < 50 do
            guard += 1
            progress = false
            local pos = 1
            while pos <= #result do
                local bs = string.find(result, "{", pos, true)
                if not bs then break end
                local bodyStart, bodyEnd = findTableBody(result, bs)
                if bodyStart and bodyEnd then
                    local innerBody = result:sub(bodyStart, bodyEnd)
                    if not innerBody:find("\n", 1, true) then
                        local entries = splitTableEntries(innerBody)
                        if #entries > 1 then
                            local innerExpanded = expandTable(innerBody, indent .. "\t", indent)
                            local before = result:sub(1, bs - 1)
                            local after = result:sub(bodyEnd + 2)
                            result = before .. innerExpanded .. after
                            progress = true
                            pos = #before + #innerExpanded + 1
                            continue
                        end
                    end
                    pos = bs + 1
                else
                    pos = bs + 1
                end
            end
        end
        return result
    end

    body = expandAllTables(body)

    local function expandAllEmptyFunctions(s: string): string
        local result = s
        local guard = 0
        while guard < 50 do
            guard += 1
            local fs, fe = findEmptyFunction(result, 1)
            if not fs then break end
            local fnText = result:sub(fs, fe)
            local params = fnText:match("^function(%s*%b())")
            local replacement = "function" .. (params or "()") .. "\n" .. indent .. "end"
            result = result:sub(1, fs - 1) .. replacement .. result:sub(fe + 1)
        end
        return result
    end

    body = expandAllEmptyFunctions(body)

    local outLines: { string } = {}
    for line2 in body:gmatch("[^\n]*") do
        if line2 ~= "" then
            if #outLines == 0 and line2:sub(1, 1) ~= "\t" and line2:sub(1, 1) ~= " " then
                table.insert(outLines, indent .. line2)
            else
                table.insert(outLines, line2)
            end
        end
    end
    if #outLines == 0 then
        table.insert(outLines, indent .. body)
    elseif outLines[1]:sub(1, #indent) ~= indent and outLines[1]:sub(1, 1) ~= "\t" and outLines[1]:sub(1, 1) ~= " " then
        outLines[1] = indent .. outLines[1]
    end
    return outLines
end

local function iterLines(s: string): () -> string?
    local pos = 1
    local len = #s
    return function(): string?
        if pos > len then return nil end
        local eol = s:find("\n", pos, true) or (len + 1)
        local line = s:sub(pos, eol - 1)
        pos = eol + 1
        return line
    end
end

local function customBeautify(source: string): string
    if not Settings.beautify then return source end
    local output: { string } = {}
    for line in iterLines(source) do
        if line == "" then
            table.insert(output, "")
        else
            local beautified = beautifyLine(line)
            for _, l in ipairs(beautified) do
                table.insert(output, l)
            end
        end
    end
    local collapsed: { string } = {}
    local blankRun = 0
    for _, l in ipairs(output) do
        if l == "" then
            blankRun += 1
            if blankRun <= 1 then table.insert(collapsed, l) end
        else
            blankRun = 0
            table.insert(collapsed, l)
        end
    end
    while #collapsed > 0 and collapsed[#collapsed] == "" do
        table.remove(collapsed, #collapsed)
    end
    return table.concat(collapsed, "\n")
end

local function darkluaBeautify(source: string): string
    return customBeautify(source)
end

local function dump(source: string): string
    lines = {}
    varCount = 0
    usedVars = {}
    for k in pairs(propertyChangeCallbacks) do propertyChangeCallbacks[k] = nil end
    for i = #eventConnections, 1, -1 do eventConnections[i] = nil end
    for k in pairs(instanceTags) do instanceTags[k] = nil end
    for k in pairs(serviceCache) do serviceCache[k] = nil end
    for k in pairs(destroyedInstances) do destroyedInstances[k] = nil end
    for k in pairs(memStorage) do memStorage[k] = nil end
    emit("-- EnvLog output")
    emit("")
    local env = createEnv()

    local fn
    local loadOk, loadErr = pcall(function()
        local compiled = luau.compile(source, { optimizationLevel = 2 })
        fn = luau.load(compiled, { debugName = "envlog", environment = env })
    end)
    if not loadOk or not fn then
        emit(string.format("-- Load error: %s", tostring(loadErr):sub(1, 200)))
        return table.concat(lines, "\n")
    end
    local ok, err = pcall(fn)
    if not ok then
        local errStr = tostring(err)
        if not errStr:find(BUDGET_ERROR, 1, true) then
            emit(string.format("-- Runtime error: %s", errStr:sub(1, 300)))
        end
    end

    inlineVars()
    deadCodeElimination()
    beautify()
    local raw = table.concat(lines, "\n")
    return darkluaBeautify(raw)
end

if Settings.ipt then
    local ok, err = pcall(function()
        if not fs.isFile(Settings.ipt) then
            error("File not found: " .. Settings.ipt)
        end
    end)
    if not ok then
        stdio.write("Error: " .. tostring(err) .. "\n")
        process.exit(1)
    end
    local source = fs.readFile(Settings.ipt)
    local result = dump(source)
    fs.writeFile(Settings.out, result)
    stdio.write(string.format("Done! Output: %s (%d bytes, %d lines)\n", Settings.out, #result, #lines))
    process.exit(0)
end

while true do
    local input = stdio.readLine()
    if not input or input == "" then break end
    local decoded = serde.decode("json", input)
    local result = dump(decoded.script)
    stdio.write(result)
    stdio.write("\n---END---\n")
end
