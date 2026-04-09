--[[
    SLUWH CURSED BLADE SCRIPT - RAYFIELD EDITION
    Credits: Sluwh
    Rayfield UI: Clean, modern, fully compatible.
    TOGGLE KEY: RightShift (Right Shift)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- RAYFIELD UI INITIALIZATION
-- =========================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Sluwh CursedBlade Script",
    Icon = 0,
    LoadingTitle = "Sluwh CursedBlade",
    LoadingSubtitle = "by Sluwh",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = false,
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- =========================
-- TABS
-- =========================
local FarmingTab = Window:CreateTab("Farming", 4483362458)
local BuffsTab   = Window:CreateTab("Buffs",   4483362458)
local SettingsTab = Window:CreateTab("Config", 4483362458)

-- =========================
-- MASTER SETTINGS & STATE
-- =========================
local Settings = {
    AttackDelay    = 0.05,
    HitsPerTarget  = 5,
    DetectionRange = 250,
    PullDistance   = 8,
    HitboxSize     = 1000,
    LootRange      = 400,
    WalkSpeed      = 16,
    FlyHeight      = 50,
    FlySpeed       = 50,
}

local BuffVars = {
    DamageValue   = "222222222222222.54",
    DamageDuration = "12.036",
    HealthDuration = "12.036",
    CritDuration   = "12.036",
    CustomID  = "1004",
    CustomVal = "1",
    CustomDur = "60"
}

_G.ScriptDestroyed    = false
_G.AutoFarmEnabled    = false
_G.RemoteSpamEnabled  = false
_G.HitboxEnabled      = false
_G.SkillRemoteEnabled = false
_G.AutoLootEnabled    = false
_G.AutoChestEnabled   = false
_G.AutoFlyEnabled     = false
_G.NoclipEnabled      = false
_G.WayPoint1 = nil
_G.WayPoint2 = nil
_G.WayPoint3 = nil

-- =========================
-- CORE HELPER FUNCTIONS
-- =========================
local function safeLoop(interval, callback)
    task.spawn(function()
        while not _G.ScriptDestroyed do
            local start = tick()
            callback()
            local elapsed = tick() - start
            task.wait(math.max(0, interval - elapsed))
        end
    end)
end

local hrp, setState, triggerSkill
local function bind(char)
    hrp = char:WaitForChild("HumanoidRootPart", 5)
    local net = char:WaitForChild("NetMessage", 5)
    if net then
        setState    = net:WaitForChild("SetState", 5)
        triggerSkill = net:WaitForChild("TrigerSkill", 5)
    end
end
if player.Character then bind(player.Character) end
player.CharacterAdded:Connect(bind)

local entityFolder = workspace:WaitForChild("Entity")
local fxFolder     = workspace:WaitForChild("FX")
local sellRemote   = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("RemoteEvent")

local mobs = {}
local function updateMobs()
    table.clear(mobs)
    for _, mob in ipairs(entityFolder:GetChildren()) do
        local hum  = mob:FindFirstChildOfClass("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if hum and root and hum.Health > 0 then
            table.insert(mobs, {mob = mob, root = root, hum = hum})
        end
    end
end

-- =========================
-- FARMING TAB INTERFACE
-- =========================
FarmingTab:CreateSection("Auto Combat")

FarmingTab:CreateToggle({
    Name         = "Auto Farm (Mob Pull)",
    CurrentValue = false,
    Flag         = "AutoFarm",
    Callback     = function(state)
        _G.AutoFarmEnabled = state
    end,
})

FarmingTab:CreateToggle({
    Name         = "Auto Kill (Attack Engine)",
    CurrentValue = false,
    Flag         = "AutoKill",
    Callback     = function(state)
        _G.SkillRemoteEnabled = state
    end,
})

FarmingTab:CreateSection("Loot & Extras")

FarmingTab:CreateToggle({
    Name         = "Auto Loot (Magnet)",
    CurrentValue = false,
    Flag         = "AutoLoot",
    Callback     = function(state)
        _G.AutoLootEnabled = state
    end,
})

FarmingTab:CreateToggle({
    Name         = "Auto Open Chests",
    CurrentValue = false,
    Flag         = "AutoChest",
    Callback     = function(state)
        _G.AutoChestEnabled = state
    end,
})

FarmingTab:CreateToggle({
    Name         = "Auto Sell (Batch 1-100)",
    CurrentValue = false,
    Flag         = "AutoSell",
    Callback     = function(state)
        _G.RemoteSpamEnabled = state
    end,
})

FarmingTab:CreateToggle({
    Name         = "Hitbox Expander (Big Mobs)",
    CurrentValue = false,
    Flag         = "Hitbox",
    Callback     = function(state)
        _G.HitboxEnabled = state
    end,
})

FarmingTab:CreateSection("Auto Flight & Travel")

FarmingTab:CreateToggle({
    Name         = "Start Auto Flight",
    CurrentValue = false,
    Flag         = "AutoFly",
    Callback     = function(state)
        _G.AutoFlyEnabled = state
    end,
})

FarmingTab:CreateToggle({
    Name         = "Enable Noclip",
    CurrentValue = false,
    Flag         = "Noclip",
    Callback     = function(state)
        _G.NoclipEnabled = state
    end,
})

FarmingTab:CreateButton({
    Name     = "Set Waypoint 1",
    Info     = "Guarda posición de origen.",
    Callback = function()
        if hrp then _G.WayPoint1 = hrp.Position end
        Rayfield:Notify({ Title = "Waypoint 1", Content = "Posición guardada.", Duration = 3, Image = 4483362458 })
    end,
})

FarmingTab:CreateButton({
    Name     = "Set Waypoint 2",
    Info     = "Guarda posición de destino.",
    Callback = function()
        if hrp then _G.WayPoint2 = hrp.Position end
        Rayfield:Notify({ Title = "Waypoint 2", Content = "Posición guardada.", Duration = 3, Image = 4483362458 })
    end,
})

FarmingTab:CreateButton({
    Name     = "Set Waypoint 3",
    Info     = "Tercer punto de patrulla (Opcional).",
    Callback = function()
        if hrp then _G.WayPoint3 = hrp.Position end
        Rayfield:Notify({ Title = "Waypoint 3", Content = "Posición guardada.", Duration = 3, Image = 4483362458 })
    end,
})

FarmingTab:CreateButton({
    Name     = "Clear All Waypoints",
    Info     = "Resetea las posiciones guardadas.",
    Callback = function()
        _G.WayPoint1 = nil; _G.WayPoint2 = nil; _G.WayPoint3 = nil
        Rayfield:Notify({ Title = "Waypoints", Content = "Todos los waypoints eliminados.", Duration = 3, Image = 4483362458 })
    end,
})

FarmingTab:CreateSlider({
    Name         = "Flight Height",
    Info         = "Ajusta tu altitud de vuelo.",
    Range        = {1, 1000},
    Increment    = 1,
    CurrentValue = 50,
    Flag         = "FlyHeight",
    Callback     = function(s)
        Settings.FlyHeight = s
    end,
})

FarmingTab:CreateSlider({
    Name         = "Flight Speed",
    Info         = "Controla la velocidad del vuelo.",
    Range        = {1, 300},
    Increment    = 1,
    CurrentValue = 50,
    Flag         = "FlySpeed",
    Callback     = function(s)
        Settings.FlySpeed = s
    end,
})

-- =========================
-- BUFFS TAB INTERFACE
-- =========================
BuffsTab:CreateSection("⚠️ PRESS ENTER ON TEXTBOXES TO SAVE ⚠️")

BuffsTab:CreateSection("Damage Buff")

BuffsTab:CreateInput({
    Name                    = "Multiplier Value",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "222222222222222.54",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt)
        BuffVars.DamageValue = txt
    end,
})

BuffsTab:CreateInput({
    Name                    = "Duration",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "12.036",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt)
        BuffVars.DamageDuration = txt
    end,
})

BuffsTab:CreateButton({
    Name     = "Apply Damage Buff",
    Info     = "Applies extreme damage.",
    Callback = function()
        local dV  = tonumber(BuffVars.DamageValue)   or 222222222222222.54
        local dur = tonumber(BuffVars.DamageDuration) or 12.036
        pcall(function() player.Character.NetMessage.AddBuff:FireServer(1004, {[1] = dV}, nil, dur) end)
    end,
})

BuffsTab:CreateSection("Health Buff")

BuffsTab:CreateInput({
    Name                    = "Health Duration",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "12.036",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt)
        BuffVars.HealthDuration = txt
    end,
})

