/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
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
		to_chat(user, span_warning("[src] is stuck to your hand!"))
		return .

	if(target.handcuffed)
		to_chat(user, span_warning("[target] is already handcudffed!"))
		return .

	if(!target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
		to_chat(user, span_warning("How do you suggest handcuffing someone with no hands?"))
		return .

	if(!ignoresClumsy && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		playsound(loc, cuffsound, 30, TRUE, -2)
		to_chat(user, span_warning("Uh... how do those things work?!"))
		apply_cuffs(user, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	playsound(loc, cuffsound, 30, TRUE, -2)

	if(user == target)
		target.visible_message(
			span_warning("[user] is trying to put [name] on [user.p_themselves()]!"),
			span_warning("You are trying to put [name] on yourself!"),
		)
	else
		target.visible_message(
			span_danger("[user] is trying to put [name] on [target]!"),
			span_userdanger("[user] is trying to put [name] on you!"),
		)

	if(!do_after(user, 5 SECONDS, target))
		to_chat(user, span_warning("You failed to handcuff [user == target ? "yourself" : target]!"))
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
			span_warning("[user] handcuffs [user.p_themselves()]!"),
			span_warning("You handcuff yourself!"),
		)
	else
		target.visible_message(
			span_warning("[user] handcuffs [target]!"),
			span_userdanger("[user] handcuffs you!"),
		)

	add_attack_logs(user, target, "Handcuffed ([src])")
	SSblackbox.record_feedback("tally", "handcuffs", 1, type)

	if(trashtype && !dispense)
		qdel(src)


/obj/item/restraints/handcuffs/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon = 'icons/obj/mining.dmi'
	icon_state = "sinewcuff"
	item_state = "sinewcuff"
	breakouttime = 300 //Deciseconds = 30s
	cuffsound = 'sound/weapons/cablecuff.ogg'

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
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
	desc = "Use this to keep prisoners in line. Or you know, your significant other."
	icon_state = "pinkcuffs"
	item_state = "pinkcuff"


/obj/item/restraints/handcuffs/cable/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/stack/rods))
		add_fingerprint(user)
		var/obj/item/stack/rods/rods = I
		if(!user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!rods.use(1))
			to_chat(user, span_warning("You need at least six metal sheets to make good enough weights!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You wrap the cable restraint around the top of the rod."))
		var/obj/item/wirerod/wirerod = new(drop_location())
		qdel(src)
		user.put_in_hands(wirerod, ignore_anim = FALSE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/metal/metal = I
		if(metal.get_amount() < 6)
			to_chat(user, span_warning("You need at least six metal sheets to make good enough weights!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You start to apply [I] to [src]..."))
		if(!do_after(user, 3.5 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(metal) || !metal.use(6))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You make some weights out of [I] and tie them to [src]."))
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
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff_white"
	breakouttime = 450 //Deciseconds = 45s
	materials = list()
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used


/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_white_used"


/obj/item/restraints/handcuffs/cable/zipties/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED


/obj/item/restraints/handcuffs/manacles
	name = "manacles"
	desc = "Wooden handcuffs analogue. Use this to keep prisoners in line."
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
	desc = "A pair of broken manacles."
	icon_state = "manacle_unlock"

/obj/item/restraints/handcuffs/manacles/used/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

