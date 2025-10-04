local player = game.Players.LocalPlayer
local GUI = player.PlayerGui

local bola = Instance.new("ScreenGui")

bola.Name = "Bola"
bola.IgnoreGuiInset = true
bola.ResetOnSpawn = false
bola.Parent = GUI

local frame = Instance.new("Frame")
frame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
frame.Position = UDim2.new(0.5, 0, 0, 0)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Size = UDim2.new(0, 125, 0, 25)
frame.Parent = bola

local UICorner = Instance.new("UICorner")

UICorner.CornerRadius = UDim.new(1,0)
UICorner.Parent = frame

local separation = Instance.new("Frame")

separation.Position = UDim2.new(0, 29, 0 , 0)
separation.Size = UDim2.new(0,1,0,25)
separation.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
separation.BorderSizePixel = 0
separation.Parent = frame

local Move = Instance.new("ImageButton")

Move.Name = "Move"
Move.Image = "rbxassetid://114710650893836"
Move.Position = UDim2.new(0, 2, 0, 0)
Move.Size = UDim2.new(0, 25, 0, 25)
Move.BackgroundTransparency = 1
Move.Parent = frame

local Enter = Instance.new("TextButton")
Enter.Name = "Enter"
Enter.Text = "FWare"
Enter.Position = UDim2.new(0, 29, 0, 0)
Enter.Size = UDim2.new(0, 95, 0, 25)
Enter.BackgroundTransparency = 1
Enter.TextSize = 23
Enter.TextStrokeTransparency = 1
Enter.TextColor3 = Color3.fromRGB(255, 255, 255)
Enter.TextScaled = false
Enter.Font = Enum.Font.SourceSans
Enter.Parent = frame

local button = Move
local framePrincipal = frame
local screen = bola

local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragStart
local startPos

button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = framePrincipal.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

button.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		if dragging then
			local delta = input.Position - dragStart
			framePrincipal.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end
end)

Enter.MouseButton1Click:Connect(function()
	game.Players.LocalPlayer.PlayerGui.FWare.Enabled = true
	game.Players.LocalPlayer.PlayerGui.Bola.Enabled = false
end)

local FWare = Instance.new("ScreenGui")

FWare.Name = "FWare"
FWare.IgnoreGuiInset = false
FWare.Enabled = false
FWare.Parent = GUI

local SFrame = Instance.new("ScrollingFrame")

SFrame.BackgroundColor3 = Color3.fromRGB(66, 66, 66)
SFrame.Position = UDim2.new(0, 10, 0, 10)
SFrame.Size = UDim2.new(1, -20, 1, -20)
SFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SFrame.BorderSizePixel = 0
SFrame.BackgroundTransparency = 0
SFrame.Parent = FWare

local UIListLayout = Instance.new("UIListLayout")

UIListLayout.Parent = SFrame

local Equis = Instance.new("ImageButton")

Equis.Image = "rbxassetid://98939136188247"
Equis.AnchorPoint = Vector2.new(1, 0)
Equis.Position = UDim2.new(1, -10, 0, 10)
Equis.Size = UDim2.new(0, 75, 0, 75)
Equis.BorderSizePixel = 0
Equis.BackgroundTransparency = 1
Equis.Parent = FWare

Equis.MouseButton1Click:Connect(function()
	GUI.Bola.Enabled = true
	GUI.FWare.Enabled = false
end)

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local HttpService = game:GetService("HttpService")

local function addMessage(text)
	local msg = Instance.new("TextLabel")
	msg.Size = UDim2.new(1, -10, 0, 30) -- ancho = frame, alto fijo
	msg.BackgroundTransparency = 0.5
	msg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	msg.TextColor3 = Color3.fromRGB(255, 255, 255)
	msg.Font = Enum.Font.SourceSans
	msg.TextSize = 20
	msg.TextXAlignment = Enum.TextXAlignment.Left
	msg.Text = text
	msg.Parent = GUI.FWare.ScrollingFrame
