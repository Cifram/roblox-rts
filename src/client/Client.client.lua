local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

Players.CharacterAutoLoads = false

local CameraManager = require(LocalPlayer.PlayerScripts:WaitForChild("CameraManager"))
local ComponentManager = require(ReplicatedStorage:WaitForChild("Scripts").ComponentManager)

CameraManager.new()
ComponentManager.new()