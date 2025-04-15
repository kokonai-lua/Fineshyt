local player = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local aimRadius = 150
local isLocked = false
local currentTarget = nil

local function getClosestTarget()
    local closest = nil
    local shortest = aimRadius
    for _, plr in ipairs(game.Players:GetPlayers()) do
        if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
            local head = plr.Character.Head
            local screenPos, visible = camera:WorldToViewportPoint(head.Position)
            if visible then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

local function toggleLock()
    if isLocked then
        isLocked = false
        currentTarget = nil
        -- Remove UI text if Aimlock is off
        if game:GetService("ReplicatedStorage"):FindFirstChild("PlayerGui") then
            game:GetService("ReplicatedStorage"):WaitForChild("PlayerGui"):FindFirstChild("AimlockText"):Destroy()
        end
    else
        local target = getClosestTarget()
        if target then
            currentTarget = target
            isLocked = true
            -- Display UI text showing locked target
            local label = Instance.new("TextLabel")
            label.Text = "Locked onto: " .. target.Name
            label.Size = UDim2.new(0, 300, 0, 50)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.Name = "AimlockText"
            label.Parent = game:GetService("ReplicatedStorage"):WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
        else
            local label = Instance.new("TextLabel")
            label.Text = "No target found"
            label.Size = UDim2.new(0, 300, 0, 50)
            label.Position = UDim2.new(0, 10, 0, 10)
            label.Name = "AimlockText"
            label.Parent = game:GetService("ReplicatedStorage"):WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
        end
    end
end

local button = Instance.new("TextButton")
button.Text = "Toggle Aimlock"
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0, 10, 0, 60)
button.Parent = game:GetService("ReplicatedStorage"):WaitForChild("PlayerGui"):FindFirstChild("ScreenGui")
button.MouseButton1Click:Connect(toggleLock)

RunService.RenderStepped:Connect(function()
    if isLocked and currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("Head") then
        local headPos = currentTarget.Character.Head.Position
        camera.CFrame = CFrame.new(camera.CFrame.Position, headPos)
    end
end)
