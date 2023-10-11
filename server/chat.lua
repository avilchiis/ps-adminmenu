local messages = {}

-- Staff Chat
RegisterNetEvent('ps-adminmenu:server:sendMessageServer', function(message, citizenid, fullname)
    local time = os.time() * 1000
    if Config.Framework == "QBCore" then
        local players = QBCore.Functions.GetQBPlayers()
        for i = 1, #players, 1 do
            local Player = players[i]
            if isAdmin(Player.PlayerData.source, Config.ModLevel) then
                showNotification(Player.PlayerData.source, locale("new_staffchat", 'inform', 7500))
            end
        end
    end
    if Config.Framework == "ESX" then
        local xPlayers = ESX.GetExtendedPlayers('group', Config.ModLevel)
        for _, xPlayer in pairs(xPlayers) do
            showNotification(xPlayer.source, locale("new_staffchat", 'inform', 7500))
        end
    end
    messages[#messages + 1] = {message = message, citizenid = citizenid, fullname = fullname, time = time}
end)

lib.callback.register('ps-adminmenu:callback:GetMessages', function(source)
    return messages
end)