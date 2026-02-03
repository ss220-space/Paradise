// Ion Rifles //
/obj/item/gun/energy/ionrifle
	name = "ion rifle"
	desc = "A man portable anti-armor weapon designed to disable mechanical threats"
	icon_state = "ionrifle"
	item_state = "ionrifle"
	fire_sound = 'sound/weapons/ionrifle.ogg'
	origin_tech = "combat=4;magnets=4"
	w_class = WEIGHT_CLASS_HUGE
	can_holster = FALSE
	slot_flags = ITEM_SLOT_BACK
	zoomable = TRUE
	zoom_amt = 7
	ammo_type = list(/obj/item/ammo_casing/energy/ion)
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/ionrifle/emp_act(severity)
	return

/obj/item/gun/energy/ionrifle/carbine
	name = "ion carbine"
	desc = "The MK.II Prototype Ion Projector is a lightweight carbine version of the larger ion rifle, built to be ergonomic and efficient."
	icon_state = "ioncarbine"
	item_state = "advtaser"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = ITEM_SLOT_BELT
	zoomable = FALSE
	ammo_x_offset = 2
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 9, "y" = 8),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -4),
	)

// Decloner //
/obj/item/gun/energy/decloner
	name = "biological demolecularisor"
	desc = "A gun that discharges high amounts of controlled radiation to slowly break a target into component elements."
	icon_state = "decloner"
	origin_tech = "combat=4;materials=4;biotech=5;plasmatech=6"
	ammo_type = list(/obj/item/ammo_casing/energy/declone)
	ammo_x_offset = 1
	accuracy = GUN_ACCURACY_MINIMAL

/obj/item/gun/energy/decloner/update_icon_state()
	return

/obj/item/gun/energy/decloner/update_overlays()
	. = list()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(cell.charge > shot.e_cost)
		. += "decloner_spin"

// Flora Gun //
/obj/item/gun/energy/floragun
	name = "floral somatoray"
	desc = "A tool that discharges controlled radiation which induces mutation in plant cells."
	icon_state = "flora"
	fire_sound = 'sound/effects/stealthoff.ogg'
	materials = list(MAT_GOLD = 2000, MAT_BLUESPACE = 1500, MAT_DIAMOND = 800, MAT_URANIUM = 500, MAT_GLASS = 500)
	origin_tech = "materials=5;biotech=6;powerstorage=6;engineering=5"
	ammo_type = list(/obj/item/ammo_casing/energy/flora/alpha, /obj/item/ammo_casing/energy/flora/beta, /obj/item/ammo_casing/energy/flora/gamma)
	modifystate = TRUE
	ammo_x_offset = 1
	can_charge = FALSE
	selfcharge = TRUE
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/floragun/emag_act(mob/user)
	. = ..()

	if(emagged)
		return

	if(user)
		balloon_alert(user, "протоколы защиты сняты!")

	emagged = TRUE
	ammo_type = list(/obj/item/ammo_casing/energy/flora/alpha/emag, /obj/item/ammo_casing/energy/flora/beta, /obj/item/ammo_casing/energy/flora/gamma)
	update_ammo_types()

/obj/item/gun/energy/floragun/examine(mob/user)
	. = ..()
	. += span_notice("Mode: [ammo_type[select]]\nCharge: [cell.percent()]%")

// Meteor Gun //
/obj/item/gun/energy/meteorgun
	name = "meteor gun"
	desc = "For the love of god, make sure you're aiming this the right way!"
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "riotgun"
	item_state = "c20r"
	fire_sound = 'sound/weapons/gunshots/gunshot_shotgun.ogg'
	w_class = WEIGHT_CLASS_BULKY
	ammo_type = list(/obj/item/ammo_casing/energy/meteor)
	cell_type = /obj/item/stock_parts/cell/potato
	clumsy_check = FALSE //Admin spawn only, might as well let clowns use it.
	selfcharge = TRUE
	accuracy = GUN_ACCURACY_RIFLE
	recoil = GUN_RECOIL_MEDIUM

/obj/item/gun/energy/meteorgun/pen
	name = "meteor pen"
	desc = "The pen is mightier than the sword."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "pen"
	item_state = "pen"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY

// Mind Flayer //
/obj/item/gun/energy/mindflayer
	name = "Mind Flayer"
	desc = "A prototype weapon recovered from the ruins of Research-Station Epsilon."
	icon_state = "xray"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/mindflayer)
	accuracy = GUN_ACCURACY_PISTOL

// Energy Crossbows //
/obj/item/gun/energy/kinetic_accelerator/crossbow
	name = "mini energy crossbow"
	desc = "Компактное энергооружие, ценимое агентами \"Синдиката\" за бесшумность. \
			Заряжается автоматически, идеально для точечных устранений."
	icon_state = "crossbow"
	item_state = "crossbow"
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=4;syndicate=4"
	suppressed = 1
	ammo_type = list(/obj/item/ammo_casing/energy/bolt)
	unique_rename = 0
	overheat_time = 20
	holds_charge = TRUE
	unique_frequency = TRUE
	max_mod_capacity = 0
	empty_state = null
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/kinetic_accelerator/crossbow/get_ru_names()
	return list(
		NOMINATIVE = "мини энерго-арбалет",
		GENITIVE = "мини энерго-арбалета",
		DATIVE = "мини энерго-арбалету",
		ACCUSATIVE = "мини энерго-арбалет",
		INSTRUMENTAL = "мини энерго-арбалетом",
		PREPOSITIONAL = "мини энерго-арбалете"
)

/obj/item/gun/energy/kinetic_accelerator/crossbow/old
	name = "old mini energy crossbow"
	desc = "A weapon favored by syndicate stealth specialists. It looks very old."
	accuracy = new /datum/gun_accuracy/minimal/old()

/obj/item/gun/energy/kinetic_accelerator/crossbow/large
	name = "energy crossbow"
	desc = "Полноразмерная реплика арбалета \"Синдиката\", воссозданная методом обратной инженерии. \
			Более громоздкий по сравнению с оригиналом."
	icon_state = "crossbowlarge"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4;syndicate=3"
	suppressed = 0
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/large)
	accuracy = GUN_ACCURACY_RIFLE

/obj/item/gun/energy/kinetic_accelerator/crossbow/large/get_ru_names()
	return list(
		NOMINATIVE = "энергетический арбалет",
		GENITIVE = "энергетического арбалета",
		DATIVE = "энергетическому арбалету",
		ACCUSATIVE = "энергетический арбалет",
		INSTRUMENTAL = "энергетическим арбалетом",
		PREPOSITIONAL = "энергетическом арбалете"
	)

