-- Craquer par Korioz#3310 --
-- Debug + ajout du BanSql par Pots#0106 --

local BanList            = {}
local BanListLoad        = false
CreateThread(function()
        while true do
                Wait(1000)
        if BanListLoad == false then
                        loadBanList()
                        if BanList ~= {} then
                                BanListLoad = true
                        end
                end
        end
end)

CreateThread(function()
        while true do
                Wait(600000)
        if BanListLoad == true then
                        loadBanList()
                end
        end
end)

RegisterServerEvent('aopkfgebjzhfpazf77')
AddEventHandler('aopkfgebjzhfpazf77', function(reason,servertarget)
        local license,identifier,liveid,xblid,discord,playerip,target
        local duree     = 0
        local reason    = reason

        if not reason then reason = "Auto Anti-Cheat" end

        if tostring(source) == "" then
                target = tonumber(servertarget)
        else
                target = source
        end

        if target and target > 0 then
                local ping = GetPlayerPing(target)

                if ping and ping > 0 then
                        if duree and duree < 365 then
                                local sourceplayername = "AntiCheat"
                                local targetplayername = GetPlayerName(target)
                                        for k,v in ipairs(GetPlayerIdentifiers(target))do
                                                if string.sub(v, 1, string.len("license:")) == "license:" then
                                                        license = v
                                                elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                                                        identifier = v
                                                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                                                        liveid = v
                                                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                                                        xblid  = v
                                                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                                                        discord = v
                                                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                                                        playerip = v
                                                end
                                        end

                                if duree > 0 then
                                        ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,0) --Timed ban here
                                        DropPlayer(target, "Vous avez été bannie par l'anticheat pour" .. reason)
                                else
                                        ban(target,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,1) --Perm ban here
                                        DropPlayer(target, "Vous avez été bannie par l'anticheat pour" .. reason)
                                end
                        end
                end
        end
end)

AddEventHandler('playerConnecting', function (playerName,setKickReason)
        local license,steamID,liveid,xblid,discord,playerip  = "n/a","n/a","n/a","n/a","n/a","n/a"

        for k,v in ipairs(GetPlayerIdentifiers(source))do
                if string.sub(v, 1, string.len("license:")) == "license:" then
                        license = v
                elseif string.sub(v, 1, string.len("steam:")) == "steam:" then
                        steamID = v
                elseif string.sub(v, 1, string.len("live:")) == "live:" then
                        liveid = v
                elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
                        xblid  = v
                elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
                        discord = v
                elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
                        playerip = v
                end
        end

        if (Banlist == {}) then
                Citizen.Wait(1000)
        end


        for i = 1, #BanList, 1 do
                if
                          ((tostring(BanList[i].license)) == tostring(license)
                        or (tostring(BanList[i].identifier)) == tostring(steamID)
                        or (tostring(BanList[i].liveid)) == tostring(liveid)
                        or (tostring(BanList[i].xblid)) == tostring(xblid)
                        or (tostring(BanList[i].discord)) == tostring(discord)
                        or (tostring(BanList[i].playerip)) == tostring(playerip))
                then

                        if (tonumber(BanList[i].permanent)) == 1 then
                                setKickReason("Vous avez été bannie par l'anticheat pour" .. BanList[i].reason)
                CancelEvent()
                print("^1Ton-Serveur - ".. GetPlayerName(source) .." Vous êtes bannie.")
                break
                        end
                end
        end
end)

function ban(source,license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,duree,reason,permanent)
        local expiration = duree * 86400
        local timeat     = os.time()
        local added      = os.date()

        if expiration < os.time() then
                expiration = os.time()+expiration
        end

                table.insert(BanList, {
                        license    = license,
                        identifier = identifier,
                        liveid     = liveid,
                        xblid      = xblid,
                        discord    = discord,
                        playerip   = playerip,
                        reason     = reason,
                        expiration = expiration,
                        permanent  = permanent
          })

                MySQL.Async.execute(
                'INSERT INTO wavebite_ban (license,identifier,liveid,xblid,discord,playerip,targetplayername,sourceplayername,reason,expiration,timeat,permanent) VALUES (@license,@identifier,@liveid,@xblid,@discord,@playerip,@targetplayername,@sourceplayername,@reason,@expiration,@timeat,@permanent)',
                {
                                ['@license']          = license,
                                ['@identifier']       = identifier,
                                ['@liveid']           = liveid,
                                ['@xblid']            = xblid,
                                ['@discord']          = discord,
                                ['@playerip']         = playerip,
                                ['@targetplayername'] = targetplayername,
                                ['@sourceplayername'] = sourceplayername,
                                ['@reason']           = reason,
                                ['@expiration']       = expiration,
                                ['@timeat']           = timeat,
                                ['@permanent']        = permanent,
                                },
                                function ()
                end)
                BanListHistoryLoad = false
end

function loadBanList()
        MySQL.Async.fetchAll(
                'SELECT * FROM wavebite_ban',
                {},
                function (data)
                  BanList = {}

                  for i=1, #data, 1 do
                        table.insert(BanList, {
                                license    = data[i].license,
                                identifier = data[i].identifier,
                                liveid     = data[i].liveid,
                                xblid      = data[i].xblid,
                                discord    = data[i].discord,
                                playerip   = data[i].playerip,
                                reason     = data[i].reason,
                                expiration = data[i].expiration,
                                permanent  = data[i].permanent
                          })
                  end
    end)
end

AddEventHandler('playerConnecting', function()
        local color = "^"..math.random(0,9)
        print("Ton-Serveur ^7- "..color.." ".. GetPlayerName(source) .." connection au serveur..^0")
end)

RegisterCommand("wsunban", function(source, args, raw)
    cmdunban(source, args)
end)

function cmdunban(source, args)
    if args[1] then
        local target = table.concat(args, " ")
        MySQL.Async.fetchAll('SELECT * FROM banlist WHERE targetplayername like @playername', {
            ['@playername'] = ("%"..target.."%")
        }, function(data)
            if data[1] then
                if #data > 1 then
                else
                    MySQL.Async.execute('DELETE FROM banlist WHERE targetplayername = @name', {
                        ['@name']  = data[1].targetplayername
                    }, function ()
                        loadBanList()
                        TriggerClientEvent('chat:addMessage', source, { args = { '^1Banlist ', data[1].targetplayername.." was unban from WaveBite" } } )
                    end)
                end
            else
            end
        end)
    else
    end
