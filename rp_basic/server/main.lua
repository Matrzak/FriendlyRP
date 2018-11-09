RegisterServerEvent("rp:checklocalaccount")
Accounts = {}

function ConvertRangToString(rangid)
	if rangid == 0 then
		return "Mieszkaniec"
	elseif rangid == 1 then
		return "Support"
	elseif rangid == 2 then
		return "Community Manager"
	elseif rangid == 3 then
		return "Developer"
	elseif rangid == 4 then
		return "Administrator"
	end
end

function Exists(steamid)
	for k,value in pairs(Accounts) do
		if value.steamid == steamid then
			return value
		end
	end
	return nil
end

AddEventHandler("rp:checklocalaccount", function (data)
	retrun_value = nil
	if Exists(data[1]) ~= nil then
		retrun_value = Exists(data[1])
	end
	TriggerEvent('rp:accountdata', {retrun_value})
end)

AddEventHandler("rp:createaccount", function (data)
	table.insert(Accounts,CreateAccountWithId(data[1],data[2]))
end)

