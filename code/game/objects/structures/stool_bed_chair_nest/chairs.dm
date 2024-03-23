/obj/structure/chair	// fuck you Pete and Jonsonmt
	name = "chair"
	desc = "You sit in this. Either by will or force."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair"
	layer = OBJ_LAYER
	can_buckle = TRUE
	buckle_lying = FALSE // you sit in a chair, not lay
	resistance_flags = NONE
	max_integrity = 250
	integrity_failure = 25
	buckle_offset = 0
	var/buildstacktype = /obj/item/stack/sheet/metal
	var/buildstackamount = 1
	var/item_chair = /obj/item/chair // if null it can't be picked up
	var/movable = FALSE // For mobility checks
	var/propelled = FALSE // Check for fire-extinguisher-driven chairs
	var/comfort = 0.3

/obj/structure/chair/narsie_act()
	if(prob(20))
		var/obj/structure/chair/wood/W = new/obj/structure/chair/wood(get_turf(src))
		W.setDir(dir)
		qdel(src)

/obj/structure/chair/ratvar_act()
	var/obj/structure/chair/brass/B = new(get_turf(src))
	B.setDir(dir)
	qdel(src)

/obj/structure/chair/Move(atom/newloc, direct)
	. = ..()
	handle_rotation()

/obj/structure/chair/buckle_mob(mob/living/M, force, check_loc)
	. = ..()
	if(. && !movable)
		anchored = TRUE

/obj/structure/chair/unbuckle_mob(mob/living/buckled_mob, force)
	anchored = initial(anchored)
	. = ..()

/obj/structure/chair/attackby(obj/item/W as obj, mob/user as mob, params)
	if(istype(W, /obj/item/assembly/shock_kit))
		var/obj/item/assembly/shock_kit/SK = W
		if(!SK.status)
			to_chat(user, span_notice("[SK] is not ready to be attached!"))
			return
		user.drop_from_active_hand()
		var/obj/structure/chair/e_chair/E = new /obj/structure/chair/e_chair(get_turf(src), SK)
		E.add_fingerprint(user)
		playsound(src.loc, W.usesound, 50, 1)
		E.dir = dir
		SK.loc = E
		SK.master = E
		qdel(src)
		return
	return ..()

/obj/structure/chair/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(flags & NODECONSTRUCT)
		to_chat(user, span_warning("Try as you might, you can't figure out how to deconstruct [src]."))
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	deconstruct(TRUE)

/obj/structure/chair/deconstruct()
	// If we have materials, and don't have the NOCONSTRUCT flag
	if(buildstacktype && (!(flags & NODECONSTRUCT)))
		new buildstacktype(loc, buildstackamount)
	..()


/obj/structure/chair/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(over_object == usr && ishuman(usr) && item_chair && !anchored && !has_buckled_mobs() && usr.Adjacent(src))
		if(usr.incapacitated())
			to_chat(usr, span_warning("You can't do that right now!"))
			return
		if(!usr.has_right_hand() && !usr.has_left_hand())
			to_chat(usr, span_warning("You try to grab the chair, but you are missing both of your hands!"))
			return
		if(usr.get_active_hand() && usr.get_inactive_hand())
			to_chat(usr, span_warning("You try to grab the chair, but your hands are already full!"))
			return
		usr.visible_message(
			span_notice("[usr] grabs [src]."),
			span_notice("You grab [src]."),
		)
		var/new_chair = new item_chair(drop_location())
		transfer_fingerprints_to(new_chair)
		usr.put_in_hands(new_chair, ignore_anim = FALSE)
		qdel(src)
		return FALSE

	return ..()


/obj/structure/chair/attack_tk(mob/user)
	if(!anchored || has_buckled_mobs() || !isturf(user.loc))
		..()
	else
		rotate()


/obj/structure/chair/proc/handle_rotation(direction)
	handle_layer()
	if(has_buckled_mobs())
		for(var/mob/living/buckled_mob as anything in buckled_mobs)
			buckled_mob.setDir(direction)


/obj/structure/chair/proc/handle_layer()
	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER


