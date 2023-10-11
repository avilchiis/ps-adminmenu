-- Returns a list of vehicles from QBCore.Shared.Vehicles
local function GetVehicles()
    local vehicles = {}
    if Config.Framework == "QBCore" then
        for _, v in pairs(QBCore.Shared.Vehicles) do
            vehicles[#vehicles + 1] = { label = v.name, value = v.model }
        end
    end
    if Config.Framework == "ESX" then
        for _, v in pairs(ESX_Vehicles) do
            vehicles[#vehicles + 1] = { label = v.name, value = v.model }
        end
    end
    return vehicles
end

-- Returns a list of items from QBCore.Shared.Items
local function GetItems()
    local items = {}
    local ItemsData = {}

    if Config.Framework == "QBCore" then
        ItemsData = QBCore.Shared.Items
    end

    if Config.Inventory == "ox_inventory" then
        ItemsData = exports.ox_inventory:Items()
    end

    if Config.Framework == "ESX" and Config.Inventory ~= "ox_inventory" then
        ItemsData = lib.callback.await('ps-adminmenu:callback:GetESXItems', false)
    end

    for name, v in pairs(ItemsData) do
        items[#items + 1] = { label = v.label, value = name }
    end

    return items
end

-- Returns a list of jobs from QBCore.Shared.Jobs
local function GetJobs()
    local jobs = {}
    if Config.Framework == "QBCore" then
        for name, v in pairs(QBCore.Shared.Jobs) do
            local gradeDataList = {}

            for grade, gradeData in pairs(v.grades) do
                gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = grade, isboss = gradeData.isboss }
            end

            jobs[#jobs + 1] = { label = v.label, value = name, grades = gradeDataList }
        end
    end
    
    if Config.Framework == "ESX" then
        local jobList = lib.callback.await('ps-adminmenu:callback:GetESXJobs', false)
        local gradeDataList = {}
        for k, v in pairs(jobList) do
            for grade, gradeData in pairs(v.grades) do
                gradeData['skin_male'] = nil -- Removed for better debug
                gradeData['skin_female'] = nil -- Removed for better debug
                gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = gradeData.grade, isboss = false }
            end
            jobs[#jobs + 1] = { label = v.label, value = v.name, grades = gradeDataList }
        end
    end
    return jobs
end

-- Returns a list of gangs from QBCore.Shared.Gangs
local function GetGangs()
    local gangs = {}
    if Config.Framework == "QBCore" then
        for name, v in pairs(QBCore.Shared.Gangs) do
            local gradeDataList = {}

            for grade, gradeData in pairs(v.grades) do
                gradeDataList[#gradeDataList + 1] = { name = gradeData.name, grade = grade, isboss = gradeData.isboss }
            end

            gangs[#gangs + 1] = { label = v.label, value = name, grades = gradeDataList }
        end
    end
    if Config.Framework == "ESX" then
        -- PENDING
    end
    return gangs
end

-- Returns a list of locations from QBCore.Shared.Loactions
local function GetLocations()
    local locations = {}
    if Config.Framework == "QBCore" then
        for name, v in pairs(QBCore.Shared.Locations) do
            locations[#locations + 1] = { label = name, value = v }
        end
    end
    if Config.Framework == "ESX" then
        -- PENDING
    end
    return locations
end

-- Sends data to the UI on resource start
function GetData()
    SendNUIMessage({
        action = "data",
        data = {
            vehicles = GetVehicles(),
            items = GetItems(),
            jobs = GetJobs(),
            gangs = GetGangs(),
            locations = GetLocations(),
        },
    })
end
