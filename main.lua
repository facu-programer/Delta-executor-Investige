-- Delta Executor / LocalScript
local player = game.Players.LocalPlayer

-- Esperar a que todo el juego esté cargado
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(1) -- asegurar que todos los objetos iniciales estén disponibles

-- ===== GUI =====
local gui = Instance.new("ScreenGui")
gui.Name = "EventDebugger"
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 250)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 2
frame.Parent = gui

-- Botón cerrar
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(1, -30, 0, 5)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
closeBtn.BackgroundColor3 = Color3.fromRGB(200,50,50)
closeBtn.Font = Enum.Font.SourceSansBold
closeBtn.TextSize = 18
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function() gui:Destroy() end)

-- ScrollingFrame con scroll vertical y horizontal
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -35)
scrollFrame.Position = UDim2.new(0,5,0,30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.ScrollBarThickness = 12
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.HorizontalScrollBarEnabled = true
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
uiListLayout.Parent = scrollFrame

-- Función de log
local function log(text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0,0,0,18)
    label.AutomaticSize = Enum.AutomaticSize.XY
    label.BackgroundTransparency = 1
    label.TextColor3 = color or Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Text = text
    label.Parent = scrollFrame
    scrollFrame.CanvasSize = UDim2.new(0, label.AbsoluteSize.X + 10, 0, uiListLayout.AbsoluteContentSize.Y)
end

-- ===== Arrastrable =====
local dragging, dragInput, mousePos, framePos = false, nil, nil, nil
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
frame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)
game:GetService("UserInputService").InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- ===== Hook global FireServer =====
local mt = getrawmetatable(game)
setreadonly(mt,false)
local oldNamecall = mt.__namecall

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if method == "FireServer" and self:IsA("RemoteEvent") then
        local args = {...}
        local str = {}
        for i,v in ipairs(args) do str[i] = tostring(v) end
        log("[Enviado] "..self:GetFullName().." | Args: "..table.concat(str,", "), Color3.fromRGB(0,200,0))
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt,true)

-- ===== Hook para RemoteEvents y BindableEvents =====
local function hookEvent(event)
    if event:IsA("RemoteEvent") then
        event.OnClientEvent:Connect(function(...)
            local args={...}
            local str={}
            for i,v in ipairs(args) do str[i]=tostring(v) end
            log("[Recibido] "..event:GetFullName().." | Args: "..table.concat(str,", "), Color3.fromRGB(0,150,255))
        end)
    elseif event:IsA("BindableEvent") then
        event.Event:Connect(function(...)
            local args={...}
            local str={}
            for i,v in ipairs(args) do str[i]=tostring(v) end
            log("[BindableEvent] "..event:GetFullName().." | Args: "..table.concat(str,", "), Color3.fromRGB(255,200,0))
        end)
    end
end

-- ===== Escaneo completo del juego =====
local function scan(parent)
    for _,c in ipairs(parent:GetChildren()) do
        hookEvent(c)
        scan(c)
    end
end

scan(game) -- escanear todos los eventos existentes
game.DescendantAdded:Connect(hookEvent) -- conectar futuros eventos
