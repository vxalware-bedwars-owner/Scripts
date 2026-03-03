--> Discord UI Dependencies
local DiscordLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/discord"))()
local Window = DiscordLib:Window("Discord UI Icon Skid from ScriptHub V3")

--> Primary & Secondary tabs
local Server = Window:Server("Features", "http://www.roblox.com/asset/?id=6031075938")
local MainTab = Server:Channel("Main")

-- Button
MainTab:Button("Button", function()
  print("Clicked button")
end)

-- Toggle
MainTab:Toggle("Toggle", false, function(state)
	if state then
		print("executed")
	else
		print("unexecuted")
	end
end)

-- Slider
MainTab:Slider("Slider (WalkSpeed)", 16, 100, 21, function(value)
	local Players = game:GetService("Players")
	local player = Players.LocalPlayer
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.WalkSpeed = value
		print("WalkSpeed set to:", value)
	end
end)

-- Dropdown
MainTab:Dropdown("Dropdown", { "None", "Example 1" }, function(option)
	if option == "None" then
		print("None")
	elseif option == "Example 1" then
		print("Example 1")
	end
end)

-- Colorpicker
MainTab:Colorpicker("Colorpicker", Color3.fromRGB(255, 1, 1), function(color)
	print("color: " .. tostring(color))
end)

-- Textbox
MainTab:Textbox("Textbox", "Enter text...", true, function(input)
	print("text entered: " .. input)
end)

--> Credits tab & Label example
local CreditsTab = Server:Channel("Credits")
CreditsTab:Label("This example is made by SynthX. Script provided by dawidscripts (library author).") -- Labe;

-- Notification
CreditsTab:Button("Notification", function()
	DiscordLib:Notification("Notification", "This is a notification", "Okay")
end)
-- This is just an example. Official example with other features may be found at https://github.com/weakhoes/Roblox-UI-Libs/blob/main/Discord%20UI%20Lib/Discord%20Lib%20Example.lua
