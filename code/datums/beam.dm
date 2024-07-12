//Beam Datum and effect
/datum/beam
	var/atom/origin = null
	var/atom/target = null
	var/list/elements = list()
	var/icon/base_icon = null
	var/icon
	var/icon_state = "" //icon state of the main segments of the beam
	var/max_distance = 0
	var/endtime = 0
	var/sleep_time = 3
	var/finished = FALSE
	var/target_oldloc = null
	var/origin_oldloc = null
	var/static_beam = FALSE
	var/beam_type = /obj/effect/ebeam //must be subtype
	///the layer of our beam
	var/beam_layer


/datum/beam/New(
	beam_origin,
	beam_target,
	beam_icon = 'icons/effects/beam.dmi',
	beam_icon_state="b_beam",
	time = 5 SECONDS,
	maxdistance = 10,
	btype = /obj/effect/ebeam,
	beam_sleep_time = 0.3 SECONDS,
	beam_layer = ABOVE_ALL_MOB_LAYER
)
	src.endtime = world.time+time
	src.origin = beam_origin
	src.origin_oldloc =	get_turf(origin)
	src.target = beam_target
	src.target_oldloc = get_turf(target)
	src.sleep_time = beam_sleep_time
	if(origin_oldloc == origin && target_oldloc == target)
		src.static_beam = TRUE
	src.max_distance = maxdistance
	src.base_icon = new(beam_icon, beam_icon_state)
	src.icon = beam_icon
	src.icon_state = beam_icon_state
	src.beam_type = btype
	src.beam_layer = beam_layer


/datum/beam/proc/Start()
	Draw()
	while(!finished && origin && target && world.time < endtime && get_dist(origin,target)<max_distance && origin.z == target.z)
		var/origin_turf = get_turf(origin)
		var/target_turf = get_turf(target)
		if(!static_beam && (origin_turf != origin_oldloc || target_turf != target_oldloc))
			origin_oldloc = origin_turf //so we don't keep checking against their initial positions, leading to endless Reset()+Draw() calls
			target_oldloc = target_turf
			Reset()
			Draw()
		sleep(sleep_time)

	qdel(src)


/datum/beam/proc/End()
	finished = TRUE


/datum/beam/proc/Reset()
	QDEL_LIST(elements)


/datum/beam/Destroy()
	Reset()
	target = null
	origin = null
	return ..()


/datum/beam/proc/Draw()
	var/Angle = round(get_angle(origin, target))

	var/matrix/rot_matrix = matrix()
	rot_matrix.Turn(Angle)

	//Translation vector for origin and target
	var/DX = (32*target.x+target.pixel_x)-(32*origin.x+origin.pixel_x)
	var/DY = (32*target.y+target.pixel_y)-(32*origin.y+origin.pixel_y)
	var/N = 0
	var/length = round(sqrt((DX)**2+(DY)**2)) //hypotenuse of the triangle formed by target and origin's displacement

	for(N in 0 to length-1 step 32)//-1 as we want < not <=, but we want the speed of X in Y to Z and step X
		if(QDELETED(src))
			break
		var/obj/effect/ebeam/X = new beam_type(origin_oldloc, src)
		elements += X

		//Assign icon, for main segments it's base_icon, for the end, it's icon+icon_state
		//cropped by a transparent box of length-N pixel size
		if(N+32>length)
			var/icon/II = new(icon, icon_state)
			II.DrawBox(null,1,(length-N),32,32)
			X.icon = II
		else
			X.icon = base_icon
		X.transform = rot_matrix

		//Calculate pixel offsets (If necessary)
		var/Pixel_x
		var/Pixel_y
		if(DX == 0)
			Pixel_x = 0
		else
			Pixel_x = round(sin(Angle)+32*sin(Angle)*(N+16)/32)
		if(DY == 0)
			Pixel_y = 0
		else
			Pixel_y = round(cos(Angle)+32*cos(Angle)*(N+16)/32)

		//Position the effect so the beam is one continous line
		var/final_x = X.x
		var/final_y = X.y
		if(abs(Pixel_x)>32)
			final_x += Pixel_x > 0 ? round(Pixel_x/32) : CEILING(Pixel_x/32, 1)
			Pixel_x %= 32
		if(abs(Pixel_y)>32)
			final_y += Pixel_y > 0 ? round(Pixel_y/32) : CEILING(Pixel_y/32, 1)
			Pixel_y %= 32

		X.forceMove(locate(final_x, final_y, X.z))
		X.pixel_x = Pixel_x
		X.pixel_y = Pixel_y
		CHECK_TICK


