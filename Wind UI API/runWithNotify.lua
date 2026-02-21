-- runWithNotify API
local _runWithNotify_firstRun = {}
local function runWithNotify(title, fn, opts)
    opts = opts or {}
    local kind = opts.kind
    local getLabel = opts.getLabel
    local getState = opts.getState
    local getValue = opts.getValue
    local suppressNone = opts.suppressNone

    -- Silent run | Error run
    if not _runWithNotify_firstRun[title] then
        _runWithNotify_firstRun[title] = true

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
                Content = "Successfully executed "..tostring(title),
                Duration = 1.5,
            })
        else
            WindUI:Notify({
                Title = "Success",
                Content = "Successfully unexecuted "..tostring(title),
                Duration = 1.5,
            })
        end
        return
    end

    -- Success run | Slider
    if kind == "slider" and type(getValue) == "function" then
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
        return
    end

    -- Success run | Universal
    WindUI:Notify({
        Title = "Success",
        Content = "Successfully ran "..tostring(title),
        Duration = 1.5,
    })
end
