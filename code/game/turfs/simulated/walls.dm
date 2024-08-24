#define WALL_DENT_HIT 1
#define WALL_DENT_SHOT 2
#define MAX_DENT_DECALS 15

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	plane = WALL_PLANE
	var/rotting = 0

	var/damage = 0
	var/damage_cap = 100 //Wall will break down to girders if damage reaches this point

	var/damage_overlay
	var/global/damage_overlays[8]

	var/max_temperature = 1800 //K, walls will take damage if they're next to a fire hotter than this

	opacity = TRUE
	density = TRUE
	blocks_air = TRUE
	init_air = FALSE
	explosion_block = 1
	explosion_vertical_block = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/melting = FALSE //TRUE if wall is currently being melted with thermite

	var/can_dismantle_with_welder = TRUE
	var/hardness = 40 //lower numbers are harder. Used to determine the probability of a hulk smashing through.
	var/slicing_duration = 100
	var/engraving //engraving on the wall
	var/engraving_quality
	var/list/dent_decals
	var/sheet_type = /obj/item/stack/sheet/metal
	var/sheet_amount = 2
	var/girder_type = /obj/structure/girder

	smoothing_groups = SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_WALLS
	smooth = SMOOTH_BITMASK

/turf/simulated/wall/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	return FALSE

/turf/simulated/wall/BeforeChange()
	for(var/obj/effect/overlay/wall_rot/WR in src)
		qdel(WR)
	. = ..()

/turf/simulated/wall/Initialize(mapload)
	. = ..()
	if(smooth & SMOOTH_DIAGONAL_CORNERS && fixed_underlay) //Set underlays for the diagonal walls.
		var/mutable_appearance/underlay_appearance = mutable_appearance(layer = TURF_LAYER, offset_spokesman = src, plane = FLOOR_PLANE)
		if(fixed_underlay["space"])
			generate_space_underlay(underlay_appearance, src)
		else
			underlay_appearance.icon = fixed_underlay["icon"]
			underlay_appearance.icon_state = fixed_underlay["icon_state"]
		fixed_underlay = string_assoc_list(fixed_underlay)
		underlays += underlay_appearance

//Appearance
/turf/simulated/wall/examine(mob/user) // If you change this, consider changing the examine_status proc of false walls to match
	. = ..()

	if(!damage)
		. += span_notice("It looks fully intact.")
	else
		var/dam = damage / damage_cap
		if(dam <= 0.3)
			. += span_warning("It looks slightly damaged.")
		else if(dam <= 0.6)
			. += span_warning("It looks moderately damaged.")
		else
			. += span_danger("It looks heavily damaged.")

	if(rotting)
		. += span_warning("There is fungus growing on [src].")


/turf/simulated/wall/update_overlays()
	. = ..()
	if(!damage_overlays[1]) //list hasn't been populated
		generate_overlays()

	queue_smooth(src)
	if(!damage)
		return

	var/overlay = round(damage / damage_cap * length(damage_overlays)) + 1
	if(overlay > length(damage_overlays))
		overlay = length(damage_overlays)

	if(damage_overlay && overlay == damage_overlay) //No need to update.
		return

	. += damage_overlays[overlay]


/turf/simulated/wall/proc/generate_overlays()
	var/alpha_inc = 256 / damage_overlays.len

	for(var/i = 1; i <= damage_overlays.len; i++)
		var/image/img = image(icon = 'icons/turf/walls.dmi', icon_state = "overlay_damage")
		img.blend_mode = BLEND_MULTIPLY
		img.alpha = (i * alpha_inc) - 1
		damage_overlays[i] = img

//Damage

/turf/simulated/wall/proc/take_damage(dam)
	if(dam)
		damage = max(0, damage + dam)
		update_damage()
	return

/turf/simulated/wall/proc/update_damage()
	var/cap = damage_cap
	if(rotting)
		cap = cap / 10

	if(damage >= cap)
		dismantle_wall()
	else
		update_icon()

	return

/turf/simulated/wall/proc/adjacent_fire_act(turf/simulated/wall, radiated_temperature)
	if(radiated_temperature > max_temperature)
		take_damage(rand(10, 20) * (radiated_temperature / max_temperature))

