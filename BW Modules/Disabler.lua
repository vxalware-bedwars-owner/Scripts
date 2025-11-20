--[[
BEDWARS JADE DISABLER
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
runcode(function()
    local Disabler
    local speedThread

    Disabler = vape.Categories.Minigames:CreateModule({
        Name = "Disabler",
        Function = function(call)
            if call then
                -- Use Jade ability safely
                pcall(function()
                    bedwars.AbilityController:useAbility("jade_hammer_jump")
                end)

                -- Kill old thread if exists
                if speedThread then
                    task.cancel(speedThread)
                end

                -- Thread so disabling/uninjecting doesn’t break anything
                speedThread = task.spawn(function()
                    local plr = game.Players.LocalPlayer
                    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then return end

                    hum.WalkSpeed = 50

                    -- Wait 3 seconds OR end early if module disabled / vape uninjects
                    local t = 0
                    while t < 3 and Disabler.Enabled and vape and vape.LOADED do
                        task.wait(0.05)
                        t += 0.05
                    end

                    -- If still valid, restore speed
                    if hum and hum.Parent and Disabler.Enabled and vape and vape.LOADED then
                        hum.WalkSpeed = 23
                    end
                end)

            else
                -- On disable: cancel thread & restore WS safely
                if speedThread then
                    task.cancel(speedThread)
                    speedThread = nil
                end

                local plr = game.Players.LocalPlayer
                local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = 23
                end
            end
        end,
        HoverText = "Jade Disabler"
    })
end)
