ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

local societyconcessmoney = nil

concess             = {}
concess.DrawDistance = 100
concess.Size         = {x = 1.0, y = 1.0, z = 1.0}
concess.Color        = {r = 255, g = 0, b = 0}
concess.Type         = 20

swann_conc = {
	catevehi = {},
	listecatevehi = {},
}

local derniervoituresorti = {}
local sortirvoitureacheter = {}

--travail concess




position = {
    {
        Zones = "Zones1",
        x= -771.48, y= -226.61, z= 37.74
    },
}

InZone = {}
local interval = 1000



Citizen.CreateThread(function()
    while true do
        Citizen.Wait(interval)
        for k,v in pairs(position)do 
            local pCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local distance = Vdist(pCoords.x, pCoords.y, pCoords.z, posammu[k].x, posammu[k].y, posammu[k].z)
            if distance <= 7.0  then
                interval = 0
                InZone[v.Zones] = true
                DrawMarker(concess.Type, position[k].x, position[k].y, position[k].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, concess.Size.x, concess.Size.y, concess.Size.z, concess.Color.r, concess.Color.g, concess.Color.b, 100, false, true, 2, false, false, false, false)
            else
                if InZone[v.Zones] then
                    interval = 1000
                    InZone[v.Zones] = false
                end
            end
            if distance <= 2.0 then
                interval = 0
                InZone[v.Zones] = true 
                RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ pour accéder au catalogue automobil", time_display = 1 })
                if IsControlJustPressed(1,51) then           
                    ESX.TriggerServerCallback('swann_concess:recuperercategorievehicule', function(catevehi)
                        swann_conc.catevehi = catevehi
                    end)
                    concesscata = false
                    ouvrircatalogue()
                    end
            end  
        end
    end
end)

--point vente
local concesscata = false
RMenu.Add('concessvente', 'main', RageUI.CreateMenu("Catalogue", "Liste des vehicules en stock"))
RMenu.Add('concessvente', 'listevehicule', RageUI.CreateSubMenu(RMenu:Get('concessvente', 'main'), "Catalogue", "Pour voir les véhicules en stock"))
RMenu.Add('concessvente', 'categorievehicule', RageUI.CreateSubMenu(RMenu:Get('concessvente', 'listevehicule'), "Véhicules", "Pour voir les véhicules en stock"))
RMenu.Add('concessvente', 'testvehicule', RageUI.CreateSubMenu(RMenu:Get('concessvente', 'categorievehicule'), "Véhicules", "Tester le véhicule"))
RMenu:Get('concessvente', 'main').Closed = function()
    concesscata = false
end
RMenu:Get('concessvente', 'categorievehicule').Closed = function()
    fairedisparaitrelevehiculeconcess()
end