/turf/simulated/wall/handle_ricochet(obj/item/projectile/P)			//A huge pile of shitcode!
	var/turf/p_turf = get_turf(P)
	var/face_direction = get_dir(src, p_turf)
	var/face_angle = dir2angle(face_direction)
	var/incidence_s = GET_ANGLE_OF_INCIDENCE(face_angle, (P.Angle + 180))
	if(abs(incidence_s) > 90 && abs(incidence_s) < 270)
		return FALSE
	var/new_angle_s = SIMPLIFY_DEGREES(face_angle + incidence_s)
	P.set_angle(new_angle_s)
	return TRUE

/turf/simulated/wall/dismantle_wall(devastated = FALSE, explode = FALSE)
	if(devastated)
		devastate_wall()
	else
		playsound(src, 'sound/items/welder.ogg', 100, 1)
		var/newgirder = break_wall()
		if(newgirder) //maybe we don't /want/ a girder!
			transfer_fingerprints_to(newgirder)

	ChangeTurf(/turf/simulated/floor/plating)
	return TRUE

/turf/simulated/wall/proc/break_wall()
	new sheet_type(src, sheet_amount)
	return new girder_type(src)

/turf/simulated/wall/proc/devastate_wall()
	new sheet_type(src, sheet_amount)
	new /obj/item/stack/sheet/metal(src)

/turf/simulated/wall/ex_act(severity)
	switch(severity)
		if(1.0)
			ChangeTurf(baseturf)
			return
		if(2.0)
			if(prob(50))
				take_damage(rand(150, 250))
			else
				dismantle_wall(1, 1)
		if(3.0)
			take_damage(rand(0, 250))
		else
	return

/turf/simulated/wall/blob_act(obj/structure/blob/B)
	if(prob(50))
		dismantle_wall()
	else
		add_dent(WALL_DENT_HIT)

/turf/simulated/wall/rpd_act(mob/user, obj/item/rpd/our_rpd)
	if(our_rpd.mode == RPD_ATMOS_MODE)
		if(!our_rpd.ranged)
			playsound(src, "sound/weapons/circsawhit.ogg", 50, 1)
			user.visible_message(span_notice("[user] starts drilling a hole in [src]..."), span_notice("You start drilling a hole in [src]..."), span_italics("You hear drilling."))
			if(!do_after(user, our_rpd.walldelay, src)) //Drilling into walls takes time
				return
		our_rpd.create_atmos_pipe(user, src)
	else if(our_rpd.mode == RPD_DISPOSALS_MODE && !our_rpd.ranged)
		return
	else
		..()

