-- I made this functions to make it compatible with ESX and QBCore, don't modify anything if u don't know what are u doing...
function getPlayerData(xPlayer)
    if Config.Framework == "QBCore" then
        return QBCore.Functions.GetPlayerData()
    end
    if Config.Framework == "ESX" then
        local myData = ESX.PlayerData
        if xPlayer then myData = xPlayer end
        myData.citizenid = myData.identifier
        myData.name = myData.firstName.." "..myData.lastName
        myData.charinfo = myData.charinfo or {}
        myData.charinfo.firstname = myData.firstName
        myData.charinfo.lastname = myData.lastName
        return myData
    end
end

-- Notifications:
function showNotification(msg, type)
    lib.notify({
        title = 'PS Admin Menu',
        description = msg,
        type = type
    })
end

RegisterNetEvent('ps-admin:notification', function(msg, type) -- Receives notifications from server
    showNotification(msg, type)
end)

-- Get Player identifier:
function getIdentifier()
    if Config.Framework == "QBCore" then
        return QBCore.Functions.GetPlayerData().citizenid
    end
    if Config.Framework == "ESX" then
        local myData = ESX.PlayerData
        return myData.identifier
    end
end

-- QBCore round but without QBCore:
function Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

-- Get vehicle plates
function getPlates(vehicle)
    if not vehicle or vehicle == 0 then
        print("getPlates() missing vehicle (?)")
        return 
    end
    return Trim(GetVehicleNumberPlateText(vehicle))
end

-- QBCore Trim but without QBCore:
function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

-- Give vehicle keys
function giveKeys(plates, server)
    if not plates then
        print("giveKeys() missing plates (?)")
        return
    end
    if Config.Framework == "QBCore" then
        if server then
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plates)
        else
            TriggerEvent("vehiclekeys:client:SetOwner", plates)
        end
        return
    end
    if Config.Framework == "ESX" then

    end
end

-- Get Entity Coords:
function getCoords(entity)
    return vector4(GetEntityCoords(entity), GetEntityHeading(entity))
end

-- Set Veh Properties:
function setVehicleProperties(vehicle, props)
    if Config.Framework == "QBCore" then
        return QBCore.Functions.SetVehicleProperties(vehicle, props)
    end
    if Config.Framework == "ESX" then
        return ESX.Game.SetVehicleProperties(vehicle, props)
    end
end