-- Triggers the notification client event
function showNotification(source, msg, type)
    if not source or not tonumber(source) then
        return -- I don't know, just in case
    end
    TriggerClientEvent('ps-admin:notification', source, msg, type)
end

-- Verify if is admin and is on duty (only available on QBCore?)
function isAdmin(player, perms)
    if Config.Framework == "QBCore" then
        if QBCore.Functions.HasPermission(player, perms) or IsPlayerAceAllowed(player, 'command') then
            return true
        end
    end
    if Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(player)
        if type(perms) == "table" then
            local myGroup = xPlayer.getGroup()
            for k, v in pairs(perms) do
                if myGroup == v then
                    return true
                end
            end
        else
            return xPlayer.getGroup() == perms
        end
    end
    return false
end

-- Get Player Identifier
function getIdentifier(src)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.identifier
        end
    end
    return false
end

-- Get a player by source ID
function getPlayerFromId(source)
    if Config.Framework == "QBCore" then
        return QBCore.Functions.GetPlayer(source)
    end
    if Config.Framework == "ESX" then
        return ESX.GetPlayerFromId(source)
    end
end

-- Get Player Name
function getName(src)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname
        end
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getName()
        end
    end
    return false
end

-- Add Item to player
function addItem(src,item,amount,info)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddItem(item,amount,false,info)
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer.canCarryItem(item,amount) then
            xPlayer.addInventoryItem(item,amount,info)
        end
    end
end

-- Retrieve all online players
function getAllPlayers()
    if Config.Framework == "QBCore" then
        return QBCore.Functions.GetQBPlayers()
    end
    if Config.Framework == "ESX" then
        return ESX.GetExtendedPlayers()
    end
end

-- Get Player money
function getMoney(src, account)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            return Player.PlayerData.money[account]
        end
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.getAccount(account).money
        end
    end
    return 0
end

-- Add Money
function addMoney(src, account, amount)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.AddMoney(account,amount)
            return true
        end
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.addAccountMoney(account,amount)
            return true
        end
    end
    return false
end

-- Remove money from player
function removeMoney(src, account, amount, reason)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            Player.Functions.RemoveMoney(account,amount,reason)
        end
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            xPlayer.removeAccountMoney(account,amount)
        end
    end
end

-- Get specific identifier
function getMyIdentifier(source,idtype)
    local identifiers = GetPlayerIdentifiers(source)
    for _, identifier in pairs(identifiers) do
        if string.find(identifier, idtype) then
            return identifier
        end
    end
    return nil
end

function setJobGrade(identifier,job,grade)
    if Config.Framework == "QBCore" then
        local Player = QBCore.Functions.GetPlayerByCitizenId(identifier)
        local jobData = QBCore.Shared.Jobs[job]['grades'][grade]
        if Player then
            Player.Functions.SetJob(job,grade)
        end
        local info = {
            name = job,
            onduty = true,
            isboss = jobData['isboss'],
            payment = jobData['payment'],
            grade = {name = jobData['name'], level = 0}
        }
        MySQL.update.await('UPDATE players SET job = ? WHERE citizenid = ?', {json.encode(info),identifier})
    elseif Config.Framework == "ESX" then
        local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
        if xPlayer then
            xPlayer.setJob(job,grade)
        end
        MySQL.update.await('UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?', {job, grade, identifier})
    end
end

-- QBCore Trim but without QBCore:
function Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end