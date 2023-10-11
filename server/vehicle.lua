-- Admin Car
RegisterNetEvent('ps-adminmenu:server:SaveCar', function(mods, vehicle, _, plate)
    local src = source
    local Player = getPlayerFromId(src)
    if Config.Framework == "QBCore" then
        local result = MySQL.query.await('SELECT plate FROM player_vehicles WHERE plate = ?', {plate})
        if result[1] == nil then
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
                Player.PlayerData.license,
                Player.PlayerData.citizenid,
                vehicle.model,
                vehicle.hash,
                json.encode(mods),
                plate,
                0
            })
            showNotification(src, locale("veh_owner"), 'success', 5000)
        else
            showNotification(src, locale("u_veh_owner"), 'error', 3000)
        end
    end
    if Config.Framework == "ESX" then
        local result = MySQL.query.await('SELECT plate FROM owned_vehicles WHERE plate = ?', {plate})
        if result[1] == nil then
            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, stored) VALUES (?, ?, ?, ?)', {
                Player.getIdentifier(),
                plate,
                json.encode(mods),
                0
            })
            showNotification(src, locale("veh_owner"), 'success', 5000)
        else
            showNotification(src, locale("u_veh_owner"), 'error', 3000)
        end
    end
end)

-- Change Plate
RegisterNetEvent('ps-adminmenu:server:ChangePlate', function(newPlate, currentPlate)
    local newPlate = newPlate:upper()

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:UpdateVehicle(currentPlate, newPlate)
    end
    if Config.Framework == "QBCore" then
        MySQL.Sync.execute('UPDATE player_vehicles SET plate = ? WHERE plate = ?', {newPlate, currentPlate})
        MySQL.Sync.execute('UPDATE trunkitems SET plate = ? WHERE plate = ?', {newPlate, currentPlate})
        MySQL.Sync.execute('UPDATE gloveboxitems SET plate = ? WHERE plate = ?', {newPlate, currentPlate})
    end
    if Config.Framework == "ESX" then
        MySQL.Sync.execute('UPDATE owned_vehicles SET plate = ? WHERE plate = ?', {newPlate, currentPlate})
    end
end)

lib.callback.register('ps-adminmenu:getVehicleData', function(source, plate)
    local vehData = {}
    if Config.Framework == "QBCore" then
        local res = MySQL.query.await('SELECT (mods, vehicle) FROM player_vehicles WHERE plate = ?', {plate})
        vehData = res[1] or {}
        if vehData and vehData['mods'] then
            vehData['mods'] = json.decode(vehData['mods'])
        end
    end
    if Config.Framework == "ESX" then
        local res = MySQL.query.await('SELECT vehicle FROM owned_vehicles WHERE plate = ?', {plate})
        vehData = res[1] or {}
        if vehData and vehData['vehicle'] then
            vehData['mods'] = json.decode(vehData['vehicle'])
            vehData['vehicle'] = vehData['mods'].model
        end
    end
    return vehData
end)

lib.callback.register('ps-adminmenu:spawnVehicle', function(source, model, coords, warp)
    local ped = GetPlayerPed(source)
    model = type(model) == 'string' and joaat(model) or model
    if not coords then coords = GetEntityCoords(ped) end
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, true)
    while not DoesEntityExist(veh) do Wait(0) end
    if warp then
        while GetVehiclePedIsIn(ped) ~= veh do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, veh, -1)
        end
    end
    while NetworkGetEntityOwner(veh) ~= source do Wait(0) end
    local netId = NetworkGetNetworkIdFromEntity(veh)
    return netId
end)

-- lib.callback.register('ps-adminmenu:server:GetVehicleByPlate', function(source, plate)
--     local result = {}
--     MySQL.query.await('SELECT vehicle FROM player_vehicles WHERE plate = ?', {plate})
--     local veh = result[1] and result[1].vehicle or {}
--     return veh
-- end)

-- Fix Vehicle for player
RegisterNetEvent('ps-adminmenu:server:FixVehFor', function(data, selectedData)
    if not CheckPerms(data.perms) then return end
    local src = source
    local playerId = selectedData['Player'].value
    local Player = QBCore.Functions.GetPlayer(tonumber(playerId))
    if Player then
        local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
        TriggerClientEvent('iens:repaira', Player.PlayerData.source)
        TriggerClientEvent('vehiclemod:client:fixEverything', Player.PlayerData.source)
        showNotification(src, locale("veh_fixed", name), 'success', 7500)
    else
        showNotification(src, locale("not_online"), "error")
    end
end)