/obj/item/gun/energy/kinetic_accelerator/crossbow/toy
	name = "toy energy crossbow"
	desc = "Игрушечное оружие, сделанное из тагерного пистолета со стильным дизайном контрабандного арбалета."
	icon_state = "crossbowtoy"
	materials = list(MAT_METAL=4000)
	origin_tech = "combat=4;magnets=4"
	suppressed = 0
	overheat_time = 8 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/bolt/bolttoy)
	accuracy = GUN_ACCURACY_DEFAULT

/obj/item/gun/energy/kinetic_accelerator/crossbow/toy/get_ru_names()
	return list(
		NOMINATIVE = "игрушечный энерго-арбалет",
		GENITIVE = "игрушечного энерго-арбалета",
		DATIVE = "игрушечному энерго-арбалету",
		ACCUSATIVE = "игрушечный энерго-арбалет",
		INSTRUMENTAL = "игрушечным энерго-арбалетом",
		PREPOSITIONAL = "игрушечном энерго-арбалете"
	)

/obj/item/gun/energy/kinetic_accelerator/crossbow/large/cyborg
	desc = "One and done!"
	origin_tech = null
	materials = list()
	accuracy = GUN_ACCURACY_RIFLE

/obj/item/gun/energy/kinetic_accelerator/suicide_act(mob/user)
	if(!suppressed)
		playsound(loc, 'sound/weapons/kenetic_reload.ogg', 60, TRUE)
	user.visible_message(span_suicide("[user] взводит [declent_ru(ACCUSATIVE)] и приставляет его к своему виску! Это похоже на попытку самоубийства!</b>"))
	shoot_live_shot(user, user, FALSE, FALSE)
	return OXYLOSS

// Plasma Cutters //
/obj/item/gun/energy/plasmacutter
	name = "plasma cutter"
	desc = "Шахтёрский инструмент, стреляющий сконцентрированной плазмой. Можете отрезать конечности ксеносам! Или, ну там... руду добывать."
	icon_state = "plasmacutter"
	item_state = "plasmacutter"
	origin_tech = "combat=1;materials=3;magnets=2;plasmatech=3;engineering=1"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma)
	usesound = 'sound/items/welder.ogg'
	container_type = OPENCONTAINER
	attack_verb = list("атаковал", "полоснул", "порезал")
	force = 12
	sharp = 1
	can_charge = FALSE
	accuracy = GUN_ACCURACY_RIFLE

/obj/item/gun/energy/plasmacutter/get_ru_names()
	return list(
		NOMINATIVE = "плазменный резак",
		GENITIVE = "плазменного резака",
		DATIVE = "плазменному резаку",
		ACCUSATIVE = "плазменный резак",
		INSTRUMENTAL = "плазменным резаком",
		PREPOSITIONAL = "плазменном резаке",
	)

/obj/item/gun/energy/plasmacutter/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("Заряд [icon2html(src, user)] [declent_ru(GENITIVE)] [round(cell.percent())]%")

/obj/item/gun/energy/plasmacutter/get_heat()
	return 3800

/obj/item/gun/energy/plasmacutter/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/sheet/mineral/plasma))
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/plasma/plasma = I
		if(cell.charge >= cell.maxcharge)
			balloon_alert(user, "заряд на максимуме!")
			return ATTACK_CHAIN_PROCEED
		if(!plasma.use(1))
			balloon_alert(user, "недостаточно плазмы!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "заряд увеличен")
		cell.give(1000)
		on_recharge()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/stack/ore/plasma))
		add_fingerprint(user)
		var/obj/item/stack/ore/plasma/plasma = I
		if(cell.charge >= cell.maxcharge)
			balloon_alert(user, "заряд на максимуме!")
			return ATTACK_CHAIN_PROCEED
		if(!plasma.use(1))
			balloon_alert(user, "недостаточно плазмы!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "заряд увеличен")
		cell.give(500)
		on_recharge()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/gun/energy/plasmacutter/update_overlays()
	return list()

/obj/item/gun/energy/plasmacutter/adv
	name = "advanced plasma cutter"
	icon_state = "adv_plasmacutter"
	item_state = "adv_plasmacutter"
	origin_tech = "combat=3;materials=4;magnets=3;plasmatech=4;engineering=2"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv)
	force = 15
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/plasmacutter/adv/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый плазменный резак",
		GENITIVE = "продвинутого плазменного резака",
		DATIVE = "продвинутому плазменному резаку",
		ACCUSATIVE = "продвинутый плазменный резак",
		INSTRUMENTAL = "продвинутым плазменным резаком",
		PREPOSITIONAL = "продвинутом плазменном резаке",
	)

/obj/item/gun/energy/plasmacutter/adv/mega
	name = "magmite plasma cutter"
	icon_state = "adv_plasmacutter_m"
	item_state = "plasmacutter_mega"
	desc = "Улучшенная версия плазменного резака с использованием плазменного магмита. Режет ксеносов вдвое эффективнее! И руду тоже."
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/adv/mega)
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/plasmacutter/adv/mega/get_ru_names()
	return list(
		NOMINATIVE = "магмитовый плазменный резак",
		GENITIVE = "магмитового плазменного резака",
		DATIVE = "магмитовому плазменному резаку",
		ACCUSATIVE = "магмитовый плазменный резак",
		INSTRUMENTAL = "магмитовым плазменным резаком",
		PREPOSITIONAL = "магмитовом плазменном резаке",
	)

/obj/item/gun/energy/plasmacutter/shotgun
	name = "plasma cutter shotgun"
	desc = "Промышленный тяжелый дробовик для шахтёрских работ."
	icon_state = "miningshotgun"
	item_state = "miningshotgun"
	origin_tech = "combat=5;materials=5;magnets=5;plasmatech=6;engineering=5"
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/shotgun)
	force = 10
	accuracy = GUN_ACCURACY_SHOTGUN

/obj/item/gun/energy/plasmacutter/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "плазменный дробовик",
		GENITIVE = "плазменного дробовика",
		DATIVE = "плазменному дробовику",
		ACCUSATIVE = "плазменный дробовик",
		INSTRUMENTAL = "плазменным дробовиком",
		PREPOSITIONAL = "плазменном дробовике",
	)