/obj/structure/chair/post_buckle_mob(mob/living/M)
	. = ..()
	handle_layer()


/obj/structure/chair/post_unbuckle_mob()
	. = ..()
	handle_layer()


/obj/structure/chair/setDir(newdir)
	..()
	handle_rotation(newdir)


/obj/structure/chair/examine(mob/user)
	. = ..()
	. += span_info("You can <b>Alt-Click</b> [src] to rotate it.")


/obj/structure/chair/proc/rotate(mob/living/user)
	if(user)
		if(isobserver(user))
			if(!CONFIG_GET(flag/ghost_interaction))
				return FALSE
		else if(!isliving(user) || user.incapacitated() || !Adjacent(user))
			return FALSE

	setDir(turn(dir, 90))
	handle_rotation()
	return TRUE


/obj/structure/chair/AltClick(mob/living/user)
	rotate(user)


/obj/structure/chair/verb/rotate_chair()
	set name = "Rotate Chair"
	set category = "Object"
	set src in oview(1)

	rotate(usr)


// CHAIR TYPES

/obj/structure/chair/wood
	name = "wooden chair"
	desc = "Old is never too old to not be in fashion."
	icon_state = "wooden_chair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 3
	buildstacktype = /obj/item/stack/sheet/wood
	item_chair = /obj/item/chair/wood

/obj/structure/chair/wood/narsie_act()
	return

/obj/structure/chair/wood/wings
	icon_state = "wooden_chair_wings"
	item_chair = /obj/item/chair/wood/wings

/obj/structure/chair/comfy
	name = "comfy chair"
	desc = "It looks comfy."
	icon_state = "comfychair"
	color = rgb(255, 255, 255)
	resistance_flags = FLAMMABLE
	max_integrity = 70
	buildstackamount = 2
	item_chair = null
	comfort = 0.6
	var/image/armrest = null

/obj/structure/chair/comfy/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/comfy/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "comfychair_armrest")

/obj/structure/chair/comfy/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/comfy/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/comfy/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/comfy/brown
	color = rgb(141,70,0)

/obj/structure/chair/comfy/red
	color = rgb(218,2,10)

/obj/structure/chair/comfy/teal
	color = rgb(0,234,250)

/obj/structure/chair/comfy/black
	color = rgb(60,60,60)

/obj/structure/chair/comfy/green
	color = rgb(1,196,8)

/obj/structure/chair/comfy/purp
	color = rgb(112,2,176)

/obj/structure/chair/comfy/blue
	color = rgb(2,9,210)

/obj/structure/chair/comfy/beige
	color = rgb(255,253,195)

/obj/structure/chair/comfy/lime
	color = rgb(255,251,0)

/obj/structure/chair/comfy/shuttle
	name = "shuttle seat"
	desc = "A comfortable, secure seat. It has a more sturdy looking buckling system, for smoother flights."
	icon_state = "shuttle_chair"
	anchored = TRUE

/obj/structure/chair/comfy/shuttle/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "shuttle_chair_armrest")

/obj/structure/chair/comfy/shuttle/dark
	icon_state = "shuttle_chair_dark"

/obj/structure/chair/comfy/shuttle/dark/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "shuttle_chair_dark_armrest")

/obj/structure/chair/office
	movable = TRUE
	item_chair = null
	buildstackamount = 5
	pull_push_speed_modifier = 1

/obj/structure/chair/office/Bump(atom/A)
	..()
	if(!has_buckled_mobs())
		return

	if(propelled)
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			unbuckle_mob(buckled_mob)
			buckled_mob.throw_at(A, 3, propelled)
			buckled_mob.Weaken(12 SECONDS)
			buckled_mob.Stuttering(12 SECONDS)
			buckled_mob.take_organ_damage(10)
			playsound(loc, 'sound/weapons/punch1.ogg', 50, 1, -1)
			buckled_mob.visible_message(span_danger("[buckled_mob] crashed into [A]!"))

/obj/structure/chair/office/light
	icon_state = "officechair_white"

/obj/structure/chair/office/dark
	icon_state = "officechair_dark"