BuffsTab:CreateButton({
    Name     = "Instantly Max Health",
    Info     = "Heals you to full health.",
    Callback = function()
        local dur = tonumber(BuffVars.HealthDuration) or 12.036
        pcall(function() player.Character.NetMessage.AddBuff:FireServer(2002, {[1] = 222222222222222.54}, nil, dur) end)
    end,
})

BuffsTab:CreateSection("Critical Buff")

BuffsTab:CreateInput({
    Name                    = "Crit Duration",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "12.036",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt)
        BuffVars.CritDuration = txt
    end,
})

BuffsTab:CreateButton({
    Name     = "Super Crit Buff",
    Info     = "Increases crit chance to 65%.",
    Callback = function()
        local dur = tonumber(BuffVars.CritDuration) or 12.036
        pcall(function() player.Character.NetMessage.AddBuff:FireServer(2010, {[1] = 223333}, nil, dur) end)
    end,
})

BuffsTab:CreateSection("Manual Buff Tool")

BuffsTab:CreateInput({
    Name                    = "Buff ID",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "1004",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt) BuffVars.CustomID = txt end,
})

BuffsTab:CreateInput({
    Name                    = "Buff Value",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "1",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt) BuffVars.CustomVal = txt end,
})

BuffsTab:CreateInput({
    Name                    = "Buff Duration",
    Info                    = "Press ENTER when done typing",
    PlaceholderText         = "60",
    RemoveTextAfterFocusLost = false,
    Callback                = function(txt) BuffVars.CustomDur = txt end,
})

