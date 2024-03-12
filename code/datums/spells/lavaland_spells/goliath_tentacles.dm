/obj/effect/proc_holder/spell/goliath_tentacles
	name = "Summon Tentacles"
	desc = "Summons a goliath tentacle attack on clicked tile"
	school = "lavaland"
	base_cooldown = 15 SECONDS
	clothes_req = TRUE
	human_req = TRUE
	invocation = "SOGESE DE RAGET'RE!"
	invocation_type = "shout"
	action_icon_state = "goliath_tentacles"
	need_active_overlay = TRUE

/obj/effect/proc_holder/spell/goliath_tentacles/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom

/obj/effect/proc_holder/spell/goliath_tentacles/cast(list/targets, mob/user = usr)
	var/turf/target_turf = get_turf(targets[1])
	new /obj/effect/temp_visual/goliath_tentacle/full_cross(target_turf, user)
