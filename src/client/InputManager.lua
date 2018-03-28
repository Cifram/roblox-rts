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

	UserInputService.InputBegan:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			downPosition = input.Position
			local ray = workspace.Camera:ScreenPointToRay(input.Position.x, input.Position.y)
			ray = Ray.new(ray.Origin, ray.Direction * 1024)
			local parts = CollectionService:GetTagged("Unit")
			downPart = Workspace:FindPartOnRayWithWhitelist(ray, parts)
		end
	end)

	UserInputService.InputEnded:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 and downPart then
			local deltaPos = input.Position - downPosition
			if deltaPos.Magnitude < 1.0 then
				local ray = workspace.Camera:ScreenPointToRay(input.Position.x, input.Position.y)
				ray = Ray.new(ray.Origin, ray.Direction * 1024)
				local parts = Component:getInstancesWithComponent(Unit)
				local part = Workspace:FindPartOnRayWithWhitelist(ray, parts)
				if part == downPart then
					local unit = Component:getComponentOnInstance(part, Unit)
					unit:onClick()
				end
			end
		end
	end)
end

return InputManager