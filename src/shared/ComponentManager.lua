local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)
require(Shared.Unit)

local ComponentManager = {}
ComponentManager.__index = ComponentManager

function ComponentManager.new()
	local self = {}
	setmetatable(self, ComponentManager)

	Component._setup()

	RunService.Heartbeat:connect(function(dt)
		Component._update(dt)
		Component._processQueue()
	end)
end

return ComponentManager