local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Stats = game:GetService("Stats")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local GUI = Instance.new("ScreenGui")
GUI.Name = "DOLONG_HUB"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 9999
GUI.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local function corner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = obj
end

local blue = Color3.fromRGB(0, 145, 255)
local dark = Color3.fromRGB(12, 16, 24)
local panel = Color3.fromRGB(20, 27, 39)
local white = Color3.fromRGB(235, 242, 255)
local green = Color3.fromRGB(0, 200, 100)
local red = Color3.fromRGB(215, 60, 60)

-- Thanh FPS
local status = Instance.new("Frame")
status.Size = UDim2.new(1, 0, 0, 24)
status.Position = UDim2.new(0, 0, 0, 0)
status.BackgroundColor3 = dark
status.BackgroundTransparency = 0.55
status.ZIndex = 10
status.Parent = GUI

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(1, -12, 1, 0)
statusText.Position = UDim2.new(0, 6, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Font = Enum.Font.GothamSemibold
statusText.TextSize = 11
statusText.TextColor3 = white
statusText.TextStrokeTransparency = 1
statusText.TextXAlignment = Enum.TextXAlignment.Center
statusText.ZIndex = 11
statusText.Parent = status

local fpsFrames, fpsClock, fpsValue = 0, os.clock(), 0
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = os.clock()
    if now - fpsClock >= 1 then
        fpsValue = math.floor(fpsFrames / (now - fpsClock))
        fpsFrames, fpsClock = 0, now
    end
    local p=0 pcall(function() p=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
    statusText.Text = string.format("FPS %d  |  PING %d ms  |  %s  |  %s", fpsValue, p, os.date("%d/%m/%Y"), os.date("%H:%M:%S"))
end)

-- Menu chính
local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(300, 320)
main.Position = UDim2.new(0.5, -150, 0.5, -160)
main.BackgroundColor3 = dark
main.Visible = false
main.ZIndex = 50
main.Parent = GUI
corner(main, 12)

local top = Instance.new("TextLabel")
top.Size = UDim2.new(1, -40, 0, 32)
top.Position = UDim2.fromOffset(10, 4)
top.BackgroundTransparency = 1
top.Text = "DOLONG HUB"
top.Font = Enum.Font.GothamBlack
top.TextSize = 16
top.TextColor3 = blue
top.TextStrokeTransparency = 1
top.TextXAlignment = Enum.TextXAlignment.Left
top.ZIndex = 51
top.Parent = main

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(24, 24)
closeBtn.Position = UDim2.new(1, -32, 0, 8)
closeBtn.BackgroundColor3 = red
closeBtn.Text = "X"
closeBtn.TextColor3 = white
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.ZIndex = 52
closeBtn.Parent = main
corner(closeBtn, 6)
closeBtn.Activated:Connect(function() main.Visible = false end)

local dragging, dragStart, startPos
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging, dragStart, startPos = true, input.Position, main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, -16, 0, 30)
tabBar.Position = UDim2.fromOffset(8, 38)
tabBar.BackgroundTransparency = 1
tabBar.ZIndex = 51
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 2)
tabLayout.Parent = tabBar

local content = Instance.new("ScrollingFrame")
content.Size = UDim2.new(1, -16, 1, -76)
content.Position = UDim2.fromOffset(8, 72)
content.BackgroundColor3 = panel
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.CanvasSize = UDim2.new()
content.ZIndex = 51
content.Parent = main
corner(content, 8)

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 6)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = content
list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    content.CanvasSize = UDim2.new(0, 0, 0, list.AbsoluteContentSize.Y + 10)
end)

local function clearContent()
    for _, child in ipairs(content:GetChildren()) do
        if child ~= list then child:Destroy() end
    end
end

local function label(text)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = blue
    l.Font = Enum.Font.GothamBold
    l.TextSize = 11
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextStrokeTransparency = 1
    l.ZIndex = 52
    l.Parent = content
    return l
end

