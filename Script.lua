--[[ Optimized by Deepseek, idk why ai change function name but am lazy to change it and some function it has been changed too]]--

local ui = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/gghiza07/Ui@4a6b521/Main"))()

local Window = ui:CreateWindow({
    Name = "Wiv Hub",
    Map = "Rock Fruit",
    Text = "v0.0.21",
    Save = {
        SaveConfig = true,
        SaveFolder = "Wiv hub",
        SaveFile = "",
        Fixbug = false
    },
    Key = {
        ToggleKey = Enum.KeyCode.RightControl
    }
})

local g = getgenv()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CoreGui = game:GetService("CoreGui")

local ActionRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Action")
local NetworkEvent = ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NetworkFramework"):WaitForChild("NetworkEvent")
local SystemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("System")

local gmt = getrawmetatable(game)
setreadonly(gmt, false)
local oldNamecall = gmt.__namecall

gmt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if self == ActionRemote and method == "FireServer" then
        return oldNamecall(self, unpack(args))
    end
    return oldNamecall(self, ...)
end)
setreadonly(gmt, true)

g.Autofarm = false
g.AutoStats = false
g.AutoChest = false
g.AutoCraft = false
g.AutoFarmItem = false
g.AutoFarmBoss = false
g.AutoSummonBoss = false
g.AutoRebirth = false
g.AutoDungeon = false
g.AutoMoonDungeon = false
g.AutoSpecialChest = false
g.AutoSkillMaster = false
g.AutoSkillZ = false
g.AutoSkillX = false
g.AutoSkillC = false
g.AutoSkillV = false
g.ShowDashboard = false
g.TransitionUntil = 0
g.SelectedStat = {"Melee"}
g.SelectedWeapon = "None"
g.StatAmount = 1
g.ChestAmount = "x15"
g.SelectedCraftItem = "None"
g.SelectedFarmItem = "None"
g.SelectedBoss = "None"
g.SelectedSummonBoss = "GooGooGaaGaa"
g.ItemFarmLimit = 100
g.FarmingBeliForCraft = false
g.FarmPosition = "Above"
g.FarmDistance = 6
g.CraftFarmItem = "None"
g.CraftFarmLimit = 0

local TargetMob = nil
local currentTier = nil
local lastMobTime = 0 
local spawnDelayThreshold = 1.5 
local lastEquipTime = 0
local isTeleporting = false
local lastTeleportAttempt = 0
local teleportCooldown = 3
local specialChestThread = nil
local levelmax = 22000

local CraftDatabase = {
    ["Boxing"] = { Materials = { ["Beli"] = 15000, ["Boxing Sandbag"] = 5, ["Boxing Gloves"] = 2, ["Dumbbell 25 KG"] = 1 } },
    ["Tanto"] = { Materials = { ["Beli"] = 2500, ["Wood"] = 10, ["Bandage"] = 15, ["Iron"] = 5 } },
    ["Super Bacon"] = { Materials = { ["Beli"] = 25000000, ["Bacon Rainbow"] = 15, ["Bacon"] = 1, ["Bacon Black"] = 20 } },
    ["Katana"] = { Materials = { ["Beli"] = 25000, ["Wood"] = 25, ["Iron"] = 15, ["Tanto"] = 1 } },
    ["Black Leg"] = { Materials = { ["Beli"] = 250000, ["Khaw Phad Kai"] = 5, ["Orb Fire"] = 75, ["Chef Hat"] = 1, ["Black Shoes"] = 2 }},
    ["Shisui"] = { Materials = { ["Beli"] = 3500000, ["Old Wood"] = 40, ["Black Iron"] = 75, ["Katana"] = 1, ["Gold"] = 20, ["Orb Red"] = 35 } },
    ["Kitetsu"] = { Materials = { ["Beli"] = 1500000, ["Cursed Iron"] = 15, ["Katana"] = 1, ["Orb Spirit"] = 20, ["Cursed Wood"] = 15 } },
    ["Michale Jackson"] = { Materials = { ["Beli"] = 10000000, ["Orb Dark"] = 25, ["Thompson Gun"] = 25, ["Microphone"] = 10, ["Boxing"] = 1 }},
    ["Kiribachi"] = { Materials = { ["Beli"] = 500000, ["Iron Shark Teeth"] = 12, ["Old Wood"] = 5, ["Gold"] = 15 }},
    ["Shirasaya"] = { Materials = { ["Beli"] = 100000, ["Old Iron"] = 25, ["Katana"] = 1, ["Old Wood"] = 30, ["Old Rock"] = 50 }},
    ["Karate Fish"] = { Materials = { ["Beli"] = 100000, ["Fish"] = 25, ["Black Belt"] = 7, ["Orb Water"] = 50 }},
    ["Wado"] = { Materials = { ["Beli"] = 2500000, ["Wind Stone"] = 35, ["Katana"] = 1, ["Old Wood"] = 25, ["Holy Iron"] = 50 }},
    ["Rokushiki"] = { Materials = { ["Beli"] = 15000000, ["Book of Rokuogan"] = 100, ["Boxing"] = 1 }},
    ["Yoru"] = { Materials = { ["Beli"] = 9500000, ["Holy Iron"] = 75, ["Holy Wood"] = 75, ["Orb Black"] = 75, ["Orb Green"] = 75 }},
    ["Jimina"] = { Materials = { ["Beli"] = 500000000, ["Orb Red"] = 125, ["Orb Black"] = 100, ["Shadow Diary"] = 10, ["Shadow Iron"] = 15, ["Black Iron"] = 50, ["Katana"] = 1, ["Orb Dark"] = 75, ["Scarf Old"] = 25 }},
    ["Cid"] = { Materials = { ["Beli"] = 1500000000, ["Black Slime"] = 75, ["Orb Shadow"] = 50, ["Orb Atomic"] = 25, ["Jimina"] = 1, ["Orb Purple"] = 125, ["Orb Dark"] = 150, ["Nuke"] = 1 }}
}

