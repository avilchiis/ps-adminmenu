local function GetVehicleName(hash)
    if Config.Framework == "QBCore" then
        for _, v in pairs(QBCore.Shared.Vehicles) do
            if hash == v.hash then
                return v.model
            end
        end
    end
    if Config.Framework == "ESX" then
        for _, v in pairs(ESX_Vehicles) do
            if hash == v.hash then
                return v.model
            end
        end
    end
end

-- Own Vehicle
RegisterNetEvent('ps-adminmenu:client:Admincar', function(data)
    if not CheckPerms(data.perms) then return end
    if not cache.vehicle then return end

    local props = lib.getVehicleProperties(cache.vehicle)
    local name = GetVehicleName(props.model)
    local sharedVehicles = false
    local hash = GetHashKey(cache.vehicle)

    if Config.Framework == "QBCore" then
        sharedVehicles = QBCore.Shared.Vehicles[name]
        if sharedVehicles then
            TriggerServerEvent('ps-adminmenu:server:SaveCar', props, sharedVehicles, hash, props.plate)
        else
            showNotification(locale("cannot_store_veh"), 'error')
        end
    end
    if Config.Framework == "ESX" then
        TriggerServerEvent('ps-adminmenu:server:SaveCar', props, nil, hash, props.plate)
    end
end)

-- Spawn Vehicle
RegisterNetEvent('ps-adminmenu:client:SpawnVehicle', function(data, selectedData)
    if not CheckPerms(data.perms) then return end

    local selectedVehicle = selectedData["Vehicle"].value
    local hash = GetHashKey(selectedVehicle)

    if not IsModelValid(hash) then return end

    lib.requestModel(hash)

    if cache.vehicle then
        DeleteVehicle(cache.vehicle)
    end

    local vehicle = CreateVehicle(hash, GetEntityCoords(cache.ped), GetEntityHeading(cache.ped), true, false)
    TaskWarpPedIntoVehicle(cache.ped, vehicle, -1)
    exports[Config.Fuel]:SetFuel(vehicle, 100.0)
    giveKeys(getPlates(vehicle))
end)

-- Refuel Vehicle
RegisterNetEvent('ps-adminmenu:client:RefuelVehicle', function(data)
    if not CheckPerms(data.perms) then return end

    if cache.vehicle then
        exports[Config.Fuel]:SetFuel(cache.vehicle, 100.0)
        showNotification(locale("refueled_vehicle"), 'success')
    else
        showNotification(locale("not_in_vehicle"), 'error')
    end
end)

-- Change plate
RegisterNetEvent('ps-adminmenu:client:ChangePlate', function(data, selectedData)
    if not CheckPerms(data.perms) then return end
    local plate = selectedData["Plate"].value

    if string.len(plate) > 8 then
        return showNotification(locale("plate_max"), "error", 5000)
    end

    if cache.vehicle then
        local AlreadyPlate = lib.callback.await("ps-adminmenu:callback:CheckAlreadyPlate", false, plate)
    
        if AlreadyPlate then
            showNotification(locale("already_plate"), "error", 5000)
            return
        end
            
        local currentPlate = GetVehicleNumberPlateText( cache.vehicle)
        TriggerServerEvent('ps-adminmenu:server:ChangePlate', plate, currentPlate)
        Wait(100)
        SetVehicleNumberPlateText(cache.vehicle, plate)
        Wait(100)
        giveKeys(getPlates(cache.vehicle), true)
    else
        showNotification(locale("not_in_vehicle"), 'error')
    end
end)


-- Toggle Vehicle Dev mode
local VEHICLE_DEV_MODE = false
local function UpdateVehicleMenu()
    while VEHICLE_DEV_MODE do
        Wait(1000)

        local vehicle = lib.getVehicleProperties(cache.vehicle)
        local name = GetVehicleName(vehicle.model)
        local netID = VehToNet(cache.vehicle)

        SendNUIMessage({
            action = "showVehicleMenu",
            data = {
                show = VEHICLE_DEV_MODE,
                name = name,
                model = vehicle.model,
                netID = netID,
                engine_health = vehicle.engineHealth,
                body_health = vehicle.bodyHealth,
                plate = vehicle.plate,
                fuel = vehicle.fuelLevel,
            }
        })
    end
end

RegisterNetEvent('ps-adminmenu:client:ToggleVehDevMenu', function(data)
    if not CheckPerms(data.perms) then return end
    if not cache.vehicle then return end

    VEHICLE_DEV_MODE = not VEHICLE_DEV_MODE

    if VEHICLE_DEV_MODE then
        CreateThread(UpdateVehicleMenu)
    end
end)

-- Max Mods
local PERFORMANCE_MOD_INDICES = { 11, 12, 13, 15, 16 }
local function UpgradePerformance(vehicle)
    SetVehicleModKit(vehicle, 0)
    ToggleVehicleMod(vehicle, 18, true)
    SetVehicleFixed(vehicle)

    for _, modType in ipairs(PERFORMANCE_MOD_INDICES) do
        local maxMod = GetNumVehicleMods(vehicle, modType) - 1
        SetVehicleMod(vehicle, modType, maxMod, customWheels)
    end

    showNotification(locale("vehicle_max_modded"), 'success', 7500)
end


RegisterNetEvent('ps-adminmenu:client:maxmodVehicle', function(data)
    if not CheckPerms(data.perms) then return end

    if cache.vehicle then
        UpgradePerformance(cache.vehicle)
    else
        showNotification(locale("vehicle_not_driver"), 'error', 7500)
    end
end)

-- Spawn Personal vehicles

RegisterNetEvent("ps-adminmenu:client:SpawnPersonalvehicle", function(data, selectedData)
    if not CheckPerms(data.perms) then return end
    local plate = selectedData['VehiclePlate'].value
    local ped = PlayerPedId()
    local coords = getCoords(ped)
    local cid = getIdentifier()
    local props = false
    local vehData = lib.callback.await('ps-adminmenu:getVehicleData', false, plate)
    props = vehData['mods']
    lib.callback('ps-adminmenu:spawnVehicle', false, function(vehicle)
        local veh = NetToVeh(vehicle)
        SetEntityHeading(veh, coords.w)
        TaskWarpPedIntoVehicle(ped, veh, -1)
        SetVehicleModKit(veh, 0)
        Wait(100)
        setVehicleProperties(veh, props)
        SetVehicleNumberPlateText(veh, plate)
        exports[Config.Fuel]:SetFuel(veh, 100.0)
        giveKeys(plate)
    end, vehData.vehicle, coords, true)
end)
