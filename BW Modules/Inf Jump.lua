--[[
BEDWARS INFINITE JUMP (UNIVERSAL)
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
run(function()
    local connection

    InfJump = vape.Categories.Blatant:CreateModule({
        Name = "Inf Jump",
        Function = function(enabled)
            if enabled then
                connection = game:GetService("UserInputService").JumpRequest:Connect(function()
                    local player = game:GetService("Players").LocalPlayer
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            else
                if connection then
                    connection:Disconnect()
                    connection = nil
                end
            end
        end,
        Tooltip = "Jump Infinitely!"
    })
end)
