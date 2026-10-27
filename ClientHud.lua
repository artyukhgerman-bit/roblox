local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Remotes"))
local WeaponCatalog = require(ReplicatedStorage.Shared.WeaponCatalog)

local player = Players.LocalPlayer
local remotes = Remotes.get()
local progress = {
	xp = 0,
	level = 1,
	owned = { "stick" },
	equipped = "stick",
	nextLevelXp = 80,
}

local gui = Instance.new("ScreenGui")
gui.Name = "MonsterForgeHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
end

local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.fromOffset(340, 148)
frame.Position = UDim2.new(0, 24, 1, -172)
frame.BackgroundColor3 = Color3.fromRGB(16, 12, 28)
frame.BackgroundTransparency = 0.18
frame.Parent = gui
corner(frame, 14)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(16, 10)
title.Size = UDim2.new(1, -32, 0, 28)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextColor3 = Color3.fromRGB(240, 230, 255)
title.Text = "Monster Forge"
title.Parent = frame

local weaponLabel = Instance.new("TextLabel")
weaponLabel.BackgroundTransparency = 1
weaponLabel.Position = UDim2.fromOffset(16, 40)
weaponLabel.Size = UDim2.new(1, -32, 0, 24)
weaponLabel.Font = Enum.Font.GothamMedium
weaponLabel.TextSize = 16
weaponLabel.TextXAlignment = Enum.TextXAlignment.Left
weaponLabel.TextColor3 = Color3.fromRGB(190, 170, 255)
weaponLabel.Text = "Меч: Деревянная палка"
weaponLabel.Parent = frame

local levelLabel = Instance.new("TextLabel")
levelLabel.BackgroundTransparency = 1
levelLabel.Position = UDim2.fromOffset(16, 66)
levelLabel.Size = UDim2.new(1, -32, 0, 22)
levelLabel.Font = Enum.Font.Gotham
levelLabel.TextSize = 15
levelLabel.TextXAlignment = Enum.TextXAlignment.Left
levelLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
levelLabel.Text = "Уровень 1"
levelLabel.Parent = frame

local hint = Instance.new("TextLabel")
hint.BackgroundTransparency = 1
hint.Position = UDim2.fromOffset(16, 110)
hint.Size = UDim2.new(1, -32, 0, 24)
hint.Font = Enum.Font.Gotham
hint.TextSize = 14
hint.TextXAlignment = Enum.TextXAlignment.Left
hint.TextColor3 = Color3.fromRGB(170, 160, 190)
hint.Text = "ЛКМ — удар  ·  E у дропа — взять меч"
hint.Parent = frame

local barBack = Instance.new("Frame")
barBack.Position = UDim2.fromOffset(16, 92)
barBack.Size = UDim2.new(1, -32, 0, 10)
barBack.BackgroundColor3 = Color3.fromRGB(40, 32, 60)
barBack.Parent = frame
corner(barBack, 6)

local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(0, 1)
barFill.BackgroundColor3 = Color3.fromRGB(170, 90, 255)
barFill.Parent = barBack
corner(barFill, 6)

local toast = Instance.new("TextLabel")
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0, 80)
toast.Size = UDim2.fromOffset(520, 40)
toast.BackgroundTransparency = 1
toast.Font = Enum.Font.GothamBold
toast.TextSize = 22
toast.TextColor3 = Color3.fromRGB(255, 220, 120)
toast.TextStrokeTransparency = 0.5
toast.Text = ""
toast.Parent = gui

local inventory = Instance.new("Frame")
inventory.Name = "Inventory"
inventory.AnchorPoint = Vector2.new(1, 1)
inventory.Position = UDim2.new(1, -24, 1, -24)
inventory.Size = UDim2.fromOffset(220, 280)
inventory.BackgroundColor3 = Color3.fromRGB(16, 12, 28)
inventory.BackgroundTransparency = 0.18
inventory.Parent = gui
corner(inventory, 14)

