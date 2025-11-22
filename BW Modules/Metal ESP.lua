--[[
METAL DETECTOR ESP
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
run(function()
    local MetalESP

    MetalESP = vape.Categories.Minigames:CreateModule({
        Name = "MetalESP",
        Function = function(call)
            if call then
                loadstring(game:HttpGet("https://raw.githubusercontent.com/void2realyt/RainWare-V6-Vxpe-Loader-Script/refs/heads/main/RainWare%20V6%20Metal%20Detector%20ESP",true))()
            end
        end,
        Tooltip = "Metal Detector ESP"
    })
end)
-- YOU CANNOT UNEXECUTE THIS SCRIPT BTW
