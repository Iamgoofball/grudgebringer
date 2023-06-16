local ovn_grudgebringers_defeat_traits = {
	["morgan_bernhardt"] = {trait = "ovn_morgan_bernhardt_defeat_trait"}
}


local function ovn_grudgebringers_get_enemy_legendary_lords_in_last_battle(character)
	local pb = cm:model():pending_battle()
	local LL_attackers = {}
	local LL_defenders = {}
	local was_attacker = false

	local num_attackers = cm:pending_battle_cache_num_attackers()
	local num_defenders = cm:pending_battle_cache_num_defenders()

	if pb:night_battle() == true or pb:ambush_battle() == true then
		num_attackers = 1
		num_defenders = 1
	end
	
	for i = 1, num_attackers do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_attacker(i)
		local char_obj = cm:model():character_for_command_queue_index(this_char_cqi)
		
		if this_char_cqi == character:cqi() then
			was_attacker = true
			break
		end
		
		if char_obj:is_null_interface() == false then
			local char_subtype = char_obj:character_subtype_key()
			
			if ovn_grudgebringers_defeat_traits[char_subtype] then
				table.insert(LL_attackers, char_subtype)
			end
		end
	end
	
	if was_attacker == false then
		return LL_attackers
	end
	
	for i = 1, num_defenders do
		local this_char_cqi, this_mf_cqi, current_faction_name = cm:pending_battle_cache_get_defender(i)
		local char_obj = cm:model():character_for_command_queue_index(this_char_cqi)
		
		if char_obj:is_null_interface() == false then
			local char_subtype = char_obj:character_subtype_key()
			
			if ovn_grudgebringers_defeat_traits[char_subtype] then
				table.insert(LL_defenders, char_subtype)
			end
		end
	end
	return LL_defenders
end

local function ovn_grudgebringers_add_defeated_trait_listeners()

    core:add_listener(
        "ovn_grudgebringers_defeat_traits_listener",
        "CharacterCompletedBattle",
        true,
        function(context)
            local character = context:character()
            if cm:char_is_general_with_army(character) and character:won_battle() then
                local enemy_LL = ovn_grudgebringers_get_enemy_legendary_lords_in_last_battle(character)
                out()
                for i = 1, #enemy_LL do
                    local LL_details = ovn_grudgebringers_defeat_traits[enemy_LL[i]]
                    
                    if LL_details ~= nil then
                        local trait = LL_details.trait	
                        out("OvN grudgebringers defeat trait is: "..trait)
                        cm:force_add_trait(cm:char_lookup_str(character),trait, true)
                    end
                end
            end
        end,
        true
    )
end


cm:add_first_tick_callback(function() ovn_grudgebringers_add_defeated_trait_listeners() end)
