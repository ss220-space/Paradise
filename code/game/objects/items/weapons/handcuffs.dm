/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Устройство из металла, представляющее собой пару соединённых цепью браслетов. \
			Используются для ограничения подвижности гуманоидов посредством сковывания кистей рук."
	gender = PLURAL
	icon_state = "handcuff"
	item_state = "handcuff"
	belt_icon = "handcuffs"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_HANDCUFFED
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "engineering=3;combat=3"
	breakout_time = 150 SECONDS
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	/// If TRUE, these cuffs are disposable
	var/trashtype = null
	var/ignoresClumsy = FALSE

/obj/item/restraints/handcuffs/get_ru_names()
	return list(
		NOMINATIVE = "наручники",
		GENITIVE = "наручников",
		DATIVE = "наручникам",
		ACCUSATIVE = "наручники",
		INSTRUMENTAL = "наручниками",
		PREPOSITIONAL = "наручниках"
	)

/obj/item/restraints/handcuffs/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!iscarbon(target))
		return .

	if(!user.IsAdvancedToolUser())
		return .

	if(HAS_TRAIT(src, TRAIT_NODROP) && !isrobot(user))
		balloon_alert(user, "не выпустить из руки!")
		return .

	if(target.handcuffed)
		balloon_alert(user, "цель уже скована!")
		return .

	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		balloon_alert(user, "у цели нет рук!")
		return .

	SEND_SIGNAL(target, COMSIG_CARBON_CUFF_ATTEMPTED, user)

	if(!ignoresClumsy && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		playsound(loc, cuffsound, 30, TRUE, -2)
		to_chat(user, span_warning("Эээ... Так какой стороной это использовать..?"))
		apply_cuffs(user, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	playsound(loc, cuffsound, 30, TRUE, -2)

	if(user == target)
		target.balloon_alert_to_viewers("начина[PLUR_ET_UT(user)] себя заковывать...", "заковывание себя...")
	else
		target.balloon_alert_to_viewers("начина[PLUR_ET_UT(user)] заковывать в [declent_ru(ACCUSATIVE)]...", "заковывание в [declent_ru(ACCUSATIVE)]...")

	var/handcuff_time_mod = 1

	if(HAS_TRAIT(user, TRAIT_FAST_CUFFING))
		handcuff_time_mod = 0.75

	if(!do_after(user, handcuff_time_mod * 5 SECONDS, target))
		balloon_alert(user, "заковывание прервано!")
		return .

	if(isrobot(user))
		apply_cuffs(target, user, TRUE)
	else
		apply_cuffs(target, user)
	return ATTACK_CHAIN_BLOCKED_ALL

/**
 * This handles handcuffing people
 *
 * When called, this instantly puts handcuffs on someone (if possible)
 * Arguments:
 * * mob/living/carbon/target - Who is being handcuffed
 * * mob/user - Who or what is doing the handcuffing
 * * dispense - True if the cuffing should create a new item instead of using putting src on the mob, false otherwise. False by default.
*/
/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, dispense = FALSE)
	if(target.handcuffed)
		return

	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		return

	if(!user.temporarily_remove_item_from_inventory(src) && !dispense)
		return

	var/obj/item/restraints/handcuffs/cuffs = src
	if(trashtype)
		cuffs = new trashtype()
	else if(dispense)
		cuffs = new type()

	target.equip_to_slot(cuffs, ITEM_SLOT_HANDCUFFED)

	if(user == target)
		target.balloon_alert_to_viewers("заковыва[PLUR_ET_UT(user)] сам себя", "вы себя заковали")
	else
		target.balloon_alert_to_viewers("заковыва[PLUR_ET_UT(user)] в [declent_ru(ACCUSATIVE)]", "цель закована в [declent_ru(ACCUSATIVE)]")

	add_attack_logs(user, target, "Handcuffed ([src])")
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)

	if(trashtype && !dispense)
		qdel(src)

/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "Сплетены из плотных сухожилий Наблюдателя. \
			Используются для ограничения подвижности гуманоидов посредством сковывания кистей рук."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	breakout_time = 1 MINUTES
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/sinew/get_ru_names()
	return list(
		NOMINATIVE = "стяжки из сухожилий",
		GENITIVE = "стяжек из сухожилий",
		DATIVE = "стяжкам из сухожилий",
		ACCUSATIVE = "стяжки из сухожилий",
		INSTRUMENTAL = "стяжками из сухожилий",
		PREPOSITIONAL = "стяжках из сухожилий"
	)

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Сплетены из электрических проводов. \
			Используются для ограничения подвижности гуманоидов посредством сковывания кистей рук."
	icon_state = "cuff_white"
	origin_tech = "engineering=2"
	materials = list(MAT_METAL=150, MAT_GLASS=75)
	breakout_time = 1 MINUTES
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable/get_ru_names()
	return list(
		NOMINATIVE = "стяжки из проводов",
		GENITIVE = "стяжек из проводов",
		DATIVE = "стяжкам из проводов",
		ACCUSATIVE = "стяжки из проводов",
		INSTRUMENTAL = "стяжками из проводов",
		PREPOSITIONAL = "стяжках из проводов"
	)