/obj/item/gun/energy/plasmacutter/shotgun/mega
	name = "magmite plasma cutter shotgun"
	icon_state = "miningshotgun_mega"
	item_state = "miningshotgun_mega"
	desc = "Улучшенный промышленный дробовик с плазменным магмитом. Разрезает... значит добывает."
	ammo_type = list(/obj/item/ammo_casing/energy/plasma/shotgun/mega)
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/gun/energy/plasmacutter/shotgun/mega/get_ru_names()
	return list(
		NOMINATIVE = "магмитовый плазменный дробовик",
		GENITIVE = "магмитового плазменного дробовика",
		DATIVE = "магмитовому плазменному дробовику",
		ACCUSATIVE = "магмитовый плазменный дробовик",
		INSTRUMENTAL = "магмитовым плазменным дробовиком",
		PREPOSITIONAL = "магмитовом плазменном дробовике",
	)

// Wormhole Projectors //
/obj/item/gun/energy/wormhole_projector
	name = "bluespace wormhole projector"
	desc = "A projector that emits high density quantum-coupled bluespace beams."
	ammo_type = list(/obj/item/ammo_casing/energy/wormhole, /obj/item/ammo_casing/energy/wormhole/orange)
	item_state = "wormhole_projector1"
	icon_state = "wormhole_projector1"
	origin_tech = "combat=4;bluespace=6;plasmatech=4;engineering=4"
	charge_delay = 5
	selfcharge = TRUE
	var/obj/effect/portal/wormhole_projector/blue
	var/obj/effect/portal/wormhole_projector/orange
	accuracy = GUN_ACCURACY_DEFAULT

/obj/item/gun/energy/wormhole_projector/update_icon_state()
	icon_state = "wormhole_projector[select]"
	item_state = icon_state

/obj/item/gun/energy/wormhole_projector/handle_chamber()
	..()
	select_fire(usr)

/obj/item/gun/energy/wormhole_projector/portal_destroyed(obj/effect/portal/wormhole_projector/portal)
	if(portal.is_orange)
		orange = null
		blue?.target = null
	else
		blue = null
		orange?.target = null

/obj/item/gun/energy/wormhole_projector/proc/create_portal(obj/projectile/beam/wormhole/wormhole_beam, turf/target)
	var/obj/effect/portal/wormhole_projector/new_portal = new(get_turf(wormhole_beam), null, src)
	if(wormhole_beam.is_orange)
		if(!QDELETED(orange))
			qdel(orange)
		orange = new_portal
		new_portal.is_orange = TRUE
		new_portal.update_icon(UPDATE_ICON_STATE)
		new_portal.set_light_color(COLOR_MOSTLY_PURE_ORANGE)
		new_portal.update_light()
	else
		if(!QDELETED(blue))
			qdel(blue)
		blue = new_portal

	if(orange && blue)
		blue.target = get_turf(orange)
		orange.target = get_turf(blue)

/* 3d printer 'pseudo guns' for borgs */
/obj/item/gun/energy/printer
	name = "cyborg lmg"
	desc = "A machinegun that fires 3d-printed flachettes slowly regenerated using a cyborg's internal power source."
	icon_state = "l6closed0"
	icon = 'icons/obj/weapons/projectile.dmi'
	cell_type = /obj/item/stock_parts/cell/secborg
	ammo_type = list(/obj/item/ammo_casing/energy/c3dbullet)
	can_charge = FALSE
	accuracy = GUN_ACCURACY_DEFAULT

/obj/item/gun/energy/printer/update_overlays()
	return list()

/obj/item/gun/energy/printer/emp_act()
	return

// Instakill Lasers //
/obj/item/gun/energy/laser/instakill
	name = "instakill rifle"
	icon_state = "instagib"
	item_state = "instagib"
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit."
	ammo_type = list(/obj/item/ammo_casing/energy/instakill)
	force = 60
	origin_tech = "combat=7;magnets=6"
	accuracy = GUN_ACCURACY_RIFLE
	attachable_allowed = GUN_MODULE_CLASS_NONE

/obj/item/gun/energy/laser/instakill/emp_act() //implying you could stop the instagib
	return

/obj/item/gun/energy/laser/instakill/red
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a red design."
	icon_state = "instagibred"
	item_state = "instagibred"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/red)

/obj/item/gun/energy/laser/instakill/blue
	desc = "A specialized ASMD laser-rifle, capable of flat-out disintegrating most targets in a single hit. This one has a blue design."
	icon_state = "instagibblue"
	item_state = "instagibblue"
	ammo_type = list(/obj/item/ammo_casing/energy/instakill/blue)

// HONK Rifle //
/obj/item/gun/energy/clown
	name = "HONK Rifle"
	desc = "Clown Planet's finest."
	icon_state = "honkrifle"
	item_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/clown)
	clumsy_check = FALSE
	selfcharge = TRUE
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_MINIMAL

/obj/item/gun/energy/toxgun
	name = "toxin pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	icon_state = "toxgun"
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/toxplasma)
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_RIFLE

// Energy Sniper //
/obj/item/gun/energy/sniperrifle
	name = "L.W.A.P. Sniper Rifle"
	desc = "A rifle constructed of lightweight materials, fitted with a SMART aiming-system scope."
	icon_state = "esniper"
	origin_tech = "combat=6;materials=5;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/sniper)
	item_state = null
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	can_holster = FALSE
	zoomable = TRUE
	zoom_amt = 7 //Long range, enough to see in front of you, but no tiles behind you.
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/sniperrifle/pod_pilot
	name = "LSR-39 Queen blade"
	desc = "Прототип компактной лазерной снайперской винтовки с парализующим и летальным режимом стрельбы, оснащена большим оптическим прицелом для эффективной работы в открытом космосе."
	icon_state = "LQB"
	item_state = "LQB"
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler/heavy,
		/obj/item/ammo_casing/energy/laser/heavy,
	)
	item_state = null
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY
	charge_sections = 3
	modifystate = TRUE
	accuracy = GUN_ACCURACY_SNIPER

// Temperature Gun //
/obj/item/gun/energy/temperature
	name = "temperature gun"
	icon = 'icons/obj/weapons/gun_temperature.dmi'
	icon_state = "tempgun_4"
	item_state = "tempgun_4"
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	desc = "A gun that changes the body temperature of its targets."
	fire_delay = 1.5 SECONDS
	var/temperature = 300
	var/target_temperature = 300
	origin_tech = "combat=4;materials=4;powerstorage=3;magnets=2"

	ammo_type = list(/obj/item/ammo_casing/energy/temp)
	selfcharge = TRUE

	var/powercost = ""
	var/powercostcolor = ""

	var/dat = ""
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/temperature/Initialize(mapload, ...)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	START_PROCESSING(SSobj, src)

