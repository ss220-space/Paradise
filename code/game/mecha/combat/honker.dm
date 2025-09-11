/obj/mecha/combat/honker
	desc = "Produced by \"Tyranny of Honk, INC\", this exosuit is designed as heavy clown-support. Used to spread the fun and joy of life. HONK!"
	name = "H.O.N.K"
	icon_state = "honker"
	initial_icon = "honker"
	step_in = 3
	max_integrity = 140
	deflect_chance = 60
	internal_damage_threshold = 60
	armor = list(MELEE = -20, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 100)
	max_temperature = 25000
	infra_luminosity = 5
	maint_access = TRUE
	operation_req_access = list(ACCESS_CLOWN)
	wreckage = /obj/structure/mecha_wreckage/honker
	id_lock_on = FALSE
	max_equip = 3
	starting_voice = /obj/item/mecha_modkit/voice/honk
	var/squeak = 0
	ui_theme = "honker"
	ui_honked = TRUE

	mech_type = MECH_TYPE_HONKER

/obj/mecha/combat/honker/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/honker
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar
	ME.attach(src)

/obj/mecha/combat/honker/mechstep(direction)
	var/result = step(src,direction)
	if(result)
		if(!squeak)
			playsound(src, SFX_CLOWN_STEP, 70, TRUE)
			squeak = 1
		else
			squeak = 0
	return result

/obj/mecha/combat/honker/Topic(href, href_list)
	..()
	if(href_list["play_sound"])
		switch(href_list["play_sound"])
			if("sadtrombone")
				playsound(src, 'sound/misc/sadtrombone.ogg', 50)
	return
