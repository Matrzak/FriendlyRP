free_index = 1
function CreateAccountWithId(steam_id,rang_id)
	local self = {}

	self.steamid = steam_id
	self.rangid = rang_id
	self.session_id = free_index
	free_index = free_index + 1
	return self
end