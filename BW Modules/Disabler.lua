runcode(function()
    local Disabler

    Disabler = vape.Categories.Minigames:CreateModule({
        Name = "Disabler",
        Function = function(call)
            if call then
                pcall(function()
                    bedwars.AbilityController:useAbility("jade_hammer_jump")
                end)

                local hum = game.Players.LocalPlayer.Character
                    and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum.WalkSpeed = 50
                    task.wait(3)
                    hum.WalkSpeed = 23
                end
            end
        end,
        HoverText = "Jade Disabler"
    })
end)
