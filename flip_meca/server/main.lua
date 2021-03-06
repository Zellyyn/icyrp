-----------------------------------------------------------------------
------------------------ INSONIA RP - PORTUGAL ------------------------
-----------------------------------------------------------------------
-------------------------    VERSION - B1G     ------------------------
-----------------------------------------------------------------------

ESX                = nil
local PlayersHarvesting  = {}
local PlayersCrafting = {}
local PlayersCrafting2 = {}
local PlayersCrafting3 = {}
local Vehicles = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

TriggerEvent('esx_phone:registerNumber', 'mecanico', _U('mecanico'), true, true)
TriggerEvent('esx_society:registerSociety', 'mecanico', 'mecanico', 'society_mecanico', 'society_mecanico', 'society_mecanico', {type = 'public'})

function Harvest(source,item)
	if PlayersHarvesting[source] == true then
		local xPlayer = ESX.GetPlayerFromId(source)
		local CaroToolQuantity = 0
		CaroToolQuantity = xPlayer.getInventoryItem(item).count
		if CaroToolQuantity >= 5 then
			TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Inventário cheio!', length = 2500, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
		else
			TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mecanico', function(account)
				if account.money >= Config.BuyItems then
					account.removeMoney(Config.BuyItems)
					xPlayer.addInventoryItem(item, 1)
					CaroToolQuantity = xPlayer.getInventoryItem(item).count
					TriggerClientEvent('attach:prop_cs_cardbox_01', source)
					TriggerEvent('esx_mecanicojob:stopHarvest', source)
				end
			end)
			if CaroToolQuantity == 5 then
				TriggerClientEvent('mythic_notify:client:SendAlert', source, { type = 'error', text = 'Inventário cheio!', length = 2500, style = { ['background-color'] = '#ffffff', ['color'] = '#000000' } })
			end
		end
	end
end

RegisterServerEvent('esx_mecanicojob:startHarvest')
AddEventHandler('esx_mecanicojob:startHarvest', function(item)
	local _source = source
	local _item = item
	print(_item)
	PlayersHarvesting[_source] = true
	Harvest(_source,_item)
end)

RegisterServerEvent('esx_mecanicojob:stopHarvest')
AddEventHandler('esx_mecanicojob:stopHarvest', function()
	local _source = source
	PlayersHarvesting[_source] = false
	TriggerClientEvent('esx_mecanicojob:Stopmecanico', _source)
end)

local function Craft(source)
	SetTimeout(4000, function()

		if PlayersCrafting[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local GazBottleQuantity = xPlayer.getInventoryItem('gazbottle').count
			if GazBottleQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_gas_can'))
			else
				xPlayer.removeInventoryItem('gazbottle', 1)
				xPlayer.addInventoryItem('blowpipe', 1)
				Craft(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mecanicojob:startCraft')
AddEventHandler('esx_mecanicojob:startCraft', function()
	local _source = source
	PlayersCrafting[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_blowtorch'))
	Craft(_source)
end)

RegisterServerEvent('esx_mecanicojob:stopCraft')
AddEventHandler('esx_mecanicojob:stopCraft', function()
	local _source = source
	PlayersCrafting[_source] = false
end)

local function Craft2(source)
	SetTimeout(4000, function()

		if PlayersCrafting2[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local FixToolQuantity = xPlayer.getInventoryItem('fixtool').count

			if FixToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_repair_tools'))
			else
				xPlayer.removeInventoryItem('fixtool', 1)
				xPlayer.addInventoryItem('fixkit', 1)
				Craft2(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mecanicojob:startCraft2')
AddEventHandler('esx_mecanicojob:startCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_repair_kit'))
	Craft2(_source)
end)

RegisterServerEvent('esx_mecanicojob:stopCraft2')
AddEventHandler('esx_mecanicojob:stopCraft2', function()
	local _source = source
	PlayersCrafting2[_source] = false
end)

local function Craft3(source)
	SetTimeout(4000, function()

		if PlayersCrafting3[source] == true then
			local xPlayer = ESX.GetPlayerFromId(source)
			local CaroToolQuantity = xPlayer.getInventoryItem('carotool').count

			if CaroToolQuantity <= 0 then
				TriggerClientEvent('esx:showNotification', source, _U('not_enough_body_tools'))
			else
				xPlayer.removeInventoryItem('carotool', 1)
				xPlayer.addInventoryItem('carokit', 1)
				Craft3(source)
			end
		end

	end)
end

RegisterServerEvent('esx_mecanicojob:startCraft3')
AddEventHandler('esx_mecanicojob:startCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = true
	TriggerClientEvent('esx:showNotification', _source, _U('assembling_body_kit'))
	Craft3(_source)
end)

RegisterServerEvent('esx_mecanicojob:setJob')
AddEventHandler('esx_mecanicojob:setJob', function(identifier,job,grade)
	local xTarget = ESX.GetPlayerFromIdentifier(identifier)
		
		if xTarget then
			xTarget.setJob(job, grade)
		end

end)


RegisterServerEvent('esx_mecanicojob:stopCraft3')
AddEventHandler('esx_mecanicojob:stopCraft3', function()
	local _source = source
	PlayersCrafting3[_source] = false
end)

RegisterServerEvent('esx_mecanicojob:getStockItem')
AddEventHandler('esx_mecanicojob:getStockItem', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mecanico', function(inventory)
		local item = inventory.getItem(itemName)
		local sourceItem = xPlayer.getInventoryItem(itemName)

		-- is there enough in the society?
		if count > 0 and item.count >= count then

			-- can the player carry the said amount of x item?
			if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
			else
				inventory.removeItem(itemName, count)
				xPlayer.addInventoryItem(itemName, count)
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', count, item.label))
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end
	end)
end)

ESX.RegisterServerCallback('esx_mecanicojob:getStockItems', function(source, cb)
	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mecanico', function(inventory)
		cb(inventory.items)
	end)
end)

RegisterServerEvent('esx_mecanicojob:forceBlip')
AddEventHandler('esx_mecanicojob:forceBlip', function()
	TriggerClientEvent('esx_mecanicojob:updateBlip', -1)
end)

AddEventHandler('onResourceStart', function(resource)
	if resource == GetCurrentResourceName() then
		Citizen.Wait(5000)
		TriggerClientEvent('esx_mecanicojob:updateBlip', -1)
	end
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('esx_phone:removeNumber', 'mecanico')
	end
end)

RegisterServerEvent('esx_mecanicojob:message')
AddEventHandler('esx_mecanicojob:message', function(target, msg)
	TriggerClientEvent('esx:showNotification', target, msg)
end)

RegisterServerEvent('esx_mecanicojob:putStockItems')
AddEventHandler('esx_mecanicojob:putStockItems', function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)

	TriggerEvent('esx_addoninventory:getSharedInventory', 'society_mecanico', function(inventory)
		local item = inventory.getItem(itemName)
		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		if item.count >= 0 and count <= playerItemCount then
			xPlayer.removeInventoryItem(itemName, count)
			inventory.addItem(itemName, count)
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
		end

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, item.label))
	end)
end)

