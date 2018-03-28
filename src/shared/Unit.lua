local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)

local Unit = Component:extend("Unit")

function Unit:onClick()
end

return Unit