/obj/item/lg_mod_case
	name = "Набор модификации лазерного оружия"
	desc = "Набор автоматизированных инструментов для модификации энергетического оружия на базе LG"
	icon = 'icons/obj/device.dmi'
	icon_state = "modcase"
	item_state = "modcase"
	w_class = WEIGHT_CLASS_NORMAL

	var/cooldown = 0
	var/cooldown_time = 10 SECONDS
	var/list/modifications = list(
		"LG-PRO «Игла»" = /obj/item/gun/energy/laser/hitscan/laserrifle,
		"LG-TAC «Фокус»" = /obj/item/gun/energy/laser/hitscan/lasershotgun,
		"LG-PDW «Шершень»" = /obj/item/gun/energy/laser/hitscan/laserpistol,
		"LG-LMG «Зенит»" = /obj/item/gun/energy/laser/hitscan/lasermg
	)

/obj/item/lg_mod_case/afterattack(obj/item/weapon, mob/user, proximity)
	if(!proximity)
		return

	// Only base hitscan laser can be modified
	if(!istype(weapon, /obj/item/gun/energy/laser/hitscan) || weapon.type != /obj/item/gun/energy/laser/hitscan)
		to_chat(user, "<span class='warning'>Работает только с базовой версией оружия!</span>")
		return

	if(cooldown > world.time)
		return

	// Create radial menu images
	var/list/choices = list()

	var/image/rifle_img = image('icons/obj/weapons/guns_48x32.dmi', "laserrifle")
	rifle_img.name = "LG-PRO «Игла»"
	choices["LG-PRO «Игла»"] = rifle_img

	var/image/shotgun_img = image('icons/obj/weapons/energy.dmi', "lasershotgun")
	shotgun_img.name = "LG-TAC «Фокус»"
	choices["LG-TAC «Фокус»"] = shotgun_img

	var/image/pistol_img = image('icons/obj/weapons/energy.dmi', "laserpistol")
	pistol_img.name = "LG-PDW «Шершень»"
	choices["LG-PDW «Шершень»"] = pistol_img

	var/image/mg_img = image('icons/obj/weapons/energy.dmi', "lasermg")
	mg_img.name = "LG-LMG «Зенит»"
	choices["LG-LMG «Зенит»"] = mg_img

	// Show radial menu
	var/choice = show_radial_menu(user, weapon, choices, require_near = TRUE)
	if(!choice)
		return

	cooldown = world.time + cooldown_time
	to_chat(user, "<span class='notice'>Запущен процесс сборки...</span>")

	// 10 second modification process
	if(!do_after(user, cooldown_time, target = weapon))
		cooldown = 0
		return

	// Determine weapon type
	var/new_type
	switch(choice)
		if("LG-PRO «Игла»")
			new_type = /obj/item/gun/energy/laser/hitscan/laserrifle
		if("LG-TAC «Фокус»")
			new_type = /obj/item/gun/energy/laser/hitscan/lasershotgun
		if("LG-PDW «Шершень»")
			new_type = /obj/item/gun/energy/laser/hitscan/laserpistol
		if("LG-LMG «Зенит»")
			new_type = /obj/item/gun/energy/laser/hitscan/lasermg
		else
			return

	var/turf/T = get_turf(user)

	// Create new weapon
	var/obj/item/new_gun = new new_type(T)
	qdel(weapon)

	// Give new weapon to player
	if(user.put_in_hands(new_gun))
		to_chat(user, "<span class='notice'>Модификация изавершена!</span>")
	else
		new_gun.forceMove(T)

	// Delete mod case after use
	qdel(src)

	// Effects
	playsound(user, 'sound/machines/ding.ogg', 50, TRUE)
	do_sparks(3, TRUE, T)
