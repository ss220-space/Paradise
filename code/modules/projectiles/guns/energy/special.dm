/**
 * Random energy gun like objects, whick do not fit in other categories (and their own files)
 */

// MARK: Decloner
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

// MARK: Flora Gun
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

// MARK: Meteor Gun
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

// MARK: Mind Flayer
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

// MARK: Cyborg LMG
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

// MARK: Instakill Lasers
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

// MARK: HONK Rifle
/obj/item/gun/energy/clown
	name = "HONK Rifle"
	desc = "Clown Planet's finest."
	icon_state = "honkrifle"
	item_state = null
	ammo_type = list(/obj/item/ammo_casing/energy/clown)
	clumsy_check = FALSE
	selfcharge = TRUE
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_MINIMAL

// MARK: Toxin pistol
/obj/item/gun/energy/toxgun
	name = "toxin pistol"
	desc = "A specialized firearm designed to fire lethal bolts of toxins."
	icon_state = "toxgun"
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/toxplasma)
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_RIFLE

// MARK: Mimic Gun
/obj/item/gun/energy/mimicgun
	name = "mimic gun"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse. Why does this one have teeth?"
	icon_state = "disabler"
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

// MARK: Vortex shotgun
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
		turf.atmos_spawn_air(LINDA_SPAWN_TOXINS, 15, T20C)

// MARK: Emitter cannon
/obj/item/gun/energy/emittercannon
	name = "Emitter Cannon"
	desc = "Looks clean and very powerful."
	ammo_type = list(/obj/item/ammo_casing/energy/emittergunborg)
	icon_state = "emittercannon"
	var/charge_cost = 750

/obj/item/gun/energy/emittercannon/emp_act(severity)
	return

// MARK: Chrono gun
/obj/item/gun/energy/chrono_gun
	name = "T.E.D. Projection Apparatus"
	desc = "It's as if they never existed in the first place."
	icon = 'icons/obj/chronos.dmi'
	icon_state = "chronogun"
	item_state = "chronogun"
	item_flags = DROPDEL
	ammo_type = list(/obj/item/ammo_casing/energy/chrono_beam)
	can_charge = FALSE
	fire_delay = 50
	var/obj/item/chrono_eraser/TED = null
	var/obj/structure/chrono_field/field = null
	var/turf/startpos = null

/obj/item/gun/energy/chrono_gun/Initialize(mapload, obj/item/chrono_eraser/T)
	. = ..()
	if(istype(T))
		TED = T
		ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)
	else //admin must have spawned it
		TED = new(src.loc)
		qdel(src)

/obj/item/gun/energy/chrono_gun/update_overlays()
	return list()

/obj/item/gun/energy/chrono_gun/process_fire(atom/target as mob|obj|turf, mob/living/user as mob|obj, message = 1, params, zone_override, bonus_spread = 0)
	if(field)
		field_disconnect(field)
	..()

/obj/item/gun/energy/chrono_gun/Destroy()
	if(TED)
		TED.PA = null
		TED = null
	if(field)
		field_disconnect(field)
	return ..()

/obj/item/gun/energy/chrono_gun/proc/field_connect(obj/structure/chrono_field/F)
	var/mob/living/user = src.loc
	if(F.gun)
		if(isliving(user) && F.captured)
			to_chat(user, span_alert("<b>FAIL: <i>[F.captured]</i> already has an existing connection.</b>"))
		src.field_disconnect(F)
	else
		startpos = get_turf(src)
		field = F
		F.gun = src
		if(isliving(user) && F.captured)
			to_chat(user, span_notice("Connection established with target: <b>[F.captured]</b>"))

/obj/item/gun/energy/chrono_gun/proc/field_disconnect(obj/structure/chrono_field/F)
	if(F && field == F)
		var/mob/living/user = src.loc
		if(F.gun == src)
			F.gun = null
		if(isliving(user) && F.captured)
			to_chat(user, span_alert("Disconnected from target: <b>[F.captured]</b>"))
	field = null
	startpos = null

/obj/item/gun/energy/chrono_gun/proc/field_check(obj/structure/chrono_field/F)
	if(F)
		if(field == F)
			var/turf/currentpos = get_turf(src)
			var/mob/living/user = src.loc
			if((currentpos == startpos) && (field in view(CHRONO_BEAM_RANGE, currentpos)) && !user.incapacitated())
				return 1
		field_disconnect(F)
		return 0

