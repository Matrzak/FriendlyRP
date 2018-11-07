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

function IsBanned(val)
	for index,value in ipairs(Banned) do
		if tostring(value.steamid) == tostring(val) then
			print ("No niezle")
			return {value.reason,value.deadline,value.punisher}
		end
	end
	return nil
end

function GetPlayersData()
	MySQL.ready(function () 
		print("OK")
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

			if not IsBanned(to_convert) == nil then
				local punisher = IsBanned(to_convert)[2]
				local deadline = IsBanned(to_convert)[1]
				local reason = IsBanned(to_convert)[0]
				deferrals.done("[FriendlyRP] Zostales zbanowany! Przez: " .. punisher .. " Za: " ..
					reason .. " Data wygasniecia: " .. deadline)
				return
			end

			if Exists(WhiteList, tostring(to_convert)) then
				deferrals.done("[FriendlyRP] Znajdujesz sie na WhiteList")
			else
				deferrals.done("[FriendlyRP] Nie znajdujesz sie na Whitelist")
			end
			deferrals.done("Ni ma przejscia")
		end)
	end)
end