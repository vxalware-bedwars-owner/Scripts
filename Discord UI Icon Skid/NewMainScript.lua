--> Services
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

--> MainScript
loadstring(game:HttpGet("https://raw.githubusercontent.com/vxalware-bedwars-owner/Scripts/refs/heads/main/Discord%20UI%20Icon%20Skid/MainScript.lua"))()

--> Variables
local DiscordUI = CoreGui:FindFirstChild("Discord")
local DiscordUIMainFrame = DiscordUI:FindFirstChild("MainFrame")

--> UI
DiscordUI.Enabled = false
DiscordUIMainFrame.Position = UDim2.new(0.5, 0, -1, 0)

--> Toggle
local ToggleState = false

--> Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = CoreGui
ScreenGui.Name = "ScriptHub V3 Toggle Button Skid"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999
ScreenGui.Enabled = true 
ScreenGui.IgnoreGuiInset = false

--> Create ImageButton
local imageButton = Instance.new("ImageButton")
imageButton.Parent = ScreenGui
imageButton.Name = "Toggle Button"
imageButton.Position = UDim2.new(0.5, 0, 2, 0)
imageButton.Size = UDim2.new(0, 50, 0, 50)
imageButton.Image = "rbxassetid://6031075938"
imageButton.BackgroundTransparency = 1
imageButton.AnchorPoint = Vector2.new(0.5, 0.5)
imageButton.Draggable = true
imageButton.ZIndex = 999

--> Create UICorner
local imageButtonUICorner = Instance.new("UICorner")
imageButtonUICorner.Parent = imageButton
imageButtonUICorner.CornerRadius = UDim.new(1, 0)

--> Blur Effect
local Blur = Instance.new("BlurEffect")
Blur.Name = "Blur Screen Effect"
Blur.Size = 0
Blur.Parent = Lighting

--> Blur Tween
local BlurIn = TweenService:Create(Blur, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = 24})
local BlurOut = TweenService:Create(Blur, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Size = 0})

--> Animation
local ButtonTween = TweenService:Create(imageButton, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.035, 0)})
ButtonTween:Play()

--> Hide Button Blur Effect
ButtonTween.Completed:Connect(function()
    BlurOut:Play()
end)

--> Animation
local ShowUI = TweenService:Create(DiscordUIMainFrame, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, 0.5, 0)})
local HideUI = TweenService:Create(DiscordUIMainFrame, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = UDim2.new(0.5, 0, -1, 0)})

--> Toggle UI
imageButton.MouseButton1Click:Connect(function()
    ToggleState = not ToggleState
    
    if ToggleState then
        DiscordUI.Enabled = true
        ShowUI:Play()
        BlurIn:Play()
    else
        HideUI:Play()
        BlurOut:Play()
        
        HideUI.Completed:Connect(function()
            if not ToggleState then
                DiscordUI.Enabled = false
            end
        end)
    end
end)
