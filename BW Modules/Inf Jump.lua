--[[
BEDWARS INFINITE JUMP (UNIVERSAL)
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
-----------------------------------
LINE: 7296 | SKIDDED FROM 
RAINWARE V6 NO RIGHTS RESERVED :D
]]
run(function()
    local InfiniteJump
    local Velocity
    InfiniteJump = vape.Categories.Blatant:CreateModule({
        Name = "InfiniteJump",
        Function = function(callback)
            if callback then
				InfiniteJump:Clean(inputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then return end
					if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then
						while inputService:IsKeyDown(Enum.KeyCode.Space) do
							local PrimaryPart = lplr.Character.PrimaryPart
							if entitylib.isAlive and PrimaryPart then
								PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
							end
							wait()
						end
					end
				end))
				if inputService.TouchEnabled then
					local Jumping = false
					local JumpButton = lplr.PlayerGui:WaitForChild("TouchGui"):WaitForChild("TouchControlFrame"):WaitForChild("JumpButton")
					
					InfiniteJump:Clean(JumpButton.MouseButton1Down:Connect(function()
						Jumping = true
					end))

					InfiniteJump:Clean(JumpButton.MouseButton1Up:Connect(function()
						Jumping = false
					end))

					InfiniteJump:Clean(runService.RenderStepped:Connect(function()
						if Jumping and entitylib.isAlive then
							local PrimaryPart = lplr.Character.PrimaryPart
							PrimaryPart.Velocity = vector.create(PrimaryPart.Velocity.X, Velocity.Value, PrimaryPart.Velocity.Z)
						end
					end))
				end
			end
        end,
        Tooltip = "Allows infinite jumping"
    })
    Velocity = InfiniteJump:CreateSlider({
        Name = 'Velocity',
        Min = 50,
        Max = 300,
        Default = 50
    })
end)
