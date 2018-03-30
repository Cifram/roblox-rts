local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local Shared = ReplicatedStorage:WaitForChild("Scripts")
local Component = require(Shared.Component)

local Unit = Component:extend("Unit")

function Unit:init()
	self.offset = Vector3.new(0, -self.instance.Size.y / 2 + 1, 0)
	self.recalculatingPath = false
	self.moveSpeed = 5
end

function Unit:update(dt)
	if self.path then
		self:moveAlongPath(dt)
	end
end

function Unit:select()
	self.instance.BrickColor = BrickColor.Yellow()
end

function Unit:deselect()
	self.instance.BrickColor = BrickColor.White()
end

function Unit:pathTo(destination)
	self.destination = destination
	self:calculatePath()
end

function Unit:moveAlongPath(dt)
	local position = self.instance.CFrame.p + self.offset
	local waypoints = self.path:GetWaypoints()
	local delta = self.currentWaypointPosition - position
	local deltaMagnitude = delta.Magnitude
	local deltaDirection = delta / deltaMagnitude
	local travel = self.moveSpeed * dt

	-- If we're closer to the waypoint than the distance we'd travel, we've reached the waypoint.
	if deltaMagnitude < travel then
		local newPos = self.instance.CFrame.p + deltaDirection * travel
		self.instance.CFrame = CFrame.new(newPos, newPos + deltaDirection)

		-- If this is the last waypoint, we're done. Clear the path.
		-- Otherwise, move to the waypoint, and then move again to use up the rest of our movement to the next one.
		if self.currentWaypoint == #waypoints then
			self.path = nil
		else
			self.currentWaypoint = self.currentWaypoint + 1
			self.currentWaypointPosition = waypoints[self.currentWaypoint].Position
			self:moveAlongPath(dt * deltaMagnitude / travel)
		end
	else
		local newPos = self.instance.CFrame.p + deltaDirection * travel
		self.instance.CFrame = CFrame.new(newPos, newPos + deltaDirection)
	end
end

function Unit:calculatePath()
	-- If the path is incomplete or blocked, we need to recalculate periodically. This flag makes sure we don't attempt
	-- to recalculate again while we're still doing the last one.
	self.recalculatingPath = true
	spawn(function()
		local position = self.instance.CFrame.p + self.offset
		local destination = self.destination
		local path = PathfindingService:FindPathAsync(position, destination)

		-- If we were given a new destination before we finished calculating this one, discard this one.
		if destination ~= self.destination then
			return
		end

		-- If there is no path, then we can't reasonably retry. Just fail and do nothing.
		if path.status == Enum.PathStatus.NoPath then
			return
		end

		self.path = path
		self.currentWaypoint = 2
		self.currentWaypointPosition = path:GetWaypoints()[2].Position
		self.recalculatingPath = false
	end)
end

return Unit