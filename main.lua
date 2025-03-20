local replicatedStorage = game:GetService("ReplicatedStorage")
local throwRemote = replicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("Knit")
    :WaitForChild("Services")
    :WaitForChild("BallService")
    :WaitForChild("RE")
    :FindFirstChild("Throw") -- Use FindFirstChild to avoid errors

if not throwRemote then
    warn("Throw Remote not found! Script will not run.")
    return
end

local players = game:GetService("Players")
local player = players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local workspace = game:GetService("Workspace")

local autoShootEnabled = true -- Toggle ON/OFF
local delayBetweenShots = 0.5 -- Delay between each shot

-- Function to find the closest hoop
local function getClosestHoop()
    local hoopsFolder = workspace:FindFirstChild("Hoops")
    if not hoopsFolder then 
        warn("Hoops folder not found!")
        return nil 
    end

    local closestHoop = nil
    local closestDistance = math.huge
    local ball = character:FindFirstChild("Ball")

    if ball then
        local ballPosition = ball.Position
        for _, hoop in ipairs(hoopsFolder:GetChildren()) do
            if hoop:IsA("BasePart") then -- Ensure it's a valid part
                local distance = (hoop.Position - ballPosition).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestHoop = hoop
                end
            end
        end
    else
        warn("Ball not found in character!")
    end

    if closestHoop then
        print("Closest hoop found at:", closestHoop.Position)
    else
        warn("No valid hoop found!")
    end

    return closestHoop
end

-- Function to calculate shot direction
local function getShotDirection()
    local ball = character:FindFirstChild("Ball")
    local closestHoop = getClosestHoop()
    
    if ball and closestHoop then
        local direction = (closestHoop.Position - ball.Position).unit -- Normalize direction
        print("Shot direction calculated:", direction)
        return Vector2.new(direction.X, direction.Y) -- Convert to 2D Vector
    end
    
    warn("Failed to get shot direction!")
    return nil
end

-- Function to check if player has the ball
local function hasBall()
    local ball = character:FindFirstChild("Ball")
    if ball then
        print("Ball detected in character.")
        return true
    else
        print("Ball not found.")
        return false
    end
end

-- Silent Aim Function (Auto-aims at the closest hoop)
local function silentAim()
    print("Silent Aim started!")
    
    while autoShootEnabled do
        if hasBall() then
            local shotDirection = getShotDirection()
            
            if throwRemote and shotDirection then
                print("Firing shot at:", shotDirection)
                throwRemote:FireServer(shotDirection)
            else
                warn("Error: throwRemote or shotDirection is nil")
            end

            task.wait(delayBetweenShots)
        end
        task.wait(0.1)
    end
end

task.spawn(silentAim)
