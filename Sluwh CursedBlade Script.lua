    CATCH AND TAME! - RAYFIELD EDITION
    Author: Sluwh
    UI Library: Rayfield

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer

-- =====================
-- // STATE VARIABLES
-- =====================
local autoEnabled = false
local autoclicking = false
local clickCPS = 13
local clickInterval = 1 / 13
local clickAccum = 0

local wsEnabled = false
local walkSpeed = 16
math.randomseed(tick())

local flyEnabled = false
local flySpeed = 5
local noclipEnabled = false
local infJumpEnabled = false

local espEnabled = false
local rarityFilters = {
    ["Common"] = true,
    ["Uncommon"] = true,
    ["Rare"] = true,
    ["Epic"] = true,
    ["Legendary"] = true,
    ["Mythical"] = true,
    ["Boss"] = true,
    ["Exclusive"] = true
}

-- =====================
-- // UI INITIALIZATION
-- =====================
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Catch And Tame! | Sluwh",
    LoadingTitle = "Catch And Tame!",
    LoadingSubtitle = "by Sluwh",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local MainTab = Window:CreateTab("Autoclicker", 4483362458)
local MovementTab = Window:CreateTab("Movement", 4483362458)
local ESPTab = Window:CreateTab("Pet ESP", 4483362458)
local TPTab = Window:CreateTab("Teleports", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)

-- =====================
-- // AUTOCLICKER TAB
-- =====================
MainTab:CreateSection("Autoclicker (Lasso-Auto)")

local statusLabel = MainTab:CreateLabel("Status: Waiting for lasso...", 4483362458)

MainTab:CreateToggle({
    Name = "Enable Autoclicker",
    CurrentValue = false,
    Flag = "AutoClickToggle",
    Callback = function(Value)
        autoEnabled = Value
        if not autoEnabled then
            autoclicking = false
            clickAccum = 0
            statusLabel:Set("Status: Disabled")
        else
            statusLabel:Set("Status: Waiting for lasso...")
        end
    end,
})

MainTab:CreateSlider({
    Name = "Click Speed (CPS)",
    Range = {1, 20},
    Increment = 1,
    Suffix = "CPS",
    CurrentValue = 13,
    Flag = "CPSSlider",
    Callback = function(Value)
        clickCPS = Value
        clickInterval = 1 / clickCPS
    end,
})

-- =====================
-- // MOVEMENT TAB
-- =====================
MovementTab:CreateSection("Character Enhancements")

MovementTab:CreateToggle({
    Name = "Enable WalkSpeed",
    CurrentValue = false,
    Flag = "WSToggle",
    Callback = function(Value)
        wsEnabled = Value
        if not wsEnabled then
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end
    end,
})

MovementTab:CreateSlider({
    Name = "WalkSpeed Value",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = 16,
    Flag = "WSSlider",
    Callback = function(Value)
        walkSpeed = Value
    end,
})

MovementTab:CreateSection("Flight & Physics")

MovementTab:CreateToggle({
    Name = "Enable Fly",
    CurrentValue = false,
    Flag = "FlyToggle",
    Callback = function(Value)
        flyEnabled = Value
        if flyEnabled then
            IY_startFly()
        else
            IY_stopFly()
        end
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {1, 10},
    Increment = 1,
    Suffix = "x",
    CurrentValue = 5,
    Flag = "FlySlider",
    Callback = function(Value)
        flySpeed = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "NoclipToggle",
    Callback = function(Value)
        noclipEnabled = Value
    end,
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfJumpToggle",
    Callback = function(Value)
        infJumpEnabled = Value
    end,
})

-- =====================
-- // ESP TAB
-- =====================
ESPTab:CreateSection("Pet ESP Options")

ESPTab:CreateToggle({
    Name = "Enable Pet ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(Value)
        espEnabled = Value
        if espEnabled then
            startESP()
        else
            stopESP()
        end
    end,
})

ESPTab:CreateSection("Rarity Filters")

for rarity, _ in pairs(rarityFilters) do
    ESPTab:CreateToggle({
        Name = rarity .. " Rarity",
        CurrentValue = true,
        Flag = "Filter_" .. rarity,
        Callback = function(Value)
            rarityFilters[rarity] = Value
            if espEnabled then
                clearAllESP()
                scanAndTag()
            end
        end,
    })