/turf/simulated/wall/rcd_deconstruct_act(mob/user, obj/item/rcd/our_rcd)
	. = ..()
	if(our_rcd.checkResource(5, user))
		to_chat(user, "Deconstructing wall...")
		playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
		if(do_after(user, 4 SECONDS * our_rcd.toolspeed, src, category = DA_CAT_TOOL))
			if(!our_rcd.useResource(5, user))
				return RCD_ACT_FAILED
			playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
			add_attack_logs(user, src, "Deconstructed wall with RCD")
			src.ChangeTurf(our_rcd.floor_type)
			return RCD_ACT_SUCCESSFULL
		to_chat(user, span_warning("ERROR! Deconstruction interrupted!"))
		return RCD_ACT_FAILED
	to_chat(user, span_warning("ERROR! Not enough matter in unit to deconstruct this wall!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/turf/simulated/wall/mech_melee_attack(obj/mecha/M)
	M.do_attack_animation(src)
	switch(M.damtype)
		if(BRUTE)
			playsound(src, 'sound/weapons/punch4.ogg', 50, TRUE)
			M.visible_message(span_danger("[M.name] hits [src]!"), span_danger("You hit [src]!"))
			if(prob(hardness + M.force) && M.force > 20)
				dismantle_wall(1)
				playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			else
				add_dent(WALL_DENT_HIT)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		if(TOX)
			playsound(src, 'sound/effects/spray2.ogg', 100, TRUE)
			return FALSE

// Wall-rot effect, a nasty fungus that destroys walls.
/turf/simulated/wall/proc/rot()
	if(!rotting)
		rotting = 1

		var/number_rots = rand(2,3)
		for(var/i=0, i<number_rots, i++)
			new /obj/effect/overlay/wall_rot(src)

/turf/simulated/wall/burn_down()
	if(istype(sheet_type, /obj/item/stack/sheet/mineral/diamond))
		return
	return ChangeTurf(/turf/simulated/floor/plating)


#define THERMITE_PER_SECOND 2.5
#define DAMAGE_PER_SECOND 60

/**
 * Melts down wall into its base turf.
 *
 * Arguments:
 * * user - who used thermite, optional argument used to show message.
 * * time - optional override; thermite reagent will not be used for melting, only passed time matters.
 */
/turf/simulated/wall/proc/thermitemelt(mob/user, time)
	set waitfor = FALSE

	if(melting)
		return
	if(istype(sheet_type, /obj/item/stack/sheet/mineral/diamond))
		return

	var/obj/effect/overlay/visuals = new(src)
	visuals.name = "Thermite"
	visuals.desc = "Looks hot."
	visuals.icon = 'icons/effects/fire.dmi'
	visuals.icon_state = "2"
	visuals.set_anchored(TRUE)
	visuals.set_density(TRUE)
	visuals.layer = FLY_LAYER

	if(user)
		to_chat(user, span_warning("The thermite starts melting through [src]."))

	if(time)
		melting = TRUE
		var/sound_timer = 10
		while(time > 0)
			if(QDELETED(src))
				return
			sound_timer++
			if(sound_timer >= 10)
				sound_timer = 0
				playsound(src, 'sound/items/welder.ogg', 100, TRUE)
			time = max(0, time - 0.1 SECONDS)
			sleep(0.1 SECONDS)
		if(QDELETED(src))
			return
		var/turf/simulated/floor/plating/our_floor = burn_down()
		our_floor.burn_tile()
		our_floor.cut_overlay(melting_olay)
		if(visuals)
			qdel(visuals)
		return

	melting = TRUE

	while(reagents.get_reagent_amount("thermite") > 0)
		if(QDELETED(src))
			return
		reagents.remove_reagent("thermite", THERMITE_PER_SECOND)
		if(damage_cap - damage <= DAMAGE_PER_SECOND)
			var/turf/simulated/floor/plating/our_floor = burn_down()
			our_floor.burn_tile()
			break
		take_damage(DAMAGE_PER_SECOND)
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
		sleep(1 SECONDS)

	if(QDELETED(src))
		return

	if(iswallturf(src))
		melting = FALSE

	cut_overlay(melting_olay)
	if(visuals)
		qdel(visuals)

#undef THERMITE_PER_SECOND
#undef DAMAGE_PER_SECOND


//Interactions

/turf/simulated/wall/attack_animal(mob/living/simple_animal/M)
	M.changeNext_move(CLICK_CD_MELEE)
	M.do_attack_animation(src)
	if((M.environment_smash & ENVIRONMENT_SMASH_WALLS) || (M.environment_smash & ENVIRONMENT_SMASH_RWALLS))
		if(M.environment_smash & ENVIRONMENT_SMASH_RWALLS)
			dismantle_wall(1)
			to_chat(M, span_info("You smash through the wall."))
		else
			to_chat(M, span_notice("You smash against the wall."))
			take_damage(rand(25, 75))
			return

	to_chat(M, span_notice("You push the wall but nothing happens!"))
	return

/turf/simulated/wall/attack_hand(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)

	if(isalien(user))
		var/mob/living/carbon/alien/A = user
		A.do_attack_animation(src)

		if(A.environment_smash & ENVIRONMENT_SMASH_RWALLS)
			dismantle_wall(1)
			to_chat(A, span_info("You smash through the wall."))
			return
		if(A.environment_smash & ENVIRONMENT_SMASH_WALLS)
			to_chat(A, span_notice("You smash against the wall."))
			take_damage(A.obj_damage)
			return

		to_chat(A, span_notice("You push the wall but nothing happens!"))
		return
	if(rotting)
		if(hardness <= 10)
			to_chat(user, span_notice("This wall feels rather unstable."))
			return
		else
			to_chat(user, span_notice("The wall crumbles under your touch."))
			dismantle_wall()
			return

	to_chat(user, span_notice("You push the wall but nothing happens!"))
	playsound(src, 'sound/weapons/genhit.ogg', 25, 1)
	add_fingerprint(user)
	return ..()


/turf/simulated/wall/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !isturf(user.loc))
		return .

	if(rotting && try_rot(I, user, params))
		user.changeNext_move(I.attack_speed)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(try_decon(I, user, params))
		user.changeNext_move(I.attack_speed)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(try_destroy(I, user, params))
		user.changeNext_move(I.attack_speed)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(try_wallmount(I, user, params))
		user.changeNext_move(I.attack_speed)
		return .|ATTACK_CHAIN_BLOCKED_ALL

	if(try_reform(I, user, params))
		user.changeNext_move(I.attack_speed)
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/wall/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(reagents?.get_reagent_amount("thermite") && I.use_tool(src, user, volume = I.tool_volume))
		thermitemelt(user)
		return
	if(rotting)
		if(I.use_tool(src, user, volume = I.tool_volume))
			for(var/obj/effect/overlay/wall_rot/WR in src)
				qdel(WR)
			rotting = FALSE
			to_chat(user, span_notice("You burn off the fungi with [I]."))
		return

	if(!I.tool_use_check(user, 0)) //Wall repair stuff
		return

	var/time_required = slicing_duration
	var/intention
	if(can_dismantle_with_welder)
		intention = "Dismantle"
	if(damage || LAZYLEN(dent_decals))
		intention = "Repair"
		if(can_dismantle_with_welder)
			var/moved_away = user.loc
			intention = alert(user, "Would you like to repair or dismantle [src]?", "[src]", "Repair", "Dismantle")
			if(user.loc != moved_away)
				to_chat(user, span_notice("Stay still while doing this!"))
				return
			if(intention == "Repair")
				time_required = max(5, damage / 5)
	if(!intention)
		return
	if(intention == "Dismantle")
		WELDER_ATTEMPT_SLICING_MESSAGE
	else
		WELDER_ATTEMPT_REPAIR_MESSAGE
	if(I.use_tool(src, user, time_required, volume = I.tool_volume))
		if(intention == "Dismantle")
			WELDER_SLICING_SUCCESS_MESSAGE
			dismantle_wall()
		else
			WELDER_REPAIR_SUCCESS_MESSAGE
			cut_overlay(dent_decals)
			dent_decals?.Cut()
			take_damage(-damage)

/turf/simulated/wall/proc/try_rot(obj/item/I, mob/user, params)
	if((!is_sharp(I) && I.force >= 10) || I.force >= 20)
		to_chat(user, span_notice("[src] crumbles away under the force of your [I.name]."))
		dismantle_wall(1)
		return TRUE
	return FALSE

/turf/simulated/wall/proc/try_decon(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/gun/energy/plasmacutter))
		to_chat(user, span_notice("You begin slicing through the outer plating."))
		playsound(src, I.usesound, 100, 1)

		var/delay = istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) ? 12 SECONDS : 6 SECONDS
		if(do_after(user, delay * I.toolspeed, src, category = DA_CAT_TOOL))
			to_chat(user, span_notice("You remove the outer plating."))
			dismantle_wall()
			visible_message(span_warning("[user] slices apart [src]!"), span_warning("You hear metal being sliced apart."))
			return TRUE

	return FALSE

