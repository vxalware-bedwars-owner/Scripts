runcode(function()
    local Disabler

    Disabler = vape.Categories.Minigames:CreateModule({
        Name = "Disabler"
        Function = function(call)
            if call then
                bedwars.AbilityController:useAbility("jade_hammer_jump")
                JadeTP.ToggleButton(false)
                game.Players.LocalPlayer.Character.Humanoid.Walkspeed = 50
                wait(3)
                game.Players.LocalPlayer.Character.Humanoid.Walkspeed = 23
            end
        end,
        HoverText = "Jade Disabler"
    })
end)
