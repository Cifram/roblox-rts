local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)

local Unit = Component:extend("Unit")

function Unit:init()
	self.selected = false
end

function Unit:onClick()
	self.selected = not self.selected
	if self.selected then
		self.instance.BrickColor = BrickColor.Yellow()
	else
		self.instance.BrickColor = BrickColor.White()
	end
end

return Unit