end

-- =====================
-- // TELEPORTS TAB
-- =====================
TPTab:CreateSection("Quick Locations")

local locations = {
    { name = "Dragon Island",     pos = Vector3.new(5, 823, -3059) },
    { name = "Bee Island",        pos = Vector3.new(106, 14, -1142)  },
    { name = "Forgotten Depths",  pos = Vector3.new(10, 6, -4984)    },
    { name = "Home Island",       pos = Vector3.new(0, 17, -2891)    },
}

for _, loc in ipairs(locations) do
    TPTab:CreateButton({
        Name = "Teleport to " .. loc.name,
        Callback = function()
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(loc.pos)
            end
        end,
    })
end

-- =====================
-- // MISC TAB
-- =====================
MiscTab:CreateSection("Utilities")

MiscTab:CreateButton({
    Name = "Anti-AFK",
    Info = "Prevents you from being kicked for inactivity.",
    Callback = function()
        local vu = game:GetService("VirtualUser")
        player.Idled:Connect(function()
            vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end)
        Rayfield:Notify({ Title = "Anti-AFK", Content = "Anti-AFK is now active.", Duration = 3 })
    end,
})

MiscTab:CreateButton({
    Name = "Rejoin Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, player)
    end,
})

MiscTab:CreateButton({
    Name = "Copy Discord Link",
    Callback = function()
        setclipboard("https://discord.gg/yourlink") -- Placeholder
        Rayfield:Notify({ Title = "Discord", Content = "Discord link copied to clipboard!", Duration = 3 })
    end,
})

-- =====================
-- // LOGIC ENGINE: AUTOCLICKER
-- =====================
local function isLocalPlayer(...)
    local args = {...}
    for _, v in ipairs(args) do
        if typeof(v) == "Instance" and v:IsA("Player") then
            return v == player
        end
        if typeof(v) == "string" then
            if v == player.Name or v == tostring(player.UserId) then
                return true
            end
        end
        if typeof(v) == "number" and v == player.UserId then
            return true
        end
    end
    return true
end

local function findRemote(name)
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name:find(name) then
            return v
        end
    end
    return nil
end

