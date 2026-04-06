--[[ 
    SLUWH CURSED BLADE SCRIPT - KAVO UI EDITION
    Credits: Sluwh
    Kavo UI: Altamente optimizada, botones pequeños, 100% compatible.
    TECLA PARA OCULTAR/MOSTRAR: RightShift (Shift Derecho)
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- =========================
-- KAVO UI INITIALIZATION
-- =========================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("Sluwh CursedBlade Script", "DarkTheme")

-- =========================
-- TABS
-- =========================
local FarmingTab = Window:NewTab("Farming")
local BuffsTab = Window:NewTab("Buffs")
local SettingsTab = Window:NewTab("Config")

-- =========================
-- MASTER SETTINGS & STATE
-- =========================
local Settings = {
    AttackDelay = 0.05,
    HitsPerTarget = 5,
    DetectionRange = 250,
    PullDistance = 8,
    HitboxSize = 1000,
    LootRange = 400,
}

local BuffVars = {
    DamageValue = "222222222222222.54",
    DamageDuration = "12.036",
    HealthDuration = "12.036",
    CritDuration = "12.036",
    CustomID = "1004",
    CustomVal = "1",
    CustomDur = "60"
}

_G.ScriptDestroyed = false
_G.AutoFarmEnabled = false
_G.RemoteSpamEnabled = false
_G.HitboxEnabled = false
_G.SkillRemoteEnabled = false
_G.AutoLootEnabled = false

local SELL_PAYLOAD = table.create(100)
for i = 1, 100 do SELL_PAYLOAD[i] = i end

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
        setState = net:WaitForChild("SetState", 5)
        triggerSkill = net:WaitForChild("TrigerSkill", 5)
    end
end
if player.Character then bind(player.Character) end
player.CharacterAdded:Connect(bind)

local entityFolder = workspace:WaitForChild("Entity")
local fxFolder = workspace:WaitForChild("FX")
local sellRemote = ReplicatedStorage:WaitForChild("Remote"):WaitForChild("RemoteEvent")

local mobs = {}
local function updateMobs()
    table.clear(mobs)
    for _, mob in ipairs(entityFolder:GetChildren()) do
        local hum = mob:FindFirstChildOfClass("Humanoid")
        local root = mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if hum and root and hum.Health > 0 then
            table.insert(mobs, {mob = mob, root = root, hum = hum})
        end
    end
end

-- =========================
-- FARMING TAB INTERFACE
-- =========================
local FarmingSec1 = FarmingTab:NewSection("Auto Combat")

FarmingSec1:NewToggle("Auto Farm (Mob Pull)", "Atrae los mobs hacia ti.", function(state)
    _G.AutoFarmEnabled = state
end)

FarmingSec1:NewToggle("Auto Kill (Attack Engine)", "Sistema de daño multi-hit ultra rápido.", function(state)
    _G.SkillRemoteEnabled = state
end)

local FarmingSec2 = FarmingTab:NewSection("Loot & Extras")

FarmingSec2:NewToggle("Auto Loot (Magnet)", "Imanta todo el botín.", function(state)
    _G.AutoLootEnabled = state
end)

FarmingSec2:NewToggle("Auto Sell (Batch 1-100)", "Vende todo cada 30 segundos automáticamente.", function(state)
    _G.RemoteSpamEnabled = state
end)

FarmingSec2:NewToggle("Hitbox Expander (Big Mobs)", "Agranda a los enemigos para hitbox infinita.", function(state)
    _G.HitboxEnabled = state
end)

-- =========================
-- BUFFS TAB INTERFACE
-- =========================
local BuffSec1 = BuffsTab:NewSection("Damage Buff (ID: 1004)")

BuffSec1:NewTextBox("Multiplier Value", "Presiona ENTER al terminar", function(txt)
    BuffVars.DamageValue = txt
end)
BuffSec1:NewTextBox("Duration", "Presiona ENTER al terminar", function(txt)
    BuffVars.DamageDuration = txt
end)
BuffSec1:NewButton("Apply Damage Buff", "Aplica el daño extremo.", function()
    local dV = tonumber(BuffVars.DamageValue) or 222222222222222.54
    local dur = tonumber(BuffVars.DamageDuration) or 12.036
    pcall(function() player.Character.NetMessage.AddBuff:FireServer(1004, {[1] = dV}, nil, dur) end)
end)

local BuffSec2 = BuffsTab:NewSection("Health Buff (ID: 2002)")
BuffSec2:NewTextBox("Health Duration", "Presiona ENTER al terminar", function(txt)
    BuffVars.HealthDuration = txt
end)
BuffSec2:NewButton("Instantly Max Health", "Te da tu vida completa.", function()
    local dur = tonumber(BuffVars.HealthDuration) or 12.036
    pcall(function() player.Character.NetMessage.AddBuff:FireServer(2002, {[1] = 222222222222222.54}, nil, dur) end)
end)

local BuffSec3 = BuffsTab:NewSection("Critical Buff (ID: 2010)")
BuffSec3:NewTextBox("Crit Duration", "Presiona ENTER al terminar", function(txt)
    BuffVars.CritDuration = txt
end)
BuffSec3:NewButton("Super Crit Buff", "Incrementa la chance de crit al 65%.", function()
    local dur = tonumber(BuffVars.CritDuration) or 12.036
    pcall(function() player.Character.NetMessage.AddBuff:FireServer(2010, {[1] = 223333}, nil, dur) end)
end)

local BuffSec4 = BuffsTab:NewSection("Manual Buff Tool")
BuffSec4:NewTextBox("Buff ID", "Presiona ENTER al terminar", function(txt) BuffVars.CustomID = txt end)
BuffSec4:NewTextBox("Buff Value", "Presiona ENTER al terminar", function(txt) BuffVars.CustomVal = txt end)
BuffSec4:NewTextBox("Buff Duration", "Presiona ENTER al terminar", function(txt) BuffVars.CustomDur = txt end)
BuffSec4:NewButton("Apply Manual Buff", "Inyecta el buff personalizado.", function()
    pcall(function()
        player.Character.NetMessage.AddBuff:FireServer(tonumber(BuffVars.CustomID), {[1] = tonumber(BuffVars.CustomVal)}, nil, tonumber(BuffVars.CustomDur))
    end)
end)

-- =========================
-- MASTER SETTINGS INTERFACE
-- =========================
local SetSec1 = SettingsTab:NewSection("Attack Speed Configurations")

SetSec1:NewSlider("Attack Delay (ms)", "Menor número = mayor velocidad (bajan los FPS).", 500, 10, function(s)
    Settings.AttackDelay = s / 1000
end)

SetSec1:NewSlider("Hits Per Cycle", "Cantidad de golpes por ciclo (Default 5).", 100, 1, function(s)
    Settings.HitsPerTarget = s
end)

local SetSec2 = SettingsTab:NewSection("Ranges Configurations")

SetSec2:NewSlider("Pull Distance", "Distancia a la que se atraen los mobs.", 30, 1, function(s)
    Settings.PullDistance = s
end)

-- Botón de emergencia para desactivarlo todo si te lageas
SetSec2:NewButton("PANIC / STOP ALL", "Desactiva los auto farm y scripts repetitivos.", function()
    _G.AutoFarmEnabled = false
    _G.SkillRemoteEnabled = false
    _G.AutoLootEnabled = false
    _G.RemoteSpamEnabled = false
end)

-- =========================
-- ULTIMATE LOOPS ENGINE
-- =========================

-- Heartbeat Mob Pull
RunService.Heartbeat:Connect(function()
    if _G.ScriptDestroyed or not _G.AutoFarmEnabled or not hrp then return end
    local targetCF = hrp.CFrame * CFrame.new(0, 2, -Settings.PullDistance)
    local range = Settings.DetectionRange
    local pPos = hrp.Position
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
            local pPos = hrp.Position
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
            data.root.Size = size
            data.root.Transparency = 0.8
            data.root.CanCollide = false
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

-- Sell & Refresh System
safeLoop(30, function()
    if _G.RemoteSpamEnabled and setState then
        setState:FireServer("action", true)
        task.wait(0.1)
        sellRemote:FireServer(539767613, SELL_PAYLOAD)
        setState:FireServer("action", false)
    end
    updateMobs()
end)
