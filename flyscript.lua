-- setup
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local uis = game:GetService("UserInputService")
local run = game:GetService("RunService")

local flying = false
local speed = 50
local direction = Vector3.zero

-- physics
local bv = Instance.new("BodyVelocity")
bv.MaxForce = Vector3.new(1e5,1e5,1e5)

local bg = Instance.new("BodyGyro")
bg.MaxTorque = Vector3.new(1e5,1e5,1e5)

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "FlyGui"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,200,0,120)
frame.Position = UDim2.new(0,20,0.5,-60)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)

local toggleBtn = Instance.new("TextButton", frame)
toggleBtn.Size = UDim2.new(1,-20,0,40)
toggleBtn.Position = UDim2.new(0,10,0,10)
toggleBtn.Text = "Fly: OFF"

local speedBox = Instance.new("TextBox", frame)
speedBox.Size = UDim2.new(1,-20,0,40)
speedBox.Position = UDim2.new(0,10,0,60)
speedBox.Text = "Speed: 50"

-- toggle logic
toggleBtn.MouseButton1Click:Connect(function()
	flying = not flying
	
	if flying then
		bv.Parent = hrp
		bg.Parent = hrp
		toggleBtn.Text = "Fly: ON"
	else
		bv.Parent = nil
		bg.Parent = nil
		toggleBtn.Text = "Fly: OFF"
	end
end)

-- speed control
speedBox.FocusLost:Connect(function()
	local num = tonumber(speedBox.Text:match("%d+"))
	if num then
		speed = num
		speedBox.Text = "Speed: "..num
	else
		speedBox.Text = "Speed: "..speed
	end
end)

-- movement input
uis.InputBegan:Connect(function(input,gpe)
	if gpe then return end
	
	if input.KeyCode == Enum.KeyCode.W then direction += Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then direction += Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then direction += Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then direction += Vector3.new(1,0,0) end
	if input.KeyCode == Enum.KeyCode.Space then direction += Vector3.new(0,1,0) end
	if input.KeyCode == Enum.KeyCode.LeftControl then direction += Vector3.new(0,-1,0) end
end)

uis.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.W then direction -= Vector3.new(0,0,-1) end
	if input.KeyCode == Enum.KeyCode.S then direction -= Vector3.new(0,0,1) end
	if input.KeyCode == Enum.KeyCode.A then direction -= Vector3.new(-1,0,0) end
	if input.KeyCode == Enum.KeyCode.D then direction -= Vector3.new(1,0,0) end
	if input.KeyCode == Enum.KeyCode.Space then direction -= Vector3.new(0,1,0) end
	if input.KeyCode == Enum.KeyCode.LeftControl then direction -= Vector3.new(0,-1,0) end
end)

-- main loop
run.RenderStepped:Connect(function()
	if flying then
		local cam = workspace.CurrentCamera
		local move = cam.CFrame:VectorToWorldSpace(direction)
		
		bv.Velocity = move * speed
		bg.CFrame = cam.CFrame
	end
end)
