local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.CharacterAutoLoads = false

local CameraManager = require(LocalPlayer.PlayerScripts:WaitForChild("CameraManager"))

CameraManager.new()