/turf/simulated/wall/proc/try_destroy(obj/item/I, mob/user, params)
	var/isdiamond = istype(sheet_type, /obj/item/stack/sheet/mineral/diamond) // snowflake bullshit

	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		to_chat(user, span_notice("You begin to drill though the wall."))

		var/delay = isdiamond ? 48 SECONDS : 24 SECONDS
		if(do_after(user, delay * I.toolspeed, src, category = DA_CAT_TOOL)) // Diamond pickaxe has 0.25 toolspeed, so 12s./6s.
			to_chat(user, span_notice("Your [I.name] tears though the last of the reinforced plating."))
			dismantle_wall()
			visible_message(span_warning("[user] drills through [src]!"), span_italics("You hear the grinding of metal."))
			return TRUE

	else if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		to_chat(user, span_notice("You begin to disintegrates the wall."))
		var/obj/item/pickaxe/drill/jackhammer/jh = I
		var/delay = isdiamond ? 60 SECONDS : 30 SECONDS
		if(do_after(user, delay * jh.wall_toolspeed, src, category = DA_CAT_TOOL)) // Jackhammer has 0.1 toolspeed, so 6s./3s.
			to_chat(user, span_notice("Your [I.name] disintegrates the reinforced plating."))
			dismantle_wall()
			visible_message(span_warning("[user] disintegrates [src]!"),span_warning("You hear the grinding of metal."))
			return TRUE

	else if(istype(I, /obj/item/twohanded/required/pyro_claws))
		to_chat(user, span_notice("You begin to melt the wall."))
		var/delay = isdiamond ? 6 SECONDS : 3 SECONDS
		if(do_after(user, delay * I.toolspeed, src, category = DA_CAT_TOOL)) // claws has 0.5 toolspeed, so 3/1.5 seconds
			to_chat(user, span_notice("Your [I.name] melts the reinforced plating."))
			dismantle_wall()
			visible_message(span_warning("[user] melts [src]!"),span_italics("You hear the hissing of steam."))
			return TRUE

	return FALSE

