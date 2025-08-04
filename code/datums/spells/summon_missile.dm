/obj/effect/proc_holder/spell/summonmissile
	name = "Summon missile"
	desc = "TEST."
	base_cooldown = 45 SECONDS
	cooldown_min = 45 SECONDS
	clothes_req = TRUE
	human_req = FALSE
	invocation = "MAGIC MISSILE"
	invocation_type = "shout"
	level_max = 0

/obj/effect/proc_holder/spell/summonmissile/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/summonmissile/cast(list/targets, mob/user = usr)

	if(is_station_level(usr.z))
		for(var/mob/living/carbon/Carbon in targets)
			var/missle_type = pick(GLOB.magic_missile)
			var/obj/item/ammo_casing/caseless/rocket/Rocket = new missle_type(get_turf(Carbon))
			playsound(get_turf(Carbon),'sound/magic/summon_guns.ogg', 50, TRUE)
			Carbon.put_in_hands(R)

	else
		to_chat(usr, span_danger("Эту магия нельзя использовать вне сектора станции"))
		return