/**
 * This is what you use to start a beam. Example: origin.Beam(target, args). **Store the return of this proc if you don't set maxdist or time, you need it to delete the beam.**
 *
 * Unless you're making a custom beam effect (see the beam_type argument), you won't actually have to mess with any other procs. Make sure you store the return of this Proc, you'll need it
 * to kill the beam.
 * **Arguments:**
 * BeamTarget: Where you're beaming from. Where do you get origin? You didn't read the docs, fuck you.
 * icon_state: What the beam's icon_state is. The datum effect isn't the ebeam object, it doesn't hold any icon and isn't type dependent.
 * icon: What the beam's icon file is. Don't change this, man. All beam icons should be in beam.dmi anyways.
 * maxdistance: how far the beam will go before stopping itself. Used mainly for two things: preventing lag if the beam may go in that direction and setting a range to abilities that use beams.
 * beam_type: The type of your custom beam. This is for adding other wacky stuff for your beam only. Most likely, you won't (and shouldn't) change it.
 */
/atom/proc/Beam(atom/BeamTarget,
	icon_state = "b_beam",
	icon = 'icons/effects/beam.dmi',
	time = 5 SECONDS,
	maxdistance = 10,
	beam_type = /obj/effect/ebeam,
	beam_sleep_time = 0.3 SECONDS,
	beam_layer = ABOVE_ALL_MOB_LAYER
)
	var/datum/beam/newbeam = new(src, BeamTarget, icon, icon_state, time, maxdistance, beam_type, beam_sleep_time, beam_layer)
	INVOKE_ASYNC(newbeam, TYPE_PROC_REF(/datum/beam, Start))
	return newbeam


/obj/effect/ebeam
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	var/datum/beam/owner


/obj/effect/ebeam/Initialize(mapload, beam_owner)
	. = ..()
	owner = beam_owner


/obj/effect/ebeam/Destroy()
	owner = null
	return ..()


/obj/effect/ebeam/ex_act(severity)
	return


/obj/effect/ebeam/singularity_pull()
	return


/obj/effect/ebeam/singularity_act()
	return


// Subtypes

/obj/effect/ebeam/floor
	plane = FLOOR_PLANE


/obj/effect/ebeam/chain
	name = "lightning chain"


/obj/effect/ebeam/medical
	name = "medical beam"


/obj/effect/ebeam/vetus


/obj/effect/ebeam/vetus/Destroy()
	for(var/mob/living/mob in get_turf(src))
		mob.electrocute_act(20, "the giant arc", safety = TRUE)
	return ..()


/obj/effect/ebeam/disintegration_telegraph
	alpha = 100


/// A beam subtype used for advanced beams, to react to atoms entering the beam
/obj/effect/ebeam/reacting
	/// If TRUE, atoms that exist in the beam's loc when inited count as "entering" the beam
	var/react_on_init = FALSE


/obj/effect/ebeam/reacting/Initialize(mapload, beam_owner)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered)
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	if(!isturf(loc) || isnull(owner) || mapload || !react_on_init)
		return

	for(var/atom/movable/existing as anything in loc)
		beam_entered(existing)


/obj/effect/ebeam/reacting/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isnull(owner))
		return

	beam_entered(arrived)


/// Some atom entered the beam's line
/obj/effect/ebeam/reacting/proc/beam_entered(atom/movable/entered)
	return


/obj/effect/ebeam/reacting/deadly


/obj/effect/ebeam/reacting/deadly/beam_entered(atom/movable/entered)
	entered.ex_act(EXPLODE_DEVASTATE)


/obj/effect/ebeam/reacting/disintegration


/obj/effect/ebeam/reacting/disintegration/beam_entered(mob/living/entered)
	if(!isliving(entered))
		return
	var/damage = 50
	if(entered.stat == DEAD)
		visible_message(span_danger("[entered] is disintegrated by the beam!"))
		entered.dust()
	if(isliving(owner.origin))
		var/mob/living/beam_owner = owner.origin
		if(faction_check(beam_owner.faction, entered.faction, FALSE))
			return
		damage = 70 - ((beam_owner.health / beam_owner.maxHealth) * 20)
	playsound(entered,'sound/weapons/sear.ogg', 50, TRUE, -4)
	to_chat(entered, span_userdanger("You're struck by a disintegration laser!"))
	var/limb_to_hit = entered.get_organ(pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_R_ARM, BODY_ZONE_L_ARM, BODY_ZONE_R_LEG, BODY_ZONE_L_LEG))
	var/armor = entered.run_armor_check(limb_to_hit, LASER)
	entered.apply_damage(damage, BURN, limb_to_hit, armor)


/obj/effect/ebeam/reacting/vine
	name = "thick vine"
	mouse_opacity = MOUSE_OPACITY_ICON
	desc = "A thick vine, painful to the touch."


/obj/effect/ebeam/reacting/vine/beam_entered(mob/living/entered)
	if(!isliving(entered) || ("vines" in entered.faction))
		return
	entered.adjustBruteLoss(5)
	to_chat(entered, span_danger("You cut yourself on the thorny vines."))