local invTitle = Instance.new("TextLabel")
invTitle.BackgroundTransparency = 1
invTitle.Position = UDim2.fromOffset(14, 10)
invTitle.Size = UDim2.new(1, -28, 0, 24)
invTitle.Font = Enum.Font.GothamBold
invTitle.TextSize = 16
invTitle.TextXAlignment = Enum.TextXAlignment.Left
invTitle.TextColor3 = Color3.fromRGB(240, 230, 255)
invTitle.Text = "Арсенал"
invTitle.Parent = inventory

local list = Instance.new("ScrollingFrame")
list.Position = UDim2.fromOffset(10, 40)
list.Size = UDim2.new(1, -20, 1, -50)
list.BackgroundTransparency = 1
list.BorderSizePixel = 0
list.ScrollBarThickness = 4
list.Parent = inventory

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.Parent = list

local function flash(text: string, color: Color3)
	toast.Text = text
	toast.TextColor3 = color
	toast.TextTransparency = 0
	TweenService:Create(toast, TweenInfo.new(1.6), { TextTransparency = 1 }):Play()
end

local function refreshHud()
	local weapon = WeaponCatalog.get(progress.equipped)
	weaponLabel.Text = string.format("%s  ·  %d урона", weapon.name, weapon.damage)
	levelLabel.Text = string.format("Уровень %d  ·  опыт %d / %d", progress.level, progress.xp, progress.nextLevelXp)
	local into = progress.xp - (progress.level - 1) * 80
	barFill.Size = UDim2.fromScale(math.clamp(into / 80, 0, 1), 1)

	for _, child in list:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, id in progress.owned do
		local def = WeaponCatalog.get(id)
		local button = Instance.new("TextButton")
		button.Size = UDim2.new(1, -4, 0, 36)
		button.BackgroundColor3 = if id == progress.equipped then Color3.fromRGB(88, 48, 140) else Color3.fromRGB(36, 28, 54)
		button.Text = string.format("%s  (%s)", def.name, def.rarity)
		button.Font = Enum.Font.GothamMedium
		button.TextSize = 13
		button.TextColor3 = Color3.fromRGB(235, 225, 255)
		button.AutoButtonColor = true
		button.Parent = list
		corner(button, 8)
		button.MouseButton1Click:Connect(function()
			remotes.Equip:FireServer(id)
		end)
	end
end

refreshHud()

remotes.Progress.OnClientEvent:Connect(function(payload)
	progress = payload
	refreshHud()
end)

remotes.CombatFx.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.kind == "loot" then
		flash("Дроп: " .. tostring(payload.name), Color3.fromRGB(255, 210, 90))
	elseif payload.kind == "kill" then
		flash(string.format("%s повержен  +%d XP", payload.name, payload.xp), Color3.fromRGB(160, 255, 140))
	elseif payload.kind == "hurt" then
		flash(string.format("-%d от %s", payload.amount, payload.from), Color3.fromRGB(255, 110, 110))
	elseif payload.kind == "hit" and typeof(payload.position) == "Vector3" then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.Shape = Enum.PartType.Ball
		part.Size = Vector3.new(0.6, 0.6, 0.6)
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255, 240, 140)
		part.CFrame = CFrame.new(payload.position)
		part.Parent = workspace
		TweenService:Create(part, TweenInfo.new(0.25), { Transparency = 1, Size = Vector3.new(2.4, 2.4, 2.4) }):Play()
		task.delay(0.3, function()
			part:Destroy()
		end)
	end
end)

local function tryAttack()
	remotes.Attack:FireServer()
	local character = player.Character
	local tool = character and character:FindFirstChildWhichIsA("Tool")
	if tool then
		local handle = tool:FindFirstChild("Handle")
		if handle and handle:IsA("BasePart") then
			local original = handle.CFrame
			handle.CFrame = original * CFrame.Angles(math.rad(-50), 0, 0)
			task.delay(0.12, function()
				if handle.Parent then
					handle.CFrame = original
				end
			end)
		end
	end
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		tryAttack()
	end
end)