/obj/item/gun/energy/chrono_gun/proc/pass_mind(datum/mind/M)
	if(TED)
		TED.pass_mind(M)

// MARK: Shuriken emitter
/obj/item/gun/energy/shuriken_emitter
	name = "shuriken emitter"
	desc = "Спрятанный в костюме Ниндзя девайс. Выпускает 3 энергетических сюрикена, которые замедляют и временно ослепляют цели."
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "shuriken_emitter"
	item_state = ""
	ninja_weapon = TRUE
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = NONE
	item_flags = DROPDEL|ABSTRACT|NOBLUDGEON
	ammo_type = list(/obj/item/ammo_casing/energy/shuriken)
	can_charge = FALSE
	burst_size = 3
	var/cost = 100
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/toggle_shuriken_fire_mode/my_action = null

/obj/item/gun/energy/shuriken_emitter/get_ru_names()
	return list(
		NOMINATIVE = "генератор энергетических сюрикенов",
		GENITIVE = "генератора энергетических сюрикенов",
		DATIVE = "генератору энергетических сюрикенов",
		ACCUSATIVE = "генератор энергетических сюрикенов",
		INSTRUMENTAL = "генератором энергетических сюрикенов",
		PREPOSITIONAL = "генераторе энергетических сюрикенов",
	)

/obj/item/gun/energy/shuriken_emitter/Destroy()
	. = ..()
	my_suit?.shuriken_emitter = null
	my_suit = null
	my_action?.action_ready = FALSE
	my_action?.use_action()
	my_action = null

/obj/item/gun/energy/shuriken_emitter/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE)
	qdel(src)

/obj/item/gun/energy/shuriken_emitter/run_drop_held_item(mob/user)
	qdel(src)

/obj/item/gun/energy/shuriken_emitter/can_shoot(mob/user)
	return !my_suit.ninjacost(cost*burst_size)

/obj/item/gun/energy/shuriken_emitter/borg
	name = "robotic shuriken emitter"
	desc = "A device sneakily hidden inside your robotic hand. Shoots 3 energy shurikens that slows and temporary blinds their targets"
	ammo_type = list(/obj/item/ammo_casing/energy/shuriken/borg)
	// Эти два значения не нужны боргам — они не носят ниндзя костюм
	cost = null
	my_suit = null

/obj/item/gun/energy/shuriken_emitter/borg/equip_to_best_slot(mob/M)
	return

/obj/item/gun/energy/shuriken_emitter/borg/can_shoot(mob/user)
	return TRUE

// MARK: Vox spike thrower
/obj/item/gun/energy/spikethrower //It's like the cyborg LMG, uses energy to make spikes
	name = "Vox spike thrower"
	desc = "A vicious alien projectile weapon. Parts of it quiver gelatinously, as though the thing is insectile and alive."
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "spikethrower"
	item_state = "spikethrower"
	w_class = WEIGHT_CLASS_SMALL
	fire_sound_text = "a strange noise"
	burst_size = 2 // burst has to be stored here
	can_charge = FALSE
	selfcharge = TRUE
	charge_delay = 10
	restricted_species = list(/datum/species/vox)
	ammo_type = list(/obj/item/ammo_casing/energy/spike)

/obj/item/gun/energy/spikethrower/emp_act()
	return

// MARK: Noise cannon
/obj/item/gun/energy/noisecannon
	name = "alien heavy cannon"
	desc = "It's some kind of enormous alien weapon, as long as a man is tall."
	icon_state = "noisecannon"
	item_state = "noisecannon"
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/sonic)
	cell_type = /obj/item/stock_parts/cell/super
	restricted_species = list(/datum/species/vox/armalis)
	sprite_sheets_inhand = list(SPECIES_VOX_ARMALIS = 'icons/mob/clothing/species/armalis/held.dmi') //Big guns big birds.
	recoil = GUN_RECOIL_HIGH

/obj/item/gun/energy/noisecannon/update_icon_state()
	return

/obj/item/gun/energy/noisecannon/update_overlays()
	return list()

#undef PLASMA_CHARGE_USE_PER_SECOND
#undef PLASMA_DISCHARGE_LIMIT
