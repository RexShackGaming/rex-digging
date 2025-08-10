local RSGCore = exports['rsg-core']:GetCoreObject()
local isDigging = false
local createdObjects = {}
lib.locale()

CreateThread(function()
    exports.ox_target:addModel(Config.Gravestones, {
        {
            name = 'gravestone',
            icon = 'far fa-eye',
            label = locale('cl_lang_5'),
            onSelect = function()
                TriggerEvent('rex-digging:client:dig', 'grave')
            end,
            distance = 2.0
        }
    })
end)

---------------------------------
-- dig workings
---------------------------------
RegisterNetEvent('rex-digging:client:dig', function(digtype)
    local hasItem = RSGCore.Functions.HasItem('shovel', 1)
    if not hasItem then
        lib.notify({ title = locale('cl_lang_3'), type = 'error', duration = 5000 })
        return
    end
    local playerCoords = GetEntityCoords(cache.ped, true)
    local nearestObject = nil
    local nearestObjectDistance = nil

    for _, obj in ipairs(createdObjects) do
        local objCoords = GetEntityCoords(obj)
        local distance = #(playerCoords - objCoords)
        if not nearestObjectDistance or distance < nearestObjectDistance then
            nearestObjectDistance = distance
            nearestObject = obj
        end
    end

    if nearestObject and nearestObjectDistance <= Config.HoleDistance then
        Wait(500)
        lib.notify({ title = locale('cl_lang_1'), type = 'info', duration = 7000 })
        return
    end
    
    if not isDigging then
        isDigging = true
        local waitrand = math.random(10000, 25000)
        local chance = math.random(100)
        local dirt = 'mp005_p_dirtpile_tall_unburied'
        
        RequestModel(dirt)
        while not HasModelLoaded(dirt) do
            Wait(1)
        end

        RequestAnimDict("amb_work@world_human_gravedig@working@male_b@base")
        while not HasAnimDictLoaded("amb_work@world_human_gravedig@working@male_b@base") do
            Wait(100)
        end

        local coords = GetEntityCoords(cache.ped)
        local boneIndex = GetEntityBoneIndexByName(cache.ped, "SKEL_R_Hand")
        shovelObject = CreateObject(GetHashKey("p_shovel02x"), coords, true, true, true)
        SetCurrentPedWeapon(cache.ped, `WEAPON_UNARMED`, true)
        AttachEntityToEntity(shovelObject, cache.ped, boneIndex, 0.0, -0.19, -0.089, 274.1899, 483.89, 378.40, true, true, false, true, 1, true)

        FreezeEntityPosition(cache.ped, true)
        TaskPlayAnim(cache.ped, "amb_work@world_human_gravedig@working@male_b@base", "base", 3.0, 3.0, -1, 1, 0, false, false, false)
        Wait(waitrand)
        
        local playerCoords = GetEntityCoords(cache.ped)
        local playerForwardVector = GetEntityForwardVector(cache.ped)
        local offsetX = 0.6 

        local objectX = playerCoords.x + playerForwardVector.x * offsetX
        local objectY = playerCoords.y + playerForwardVector.y * offsetX
        local objectZ = playerCoords.z - 1

        object = CreateObject(dirt, objectX, objectY, objectZ, true, true, false)
        table.insert(createdObjects, object) 
        objectIndex = #createdObjects

        if digtype == 'anywhere' then
            if chance <= Config.AnywhereRewardChance then
                TriggerServerEvent('rex-digging:server:givereward', digtype)
            else
                lib.notify({ title = locale('cl_lang_2'), type = 'info', duration = 7000 })
            end
        end
        
        if digtype == 'grave' then
            RSGCore.Functions.TriggerCallback('hud:server:getoutlawstatus', function(result)
                if Config.LawAlertActive then
                    local random = math.random(100)
                    if random <= Config.LawAlertChance then
                        local coords = GetEntityCoords(cache.ped)
                        TriggerEvent('rsg-lawman:client:lawmanAlert', coords, locale('cl_lang_4'))
                    end
                end
                if chance <= Config.GraveRewardChance then
                    outlawstatus = result[1].outlawstatus
                    TriggerServerEvent('rex-digging:server:givereward', digtype, outlawstatus)
                else
                    lib.notify({ title = locale('cl_lang_2'), type = 'info', duration = 7000 })
                end
            end)
        end

        FreezeEntityPosition(cache.ped, false)
        ClearPedTasks(cache.ped)
        DeleteObject(shovelObject)
        isDigging = false
    end
end)