/obj/item/gun/energy/temperature/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/energy/temperature/newshot()
	..()

/obj/item/gun/energy/temperature/attack_self(mob/living/user)
	user.set_machine(src)
	update_dat()
	var/datum/browser/popup = new(user, "tempgun", "Temperature Gun Configuration", 510, 120)
	popup.set_content("<hr>[dat]")
	popup.open(TRUE)
	onclose(user, "tempgun")

/obj/item/gun/energy/temperature/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		if(user)
			to_chat(user, span_caution("You double the gun's temperature cap! Targets hit by searing beams will burst into flames!"))
		desc = "A gun that changes the body temperature of its targets. Its temperature cap has been hacked."

/obj/item/gun/energy/temperature/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)

	if(href_list["temp"])
		var/amount = text2num(href_list["temp"])
		if(amount > 0)
			target_temperature = min((500 + 500*emagged), target_temperature+amount)
		else
			target_temperature = max(TCMB, target_temperature+amount)
	if(ismob(loc))
		attack_self(loc)
	add_fingerprint(usr)
	return

/obj/item/gun/energy/temperature/process()
	..()
	var/obj/item/ammo_casing/energy/temp/T = ammo_type[select]
	T.temp = temperature
	switch(temperature)
		if(0 to 100)
			T.e_cost = 300
			powercost = "High"
		if(100 to 250)
			T.e_cost = 200
			powercost = "Medium"
		if(251 to 300)
			T.e_cost = 100
			powercost = "Low"
		if(301 to 400)
			T.e_cost = 200
			powercost = "Medium"
		if(401 to 1000)
			T.e_cost = 300
			powercost = "High"
	switch(powercost)
		if("High")
			powercostcolor = "orange"
		if("Medium")
			powercostcolor = "green"
		else
			powercostcolor = "blue"
	if(target_temperature != temperature)
		var/difference = abs(target_temperature - temperature)
		if(difference >= (10 + 40*emagged)) //so emagged temp guns adjust their temperature much more quickly
			if(target_temperature < temperature)
				temperature -= (10 + 40*emagged)
			else
				temperature += (10 + 40*emagged)
		else
			temperature = target_temperature
		update_icon()

		if(iscarbon(loc))
			var/mob/living/carbon/M = loc
			if(src == M.machine)
				update_dat()
				var/datum/browser/popup = new(M, "tempgun", "Temperature Gun Configuration", 510, 120)
				popup.set_content("<hr>[dat]")
				popup.open(FALSE)
	return

/obj/item/gun/energy/temperature/proc/update_dat()
	dat = ""
	dat += "Current output temperature: "
	if(temperature > 500)
		dat += "<span style='color: red;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
		dat += "<span style='color: red;'><b> SEARING!</b></span>"
	else if(temperature > (T0C + 50))
		dat += "<span style='color: red;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	else if(temperature > (T0C - 50))
		dat += "<span style='color: black;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	else
		dat += "<span style='color: blue;'><b>[temperature]</b> ([round(temperature-T0C)]&deg;C)</span>"
	dat += "<br>"
	dat += "Target output temperature: "	//might be string idiocy, but at least it's easy to read
	dat += "<a href='byond://?src=[UID()];temp=-100'>-</a> "
	dat += "<a href='byond://?src=[UID()];temp=-10'>-</a> "
	dat += "<a href='byond://?src=[UID()];temp=-1'>-</a> "
	dat += "[target_temperature] "
	dat += "<a href='byond://?src=[UID()];temp=1'>+</a> "
	dat += "<a href='byond://?src=[UID()];temp=10'>+</a> "
	dat += "<a href='byond://?src=[UID()];temp=100'>+</a>"
	dat += "<br>"
	dat += "Power cost: "
	dat += "<span style='color: [powercostcolor];'><b>[powercost]</b></span>"

/obj/item/gun/energy/temperature/update_icon_state()
	switch(temperature)
		if(501 to INFINITY)
			item_state = "tempgun_8"
		if(400 to 500)
			item_state = "tempgun_7"
		if(360 to 400)
			item_state = "tempgun_6"
		if(335 to 360)
			item_state = "tempgun_5"
		if(295 to 335)
			item_state = "tempgun_4"
		if(260 to 295)
			item_state = "tempgun_3"
		if(200 to 260)
			item_state = "tempgun_2"
		if(120 to 260)
			item_state = "tempgun_1"
		if(-INFINITY to 120)
			item_state = "tempgun_0"

	icon_state = item_state

/obj/item/gun/energy/temperature/update_overlays()
	. = ..()
	switch(cell.charge)
		if(900 to INFINITY)
			. += "900"
		if(800 to 900)
			. += "800"
		if(700 to 800)
			. += "700"
		if(600 to 700)
			. += "600"
		if(500 to 600)
			. += "500"
		if(400 to 500)
			. += "400"
		if(300 to 400)
			. += "300"
		if(200 to 300)
			. += "200"
		if(100 to 202)
			. += "100"
		if(-INFINITY to 100)
			. += "0"

// Mimic Gun //
/obj/item/gun/energy/mimicgun
	name = "mimic gun"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse. Why does this one have teeth?"
	icon_state = "disabler"
	item_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/mimic)
	clumsy_check = FALSE //Admin spawn only, might as well let clowns use it.
	selfcharge = TRUE
	ammo_x_offset = 3
	var/mimic_type = /obj/item/gun/projectile/automatic/pistol //Setting this to the mimicgun type does exactly what you think it will.
	accuracy = GUN_ACCURACY_DEFAULT

/obj/item/gun/energy/mimicgun/newshot()
	var/obj/item/ammo_casing/energy/mimic/M = ammo_type[select]
	M.mimic_type = mimic_type
	..()

// Sibyl System's Dominator //
/obj/item/gun/energy/dominator
	name = "Доминатор"
	desc = "Проприетарное высокотехнологичное оружие правоохранительной организации Sibyl System, произведённое специально для борьбы с преступностью."
	icon_state = "dominator"
	base_icon_state = "dominator"
	item_state = null
	force = 10
	resistance_flags = INDESTRUCTIBLE|LAVA_PROOF|FIRE_PROOF|ACID_PROOF
	origin_tech = "combat=4;magnets=4"
	cell_type = /obj/item/stock_parts/cell/dominator
	modifystate = TRUE
	shaded_charge = TRUE
	charge_sections = 3
	ammo_type = list(
		/obj/item/ammo_casing/energy/disabler,
		/obj/item/ammo_casing/energy/electrode,
		/obj/item/ammo_casing/energy/laser,
	)
	/// Sounds played after selecting the firemode, must be in the same order as ammo_type
	var/sound_voice = list(
		null,
		'sound/voice/dominator/nonlethal-paralyzer.ogg',
		'sound/voice/dominator/lethal-eliminator.ogg',
		'sound/voice/dominator/execution-slaughter.ogg',
	)
	/// Whether we are currently equipped or not.
	/// Its rather this variable or delayed icon update on dropped.
	var/is_equipped = FALSE
	/// Timestamp used for sound effects
	COOLDOWN_DECLARE(last_sound_effect)
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = -3, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 7, "y" = -8),
	)

