local Version = "1.6.61"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. Version .. "/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "Wind UI API",
    Icon = "moon-star",
    Author = "SynthX",
    Folder = "WindUIAPIs",
    
    Size = UDim2.fromOffset(580, 460),
    MinSize = Vector2.new(560, 350),
    MaxSize = Vector2.new(850, 560),
    Transparent = false,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = true,
    
    User = {
        Enabled = true,
        Anonymous = true,
        Callback = function()
            print("user check")
        end,
    },
})

Window:SetToggleKey(Enum.KeyCode.K)
Window:SetIconSize(26)
Window:EditOpenButton({
    Title = "Open Script",
    Icon = "monitor",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("FFFFFF"), 
        Color3.fromHex("FFFFFF")
    ),
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})

-- safeWriteConfig API
local HttpService = game:GetService("HttpService")
local folderName = "WindUIAPIs"
local configFilePath = folderName .. "/WUAConfig.json"

local hasFileApi = (type(isfolder) == "function")
               and (type(makefolder) == "function")
               and (type(isfile) == "function")
               and (type(readfile) == "function")
               and (type(writefile) == "function")

local config = {
    dropdown = {},
    toggle = {},
    slider = {},
}

local function safeWriteConfig()
    if not hasFileApi then return false end
    local ok, err = pcall(function()
        writefile(configFilePath, HttpService:JSONEncode(config))
    end)
    return ok
end

local function loadConfig()
    if not hasFileApi then return end
    if not isfolder(folderName) then
        pcall(makefolder, folderName)
    end
    if isfile(configFilePath) then
        local ok, data = pcall(readfile, configFilePath)
        if ok and data then
            local succ, decoded = pcall(HttpService.JSONDecode, HttpService, data)
            if succ and type(decoded) == "table" then
                -- keep defaults
                config.dropdown = decoded.dropdown or config.dropdown
                config.toggle = decoded.toggle or config.toggle
                config.slider = decoded.slider or config.slider
            end
        end
    else
        safeWriteConfig()
    end
end

loadConfig()

if not hasFileApi then
    WindUI:Notify({
        Title = "Config Disabled",
        Content = "API Unreachable — config will not be saved.",
        Duration = 5,
        Icon = "x",
    })
end

-- runWithNotify API
local _APIFirstRun = {}
local _sliderNotifHandler = {}
local function runWithNotify(title, fn, opts)
    opts = opts or {}
    local kind = opts.kind
    local getLabel = opts.getLabel
    local getState = opts.getState
    local getValue = opts.getValue
    local suppressNone = opts.suppressNone

    -- Silent run | Error run
    if not _APIFirstRun[title] then
        _APIFirstRun[title] = true

        if kind == "dropdown" or kind == "toggle" then
            local ok, err = pcall(fn)
            if not ok then
                WindUI:Notify({
                    Title = "Error",
                    Content = "Failed to run "..tostring(title).."\n"..tostring(err),
                    Duration = 5,
                    Icon = "x",
                })
            end
            return
        end
    end

    -- Normal run | Error run
    local ok, err = pcall(fn)
    if not ok then
        WindUI:Notify({
            Title = "Error",
            Content = "Failed to run "..tostring(title).."\n"..tostring(err),
            Duration = 5,
            Icon = "x",
        })
        return
    end

    -- Success run | Dropdown
    if kind == "dropdown" and type(getLabel) == "function" then
        local label = getLabel()
        if suppressNone and tostring(label) == "None" then
            return
        end
        WindUI:Notify({
            Title = "Success",
            Content = "Successfully executed "..tostring(label),
            Duration = 1.5,
        })
        return
    end

    -- Success run | Toggle
    if kind == "toggle" and type(getState) == "function" then
        local state = getState()
        if state then
            WindUI:Notify({
                Title = "Success",
                Content = "Successfully enabled "..tostring(title),
                Duration = 1.5,
            })
        else
            WindUI:Notify({
                Title = "Success",
                Content = "Successfully disabled "..tostring(title),
                Duration = 1.5,
            })
        end
        return
    end

    -- Success run | Slider
    if kind == "slider" and type(getValue) == "function" then
        if _sliderNotifHandler[title] then
            task.cancel(_sliderNotifHandler[title])
        end

        _sliderNotifHandler[title] = task.delay(0.25, function()
            local value = getValue()
            local valueStr = tostring(value)
            if type(value) == "number" then
                valueStr = tostring(tonumber(string.format("%.6f", value))):gsub("%.?0+$", "")
            end

            WindUI:Notify({
                Title = "Success",
                Content = tostring(title) .. " set to " .. valueStr,
                Duration = 1.5,
            })

            _sliderNotifHandler[title] = nil
        end)
        return
    end

    -- Success run | Universal
    WindUI:Notify({
        Title = "Success",
        Content = "Successfully ran "..tostring(title),
        Duration = 1.5,
    })
