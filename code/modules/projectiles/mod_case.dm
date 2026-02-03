/obj/item/lg_mod_case
	name = "Набор модификации энергетического оружия"
	desc = "Набор автоматизированных инструментов для модификации энергетического оружия"
	icon = 'icons/obj/device.dmi'
	icon_state = "modcase"
	item_state = "modcase"
	w_class = WEIGHT_CLASS_NORMAL

	var/cooldown = 0
	var/cooldown_time = 10 SECONDS

/obj/item/lg_mod_case/afterattack(obj/item/target_weapon, mob/user, proximity)
	if(!proximity)
		return

	var/is_laser = istype(target_weapon, /obj/item/gun/energy/laser/hitscan)
	var/is_egun = istype(target_weapon, /obj/item/gun/energy/accumulator/egun)

	if(!is_laser && !is_egun)
		to_chat(user, "<span class='warning'>Несовместимо с этим типом вооружения</span>")
		return

	if(is_laser && target_weapon.type != /obj/item/gun/energy/laser/hitscan)
		to_chat(user, "<span class='warning'>Работает только с базовой версией лазерного оружия!</span>")
		return

	if(is_egun && target_weapon.type != /obj/item/gun/energy/accumulator/egun)
		to_chat(user, "<span class='warning'>Работает только с базовой версией энергетического оружия!</span>")
		return

	if(cooldown > world.time)
		return

	var/list/choices = list()

	if(is_laser)
		var/image/rifle_img = image('icons/obj/weapons/guns_48x32.dmi', "LSR")
		rifle_img.name = "L-SR «Игла»"
		choices["L-SR «Игла»"] = rifle_img

		var/image/shotgun_img = image('icons/obj/weapons/energy.dmi', "LSG")
		shotgun_img.name = "L-SG «Фокус»"
		choices["L-SG «Фокус»"] = shotgun_img

		var/image/pistol_img = image('icons/obj/weapons/energy.dmi', "LPDW")
		pistol_img.name = "L-PDW «Шершень»"
		choices["L-PDW «Шершень»"] = pistol_img

		var/image/mg_img = image('icons/obj/weapons/energy.dmi', "LAR")
		mg_img.name = "L-AR «Зенит»"
		choices["L-AR «Зенит»"] = mg_img
	else
		var/image/rifle_img = image('icons/obj/weapons/guns_48x32.dmi', "ESR")
		rifle_img.name = "E-SR «Богомол»"
		choices["E-SR «Богомол»"] = rifle_img

		var/image/shotgun_img = image('icons/obj/weapons/energy.dmi', "ESG")
		shotgun_img.name = "E-SG «Скарабей»"
		choices["E-SG «Скарабей»"] = shotgun_img

		var/image/pistol_img = image('icons/obj/weapons/energy.dmi', "EPDW")
		pistol_img.name = "E-PDW «Оса»"
		choices["E-PDW «Оса»"] = pistol_img

		var/image/mg_img = image('icons/obj/weapons/energy.dmi', "EAR")
		mg_img.name = "E-AR «Скорпион»"
		choices["E-AR «Скорпион»"] = mg_img

	var/choice = show_radial_menu(user, target_weapon, choices, require_near = TRUE)
	if(!choice)
		return

	cooldown = world.time + cooldown_time
	to_chat(user, "<span class='notice'>Запущен процесс сборки...</span>")

	if(!do_after(user, cooldown_time, target = target_weapon))
		cooldown = 0
		return

	var/new_type
	if(is_laser)
		switch(choice)
			if("L-SR «Игла»")
				new_type = /obj/item/gun/energy/laser/hitscan/sniper
			if("L-SG «Фокус»")
				new_type = /obj/item/gun/energy/laser/hitscan/shotgun
			if("L-PDW «Шершень»")
				new_type = /obj/item/gun/energy/laser/hitscan/pistol
			if("L-AR «Зенит»")
				new_type = /obj/item/gun/energy/laser/hitscan/automatic
	else
		switch(choice)
			if("E-SR «Богомол»")
				new_type = /obj/item/gun/energy/accumulator/egun/sniper
			if("E-SG «Скарабей»")
				new_type = /obj/item/gun/energy/accumulator/egun/shotgun
			if("E-PDW «Оса»")
				new_type = /obj/item/gun/energy/accumulator/egun/pistol
			if("E-AR «Скорпион»")
				new_type = /obj/item/gun/energy/accumulator/egun/automatic

	if(!new_type)
		return

	var/turf/spawn_turf = get_turf(user)

	var/obj/item/new_gun = new new_type(spawn_turf)
	qdel(target_weapon)

	if(user.put_in_hands(new_gun))
		to_chat(user, "<span class='notice'>Модификация завершена!</span>")
	else
		new_gun.forceMove(spawn_turf)

	qdel(src)

	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	do_sparks(3, TRUE, spawn_turf)