end

local newestversion = "v1.6.4"
local versionac = ConfigACS.Version

function inTable(tbl, item)
    for key, value in pairs(tbl) do
        if value == item then return key end
    end
    return false
end

RegisterServerEvent("ws:getIsAllowed")
AddEventHandler("ws:getIsAllowed", function()
    if IsPlayerAceAllowed(source, "wavebitebypass") then
        TriggerClientEvent("ws:returnIsAllowed", source, true)
    else
        TriggerClientEvent("ws:returnIsAllowed", source, false)
    end
end)

Citizen.CreateThread(function()
    ACStarted()
end)

if ConfigACS.License == nil then
    licenseee = ""
else
    licenseee = ConfigACS.License
end

function nullfieldcheck()
    if ConfigACS.License == "" then
        print("^3Ton-Serveur ^7 ^4ConfigACS.License ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACS.LogBanWebhook == "" or ConfigACS.LogBanWebhook == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACS.LogBanWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACS.ServerName == "" or ConfigACS.ServerName == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACS.ServerName ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACS.ModelsLogWebhook == "" or ConfigACS.ModelsLogWebhook == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACS.ModelsLogWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACS.ExplosionLogWebhook == "" or ConfigACS.ExplosionLogWebhook == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACS.ExplosionLogWebhook ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACS.Version == "" or ConfigACS.Version == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACS.Version ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiVPN == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiVPN ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiVPNDiscordLogs == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiVPNDiscordLogs ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.GlobalCheat == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.GlobalCheat ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiBlips == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiBlips ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiSpectate == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiSpectate ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiESX == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiESX ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiResourceStart == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiResourceStart ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiResourceStop == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiResourceStop ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiResourceRestart == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiResourceRestart ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.ResourceCount == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.ResourceCount ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiInjection == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.AntiInjection ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.WeaponProtection == nil then
        print("^3Ton-Serveur ^7 ^ConfigACC.WeaponProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.TriggersProtection == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.TriggersProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.GiveWeaponsProtection == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.GiveWeaponsProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.ExplosionProtection == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.ExplosionProtection ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.AntiClearPedTask == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.AntiClearPedTask ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BanBlacklistedWeapon == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BanBlacklistedWeapon ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedCommands == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlacklistedCommands ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlockedExplosions == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlockedExplosions ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedWords == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlacklistedWords ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedWeapons == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlacklistedWeapons ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedModels == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlacklistedModels ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.WhitelistedProps == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.WhitelistedProps ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    elseif ConfigACC.BlacklistedEvents == nil then
        print("^3Ton-Serveur ^7 ^4ConfigACC.BlacklistedEvents ^7: ^1MISSING or is NULL ^7!")
        print("^3Ton-Serveur ^7 ^1Stop AntiCheat..")
        Wait(10000)
        os.exit()
    else
        return true
    end
end

LogBanToDiscord = function(playerId, reason,typee)
    playerId = tonumber(playerId)
    local name = GetPlayerName(playerId)
    if playerId == 0 then
        local name = "Trigger Blacklist"
        local reason = "TriggerEvent Blacklist"
    else
    end
    local steamid = "Unknown"
    local license = "Unknown"
    local discord = "Unknown"
    local xbl = "Unknown"
    local liveid = "Unknown"
    local ip = "Unknown"

    if name == nil then
        name = "Unknown"
    end

    for k, v in pairs(GetPlayerIdentifiers(playerId)) do
        if string.sub(v, 1, string.len("steam:")) == "steam:" then
            steamid = v
        elseif string.sub(v, 1, string.len("license:")) == "license:" then
            license = v
        elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
            xbl = v
        elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
            ip = string.sub(v, 4)
        elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
            discordid = string.sub(v, 9)
            discord = "<@" .. discordid .. ">"
        elseif string.sub(v, 1, string.len("live:")) == "live:" then
            liveid = v
        end
    end

    local discordInfo = {
        ["color"] = "15158332",
        ["type"] = "rich",
        ["title"] = "Le joueur a été bannie",
        ["description"] = "**Name : **" ..
            name ..
                "\n **Reason : **" ..
                    reason ..
                        "\n **ID : **" ..
                            playerId ..
                                "\n **IP : **" ..
                                    ip ..
                                        "\n **Steam Hex : **" ..
                                            steamid .. "\n **License : **" .. license .. "\n **Discord : **" .. discord,
        ["footer"] = {
            ["text"] = " Ton-Serveur " .. versionac
        }
    }

    if name ~= "Unknown" then
        if typee == "basic" then
            PerformHttpRequest(
                ConfigACS.LogBanWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " Ton-Serveur", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        elseif typee == "model" then
            PerformHttpRequest(
                ConfigACS.ModelsLogWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " Ton-Serveur", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        elseif typee == "explosion" then
            PerformHttpRequest(
                ConfigACS.ExplosionLogWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode({username = " Ton-Serveur", embeds = {discordInfo}}),
                {["Content-Type"] = "application/json"}
            )
        end
    end
end

ACStarted = function()
    local discordInfo = {
        ["color"] = "15158332",
        ["type"] = "rich",
        ["title"] = " AntiCheat Start",
        ["footer"] = {
            ["text"] = " Ton-Serveur " .. versionac
        }
    }

    PerformHttpRequest(
        ConfigACS.LogBanWebhook,
        function(err, text, headers)
        end,
        "POST",
        json.encode({username = " Ton-Serveur", embeds = {discordInfo}}),
        {["Content-Type"] = "application/json"}
    )
end

ACFailed = function()
end

--=====================================================--
--=====================================================--

RegisterServerEvent("fuhjizofzf4z5fza")
AddEventHandler(
    "fuhjizofzf4z5fza",
    function(type, item)
        local _type = type or "default"
        local _item = item or "none"
        _type = string.lower(_type)

        if not IsPlayerAceAllowed(source, "wavebitebypass") then
            if (_type == "default") then
                LogBanToDiscord(source, "Aucune raison donner","basic")
                TriggerEvent("aopkfgebjzhfpazf77", "Tu es ban", source)
            elseif (_type == "godmode") then
                LogBanToDiscord(source, "GodMod","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " GodeMod", source)
            elseif (_type == "resourcestart") then
                LogBanToDiscord(source, "Start resource "..item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Start resource", source)
            elseif (_type == "resourcestop") then
                LogBanToDiscord(source, "Stop resource "..item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Stop Resource", source)
            elseif (_type == "esx") then
                LogBanToDiscord(source, "Injection Menu","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Injection Menu", source)
            elseif (_type == "spec") then
                LogBanToDiscord(source, "NoClip","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " NoClip", source)
            elseif (_type == "resourcecounter") then
                LogBanToDiscord(source, "Nombre de resource","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Nombre de resource", source)
            elseif (_type == "antiblips") then
                LogBanToDiscord(source, "Injection Blips","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Injection Blips", source)
            elseif (_type == "injection") then
                LogBanToDiscord(source, "Commande interdite " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Commande interdite", source)
            elseif (_type == "blacklisted_weapon") then
                LogBanToDiscord(source, "Arme interdite " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Arme interdite", source)
            elseif (_type == "hash") then
                LogBanToDiscord(source, "Véhicule interdit " .. item,"basic")
            elseif (_type == "explosion") then
                LogBanToDiscord(source, "Explosion " .. item,"basic")
                TriggerServerEvent("aopkfgebjzhfpazf77", " Explosion", source)
            elseif (_type == "event") then
                LogBanToDiscord(source, "Event / Trigger " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Event / Triger", source)
            elseif (_type == "menu") then
                LogBanToDiscord(source, "Injection " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Injection", source)
            elseif (_type == "functionn") then
                LogBanToDiscord(source, "Injection " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Injection", source)
            elseif (_type == "damagemodifier") then
                LogBanToDiscord(source, "Dommage d'arme modifier " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Dommage d'arme modifier", source)
            elseif (_type == "malformedresource") then
                LogBanToDiscord(source, "Injection resource " .. item,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Injection resource", source)
            end
        end
    end
)

Citizen.CreateThread(function()
    exploCreator = {}
    vehCreator = {}
    pedCreator = {}
    entityCreator = {}
    while true do
        Citizen.Wait(2500)
        exploCreator = {}
        vehCreator = {}
        pedCreator = {}
        entityCreator = {}
    end
end)

if ConfigACC.ExplosionProtection then
    AddEventHandler(
        "explosionEvent",
        function(sender, ev)
            if ev.damageScale ~= 0.0 then
                local BlacklistedExplosionsArray = {}

                for kkk, vvv in pairs(ConfigACC.BlockedExplosions) do
                    table.insert(BlacklistedExplosionsArray, vvv)
                end

                if inTable(BlacklistedExplosionsArray, ev.explosionType) ~= false then
                    CancelEvent()
                    LogBanToDiscord(sender, "Tried to spawn a blacklisted explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " Explosion", sender)
                end

                if ev.explosionType ~= 9 then
                    exploCreator[sender] = (exploCreator[sender] or 0) + 1
                    if exploCreator[sender] > 3 then
                        LogBanToDiscord(sender, "Tried to spawn mass explosions - type : "..ev.explosionType,"explosion")
                        TriggerEvent("aopkfgebjzhfpazf77", " Mass Explosion", sender)
                        CancelEvent()
                    end
                else
                    exploCreator[sender] = (exploCreator[sender] or 0) + 1
                    if exploCreator[sender] > 3 then
                        LogBanToDiscord(sender, "Tried to spawn mass explosions ( gas pump )","explosion")
                        CancelEvent()
                    end
                end

                if ev.isAudible == false then
                    LogBanToDiscord(sender, "Tried to spawn silent explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " Silent Explosion", sender)
                end

                if ev.isInvisible == true then
                    LogBanToDiscord(sender, "Tried to spawn invisible explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", " Invisible Explosion", sender)
                end

                if ev.damageScale > 1.0 then
                    LogBanToDiscord(sender, "Tried to spawn oneshot explosion - type : "..ev.explosionType,"explosion")
                    TriggerEvent("aopkfgebjzhfpazf77", "Explosion", sender)
                end
                CancelEvent()
            end
        end
    )
end

if ConfigACC.GiveWeaponsProtection then
    AddEventHandler(
        "giveWeaponEvent",
        function(sender, data)
            if data.givenAsPickup == false then
                LogBanToDiscord(sender, "Tried to give weapon to a player","basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Give Weapon", sender)
                CancelEvent()
            end
        end
    )

    AddEventHandler(
        "RemoveWeaponEvent",
        function(sender, data)
            CancelEvent()
            LogBanToDiscord(sender, "Tried to remove weapon to a player","basic")
            TriggerEvent("aopkfgebjzhfpazf77", " Remove Weapon", sender)
        end
    )

    AddEventHandler(
        "RemoveAllWeaponsEvent",
        function(sender, data)
            CancelEvent()
            LogBanToDiscord(sender, "Tried to remove all weapons to a player","basic")
            TriggerEvent("aopkfgebjzhfpazf77", " Remove All Weapons", sender)
        end
    )
end

if ConfigACC.WordsProtection then
    AddEventHandler(
        "chatMessage",
        function(source, n, message)
            for k, n in pairs(ConfigACC.BlacklistedWords) do
                if string.match(message:lower(), n:lower()) then
                    LogBanToDiscord(source, "Tried to say : " .. n,"basic")
                    TriggerEvent("aopkfgebjzhfpazf77", " Blacklisted Word", source)
                end
            end
        end
    )
end

if ConfigACC.TriggersProtection then
    for k, events in pairs(ConfigACC.BlacklistedEvents) do
        RegisterServerEvent(events)
        AddEventHandler(
            events,
            function()
                LogBanToDiscord(source, "Tried to trigger his shit event : " .. events,"basic")
                TriggerEvent("aopkfgebjzhfpazf77", " Blacklisted Event", source)
                CancelEvent()
            end
        )
    end
end

AddEventHandler(
    "entityCreating",
    function(entity)
        if DoesEntityExist(entity) then
            local src = NetworkGetEntityOwner(entity)
            local model = GetEntityModel(entity)
            local blacklistedPropsArray = {}
            local WhitelistedPropsArray = {}
            local eType = GetEntityPopulationType(entity)

            if src == nil then
                CancelEvent()
            end

            for bl_k, bl_v in pairs(ConfigACC.BlacklistedModels) do
                table.insert(blacklistedPropsArray, GetHashKey(bl_v))
            end

            for wl_k, wl_v in pairs(ConfigACC.WhitelistedProps) do
                table.insert(WhitelistedPropsArray, GetHashKey(wl_v))
            end

            if eType == 0 then
                CancelEvent()
            end

            if GetEntityType(entity) == 3 then
                if eType == 6 or eType == 7 then
                    if inTable(WhitelistedPropsArray, model) == false then
                        if model ~= 0 then
                            LogBanToDiscord(src, "Tried to spawn a blacklisted prop : " .. model,"model")
                            CancelEvent()

                            entityCreator[src] = (entityCreator[src] or 0) + 1
                            if entityCreator[src] > 30 then
                                LogBanToDiscord(src, "Tried to spawn "..entityCreator[src].." entities","model")
                            end
                        end
                    end
                end
            else
                if GetEntityType(entity) == 2 then
                    if eType == 6 or eType == 7 then
                        if inTable(blacklistedPropsArray, model) ~= false then
                            if model ~= 0 then
                                LogBanToDiscord(src, "Tried to spawn a blacklisted vehicle : " .. model,"model")
                                CancelEvent()
                            end
                        end
                        vehCreator[src] = (vehCreator[src] or 0) + 1
                        if vehCreator[src] > 20 then
                            LogBanToDiscord(src, "Tried to spawn "..vehCreator[src].." vehs","model")
                            TriggerEvent("aopkfgebjzhfpazf77", " Spawned Mass Vehs", src)
                        end
                    end
                elseif GetEntityType(entity) == 1 then
                    if eType == 6 or eType == 7 then
                        if inTable(blacklistedPropsArray, model) ~= false then
                            if model ~= 0 or model ~= 225514697 then
                                LogBanToDiscord(src, "Tried to spawn a blacklisted ped : " .. model,"model")
                                CancelEvent()
                            end
                        end
                        pedCreator[src] = (pedCreator[src] or 0) + 1
                        if pedCreator[src] > 20 then
                            LogBanToDiscord(src, "Tried to spawn "..pedCreator[src].." peds","model")
                            TriggerEvent("aopkfgebjzhfpazf77", " Spawned Mass Peds", src)
                        end
                    end
                else
                    if inTable(blacklistedPropsArray, GetHashKey(entity)) ~= false then
                        if model ~= 0 or model ~= 225514697 then
                            LogBanToDiscord(src, "Tried to spawn a model : " .. model,"model")
                            CancelEvent()
                        end
                    end
                end
            end
        end
    end
)

if ConfigACC.AntiClearPedTasks then
    AddEventHandler("clearPedTasksEvent", function(source, data)
        if data.immediately then
            LogBanToDiscord(source, "Tried to clear ped tasks","basic")
            TriggerEvent("aopkfgebjzhfpazf77", " Clear Peds Tasks", source)
        end
    end)
end

function webhooklog(a, b, d, e, f)
    if ConfigACC.AntiVPN then
        if ConfigACS.AntiVPNWebhook ~= "" or ConfigACS.AntiVPNWebhook ~= nil then
            PerformHttpRequest(
                ConfigACS.AntiVPNWebhook,
                function(err, text, headers)
                end,
                "POST",
                json.encode(
                    {
                        embeds = {
                            {
                                author = {name = " WaveBite AntiVPN", url = "", icon_url = ""},
                                title = "Connection " .. a,
                                description = "**Player:** " .. b .. "\nIP: " .. d .. "\n" .. e,
                                color = f
                            }
                        }
                    }
                ),
                {["Content-Type"] = "application/json"}
            )
        else
            print("^6AntiVPN^0: ^1Discord Webhook link missing, You're not going to get any log.^0")
        end
    end
end

if ConfigACC.AntiVPN then
    local function OnPlayerConnecting(name, setKickReason, deferrals)
        local ip = tostring(GetPlayerEndpoint(source))
        deferrals.defer()
        Wait(0)
        deferrals.update("WaveBite: Checking VPN...")
        PerformHttpRequest(
            "https://blackbox.ipinfo.app/lookup/" .. ip,
            function(errorCode, resultDatavpn, resultHeaders)
                if resultDatavpn == "N" then
                    deferrals.done()
                else
                    print("^6Ton-Serveur^0: ^1Player ^0" .. name .. " ^1kicked for using a VPN, ^8IP: ^0" .. ip .. "^0")
                    if ConfigACC.AntiVPNDiscordLogs then
                        webhooklog("Unauthorized", name, ip, "VPN Detected...", 16515843)
                    end
                    deferrals.done("WaveBite: Please disable your VPN connection.")
                end
            end
        )
    end

    AddEventHandler("playerConnecting", OnPlayerConnecting)
end

local Charset = {}
for i = 65, 90 do
    table.insert(Charset, string.char(i))
end
for i = 97, 122 do
    table.insert(Charset, string.char(i))
end

function RandomLetter(length)
    if length > 0 then
        return RandomLetter(length - 1) .. Charset[math.random(1, #Charset)]
    end

    return ""
end

RegisterCommand(
    "wavebitefx",
    function(source)
        if source == 0 then
            count = 0
            skip = 0
            local randomtextfile = RandomLetter(10) .. ".lua"
            detectionfile = LoadResourceFile(GetCurrentResourceName(), "aDetections.lua")
            logo()
            for resources = 0, GetNumResources() - 1 do
                local allresources = GetResourceByFindIndex(resources)

                resourcefile = LoadResourceFile(allresources, "fxmanifest.lua")

                if resourcefile then
                    Wait(100)
                        resourceaddcontent = resourcefile .. "\n\nclient_script '" .. randomtextfile .. "'"

                        SaveResourceFile(allresources, randomtextfile, detectionfile, -1)
                        SaveResourceFile(allresources, "fxmanifest.lua", resourceaddcontent, -1)
                        color = math.random(1, 6)

                        print("^" .. color .. "installed on " .. allresources .. " resource^0")

                        count = count + 1
                else
                    skip = skip + 1
                    print("skipped " .. allresources .. " resource")
                end
            end
            logo()
            print("skipped " .. skip .. " resouce(s)")
            print("installed on " .. count .. " resources")
            print("INSTALLATION FINISHED")
        end
    end
)

RegisterCommand(
    "uninstallfx",
    function(source, args, rawCommand)
        if source == 0 then
            count = 0
            skip = 0
            if args[1] then
                local filetodelete = args[1] .. ".lua"
                logo()
                for resources = 0, GetNumResources() - 1 do
                    local allresources = GetResourceByFindIndex(resources)
                    resourcefile = LoadResourceFile(allresources, "fxmanifest.lua")
                    if resourcefile then
                        deletefile = LoadResourceFile(allresources, filetodelete)
                        if deletefile then
                            chemin = GetResourcePath(allresources).."/"..filetodelete
                            Wait(100)
                            os.remove(chemin)
                            color = math.random(1, 6)
                            print("^" .. color .. "uninstalled on " .. allresources .. " resource^0")
                            count = count + 1
                        else
                            skip = skip + 1
                            print("skipped " .. allresources .. " resource")
                        end
                    else
                        skip = skip + 1
                        print("skipped " .. allresources .. " resource")
                    end
                end
                logo()
                print("skipped " .. skip .. " resouce(s)")
                print("uninstalled on " .. count .. " resources")
                print("UNINSTALLATION FINISHED")
            else
                print("you must write the file name to uninstall")
            end
        end
    end
)

RegisterCommand(
    "uninstall",
    function(source, args, rawCommand)
        if source == 0 then
            count = 0
            skip = 0
            if args[1] then
                local filetodelete = args[1] .. ".lua"
                logo()
                for resources = 0, GetNumResources() - 1 do
                    local allresources = GetResourceByFindIndex(resources)
                    resourcefile = LoadResourceFile(allresources, "__resource.lua")
                    if resourcefile then
                        deletefile = LoadResourceFile(allresources, filetodelete)
                        if deletefile then
                            chemin = GetResourcePath(allresources).."/"..filetodelete
                            Wait(100)
                            os.remove(chemin)
                            color = math.random(1, 6)
                            print("^" .. color .. "uninstalled on " .. allresources .. " resource^0")
                            count = count + 1
                        else
                            skip = skip + 1
                            print("skipped " .. allresources .. " resource")
                        end
                    else
                        skip = skip + 1
                        print("skipped " .. allresources .. " resource")
                    end
                end
                logo()
                print("skipped " .. skip .. " resouce(s)")
                print("uninstalled on " .. count .. " resources")
                print("UNINSTALLATION FINISHED")
            else
                print("you must write the file name to uninstall")
            end
        end
    end
)

RegisterCommand(
    "wavebite",
    function(source)
        if source == 0 then
            count = 0
            skip = 0
            local randomtextfile = RandomLetter(10) .. ".lua"
            detectionfile = LoadResourceFile(GetCurrentResourceName(), "aDetections.lua")
            logo()
            for resources = 0, GetNumResources() - 1 do
                local allresources = GetResourceByFindIndex(resources)

                resourcefile = LoadResourceFile(allresources, "__resource.lua")

                if resourcefile then
                    Wait(100)

                        resourceaddcontent = resourcefile .. "\n\nclient_script '" .. randomtextfile .. "'"

                        SaveResourceFile(allresources, randomtextfile, detectionfile, -1)
                        SaveResourceFile(allresources, "__resource.lua", resourceaddcontent, -1)
                        color = math.random(1, 6)

                        print("^" .. color .. "installed on " .. allresources .. " resource^0")

                        count = count + 1
                else
                    skip = skip + 1
                    print("skipped " .. allresources .. " resource")
                end
            end
            logo()
            print("skipped " .. skip .. " resouce(s)")
            print("installed on " .. count .. " resources")
            print("INSTALLATION FINISHED")
        else
            print("zezette")
        end
    end
)




-- Ban Sql --





TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    local licenseid, playerip = 'N/A', 'N/A'
    licenseid = ESX.GetIdentifierFromId(_source, 'license:')

    if not licenseid then
        setKickReason(Locale.invalididentifier)
        CancelEvent()
    end

    deferrals.defer()
    Citizen.Wait(0)
    deferrals.update(('Vérification de %s en cours...'):format(playerName))
    Citizen.Wait(0)

    IsBanned(licenseid, function(isBanned, banData)
        if isBanned then
            if tonumber(banData.permanent) == 1 then
                deferrals.done(('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(banData.reason, banData.sourceName))
                TriggerEvent('esx:customDiscordLog', ('Tentative de Connexion du Joueur : %s (%s)\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(playerName, licenseid, banData.reason, banData.sourceName), 'Ban Info')
            else
                if tonumber(banData.expiration) > os.time() then
                    local timeRemaining = tonumber(banData.expiration) - os.time()
                    deferrals.done(('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(banData.reason, SexyTime(timeRemaining), banData.sourceName))
                    TriggerEvent('esx:customDiscordLog', ('Tentative de Connexion du Joueur : %s (%s)\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(playerName, licenseid, banData.reason, SexyTime(timeRemaining), banData.sourceName), 'Ban Info')
                else
                    --DeleteBan(licenseid)
                    deferrals.done()
                end
            end
        else
            deferrals.done()
        end
    end)
end)

RegisterServerEvent('BanSql:ICheatClient')
AddEventHandler('BanSql:ICheatClient', function(reason)
    local _source = source
    local licenseid, playerip = 'N/A', 'N/A'

    if reason == nil then
        reason = 'Cheat'
    end

    if _source then
        local name = GetPlayerName(_source)

        if name then
            licenseid = ESX.GetIdentifierFromId(_source, 'license:')
            --playerip = GetPlayerEndpoint(_source)

            if not licenseid then
                licenseid = 'N/A'
            end

            AddBan(_source, licenseid, playerip, name, 'Anti-Cheat', 0, reason, 1)
            DropPlayer(_source, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : Anti-Cheat'):format(reason))
        end
    else
        print('BanSql Error : Anti-Cheat have received invalid id.')
    end
end)

AddEventHandler('BanSql:ICheatServer', function(target, reason)
    local licenseid, playerip = 'N/A', 'N/A'

    if reason == nil then
        reason = 'Cheat'
    end

    if target then
        local name = GetPlayerName(target)

        if name then
            licenseid = ESX.GetIdentifierFromId(target, 'license:')

            if not licenseid then
                licenseid = 'N/A'
            end

            AddBan(target, licenseid, playerip, name, 'Anti-Cheat', 0, reason, 1)
            DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : Anti-Cheat'):format(reason))
        end
    else
        print('BanSql Error : Anti-Cheat have received invalid id.')
    end
end)

function SexyTime(seconds)
    local days = seconds / 86400
    local hours = (days - math.floor(days)) * 24
    local minutes = (hours - math.floor(hours)) * 60
    seconds = (minutes - math.floor(minutes)) * 60
    return ('%s jours %s heures %s minutes %s secondes'):format(math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds))
end

function SendMessage(source, message)
    if source ~= 0 then
        TriggerClientEvent('chat:addMessage', source, { args = {'^1BanInfo ', message} })
    else
        print(('SqlBan: %s'):format(message))
    end
end

function AddBan(source, licenseid, playerip, targetName, sourceName, time, reason, permanent)
    time = time * 3600
    local timeat = os.time()
    local expiration = time + timeat

    MySQL.Async.execute('INSERT INTO banlist (licenseid, playerip, targetName, sourceName, reason, timeat, expiration, permanent) VALUES (@licenseid, @playerip, @targetName, @sourceName, @reason, @timeat, @expiration, @permanent)', {
        ['@licenseid'] = licenseid,
        ['@playerip'] = playerip,
        ['@targetName'] = targetName,
        ['@sourceName'] = sourceName,
        ['@reason'] = reason,
        ['@timeat'] = timeat,
        ['@expiration'] = expiration,
        ['@permanent'] = permanent
    }, function()
        MySQL.Async.execute('INSERT INTO banlisthistory (licenseid, playerip, targetName, sourceName, reason, timeat, expiration, permanent) VALUES (@licenseid, @playerip, @targetName, @sourceName, @reason, @timeat, @expiration, @permanent)', {
            ['@licenseid'] = licenseid,
            ['@playerip'] = playerip,
            ['@targetName'] = targetName,
            ['@sourceName'] = sourceName,
            ['@reason'] = reason,
            ['@timeat'] = timeat,
            ['@expiration'] = expiration,
            ['@permanent'] = permanent
        })

        if permanent == 0 then
            SendMessage(source, (('Vous avez banni %s / Durée : %s / Raison : %s'):format(targetName, SexyTime(time), reason)))
            TriggerEvent('esx:customDiscordLog', ('`%s` a banni `%s` / Durée : `%s` / Raison : `%s`\n```\n%s\n%s\n```'):format(sourceName, targetName, SexyTime(time), reason, licenseid, playerip), 'Ban Info')
        else
            SendMessage(source, (('Vous avez banni %s / Durée : Permanent / Raison : %s'):format(targetName, reason)))
            TriggerEvent('esx:customDiscordLog', ('`%s` a banni `%s` / Durée : `Permanent` / Raison : `%s`\n```\n%s\n%s\n```'):format(sourceName, targetName, reason, licenseid, playerip), 'Ban Info')
        end
    end)
end

function DeleteBan(licenseid, cb)
    MySQL.Async.execute('DELETE FROM banlist WHERE licenseid = @licenseid', {
        ['@licenseid'] = licenseid
    }, function()
        if cb then
            cb()
        end
    end)
end

function IsBanned(licenseid, cb)
    MySQL.Async.fetchAll('SELECT * FROM banlist WHERE licenseid = @licenseid', {
        ['@licenseid'] = licenseid
    }, function(result)
        if #result > 0 then
            cb(true, result[1])
        else
            cb(false, result[1])
        end
    end)
end

ESX.AddGroupCommand('sqlban', 'admin', function(source, args, user)
    local licenseid, playerip = 'N/A', 'N/A'
    local target = tonumber(args[1])
    local expiration = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)

    if target and target > 0 then
        local sourceName = GetPlayerName(source)
        local targetName = GetPlayerName(target)

        if targetName then
            if expiration and expiration <= 336 then
                licenseid = ESX.GetIdentifierFromId(target, 'license:')

                if not licenseid then
                    licenseid = 'N/A'
                end

                if reason == '' then
                    reason = Locale.noreason
                end

                if expiration > 0 then
                    AddBan(source, licenseid, playerip, targetName, sourceName, expiration, reason, 0)
                    DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(reason, SexyTime(expiration * 3600), sourceName))
                else
                    AddBan(source, licenseid, playerip, targetName, sourceName, expiration, reason, 1)
                    DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(reason, sourceName))
                end
            else
                SendMessage(source, Locale.invalidtime)
            end
        else
            SendMessage(source, Locale.invalidid)
        end
    else
        SendMessage(source, Locale.invalidid)
    end
end, {help = Locale.ban, params = { {name = 'id'}, {name = 'hour', help = Locale.timehelp}, {name = 'reason', help = Locale.reason} }})

ESX.AddGroupCommand('sqlbanoffline', 'admin', function(source, args, user)
    local licenseid = tostring(args[1])
    local expiration = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)
    local sourceName = GetPlayerName(source)

    if expiration then
        if licenseid then
            MySQL.Async.fetchAll('SELECT * FROM account_info WHERE license = @license', {
                ['@license'] = licenseid
            }, function(data)
                if data[1] then
                    if expiration and expiration <= 336 then
                        if reason == '' then
                            reason = Locale.noreason
                        end

                        if expiration > 0 then
                            AddBan(source, data[1].license, data[1].ip, data[1].name, sourceName, expiration, reason, 0)
                        else
                            AddBan(source, data[1].license, data[1].ip, data[1].name, sourceName, expiration, reason, 1)
                        end
                    else
                        SendMessage(source, Locale.invalidtime)
                    end
                else
                    SendMessage(source, Locale.invalidid)
                end
            end)
        else
            SendMessage(source, Locale.invalidname)
        end
    else
        SendMessage(source, Locale.invalidtime)
    end
end, {help = Locale.banoff, params = { {name = 'licenseid', help = Locale.licenseid}, {name = 'hour', help = Locale.timehelp}, {name = 'reason', help = Locale.reason} }})

ESX.AddGroupCommand('sqlunban', 'admin', function(source, args, user)
    local sourceName = GetPlayerName(source)
    local licenseid = table.concat(args, ' ')

    if licenseid then
        MySQL.Async.fetchAll('SELECT * FROM banlist WHERE licenseid LIKE @licenseid', {
            ['@licenseid'] = ('%' .. licenseid .. '%')
        }, function(data)
            if data[1] then
                DeleteBan(data[1].licenseid, function()
                    SendMessage(source, ('%s a était déban'):format(data[1].targetName))
                    TriggerEvent('esx:customDiscordLog', ('`%s` a était déban par `%s`'):format(data[1].targetName, sourceName), 'Ban Info')
                end)
            else
                SendMessage(source, Locale.invalidname)
            end
        end)
    else
        SendMessage(source, Locale.cmdunban)
    end
end, {help = Locale.unban, params = { {name = 'licenseid', help = Locale.licenseid} }})



-- Ban SQL --



TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
    local _source = source
    local licenseid, playerip = 'N/A', 'N/A'
    licenseid = ESX.GetIdentifierFromId(_source, 'license:')
    --playerip = GetPlayerEndpoint(_source)

    if not licenseid then
        setKickReason(Locale.invalididentifier)
        CancelEvent()
    end

    deferrals.defer()
    Citizen.Wait(0)
    deferrals.update(('Vérification de %s en cours...'):format(playerName))
    Citizen.Wait(0)

    IsBanned(licenseid, function(isBanned, banData)
        if isBanned then
            if tonumber(banData.permanent) == 1 then
                deferrals.done(('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(banData.reason, banData.sourceName))
                TriggerEvent('esx:customDiscordLog', ('Tentative de Connexion du Joueur : %s (%s)\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(playerName, licenseid, banData.reason, banData.sourceName), 'Ban Info')
            else
                if tonumber(banData.expiration) > os.time() then
                    local timeRemaining = tonumber(banData.expiration) - os.time()
                    deferrals.done(('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(banData.reason, SexyTime(timeRemaining), banData.sourceName))
                    TriggerEvent('esx:customDiscordLog', ('Tentative de Connexion du Joueur : %s (%s)\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(playerName, licenseid, banData.reason, SexyTime(timeRemaining), banData.sourceName), 'Ban Info')
                else
                    DeleteBan(licenseid)
                    deferrals.done()
                end
            end
        else
            deferrals.done()
        end
    end)
end)

RegisterServerEvent('BanSql:ICheatClient')
AddEventHandler('BanSql:ICheatClient', function(reason)
    local _source = source
    local licenseid, playerip = 'N/A', 'N/A'

    if reason == nil then
        reason = 'Cheat'
    end

    if _source then
        local name = GetPlayerName(_source)

        if name then
            licenseid = ESX.GetIdentifierFromId(_source, 'license:')
            --playerip = GetPlayerEndpoint(_source)

            if not licenseid then
                licenseid = 'N/A'
            end

            AddBan(_source, licenseid, playerip, name, 'Anti-Cheat Ton-Serveur', 0, reason, 1)
            DropPlayer(_source, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : Anti-Cheat Ton-Serveur'):format(reason))
        end
    else
        print('BanSql Error : Anti-Cheat Ton-Serveur have received invalid id.')
    end
end)

AddEventHandler('BanSql:ICheatServer', function(target, reason)
    local licenseid, playerip = 'N/A', 'N/A'

    if reason == nil then
        reason = 'Cheat'
    end

    if target then
        local name = GetPlayerName(target)

        if name then
            licenseid = ESX.GetIdentifierFromId(target, 'license:')
            --playerip = GetPlayerEndpoint(_source)

            if not licenseid then
                licenseid = 'N/A'
            end

            AddBan(target, licenseid, playerip, name, 'Anti-Cheat Ton-Serveur', 0, reason, 1)
            DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : Anti-Cheat Ton-Serveur'):format(reason))
        end
    else
        print('BanSql Error : Anti-Cheat Ton-Serveur have received invalid id.')
    end
end)

function SexyTime(seconds)
    local days = seconds / 86400
    local hours = (days - math.floor(days)) * 24
    local minutes = (hours - math.floor(hours)) * 60
    seconds = (minutes - math.floor(minutes)) * 60
    return ('%s jours %s heures %s minutes %s secondes'):format(math.floor(days), math.floor(hours), math.floor(minutes), math.floor(seconds))
end

function SendMessage(source, message)
    if source ~= 0 then
        TriggerClientEvent('chat:addMessage', source, { args = {'^1BanInfo ', message} })
    else
        print(('SqlBan: %s'):format(message))
    end
end

function AddBan(source, licenseid, playerip, targetName, sourceName, time, reason, permanent)
    time = time * 3600
    local timeat = os.time()
    local expiration = time + timeat

    MySQL.Async.execute('INSERT INTO banlist (licenseid, playerip, targetName, sourceName, reason, timeat, expiration, permanent) VALUES (@licenseid, @playerip, @targetName, @sourceName, @reason, @timeat, @expiration, @permanent)', {
        ['@licenseid'] = licenseid,
        ['@playerip'] = playerip,
        ['@targetName'] = targetName,
        ['@sourceName'] = sourceName,
        ['@reason'] = reason,
        ['@timeat'] = timeat,
        ['@expiration'] = expiration,
        ['@permanent'] = permanent
    }, function()
        MySQL.Async.execute('INSERT INTO banlisthistory (licenseid, playerip, targetName, sourceName, reason, timeat, expiration, permanent) VALUES (@licenseid, @playerip, @targetName, @sourceName, @reason, @timeat, @expiration, @permanent)', {
            ['@licenseid'] = licenseid,
            ['@playerip'] = playerip,
            ['@targetName'] = targetName,
            ['@sourceName'] = sourceName,
            ['@reason'] = reason,
            ['@timeat'] = timeat,
            ['@expiration'] = expiration,
            ['@permanent'] = permanent
        })

        if permanent == 0 then
            SendMessage(source, (('Vous avez banni %s / Durée : %s / Raison : %s'):format(targetName, SexyTime(time), reason)))
            TriggerEvent('esx:customDiscordLog', ('`%s` a banni `%s` / Durée : `%s` / Raison : `%s`\n```\n%s\n%s\n```'):format(sourceName, targetName, SexyTime(time), reason, licenseid, playerip), 'Ban Info')
        else
            SendMessage(source, (('Vous avez banni %s / Durée : Permanent / Raison : %s'):format(targetName, reason)))
            TriggerEvent('esx:customDiscordLog', ('`%s` a banni `%s` / Durée : `Permanent` / Raison : `%s`\n```\n%s\n%s\n```'):format(sourceName, targetName, reason, licenseid, playerip), 'Ban Info')
        end
    end)
end

function DeleteBan(licenseid, cb)
    MySQL.Async.execute('DELETE FROM banlist WHERE licenseid = @licenseid', {
        ['@licenseid'] = licenseid
    }, function()
        if cb then
            cb()
        end
    end)
end

function IsBanned(licenseid, cb)
    MySQL.Async.fetchAll('SELECT * FROM banlist WHERE licenseid = @licenseid', {
        ['@licenseid'] = licenseid
    }, function(result)
        if #result > 0 then
            cb(true, result[1])
        else
            cb(false, result[1])
        end
    end)
end

ESX.AddGroupCommand('sqlban', 'admin', function(source, args, user)
    local licenseid, playerip = 'N/A', 'N/A'
    local target = tonumber(args[1])
    local expiration = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)

    if target and target > 0 then
        local sourceName = GetPlayerName(source)
        local targetName = GetPlayerName(target)

        if targetName then
            if expiration and expiration <= 336 then
                licenseid = ESX.GetIdentifierFromId(target, 'license:')
                --playerip = GetPlayerEndpoint(target)

                if not licenseid then
                    licenseid = 'N/A'
                end

                if reason == '' then
                    reason = Locale.noreason
                end

                if expiration > 0 then
                    AddBan(source, licenseid, playerip, targetName, sourceName, expiration, reason, 0)
                    DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : %s\nAuteur : %s'):format(reason, SexyTime(expiration * 3600), sourceName))
                else
                    AddBan(source, licenseid, playerip, targetName, sourceName, expiration, reason, 1)
                    DropPlayer(target, ('Vous êtes banni de Ton-Serveur\nRaison : %s\nTemps Restant : Permanent\nAuteur : %s'):format(reason, sourceName))
                end
            else
                SendMessage(source, Locale.invalidtime)
            end
        else
            SendMessage(source, Locale.invalidid)
        end
    else
        SendMessage(source, Locale.invalidid)
    end
end, {help = Locale.ban, params = { {name = 'id'}, {name = 'hour', help = Locale.timehelp}, {name = 'reason', help = Locale.reason} }})

ESX.AddGroupCommand('sqlbanoffline', 'admin', function(source, args, user)
    local licenseid = tostring(args[1])
    local expiration = tonumber(args[2])
    local reason = table.concat(args, ' ', 3)
    local sourceName = GetPlayerName(source)

    if expiration then
        if licenseid then
            MySQL.Async.fetchAll('SELECT * FROM account_info WHERE license = @license', {
                ['@license'] = licenseid
            }, function(data)
                if data[1] then
                    if expiration and expiration <= 336 then
                        if reason == '' then
                            reason = Locale.noreason
                        end

                        if expiration > 0 then
                            AddBan(source, data[1].license, data[1].ip, data[1].name, sourceName, expiration, reason, 0)
                        else
                            AddBan(source, data[1].license, data[1].ip, data[1].name, sourceName, expiration, reason, 1)
                        end
                    else
                        SendMessage(source, Locale.invalidtime)
                    end
                else
                    SendMessage(source, Locale.invalidid)
                end
            end)
        else
            SendMessage(source, Locale.invalidname)
        end
    else
        SendMessage(source, Locale.invalidtime)
    end
end, {help = Locale.banoff, params = { {name = 'licenseid', help = Locale.licenseid}, {name = 'hour', help = Locale.timehelp}, {name = 'reason', help = Locale.reason} }})

ESX.AddGroupCommand('sqlunban', 'admin', function(source, args, user)
    local sourceName = GetPlayerName(source)
    local licenseid = table.concat(args, ' ')

    if licenseid then
        MySQL.Async.fetchAll('SELECT * FROM banlist WHERE licenseid LIKE @licenseid', {
            ['@licenseid'] = ('%' .. licenseid .. '%')
        }, function(data)
            if data[1] then
                DeleteBan(data[1].licenseid, function()
                    SendMessage(source, ('%s a était déban'):format(data[1].targetName))
                    TriggerEvent('esx:customDiscordLog', ('`%s` a était déban par `%s`'):format(data[1].targetName, sourceName), 'Ban Info')
                end)
            else
                SendMessage(source, Locale.invalidname)
            end
        end)
    else
        SendMessage(source, Locale.cmdunban)
    end
end, {help = Locale.unban, params = { {name = 'licenseid', help = Locale.licenseid} }})

-- Craquer par Korioz#3310 --
-- Debug + ajout du BanSql par Pots#0106 --