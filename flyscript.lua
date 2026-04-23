-- =========================================================
-- FLY + SPEED GUI V4 (Modern & Stable)
-- Tata letak meniru input gambar user.
-- Tempatkan di: StarterPlayerScripts sebagai LocalScript
-- =========================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- --- Konfigurasi & Variabel State ---
local isFlying = false
local currentSpeed = 50 -- Kecepatan jalan & terbang awal
local isGuiVisible = true -- Untuk tombol minimize (-)

-- Variabel objek fisika fly (Modern)
local linearVel, alignOri, attachment

-- --- 1. Pembuatan GUI (Desain Tabel) ---
local sg = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
sg.Name = "CustomFlySpeedGUI"
sg.ResetOnSpawn = false -- GUI tidak hilang saat mati

local mainFrame = Instance.new("Frame", sg)
mainFrame.Size = UDim2.new(0, 260, 0, 100) -- Ukuran disesuaikan
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0) -- Posisi kiri tengah
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Bisa digeser

-- Fungsi helper untuk membuat tombol kotak seragam
local function createGridButton(parent, text, bgColor, textColor, posX, posY, sizeX, sizeY)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(0, sizeX or 50, 0, sizeY or 30)
    btn.Position = UDim2.new(0, posX, 0, posY)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.BackgroundColor3 = bgColor
    btn.TextColor3 = textColor
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    return btn
end

-- --- Layout Baris 1: Header & Kontrol Jendela ---
local closeBtn = createGridButton(mainFrame, "X", Color3.fromRGB(255, 50, 50), Color3.fromRGB(255, 255, 255), 0, 0)
local minBtn = createGridButton(mainFrame, "-", Color3.fromRGB(150, 150, 250), Color3.fromRGB(0, 0, 0), 51, 0)

local titleLbl = Instance.new("TextLabel", mainFrame)
titleLbl.Size = UDim2.new(0, 156, 0, 30)
titleLbl.Position = UDim2.new(0, 103, 0, 0)
titleLbl.Text = "FLY & SPEED GUI BY SHNOIZM"
titleLbl.Font = Enum.Font.SourceSansBold
titleLbl.TextSize = 16
titleLbl.BackgroundColor3 = Color3.fromRGB(255, 100, 255)
titleLbl.TextColor3 = Color3.fromRGB(0, 0, 0)
titleLbl.BorderSizePixel = 1

-- --- Layout Baris 2 & 3: Kontrol Vertikal (Kiri) & Speed/Fly (Kanan) ---

-- Kontrol Vertikal (Kolom Kiri)
local upBtn = createGridButton(mainFrame, "UP", Color3.fromRGB(150, 255, 150), Color3.fromRGB(0, 0, 0), 0, 31, 50, 34)
local downBtn = createGridButton(mainFrame, "DOWN", Color3.fromRGB(200, 255, 200), Color3.fromRGB(0, 0, 0), 0, 66, 50, 34)

-- Kontrol Speed (Kolom Tengah)
local speedPlusBtn = createGridButton(mainFrame, "+", Color3.fromRGB(150, 150, 250), Color3.fromRGB(0, 0, 0), 51, 31, 50, 34)
local speedMinusBtn = createGridButton(mainFrame, "-", Color3.fromRGB(150, 250, 250), Color3.fromRGB(0, 0, 0), 51, 66, 50, 34)

-- Input Angka Speed (Tengah Bawah)
local speedInput = Instance.new("TextBox", mainFrame)
speedInput.Size = UDim2.new(0, 50, 0, 34)
speedInput.Position = UDim2.new(0, 103, 0, 66)
speedInput.Text = tostring(currentSpeed)
speedInput.Font = Enum.Font.SourceSansBold
speedInput.TextSize = 20
speedInput.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
speedInput.TextColor3 = Color3.fromRGB(0, 0, 0)
speedInput.BorderSizePixel = 1

-- Tombol Fly Utama (Kanan)
local flyToggleBtn = createGridButton(mainFrame, "fly", Color3.fromRGB(255, 255, 100), Color3.fromRGB(0, 0, 0), 154, 31, 105, 69)
flyToggleBtn.TextSize = 24

-- --- Container Minimize ---
local minFrame = Instance.new("Frame", sg)
minFrame.Size = UDim2.new(0, 100, 0, 30)
minFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
minFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
minFrame.Visible = false
minFrame.Active = true; minFrame.Draggable = true

local maxBtn = createGridButton(minFrame, "Show GUI", Color3.fromRGB(100, 255, 100), Color3.fromRGB(0, 0, 0), 0, 0, 100, 30)

-- =========================================================
-- --- 2. Logika Inti: Speed & Fly ---
-- =========================================================

-- Fungsi Membersihkan Objek Fisika Fly
local function cleanFlyPhysics()
    local char = player.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
    if linearVel then linearVel:Destroy(); linearVel = nil end
    if alignOri then alignOri:Destroy(); alignOri = nil end
    if attachment then attachment:Destroy(); attachment = nil end
end