/obj/item/gun/energy/dominator/select_fire(mob/living/user)
	. = ..()
	if(sibyl_mod?.voice_is_enabled && sound_voice[select] && COOLDOWN_FINISHED(src, last_sound_effect))
		user.playsound_local(user, sound_voice[select], 50, FALSE)
		COOLDOWN_START(src, last_sound_effect, 2 SECONDS)

/obj/item/gun/energy/dominator/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	is_equipped = TRUE
	update_icon()

/obj/item/gun/energy/dominator/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	is_equipped = FALSE
	update_icon()

// Global check procedure for weapon accumulators
/proc/is_accumulator_cell(obj/item/weapon_cell/cell)
	return istype(cell, /obj/item/weapon_cell/specter) || istype(cell, /obj/item/weapon_cell/egun)

// Accumulator parent type
/obj/item/weapon_cell/accumulator
	name = "Родительский аккумулятор для энергооружия"
	desc = "Если вы это видите - сообщите разработчикам, это - ошибка."
	icon_state = "specter_accumulator"

/obj/item/weapon_cell/specter
	name = "Аккумулятор для пистолета \"Спектр\"."
	desc = "Подходит только к пистолету \"Спектр\" вмещает энергию на 8 летальных или 16 оглушающих выстрела, имеет адаптивные магниты для быстрой перезарядки из пояса."
	parent_type = /obj/item/weapon_cell/accumulator
	icon_state = "specter_accumulator"
	internal_cell = new /obj/item/stock_parts/cell/specter()

/obj/item/weapon_cell/egun
	name = "Аккумулятор для энергетического оружия"
	desc = "Подходит к большинству видов аккумуляторного энергооружия, имеет внушительную ёмкость и адаптивные магниты для быстрой перезарядки из пояса."
	parent_type = /obj/item/weapon_cell/accumulator
	icon_state = "egun_accumulator"
	internal_cell = new /obj/item/stock_parts/cell/egun()

// Parent type for all accumulator based guns
/obj/item/gun/energy/accumulator
	name = "Родительское аккумуляторное оружие"
	desc = "Если вы это видите - сообщите разработчикам, это ошибка"
	shaded_charge = TRUE
	var/obj/item/weapon_cell/magazine
	var/accumulator_type = /obj/item/weapon_cell/specter
	var/charge_empty = 'sound/weapons/smg_empty_alarm.ogg'
	var/magazine_out_sound = 'sound/weapons/gun_interactions/spec_magout.ogg'
	var/magazine_in_sound = 'sound/weapons/gun_interactions/spec_magin.ogg'
	var/autofire_delay = 0
	modifystate = FALSE
	charge_sections = 0

/obj/item/gun/energy/accumulator/Initialize(mapload)
	. = ..()
	if(accumulator_type)
		magazine = new accumulator_type(src)
		if(magazine && magazine.get_cell())
			cell = magazine.get_cell()
	update_icon()

/obj/item/gun/energy/accumulator/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/ammo_alarm)

/obj/item/gun/energy/accumulator/can_shoot(mob/living/user, silent)
	if(!magazine)
		if(!silent)
			balloon_alert(user, "Нет аккумулятора!")
		return FALSE
	return ..()

/obj/item/gun/energy/accumulator/attackby(obj/item/item, mob/user, params)
	if(!is_accumulator_cell(item))
		return ..()

	add_fingerprint(user)

	if(accumulator_type && !istype(item, accumulator_type))
		balloon_alert(user, "Неподходящий аккумулятор!")
		return

	if(!user.drop_transfer_item_to_loc(item, src))
		balloon_alert(user, "Не получается выбросить!")
		return ATTACK_CHAIN_PROCEED

	if(magazine)
		magazine.update_icon(UPDATE_OVERLAYS)
		user.put_in_hands(magazine)

	magazine = item
	if(magazine.get_cell())
		cell = magazine.get_cell()
		cell_type = cell.type

	balloon_alert(user, "Аккумулятор заменён!")
	update_icon()

	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	if(magazine.is_available_shot(shot.e_cost))
		playsound(loc, magazine_in_sound, 50, TRUE)

	return ATTACK_CHAIN_PROCEED

/obj/item/gun/energy/accumulator/attack_self(mob/living/user)
	if(!magazine)
		return FALSE

	magazine.update_icon(UPDATE_OVERLAYS)
	user.put_in_hands(magazine)

	cell = null
	magazine = null

	update_icon()
	playsound(loc, magazine_out_sound, 50, TRUE)
	return TRUE

/obj/item/gun/energy/accumulator/examine(mob/user)
	. = ..()
	if(magazine && cell)
		. += span_notice("Заряд аккумулятора: [round(cell.percent())]%")
		var/obj/item/ammo_casing/energy/shot = ammo_type[select]
		. += span_notice("Режим: [shot.select_name]")
	else
		. += span_warning("Нет аккумулятора!")

/obj/item/gun/energy/accumulator/afterattack(atom/target, mob/user, proximity_flag)
	if(!proximity_flag || !is_accumulator_cell(target))
		return ..()

	var/obj/item/weapon_cell/new_cell = target
	var/belt = new_cell.loc

	if(!istype(belt, /obj/item/storage/belt))
		return ..()

	if(accumulator_type && !istype(new_cell, accumulator_type))
		balloon_alert(user, "Неподходящий аккумулятор")
		return TRUE

	if(magazine)
		var/obj/item/weapon_cell/old_cell = magazine

		belt:remove_from_storage(new_cell, get_turf(user))

		magazine = new_cell
		cell = new_cell.internal_cell

		new_cell.forceMove(src)
		belt:handle_item_insertion(old_cell, FALSE, user)

		old_cell.update_icon(UPDATE_OVERLAYS)
		update_icon()

		playsound(loc, magazine_in_sound, 30, TRUE)
		return TRUE

	belt:remove_from_storage(new_cell, get_turf(user))
	attackby(new_cell, user)
	playsound(loc, magazine_in_sound, 30, TRUE)
	return TRUE