/turf/simulated/wall/proc/try_wallmount(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/mounted))
		return FALSE	// afterattack will handle this

	if(istype(I, /obj/item/poster))
		place_poster(I, user)
		return TRUE

	//Bone White - Place pipes on walls // I fucking hate your code with a passion bone
	if(istype(I, /obj/item/pipe))
		var/obj/item/pipe/P = I
		if(P.pipe_type != -1) // ANY PIPE
			playsound(get_turf(src), 'sound/weapons/circsawhit.ogg', 50, 1)
			user.visible_message(
				span_notice("[user] starts drilling a hole in [src]."),
				span_notice("You start drilling a hole in [src]."),
				span_italics("You hear a drill."))

			if(do_after(user, 8 SECONDS * P.toolspeed, src, category = DA_CAT_TOOL))
				user.visible_message(
					span_notice("[user] drills a hole in [src] and pushes [P] into the void."),
					span_notice("You finish drilling [src] and push [P] into the void."),
					span_italics("You hear a ratchet."))

				user.drop_from_active_hand()
				if(P.is_bent_pipe())  // bent pipe rotation fix see construction.dm
					P.setDir(5)
					if(user.dir == 1)
						P.setDir(6)
					else if(user.dir == 2)
						P.setDir(9)
					else if(user.dir == 4)
						P.setDir(10)
				else
					P.setDir(user.dir)
				P.forceMove(src)
				P.level = 2
		return TRUE
	return FALSE

/turf/simulated/wall/proc/try_reform(obj/item/I, mob/user, params)
	if(I.enchant_type == REFORM_SPELL && (src.type == /turf/simulated/wall)) //fuck
		I.deplete_spell()
		ChangeTurf(/turf/simulated/floor/plating)
		new /obj/structure/falsewall/clockwork(src) //special falsewalls
		playsound(src, 'sound/magic/cult_spell.ogg', 100, 1)
		return TRUE
	return FALSE

/turf/simulated/wall/singularity_pull(S, current_size)
	..()
	wall_singularity_pull(current_size)

/turf/simulated/wall/proc/wall_singularity_pull(current_size)
	if(current_size >= STAGE_FIVE)
		if(prob(50))
			dismantle_wall()
		return
	if(current_size == STAGE_FOUR)
		if(prob(30))
			dismantle_wall()

/turf/simulated/wall/narsie_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/wall/cult)

/turf/simulated/wall/ratvar_act()
	if(prob(20))
		ChangeTurf(/turf/simulated/wall/clockwork)


/turf/simulated/wall/acid_act(acidpwr, acid_volume)
	if(explosion_block >= 2)
		acidpwr = min(acidpwr, 50) //we reduce the power so strong walls never get melted.
	. = ..()

/turf/simulated/wall/acid_melt()
	dismantle_wall(1)

/turf/simulated/wall/proc/add_dent(denttype, x=rand(-8, 8), y=rand(-8, 8))
	if(LAZYLEN(dent_decals) >= MAX_DENT_DECALS)
		return

	var/mutable_appearance/decal = mutable_appearance('icons/effects/effects.dmi', "", BULLET_HOLE_LAYER)
	switch(denttype)
		if(WALL_DENT_SHOT)
			decal.icon_state = "bullet_hole"
		if(WALL_DENT_HIT)
			decal.icon_state = "impact[rand(1, 3)]"

	decal.pixel_x = x
	decal.pixel_y = y

	if(LAZYLEN(dent_decals))
		cut_overlay(dent_decals)
		dent_decals += decal
	else
		dent_decals = list(decal)

	add_overlay(dent_decals)

#undef MAX_DENT_DECALS
