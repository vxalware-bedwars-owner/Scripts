-- loads Orion
local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/thanhdat4461/GUI-Library/refs/heads/main/Orion%20Library.lua", true))()

-- Window
local Window = OrionLib:MakeWindow({
	Name = "Orion Example",
	HidePremium = false,
	SaveConfig = false,
	ConfigFolder = "OrionExample",
	IntroText = "Example UI by SynthX"
})

-- Tab
local MainTab = Window:MakeTab({
	Name = "Features",
	Icon = "rbxassetid://10709762727",
	PremiumOnly = false
})

-- Section
local Section = MainTab:AddSection({
	Name = "Section"
})

-- Button
MainTab:AddButton({
	Name = "Button",
	Callback = function()
		print("Clicked button")
	end    
})

-- Toggle
MainTab:AddToggle({
	Name = "This is a toggle!",
	Default = false,
	Callback = function(state)
		if state then
			print("executed")
		else
			print("unexecuted")
		end
	end    
})

-- Colourpicker
MainTab:AddColorpicker({
	Name = "Colorpicker",
	Default = Color3.fromRGB(0, 0, 255),
	Callback = function(color)
		print("color: " .. tostring(color))
	end	  
})

-- Slider
MainTab:AddSlider({
	Name = "WalkSpeed",
	Min = 16,
	Max = 100,
	Default = 21,
	Color = Color3.fromRGB(0, 0, 255),
	Increment = 1,
	ValueName = "speed",
	Callback = function(value)
		local player = game.Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		
		if humanoid then
			humanoid.WalkSpeed = value
			print("WalkSpeed set to:", value)
		else
			warn("Humanoid not found")
		end
	end    
})

-- Input
MainTab:AddTextbox({
	Name = "Textbox",
	Default = "Input stuff",
	TextDisappear = false,
	Callback = function(Value)
		print(Value)
	end	  
})

-- Dropdown
MainTab:AddDropdown({
	Name = "Dropdown",
	Default = "None",
	Options = {"None", "Example 1"},
	Callback = function(Value)
		if Value == "None" then
			print("None")
		elseif Value == "Example 1" then
			print("Example 1")
		end
	end    
})

-- Credits Tab
local CreditsTab = Window:MakeTab({
	Name = "Credits",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

-- Paragraph
CreditsTab:AddParagraph("Credits", "This Library is made by Sirius. Custom source by thanhdat4461 and example by SynthX")

-- Notification
OrionLib:MakeNotification({
	Name = "Finished Loading!!",
	Content = "Thank you for using Orion Library. Press Left Control to toggle GUI",
	Image = "rbxassetid://10709762727",
	Time = 5
})

-- Finish script
OrionLib:Init()
-- This is just an example. Official doccumentation with other features may be found at https://github.com/jensonhirst/Orion/blob/main/Documentation.md
