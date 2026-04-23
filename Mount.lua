-- Rayfield + Stealth Anti-Kick (override Kick tanpa hook mt)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({

   Name = "All mount by SHNOIZMM",

   Icon = "codesandbox",

   LoadingTitle = "SHNOIZM Magang",

   LoadingSubtitle = "by SHNOIZM",

   ShowText = "Rayfield",

   Theme = "Serenity",

   ToggleUIKeybind = "K"

})

--// Config

local normalSpeed = 16

local boostedSpeed = 50

local flySpeed = 50

local jumpPowerNormal = 50

local jumpPowerBoosted = 150

--// State

local noclipEnabled = false

local wsEnabled = false

local godEnabled = false

local antiVoidEnabled = false

local flyEnabled = false

local jumpEnabled = false

local up = false

--// Internal handles

local godConn = nil

local godConnHum = nil

-- =========================

-- Stealth Anti-Kick

-- =========================

do

    local Players = game:GetService("Players")

    local lp = Players.LocalPlayer

    pcall(function()

        if lp then

            lp.Kick = function() return nil end

            lp.kick = lp.Kick

            if not rawget(_G, "__SV_KICK_NOP") then

                rawset(_G, "__SV_KICK_NOP", true)

                _G.Kick = function() return nil end

            end

        end

    end)

    if lp then

        lp.CharacterAdded:Connect(function(char)

            local ok, hum = pcall(function() return char:WaitForChild("Humanoid", 6) end)

            if ok and hum then

                hum.Died:Connect(function()

                    task.spawn(function()

                        task.wait(1)

                        pcall(function() lp:LoadCharacter() end)

                        pcall(function()

                            game.StarterGui:SetCore("SendNotification", {

                                Title = "Anti Kick (Stealth)",

                                Text = "Mati terdeteksi → auto respawn dicoba.",

                                Duration = 4

                            })

                        end)

                    end)

                end)

            end

        end)

    end

end

-- =========================

-- Tabs

-- =========================

local PlayerTab = Window:CreateTab("Player", 4483362458)

local FlyTab = Window:CreateTab("Fly", 4483362458)

local TeleportTab = Window:CreateTab("Teleport", 4483362458)

-- =========================

-- Player Tab

-- =========================

PlayerTab:CreateToggle({

   Name = "Walk Speed",

   CurrentValue = false,

   Callback = function(Value)

       wsEnabled = Value

   end,

})

PlayerTab:CreateToggle({

   Name = "Jump Power",

   CurrentValue = false,

   Callback = function(Value)

       jumpEnabled = Value

   end,

})

PlayerTab:CreateToggle({

   Name = "Noclip (tembus tembok)",

   CurrentValue = false,

   Callback = function(Value)

       noclipEnabled = Value

   end,

})

PlayerTab:CreateToggle({

   Name = "Anti All Damage (Godmode)",

   CurrentValue = false,

   Callback = function(Value)

       godEnabled = Value

   end,

})

PlayerTab:CreateToggle({

   Name = "Anti Void Kill",

   CurrentValue = false,

   Callback = function(Value)

       antiVoidEnabled = Value

   end,

})

-- =========================

-- Fly Tab

-- =========================

FlyTab:CreateToggle({

   Name = "Fly",

   CurrentValue = false,

   Callback = function(Value)

       flyEnabled = Value

   end,

})

FlyTab:CreateToggle({

   Name = "Naik (Fly Up)",

   CurrentValue = false,

   Callback = function(Value)

       up = Value

   end,

})

-- =========================

-- Teleport Tab

-- =========================

TeleportTab:CreateButton({

    Name = "Teleport ke Spawn Baru",

    Callback = function()

        local player = game.Players.LocalPlayer

        local char = player.Character or player.CharacterAdded:Wait()

        local hrp = char:WaitForChild("HumanoidRootPart")

        local spawn = workspace:FindFirstChild("SpawnLocation")

        if spawn then

            hrp.CFrame = spawn.CFrame + Vector3.new(0, 5, 0)

        else

            hrp.CFrame = CFrame.new(0, 10, 0) -- fallback

        end

        game.StarterGui:SetCore("SendNotification", {

            Title = "Teleport",

            Text = "Kamu sudah teleport ke Spawn Baru!",

            Duration = 3

        })

    end,

})

