/*
 * False Walls
 */

// Minimum pressure difference to fail building falsewalls.
// Also affects admin alerts.
#define FALSEDOOR_MAX_PRESSURE_DIFF 25.0

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"

	var/mineral = /obj/item/stack/sheet/metal
	var/mineral_amount = 2
	var/walltype = /turf/simulated/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE

	density = TRUE
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP// just in case in up. But falsewall should be on the floor.
	opacity = TRUE
	max_integrity = 100

	canSmoothWith = SMOOTH_GROUP_WALLS
	smoothing_groups = SMOOTH_GROUP_WALLS
	smooth = SMOOTH_BITMASK

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	air_update_turf(1)

/obj/structure/falsewall/examine_status(mob/user)
	var/healthpercent = (obj_integrity/max_integrity) * 100
	switch(healthpercent)
		if(100)
			. = "<span class='notice'>It looks fully intact.</span>"
		if(70 to 99)
			. =  "<span class='warning'>It looks slightly damaged.</span>"
		if(40 to 70)
			. =  "<span class='warning'>It looks moderately damaged.</span>"
		if(0 to 40)
			. = "<span class='danger'>It looks heavily damaged.</span>"
	. += "<br><span class='notice'>Using a lit welding tool on this item will allow you to slice through it, eventually removing the outer layer.</span>"

/obj/structure/falsewall/ratvar_act()
	new /obj/structure/falsewall/brass(loc)
	qdel(src)

/obj/structure/falsewall/Destroy()
	set_density(FALSE)
	air_update_turf(1)
	return ..()

/obj/structure/falsewall/CanAtmosPass(turf/T, vertical)
	return !density

/obj/structure/falsewall/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		toggle(user)

/obj/structure/falsewall/attack_hand(mob/user)
	. = ..()
	toggle(user)


/obj/structure/falsewall/proc/toggle(mob/user)
	if(opening)
		return
	opening = TRUE
	if(density)
		add_fingerprint(user)
		do_the_flick()
		sleep(0.4 SECONDS)
		set_density(FALSE)
		obj_flags &= ~BLOCK_Z_IN_DOWN
		set_opacity(FALSE)
	else
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
		add_fingerprint(user)
		do_the_flick()
		set_density(TRUE)
		obj_flags |= BLOCK_Z_IN_DOWN
		sleep(0.4 SECONDS)
		set_opacity(TRUE)
	air_update_turf(TRUE)
	opening = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/structure/falsewall/proc/do_the_flick()
	if(density)
		smooth = NONE
		clear_smooth_overlays()
		flick("fwall_opening", src)
	else
		flick("fwall_closing", src)


/obj/structure/falsewall/update_icon_state()
	if(density)
		icon_state = initial(icon_state)
		smooth = SMOOTH_BITMASK
		queue_smooth(src)
	else
		icon_state = "fwall_open"


/obj/structure/falsewall/proc/ChangeToWall(delete = TRUE)
	var/turf/T = get_turf(src)
	T.ChangeTurf(walltype)
	if(delete)
		qdel(src)
	return T


/obj/structure/falsewall/attackby(obj/item/I, mob/user, params)
	if(opening)
		add_fingerprint(user)
		to_chat(user, span_warning("You have to wait until the door stops moving!"))
		return ATTACK_CHAIN_BLOCKED_ALL

	var/static/list/dismantle_typecache = typecacheof(list(
		/obj/item/gun/energy/plasmacutter,
		/obj/item/pickaxe/drill/diamonddrill,
		/obj/item/pickaxe/drill/jackhammer,
		/obj/item/melee/energy/blade,
		/obj/item/twohanded/required/pyro_claws,
	))
	if(is_type_in_typecache(I, dismantle_typecache))
		dismantle(user, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/falsewall/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!density)
		to_chat(user, span_warning("You can't reach, close it first!"))
		return .
	var/turf/our_turf = get_turf(src)
	if(our_turf?.density)
		to_chat(user, span_warning("The [name] is blocked!"))
		return .
	if(!isfloorturf(our_turf))
		to_chat(user,  span_warning("The [name]'s bolts must be tightened on the floor!"))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	user.visible_message(
		span_notice("[user] tightens some bolts on the wall."),
		span_warning("You tighten the bolts on the wall."),
	)
	ChangeToWall()