function ouvrircatalogue()
    if not concesscata then
        concesscata = true
        RageUI.Visible(RMenu:Get('concessvente', 'main'), true)
    while concesscata do

        RageUI.IsVisible(RMenu:Get('concessvente', 'main'), true, true, true, function()
           
            RageUI.ButtonWithStyle("Catalogue véhicules", nil, {RightBadge = RageUI.BadgeStyle.Car},true, function()
           end, RMenu:Get('concessvente', 'listevehicule'))

           RageUI.Separator("Faites la touche retour pour quitter le menu")
    
            end, function()
            end)

        RageUI.IsVisible(RMenu:Get('concessvente', 'listevehicule'), true, true, true, function()
            RageUI.Separator("↓ Les catégorie ↓")
        	for i = 1, #swann_conc.catevehi, 1 do
            RageUI.ButtonWithStyle(" "..swann_conc.catevehi[i].label, nil, {RightBadge = RageUI.BadgeStyle.Car},true, function(Hovered, Active, Selected)
            if (Selected) then
            		nomcategorie = swann_conc.catevehi[i].label
                    categorievehi = swann_conc.catevehi[i].name
                    ESX.TriggerServerCallback('swann_concess:recupererlistevehicule', function(listevehi)
                            swann_conc.listecatevehi = listevehi
                    end, categorievehi)
                end
            end, RMenu:Get('concessvente', 'categorievehicule'))
        	end
            end, function()
            end)

        RageUI.IsVisible(RMenu:Get('concessvente', 'categorievehicule'), true, true, true, function()
        	RageUI.Separator("↓ "..nomcategorie.." ↓")

        	for i2 = 1, #swann_conc.listecatevehi, 1 do
            RageUI.ButtonWithStyle(swann_conc.listecatevehi[i2].name, "Les prix d'achat sont 40% supérieurs à ceux affichés", {RightLabel = swann_conc.listecatevehi[i2].price.."$"},true, function(Hovered, Active, Selected)
            if (Selected) then
            		nomvoiture = swann_conc.listecatevehi[i2].name
            		prixvoiture = swann_conc.listecatevehi[i2].price
            		modelevoiture = swann_conc.listecatevehi[i2].model
            		fairedisparaitrelevehiculeconcess()
					chargementvoiture(modelevoiture)

                    local pos = GetEntityCoords(PlayerPedId())
					ESX.Game.SpawnLocalVehicle(modelevoiture, {x = -777.40, y = -230.38, z = 37.14}, 210.25, function (vehicle)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
					table.insert(derniervoituresorti, vehicle)
					FreezeEntityPosition(vehicle, true)
					SetModelAsNoLongerNeeded(modelevoiture)
					end)
                end
            end, RMenu:Get('concessvente', 'testvehicule'))

        	end
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get('concessvente', 'testvehicule'), true, true, true, function()
                
                RageUI.ButtonWithStyle("Tester le vehicule", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered, Active, Selected)
                    if (Selected) then
                            cooldown = false
                        testveh()
                        ESX.Game.SpawnLocalVehicle(modelevoiture, {x = -916.540, y = -3284.19, z = 13.94}, 58.16, function (vehicle)
                            TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                            table.insert(derniervoituresorti, vehicle)
                            SetModelAsNoLongerNeeded(modelevoiture)
                            end)
                        cooldown = true
                        Citizen.SetTimeout("30000", function()
                            cooldown = false
                            testdelete()
                            SetEntityCoords(GetPlayerPed(-1), -771.48,-226.61,37.74)
                        end)
                        ESX.ShowNotification("~b~Vous êtes dans le véhicule de test")
                        timer()
                    end
                end, RMenu:Get('concessvente', 'main'))

            end,function()
            end)

            Citizen.Wait(0)
        end
    else
        concesscata = false
    end
end



function fairedisparaitrelevehiculeconcess()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

		ESX.Game.DeleteVehicle(vehicle)
        ExecuteCommand("tp -771.48,-226.61,37.74")
		table.remove(derniervoituresorti, 1)
	end
end

function testveh()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

        ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end


function testdelete()
	while #derniervoituresorti > 0 do
		local vehicle = derniervoituresorti[1]

        ESX.Game.DeleteVehicle(vehicle)
		table.remove(derniervoituresorti, 1)
	end
end

function chargementvoiture(modelHash)
	modelHash = (type(modelHash) == 'number' and modelHash or GetHashKey(modelHash))

	if not HasModelLoaded(modelHash) then
		RequestModel(modelHash)

		BeginTextCommandBusyString('STRING')
		AddTextComponentSubstringPlayerName('shop_awaiting_model')
		EndTextCommandBusyString(4)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
			DisableAllControlActions(0)
		end

		RemoveLoadingPrompt()
	end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)


    AddTextEntry('FMMC_KEY_TIP1', TextEntry) 
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    blockinput = true

    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Citizen.Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult() 
        Citizen.Wait(500) 
        blockinput = false
        return result 
    else
        Citizen.Wait(500) 
        blockinput = false 
        return nil 
    end
end

------------

function timer()
    Citizen.SetTimeout("1000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 29s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("2000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 28s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("3000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 27s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("4000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 26s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("5000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 25s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("6000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 24s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("7000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 23s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("8000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 22s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("9000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 21s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("10000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 20s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("11000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 19s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("12000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 18s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("13000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 17s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("14000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 16s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("15000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 15s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("16000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 14s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("17000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 13s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("18000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 12s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("19000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 11s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("20000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 10s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("21000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 9s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("22000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 8s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("23000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 7s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("24000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 6s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("25000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 5s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("26000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 4s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("27000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 3s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("28000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 2s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("29000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~r~Il vous reste 1s",
                time_display = 4555555555555
            })
    end)
    Citizen.SetTimeout("30000", function()
        cooldown = false
        RageUI.Text({
            message = "~h~~g~Le temps est terminé je vous souhaite une agréable journée",
                time_display = 5000
            })
    end)
end