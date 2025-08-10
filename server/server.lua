local RSGCore = exports['rsg-core']:GetCoreObject()

---------------------------------
-- use shovel
---------------------------------
RSGCore.Functions.CreateUseableItem('shovel', function(source, item)
    local src = source
    TriggerClientEvent('rex-digging:client:dig', src, 'anywhere')
end)

---------------------------------
-- give reward item
---------------------------------
RegisterNetEvent('rex-digging:server:givereward', function(digtype, outlawstatus)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    if not Player then return end
    if digtype == 'anywhere' then
        local randomItem = Config.RandomItems[math.random(#Config.RandomItems)]
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomItem], 'add', 1)
    end
    if digtype == 'grave' then
        local randomItem = Config.GraveyardItems[math.random(#Config.GraveyardItems)]
        Player.Functions.AddItem(randomItem, 1)
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[randomItem], 'add', 1)
        -- udpate outlaw status
        local newoutlawstatus = (outlawstatus + Config.OutlawStatusAdd)
        MySQL.update('UPDATE players SET outlawstatus = ? WHERE citizenid = ?', { newoutlawstatus, citizenid })
    end
end)