/obj/structure/falsewall/welder_act(mob/user, obj/item/I)
	if(!density)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	dismantle(user, TRUE)

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled = TRUE)
	user.visible_message("<span class='notice'>[user] dismantles the false wall.</span>", "<span class='warning'>You dismantle the false wall.</span>")
	playsound(src, 'sound/items/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/falsewall/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/obj/structure/falsewall/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	. = ..()
	if(our_rcd.checkResource(5, user))
		to_chat(user, "Deconstructing wall...")
		playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 4 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
			if(!our_rcd.useResource(5, user))
				return RCD_ACT_FAILED
			playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
			add_attack_logs(user, src, "Deconstructed false wall with RCD")
			qdel(src)
			return RCD_ACT_SUCCESSFULL
		to_chat(user, span_warning("ERROR! Deconstruction interrupted!"))
		return RCD_ACT_FAILED
	to_chat(user, span_warning("ERROR! Not enough matter in unit to deconstruct this wall!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED


// Copy of `/turf/hit_by_thrown_carbon()`. A falsewall is just a wall after all.
/obj/structure/falsewall/hit_by_thrown_carbon(mob/living/carbon/human/C, datum/thrownthing/throwingdatum, damage, mob_hurt, self_hurt)
	if(mob_hurt || !density)
		return
	playsound(src, 'sound/weapons/punch1.ogg', 35, TRUE)
	C.visible_message(	span_danger("[C] slams into [src]!"		),
						span_userdanger("You slam into [src]!"	))
	C.take_organ_damage(damage)
	C.Weaken(0.1 SECONDS)

// Copy of `/atom/proc/hitby()`. Falsewalls must use this `hitby` as do regular walls.
/obj/structure/falsewall/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(density && !AM.has_gravity()) //thrown stuff bounces off dense stuff in no grav, unless the thrown stuff ends up inside what it hit(embedding, bola, etc...).
		addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, hitby_react), AM), 0.2 SECONDS)


/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "r_wall-0"
	base_icon_state = "r_wall"
	walltype = /turf/simulated/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel

/obj/structure/falsewall/reinforced/examine_status(mob/user)
	. = ..()
	. += "<br><span class='notice'>The outer <b>grille</b> is fully intact.</span>"	//not going to fake other states of disassembly

/obj/structure/falsewall/reinforced/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.ChangeTurf(/turf/simulated/wall/r_wall)
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/reinforced/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	if(!our_rcd.canRwall)
		return RCD_NO_ACT
	. = ..()

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-0"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/simulated/wall/mineral/uranium
	var/active = null
	var/last_event = 0
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS

/obj/structure/falsewall/uranium/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/radioactivity, \
				rad_per_interaction = 12, \
				rad_interaction_radius = 3, \
				rad_interaction_cooldown = 1.5 SECONDS \
	)


/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-0"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/simulated/wall/mineral/gold
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-0"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/simulated/wall/mineral/silver
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-0"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/simulated/wall/mineral/diamond
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS
	max_integrity = 800


/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definately a bad idea."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/simulated/wall/mineral/plasma
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS


/obj/structure/falsewall/plasma/attackby(obj/item/I, mob/user, params)
	if(opening)
		return ..()

	if(is_hot(I) > 300)
		add_attack_logs(user, src, "Ignited using [I]", ATKLOG_FEW)
		investigate_log("was <span class='warning'>ignited</span> by [key_name_log(user)]",INVESTIGATE_ATMOS)
		burnbabyburn()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/falsewall/plasma/proc/burnbabyburn(user)
	playsound(src, 'sound/items/welder.ogg', 100, 1)
	atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, 400)
	new /obj/structure/girder/displaced(loc)
	qdel(src)

/obj/structure/falsewall/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		burnbabyburn()

/obj/structure/falsewall/alien
	name = "alien wall"
	desc = "A strange-looking alien wall."
	icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-0"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/simulated/wall/mineral/abductor
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS


/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-0"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/simulated/wall/mineral/bananium
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS

/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating."
	icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-0"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/simulated/wall/mineral/sandstone
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-0"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/wood
	walltype = /turf/simulated/wall/mineral/wood
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS

/obj/structure/falsewall/iron
	name = "rough metal wall"
	desc = "A wall with rough metal plating."
	icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-0"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/simulated/wall/mineral/iron
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-0"
	base_icon_state = "abductor_wall"
	smooth = SMOOTH_BITMASK | SMOOTH_DIAGONAL_CORNERS
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/simulated/wall/mineral/abductor
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS

/obj/structure/falsewall/gingerbread
	name = "gingerbread wall"
	desc = "Don't even try to bite it!"
	icon = 'icons/turf/walls/gingerbread_wall.dmi'
	icon_state = "gingerbread_wall-0"
	base_icon_state = "gingerbread_wall"
	mineral = /obj/item/stack/sheet/gingerbread
	mineral_amount = 5
	walltype = /turf/simulated/wall/mineral/gingerbread
	canSmoothWith = SMOOTH_GROUP_WALL_GINGERBREAD
	smoothing_groups = SMOOTH_GROUP_WALL_GINGERBREAD

/obj/structure/falsewall/titanium
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle/shuttle_wall.dmi'
	icon_state = "shuttle"
	base_icon_state = "shuttle"
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/simulated/wall/mineral/titanium
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_TITANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS

/obj/structure/falsewall/plastitanium
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/simulated/wall/mineral/plastitanium
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_PLASTITANIUM_WALLS
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS

/obj/structure/falsewall/brass
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	base_icon_state = "clockwork_wall"
	icon_state = "clockwork_wall-0"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mineral_amount = 1
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_CLOCKWORK_WALLS
	smoothing_groups = SMOOTH_GROUP_CLOCKWORK_WALLS
	girder_type = /obj/structure/clockwork/wall_gear/displaced
	walltype = /turf/simulated/wall/clockwork
	mineral = /obj/item/stack/sheet/brass

/obj/structure/falsewall/brass/fake
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within. You feel a wind."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall-0"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mineral_amount = 1
	canSmoothWith = SMOOTH_GROUP_CLOCKWORK_WALLS
	smoothing_groups = SMOOTH_GROUP_CLOCKWORK_WALLS
	girder_type = /obj/structure/clockwork/wall_gear/fake/displaced
	walltype = /turf/simulated/wall/clockwork/fake
	mineral = /obj/item/stack/sheet/brass_fake

/obj/structure/falsewall/brass/Initialize(mapload)
	. = ..()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/ratvar/wall/false(T)
	new /obj/effect/temp_visual/ratvar/beam/falsewall(T)

/obj/structure/falsewall/clockwork/attack_hand(mob/user)
	if(!isclocker(user))
		user.changeNext_move(CLICK_CD_MELEE)
		to_chat(user, "<span class='notice'>You push the wall but nothing happens!</span>")
		playsound(src, 'sound/weapons/genhit.ogg', 25, 1) //sneaky
		return FALSE
	return ..()

/obj/structure/falsewall/clockwork/fake/attack_hand(mob/user)
	return ..()

/obj/structure/falsewall/clockwork/welder_act(mob/user, obj/item/I)
	if(!density)
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 120, volume = I.tool_volume)) // 20% more than double normal wall.
		dismantle(user, TRUE)


/obj/structure/falsewall/clockwork/screwdriver_act(mob/living/user, obj/item/I)
	return FALSE	// wall change is unavailable, idk why


/obj/structure/falsewall/mineral_ancient
	name = "ancient rock"
	desc = "A rare asteroid rock that appears to be resistant to all mining tools except pickaxes!"
	icon = 'icons/turf/smoothrocks.dmi'
	base_icon_state = "smoothrocks"
	icon_state = "rock_ancient"
	color = COLOR_ANCIENT_ROCK
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_MINERAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MINERAL_WALLS
	mineral = /obj/item/stack/ore/glass/basalt/ancient
	walltype = /turf/simulated/mineral/ancient