local function button(text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 30)
    b.BackgroundColor3 = dark
    b.Text = text
    b.TextColor3 = white
    b.Font = Enum.Font.GothamSemibold
    b.TextSize = 11
    b.TextStrokeTransparency = 1
    b.ZIndex = 52
    b.Parent = content
    corner(b, 6)
    b.Activated:Connect(callback)
    return b
end

local function createToggleSwitch(text, defaultState, callback)
    local holder = Instance.new("TextButton")
    holder.Size = UDim2.new(1, -10, 0, 32)
    holder.BackgroundColor3 = dark
    holder.Text = ""
    holder.AutoButtonColor = false
    holder.ZIndex = 52
    holder.Parent = content
    corner(holder, 6)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.fromOffset(10, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = white
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextStrokeTransparency = 1
    lbl.ZIndex = 53
    lbl.Parent = holder

    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(38, 18)
    track.Position = UDim2.new(1, -48, 0.5, -9)
    track.BackgroundColor3 = defaultState and blue or Color3.fromRGB(50, 50, 55)
    track.ZIndex = 53
    track.Parent = holder
    corner(track, 9)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.Position = defaultState and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    knob.BackgroundColor3 = white
    knob.ZIndex = 54
    knob.Parent = track
    corner(knob, 7)

    local state = defaultState
    local function update(v)
        state = v
        local ti = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        if state then
            TweenService:Create(track, ti, {BackgroundColor3 = blue}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(1, -16, 0.5, -7)}):Play()
        else
            TweenService:Create(track, ti, {BackgroundColor3 = Color3.fromRGB(50, 50, 55)}):Play()
            TweenService:Create(knob, ti, {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
        end
        if callback then callback(state) end
    end

    holder.Activated:Connect(function() update(not state) end)
    return holder, update
end

local function slider(text, minV, maxV, defaultV, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, -10, 0, 42)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 52
    holder.Parent = content
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 16)
    title.BackgroundTransparency = 1
    title.TextColor3 = white
    title.Font = Enum.Font.Gotham
    title.TextSize = 11
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = text .. ": " .. tostring(defaultV)
    title.TextStrokeTransparency = 1
    title.ZIndex = 52
    title.Parent = holder
    local bar = Instance.new("TextButton")
    bar.Size = UDim2.new(1, 0, 0, 14)
    bar.Position = UDim2.fromOffset(0, 22)
    bar.Text = ""
    bar.BackgroundColor3 = Color3.fromRGB(42, 52, 68)
    bar.ZIndex = 52
    bar.Parent = holder
    corner(bar, 7)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultV-minV)/(maxV-minV), 0, 1, 0)
    fill.BackgroundColor3 = blue
    fill.ZIndex = 53
    fill.Parent = bar
    corner(fill, 7)
    local function setFromX(x)
        local ratio = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = math.floor(minV + ratio * (maxV-minV))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        title.Text = text .. ": " .. tostring(value)
        callback(value)
    end
    bar.Activated:Connect(function() setFromX(UserInputService:GetMouseLocation().X) end)
    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            setFromX(input.Position.X)
        end
    end)
end

-- Logic Variables
local flying, flySpeed, flyConn = false, 55, nil
local speedEnabled, speedValue = false, 50
local bodyVelocity, bodyGyro
local upHeld, downHeld = false, false
local autoClick, autoWin, noclip, autoCollectEnabled = false, false, false, false
local godModeConn, antiAfkConn, infJumpConn, noclipConn, antiVoidConn, waterWalkConn, flyToMouseConn, rainbowConn, autoFarmConn

local function applySpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speedEnabled and speedValue or 16 end
end

local function stopFly()
    flying = false
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
    if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
end