/obj/item/gun/energy/accumulator/CtrlClick(mob/user)
	if(length(ammo_type) > 1)
		select_fire(user)
		update_icon()
		return TRUE
	return FALSE

/obj/item/gun/energy/accumulator/handle_chamber(empty_chamber = TRUE, from_firing = TRUE, chamber_next_round = TRUE, atom/shooter = null)
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/was_charged = magazine && magazine.is_available_shot(shot.e_cost)

	. = ..()

	var/is_charged_now = magazine && magazine.is_available_shot(shot.e_cost)

	if(was_charged && !is_charged_now)
		playsound(loc, charge_empty, 50, TRUE)

//Actual weapon types
/obj/item/gun/energy/accumulator/egun
	name = "E-DMR \"Скорпион\""
	desc = "Энергетическая винтовка \"Скорпион\", работающая на съёмных аккумуляторах. Популярна среди множества силовых структур по всей галактике, имеет магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке."
	icon_state = "EDMR"
	item_state = "EDMR"
	force = 10
	origin_tech = "combat=4;materials=2"
	accumulator_type = /obj/item/weapon_cell/egun
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	materials = list(MAT_METAL = 50000)
	weapon_weight = WEAPON_LIGHT
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BELT
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL | GUN_MODULE_CLASS_RIFLE_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 6, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -6),
	)
	ammo_x_offset = 0

/obj/item/gun/energy/accumulator/egun/get_ru_names()
	return list(
		NOMINATIVE = "энергетическая винтовка",
		GENITIVE = "энергетической винтовки",
		DATIVE = "энергетической винтовке",
		ACCUSATIVE = "энергетическую винтовку",
		INSTRUMENTAL = "энергетической винтовкой",
		PREPOSITIONAL = "энергетической винтовке",
	)

/obj/item/gun/energy/accumulator/egun/pistol
	name = "E-PDW \"Оса\""
	desc = "Ручной бластер \"Оса\", работающий на съёмных аккумуляторах. Популярен среди множества силовых структур по всей галактике как удобное миниатюрное оружие, имеет магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке."
	icon_state = "EPDW"
	item_state = "EPDW"
	weapon_weight = WEAPON_LIGHT
	w_class = WEIGHT_CLASS_NORMAL
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 7, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 5, "y" = -5),
	)
	ammo_x_offset = 0

/obj/item/gun/energy/accumulator/egun/pistol/get_ru_names()
	return list(
		NOMINATIVE = "бластер \"Оса\"",
		GENITIVE = "бластера \"Оса\"",
		DATIVE = "бластеру \"Оса\"",
		ACCUSATIVE = "бластер \"Оса\"",
		INSTRUMENTAL = "бластером \"Оса\"",
		PREPOSITIONAL = "бластере \"Оса\"",
	)

/obj/item/gun/energy/accumulator/egun/automatic
	name = "E-AR \"Скорпион\""
	desc = "Энергетический автомат \"Скорпион\", работающий на съёмных аккумуляторах. Популярен среди силовых структур по всей галактике как мощное оружие для штурма и подавления множества целей, имеет магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке."
	icon_state = "EAR"
	item_state = "EAR"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/weak, /obj/item/ammo_casing/energy/laser/weak)
	autofire_delay = 3
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_RIFLE
	slot_flags = ITEM_SLOT_SUITSTORE
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 5),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -7),
	)
	ammo_x_offset = 0

/obj/item/gun/energy/accumulator/egun/automatic/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/automatic_fire, autofire_delay)

/obj/item/gun/energy/accumulator/egun/automatic/get_ru_names()
	return list(
		NOMINATIVE = "энергетический автомат",
		GENITIVE = "энергетического автомата",
		DATIVE = "энергетическому автомату",
		ACCUSATIVE = "энергетический автомат",
		INSTRUMENTAL = "энергетическим автоматом",
		PREPOSITIONAL = "энергетическом автомате",
	)

/obj/item/gun/energy/accumulator/egun/shotgun
	name = "E-SG \"Скарабей\""
	desc = "Энергетический дробовик \"Скарабей\", работающий на съёмных аккумуляторах. Популярен среди силовых структур по всей галактике как мощное оружие для боя в тесных условиях, имеет магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке."
	icon_state = "ESG"
	item_state = "ESG"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/scatter, /obj/item/ammo_casing/energy/laser/scatter)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_RIFLE
	slot_flags = ITEM_SLOT_SUITSTORE
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 7),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -8),
	)
	ammo_x_offset = 0

/obj/item/gun/energy/accumulator/egun/shotgun/get_ru_names()
	return list(
		NOMINATIVE = "энергетический дробовик",
		GENITIVE = "энергетического робовика",
		DATIVE = "энергетическому дробовику",
		ACCUSATIVE = "энергетический дробовик",
		INSTRUMENTAL = "бэнергетическим дробовиком",
		PREPOSITIONAL = "энергетическом дробовике",
	)

/obj/item/gun/energy/accumulator/egun/sniper
	name = "E-SR \"Богомол\""
	desc = "Энергетическая снайперская винтовка \"Богомол\", работающая на съёмных аккумуляторах. Популярна среди силовых структур по всей галактике как мощное оружие для боя на дальних дистанциях, имеет магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке."
	icon = 'icons/obj/weapons/guns_48x32.dmi'
	icon_state = "ESR"
	item_state = "ESR"
	ammo_type = list( /obj/item/ammo_casing/energy/disabler/heavy, /obj/item/ammo_casing/energy/laser/heavy)
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_SNIPER
	slot_flags = ITEM_SLOT_SUITSTORE | ITEM_SLOT_BACK
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 4, "y" = 6),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -7),
	)
	ammo_x_offset = 0

/obj/item/gun/energy/accumulator/egun/sniper/get_ru_names()
	return list(
		NOMINATIVE = "энергетическая снайперская винтовка",
		GENITIVE = "энергетической снайперской винтовки",
		DATIVE = "энергетической снайперской винтовке",
		ACCUSATIVE = "энергетическую снайперскую винтовку",
		INSTRUMENTAL = "энергетической снайперской винтовкой",
		PREPOSITIONAL = "энергетической снайперской винтовке",
	)

