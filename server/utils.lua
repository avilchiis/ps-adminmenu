local function noPerms(source)
    showNotification(source, "You are not Admin or God.", 'error')
end

--- @param perms string
function CheckPerms(perms)
    local hasPerms = isAdmin(source, perms)

    if not hasPerms then
        return noPerms(source)
    end

    return hasPerms
end

---@param plate string
---@return boolean
function CheckAlreadyPlate ( plate )
    local vPlate = Trim( plate )
    local result = false
    if Config.Framework == "QBCore" then
        result = MySQL.single.await("SELECT plate FROM player_vehicles WHERE plate = ?", {vPlate})
    end
    if Config.Framework == "ESX" then
        result = MySQL.single.await("SELECT plate FROM owned_vehicles WHERE plate = ?", {vPlate})
    end
    if result and result.plate then return true end
    return false
end

lib.callback.register('ps-adminmenu:callback:CheckPerms', function(source, perms)
    return CheckPerms(perms)
end)

lib.callback.register('ps-adminmenu:callback:CheckAlreadyPlate', function (_, vPlate )
    return CheckAlreadyPlate( vPlate )
end)

lib.callback.register('ps-adminmenu:callback:GetESXItems', function ()
    if ESX.Items and not ESX.Items[1] then
        ESX = exports['es_extended']:getSharedObject() --I don't know just in case
    end
    return ESX.Items
end)

lib.callback.register('ps-adminmenu:callback:GetESXJobs', function ()
    if ESX.Jobs and not ESX.Jobs[1] then
        ESX = exports['es_extended']:getSharedObject() --I don't know just in case
    end
    return ESX.Jobs
end)

--- @param source number
--- @param target number
function CheckRoutingbucket(source, target)
    local sourceBucket = GetPlayerRoutingBucket(source)
    local targetBucket = GetPlayerRoutingBucket(target)

    if sourceBucket == targetBucket then return end

    SetPlayerRoutingBucket(source, targetBucket)
    showNotification(source, locale("bucket_set", targetBucket), 'error', 7500)
end
