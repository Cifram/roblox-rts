local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local CameraManager = {}
CameraManager.__index = CameraManager

function CameraManager.new()
	local self = {}
	setmetatable(self, CameraManager)

	local cameraSpeed = 1
	local cameraRotateSpeed = 1
	local minZoom = 4
	local maxZoom = 6
	local zoomRate = 1

	local camera = workspace.Camera
	local terrain = workspace.Terrain
	local origin = Vector3.new(0, 512, 0)
	local angle = 0
	local zoom = minZoom
	local movingForward = false
	local movingBackward = false
	local movingLeft = false
	local movingRight = false
	local rotatingLeft = false
	local rotatingRight = false
	
	camera.CameraType = Enum.CameraType.Scriptable

	UserInputService.InputBegan:connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.W then
				movingForward = true
			elseif input.KeyCode == Enum.KeyCode.S then
				movingBackward = true
			elseif input.KeyCode == Enum.KeyCode.A then
				movingLeft = true
			elseif input.KeyCode == Enum.KeyCode.D then
				movingRight = true
			elseif input.KeyCode == Enum.KeyCode.Q then
				rotatingLeft = true
			elseif input.KeyCode == Enum.KeyCode.E then
				rotatingRight = true
			end
		end
	end)

	UserInputService.InputEnded:connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.W then
				movingForward = false
			elseif input.KeyCode == Enum.KeyCode.S then
				movingBackward = false
			elseif input.KeyCode == Enum.KeyCode.A then
				movingLeft = false
			elseif input.KeyCode == Enum.KeyCode.D then
				movingRight = false
			elseif input.KeyCode == Enum.KeyCode.Q then
				rotatingLeft = false
			elseif input.KeyCode == Enum.KeyCode.E then
				rotatingRight = false
			end
		end
	end)

	UserInputService.InputChanged:connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom + input.Position.Z * 0.01, minZoom, maxZoom)
		end
	end)

	RunService.Heartbeat:connect(function(timeMult)
		if rotatingLeft then
			angle = angle - cameraRotateSpeed * timeMult
		end
		if rotatingRight then
			angle = angle + cameraRotateSpeed * timeMult
		end

		local range = zoom*zoom
		local actualCameraSpeed = range * cameraSpeed
		local forward = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local left = Vector3.new(-forward.z, 0, forward.x)

		if movingForward then
			origin = origin + forward * actualCameraSpeed * timeMult
		end
		if movingBackward then
			origin = origin + forward * -actualCameraSpeed * timeMult
		end
		if movingRight then
			origin = origin + left * actualCameraSpeed * timeMult
		end
		if movingLeft then
			origin = origin + left * -actualCameraSpeed * timeMult
		end

		local _, intersection = workspace:FindPartOnRayWithWhitelist(Ray.new(origin, Vector3.new(0, -1024, 0)), { terrain })
		camera.CFrame = CFrame.new(intersection - forward*range + Vector3.new(0, range, 0), intersection)
	end)
	
	return self
end

return CameraManager