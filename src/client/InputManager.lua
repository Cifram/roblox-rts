local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)
local Unit = require(Shared.Unit)

local InputManager = {}
InputManager.__index = InputManager

function InputManager.new()
	local downPosition = nil
	local downPart = nil

	local selectedUnit = nil
	local terrain = workspace.Terrain

	local function getClickables()
		local parts = Component:getInstancesWithComponent(Unit)
		parts[#parts+1] = terrain
		return parts
	end

	local function clickTerrain(position)
		print("Terrain clicked", position)
	end

	local function clickUnit(unit)
		if unit == selectedUnit then
			selectedUnit = nil
			unit:deselect()
		else
			selectedUnit = unit
			unit:select()
		end
	end

	UserInputService.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			downPosition = input.Position
			local ray = workspace.Camera:ScreenPointToRay(input.Position.x, input.Position.y)
			ray = Ray.new(ray.Origin, ray.Direction * 1024)
			local parts = getClickables()
			downPart = Workspace:FindPartOnRayWithWhitelist(ray, parts)
		end
	end)

	UserInputService.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and downPart then
			local deltaPos = input.Position - downPosition
			if deltaPos.Magnitude < 1.0 then
				local ray = workspace.Camera:ScreenPointToRay(input.Position.x, input.Position.y)
				ray = Ray.new(ray.Origin, ray.Direction * 1024)
				local parts = getClickables()
				local part, position = Workspace:FindPartOnRayWithWhitelist(ray, parts)
				if part == downPart then
					if part == terrain then
						clickTerrain(position)
					else
						local unit = Component:getComponentOnInstance(part, Unit)
						clickUnit(unit)
					end
				end
			end
		end
	end)
end

return InputManager