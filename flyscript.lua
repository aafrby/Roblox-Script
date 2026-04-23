local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

local flying = false
local speedValue = 50

-- 1. Membuat GUI
local screenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
screenGui.Name = "FlySpeedGUI"

local frame = Instance.new("Frame", screenGui)
frame.Size = UDim2.new(0, 150, 0, 150)
frame.Position = UDim2.new(0.1, 0, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
frame.Active = true
frame.Draggable = true -- Bisa digeser

local flyButton = Instance.new("TextButton", frame)
flyButton.Size = UDim2.new(0, 130, 0, 40)
flyButton.Position = UDim2.new(0.07, 0, 0.1, 0)
flyButton.Text = "Fly: OFF"
flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)

local speedInput = Instance.new("TextBox", frame)
speedInput.Size = UDim2.new(0, 130, 0, 40)
speedInput.Position = UDim2.new(0.07, 0, 0.5, 0)
speedInput.PlaceholderText = "Speed (Default: 50)"
speedInput.Text = ""

-- 2. Fungsi Fly
local bv -- BodyVelocity
local bg -- BodyGyro

local function toggleFly()
    flying = not flying
    if flying then
        flyButton.Text = "Fly: ON"
        flyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        
        bv = Instance.new("BodyVelocity", root)
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        bg = Instance.new("BodyGyro", root)
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = root.CFrame
        
        -- Loop pergerakan
        spawn(function()
            while flying do
                wait()
                local moveDir = humanoid.MoveDirection
                bv.Velocity = moveDir * speedValue
                bg.CFrame = workspace.CurrentCamera.CFrame
            end
        end)
    else
        flyButton.Text = "Fly: OFF"
        flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end
end

-- 3. Event Handling
flyButton.MouseButton1Click:Connect(toggleFly)

speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        local newSpeed = tonumber(speedInput.Text)
        if newSpeed then
            speedValue = newSpeed
            humanoid.WalkSpeed = newSpeed
        end
    end
end)