end

local function tableToString(t)
	local final = ""
	local isArray = true
	local ek = 1

	for k, v in pairs(t) do
		if type(k) ~= "number" or k ~= ek then
			isArray = false
			break
		end
		ek = ek + 1
	end

	final = isArray and "[" or "{"

	local first = true
	for k, v in pairs(t) do
		if not first then final = final .. ", " end
		first = false

		if type(v) == "number" then
			final = final .. k .. ": Number " .. v
		elseif type(v) == "string" then
			final = final .. k .. ": String " .. v
		elseif type(v) == "boolean" then
			final = final .. k .. ": Boolean " .. tostring(v)
		elseif type(v) == "table" then
			final = final .. k .. ": Table " .. tableToString(v)
		elseif typeof(v) == "Vector2" then
			final = final .. k .. ": Vector2, X: " .. v.X .. ", Y: " .. v.Y
		elseif typeof(v) == "Vector3" then
			final = final .. k .. ": Vector3, X: " .. v.X .. ", Y: " .. v.Y .. ", Z: " .. v.Z
		elseif typeof(v) == "Color3" then
			final = final .. k .. ": Color3, R: " .. v.R .. ", G: " .. v.G .. ", B: " .. v.B
		elseif typeof(v) == "UDim2" then
			final = final .. k .. ": UDim2, XScale: " .. v.X.Scale .. ", XOffset: " .. v.X.Offset .. ", YScale: " .. v.Y.Scale .. ", YOffset: " .. v.Y.Offset
		elseif typeof(v) == "Instance" then
			final = final .. k .. ": Instance " .. v.ClassName .. ", Not supported"
		else
			final = final .. k .. ": " .. typeof(v) .. ", Not supported"
		end
	end

	final = final .. (isArray and "]" or "}")
	return final
end

local hooks = {}

local function hookear(event, func)
	table.insert(hooks, {event, func})
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
	local method = getnamecallmethod()

	if method == "FireServer" and self:IsA("RemoteEvent") then
		
		local args = {...}
		
		task.spawn(function()
			for _, e in ipairs(hooks) do
				if e[1] == self then
					pcall(e[2], table.unpack(args))
				end
			end
		end)
		
		return oldNamecall(self, ...)
	end
	
	return oldNamecall(self, ...)
end)

local function react(e)
	if e:IsA("RemoteEvent") then
		e.OnClientEvent:Connect(function(...)
			addMessage("[RECIBIDO]: RemoteEvent " .. e.Name .. " Args: " .. tableToString({...}))
		end)
		hookear(e, function(...)
			addMessage("[ENVIADO]: RemoteEvent " .. e.Name .. " Args: " .. tableToString({...}))
		end)
	elseif e:IsA("BindableEvent") then
		e.Event:Connect(function(...)
			addMessage("[AUTOENVIADO]: BindableEvent " .. e.Name .. " Args: " .. tableToString({...}))
		end)
	end
end

for _, e in ipairs(game:GetDescendants()) do
	if e:IsA("RemoteEvent") or e:IsA("BindableEvent") then
		react(e)
	end
end

game.DescendantAdded:Connect(function(e)
	if e:IsA("RemoteEvent") or e:IsA("BindableEvent") then
		react(e)
	end
	
end)

local Bunkers = workspace:WaitForChild("Bunkers")

local function findChildWithBillboardGui()
	local all = {}
	for _, child in ipairs(Bunkers:GetChildren()) do
		local added = false
		for _, descendant in ipairs(child:GetDescendants()) do
			if descendant:IsA("BillboardGui") and not added then
				table.insert(all, child)
				added = true
			end
		end
	end
	return all
end


local result = findChildWithBillboardGui()
if result then
	print("Hijo encontrado:", #result)
else
	print("No se encontró ningún hijo con BillboardGui")
end
