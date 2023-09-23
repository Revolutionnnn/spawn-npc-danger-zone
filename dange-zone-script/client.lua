Citizen.CreateThread(function()
    local radius = 100.0
    local npcs = {}                 -- Lista para mantener una referencia a los NPCs generados en cada zona
    local separationDistance = 15.0 -- Debes definir la distancia de separación
    local Config = {}
    Config.zones = {
        { ['x'] = 96.78,             ['y'] = -1932.47,          ['z'] = 20.80 }, -- Sandy Shores PD
        { ['x'] = -1688.43811035156, ['y'] = -1073.62536621094, ['z'] = 13.1521873474121 },
        { ['x'] = -2195.1352539063,  ['y'] = 4288.7290039063,   ['z'] = 49.173923492432 }
    }

    for i = 1, #Config.zones, 1 do
        local blip = AddBlipForRadius(Config.zones[i].x, Config.zones[i].y, Config.zones[i].z, radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, 11)
        SetBlipAlpha(blip, 128)

        local x, y, z = Config.zones[i].x, Config.zones[i].y, Config.zones[i].z
        local sprite = 1 -- Reemplaza esto con el sprite que desees

        local blip1 = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip1, sprite)
        SetBlipDisplay(blip1, true)
        SetBlipScale(blip1, 0.9)
        SetBlipColour(blip1, 11)
        SetBlipAsShortRange(blip1, true)

        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local playerCoords = GetEntityCoords(PlayerPedId())
                local distance = Vdist(playerCoords.x, playerCoords.y, playerCoords.z, x, y, z)

                if distance < radius then
                    if #npcs[i] < 5 then
                        -- El jugador está dentro de la zona y no se han generado suficientes NPCs, spawnear el NPC agresivo

                        local npcModel = "g_m_y_mexgoon_03" -- Reemplaza con el modelo del NPC que desees
                        RequestModel(npcModel)
                        while not HasModelLoaded(npcModel) do
                            Citizen.Wait(1)
                        end

                        local xOffset = math.random(-separationDistance, separationDistance)
                        local yOffset = math.random(-separationDistance, separationDistance)
                        local npc = CreatePed(4, npcModel, x + xOffset, y + yOffset, z, 0, true, true)
                        SetPedRelationshipGroupHash(npc, GetHashKey("HATES_PLAYER"))
                        TaskCombatPed(npc, PlayerPedId(), 0, 1)
                        SetPedAsCop(npc, true)
                        SetEntityAsMissionEntity(npc, true, true)
                        SetEntityInvincible(npc, false)
                        SetEntityHasGravity(npc, true)
                        SetEntityCollision(npc, true, true)
                        local weaponHash = GetHashKey("weapon_vintagepistol")
                        GiveWeaponToPed(npc, weaponHash, 500, true, true)

                        table.insert(npcs[i], npc) -- Agregar el NPC generado a la lista

                        -- Puedes ajustar la lógica de la IA y otros parámetros del NPC aquí
                    end
                else
                    -- El jugador está fuera del radio, eliminar los NPCs generados en esta zona
                    for _, npc in ipairs(npcs[i]) do
                        if DoesEntityExist(npc) then
                            DeleteEntity(npc)
                        end
                    end
                    npcs[i] = {} -- Limpiar la lista de NPCs generados
                end
            end
        end)
        npcs[i] = {} -- Inicializar la lista de NPCs generados para esta zona
    end
end)