ESX.RegisterServerCallback('esx_mecanicojob:getPlayerInventory', function(source, cb)
	local xPlayer    = ESX.GetPlayerFromId(source)
	local items      = xPlayer.inventory

	cb({items = items})
end)

RegisterServerEvent('esx_mecanicojob:SVdestroyDoor')
AddEventHandler('esx_mecanicojob:SVdestroyDoor', function()
	local id = source
	TriggerClientEvent('esx_mecanicojob:destroyDoor', id)
end)

RegisterServerEvent('esx_mecanicojob:buyMod')
AddEventHandler('esx_mecanicojob:buyMod', function(price)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	price = tonumber(price)

	local societyAccount = nil
		TriggerEvent('esx_addonaccount:getSharedAccount', 'society_mecanico', function(account)
			societyAccount = account
		end)
		if price < societyAccount.money then
			TriggerClientEvent('esx_mecanicojob:installMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('purchased'))
			societyAccount.removeMoney(price)
		else
			TriggerClientEvent('esx_mecanicojob:cancelInstallMod', _source)
			TriggerClientEvent('esx:showNotification', _source, _U('not_enough_money'))
		end
end)

RegisterServerEvent('esx_mecanicojob:refreshOwnedVehicle')
AddEventHandler('esx_mecanicojob:refreshOwnedVehicle', function(vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT vehicle FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = vehicleProps.plate
	}, function(result)
		if result[1] then
			local vehicle = json.decode(result[1].vehicle)

			if vehicleProps.model == vehicle.model then
				MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE plate = @plate', {
					['@plate'] = vehicleProps.plate,
					['@vehicle'] = json.encode(vehicleProps)
				})
			else
				print(('esx_mecanicojob: %s attempted to upgrade vehicle with mismatching vehicle model!'):format(xPlayer.identifier))
			end
		end
	end)
end)

ESX.RegisterServerCallback('esx_mecanicojob:getVehiclesPrices', function(source, cb)
	if not Vehicles then
		MySQL.Async.fetchAll('SELECT * FROM vehicles', {}, function(result)
			local vehicles = {}

			for i=1, #result, 1 do
				table.insert(vehicles, {
					model = result[i].model,
					price = result[i].price
				})
			end

			Vehicles = vehicles
			cb(Vehicles)
		end)
	else
		cb(Vehicles)
	end
end)

ESX.RegisterUsableItem('blowpipe', function(source)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('blowpipe', 1)

	TriggerClientEvent('esx_mecanicojob:onHijack', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('you_used_blowtorch'))
end)

ESX.RegisterUsableItem('fixkit', function(source)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('fixkit', 1)

	TriggerClientEvent('esx_mecanicojob:onFixkit', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('you_used_repair_kit'))
end)

ESX.RegisterUsableItem('carokit', function(source)
	local _source = source
	local xPlayer  = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('carokit', 1)

	TriggerClientEvent('esx_mecanicojob:onCarokit', _source)
	TriggerClientEvent('esx:showNotification', _source, _U('you_used_body_kit'))
end)

