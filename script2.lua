-- Notruf Hamburg Loader mit Fluent UI, Blacklist, Bypass & Key-System
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- URLs
local KEY_URL = "https://nhscripts.vercel.app/key.json"
local BYPASS_URL = "https://nhscripts.vercel.app/bypass.json"
local BLACKLIST_URL = "https://nhscripts.vercel.app/api/blacklist"

-- Fluent UI laden
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "🔐 Fly to Space Loader",
    SubTitle = "Key, Whitelist & Blacklist System",
    TabWidth = 120,
    Size = UDim2.fromOffset(420, 320),
    Acrylic = true, -- schöner Blur-Effekt
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl
})

-- Tabs
local Main = Window:AddTab({ Title = "Key System", Icon = "🔑" })

-- Status-Variablen
local isBypass = false
local isBlacklisted = false
local reason = nil
local remoteKey = nil

-- Blacklist-Check
pcall(function()
    local data = HttpService:JSONDecode(game:HttpGet(BLACKLIST_URL))
    for _, entry in ipairs(data) do
        if tonumber(entry.userId) == player.UserId then
            isBlacklisted = true
            reason = entry.reason or "Kein Grund angegeben"
            break
        end
    end
end)

if isBlacklisted then
    Main:AddParagraph({
        Title = "🚫 Zugriff verweigert",
        Content = "Du bist auf der Blacklist!\nGrund: " .. reason
    })
    Fluent:Notify({
        Title = "Blacklist",
        Content = "Dein Zugriff wurde blockiert.",
        SubContent = reason,
        Duration = 10
    })
    return
end

-- Bypass-Check
pcall(function()
    local data = HttpService:JSONDecode(game:HttpGet(BYPASS_URL))
    for _, id in ipairs(data) do
        if tonumber(id) == player.UserId then
            isBypass = true
            break
        end
    end
end)

-- Key vom Server abrufen
pcall(function()
    local data = HttpService:JSONDecode(game:HttpGet(KEY_URL))
    remoteKey = data and data.key and tostring(data.key):lower() or nil
end)

-- UI Elemente
local keyInput = Main:AddInput("KeyInput", {
    Title = "Key Eingabe",
    Default = "",
    Placeholder = isBypass and "Whitelist aktiv – kein Key nötig" or "Key hier eingeben...",
    Numeric = false,
    Finished = false,
    Callback = function() end
})

local confirmBtn = Main:AddButton({
    Title = "✅ Bestätigen",
    Description = "Lade das Haupt-Script mit gültigem Key oder Whitelist.",
    Callback = function()
        if isBypass then
            Fluent:Notify({
                Title = "Whitelist",
                Content = "Du bist whitelisted!",
                Duration = 5
            })
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sylolua/PoopHub/refs/heads/main/Loader", true))()
            return
        end

        local inputKey = keyInput.Value:lower():gsub("%s+", "")
        if remoteKey and inputKey == remoteKey then
            Fluent:Notify({
                Title = "Key akzeptiert ✅",
                Content = "Lade Loader...",
                Duration = 5
            })
            loadstring(game:HttpGet("https://raw.githubusercontent.com/sylolua/PoopHub/refs/heads/main/Loader", true))()
        else
            Fluent:Notify({
                Title = "❌ Falscher Key",
                Content = "Bitte überprüfe deine Eingabe!",
                Duration = 5
            })
        end
    end
})

-- Info-Sektion
Main:AddParagraph({
    Title = "ℹ️ Info",
    Content = "UserID: " .. player.UserId .. "\n" ..
              (isBypass and "✅ Whitelist aktiv" or "🔑 Key erforderlich") ..
              "\nFalls du Probleme hast, melde dich beim Support."
})

-- Fenster anzeigen
Window:SelectTab(1)
Fluent:Notify({
    Title = "Fly to Space Loader",
    Content = "Fluent UI erfolgreich geladen!",
    Duration = 4
})