/obj/item/gun/energy/accumulator/specter
	name = "Энергетический пистолет \"Спектр\"."
	desc = "Современный пистолет \"Спектр\", работающий на съёмных аккумуляторах, имеет встроенные магнитные захваты для быстрой перезарядки аккумуляторов хранящихся в поясе или тактической разгрузке. Поставляется только силовым структурам Нанотрайзен."
	icon_state = "specter"
	item_state = "specter"
	force = 10
	origin_tech = "combat=4;materials=2"
	accumulator_type = /obj/item/weapon_cell/specter
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	materials = list(MAT_METAL = 10000)
	accuracy = GUN_ACCURACY_PISTOL
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_RAIL | GUN_MODULE_CLASS_PISTOL_UNDER
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 2, "y" = 11),
		ATTACHMENT_SLOT_UNDER = list("x" = 8, "y" = -3),
	)
	ammo_x_offset = 0

	var/rail_color
	var/grip_color

/obj/item/gun/energy/accumulator/specter/get_ru_names()
	return list(
		NOMINATIVE = "спектр",
		GENITIVE = "спектра",
		DATIVE = "спектру",
		ACCUSATIVE = "спектр",
		INSTRUMENTAL = "спектром",
		PREPOSITIONAL = "спектре",
	)

/obj/item/gun/energy/accumulator/specter/update_overlays()
	. = ..()

	if(rail_color)
		var/image/rail = image(icon = icon, icon_state = "specter_rail")
		rail.color = rail_color
		rail.blend_mode = BLEND_DEFAULT
		if(!cell && findtext(icon_state, "-e"))
			rail.pixel_x = -4
		. += rail

	if(grip_color)
		var/image/grip = image(icon = icon, icon_state = "specter_grip")
		grip.color = grip_color
		grip.blend_mode = BLEND_DEFAULT
		. += grip

/obj/item/gun/energy/accumulator/specter/update_icon_state()
	if(!cell)
		icon_state = "[initial(icon_state)]-e"
	else
		icon_state = initial(icon_state)

/obj/item/gun/energy/accumulator/specter/examine(mob/user)
	. = ..()
	. += span_notice("Используйте \"Настроить Спектр\" в меню предмета для покраски.")

/obj/item/gun/energy/accumulator/specter/verb/customize_specter()
	set name = "Настроить Спектр"
	set category = VERB_CATEGORY_OBJECT
	set src in view(1)

	if(usr.incapacitated() || !usr.Adjacent(src))
		return

	var/choice = alert(usr, "Что покрасить?", "Покраска Спектра", "Затвор", "Рукоятка", "Сбросить всё")

	switch(choice)
		if("Затвор")
			var/color = input(usr, "Цвет затвора:", "Покраска Спектра", rail_color) as color|null
			if(color && usr.Adjacent(src))
				rail_color = color
				update_icon()
		if("Рукоятка")
			var/color = input(usr, "Цвет рукоятки:", "Покраска Спектра", grip_color) as color|null
			if(color && usr.Adjacent(src))
				grip_color = color
				update_icon()
		if("Сбросить всё")
			rail_color = null
			grip_color = null
			update_icon()

/obj/item/gun/energy/emittergun
	name = "Handicraft Emitter Rifle"
	desc = "A rifle constructed of some trash materials. Looks rough but very powerful."
	icon_state = "emittercannonvgovne"
	item_state = null
	origin_tech = "combat=3;materials=3;powerstorage=2;magnets=2"
	weapon_weight = WEAPON_HEAVY
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	can_holster = FALSE
	cell_type = /obj/item/stock_parts/cell/emittergun
	ammo_type = list(/obj/item/ammo_casing/energy/emittergun)
	accuracy = GUN_ACCURACY_MINIMAL
	attachable_allowed = GUN_MODULE_CLASS_RIFLE_RAIL
	attachable_offset = list(
		ATTACHMENT_SLOT_RAIL = list("x" = 0, "y" = 7),
	)

/obj/item/gun/energy/vortex_shotgun
	name = "reality vortex wrist mounted shotgun"
	desc = "Это оружие использует силу вихревой аномалии для локального разрушения ткани реальности."
	icon_state = "flayer" //Sorta wrist mounted? Sorta? Not really but we work with what we got.
	ammo_type = list(/obj/item/ammo_casing/energy/vortex_blast)
	fire_sound = 'sound/weapons/bladeslice.ogg'
	cell_type = /obj/item/stock_parts/cell/infinite

/obj/item/gun/energy/vortex_shotgun/get_ru_names()
	return list(
		NOMINATIVE = "вортекс-дробовик",
		GENITIVE = "вортекс-дробовика",
		DATIVE = "вортекс-дробовику",
		ACCUSATIVE = "вортекс-дробовик",
		INSTRUMENTAL = "вортекс-дробовиком",
		PREPOSITIONAL = "вортекс-дробовике",
	)

/obj/item/ammo_casing/energy/vortex_blast
	projectile_type = /obj/projectile/energy/vortex_blast
	muzzle_flash_effect = /obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast
	variance = 70
	pellets = 8
	delay = 1.2 SECONDS //and delay has to be stored here on energy guns
	select_name = "vortex blast"
	fire_sound = 'sound/weapons/wave.ogg'

/obj/projectile/energy/vortex_blast
	name = "vortex blast"
	damage = 2
	range = 5
	icon_state = "magspear"
	hitsound = 'sound/weapons/sear.ogg' //Gets a bit spamy, suppressed is needed to suffer less
	hitsound_wall = null
	suppressed = TRUE

/obj/projectile/energy/vortex_blast/get_ru_names()
	return list(
		NOMINATIVE = "вортекс-выстрел",
		GENITIVE = "вортекс-выстрела",
		DATIVE = "вортекс-выстрелу",
		ACCUSATIVE = "вортекс-выстрел",
		INSTRUMENTAL = "вортекс-выстрелом",
		PREPOSITIONAL = "вортекс-выстреле",
	)

/obj/projectile/energy/vortex_blast/prehit(atom/target)
	. = ..()
	if(ishuman(target))
		return
	if(isliving(target))
		damage *= 6 //Up damage if not a human as we are not doing shenanigins
		return
	damage *= 15 //objects tend to fall apart as atoms are ripped up