-- Fungsi Toggle Fly
local function toggleFly()
    isFlying = not isFlying
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    
    cleanFlyPhysics() -- Pastikan bersih dulu

    if isFlying and root and hum then
        flyToggleBtn.Text = "FLYING"
        flyToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 255, 100) -- Hijau saat aktif
        hum.PlatformStand = true -- Mematikan fisika jalan standar
        
        attachment = Instance.new("Attachment", root)
        
        -- Mengontrol posisi (Terbang)
        linearVel = Instance.new("LinearVelocity", root)
        linearVel.Attachment0 = attachment
        linearVel.MaxForce = 9999999 -- Sangat kuat
        linearVel.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        linearVel.VectorVelocity = Vector3.new(0, 0, 0)
        
        -- Mengontrol rotasi (Menghadap Kamera)
        alignOri = Instance.new("AlignOrientation", root)
        alignOri.Attachment0 = attachment
        alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
        alignOri.RigidityEnabled = true
        alignOri.CFrame = workspace.CurrentCamera.CFrame
    else
        flyToggleBtn.Text = "fly"
        flyToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 100) -- Kuning default
    end
end

-- --- 3. Loop Utama (RunService) ---
-- Berjalan setiap frame untuk memaksa Speed dan arah terbang
RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if not hum or not root then return end

    -- A. PAKSA SPEED (Anti-Reset)
    -- Ini berjalan terus, baik saat terbang maupun tidak.
    if hum.WalkSpeed ~= currentSpeed then
        hum.WalkSpeed = currentSpeed
    end

    -- B. LOGIKA ARAH TERBANG
    if isFlying and linearVel and alignOri then
        local camCF = workspace.CurrentCamera.CFrame
        local moveDir = hum.MoveDirection -- Arah input WASD user
        
        -- Kecepatan terbang lebih tinggi dari jalan agar terasa pas
        local flySpeedMultiplier = 2.5 
        local targetVelocity = moveDir * (currentSpeed * flySpeedMultiplier)
        
        -- Jika tidak ada input gerakan, kunci posisi (hover)
        if moveDir.Magnitude > 0 then
            linearVel.VectorVelocity = targetVelocity
        else
            linearVel.VectorVelocity = Vector3.new(0, 0, 0)
        end
        
        -- Paksa karakter selalu menghadap arah kamera
        alignOri.CFrame = camCF
    end
end)

-- =========================================================
-- --- 4. Event Handling (Tombol) ---
-- =========================================================

-- Tombol X (Tutup total)
closeBtn.MouseButton1Click:Connect(function()
    if isFlying then toggleFly() end -- Matikan fly dulu
    sg:Destroy()
end)

-- Tombol - (Minimize)
minBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    minFrame.Visible = true
    minFrame.Position = mainFrame.Position -- Pindah ke posisi terakhir
end)

-- Tombol Show GUI
maxBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = true
    minFrame.Visible = false
    mainFrame.Position = minFrame.Position -- Pindah ke posisi terakhir
end)

-- Tombol UP (Terbang naik manual)
local verticalVel = 50 -- Kecepatan naik/turun
upBtn.MouseButton1Down:Connect(function()
    if isFlying and linearVel then
        linearVel.VectorVelocity = Vector3.new(0, verticalVel, 0)
    end
end)
upBtn.MouseButton1Up:Connect(function() -- Berhenti naik saat dilepas
    if isFlying and linearVel then linearVel.VectorVelocity = Vector3.new(0,0,0) end
end)

-- Tombol DOWN (Terbang turun manual)
downBtn.MouseButton1Down:Connect(function()
    if isFlying and linearVel then
        linearVel.VectorVelocity = Vector3.new(0, -verticalVel, 0)
    end
end)
downBtn.MouseButton1Up:Connect(function() -- Berhenti turun saat dilepas
    if isFlying and linearVel then linearVel.VectorVelocity = Vector3.new(0,0,0) end
end)

-- Fungsi Update Speed Aman
local function setSpeed(newSpeed)
    local s = tonumber(newSpeed)
    if s and s > 0 then
        currentSpeed = s
        speedInput.Text = tostring(currentSpeed)
        -- Speed dipaksa di loop Heartbeat, jadi tidak perlu set manual di sini
    end
end

-- Tombol Speed +
speedPlusBtn.MouseButton1Click:Connect(function()
    setSpeed(currentSpeed + 10)
end)

-- Tombol Speed -
speedMinusBtn.MouseButton1Click:Connect(function()
    if currentSpeed > 10 then
        setSpeed(currentSpeed - 10)
    else
        setSpeed(1) -- Jangan sampai 0/negatif
    end
end)

-- Input Angka Manual
speedInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        setSpeed(speedInput.Text)
    end
end)

-- Tombol Fly Utama
flyToggleBtn.MouseButton1Click:Connect(toggleFly)

-- Bersihkan jika karakter mati/respawn (tambahan keamanan)
player.CharacterAdded:Connect(function()
    if isFlying then toggleFly() end
end)
