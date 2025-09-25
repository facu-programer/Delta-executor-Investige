-- Delta Executor / LocalScript

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

-- GUI básica
local gui = Instance.new("ScreenGui")
gui.Name = "EventDebugger"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 500, 0, 350)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.Parent = gui

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -10)
scrollFrame.Position = UDim2.new(0, 5, 0, 5)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 12
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollFrame

-- Función de log con color
local function log(text, color)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 20)
	label.BackgroundTransparency = 1
	label.TextColor3 = color or Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = text
	label.Parent = scrollFrame
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
end

-- Hook global para interceptar FireServer
local mt = getrawmetatable(game)
setreadonly(mt, false)

local oldIndex = mt.__index
mt.__index = newcclosure(function(self, key)
	local result = oldIndex(self, key)
	if key == "FireServer" and typeof(self) == "Instance" and self:IsA("RemoteEvent") then
		local oldFire = result
		result = newcclosure(function(remoteSelf, ...)
			local args = {...}
			local argStr = {}
			for i,v in ipairs(args) do argStr[i] = tostring(v) end
			log("[Enviado] " .. remoteSelf:GetFullName() .. " | Args: " .. table.concat(argStr, ", "), Color3.fromRGB(0,200,0))
			return oldFire(remoteSelf, ...)
		end)
	end
	return result
end)

setreadonly(mt, true)

-- Función para interceptar eventos ya existentes
local function hookExisting(remote)
	if remote:IsA("RemoteEvent") then
		-- OnClientEvent
		remote.OnClientEvent:Connect(function(...)
			local args = {...}
			local argStr = {}
			for i,v in ipairs(args) do argStr[i] = tostring(v) end
			log("[Recibido] " .. remote:GetFullName() .. " | Args: " .. table.concat(argStr, ", "), Color3.fromRGB(0,150,255))
		end)
	elseif remote:IsA("BindableEvent") then
		remote.Event:Connect(function(...)
			local args = {...}
			local argStr = {}
			for i,v in ipairs(args) do argStr[i] = tostring(v) end
			log("[BindableEvent] " .. remote:GetFullName() .. " | Args: " .. table.concat(argStr, ", "), Color3.fromRGB(255,200,0))
		end)
	end
end

-- Escanear lugares comunes
local function scan(parent)
	for _, child in ipairs(parent:GetChildren()) do
		hookExisting(child)
		scan(child)
	end
end

scan(workspace)
scan(replicatedStorage)
scan(player)

-- Monitorear futuros hijos
workspace.DescendantAdded:Connect(hookExisting)
replicatedStorage.DescendantAdded:Connect(hookExisting)
player.DescendantAdded:Connect(hookExisting)