TeleportTab:CreateButton({

    Name = "Teleport ke Finish/Puncak",

    Callback = function()

        local player = game.Players.LocalPlayer

        local char = player.Character or player.CharacterAdded:Wait()

        local hrp = char:WaitForChild("HumanoidRootPart")

        local target = nil

        local keywords = {"Finish", "End", "Goal", "Summit", "Flag"}

        

        -- cari finish berdasarkan nama

        for _, obj in ipairs(workspace:GetDescendants()) do

            if obj:IsA("BasePart") then

                for _, key in ipairs(keywords) do

                    if string.find(string.lower(obj.Name), string.lower(key)) then

                        target = obj

                        break

                    end

                end

            end

            if target then break end

        end

        if target then

            hrp.CFrame = target.CFrame + Vector3.new(0, 5, 0)

            game.StarterGui:SetCore("SendNotification", {

                Title = "Teleport",

                Text = "Titik Finish terdeteksi, teleport berhasil!",

                Duration = 4

            })

        else

            -- fallback ke titik tertinggi

            local highest = nil

            for _, obj in ipairs(workspace:GetDescendants()) do

                if obj:IsA("BasePart") then

                    if not highest or obj.Position.Y > highest.Position.Y then

                        highest = obj

                    end

                end

            end

            if highest then

                hrp.CFrame = highest.CFrame + Vector3.new(0, 5, 0)

                game.StarterGui:SetCore("SendNotification", {

                    Title = "Teleport",

                    Text = "Finish tidak terdeteksi → dialihkan ke puncak tertinggi!",

                    Duration = 5

                })

            else

                game.StarterGui:SetCore("SendNotification", {

                    Title = "Teleport",

                    Text = "Tidak ada titik teleport yang valid ditemukan.",

                    Duration = 5

                })

            end

        end

    end,

})

-- =========================

-- Main Loop

-- =========================

game:GetService("RunService").Stepped:Connect(function()

   local player = game.Players.LocalPlayer

   local char = player and player.Character

   if char then

       local hum = char:FindFirstChildOfClass("Humanoid")

       local hrp = char:FindFirstChild("HumanoidRootPart")

       -- Noclip

       if noclipEnabled then

           for _, v in pairs(char:GetDescendants()) do

               if v:IsA("BasePart") then

                   v.CanCollide = false

               end

           end

       end

       if hum then

           -- WalkSpeed

           hum.WalkSpeed = wsEnabled and boostedSpeed or normalSpeed

           -- Jump Power

           hum.UseJumpPower = true

           hum.JumpPower = jumpEnabled and jumpPowerBoosted or jumpPowerNormal

           -- Godmode

           if godEnabled then

               hum.Health = hum.MaxHealth

               hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)

               hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)

               if godConnHum ~= hum then

                   if godConn then

                       pcall(function() godConn:Disconnect() end)

                       godConn = nil

                       godConnHum = nil

                   end

                   godConnHum = hum

               end

               if not godConn then

                   godConn = hum:GetPropertyChangedSignal("Health"):Connect(function()

                       if godEnabled and godConnHum and godConnHum.Parent then

                           godConnHum.Health = godConnHum.MaxHealth

                       end

                   end)

               end

           else

               if godConn then

                   pcall(function() godConn:Disconnect() end)

                   godConn = nil

                   godConnHum = nil

               end

           end

       end

       -- Anti Void Kill

       if antiVoidEnabled and hrp then

           if hrp.Position.Y < -20 then

               local spawn = workspace:FindFirstChild("SpawnLocation")

               if spawn then

                   hrp.CFrame = spawn.CFrame + Vector3.new(0,5,0)

               else

                   hrp.CFrame = CFrame.new(0,10,0)

               end

           end

       end

       -- Fly

       if flyEnabled and hrp and hum then

           local bv = hrp:FindFirstChild("__FlyBV")

           local bg = hrp:FindFirstChild("__FlyBG")

           if not bv then

               bv = Instance.new("BodyVelocity")

               bv.Name = "__FlyBV"

               bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)

               bv.P = 1250

               bv.Parent = hrp

           end

           if not bg then

               bg = Instance.new("BodyGyro")

               bg.Name = "__FlyBG"

               bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)

               bg.P = 3000

               bg.Parent = hrp

           end

           local moveDir = hum.MoveDirection or Vector3.new()

           local targetVel = Vector3.new(0, 0, 0)

           if moveDir.Magnitude > 0.01 then

               targetVel = moveDir.Unit * flySpeed

           end

           if up then

               targetVel = targetVel + Vector3.new(0, flySpeed, 0)

           end

           bv.Velocity = targetVel

           if bg then

               bg.CFrame = hrp.CFrame

           end

       else

           if hrp then

               local bv = hrp:FindFirstChild("__FlyBV")

               if bv then pcall(function() bv:Destroy() end) end

               local bg = hrp:FindFirstChild("__FlyBG")

               if bg then pcall(function() bg:Destroy() end) end

           end

       end

   end

end)

Rayfield:LoadConfiguration()