BuffsTab:CreateButton({
    Name     = "Apply Manual Buff",
    Info     = "Inject custom buff ID.",
    Callback = function()
        pcall(function()
            player.Character.NetMessage.AddBuff:FireServer(
                tonumber(BuffVars.CustomID),
                {[1] = tonumber(BuffVars.CustomVal)},
                nil,
                tonumber(BuffVars.CustomDur)
            )
        end)
    end,
})

-- =========================
-- CONFIG TAB INTERFACE
-- =========================
SettingsTab:CreateSection("Attack Speed Configurations")

SettingsTab:CreateSlider({
    Name         = "Attack Delay (ms)",
    Info         = "Lower number = faster speed (drops FPS).",
    Range        = {10, 500},
    Increment    = 5,
    CurrentValue = 50,
    Flag         = "AttackDelay",
    Callback     = function(s)
        Settings.AttackDelay = s / 1000
    end,
})

SettingsTab:CreateSlider({
    Name         = "Hits Per Cycle",
    Info         = "Amount of hits per cycle (Default 5).",
    Range        = {1, 100},
    Increment    = 1,
    CurrentValue = 5,
    Flag         = "HitsPerCycle",
    Callback     = function(s)
        Settings.HitsPerTarget = s
    end,
})

SettingsTab:CreateSection("Range Configurations")

SettingsTab:CreateSlider({
    Name         = "Pull Distance",
    Info         = "Distance at which mobs are pulled.",
    Range        = {1, 30},
    Increment    = 1,
    CurrentValue = 8,
    Flag         = "PullDist",
    Callback     = function(s)
        Settings.PullDistance = s
    end,
})

SettingsTab:CreateSection("Player Configurations")

SettingsTab:CreateSlider({
    Name         = "Movement Speed",
    Info         = "Changes your character's WalkSpeed.",
    Range        = {16, 200},
    Increment    = 1,
    CurrentValue = 16,
    Flag         = "WalkSpeed",
    Callback     = function(s)
        Settings.WalkSpeed = s
    end,
})

SettingsTab:CreateSection("Emergency")

SettingsTab:CreateButton({
    Name     = "⛔ PANIC / STOP ALL",
    Info     = "Disables auto farm and all repetitive scripts.",
    Callback = function()
        _G.AutoFarmEnabled    = false
        _G.SkillRemoteEnabled = false
        _G.AutoLootEnabled    = false
        _G.RemoteSpamEnabled  = false
        _G.AutoChestEnabled   = false
        _G.AutoFlyEnabled     = false
        _G.NoclipEnabled      = false
        Rayfield:Notify({ Title = "⛔ PANIC", Content = "Todos los scripts detenidos.", Duration = 4, Image = 4483362458 })
    end,
})

-- =========================
-- ULTIMATE LOOPS ENGINE
-- =========================

local patrolTarget = 1

