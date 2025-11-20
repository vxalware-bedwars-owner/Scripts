run(function()
    local InfJump
    local connection

    InfJump = vape.Categories.Minigames:CreateModule({
        Name = "InfJump",
        Function = function(call)
            if enabled then
                connection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid then
                        humanoid.Jump = true
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end,
        HoverText = "Jump Infinitely!"
    })
end)