task.spawn(function()
    local throwLasso = findRemote("ThrowLasso")
    local walkPet = findRemote("RequestWalkPet")

    if throwLasso then
        throwLasso.OnClientEvent:Connect(function(...)
            if autoEnabled and isLocalPlayer(...) then
                autoclicking = true
                clickAccum = 0
                statusLabel:Set("Status: Clicking! 🟢")
            end
        end)
    end

    if walkPet then
        walkPet.OnClientEvent:Connect(function(...)
            if isLocalPlayer(...) then
                autoclicking = false
                clickAccum = 0
                statusLabel:Set("Status: Caught! ✅")
                task.delay(2, function()
                    if autoEnabled and not autoclicking then
                        statusLabel:Set("Status: Waiting for lasso...")
                    end
                end)
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if autoclicking and autoEnabled then
        clickAccum = clickAccum + dt
        if clickAccum >= clickInterval then
            clickAccum = clickAccum - clickInterval
            local mousePos = UserInputService:GetMouseLocation()
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(mousePos.X, mousePos.Y, 0, false, game, 0)
        end
    else
        clickAccum = 0
    end
end)

-- =====================
-- // LOGIC ENGINE: MOVEMENT
-- =====================
RunService.Heartbeat:Connect(function()
    if wsEnabled then
        local char = player.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum.WalkSpeed ~= walkSpeed then
                hum.WalkSpeed = walkSpeed
            end
        end
    end
    
    if noclipEnabled then
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if infJumpEnabled then
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum:GetState() ~= Enum.HumanoidStateType.Dead then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- =====================
-- // LOGIC ENGINE: FLY
-- =====================
local flyBodyVelocity, flyBodyGyro
local camera = workspace.CurrentCamera

function IY_startFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    hum.PlatformStand = true

    flyBodyGyro = Instance.new("BodyGyro")
    flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBodyGyro.CFrame = hrp.CFrame
    flyBodyGyro.D = 50
    flyBodyGyro.Parent = hrp

    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.Velocity = Vector3.zero
    flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    flyBodyVelocity.Parent = hrp

    RunService:BindToRenderStep("IYFly", Enum.RenderPriority.Camera.Value + 1, function()
        if not flyEnabled then return end
        local hrp2 = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp2 or not flyBodyVelocity or not flyBodyGyro then return end

        local speed = flySpeed * 15
        local cf = camera.CFrame
        local dir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        flyBodyGyro.CFrame = cf
        flyBodyVelocity.Velocity = dir.Magnitude > 0 and dir.Unit * speed or Vector3.zero
    end)
end

function IY_stopFly()
    RunService:UnbindFromRenderStep("IYFly")
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hrp then
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            if flyBodyGyro then flyBodyGyro:Destroy() end
        end
        if hum then hum.PlatformStand = false end
    end
end

-- =====================
-- // LOGIC ENGINE: PET ESP
-- =====================
local rarityColours = {
    ["Common"]    = Color3.fromRGB(200, 200, 200),
    ["Uncommon"]  = Color3.fromRGB(80, 200, 80),
    ["Rare"]      = Color3.fromRGB(80, 120, 255),
    ["Epic"]      = Color3.fromRGB(180, 80, 255),
    ["Legendary"] = Color3.fromRGB(255, 200, 0),
    ["Mythical"]  = Color3.fromRGB(255, 80, 80),
    ["Boss"]      = Color3.fromRGB(255, 40, 180),
    ["Exclusive"] = Color3.fromRGB(255, 215, 120),
}

local espTags = {}

local function getPetRarity(model)
    local attr = model:GetAttribute("Rarity") or model:GetAttribute("rarity")
    if attr then return tostring(attr) end
    local sv = model:FindFirstChild("Rarity") or model:FindFirstChild("rarity")
    if sv and sv:IsA("StringValue") then return sv.Value end
    for _, v in ipairs(model:GetDescendants()) do
        if v:IsA("StringValue") then
            for rarity, _ in pairs(rarityColours) do
                if v.Value:lower():find(rarity:lower()) then return v.Value end
            end
        end
    end
    return nil
end

local function getPetsFolder()
    local roaming = workspace:FindFirstChild("RoamingPets")
    return roaming and roaming:FindFirstChild("Pets")
end

function createESPTag(obj)
    if espTags[obj] then return end
    local rarity = getPetRarity(obj)
    if rarity then
        for r, enabled in pairs(rarityFilters) do
            if rarity:lower():find(r:lower()) and not enabled then return end
        end
    end

    local root = (obj:IsA("Model") and obj.PrimaryPart) or obj:FindFirstChildOfClass("BasePart") or (obj:IsA("BasePart") and obj)
    if not root then return end

    local colour = Color3.fromRGB(255, 255, 255)
    if rarity then
        for r, col in pairs(rarityColours) do
            if rarity:lower():find(r:lower()) then colour = col break end
        end
    end

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "PetESP"
    billboard.Size = UDim2.new(0, 130, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = root
    billboard.Parent = root

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.45
    bg.BorderSizePixel = 0
    bg.Parent = billboard
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = rarity and (obj.Name .. "\n[" .. rarity .. "]") or obj.Name
    txt.TextColor3 = colour
    txt.Font = Enum.Font.GothamBold
    txt.TextSize = 11
    txt.Parent = bg

    espTags[obj] = billboard
end

function clearAllESP()
    for obj, tag in pairs(espTags) do
        if tag then tag:Destroy() end
        espTags[obj] = nil
    end
end

function scanAndTag()
    local folder = getPetsFolder()
    if not folder then return end
    for _, obj in ipairs(folder:GetChildren()) do
        createESPTag(obj)
    end
end

local espConnection
function startESP()
    scanAndTag()
    local folder = getPetsFolder()
    if folder then
        espConnection = folder.ChildAdded:Connect(function(obj)
            task.wait(0.1)
            createESPTag(obj)
        end)
    end
    task.spawn(function()
        while espEnabled do
            task.wait(2)
            if espEnabled then scanAndTag() end
        end
    end)
end

function stopESP()
    if espConnection then espConnection:Disconnect() end
    clearAllESP()
end

Rayfield:Notify({
    Title = "Script Loaded",
    Content = "The UI has been successfully updated to Rayfield.",
    Duration = 5,
    Image = 4483362458,
})
