# Wind UI API
*An essential add-on to your scripts using the Wind UI Library*

## Introduction
The **Wind UI API** enhances your scripts by providing:
* **Config saving**: Automatically save and load user preferences for the supported UI elements.
* **Notifications**: Display customizable notifications to the player from your script.

This API is designed to be simple, lightweight, and fully compatible with Wind UI.

## Installation

1. Copy the code from this repository.
2. Customize the API code to your preferences
3. Place the code after your 'Window' settings in Wind UI.

## APIs
### 1. `runWithNotify`
Display notifications for elements on success or failure.

### 2. `safeWriteConfig`
Automatically saves and loads settings for supported UI elements.

## Element examples

#### Buttons:
```lua
local Button = MainTab:Button({
    Title = "Your title",
    Callback = function()
        runWithNotify("Your message", function()
            print("Place your code here")
        end)
    end
})
```

#### Toggles:
```lua
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
```

#### Dropdowns:
```lua
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
```

#### Sliders:
```lua
local MainSaved = config.slider["example"]
local Slider = MainTab:Slider({
    Title = "Your title",
    Min = 10,
    Max = 100,
    Default = MainSaved or 50,
    Increment = 10,
    Callback = function(value)
        runWithNotify("Your message", function()
            print(value)
        end, {
            kind = "slider",
            getValue = function() return value end
        })
        config.slider["example"] = value
        safeWriteConfig()

        task.defer(function()
            pcall(function()
                local saved = config.slider["example"]
                if type(saved) == "number" then
                    if Slider.Set then
                        Slider:Set(saved)
                    elseif Slider.SetValue then
                        Slider:SetValue(saved)
                    end
                end
            end)
        end)
    end
})
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for:

* Bug fixes
* Feature requests

---
