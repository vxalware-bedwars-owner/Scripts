runcode(function()
    local MetalESP

    MetalESP = vape.Categories.Minigames:CreateModule({
        Name = "MetalESP"
        Function = function(call)
            if call then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/void2realyt/RainWare-V6-Vxpe-Loader-Script/refs/heads/main/RainWare%20V6%20Metal%20Detector%20ESP",true))()
            end
        end,
        HoverText = "Metal Detector ESP"
    })
end)