/obj/structure/chair/barber
	icon_state = "barber_chair"
	item_chair = null
	anchored = TRUE

// SOFAS
/obj/structure/chair/sofa
	name = "sofa"
	icon_state = "leather_sofa_middle"
	anchored = TRUE
	item_chair = null
	comfort = 0.6
	var/mutable_appearance/armrest

/obj/structure/chair/sofa/Initialize(mapload)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/chair/sofa/proc/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/sofa/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/chair/sofa/post_buckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_armrest()

/obj/structure/chair/sofa/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

/obj/structure/chair/sofa/left
	icon_state = "leather_sofa_left"

/obj/structure/chair/sofa/right
	icon_state = "leather_sofa_right"

/obj/structure/chair/sofa/corner
	icon_state = "leather_sofa_corner"

/obj/structure/chair/sofa/corp
	name = "sofa"
	desc = "Soft and cushy."
	icon_state = "corp_sofamiddle"

/obj/structure/chair/sofa/corp/left
	icon_state = "corp_sofaend_left"

/obj/structure/chair/sofa/corp/right
	icon_state = "corp_sofaend_right"

/obj/structure/chair/sofa/corp/corner
	icon_state = "corp_sofacorner"

/obj/structure/chair/sofa/pew
	name = "pew"
	desc = "Rigid and uncomfortable, perfect for keeping you awake and alert."
	icon_state = "pewmiddle"
	buildstacktype = /obj/item/stack/sheet/wood
	comfort = 0.2

/obj/structure/chair/sofa/pew/left
	icon_state = "pewend_left"

/obj/structure/chair/sofa/pew/right
	icon_state = "pewend_right"

/obj/structure/chair/stool
	name = "stool"
	desc = "Apply butt."
	icon_state = "stool"
	item_chair = /obj/item/chair/stool

/obj/structure/chair/stool/bar
	name = "bar stool"
	desc = "It has some unsavory stains on it..."
	icon_state = "bar"
	item_chair = /obj/item/chair/stool/bar

/obj/structure/chair/stool/bar/dark
	icon_state = "bar_dark"
	item_chair = /obj/item/chair/stool/bar/dark

/obj/structure/chair/stool/handle_layer()
	return

/obj/item/chair
	name = "chair"
	desc = "Bar brawl essential."
	icon = 'icons/obj/chairs.dmi'
	icon_state = "chair_toppled"
	item_state = "chair"
	lefthand_file = 'icons/mob/inhands/chairs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chairs_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	force = 8
	throwforce = 10
	throw_range = 3
	hitsound = 'sound/items/trayhit1.ogg'
	hit_reaction_chance = 50
	materials = list(MAT_METAL = 2000)
	var/break_chance = 5 //Likely hood of smashing the chair.
	var/obj/structure/chair/origin_type = /obj/structure/chair


/obj/item/chair/stool
	name = "stool"
	icon = 'icons/obj/chairs.dmi'
	icon_state = "stool_toppled"
	item_state = "stool"
	force = 10
	origin_type = /obj/structure/chair/stool
	break_chance = 0 //It's too sturdy.

/obj/item/chair/stool/bar
	name = "bar stool"
	icon_state = "bar_toppled"
	item_state = "stool_bar"
	origin_type = /obj/structure/chair/stool/bar

/obj/item/chair/stool/bar/dark
	icon_state = "bar_toppled_dark"
	item_state = "stool_bar_dark"
	origin_type = /obj/structure/chair/stool/bar/dark

/obj/item/chair/attack_self(mob/user)
	plant(user)

/obj/item/chair/proc/plant(mob/user)
	if(QDELETED(src))
		return

	for(var/obj/A in get_turf(loc))
		if(istype(A, /obj/structure/chair))
			to_chat(user, span_danger("There is already [A] here."))
			return

	user.visible_message(span_notice("[user] rights \the [src]."), span_notice("You right \the [src]."))
	var/obj/structure/chair/C = new origin_type(get_turf(loc))
	transfer_fingerprints_to(C)
	C.setDir(dir)
	qdel(src)