local function startFly()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    stopFly()
    flying = true
    bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bodyVelocity.Velocity = Vector3.zero
    bodyVelocity.Parent = hrp
    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    bodyGyro.P = 9e4
    bodyGyro.CFrame = hrp.CFrame
    bodyGyro.Parent = hrp
    flyConn = RunService.RenderStepped:Connect(function()
        if not flying or not hrp.Parent then stopFly() return end
        local cam = workspace.CurrentCamera
        local move = hum.MoveDirection
        local vertical = (upHeld and 1 or 0) - (downHeld and 1 or 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vertical = 1 end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vertical = -1 end
        bodyVelocity.Velocity = (move + Vector3.new(0, vertical, 0)) * flySpeed
        bodyGyro.CFrame = cam.CFrame
    end)
end

local espEnabled, nameESP, distanceESP = false, false, false
local espObjects = {}
local function clearESP()
    for p, gui in pairs(espObjects) do if gui then gui:Destroy() end espObjects[p] = nil end
end
local function makeESP(player)
    if player == LocalPlayer or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    if not head then return end
    if espObjects[player] then espObjects[player]:Destroy() end
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(160, 34) bb.StudsOffset = Vector3.new(0, 2.5, 0) bb.AlwaysOnTop = true bb.Adornee = head bb.Parent = GUI
    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1) txt.BackgroundTransparency = 1 txt.TextColor3 = blue txt.TextStrokeTransparency = 1 txt.Font = Enum.Font.GothamBold txt.TextSize = 12 txt.Parent = bb
    espObjects[player] = bb
    task.spawn(function()
        while bb.Parent and player.Parent do
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local theirRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local parts = {}
            if nameESP then table.insert(parts, player.Name) end
            if distanceESP and myRoot and theirRoot then table.insert(parts, tostring(math.floor((myRoot.Position-theirRoot.Position).Magnitude)).."m") end
            txt.Text = (#parts > 0 and table.concat(parts, " | ") or player.Name)
            task.wait(0.25)
        end
    end)
end
local function refreshESP()
    clearESP()
    if espEnabled or nameESP or distanceESP then for _, p in ipairs(Players:GetPlayers()) do makeESP(p) end end
end
Players.PlayerAdded:Connect(function() task.wait(1) refreshESP() end)
Players.PlayerRemoving:Connect(function(p) if espObjects[p] then espObjects[p]:Destroy() espObjects[p] = nil end end)

local function makeDraggable(btn, onClick)
    local dragging, dragStart, startPos, moved = false, nil, nil, false
    btn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging, moved, dragStart, startPos = true, false, input.Position, btn.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onClick then onClick() end
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then moved = true end
            btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- NÚT NỔI
local winBtnFloat = Instance.new("TextButton")
winBtnFloat.Size = UDim2.fromOffset(54, 34) winBtnFloat.Position = UDim2.new(0, 12, 0.55, 45)
winBtnFloat.BackgroundColor3 = dark winBtnFloat.Text = "WIN" winBtnFloat.TextColor3 = blue winBtnFloat.Font = Enum.Font.GothamBlack winBtnFloat.TextSize = 10 winBtnFloat.TextStrokeTransparency = 1 winBtnFloat.ZIndex = 999 winBtnFloat.Parent = GUI
corner(winBtnFloat, 8)

local acBtnFloat = Instance.new("TextButton")
acBtnFloat.Size = UDim2.fromOffset(54, 34) acBtnFloat.Position = UDim2.new(0, 12, 0.55, 90)
acBtnFloat.BackgroundColor3 = dark acBtnFloat.Text = "AC" acBtnFloat.TextColor3 = blue acBtnFloat.Font = Enum.Font.GothamBlack acBtnFloat.TextSize = 10 acBtnFloat.TextStrokeTransparency = 1 acBtnFloat.ZIndex = 999 acBtnFloat.Parent = GUI
corner(acBtnFloat, 8)

local upBtn = Instance.new("TextButton")
upBtn.Size = UDim2.fromOffset(45, 45) upBtn.Position = UDim2.new(1, -110, 0.7, 0)
upBtn.BackgroundColor3 = dark upBtn.Text = "⬆️" upBtn.TextColor3 = blue upBtn.Font = Enum.Font.GothamBold upBtn.TextSize = 20 upBtn.TextStrokeTransparency = 1 upBtn.ZIndex = 999 upBtn.Parent = GUI
upBtn.Visible = false
corner(upBtn, 8)
upBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then upHeld=true end end)
upBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then upHeld=false end end)

local downBtn = Instance.new("TextButton")
downBtn.Size = UDim2.fromOffset(45, 45) downBtn.Position = UDim2.new(1, -60, 0.7, 0)
downBtn.BackgroundColor3 = dark downBtn.Text = "⬇️" downBtn.TextColor3 = blue downBtn.Font = Enum.Font.GothamBold downBtn.TextSize = 20 downBtn.TextStrokeTransparency = 1 downBtn.ZIndex = 999 downBtn.Parent = GUI
downBtn.Visible = false
corner(downBtn, 8)
downBtn.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then downHeld=true end end)
downBtn.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then downHeld=false end end)

local function setAutoWin(state)
    autoWin = state
    winBtnFloat.Text = autoWin and "WIN ON" or "WIN"
    winBtnFloat.BackgroundColor3 = autoWin and green or dark
    winBtnFloat.TextColor3 = autoWin and dark or blue
end

local function setAutoClick(state)
    autoClick = state
    acBtnFloat.Text = autoClick and "AC ON" or "AC"
    acBtnFloat.BackgroundColor3 = autoClick and green or dark
    acBtnFloat.TextColor3 = autoClick and dark or blue
end

makeDraggable(winBtnFloat, function() setAutoWin(not autoWin) end)
makeDraggable(acBtnFloat, function() setAutoClick(not autoClick) end)