/obj/projectile/energy/vortex_blast/on_hit(atom/target, blocked = 0)
	if(blocked >= 100)
		return ..()
	if(ishuman(target))
		var/mob/living/carbon/human/livivng_target = target
		var/obj/item/organ/external/affecting = livivng_target.get_organ(ran_zone(def_zone))
		livivng_target.apply_damage(2, BRUTE, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.apply_damage(2, TOX, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.apply_damage(2, CLONE, affecting, livivng_target.run_armor_check(affecting, ENERGY))
		livivng_target.adjustBrainLoss(3)
	..()

/obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast
	invisibility = INVISIBILITY_ABSTRACT // visual is from effect

/obj/effect/temp_visual/target_angled/muzzle_flash/vortex_blast/Initialize(mapload, atom/target, duration_override)
	. = ..()
	if(target)
		new /obj/effect/warp_effect/vortex_blast(loc, target)

/obj/effect/warp_effect/vortex_blast
	icon = 'icons/effects/64x64.dmi'
	icon_state = "vortex_shotgun"

/obj/effect/warp_effect/vortex_blast/Initialize(mapload, target)
	. = ..()
	var/matrix/our_matrix = matrix() * 0.5
	our_matrix.Turn(get_angle(src, target) - 45)
	transform = our_matrix
	animate(src, transform = our_matrix * 10, time = 0.3 SECONDS, alpha = 0)
	QDEL_IN(src, 0.3 SECONDS)

// Shield breaker //
#define PLASMA_CHARGE_USE_PER_SECOND 2.5
#define PLASMA_DISCHARGE_LIMIT 5

// MARK: Plasma pistol
/obj/item/gun/energy/plasma_pistol
	name = "plasma pistol"
	desc = "A specialized firearm designed to fire superheated bolts of plasma. Can be overloaded for a high damage, shield-breaking shot."
	icon_state = "plasmagun"
	item_state = "plasmagun"
	origin_tech = "combat=6;magnets=5;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/weak_plasma, /obj/item/ammo_casing/energy/charged_plasma)
	shaded_charge = TRUE
	atom_say_verb = list("бупает", "бипает")
	bubble_icon = "swarmer"
	light_color = "#89078E"
	light_power = 4
	accuracy = GUN_ACCURACY_PISTOL
	var/overloaded = FALSE
	var/warned = FALSE
	var/charging = FALSE
	var/charge_failure = FALSE
	var/mob/living/carbon/holder = null

/obj/item/gun/energy/plasma_pistol/examine(mob/user)
	. = ..()
	. += span_warning("Beware! Improper handling of [src] may release a cloud of highly flammable plasma gas!")

/obj/item/gun/energy/plasma_pistol/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/obj/item/gun/energy/plasma_pistol/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	holder = null
	return ..()

/obj/item/gun/energy/plasma_pistol/process()
	..()
	if(overloaded)
		cell.charge -= PLASMA_CHARGE_USE_PER_SECOND / 5 //2.5 per second, 25 every 10 seconds
		if(cell.charge <= PLASMA_CHARGE_USE_PER_SECOND * 10 && !warned)
			warned = TRUE
			playsound(loc, 'sound/weapons/smg_empty_alarm.ogg', 75, TRUE)
			atom_say("Caution, charge low. Forced discharge in under 10 seconds.", use_tts = FALSE)
		if(cell.charge <= PLASMA_DISCHARGE_LIMIT)
			discharge()

/obj/item/gun/energy/plasma_pistol/attack_self(mob/living/user)
	if(overloaded)
		to_chat(user, span_warning("[src] is already overloaded!"))
		return
	if(cell.charge <= 140) // at least 6 seconds of charge time
		to_chat(user, span_warning("[src] does not have enough charge to be overloaded."))
		return
	if(charging)
		to_chat(user, span_warning("[src] is already charging!"))
		return
	to_chat(user, span_notice("You begin to overload [src]."))
	charging = TRUE
	charge_failure = FALSE
	holder = user
	RegisterSignal(holder, COMSIG_MOB_SWAP_HANDS, PROC_REF(fail_charge))
	addtimer(CALLBACK(src, PROC_REF(overload)), 2.5 SECONDS)

/obj/item/gun/energy/plasma_pistol/proc/fail_charge()
	SIGNAL_HANDLER // COMSIG_MOB_SWAP_HANDS
	charge_failure = TRUE // No charging 2 guns at once.
	UnregisterSignal(holder, COMSIG_MOB_SWAP_HANDS)

/obj/item/gun/energy/plasma_pistol/proc/overload()
	UnregisterSignal(holder, COMSIG_MOB_SWAP_HANDS)
	if(ishuman(loc) && !charge_failure)
		var/mob/living/carbon/carbon = loc
		select_fire(carbon)
		overloaded = TRUE
		cell.use(125)
		playsound(carbon.loc, 'sound/machines/terminal_prompt_confirm.ogg', 75, TRUE)
		atom_say("Overloading failure.", use_tts = FALSE)
		set_light(3) // extra visual effect to make it more noticable to user and victims alike
		holder = carbon
		RegisterSignal(holder, COMSIG_MOB_SWAP_HANDS, PROC_REF(discharge))
	else
		balloon_alert_to_viewers("overloading failure")
		playsound(loc, 'sound/machines/buzz-sigh.ogg', 75, TRUE)
	charging = FALSE
	charge_failure = FALSE

/obj/item/gun/energy/plasma_pistol/proc/reset_overloaded()
	select_fire()
	set_light(0)
	overloaded = FALSE
	warned = FALSE
	UnregisterSignal(holder, COMSIG_MOB_SWAP_HANDS)
	holder = null

/obj/item/gun/energy/plasma_pistol/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	if(charging)
		return
	return ..()

/obj/item/gun/energy/plasma_pistol/handle_chamber()
	if(overloaded)
		do_sparks(2, TRUE, src)
		reset_overloaded()
	..()
	update_icon()

/obj/item/gun/energy/plasma_pistol/emp_act(severity)
	..()
	charge_failure = TRUE
	if(prob(100 / severity) && overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/dropped(mob/user)
	. = ..()
	charge_failure = TRUE
	if(overloaded)
		discharge()

/obj/item/gun/energy/plasma_pistol/equipped(mob/user, slot, initial)
	. = ..()
	charge_failure = TRUE
	if(overloaded)
		discharge()

//25% of the time, plasma leak. Otherwise, shoot at a random mob / turf nearby. If no proper mob is found when mob is picked, fire at a turf instead
/obj/item/gun/energy/plasma_pistol/proc/discharge()
	SIGNAL_HANDLER
	reset_overloaded()
	do_sparks(2, TRUE, src)
	update_icon()
	visible_message(span_danger("[src] vents heated plasma!"))
	var/turf/simulated/turf = get_turf(src)
	if(istype(turf))
		turf.atmos_spawn_air(LINDA_SPAWN_TOXINS|LINDA_SPAWN_20C,15)

#undef PLASMA_CHARGE_USE_PER_SECOND
#undef PLASMA_DISCHARGE_LIMIT
