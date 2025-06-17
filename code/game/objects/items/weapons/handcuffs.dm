/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Используются для ограничения передвижения заключённых."
	ru_names = list(
		NOMINATIVE = "наручники",
		GENITIVE = "наручников",
		DATIVE = "наручникам",
		ACCUSATIVE = "наручники",
		INSTRUMENTAL = "наручниками",
		PREPOSITIONAL = "наручниках"
	)
	gender = PLURAL
	icon = 'icons/obj/items.dmi'
	icon_state = "handcuff"
	item_state = "handcuff"
	belt_icon = "handcuffs"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_HANDCUFFED
	throwforce = 5
	w_class = WEIGHT_CLASS_SMALL
	throw_speed = 2
	throw_range = 5
	materials = list(MAT_METAL=500)
	origin_tech = "engineering=3;combat=3"
	breakouttime = 600 //Deciseconds = 60s = 1 minutes
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	var/trashtype = null //For disposable cuffs
	var/ignoresClumsy = FALSE


/obj/item/restraints/handcuffs/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(!iscarbon(target)) // Shouldn't be able to cuff anything but carbons.
		return .

	if(!user.IsAdvancedToolUser())
		return .

	if(HAS_TRAIT(src, TRAIT_NODROP) && !isrobot(user))
		balloon_alert(user, ("прилипли к руке!"))
		return .

	if(target.handcuffed)
		balloon_alert(user, ("цель уже закована!"))
		return .

	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		balloon_alert(user, ("у цели нет рук!"))
		return .

	SEND_SIGNAL(target, COMSIG_CARBON_CUFF_ATTEMPTED, user)

	if(!ignoresClumsy && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		playsound(loc, cuffsound, 30, TRUE, -2)
		to_chat(user, span_warning("Эээм... как этим пользоваться?!"))
		apply_cuffs(user, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	playsound(loc, cuffsound, 30, TRUE, -2)

	if(user == target)
		target.visible_message(
			span_warning("[user] пыта[pluralize_ru(user.gender, "ется", "ются")] заковать себя в [name]!"),
			span_warning("Вы пытаетесь заковать себя в [name]!"),
		)
	else
		target.visible_message(
			span_danger("[user] пыта[pluralize_ru(user.gender, "ется", "ются")] заковать [target] в [name]!"),
			span_userdanger("[user] пыта[pluralize_ru(user.gender, "ется", "ются")] нацепить [name] на тебя!"),
		)

	if(!do_after(user, 5 SECONDS, target))
		to_chat(user, span_warning("Вы не смогли заковать [user == target ? "себя" : target]!"))
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
		target.visible_message(
			span_warning("[user] заковывает [user.p_themselves()]!"),
			span_warning("Вы заковали себя!"),
		)
	else
		target.visible_message(
			span_warning("[user] заковывает [target]!"),
			span_userdanger("[user] заковал вас!"),
		)

	add_attack_logs(user, target, "Закованный в ([src])")
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)

	if(trashtype && !dispense)
		qdel(src)


/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "Пара стяжек, сделанных из сухожилий."
	ru_names = list(
		NOMINATIVE = "стяжки из сухожилий",
		GENITIVE = "стяжек из сухожилий",
		DATIVE = "стяжкам из сухожилий",
		ACCUSATIVE = "стяжки из сухожилий",
		INSTRUMENTAL = "стяжками из сухожилий",
		PREPOSITIONAL = "стяжках из сухожилий"
	)
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Связанные вместе мотки кабеля. Можно использовать, чтобы связать что-либо или кого-либо."
	ru_names = list(
		NOMINATIVE = "кабельные стяжки",
		GENITIVE = "кабельных стяжек",
		DATIVE = "кабельным стяжкам",
		ACCUSATIVE = "кабельные стяжки",
		INSTRUMENTAL = "кабельными стяжками",
		PREPOSITIONAL = "кабельных стяжках"
	)
	icon_state = "cuff_white"
	origin_tech = "engineering=2"
	materials = list(MAT_METAL=150, MAT_GLASS=75)
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

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

/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/obj/item/restraints/handcuffs/pinkcuffs
	name = "fluffy pink handcuffs"
	desc = "Используются для ограничения передвижения заключённых. Или для своей второй половинки.."
	ru_names = list(
		NOMINATIVE = "пушистые розовые наручники",
		GENITIVE = "пушистых розовых наручников",
		DATIVE = "пушистым розовым наручникам",
		ACCUSATIVE = "пушистые розовые наручники",
		INSTRUMENTAL = "пушистыми розовыми наручниками",
		PREPOSITIONAL = "пушистых розовых наручниках"
	)
	icon_state = "pinkcuffs"
	item_state = "pinkcuff"


/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(!user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!rods.use(1))
			to_chat(user, span_warning("Для изготовления гирь вам понадобится не менее шести металлических листов!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы обернули стяжки вокруг верхушки металлического стержня."))
		var/obj/item/wirerod/wirerod = new(drop_location())
		qdel(src)
		user.put_in_hands(wirerod, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < 6)
			to_chat(user, span_warning("Для изготовления гирь вам понадобится не менее шести металлических листов!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы начали прикреплять [I] к [src]..."))
		if(!do_after(user, 3.5 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(metal) || !metal.use(6))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы делаете гири из [I] и привязываете их к [src]."))
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
	desc = "Пластиковые одноразовые стяжки, которые можно использовать для ограничения передвижения."
	ru_names = list(
		NOMINATIVE = "стяжки",
		GENITIVE = "стяжек",
		DATIVE = "стяжкам",
		ACCUSATIVE = "стяжки",
		INSTRUMENTAL = "стяжками",
		PREPOSITIONAL = "стяжках"
	)
	icon_state = "cuff_white"
	breakouttime = 450 //Deciseconds = 45s
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used


/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "Пара использованных стяжек."
	icon_state = "cuff_white_used"


/obj/item/restraints/handcuffs/cable/zipties/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/restraints/handcuffs/manacles
	name = "manacles"
	desc = "Аналог деревянных наручников. Используются для ограничения передвижения заключённых."
	ru_names = list(
		NOMINATIVE = "кандалы",
		GENITIVE = "кандалов",
		DATIVE = "кандалам",
		ACCUSATIVE = "кандалы",
		INSTRUMENTAL = "кандалами",
		PREPOSITIONAL = "кандалах"
	)
	icon = 'icons/obj/ninjaobjects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/ninja_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/ninja_righthand.dmi'
	icon_state = "manacle_lock"
	item_state = "manacle"
	breakouttime = 450 //Deciseconds = 45s
	cuffsound = 'sound/items/zippoclose.ogg'
	onmob_sheets = list(
		ITEM_SLOT_HANDCUFFED_STRING = 'icons/obj/ninjaobjects.dmi'
	)
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/manacles/used

/obj/item/restraints/handcuffs/manacles/used
	desc = "Пара использованных кандалов."
	icon_state = "manacle_unlock"

/obj/item/restraints/handcuffs/manacles/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