-- Hàm Teleport tới Player
local function createTPList()
    local tpLabel = Instance.new("TextLabel")
    tpLabel.Size = UDim2.new(1, -10, 0, 20)
    tpLabel.BackgroundTransparency = 1
    tpLabel.Text = "TELEPORT TO PLAYER"
    tpLabel.TextColor3 = blue
    tpLabel.Font = Enum.Font.GothamBold
    tpLabel.TextSize = 11
    tpLabel.TextXAlignment = Enum.TextXAlignment.Left
    tpLabel.TextStrokeTransparency = 1
    tpLabel.ZIndex = 52
    tpLabel.Parent = content

    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(1, -10, 0, 26)
    refreshBtn.BackgroundColor3 = dark
    refreshBtn.Text = "Refresh Player List"
    refreshBtn.TextColor3 = white
    refreshBtn.Font = Enum.Font.GothamSemibold
    refreshBtn.TextSize = 11
    refreshBtn.TextStrokeTransparency = 1
    refreshBtn.ZIndex = 52
    refreshBtn.Parent = content
    corner(refreshBtn, 6)
    
    local playerListFrame = Instance.new("Frame")
    playerListFrame.Size = UDim2.new(1, -10, 0, 0)
    playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
    playerListFrame.BackgroundTransparency = 1
    playerListFrame.ZIndex = 52
    playerListFrame.Parent = content

    local pListLayout = Instance.new("UIListLayout")
    pListLayout.Padding = UDim.new(0, 4)
    pListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pListLayout.Parent = playerListFrame

    local function populateList()
        for _, child in ipairs(playerListFrame:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end

        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pBtn = Instance.new("TextButton")
                pBtn.Size = UDim2.new(1, 0, 0, 28)
                pBtn.BackgroundColor3 = Color3.fromRGB(30, 40, 55)
                pBtn.Text = "TP -> " .. p.Name
                pBtn.TextColor3 = white
                pBtn.Font = Enum.Font.GothamSemibold
                pBtn.TextSize = 11
                pBtn.TextStrokeTransparency = 1
                pBtn.ZIndex = 53
                pBtn.Parent = playerListFrame
                corner(pBtn, 6)
                
                pBtn.Activated:Connect(function()
                    local myChar = LocalPlayer.Character
                    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                    local targetChar = p.Character
                    local targetHrp = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
                    
                    if myHrp and targetHrp then
                        myHrp.CFrame = targetHrp.CFrame + Vector3.new(0, 3, 0)
                    end
                end)
            end
        end
    end

    refreshBtn.Activated:Connect(populateList)
    populateList()
end

local function showTab(tabName)
    clearContent()
    
    if tabName == "MOVE" then
        label("FLIGHT")
        createToggleSwitch("Fly", false, function(v) 
            upBtn.Visible = v downBtn.Visible = v
            if v then startFly() else stopFly() end 
        end)
        slider("Fly Speed", 10, 150, flySpeed, function(v) flySpeed = v end)
        createToggleSwitch("Fly to Mouse", false, function(v)
            if flyToMouseConn then flyToMouseConn:Disconnect() flyToMouseConn = nil end
            if v then
                flyToMouseConn = RunService.RenderStepped:Connect(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local mouse = UserInputService:GetMouseLocation()
                        local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                        hrp.CFrame = CFrame.new(ray.Origin + ray.Direction * 50)
                    end
                end)
            end
        end)
        
        label("SPEED")
        createToggleSwitch("Speed Boost", false, function(v) speedEnabled = v applySpeed() end)
        slider("Walk Speed", 16, 150, speedValue, function(v) speedValue = v if speedEnabled then applySpeed() end end)
        
        label("TRAVERSAL")
        createToggleSwitch("Noclip", false, function(v)
            noclip = v
            if noclipConn then noclipConn:Disconnect() noclipConn = nil end
            if v then
                noclipConn = RunService.Stepped:Connect(function()
                    local char = LocalPlayer.Character
                    if char then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = false end end end
                end)
            else
                local char = LocalPlayer.Character
                if char then for _, part in ipairs(char:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end end
            end
        end)
        createToggleSwitch("Infinite Jump", false, function(v)
            if infJumpConn then infJumpConn:Disconnect() infJumpConn = nil end
            if v then
                infJumpConn = UserInputService.JumpRequest:Connect(function()
                    local char = LocalPlayer.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end)
            end
        end)
        createToggleSwitch("Walk on Water", false, function(v)
            if waterWalkConn then waterWalkConn:Disconnect() waterWalkConn = nil end
            if v then
                waterWalkConn = RunService.Stepped:Connect(function()
                    for _, part in ipairs(workspace:GetDescendants()) do
                        if part:IsA("BasePart") and part.Material == Enum.Material.Water then
                            part.Material = Enum.Material.Plastic
                            part.Transparency = 0.5
                            part.Color = Color3.fromRGB(0, 150, 255)
                        end
                    end
                end)
            end
        end)

        createTPList() -- GỌI HÀM TẠO DANH SÁCH TP Ở ĐÂY

    elseif tabName == "TOOLS" then
        label("FARMING")
        createToggleSwitch("AUTO WIN", false, function(v) setAutoWin(v) end)
        createToggleSwitch("Auto Click", false, function(v) setAutoClick(v) end)
        createToggleSwitch("Auto Collect", false, function(v)
            autoCollectEnabled = v
            if v then
                task.spawn(function()
                    while autoCollectEnabled do
                        local char = LocalPlayer.Character
                        local hrp = char and char:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            for _, obj in ipairs(workspace:GetDescendants()) do
                                if obj:IsA("BasePart") then
                                    local n = obj.Name:lower()
                                    if n:find("coin") or n:find("cash") or n:find("gem") or n:find("drop") then
                                        hrp.CFrame = obj.CFrame
                                        task.wait(0.1)
                                    end
                                end
                            end
                        end
                        task.wait(0.5)
                    end
                end)
            end
        end)
        createToggleSwitch("Auto Farm (Basic)", false, function(v)
            if autoFarmConn then autoFarmConn:Disconnect() autoFarmConn = nil end
            if v then
                autoFarmConn = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, mob in ipairs(workspace:GetDescendants()) do
                            if mob:IsA("Model") and mob:FindFirstChild("Humanoid") and mob ~= char and mob.Humanoid.Health > 0 then
                                if mob:FindFirstChild("HumanoidRootPart") then
                                    hrp.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                                    local tool = char:FindFirstChildOfClass("Tool")
                                    if tool then tool:Activate() end
                                    break
                                end
                            end
                        end
                    end
                end)
            end
        end)
        
        label("SERVER")
        button("Rejoin Server", function()
            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
        end)
        button("Server Hop", function()
            task.spawn(function()
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                local res = HttpService:JSONDecode(game:HttpGet(url))
                if res and res.data then
                    for _, srv in ipairs(res.data) do
                        if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                            pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id, LocalPlayer) end)
                            break
                        end
                    end
                end
            end)
        end)
        
        label("UTILITY")
        createToggleSwitch("Fix Lag", false, function(v)
            if v then
                Lighting.GlobalShadows = false
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then obj.Enabled = false end
                end
            else Lighting.GlobalShadows = true end
        end)
        button("Teleport to Spawn", function()
            local char = LocalPlayer.Character
            if char then char:PivotTo(CFrame.new(0, 10, 0)) end
        end)

    elseif tabName == "MISC" then
        label("PLAYER")
        createToggleSwitch("God Mode", false, function(v)
            if godModeConn then godModeConn:Disconnect() godModeConn = nil end
            if v then
                godModeConn = RunService.Heartbeat:Connect(function()
                    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = hum.MaxHealth end
                end)
            end
        end)
        createToggleSwitch("Anti-AFK", false, function(v)
            if antiAfkConn then antiAfkConn:Disconnect() antiAfkConn = nil end
            if v then
                antiAfkConn = LocalPlayer.Idled:Connect(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
        createToggleSwitch("Anti-Void", false, function(v)
            if antiVoidConn then antiVoidConn:Disconnect() antiVoidConn = nil end
            if v then
                antiVoidConn = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and hrp.Position.Y < -50 then
                        hrp.CFrame = CFrame.new(0, 50, 0)
                    end
                end)
            end
        end)
        createToggleSwitch("Fake Headless", false, function(v)
            local char = LocalPlayer.Character
            if char then
                local head = char:FindFirstChild("Head")
                if head then
                    head.Transparency = v and 1 or 0
                    local face = head:FindFirstChild("face")
                    if face then face.Transparency = v and 1 or 0 end
                end
            end
        end)
        
        label("VISUAL")
        createToggleSwitch("Fullbright", false, function(v)
            if v then
                Lighting.Ambient = Color3.fromRGB(255, 255, 255)
                Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
            else
                Lighting.Ambient = Color3.fromRGB(70, 70, 70)
                Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
            end
        end)
        createToggleSwitch("No Fog", false, function(v)
            Lighting.FogEnd = v and 1e9 or 100000
            Lighting.FogStart = v and 1e9 or 0
        end)
        createToggleSwitch("Rainbow Char", false, function(v)
            if rainbowConn then rainbowConn:Disconnect() rainbowConn = nil end
            if v then
                rainbowConn = RunService.Heartbeat:Connect(function()
                    local char = LocalPlayer.Character
                    if char then
                        local t = tick()
                        for _, part in ipairs(char:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Color = Color3.fromHSV((t * 0.5 + part.Position.X * 0.1) % 1, 1, 1)
                            end
                        end
                    end
                end)
            end
        end)

    elseif tabName == "ESP" then
        label("PLAYER ESP")
        createToggleSwitch("ESP", false, function(v) espEnabled = v refreshESP() end)
        createToggleSwitch("Name ESP", false, function(v) nameESP = v refreshESP() end)
        createToggleSwitch("Distance ESP", false, function(v) distanceESP = v refreshESP() end)
    end
end

local tabs = {"MOVE", "TOOLS", "MISC", "ESP"}
local firstTabBtn = nil
for _, tabName in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0.24, 0, 1, 0)
    b.BackgroundColor3 = panel
    b.Text = tabName
    b.TextColor3 = white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.TextStrokeTransparency = 1
    b.ZIndex = 52
    b.Parent = tabBar
    corner(b, 6)
    if tabName == "MOVE" then firstTabBtn = b end
    b.Activated:Connect(function()
        for _, sibling in ipairs(tabBar:GetChildren()) do
            if sibling:IsA("TextButton") then sibling.BackgroundColor3 = panel; sibling.TextColor3 = white end
        end
        b.BackgroundColor3 = blue
        b.TextColor3 = dark
        showTab(tabName)
    end)
end

showTab("MOVE")
if firstTabBtn then
    firstTabBtn.BackgroundColor3 = blue
    firstTabBtn.TextColor3 = dark
end

-- NÚT MỞ MENU
local launcher = Instance.new("TextButton")
launcher.Size = UDim2.fromOffset(60, 34)
launcher.Position = UDim2.new(0, 12, 0.55, 0)
launcher.BackgroundColor3 = dark
launcher.Text = "MENU"
launcher.TextColor3 = blue
launcher.Font = Enum.Font.GothamBlack
launcher.TextSize = 12
launcher.TextStrokeTransparency = 1
launcher.ZIndex = 999
launcher.Parent = GUI
corner(launcher, 8)
makeDraggable(launcher, function() main.Visible = not main.Visible end)

-- LOGIC AUTO CLICK
task.spawn(function()
    while task.wait(0.05) do
        if autoClick and UserInputService:GetFocusedTextBox() == nil then
            local cam = workspace.CurrentCamera
            if cam then
                local x, y = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
                if mouse1click then pcall(mouse1click) end
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 1)
                    task.wait(0.005)
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 1)
                end)
                pcall(function()
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
                    task.wait(0.005)
                    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
                end)
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(x, y))
                end)
            end
        end
    end
