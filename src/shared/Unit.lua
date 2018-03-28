local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)

local Unit = Component:extend("Unit")

function Unit:select()
	self.instance.BrickColor = BrickColor.Yellow()
end

function Unit:deselect()
	self.instance.BrickColor = BrickColor.White()
end

return Unit