-- Noclip Engine
RunService.Stepped:Connect(function()
    if _G.ScriptDestroyed then return end
    if _G.NoclipEnabled and player.Character then
        for _, v in ipairs(player.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
end)

-- Heartbeat Engine
RunService.Heartbeat:Connect(function(dt)
    if _G.ScriptDestroyed then return end

    -- Auto Flight Logic
    if _G.AutoFlyEnabled and hrp and _G.WayPoint1 and _G.WayPoint2 then
        local waypoints = {}
        table.insert(waypoints, Vector3.new(_G.WayPoint1.X, Settings.FlyHeight, _G.WayPoint1.Z))
        table.insert(waypoints, Vector3.new(_G.WayPoint2.X, Settings.FlyHeight, _G.WayPoint2.Z))
        if _G.WayPoint3 then
            table.insert(waypoints, Vector3.new(_G.WayPoint3.X, Settings.FlyHeight, _G.WayPoint3.Z))
        end

        if patrolTarget > #waypoints then patrolTarget = 1 end

        local currentTarget = waypoints[patrolTarget]
        local dist = (currentTarget - hrp.Position).Magnitude

        hrp.AssemblyLinearVelocity = Vector3.zero

        if dist < 5 then
            patrolTarget = patrolTarget + 1
            if patrolTarget > #waypoints then patrolTarget = 1 end
        else
            local dir    = (currentTarget - hrp.Position).Unit
            local nextPos = hrp.Position + (dir * (Settings.FlySpeed * dt))
            hrp.CFrame   = CFrame.lookAt(nextPos, currentTarget)
        end
    end

    if Settings.WalkSpeed and Settings.WalkSpeed ~= 16 then
        if player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = Settings.WalkSpeed end
        end
    end

    if not _G.AutoFarmEnabled or not hrp then return end
    local targetCF = hrp.CFrame * CFrame.new(0, 2, -Settings.PullDistance)
    local range    = Settings.DetectionRange
    local pPos     = hrp.Position
    for _, data in ipairs(mobs) do
        if data.root and data.hum.Health > 0 then
            if (data.root.Position - pPos).Magnitude <= range then
                data.root.CFrame = targetCF
                data.root.AssemblyLinearVelocity = Vector3.zero
            end
        end
    end
end)

-- Main Attack Executor
task.spawn(function()
    while not _G.ScriptDestroyed do
        if _G.SkillRemoteEnabled and setState and triggerSkill and hrp then
            updateMobs()
            local range = Settings.DetectionRange
            local pPos  = hrp.Position
            setState:FireServer("action", true)
            for _, data in ipairs(mobs) do
                if (data.root.Position - pPos).Magnitude <= range then
                    local targetCF = data.root.CFrame
                    for i = 1, Settings.HitsPerTarget do
                        triggerSkill:FireServer(101, "Enter", targetCF, 1)
                    end
                end
            end
            setState:FireServer("action", false)
        end
        task.wait(Settings.AttackDelay)
    end
end)

-- Hitbox Logic
safeLoop(0.5, function()
    if not _G.HitboxEnabled then return end
    local size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
    for _, data in ipairs(mobs) do
        if data.root and data.root.Size ~= size then
            data.root.Size         = size
            data.root.Transparency = 0.8
            data.root.CanCollide   = false
        end
    end
end)

-- Loot Logic
safeLoop(1, function()
    if not _G.AutoLootEnabled or not hrp then return end
    local range = Settings.LootRange
    for _, fx in ipairs(fxFolder:GetChildren()) do
        local part = fx:IsA("BasePart") and fx or fx.PrimaryPart
        if part and (part.Position - hrp.Position).Magnitude <= range then
            if fx:IsA("Model") then fx:PivotTo(hrp.CFrame) else fx.CFrame = hrp.CFrame end
        end
    end
end)

-- Chest Opening Logic
safeLoop(1, function()
    if not _G.AutoChestEnabled or not hrp then return end
    local range = 800
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            local parent = prompt.Parent
            local targetPos
            if parent then
                if parent:IsA("BasePart") then
                    targetPos = parent.Position
                elseif parent:IsA("Model") and parent.PrimaryPart then
                    targetPos = parent.PrimaryPart.Position
                end
            end
            if targetPos and (targetPos - hrp.Position).Magnitude <= range then
                if type(fireproximityprompt) == "function" then
                    prompt.MaxActivationDistance = math.huge
                    prompt.RequiresLineOfSight   = false
                    fireproximityprompt(prompt)
                end
            end
        end
    end
end)

-- Sell & Refresh System
local function buildSellPayload()
    local char      = player.Character
    local invFolder = player:FindFirstChild("Inventory")
                   or player:FindFirstChild("Backpack")
                   or (char and char:FindFirstChild("Inventory"))

    if invFolder then
        local slots = {}
        for i, _ in ipairs(invFolder:GetChildren()) do
            table.insert(slots, i)
        end
        if #slots > 0 then return slots end
    end

    local fallback = table.create(100)
    for i = 1, 100 do fallback[i] = i end
    return fallback
end

local function doSell()
    if not sellRemote then return end
    local payload = buildSellPayload()
    sellRemote:FireServer(539767613, payload)
end

task.spawn(function()
    while not _G.ScriptDestroyed do
        if _G.RemoteSpamEnabled then
            doSell()
            task.wait(1.5)
        else
            task.wait(0.1)
        end
    end
end)

safeLoop(30, function()
    updateMobs()
end)