local ItemDatabase = {
    ["Bacon"] = { Npc = "NPC_Quest1", Items = {"Wood", "Bandage", "Bacon"}},
    ["Bacon Strong"] = { Npc = "NPC_Quest2", Items = {"Boxing Gloves", "Boxing Sandbag", "Dumbbell 25 KG"}},
    ["Bacon Traveler"] = { Npc = "NPC_Quest3", Items = {"Pipe", "Iron"}},
    ["Bacon Fawkes"] = { Npc = "NPC_Quest4", Items = {"Gold", "Black Belt"}},
    ["Bacon Pirate"] = { Npc = "NPC_Quest5", Items = {"Iron Shark Teeth"}},
    ["Bacon Clown"] = { Npc = "NPC_Quest6", Items = {"Orb Spirit"}},
    ["Bacon Tarzan"] = { Npc = "NPC_Quest7", Items = {"Old Rock", "Old Wood"}},
    ["Gorilla"] = { Npc = "NPC_Quest8", Items = {"Orb Black", "Old Iron"}},
    ["Bacon Fisherman"] = { Npc = "NPC_Quest9", Items = {"Fish"}},
    ["Bacon The Deep"] = { Npc = "NPC_Quest10", Items = {"Orb Water"}},
    ["Bacon Marine"] = { Npc = "NPC_Quest11", Items = {"Chef Hat", "Black Shoes"}},
    ["Bacon Marine Captain"] = { Npc = "NPC_Quest12", Items = {"Holy Wood", "Orb Green"}},
    ["Bacon Rock"] = { Npc = "NPC_Quest13", Items = {"Holy Stone"}},
    ["Bacon Iron"] = { Npc = "NPC_Quest14", Items = {"Holy Iron"}},
    ["Bacon Minerals"] = { Npc = "NPC_Quest15", Items = {"Holy Gold", "Black Iron"}},
    ["Bacon Kryptonite"] = { Npc = "NPC_Quest16", Items = {"Wind Stone", "Orb Red"}},
    ["Bacon Snow"] = { Npc = "NPC_Quest17", Items = {"Khaw Phad Kai", "Book of Rokuogan"}},
    ["Bacon Ice"] = { Npc = "NPC_Quest18", Items = {"Cursed Wood", "Cursed Iron"}},
    ["Bacon Lava"] = { Npc = "NPC_Quest19", Items = {"Orb Fire"}},
    ["Bacon Hellfire"] = { Npc = "NPC_Quest20", Items = {"Orb Dragon", "Dragon Fang"}},
    ["Bacon Shadow Garden"] = { Npc = "NPC_Quest21", Items = {"Shadow Iron", "Orb Purple"}},
    ["Bacon Jackson"] = { Npc = "Jackson Man", Items = {"Microphone", "Thompson Gun"}},
    ["Bacon Monster"] = { Npc = "Jackson Man", Items = {"Heart of Envy", "Cake Monster"}},
    ["Bacon Seinen"] = { Npc = "Jackson Man", Items = {"Shadow Diary", "Scarf Old"}},
}

local levelconfig = {
    {lvl = 1, lvm = 1000, Mon = "Bacon", Npc = "NPC_Quest1"},
    {lvl = 1001, lvm = 2000, Mon = "Bacon Strong", Npc = "NPC_Quest2"},
    {lvl = 2001, lvm = 3000, Mon = "Bacon Traveler", Npc = "NPC_Quest3"},
    {lvl = 3001, lvm = 4000, Mon = "Bacon Fawkes", Npc = "NPC_Quest4"},
    {lvl = 4001, lvm = 5000, Mon = "Bacon Pirate", Npc = "NPC_Quest5"},
    {lvl = 5001, lvm = 6000, Mon = "Bacon Clown", Npc = "NPC_Quest6"},
    {lvl = 6001, lvm = 7000, Mon = "Bacon Tarzan", Npc = "NPC_Quest7"},
    {lvl = 7001, lvm = 8000, Mon = "Gorilla", Npc = "NPC_Quest8"},
    {lvl = 8000, lvm = 9000, Mon = "Bacon Fisherman", Npc = "NPC_Quest9"},
    {lvl = 9001, lvm = 10000, Mon = "Bacon The Deep", Npc = "NPC_Quest10"},
    {lvl = 10001, lvm = 11000, Mon = "Bacon Marine", Npc = "NPC_Quest11"},
    {lvl = 11001, lvm = 12000, Mon = "Bacon Marine Captain", Npc = "NPC_Quest12"},
    {lvl = 12001, lvm = 13000, Mon = "Bacon Rock", Npc = "NPC_Quest13"},
    {lvl = 13001, lvm = 14000, Mon = "Bacon Iron", Npc = "NPC_Quest14"},
    {lvl = 14001, lvm = 15000, Mon = "Bacon Minerals", Npc = "NPC_Quest15"},
    {lvl = 15001, lvm = 16000, Mon = "Bacon Kryptonite", Npc = "NPC_Quest16"},
    {lvl = 16001, lvm = 17000, Mon = "Bacon Snow", Npc = "NPC_Quest17"},
    {lvl = 17001, lvm = 18000, Mon = "Bacon Ice", Npc = "NPC_Quest18"},
    {lvl = 18001, lvm = 19000, Mon = "Bacon Lava", Npc = "NPC_Quest19"},
    {lvl = 19001, lvm = 20000, Mon = "Bacon Hellfire", Npc = "NPC_Quest20"},
    {lvl = 20001, lvm = 22000, Mon = "Bacon Shadow Garden", Npc = "NPC_Quest21"},
}

local function CreateDashboard()
    local DashGui = Instance.new("ScreenGui")
    local DashFrame = Instance.new("Frame")
    local DashTitle = Instance.new("TextLabel")
    local DashScroll = Instance.new("ScrollingFrame")
    local DashListLayout = Instance.new("UIListLayout")
    local DashPadding = Instance.new("UIPadding")

    DashGui.Name = "Dashboard"
    DashGui.Parent = CoreGui
    DashGui.ResetOnSpawn = false
    DashGui.Enabled = false

    DashFrame.Name = "DashFrame"
    DashFrame.Parent = DashGui
    DashFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    DashFrame.BorderSizePixel = 0
    DashFrame.Position = UDim2.new(0.75, 0, 0.3, 0)
    DashFrame.Size = UDim2.new(0, 260, 0, 240)
    DashFrame.Active = true
    DashFrame.Draggable = true

    local MainCorner = Instance.new("UICorner", DashFrame)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke", DashFrame)
    MainStroke.Color = Color3.fromRGB(45, 45, 60)
    MainStroke.Thickness = 1.5

    DashTitle.Name = "DashTitle"
    DashTitle.Parent = DashFrame
    DashTitle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    DashTitle.BorderSizePixel = 0
    DashTitle.Size = UDim2.new(1, 0, 0, 38)
    DashTitle.Font = Enum.Font.GothamBold
    DashTitle.Text = "CRAFT TRACKER"
    DashTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    DashTitle.TextSize = 13

    local TitleCorner = Instance.new("UICorner", DashTitle)
    TitleCorner.CornerRadius = UDim.new(0, 10)

    local TitleLine = Instance.new("Frame", DashTitle)
    TitleLine.Size = UDim2.new(1, 0, 0, 2)
    TitleLine.Position = UDim2.new(0, 0, 1, -2)
    TitleLine.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    TitleLine.BorderSizePixel = 0

    DashScroll.Name = "DashScroll"
    DashScroll.Parent = DashFrame
    DashScroll.BackgroundTransparency = 1
    DashScroll.BorderSizePixel = 0
    DashScroll.Position = UDim2.new(0, 0, 0, 42)
    DashScroll.Size = UDim2.new(1, 0, 1, -47)
    DashScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    DashScroll.ScrollBarThickness = 3
    DashScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)

    DashListLayout.Parent = DashScroll
    DashListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    DashListLayout.Padding = UDim.new(0, 6)

    DashPadding.Parent = DashScroll
    DashPadding.PaddingLeft = UDim.new(0, 8)
    DashPadding.PaddingRight = UDim.new(0, 8)
    DashPadding.PaddingTop = UDim.new(0, 4)

    return DashGui, DashFrame, DashTitle, DashScroll
end

local DashGui, DashFrame, DashTitle, DashScroll = CreateDashboard()

local Utils = {
    _levelCache = 1,
    _lastLevelCheck = 0,
    _beliCache = 0,
    _lastBeliCheck = 0,
    _itemCache = {},
    _lastItemCheck = 0,
    _itemTypeCache = {}
}

