lib.addCommand('admin', {
    help = 'Open the admin menu',
    restricted = 'qbcore.mod'
}, function(source)
    TriggerClientEvent('ps-adminmenu:client:OpenUI', source)
end)

if Config.Framework == "ESX" then
    ESX.RegisterCommand({'admin'}, Config.ModLevel, function(xPlayer, args, showError)
        TriggerClientEvent('ps-adminmenu:client:OpenUI', xPlayer.source)
    end, false, {help = 'Open the admin menu'})
end
-- Callbacks
