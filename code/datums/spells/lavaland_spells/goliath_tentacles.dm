/obj/effect/proc_holder/spell/goliath_tentacles
	name = "Summon Tentacles"
	desc = ""
	school = "lavaland"
	base_cooldown = 15 SECONDS
	clothes_req = TRUE
	human_req = TRUE
	invocation = "SOGESE DE RAGET'RE!"
	invocation_type = "shout"
	action_icon_state = "barn"
	need_active_overlay = TRUE

/obj/effect/proc_holder/spell/goliath_tentacles/create_new_targeting()
	var/datum/spell_targeting/click/T = new
	T.allowed_type = /atom
	T.try_auto_target = FALSE
	return T

/obj/effect/proc_holder/spell/goliath_tentacles/cast(list/targets, mob/user = usr)
	var/turf/target_turf = get_turf(targets[1])
	new /obj/effect/temp_visual/goliath_tentacle/original(target_turf, user)