function Utils.Level()
    if os.clock() - Utils._lastLevelCheck < 0.5 then return Utils._levelCache end
    local hud = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("HUD")
    if hud and hud.Main.Frame_Display.LevelText then
        local level = tonumber(string.match(hud.Main.Frame_Display.LevelText.Text, "%d+")) or 1
        Utils._levelCache = level
        Utils._lastLevelCheck = os.clock()
        return level
    end
    return Utils._levelCache
end

function Utils.getMaxLevel()
    return levelmax
end

function Utils.getMon()
    local lv = Utils.Level()
    for i, config in ipairs(levelconfig) do
        if lv >= config.lvl and lv <= config.lvm then return config.Mon, config.Npc, i end
    end
    return nil, nil, nil
end

function Utils.parseNumberString(text)
    if not text then return 0 end
    local cleanText = string.gsub(text, ",", "")
    local numStr = string.match(cleanText, "[%d%.]+")
    local num = tonumber(numStr) or 0
    local upperText = string.upper(cleanText)
    if string.find(upperText, "Qd") then num = num * 1000000000000000
    elseif string.find(upperText, "T") then num = num * 1000000000000
    elseif string.find(upperText, "B") then num = num * 1000000000
    elseif string.find(upperText, "M") then num = num * 1000000
    elseif string.find(upperText, "K") then num = num * 1000 end
    return math.floor(num + 0.5)
end

function Utils.formatNumber(num)
    if not num then return "0" end
    if num >= 1000000000000000 then return string.format("%.2f", num / 1000000000000000):gsub("*%.?0+$", "") .. "Qd"
    elseif num >= 1000000000000 then return string.format("%.2f", num / 1000000000000):gsub("%.?0+$", "") .. "T"
    elseif num >= 1000000000 then return string.format("%.2f", num / 1000000000):gsub("%.?0+$", "") .. "B"
    elseif num >= 1000000 then return string.format("%.2f", num / 1000000):gsub("%.?0+$", "") .. "M"
    elseif num >= 1000 then return string.format("%.2f", num / 1000):gsub("%.?0+$", "") .. "K" end
    return tostring(num)
end

function Utils.getBeliAmount()
    if os.clock() - Utils._lastBeliCheck < 0.5 then return Utils._beliCache end
    local amount = 0
    pcall(function()
        local display = LocalPlayer.PlayerGui.HUD.Main:FindFirstChild("Frame_Display")
        local beliTextObj = display and display.Currency.Beli.BeliText
        if beliTextObj then 
            amount = Utils.parseNumberString(beliTextObj.Text)
            Utils._beliCache = amount
            Utils._lastBeliCheck = os.clock()
        end
    end)
    return amount
end

function Utils.getItemType(itemName)
    if Utils._itemTypeCache[itemName] then
        return Utils._itemTypeCache[itemName]
    end
    
    local itemType = nil
    pcall(function()
        local inventory = LocalPlayer.PlayerGui.HUD.Main.Frame_Inventory.Handler.InventoryHandler.ScrollingFrame
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item.Name == itemName then
                    local typeAttr = item:GetAttribute("Type") or item:GetAttribute("type")
                    if typeAttr then
                        itemType = typeAttr
                    else
                        local typeObj = item:FindFirstChild("Type")
                        if typeObj then
                            itemType = typeObj.Text
                        end
                    end
                    break
                end
            end
        end
    end)
    
    Utils._itemTypeCache[itemName] = itemType
    return itemType
end

function Utils.isWeapon(itemName)
    local itemType = Utils.getItemType(itemName)
    return itemType == "Sword" or itemType == "Accessory" or itemType == "Combat"
end

function Utils.checkOwnedItem(itemName)
    if not itemName or itemName == "None" then return false end
    
    local found = false
    pcall(function()
        local inventory = LocalPlayer.PlayerGui.HUD.Main.Frame_Inventory.Handler.InventoryHandler.ScrollingFrame
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item.Name == itemName then
                    found = true
                    break
                end
            end
        end
    end)
    
    if found then return true end
    
    if LocalPlayer.Backpack:FindFirstChild(itemName) then
        return true
    end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName) then
        return true
    end
    
    return false
end

function Utils.getItemAmount(itemName)
    if Utils._itemCache[itemName] and os.clock() - Utils._lastItemCheck < 0.5 then 
        return Utils._itemCache[itemName] 
    end
    
    local amount = 0
    
    pcall(function()
        local inventory = LocalPlayer.PlayerGui.HUD.Main.Frame_Inventory.Handler.InventoryHandler.ScrollingFrame
        if inventory then
            for _, item in ipairs(inventory:GetChildren()) do
                if item.Name == itemName then
                    local typeAttr = item:GetAttribute("Type") or item:GetAttribute("type")
                    local typeText = typeAttr or ""
                    
                    if typeText == "Sword" or typeText == "Accessory" or typeText == "Combat" then
                        amount = 1
                    else
                        local amountObj = item:FindFirstChild("Amount") or (item:FindFirstChild("Main") and item.Main:FindFirstChild("Amount"))
                        if amountObj then
                            local text = amountObj.Text
                            if string.find(text, "Lv") or string.find(text, "Lv%.") then 
                                amount = 1
                            elseif string.find(text, "/") then
                                local num = string.match(text, "^(%d+)/")
                                amount = tonumber(num) or 0
                            else 
                                amount = Utils.parseNumberString(text) 
                            end
                        else
                            amount = 1
                        end
                    end
                    break
                end
            end
        end
    end)
    
    if amount == 0 then
        if LocalPlayer.Backpack:FindFirstChild(itemName) or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild(itemName)) then
            amount = 1
        end
    end
    
    Utils._itemCache[itemName] = amount
    Utils._lastItemCheck = os.clock()
    return amount
end

function Utils.getAvailableWeapons()
    local weapons = {"None"}
    local function checkFolder(folder)
        if not folder then return end
        for _, v in ipairs(folder:GetChildren()) do
            if v:IsA("Tool") and not table.find(weapons, v.Name) then table.insert(weapons, v.Name) end
        end
    end
    checkFolder(LocalPlayer.Backpack)
    if LocalPlayer.Character then checkFolder(LocalPlayer.Character) end
    return weapons
end

function Utils.getNpcObject(npcName)
    if not npcName then return nil end
    if workspace:FindFirstChild("NpcQuest") and workspace.NpcQuest:FindFirstChild(npcName) then return workspace.NpcQuest[npcName] end
    if workspace:FindFirstChild("NpcWeapon") and workspace.NpcWeapon:FindFirstChild(npcName) then return workspace.NpcWeapon[npcName] end
    return workspace:FindFirstChild(npcName)
end

function Utils.findMobByItem(itemName)
    for mobName, data in pairs(ItemDatabase) do
        if table.find(data.Items, itemName) then return mobName, data.Npc end
    end
    return nil, nil
end

function Utils.realHoldButton(btn)
    if not btn or not btn.Visible then return end
    pcall(function()
        if firesignal then
            firesignal(btn.MouseButton1Click)
            firesignal(btn.Activated)
        else
            local inset, _ = GuiService:GetGuiInset()
            local x = btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2) + inset.X
            local y = btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2) + inset.Y
            VirtualInputManager:SendTouchEvent(1, 0, x, y)
            task.wait(0.05)
            VirtualInputManager:SendTouchEvent(1, 2, x, y)
        end
    end)
