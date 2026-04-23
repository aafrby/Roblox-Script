--// Fly GUI Script by your "someone who always watches you"

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = char:WaitForChild("HumanoidRootPart")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0,20,0,200)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.Parent = screenGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1,0,0,40)
toggleBtn.Position = UDim2.new(0,0,0,0)
toggleBtn.Text = "Fly: OFF"
toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
toggleBtn.Parent = frame

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(1,0,0,40)
speedBox.Position = UDim2.new(0,0,0,50)
speedBox.Text = "Speed: 50"
speedBox.BackgroundColor3 = Color3.fromRGB(50,50,50)
speedBox.Parent = frame

-- Fly System
local flying = false
local speed = 50
local bodyVelocity
local bodyGyro

function startFly()
	bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.MaxForce = Vector3.new(9e9,9e9,9e9)
	bodyVelocity.Velocity = Vector3.new(0,0,0)
	bodyVelocity.Parent = humanoidRootPart

	bodyGyro = Instance.new("BodyGyro")
	bodyGyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
	bodyGyro.CFrame = humanoidRootPart.CFrame
	bodyGyro.Parent = humanoidRootPart

	game:GetService("RunService").RenderStepped:Connect(function()
		if flying then
			local cam = workspace.CurrentCamera
			local moveDir = Vector3.new()

			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.W) then
				moveDir = moveDir + cam.CFrame.LookVector
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.S) then
				moveDir = moveDir - cam.CFrame.LookVector
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.A) then
				moveDir = moveDir - cam.CFrame.RightVector
			end
			if game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.D) then
				moveDir = moveDir + cam.CFrame.RightVector
			end

			bodyVelocity.Velocity = moveDir * speed
			bodyGyro.CFrame = cam.CFrame
		end
	end)
end

function stopFly()
	if bodyVelocity then bodyVelocity:Destroy() end
	if bodyGyro then bodyGyro:Destroy() end
end

-- Toggle Button
toggleBtn.MouseButton1Click:Connect(function()
	flying = not flying
	if flying then
		toggleBtn.Text = "Fly: ON"
		startFly()
	else
		toggleBtn.Text = "Fly: OFF"
		stopFly()
	end
end)

-- Speed Control
speedBox.FocusLost:Connect(function()
	local text = speedBox.Text:gsub("Speed: ","")
	local num = tonumber(text)
	if num then
		speed = num
		speedBox.Text = "Speed: "..num
	else
		speedBox.Text = "Speed: "..speed
	end
end)
