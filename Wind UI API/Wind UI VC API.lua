-- WindUI VC (Version Check) API
local HttpService = game:GetService("HttpService")
local Version = "6.7.41" -- put your version number here
local folderName = "foldername" -- put the name you gave for your Wind UI folder
local versionFilePath = folderName .. "/version.json" -- put your file name (no spaces)
local windUIFolder = "WindUI"

local hasFileApi = (type(isfolder) == "function")
               and (type(makefolder) == "function")
               and (type(isfile) == "function")
               and (type(readfile) == "function")
               and (type(writefile) == "function")
               and (type(delfolder) == "function")

local function safeMakeFolder(name)
    if not hasFileApi then return false end
    return pcall(makefolder, name)
end

local function safeDelFolder(name)
    if not hasFileApi then return false end
    return pcall(delfolder, name)
end

local function writeVersionFile()
    if not hasFileApi then return false end
    local ok, err = pcall(function()
        if not isfolder(folderName) then
            makefolder(folderName)
        end
        writefile(versionFilePath, HttpService:JSONEncode({ version = tostring(Version) }))
    end)
    return ok
end

if not hasFileApi then
    print("[WindUI VC API] error 503: WindUI VC API Unreachable! Please create a support ticket in our discord server!")
else
    if not isfile(versionFilePath) then
        pcall(function()
            safeDelFolder(folderName)
            safeDelFolder(windUIFolder)
            safeMakeFolder(folderName)
            writeVersionFile()
        end)
        print("[WindUI VC API] Successfully implemented Version check!")
    else
        local ok, data = pcall(readfile, versionFilePath)
        local parsed = nil
        if ok and data then
            local succ, dec = pcall(HttpService.JSONDecode, HttpService, data)
            if succ and type(dec) == "table" then
                parsed = dec
            end
        end

        if not parsed or tostring(parsed.version) ~= tostring(Version) then
            pcall(function()
                safeDelFolder(folderName)
                safeDelFolder(windUIFolder)
                safeMakeFolder(folderName)
                writeVersionFile()
            end)
            print("[WindUI VC API] Successfully updated script to Version " .. Version)
        else
            print("[WindUI VC API] Script is running on the latest Version!")
        end
    end
end
