-- LocalScript

local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local workspace = game:GetService("Workspace")

-- Función recursiva para imprimir hijos
local function printChildren(parent, indent)
	indent = indent or ""  -- indentación inicial
	for _, child in ipairs(parent:GetChildren()) do
		print(indent .. child.Name .. " (" .. child.ClassName .. ")")
		-- Llamada recursiva para los hijos del hijo
		printChildren(child, indent .. "  ")
	end
end

print("=== Hijos de LocalPlayer ===")
printChildren(player)

print("=== Hijos de ReplicatedStorage ===")
printChildren(replicatedStorage)