end

-- Main tab
local MainTab = Window:Tab({ Title = "Main", Icon = "circle-user-round" })

-- Buttons
local Button = MainTab:Button({
    Title = "Your title",
    Callback = function()
        runWithNotify("Your message", function()
            print("Place your code here")
        end)
    end
})

-- Toggles
local MainSaved = config.toggle["example"]
local Toggle = MainTab:Toggle({
    Title = "Your title",
    Type = "Toggle",
    Flag = "flagexample",
    Default = MainSaved or false,
    Callback = function(state)
        runWithNotify("Your message", function()
            if state then
                print("Enabled")
            else
                print("Disabled")
            end
        end, {
            kind = "toggle",
            getState = function() return state end,
        })
        config.toggle["example"] = (state == true)
        safeWriteConfig()

        task.defer(function()
            pcall(function()
                local saved = config.toggle["example"]
                if type(saved) == "boolean" then
                    if Toggle.Set then
                        Toggle:Set(saved)
                    elseif Toggle.SetValue then
                        Toggle:SetValue(saved)
                    end
                end
            end)
        end)
    end
})

-- Dropdowns
local MainSaved = config.dropdown["example"]
local Dropdown = MainTab:Dropdown({
    Title = "Your title",
    Values = { "eg1", "eg2", "eg3" },
    Value = MainSaved or "None",
    Callback = function(option)
        runWithNotify("your message", function()
            if option == "eg1" then
                print("eg1")
            elseif option == "eg2" then
                print("eg2")
            elseif option == "eg3" then
                print("eg3")
            end
        end, {
            kind = "dropdown",
            getLabel = function() return option end,
            suppressNone = true,
        })
        config.dropdown["example"] = option
        safeWriteConfig()
    end
})

-- Sliders
local MainSaved = config.slider["example"]
local Slider = MainTab:Slider({
    Title = "Your title",
    Step = 10,
    Value = {
        Min = 10,
        Max = 100,
        Default = MainSaved or 50,
    },
    Callback = function(value)
        runWithNotify("Your message", function()
            print(value)
        end, {
            kind = "slider",
            getValue = function() return value end
        })
        config.slider["example"] = value
        safeWriteConfig()
    end
})

-- Credits tab
local CreditsTab = Window:Tab({ Title = "Credits", Icon = "star" })
local Paragraph = CreditsTab:Paragraph({
    Title = "Wind UI",
    Desc = "This script is made by SynthX. All credits go to footagesus for making the UI Library",
    Locked = false,
})

local Paragraph = CreditsTab:Paragraph({
    Title = "API",
    Desc = "All credits go to SynthX & ANerd for writing out the Wind UI API code",
    Locked = false,
})

local Paragraph = CreditsTab:Paragraph({
    Title = "Keybind",
    Desc = "If you didn't read the message at the start of the script execution, press 'K' to toggle the GUI",
    Locked = false,
})

-- Notification
WindUI:Notify({
    Title = "Successfully Loaded!",
    Content = "Wind UI API Script",
    Duration = 5,
    Icon = "check"
})