end)

-- LOGIC AUTO WIN
task.spawn(function()
    while task.wait(0.5) do
        if autoWin then
            local c = LocalPlayer.Character 
            local r = c and c:FindFirstChild("HumanoidRootPart")
            if r then
                for _, x in pairs(workspace:GetDescendants()) do
                    if x:IsA("BasePart") or x:IsA("ClickDetector") or x:IsA("ProximityPrompt") then
                        local n = x.Name:lower()
                        local pName = x.Parent and x.Parent.Name:lower() or ""
                        
                        local function isShop(str)
                            return str:find("buy") or str:find("shop") or str:find("purchase") or str:find("spend") 
                                or str:find("sell") or str:find("upgrade") or str:find("store") or str:find("item")
                        end

                        if not isShop(n) and not isShop(pName) then
                            if n:find("win") or n:find("finish") or n:find("goal") or n:find("checkpoint") or (n:find("end") and not n:find("spend")) then
                                if x:IsA("ProximityPrompt") then pcall(function() fireproximityprompt(x) end)
                                elseif x:IsA("ClickDetector") then pcall(function() fireclickdetector(x) end)
                                elseif x:IsA("BasePart") then
                                    r.CFrame = x.CFrame + Vector3.new(0,5,0) 
                                    task.wait(0.1)
                                    if firetouchinterest then 
                                        task.spawn(function() firetouchinterest(r, x, 0) end) 
                                        task.wait(0.05) 
                                        task.spawn(function() firetouchinterest(r, x, 1) end) 
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if flying then stopFly() end
    if speedEnabled then applySpeed() end
    if espEnabled or nameESP or distanceESP then refreshESP() end
end)

GUI.Destroying:Connect(function()
    stopFly()
    if noclipConn then noclipConn:Disconnect() end
    if godModeConn then godModeConn:Disconnect() end
    if antiAfkConn then antiAfkConn:Disconnect() end
    if infJumpConn then infJumpConn:Disconnect() end
    if antiVoidConn then antiVoidConn:Disconnect() end
    if waterWalkConn then waterWalkConn:Disconnect() end
    if flyToMouseConn then flyToMouseConn:Disconnect() end
    if rainbowConn then rainbowConn:Disconnect() end
    if autoFarmConn then autoFarmConn:Disconnect() end
    clearESP()
end)