/obj/item/restraints/handcuffs/cable/red
	color = COLOR_RED

/obj/item/restraints/handcuffs/cable/yellow
	color = COLOR_YELLOW

/obj/item/restraints/handcuffs/cable/blue
	color = COLOR_BLUE

/obj/item/restraints/handcuffs/cable/green
	color = COLOR_GREEN

/obj/item/restraints/handcuffs/cable/pink
	color = COLOR_PINK

/obj/item/restraints/handcuffs/cable/orange
	color = COLOR_ORANGE

/obj/item/restraints/handcuffs/cable/cyan
	color = COLOR_CYAN

/obj/item/restraints/handcuffs/cable/white
	color = COLOR_WHITE

/obj/item/restraints/handcuffs/cable/random/New()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_WHITE, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	..()

/obj/item/restraints/handcuffs/cable/proc/cable_color(colorC)
	if(!colorC)
		color = COLOR_RED
	else if(colorC == "rainbow")
		color = color_rainbow()
	else if(colorC == "orange") //byond only knows 16 colors by name, and orange isn't one of them
		color = COLOR_ORANGE
	else
		color = colorC

/obj/item/restraints/handcuffs/cable/proc/color_rainbow()
	color = pick(COLOR_RED, COLOR_BLUE, COLOR_GREEN, COLOR_PINK, COLOR_YELLOW, COLOR_CYAN)
	return color

/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(!user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!rods.use(1))
			balloon_alert(user, "недостаточно стержней!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "стяжки намотаны на стержень")
		var/obj/item/wirerod/wirerod = new(drop_location())
		qdel(src)
		user.put_in_hands(wirerod, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < 6)
			balloon_alert(user, "недостаточно стали!")
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "создание болы...")
		if(!do_after(user, 3.5 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(metal) || !metal.use(6))
			return ATTACK_CHAIN_PROCEED
		balloon_alert(user, "бола собрана")
		var/obj/item/restraints/legcuffs/bola/bola = new(drop_location())
		qdel(src)
		user.put_in_hands(bola, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/toy/crayon))
		add_fingerprint(user)
		var/obj/item/toy/crayon/crayon = I
		cable_color(crayon.colourName)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Устройство из пластика, представляющее собой пару соединённых браслетов. \
			Используются для ограничения подвижности гуманоидов посредством сковывания кистей рук. \
			Не предназначены для многократного использования."
	breakout_time = 90 SECONDS
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used

/obj/item/restraints/handcuffs/cable/zipties/get_ru_names()
	return list(
		NOMINATIVE = "стяжки",
		GENITIVE = "стяжек",
		DATIVE = "стяжкам",
		ACCUSATIVE = "стяжки",
		INSTRUMENTAL = "стяжками",
		PREPOSITIONAL = "стяжках"
	)

/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "Сломанные и уже ни на что не годятся."
	icon_state = "cuff_white_used"

/obj/item/restraints/handcuffs/cable/zipties/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Устройство из металла, представляющее собой пару соединённых цепью браслетов. \
			Используются для ограничения подвижности заключённых посредством сковывания кистей рук. \
			Для чего данная модель отделана розовым мехом — вопрос."
	item_state = "cuff_pink"

/obj/item/restraints/handcuffs/pinkcuffs/get_ru_names()
	return list(
		NOMINATIVE = "розовые наручники",
		GENITIVE = "розовых наручников",
		DATIVE = "розовым наручникам",
		ACCUSATIVE = "розовые наручники",
		INSTRUMENTAL = "розовыми наручниками",
		PREPOSITIONAL = "розовых наручниках"
	)

/obj/item/restraints/handcuffs/manacles
	name = "manacles"
	desc = "Тяжёлые деревянные оковы, предназначенные для ограничения подвижности гуманоидов \
			посредством сковывания кистей рук."
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "manacle_lock"
	item_state = "manacle"
	breakout_time = 2 MINUTES
	cuffsound = 'sound/items/zippoclose.ogg'
	onmob_sheets = list(
		ITEM_SLOT_HANDCUFFED_STRING = 'icons/obj/ninjaobjects.dmi',
	)
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/manacles/used

/obj/item/restraints/handcuffs/manacles/get_ru_names()
	return list(
		NOMINATIVE = "кандалы",
		GENITIVE = "кандалов",
		DATIVE = "кандалам",
		ACCUSATIVE = "кандалы",
		INSTRUMENTAL = "кандалами",
		PREPOSITIONAL = "кандалах"
	)

/obj/item/restraints/handcuffs/manacles/used
	desc = "Сломанные и уже ни на что не годятся."
	icon_state = "manacle_unlock"

/obj/item/restraints/handcuffs/manacles/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED
