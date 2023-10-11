-- Clear Inventory
RegisterNetEvent('ps-adminmenu:server:ClearInventory', function(data, selectedData)
    if not CheckPerms(data.perms) then return end

    local src = source
    local player = selectedData["Player"].value
    local Player = getPlayerFromId(src)

    if not Player then
        return showNotification(source, locale("not_online"), 'error', 7500)
    end

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:ClearInventory(player)
    else
        exports[Config.Inventory]:ClearInventory(player, nil)
    end
    local fullName = getName(src)
    showNotification(src, locale("invcleared", fullName), 'success', 7500)
end)

-- Open Inv [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenInv', function(data)
    exports.ox_inventory:forceOpenInventory(source, 'player', data)
end)

-- Open Stash [ox side]
RegisterNetEvent('ps-adminmenu:server:OpenStash', function(data)
    exports.ox_inventory:forceOpenInventory(source, 'stash', data)
end)

-- Give Item
RegisterNetEvent('ps-adminmenu:server:GiveItem', function(data, selectedData)
    if not CheckPerms(data.perms) then return end

    local target = selectedData["Player"].value
    local item = selectedData["Item"].value
    local amount = selectedData["Amount"].value
    local Player = getPlayerFromId(target)

    if not item or not amount then return end
    if not Player then
        return showNotification(source, locale("not_online"), 'error', 7500)
    end
    addItem(target,item,amount)
    local fullName = getName(target)
    showNotification(source, locale("give_item", tonumber(amount) .. " " .. item, fullName), "success", 7500)
end)

-- Give Item to All
RegisterNetEvent('ps-adminmenu:server:GiveItemAll', function(data, selectedData)
    if not CheckPerms(data.perms) then return end
    local src = source
    local item = selectedData["Item"].value
    local amount = selectedData["Amount"].value
    local players = getAllPlayers()

    if not item or not amount then return end
    for _, Player in pairs(players) do
        if Config.Framework == "QBCore" then
            addItem(Player.PlayerData.source,item,amount)
        end
        if Config.Framework == "ESX" then
            addItem(Player.source,item,amount)
        end
    end
    showNotification(src, locale("give_item_all", amount .. " " .. item), "success", 7500)
end)
