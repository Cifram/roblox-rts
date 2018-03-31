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

	local selectedUnits = {}
	local terrain = workspace.Terrain

	local function getClickables()
		local parts = Component:getInstancesWithComponent(Unit)
		parts[#parts+1] = terrain
		return parts
	end

	local function clickTerrain(position)
		for _, unit in pairs(selectedUnits) do
			unit:pathTo(position)
		end
	end

	local function clickUnit(unit)
		for _, curUnit in pairs(selectedUnits) do
			curUnit:deselect()
		end

		if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
			local selectedIndex = 0
			for index, testUnit in pairs(selectedUnits) do
				if testUnit == unit then
					selectedIndex = index
					break
				end
			end

			if selectedIndex ~= 0 then
				table.remove(selectedUnits, selectedIndex)
			else
				selectedUnits[#selectedUnits+1] = unit
			end
		else
			selectedUnits = { unit }
		end

		for _, curUnit in pairs(selectedUnits) do
			curUnit:select()
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