-- Freeze Player
local frozen = false
RegisterNetEvent('ps-adminmenu:server:FreezePlayer', function(data, selectedData)
    if not CheckPerms(data.perms) then return end
    local src = source

    local target = selectedData["Player"].value

    local ped = GetPlayerPed(target)
    local Player = getPlayerFromId(target)
    local fullName = getName(target)
    local identifier = getIdentifier(target)
    if not frozen then
        frozen = true
        FreezeEntityPosition(ped, true)
        showNotification(src, locale("Frozen", fullName .. " | " .. identifier), 'Success', 7500)
    else
        frozen = false
        FreezeEntityPosition(ped, false)
        showNotification(src, locale("deFrozen", fullName .. " | " .. identifier), 'Success', 7500)

    end
    if Player == nil then return showNotification(src, locale("not_online"), 'error', 7500) end

end)