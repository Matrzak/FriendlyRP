
WhiteList = {}
Banned = {}

function Exists(array,val)
	for index,value in ipairs(array) do
		if value == val then
			return true
		end
	end
	return false
end

function BanExpired(timestamp)
	local currently = os.time(os.date("!*t"))
	if timestamp <= currently then
		return true
	end
	return false
end

function RemoveBan(steamid)
	MySQL.ready(function ()
		MySQL.Sync.execute('DELETE FROM banned WHERE steamid = ' .. steamid,{},function(changed)
			print(changed)
		end)
	end)
end

function IsBanned(val)
	for index,value in ipairs(Banned) do
		if tostring(value.steamid) == tostring(val) then
			return value.reason,value.deadline,value.punisher
		end
	end
	return nil
end

function GetPlayersData()
	MySQL.ready(function () 
		MySQL.Async.fetchAll('SELECT * FROM whitelist',{}, function(user)
			for i=1, #user, 1 do
				table.insert(WhiteList,tostring(user[i].steamid))
			end
		end)
		MySQL.Async.fetchAll('SELECT * FROM banned',{}, function(banned)
			for i =1, #banned, 1 do
				table.insert(Banned,banned[i])
			end
			StartLoginController()
		end)
	end)
end

AddEventHandler('onResourceStart',function(resouce_data)
	if resouce_data == "rp_core" then
		GetPlayersData()

	end

end)

function StartLoginController()
	print("Wielkosc: " .. #WhiteList)
	Citizen.CreateThread(function()
		AddEventHandler('playerConnecting', function(name, callback, deferrals)
			local source_data = source
			print(source_data .. "trying to conenct..")

			deferrals.defer()
			deferrals.update("[FriendlyRP] Sprawdzam SteamID..")
			Wait(100)
			local whitelisted, kickReason, steamID = false, nil, GetPlayerIdentifiers(source_data)[1]

			if not string.match(steamID, 'steam:1') then
				deferrals.done("[FriendlyRP] Aplikacja STEAM musi byc wlaczona aby wejsc na server")
			end
			local string_id = string.sub(steamID,7,#steamID)
			local to_convert = tonumber(string_id,16)

			if not Exists(WhiteList, tostring(to_convert)) then
				deferrals.done("[FriendlyRP] Nie znajdujesz sie na Whitelist")
			end

			if IsBanned(to_convert) ~= nil then
				print("XD1")
				local values = {IsBanned(to_convert)}
				if values[2] == 0 then
					deferrals.done("[FriendlyRP] Zostales zbanowany permanentnie! \n Przez: " .. values[3] .. "\n Powod: " .. values[1])
				end
				if not BanExpired(tonumber(values[2])) then
					print("XD3")
					deferrals.done("[FriendlyRP] Zostales zbanowany! \n Przez: " .. values[3] .. " \n Powod: " ..
					values[1] .. " \n Data wygasniecia: " .. os.date('%Y-%m-%d %H:%M:%S', values[2]))
				else
					print("XD")
					RemoveBan(to_convert)
					deferrals.done()
				end
				
			end

			deferrals.done()

		end)
	end)
end