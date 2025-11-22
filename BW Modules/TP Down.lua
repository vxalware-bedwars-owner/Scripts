--[[
BEDWARS UNIVERSAL TP DOWN
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
run(function()
    local TPDown
    local tpConnection

    TPDown = vape.Categories.Minigames:CreateModule({
        Name = "TPDown",
        Function = function(call)
            if call then
                local Players = game:GetService("Players")
                local RunService = game:GetService("RunService")
                local workspace = game:GetService("Workspace")

                local player = Players.LocalPlayer
                local AIRBORNE_THRESHOLD = 2.3
                local HOLD_TIME = 0.1
                local RAY_LENGTH = 500
                local SURFACE_OFFSET = 3

                local airborneStart = nil
                local isBusy = false

                local function getRoot()
                    local character = player.Character
                    if not character then return nil end
                    return character:FindFirstChild("HumanoidRootPart")
                end

                local function getHumanoid()
                    local character = player.Character
                    if not character then return nil end
                    return character:FindFirstChildOfClass("Humanoid")
                end

                local function isOnGround(humanoid)
                    return humanoid and humanoid.FloorMaterial ~= Enum.Material.Air
                end

                tpConnection = RunService.Heartbeat:Connect(function()
                    if isBusy then return end

                    local root = getRoot()
                    local humanoid = getHumanoid()
                    if not root or not humanoid then
                        airborneStart = nil
                        return
                    end

                    if isOnGround(humanoid) then
                        airborneStart = nil
                        return
                    end

                    if not airborneStart then
                        airborneStart = tick()
                        return
                    end

                    if tick() - airborneStart < AIRBORNE_THRESHOLD then
                        return
                    end

                    local origin = root.Position
                    local params = RaycastParams.new()
                    params.FilterType = Enum.RaycastFilterType.Blacklist
                    params.FilterDescendantsInstances = { player.Character }
                    params.IgnoreWater = true

                    local result = workspace:Raycast(origin, Vector3.new(0, -RAY_LENGTH, 0), params)

                    if not result or not result.Instance or not result.Instance.CanCollide then
                        airborneStart = nil
                        return
                    end

                    isBusy = true
                    local originalCFrame = root.CFrame
                    local hitPos = result.Position
                    local targetCFrame = CFrame.new(hitPos + Vector3.new(0, SURFACE_OFFSET, 0))

                    local ok, err = pcall(function()
                        if not player.Character then return end
                        root.CFrame = targetCFrame
                        task.wait(HOLD_TIME)
                        if root and root.Parent then
                            root.CFrame = originalCFrame
                        end
                    end)

                    if not ok then
                        warn("script error:", err)
                    end

                    airborneStart = nil
                    isBusy = false
                end)
            else
                if tpConnection then
                    tpConnection:Disconnect()
                    tpConnection = nil
                end
            end
        end,
        Tooltip = "Sends you to the ground every 2.3 seconds"
    })
end)