/obj/item/chair/proc/smash()
	var/stack_type = initial(origin_type.buildstacktype)
	if(!stack_type)
		return
	var/remaining_mats = initial(origin_type.buildstackamount)
	remaining_mats-- //Part of the chair was rendered completely unusable. It magically dissapears. Maybe make some dirt?
	if(remaining_mats)
		for(var/M=1 to remaining_mats)
			new stack_type(get_turf(loc))
	qdel(src)

/obj/item/chair/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(attack_type == UNARMED_ATTACK && prob(hit_reaction_chance))
		owner.visible_message(span_danger("[owner] fends off [attack_text] with [src]!"))
		return TRUE
	return FALSE

/obj/item/chair/attack(mob/M, mob/user)
	if(..() && prob(break_chance))
		user.visible_message(span_combatdanger("[user] smashes \the [src] to pieces against \the [M]."))
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(C.health < C.maxHealth*0.5)
				C.Weaken(12 SECONDS)
				C.Stuttering(12 SECONDS)
				playsound(loc, 'sound/weapons/punch1.ogg', 50, TRUE, -1)
		smash()
		return TRUE

/obj/item/chair/attack_obj(obj/O, mob/living/user, params)
	..()
	if(prob(break_chance))
		user.visible_message(span_danger("[user] smashes \the [src] to pieces against \the [O]."))
		smash()

/obj/item/chair/wood
	name = "wooden chair"
	icon_state = "wooden_chair_toppled"
	item_state = "woodenchair"
	resistance_flags = FLAMMABLE
	max_integrity = 70
	hitsound = 'sound/weapons/genhit1.ogg'
	origin_type = /obj/structure/chair/wood
	materials = null
	break_chance = 50

/obj/item/chair/wood/narsie_act()
	return

/obj/item/chair/wood/wings
	icon_state = "wooden_chair_wings_toppled"
	origin_type = /obj/structure/chair/wood/wings

/obj/structure/chair/old
	name = "strange chair"
	desc = "You sit in this. Either by will or force. Looks REALLY uncomfortable."
	icon_state = "chairold"
	item_chair = null
	comfort = 0

// Brass chair
/obj/structure/chair/brass
	name = "brass chair"
	desc = "A spinny chair made of brass. It looks uncomfortable."
	icon_state = "brass_chair"
	max_integrity = 150
	buildstacktype = /obj/item/stack/sheet/brass
	item_chair = null
	comfort = 0.2
	var/turns = 0

/obj/structure/chair/brass/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	. = ..()

/obj/structure/chair/brass/process()
	setDir(turn(dir, -90))
	playsound(src, 'sound/effects/servostep.ogg', 50, FALSE)
	turns++
	if(turns >= 8)
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/brass/ratvar_act()
	return

/obj/structure/chair/brass/AltClick(mob/living/user)
	if(!istype(user) || user.incapacitated())
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user))
		return
	add_fingerprint(user)
	turns = 0
	if(!isprocessing)
		user.visible_message(span_notice("[user] spins [src] around, and Ratvarian technology keeps it spinning FOREVER."), \
		span_notice("Automated spinny chairs. The pinnacle of Ratvarian technology."))
		START_PROCESSING(SSfastprocess, src)
	else
		user.visible_message(span_notice("[user] stops [src]'s uncontrollable spinning."), \
		span_notice("You grab [src] and stop its wild spinning."))
		STOP_PROCESSING(SSfastprocess, src)

/obj/structure/chair/brass/fake
	name = "brass chair"
	desc = "A spinny chair made of brass. It looks uncomfortable. Totally not magic!"
	buildstacktype = /obj/item/stack/sheet/brass_fake

/obj/structure/chair/comfy/abductor
	name = "alien chair"
	desc = "Alien chair. It look strange but comfortable."
	icon_state = "alien_chair"
	anchored = TRUE
	max_integrity = 375
	buildstacktype = /obj/item/stack/sheet/mineral/abductor

/obj/structure/chair/comfy/abductor/GetArmrest()
	return mutable_appearance('icons/obj/chairs.dmi', "alien_chair_armrest")
