--[[
BEDWARS JADE DISABLER
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
run(function()
    local Disabler
    local speedThread

    Disabler = vape.Categories.Minigames:CreateModule({
        Name = "Disabler",
        Function = function(call)
            if call then
                pcall(function()
                    bedwars.AbilityController:useAbility("jade_hammer_jump")
                end)

                if speedThread then
                    task.cancel(speedThread)
                end

                speedThread = task.spawn(function()
                    local plr = game.Players.LocalPlayer
                    local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
                    if not hum then return end

                    hum.WalkSpeed = 50

                    local t = 0
                    while t < 3 and Disabler.Enabled and vape and vape.LOADED do
                        task.wait(0.05)
                        t += 0.05
                    end

                    if hum and hum.Parent and Disabler.Enabled and vape and vape.LOADED then
                        hum.WalkSpeed = 23
                    end
                end)

            else
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
