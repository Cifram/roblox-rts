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
	local zoomRate = 0.1

	local camera = workspace.Camera
	local terrain = workspace.Terrain
	local origin = Vector3.new(0, 512, 0)
	local angle = 0
	local zoom = minZoom

	camera.CameraType = Enum.CameraType.Scriptable

	UserInputService.InputChanged:connect(function(input, processed)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			zoom = math.clamp(zoom + input.Position.Z * zoomRate, minZoom, maxZoom)
		end
	end)

	RunService.Heartbeat:connect(function(timeMult)
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			angle = angle - cameraRotateSpeed * timeMult
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			angle = angle + cameraRotateSpeed * timeMult
		end

		local range = zoom*zoom
		local actualCameraSpeed = range * cameraSpeed
		local forward = Vector3.new(math.cos(angle), 0, math.sin(angle))
		local left = Vector3.new(-forward.z, 0, forward.x)

		if UserInputService:IsKeyDown(Enum.KeyCode.W) then
			origin = origin + forward * actualCameraSpeed * timeMult
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then
			origin = origin + forward * -actualCameraSpeed * timeMult
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then
			origin = origin + left * actualCameraSpeed * timeMult
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then
			origin = origin + left * -actualCameraSpeed * timeMult
		end

		local _, intersection = workspace:FindPartOnRayWithWhitelist(Ray.new(origin, Vector3.new(0, -1024, 0)), { terrain })
		camera.CFrame = CFrame.new(intersection - forward*range + Vector3.new(0, range, 0), intersection)
	end)
	
	return self
end

return CameraManager