end

function Utils.hasSpaceTicket()
    return Utils.checkOwnedItem("Space Ticket") or Utils.getItemAmount("Space Ticket") > 0
end

local function getEventStoneAmount()
    local amount = 0
    pcall(function()
        local display = LocalPlayer.PlayerGui.HUD.Main.Frame_Display.Currency["Event Stone"]
        if display and display.TextLabel then
            local text = display.TextLabel.Text
            amount = tonumber(string.match(text, "%d+")) or 0
        end
    end)
    return amount
end

local function openSpecialChest(chestType)
    local eventStone = getEventStoneAmount()
    local cost = 0
    
    if chestType == "x5" then cost = 25
    elseif chestType == "x10" then cost = 50
    elseif chestType == "x15" then cost = 75
    else return false end
    
    if eventStone >= cost then
        pcall(function()
            NetworkEvent:FireServer("fire", nil, "EventMoon", chestType)
        end)
        return true
    else
        return false
    end
end

local function enterMoonDungeon()
    if isTeleporting then return end
    if os.clock() - lastTeleportAttempt < teleportCooldown then return end
    if game.PlaceId == 82878101790702 then return end

    isTeleporting = true
    lastTeleportAttempt = os.clock()

    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end

        local hrp = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not hrp or not humanoid or humanoid.Health <= 0 then return end

        local npcPromptFolder = workspace:FindFirstChild("NpcPrompt")
        local npc = npcPromptFolder and npcPromptFolder:FindFirstChild("GoMoon")
        if not npc then return end

        local npcPos = npc:FindFirstChild("HumanoidRootPart")
        if npcPos then
            hrp.CFrame = npcPos.CFrame * CFrame.new(0, 0, 3)
            task.wait(0.3)
        end

        if fireproximityprompt then
            for _, prompt in ipairs(npc:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") then
                    fireproximityprompt(prompt)
                    task.wait(0.2)
                end
            end
        end

        local portal = nil
        local waitTime = 0
        local maxWait = 5
        
        repeat
            task.wait(0.1)
            waitTime = waitTime + 0.1
            
            for _, obj in ipairs(workspace:GetChildren()) do
                if obj.Name == "Portal" or (obj.Name and string.find(obj.Name, "Portal")) then
                    portal = obj
                    break
                end
            end
        until portal or waitTime >= maxWait

        if portal then
            local portalPos = portal:FindFirstChild("HumanoidRootPart") or portal:FindFirstChild("Part")
            if portalPos then
                hrp.CFrame = portalPos.CFrame * CFrame.new(0, 0, -3)
                task.wait(0.1)
                hrp.CFrame = portalPos.CFrame * CFrame.new(0, 0, -1)
                task.wait(0.1)
                hrp.CFrame = portalPos.CFrame
                task.wait(0.3)
            end
        else
            if fireproximityprompt then
                for _, prompt in ipairs(npc:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        fireproximityprompt(prompt)
                        task.wait(0.2)
                    end
                end
            end
            
            waitTime = 0
            repeat
                task.wait(0.1)
                waitTime = waitTime + 0.1
                for _, obj in ipairs(workspace:GetChildren()) do
                    if obj.Name == "Portal" or (obj.Name and string.find(obj.Name, "Portal")) then
                        portal = obj
                        break
                    end
                end
            until portal or waitTime >= 3
            
            if portal then
                local portalPos = portal:FindFirstChild("HumanoidRootPart") or portal:FindFirstChild("Part")
                if portalPos then
                    hrp.CFrame = portalPos.CFrame
                    task.wait(0.3)
                end
            end
        end

        task.wait(1.5)
    end)

    isTeleporting = false
end

local CombatSystem = {}

function CombatSystem.equipAndGetWeapon()
    local weaponName = g.SelectedWeapon
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChildOfClass("Humanoid") then return nil end
    
    if not weaponName or weaponName == "None" or weaponName == "" then
        local currentTool = character:FindFirstChildOfClass("Tool")
        return currentTool and currentTool.Name
    end
    
    if character:FindFirstChild(weaponName) then return weaponName end
    
    if os.clock() - lastEquipTime > 0.3 then
        local backpackTool = LocalPlayer.Backpack:FindFirstChild(weaponName)
        if backpackTool and character.Humanoid.Health > 0 then
            lastEquipTime = os.clock()
            character.Humanoid:EquipTool(backpackTool)
            return weaponName
        end
    end
    return nil
end

local attackThread = nil
function CombatSystem.startAttackLoop()
    if attackThread then return end
    attackThread = task.spawn(function()
        while g.Autofarm or g.AutoFarmItem or g.AutoCraft or g.AutoFarmBoss or g.AutoDungeon do
            if TargetMob and TargetMob:FindFirstChildOfClass("Humanoid") and TargetMob.Humanoid.Health > 0 then
                pcall(function()
                    local weapon = CombatSystem.equipAndGetWeapon()
                    if weapon then ActionRemote:FireServer(weapon, "hit") end
                end)
            else
                TargetMob = nil
            end
            task.wait(0.02)
        end
        attackThread = nil
    end)
end

task.spawn(function()
    while true do
        if g.AutoSkillMaster or g.Autofarm or g.AutoFarmItem or g.AutoCraft or g.AutoFarmBoss or g.AutoDungeon then
            local weapon = CombatSystem.equipAndGetWeapon()
            if weapon and weapon ~= "None" and weapon ~= "" then
                pcall(function()
                    if g.AutoSkillZ then ActionRemote:FireServer(weapon, "z") end
                    if g.AutoSkillX then ActionRemote:FireServer(weapon, "x") end
                    if g.AutoSkillC then ActionRemote:FireServer(weapon, "c") end
                    if g.AutoSkillV then ActionRemote:FireServer(weapon, "v") end
                end)
            end
        end
        task.wait(0.01)
    end
end)

local CraftingSystem = {}

function CraftingSystem.getCurrentCraftTarget(itemName)
    if Utils.checkOwnedItem(itemName) then return nil end
    
    if Utils.isWeapon(itemName) and Utils.getItemAmount(itemName) >= 1 then
        return nil
    end
    
    local recipeData = CraftDatabase[itemName]
    if not recipeData then return nil end

    local mats = recipeData.Materials
    if not mats then return nil end

    for mat, needed in pairs(mats) do
        if mat ~= "Beli" and CraftDatabase[mat] then
            if Utils.isWeapon(mat) and Utils.checkOwnedItem(mat) then
            else
                local subAction, subTarget, subAmt = CraftingSystem.getCurrentCraftTarget(mat)
                if subAction then return subAction, subTarget, subAmt end
            end
        end
    end

    for mat, needed in pairs(mats) do
        if mat ~= "Beli" and not CraftDatabase[mat] then
            local currentAmt = Utils.getItemAmount(mat)
            if currentAmt < needed then return "farm", mat, needed end
        end
    end

    local beliNeeded = mats["Beli"] or 0
    if Utils.getBeliAmount() < beliNeeded then return "beli", "Beli", beliNeeded end

    return "craft", itemName, 1
end

function CraftingSystem.executeCraftingCheck()
    if not g.AutoCraft or g.SelectedCraftItem == "None" then
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = "None"
        return
    end

    if Utils.checkOwnedItem(g.SelectedCraftItem) then
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = "None"
        return
    end

    local actionType, targetName, amountNeeded = CraftingSystem.getCurrentCraftTarget(g.SelectedCraftItem)
    if not actionType then
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = "None"
        return
    end

    if actionType == "beli" then
        g.FarmingBeliForCraft = true
        g.CraftFarmItem = "None"
    elseif actionType == "farm" then
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = targetName
        g.CraftFarmLimit = amountNeeded
    elseif actionType == "craft" then
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = "None"
        TargetMob = nil
        local itemType = (ReplicatedStorage:WaitForChild("Weapon"):FindFirstChild("Sword") and ReplicatedStorage.Weapon.Sword:FindFirstChild(targetName)) and "Sword" or "Melee"
        NetworkEvent:FireServer("fire", nil, "Craft", targetName, itemType)
        task.wait(0.8)
    end
end

function CraftingSystem.updateDashboardUI()
    for _, child in ipairs(DashScroll:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
    end

    if g.SelectedCraftItem == "None" or Utils.checkOwnedItem(g.SelectedCraftItem) then
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 50)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = g.SelectedCraftItem == "None" and "Please Select Item to Craft" or "Item Already Crafted!"
        lbl.TextColor3 = Color3.fromRGB(150, 155, 170)
        lbl.TextSize = 13
        lbl.Parent = DashScroll
        DashScroll.CanvasSize = UDim2.new(0, 0, 0, 50)
        return
    end

    local recipeData = CraftDatabase[g.SelectedCraftItem]
    if not recipeData or not recipeData.Materials then return end

    local totalHeight = 0
    for matName, neededAmt in pairs(recipeData.Materials) do
        local currentAmt = (matName == "Beli") and Utils.getBeliAmount() or Utils.getItemAmount(matName)
        local missingAmt = math.max(0, neededAmt - currentAmt)

        local itemFrame = Instance.new("Frame")
        itemFrame.Size = UDim2.new(1, -4, 0, 36)
        itemFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
        itemFrame.BorderSizePixel = 0
        Instance.new("UICorner", itemFrame).CornerRadius = UDim.new(0, 6)
        local cardStroke = Instance.new("UIStroke", itemFrame)
        cardStroke.Thickness = 1

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -15, 1, 0)
        lbl.Position = UDim2.new(0, 10, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamSemibold
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = itemFrame

        local currentStr = Utils.formatNumber(currentAmt)
        local neededStr = Utils.formatNumber(neededAmt)

        if missingAmt == 0 then
            lbl.Text = matName .. " (" .. currentStr .. "/" .. neededStr .. ")"
            lbl.TextColor3 = Color3.fromRGB(80, 240, 120)
            cardStroke.Color = Color3.fromRGB(40, 100, 60)
        else
            lbl.Text = matName .. " (" .. currentStr .. "/" .. neededStr .. ")"
            lbl.TextColor3 = Color3.fromRGB(255, 110, 110)
            cardStroke.Color = Color3.fromRGB(110, 45, 45)
        end
        itemFrame.Parent = DashScroll
        totalHeight = totalHeight + 42
    end
    DashScroll.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local craftThread = nil
function CraftingSystem.startCraftLoop()
    if craftThread then return end
    craftThread = task.spawn(function()
        while g.AutoCraft do
            pcall(CraftingSystem.executeCraftingCheck)
            task.wait(0.2)
        end
        g.FarmingBeliForCraft = false
        g.CraftFarmItem = "None"
        craftThread = nil
    end)
end

local dashboardThread = nil
function CraftingSystem.startDashboardLoop()
    if dashboardThread then return end
    dashboardThread = task.spawn(function()
        while g.ShowDashboard do
            pcall(CraftingSystem.updateDashboardUI)
            task.wait(1)
        end
        dashboardThread = nil
    end)
end

local FarmSystem = {}

function FarmSystem.determineFarmTarget()
    local Mon, Npc, tierIndex = nil, nil, nil

    if g.AutoFarmBoss and g.SelectedBoss ~= "None" then
        Mon = g.SelectedBoss
        tierIndex = "Boss_" .. g.SelectedBoss
    end

    if not Mon and g.AutoCraft and g.SelectedCraftItem ~= "None" then
        if g.FarmingBeliForCraft then
            Mon, Npc, _ = Utils.getMon()
            tierIndex = "Beli_Farm_Level"
        elseif g.CraftFarmItem ~= "None" then
            local monName, npcName = Utils.findMobByItem(g.CraftFarmItem)
            if monName then Mon = monName Npc = npcName tierIndex = "CraftItem_" .. g.CraftFarmItem end
        end
    end

    if not Mon and g.AutoFarmItem and g.SelectedFarmItem ~= "None" then
        if Utils.getItemAmount(g.SelectedFarmItem) < g.ItemFarmLimit then
            local monName, npcName = Utils.findMobByItem(g.SelectedFarmItem)
            if monName then Mon = monName Npc = npcName tierIndex = "ManualItem_" .. g.SelectedFarmItem end
        end
    end

    if not Mon and g.Autofarm then
        Mon, Npc, _ = Utils.getMon()
        tierIndex = "Level_Farm"
    end

    return Mon, Npc, tierIndex
end

local function getAllAliveMobs(monsterName, folder)
    local mobs = {}
    for _, mob in ipairs(folder:GetChildren()) do
        if mob.Name == monsterName and mob:FindFirstChildOfClass("Humanoid") and mob:FindFirstChild("HumanoidRootPart") then
            local humanoid = mob.Humanoid
            if humanoid.Health > 0 and mob.HumanoidRootPart.Position.Y > -500 then
                table.insert(mobs, {
                    mob = mob,
                    health = humanoid.Health
                })
            end
        end
    end
    table.sort(mobs, function(a, b) return a.health > b.health end)
    return mobs
end

function FarmSystem.executeFarmingCycle()
    local Mon, Npc, tierIndex = FarmSystem.determineFarmTarget()
    if not Mon or Mon == "" then TargetMob = nil return end

    pcall(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
            TargetMob = nil 
            return 
        end

        local FolderMon = (tierIndex and tierIndex:find("Boss_")) and (workspace:FindFirstChild("Boss") or workspace) or (workspace:FindFirstChild("Mob") or workspace)
        local questFrame = LocalPlayer.PlayerGui.HUD.Main:FindFirstChild("Frame_Quest")

        if questFrame and questFrame.Visible and questFrame:FindFirstChild("Title") then
            local questTitle = questFrame.Title.Text
            if not string.find(questTitle, Mon) then
                g.TransitionUntil = os.clock() + 0.5
                TargetMob = nil
                NetworkEvent:FireServer("fire", nil, "Quest", "Cancel")
                questFrame.Visible = false
                task.wait(0.3)
            end
        end

        if currentTier ~= tierIndex then
            g.TransitionUntil = os.clock() + 0.3
            TargetMob = nil
            lastMobTime = 0 
            if questFrame and questFrame.Visible then
                NetworkEvent:FireServer("fire", nil, "Quest", "Cancel")
                questFrame.Visible = false
            end
            task.wait(0.3)
            currentTier = tierIndex
        end

        local hasQuest = questFrame and questFrame.Visible or false
        local npc = Npc and Utils.getNpcObject(Npc)
        local shouldAcceptQuest = (tierIndex == "Level_Farm" or tierIndex == "Beli_Farm_Level")

        if shouldAcceptQuest and npc and npc:FindFirstChild("HumanoidRootPart") then
            if hasQuest and questFrame and questFrame:FindFirstChild("Title") then
                if not string.find(questFrame.Title.Text, Mon) then
                    NetworkEvent:FireServer("fire", nil, "Quest", "Cancel")
                    questFrame.Visible = false
                    task.wait(0.3)
                    hasQuest = false
                end
            end
            
            if not hasQuest then
                g.TransitionUntil = os.clock() + 1.0
                TargetMob = nil
                character.Humanoid.PlatformStand = true
                character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                character.HumanoidRootPart.CFrame = npc.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                task.wait(0.3)

                if fireproximityprompt then
                    for _, v in ipairs(npc:GetDescendants()) do 
                        if v:IsA("ProximityPrompt") then 
                            fireproximityprompt(v) 
                            task.wait(0.05) 
                        end 
                    end
                end
                task.wait(0.3)

                for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
                    if v:IsA("TextButton") and v.Visible then
                        local name, text = v.Name:lower(), v.Text:lower()
                        if name:find("accept") or name:find("quest") or text:find("accept") or text:find("รับ") then
                            Utils.realHoldButton(v)
                            task.wait(0.2)
                            break
                        end
                    end
                end
                return
            end
        end

        local mobs = getAllAliveMobs(Mon, FolderMon)
        
        if #mobs == 0 then
            TargetMob = nil
            lastMobTime = os.clock()
            return
        end
        
        TargetMob = mobs[1].mob
    end)
end

function FarmSystem.executeDungeonCycle()
    if not g.AutoDungeon then 
        TargetMob = nil 
        return 
    end

    pcall(function()
        local character = LocalPlayer.Character
        if not character or not character:FindFirstChild("Humanoid") or character.Humanoid.Health <= 0 then 
            TargetMob = nil 
            return 
        end

        if TargetMob and (not TargetMob.Parent or not TargetMob:FindFirstChild("Humanoid") or TargetMob.Humanoid.Health <= 0) then
            TargetMob = nil
        end

        if not TargetMob then
            local closestMob = nil
            local minDistance = math.huge
            local folder = workspace:FindFirstChild("Mob") or workspace

            for _, mob in ipairs(folder:GetChildren()) do
                if mob:IsA("Model") and mob:FindFirstChildOfClass("Humanoid") and mob.Humanoid.Health > 0 and mob:FindFirstChild("HumanoidRootPart") then
                    if mob.HumanoidRootPart.Position.Y > -500 then
                        local dist = (character.HumanoidRootPart.Position - mob.HumanoidRootPart.Position).Magnitude
                        if dist < minDistance then
                            minDistance = dist
                            closestMob = mob
                        end
                    end
                end
            end
            TargetMob = closestMob
        end
    end)
end

local farmThread = nil
function FarmSystem.startMainFarmLoop()
    if farmThread then return end
    farmThread = task.spawn(function()
        while true do
            local isEnabled = g.Autofarm or g.AutoFarmItem or g.AutoCraft or g.AutoFarmBoss or g.AutoDungeon
            if not isEnabled then break end

            if g.AutoDungeon and game.PlaceId == 82878101790702 then
                pcall(function() FarmSystem.executeDungeonCycle() end)
            else
                pcall(function() FarmSystem.executeFarmingCycle() end)
            end
            task.wait(0.1)
        end
        TargetMob = nil
        currentTier = nil
        farmThread = nil
    end)
end

local MiscSystem = {}

function MiscSystem.startSummonLoop()
    local summonThread = nil
    if summonThread then return end
    summonThread = task.spawn(function()
        while g.AutoSummonBoss do
            if g.SelectedSummonBoss ~= "None" then
                local bossFolder = workspace:FindFirstChild("Boss")
                local bossExists = false
                if bossFolder and bossFolder:FindFirstChild(g.SelectedSummonBoss) then
                    local b = bossFolder[g.SelectedSummonBoss]
                    if b:FindFirstChildOfClass("Humanoid") and b.Humanoid.Health > 0 then 
                        bossExists = true 
                    end
                end
                if not bossExists then
                    NetworkEvent:FireServer("fire", nil, "SummonBoss", g.SelectedSummonBoss)
                    task.wait(3)
                end
            end
            task.wait(0.5)
        end
        summonThread = nil
    end)
end

function MiscSystem.startRebirthLoop()
    local rebirthThread = nil
    if rebirthThread then return end
    rebirthThread = task.spawn(function()
        while g.AutoRebirth do
            pcall(function()
                if Utils.Level() >= levelmax then
                    local questFrame = LocalPlayer.PlayerGui.HUD.Main:FindFirstChild("Frame_Quest")
                    if questFrame and questFrame.Visible then
                        NetworkEvent:FireServer("fire", nil, "Quest", "Cancel")
                        questFrame.Visible = false
                        task.wait(0.5)
                    end
                    
                    NetworkEvent:FireServer("fire", nil, "Rebirth")
                    task.wait(1)
                end
            end)
            task.wait(0.5)
        end
        rebirthThread = nil
    end)
end

RunService.Heartbeat:Connect(function()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChildOfClass("Humanoid") then return end

    if character.HumanoidRootPart.Position.Y < -500 or character.HumanoidRootPart.Position.Y > 10000 then
        TargetMob = nil
        character.Humanoid.PlatformStand = false
        character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0) 
        return
    end

    if g.TransitionUntil and os.clock() < g.TransitionUntil then
        character.Humanoid.PlatformStand = true
        character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
        character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
        return
    end

    local isFarming = g.Autofarm or g.AutoFarmItem or g.AutoCraft or g.AutoFarmBoss or g.AutoDungeon

    if isFarming then
        if character.Humanoid.Health > 0 then
            if TargetMob and TargetMob:FindFirstChild("HumanoidRootPart") and TargetMob:FindFirstChildOfClass("Humanoid") and TargetMob.Humanoid.Health > 0 then
                if TargetMob.HumanoidRootPart.Position.Y < -500 then 
                    TargetMob = nil 
                    return 
                end

                lastMobTime = os.clock()
                character.Humanoid.PlatformStand = true
                character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

                local offset = Vector3.new(0, g.FarmDistance, 0)
                if g.FarmPosition == "Below" then 
                    offset = Vector3.new(0, -g.FarmDistance, 0)
                elseif g.FarmPosition == "Behind" then 
                    offset = TargetMob.HumanoidRootPart.CFrame.LookVector * -g.FarmDistance 
                end

                character.HumanoidRootPart.CFrame = CFrame.lookAt(TargetMob.HumanoidRootPart.Position + offset, TargetMob.HumanoidRootPart.Position)
                workspace.CurrentCamera.CameraSubject = TargetMob.Humanoid
                return
            else
                if g.AutoDungeon and game.PlaceId == 82878101790702 then
                    character.Humanoid.PlatformStand = true
                    character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero
                    if workspace.CurrentCamera.CameraSubject ~= character.Humanoid then 
                        workspace.CurrentCamera.CameraSubject = character.Humanoid 
                    end
                    return
                end

                local Mon, Npc, tierIndex = FarmSystem.determineFarmTarget()
                if Mon and Npc then
                    character.Humanoid.PlatformStand = true
                    character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.zero
                    character.HumanoidRootPart.AssemblyAngularVelocity = Vector3.zero

                    if os.clock() - lastMobTime < spawnDelayThreshold then
                        if workspace.CurrentCamera.CameraSubject ~= character.Humanoid then 
                            workspace.CurrentCamera.CameraSubject = character.Humanoid 
                        end
                        return
                    end

                    local npcObj = Utils.getNpcObject(Npc)
                    if npcObj and npcObj:FindFirstChild("HumanoidRootPart") then
                        local hasQuest = false
                        pcall(function() hasQuest = LocalPlayer.PlayerGui.HUD.Main.Frame_Quest.Visible end)
                        local shouldAcceptQuest = (tierIndex == "Level_Farm" or tierIndex == "Beli_Farm_Level")

                        if (shouldAcceptQuest and not hasQuest) or (tierIndex and (tierIndex:find("CraftItem_") or tierIndex:find("ManualItem_"))) then
                            local aboveNpcPos = npcObj.HumanoidRootPart.Position + Vector3.new(0, 15, 0)
                            character.HumanoidRootPart.CFrame = CFrame.new(aboveNpcPos) * CFrame.Angles(0, math.rad(180), 0)
                        end
                    end
                else
                    if character.Humanoid.PlatformStand then 
                        character.Humanoid.PlatformStand = false 
                    end
                    if workspace.CurrentCamera.CameraSubject ~= character.Humanoid then 
                        workspace.CurrentCamera.CameraSubject = character.Humanoid 
                    end
                end
                if workspace.CurrentCamera.CameraSubject ~= character.Humanoid then 
                    workspace.CurrentCamera.CameraSubject = character.Humanoid 
                end
                return
            end
        end
    end

    pcall(function()
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            if LocalPlayer.Character.Humanoid.PlatformStand then 
                LocalPlayer.Character.Humanoid.PlatformStand = false 
            end
            if workspace.CurrentCamera.CameraSubject ~= LocalPlayer.Character.Humanoid then 
                workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid 
            end
        end
    end)
end)

