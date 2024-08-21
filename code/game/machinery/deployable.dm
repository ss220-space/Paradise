#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	var/proj_pass_rate = 50 //How many projectiles will pass the cover. Lower means stronger cover
	var/bar_material = METAL
	var/drop_amount = 3
	var/stacktype = /obj/item/stack/sheet/metal

/obj/structure/barricade/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		make_debris()
	qdel(src)


/obj/structure/barricade/proc/make_debris()
	if(stacktype)
		new stacktype(get_turf(src), drop_amount)

/obj/structure/barricade/welder_act(mob/user, obj/item/I)
	if(bar_material != METAL)
		return
	if(obj_integrity >= max_integrity)
		to_chat(user, span_notice("[src] does not need repairs."))
		return
	if(user.a_intent == INTENT_HARM)
		return
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_REPAIR_SUCCESS_MESSAGE
		obj_integrity = clamp(obj_integrity + 20, 0, max_integrity)
		update_icon()
	return TRUE


/obj/structure/barricade/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	if(isprojectile(mover) && !checkpass(mover))
		if(!anchored)
			return TRUE
		var/obj/item/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE


/obj/structure/barricade/attack_hand(mob/living/carbon/human/user)
	if(user.a_intent == INTENT_HARM && ishuman(user) && (user.dna.species.obj_damage + user.physiology.punch_obj_damage > 0))
		SEND_SIGNAL(src, COMSIG_ATOM_ATTACK_HAND, user)
		add_fingerprint(user)
		user.changeNext_move(CLICK_CD_MELEE)
		attack_generic(user, user.dna.species.obj_damage + user.physiology.punch_obj_damage)
		return
	else
		..()



/////BARRICADE TYPES///////

/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	bar_material = WOOD
	stacktype = /obj/item/stack/sheet/wood


/obj/structure/barricade/wooden/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I,/obj/item/stack/sheet/wood) && isturf(loc))
		add_fingerprint(user)
		var/obj/item/stack/sheet/wood/wood = I
		if(wood.get_amount() < 5)
			to_chat(user, span_warning("You need at least five wooden planks to make a wall!"))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You start adding [I] to [src]..."))
		if(do_after(user, 5 SECONDS, src) || QDELETED(wood) || !wood.use(5) || !isturf(loc))
			return ATTACK_CHAIN_PROCEED
		var/turf/our_turf = loc
		our_turf.ChangeTurf(/turf/simulated/wall/mineral/wood/nonmetal)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "woodenbarricade-old"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "woodenbarricade-snow-old"
	max_integrity = 75

/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags"
	base_icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags_self = LETPASSTHROW
	bar_material = SAND
	climbable = TRUE
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDBAGS
	canSmoothWith = SMOOTH_GROUP_SECURITY_BARRICADE + SMOOTH_GROUP_SANDBAGS + SMOOTH_GROUP_WALLS
	stacktype = null

/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/objects.dmi'
	icon_state = "barrier0"
	density = FALSE
	anchored = FALSE
	max_integrity = 180
	proj_pass_rate = 20
	armor = list(melee = 10, bullet = 50, laser = 50, energy = 50, bomb = 10, bio = 100, rad = 100, fire = 10, acid = 0)
	stacktype = null
	var/deploy_time = 40
	var/deploy_message = TRUE

/obj/structure/barricade/security/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(deploy)), deploy_time)

/obj/structure/barricade/security/proc/deploy()
	icon_state = "barrier1"
	set_density(TRUE)
	set_anchored(TRUE)
	if(deploy_message)
		visible_message(span_warning("[src] deploys!"))


/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "barrier"
	item_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle modes.")

/obj/item/grenade/barrier/AltClick(mob/living/carbon/user)
	if(!istype(user) || !user.Adjacent(src) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	toggle_mode(user)

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE

	to_chat(user, "[src] is now in [mode] mode.")

/obj/item/grenade/barrier/prime()
	new /obj/structure/barricade/security(get_turf(loc))
	switch(mode)
		if(VERTICAL)
			var/turf/target_turf = get_step(src, NORTH)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, SOUTH)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/turf/target_turf = get_step(src, EAST)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, WEST)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user, datum/action/action, leftclick)
	toggle_mode(user)


/obj/structure/barricade/mime
	name = "floor"
	desc = "Is... this a floor?"
	icon = 'icons/effects/water.dmi'
	icon_state = "wet_floor_static"
	stacktype = /obj/item/stack/sheet/mineral/tranquillite

/obj/structure/barricade/mime/mrcd
	stacktype = null

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