task.spawn(function()
    while true do
        if g.AutoMoonDungeon then
            if not Utils.hasSpaceTicket() then
                pcall(function()
                    NetworkEvent:FireServer("fire", nil, "RandomItem", "x15")
                end)
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    while true do
        if g.AutoMoonDungeon then
            if game.PlaceId ~= 82878101790702 then
                if Utils.hasSpaceTicket() then
                    enterMoonDungeon()
                end
                task.wait(1)
            else
                task.wait(2)
            end
        end
        task.wait(0.5)
    end
end)

if game.PlaceId == 119091355492870 then
    local Tab1 = Window:CreateTab("Main")
    local Tab2 = Window:CreateTab("Skills")
    local Tab3 = Window:CreateTab("Items & Craft")
    local Tab4 = Window:CreateTab("Stats")
    local Tab5 = Window:CreateTab("Settings")

    Tab1:AddSection("Level Farming")
    Tab1:AddToggle("Auto Farm Level", "Autofarm", false, function(v)
        g.Autofarm = v
        if v then
            FarmSystem.startMainFarmLoop()
            CombatSystem.startAttackLoop()
        end
    end)

    Tab1:AddSection("Rebirth")
    Tab1:AddToggle("Auto Rebirth", "AutoRebirth", false, function(v)
        g.AutoRebirth = v
        if v then MiscSystem.startRebirthLoop() end
    end)

    local WeaponDropdown = Tab1:Dropdown("Select Weapon", "Weapon", Utils.getAvailableWeapons(), "None", false, function(v) 
        g.SelectedWeapon = v
    end)

    local function AutoRefreshWeapon() 
        if WeaponDropdown and WeaponDropdown.Refresh then 
            pcall(function() 
                WeaponDropdown:Refresh(Utils.getAvailableWeapons()) 
            end) 
        end 
    end

    LocalPlayer.Backpack.ChildAdded:Connect(AutoRefreshWeapon) 
    LocalPlayer.Backpack.ChildRemoved:Connect(AutoRefreshWeapon)
    LocalPlayer.CharacterAdded:Connect(function(char) 
        char.ChildAdded:Connect(AutoRefreshWeapon) 
        char.ChildRemoved:Connect(AutoRefreshWeapon) 
    end)

    Tab1:AddSection("Farming Method Settings")
    Tab1:Dropdown("Farm Position", "FarmPosition", {"Above", "Below", "Behind"}, "Above", false, function(v) 
        g.FarmPosition = v
    end)
    Tab1:AddSlider("Farm Distance (Studs)", "FarmDistance", 1, 30, 6, function(v) 
        g.FarmDistance = tonumber(v) or 6
    end)

    Tab1:AddSection("Boss Farm")
    Tab1:Dropdown("Select Boss to Summon", "SummonBoss", {"GooGooGaaGaa", "Dark Bacon"}, "GooGooGaaGaa", false, function(v) 
        g.SelectedSummonBoss = v
    end)
    Tab1:AddToggle("Auto Summon", "AutoSummonBoss", false, function(v)
        g.AutoSummonBoss = v
        if v then MiscSystem.startSummonLoop() end
    end)
    Tab1:Dropdown("Select Boss Farm", "Dropdown_FarmBoss", {"None", "GooGooGaaGaa", "Dark Bacon"}, "None", false, function(v) 
        g.SelectedBoss = v
    end)
    Tab1:AddToggle("Auto Farm Boss", "AutoFarm2", false, function(v)
        g.AutoFarmBoss = v
        if v then
            FarmSystem.startMainFarmLoop()
            CombatSystem.startAttackLoop()
        else
            TargetMob = nil
        end
    end)

    Tab1:AddSection("Dungeon")
    Tab1:AddToggle("Auto Moon Dungeon", "DungeonPortal", false, function(v)
        g.AutoMoonDungeon = v
    end)

    Tab2:AddSection("Skills")
    Tab2:AddToggle("Default Auto Skill", "Skill", false, function(v) 
        g.AutoSkillMaster = v
    end)
    Tab2:AddToggle("Z", "SkillZ", false, function(v) 
        g.AutoSkillZ = v
    end)
    Tab2:AddToggle("X", "SkillX", false, function(v) 
        g.AutoSkillX = v
    end)
    Tab2:AddToggle("C", "SkillC", false, function(v) 
        g.AutoSkillC = v
    end)
    Tab2:AddToggle("V", "SkillV", false, function(v) 
        g.AutoSkillV = v
    end)

    Tab3:AddSection("Gacha")
    Tab3:Dropdown("Select Chest Amount", "ChestAmount", {"x5", "x10", "x15"}, "x15", false, function(v) 
        g.ChestAmount = v
    end)
    Tab3:AddToggle("Auto Open Chest", "AutoChest", false, function(v)
        g.AutoChest = v
        if v then
            if chestThread then return end
            local chestThread = task.spawn(function()
                while g.AutoChest do
                    pcall(function()
                        if g.AutoMoonDungeon and Utils.hasSpaceTicket() then
                            return
                        end
                        NetworkEvent:FireServer("fire", nil, "RandomItem", g.ChestAmount)
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end)

    Tab3:AddSection("Special Chest (Event Moon)")
    
    Tab3:AddButton("Open x5 (25 Event Stone)", function()
        openSpecialChest("x5")
    end)
    Tab3:AddButton("Open x10 (50 Event Stone)", function()
        openSpecialChest("x10")
    end)
    Tab3:AddButton("Open x15 (75 Event Stone)", function()
        openSpecialChest("x15")
    end)
    
    Tab3:AddToggle("Auto Open Special Chest", "AutoSpecialChest", false, function(v)
        g.AutoSpecialChest = v
        if v then
            if specialChestThread then return end
            specialChestThread = task.spawn(function()
                while g.AutoSpecialChest do
                    pcall(function()
                        local eventStone = getEventStoneAmount()
                        local chestType = g.ChestAmount or "x15"
                        local cost = 0
                        if chestType == "x5" then cost = 25
                        elseif chestType == "x10" then cost = 50
                        elseif chestType == "x15" then cost = 75
                        end
                        
                        if eventStone >= cost then
                            NetworkEvent:FireServer("fire", nil, "EventMoon", chestType)
                            task.wait(0.3)
                        else
                            task.wait(5)
                        end
                    end)
                    task.wait(0.2)
                end
            end)
        end
    end)

    Tab3:AddSection("Item Farm")
    local farmItemList = {"None"}
    for _, data in pairs(ItemDatabase) do 
        for _, itemName in ipairs(data.Items) do 
            if not table.find(farmItemList, itemName) then 
                table.insert(farmItemList, itemName) 
            end 
        end 
    end
    Tab3:Dropdown("Select Item to Farm", "ItemFarm", farmItemList, "None", false, function(v) 
        g.SelectedFarmItem = v
    end)
    Tab3:AddSlider("Farming Item Limit", "ItemLimit", 1, 10000, 10, function(v) 
        g.ItemFarmLimit = tonumber(v) or 10
    end)
    Tab3:AddToggle("Auto Farm Item", "AutoFarmItem", false, function(v)
        g.AutoFarmItem = v
        if v then
            FarmSystem.startMainFarmLoop()
            CombatSystem.startAttackLoop()
        else
            TargetMob = nil
        end
    end)

    Tab3:AddSection("Craft")
    local craftList = {"None"}
    for itemName, _ in pairs(CraftDatabase) do 
        table.insert(craftList, itemName) 
    end
    Tab3:Dropdown("Select Item to Craft", "CraftItem", craftList, "None", false, function(v) 
        g.SelectedCraftItem = v
    end)
    Tab3:AddToggle("Auto Craft Item", "AutoCraft", false, function(v)
        g.AutoCraft = v
        if v then
            CraftingSystem.startCraftLoop()
            FarmSystem.startMainFarmLoop()
            CombatSystem.startAttackLoop()
        else
            g.FarmingBeliForCraft = false
            g.CraftFarmItem = "None"
            TargetMob = nil
        end
    end)
    Tab3:AddToggle("Craft Dashboard", "DashboardFrameShow", false, function(v)
        g.ShowDashboard = v
        DashGui.Enabled = v
        if v then CraftingSystem.startDashboardLoop() end
    end)

    Tab4:AddSection("Status")
    Tab4:Dropdown("Select Status", "Stats", {"Melee", "Defense", "Sword", "Power"}, {"Melee"}, true, function(v) 
        g.SelectedStat = v
    end)
    Tab4:AddSlider("Upgrade Amount (Slider)", "StatAmount", 1, 10000, 1, function(v) 
        g.StatAmount = tonumber(v) or 1
    end)
    Tab4:AddToggle("Auto Up Stats", "AutoStats", false, function(v)
        g.AutoStats = v
        if v then
            if statsThread then return end
            local currentStatIndex = 1
            local statsThread = task.spawn(function()
                while g.AutoStats do
                    pcall(function()
                        local enabledStats = {}
                        if type(g.SelectedStat) == "table" then
                            for k, val in pairs(g.SelectedStat) do 
                                if val == true then table.insert(enabledStats, k) 
                                elseif type(val) == "string" and val ~= "" then table.insert(enabledStats, val) end 
                            end
                        elseif type(g.SelectedStat) == "string" and g.SelectedStat ~= "" then 
                            table.insert(enabledStats, g.SelectedStat) 
                        end
                        if #enabledStats > 0 then
                            if currentStatIndex > #enabledStats then currentStatIndex = 1 end
                            SystemRemote:FireServer("UpStats", enabledStats[currentStatIndex], g.StatAmount)
                            currentStatIndex = currentStatIndex + 1
                        end
                    end)
                    task.wait(0.05)
                end
            end)
        end
    end)
    Tab4:AddButton("Reset Status", function() 
        pcall(function() 
            SystemRemote:FireServer("ResetStats") 
        end) 
    end)

    Tab5:AddSection("Ui Fixes")
    Tab5:AddToggle("FixUi", "Fixui", false, function(v)
        if Window and Window.Save then 
            Window.Save.Fixbug = v 
        end
    end)

elseif game.PlaceId == 82878101790702 then
    local Tab1 = Window:CreateTab("Main")
    local Tab2 = Window:CreateTab("Skills")

    Tab1:AddSection("Auto Dungeon")
    Tab1:AddToggle("Auto Mon", "DungeonMon", false, function(v)
        g.AutoDungeon = v
        if v then
            FarmSystem.startMainFarmLoop()
            CombatSystem.startAttackLoop()
        else
            TargetMob = nil
            pcall(function()
                if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                    LocalPlayer.Character.Humanoid.PlatformStand = false
                end
            end)
        end
    end)

    Tab1:AddSection("Setting")
    local WeaponDropdown = Tab1:Dropdown("Select Weapon", "Weapon", Utils.getAvailableWeapons(), "None", false, function(v) 
        g.SelectedWeapon = v
    end)

    local function AutoRefreshWeapon() 
        if WeaponDropdown and WeaponDropdown.Refresh then 
            pcall(function() 
                WeaponDropdown:Refresh(Utils.getAvailableWeapons()) 
            end) 
        end 
    end

    LocalPlayer.Backpack.ChildAdded:Connect(AutoRefreshWeapon) 
    LocalPlayer.Backpack.ChildRemoved:Connect(AutoRefreshWeapon)
    LocalPlayer.CharacterAdded:Connect(function(char) 
        char.ChildAdded:Connect(AutoRefreshWeapon) 
        char.ChildRemoved:Connect(AutoRefreshWeapon) 
    end)

    Tab1:Dropdown("Farm Position", "FarmPosition", {"Above", "Below", "Behind"}, "Above", false, function(v) 
        g.FarmPosition = v
    end)
    Tab1:AddSlider("Farm Distance (Studs)", "FarmDistance", 1, 30, 6, function(v) 
        g.FarmDistance = tonumber(v) or 6
    end)

    Tab2:AddSection("Skills")
    Tab2:AddToggle("Default Auto Skill", "MasterSkill", false, function(v) 
        g.AutoSkillMaster = v
    end)
    Tab2:AddToggle("Z", "SkillZ", false, function(v) 
        g.AutoSkillZ = v
    end)
    Tab2:AddToggle("X", "SkillX", false, function(v) 
        g.AutoSkillX = v
    end)
    Tab2:AddToggle("C", "SkillC", false, function(v) 
        g.AutoSkillC = v
    end)
    Tab2:AddToggle("V", "SkillV", false, function(v) 
        g.AutoSkillV = v
    end)
else
    print("? What")
end
