/// The max range we can zoom in on people from.
#define MAX_LIONHUNTER_RANGE 30
#define LIONHUNTER_TURN_SPEED 150

/obj/item/gun/projectile/shotgun/boltaction/lionhunter
	name = "lionhunter's rifle"
	desc = "Старинное ружье, выглядящее безупречно, несмотря на то, что оно явно очень старое."
	gender = FEMALE
	icon = 'icons/obj/weapons/wide_guns.dmi'
	icon_state = "lionhunter"
	item_state = "lionhunter"
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/lionhunter
	fire_sound = 'sound/weapons/gunshots/shot.ogg'
	accuracy = GUN_ACCURACY_SNIPER
	recoil = GUN_RECOIL_HIGH
	zoomable = TRUE
	zoom_amt = 10


/obj/item/gun/projectile/shotgun/boltaction/lionhunter/get_ru_names()
	return alist(
		NOMINATIVE = "винтовка охотника на львов",
		GENITIVE = "винтовки охотника на львов",
		DATIVE = "винтовке охотника на львов",
		ACCUSATIVE = "винтовку охотника на львов",
		INSTRUMENTAL = "винтовкой охотника на львов",
		PREPOSITIONAL = "винтовке охотника на львов",
	)


/obj/item/gun/projectile/shotgun/boltaction/lionhunter/Initialize(mapload)
	. = ..()
	bolt_open = TRUE
	pump()


/obj/item/gun/projectile/shotgun/boltaction/lionhunter/update_icon_state()
	icon_state = initial(icon_state)


/obj/item/gun/projectile/shotgun/boltaction/lionhunter/update_overlays()
	. = ..()
	. += "[initial(icon_state)][bolt_open ? "_bolt_locked" : "_bolt"]"


/obj/item/gun/projectile/shotgun/boltaction/lionhunter/pump(mob/M)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/obj/item/ammo_box/magazine/internal/lionhunter
	name = "lionhunter's rifle internal mag"
	gun_name = "винтовки охотника на львов"
	ammo_type = /obj/item/ammo_casing/lionhunter
	caliber = CALIBER_DOT_310
	max_ammo = 3


/obj/item/ammo_casing/lionhunter
	projectile_type = /obj/projectile/bullet/lionhunter
	ammo_marking = ".310"
	caliber = CALIBER_DOT_310
	/// Whether we're currently aiming this casing at something
	var/currently_aiming = FALSE
	/// How many seconds it takes to aim per tile of distance between the target
	var/seconds_per_distance = 0.2 SECONDS
	/// The minimum distance required to gain a damage bonus from aiming
	var/min_distance = 4


/obj/item/ammo_casing/lionhunter/fire(atom/target, mob/living/user, list/modifiers, distro, quiet, zone_override = "", spread, atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	if(!check_fire(target, user))
		return

	return ..()


/// Checks if we can successfully fire our projectile.
/obj/item/ammo_casing/lionhunter/proc/check_fire(atom/target, mob/living/user)
	if(!iscarbon(user) || !istype(loc, /obj/item/gun/projectile/shotgun/boltaction/lionhunter))
		return TRUE

	if(currently_aiming)
		user.balloon_alert(user, "уже целится!")
		return FALSE

	var/distance = get_dist(user, target)
	if(target.z != user.z || distance > MAX_LIONHUNTER_RANGE)
		return FALSE

	var/fire_time = min(distance * seconds_per_distance, 10 SECONDS)

	if(distance <= min_distance || !isliving(target))
		return TRUE

	user.balloon_alert(user, "прицеливание...")
	user.playsound_local(get_turf(user), 'sound/weapons/chunkyrack.ogg', 100, TRUE)

	var/image/reticle = image(
		icon = 'icons/mob/actions/actions_items.dmi',
		icon_state = "sniper_zoom",
		layer = ABOVE_MOB_LAYER,
		loc = target,
	)
	reticle.alpha = 0

	var/list/mob/viewers = viewers(target)
	viewers |= user // the shooter might be out of view, but they should be included

	for(var/mob/viewer as anything in viewers)
		viewer.client?.images |= reticle

	animate(reticle, fire_time * 0.5, alpha = 255, transform = turn(reticle.transform, 180))
	animate(reticle, fire_time * 0.5, transform = turn(reticle.transform, 180))

	currently_aiming = TRUE
	. = do_after(user, fire_time, target, DEFAULT_DOAFTER_IGNORE | DA_IGNORE_TARGET_LOC_CHANGE, extra_checks = CALLBACK(src, PROC_REF(check_fire_callback), target, user))
	currently_aiming = FALSE

	animate(reticle, 0.5 SECONDS, alpha = 0)
	for(var/mob/viewer as anything in viewers)
		viewer.client?.images -= reticle

	if(!.)
		user.balloon_alert(user, "прервано!")

	return .


/// Callback for the do_after within the check_fire proc to see if something will prevent us from firing while aiming
/obj/item/ammo_casing/lionhunter/proc/check_fire_callback(mob/living/target, mob/living/user)
	if(!isturf(target.loc))
		return FALSE

	return TRUE


/obj/item/ammo_casing/lionhunter/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	if(!BB)
		return

	var/distance = get_dist(user, target)
	if(distance > min_distance && isliving(target) && iscarbon(user))
		BB.stamina *= 2
		BB.knockdown = 0.5 SECONDS
		BB.stutter = 6 SECONDS
		BB.homing_turn_speed = LIONHUNTER_TURN_SPEED
		BB.set_homing_target(target)

	return ..()


/obj/projectile/bullet/lionhunter
	name = "hunter .310 bullet"
	damage = 30
	stamina = 30
	forcedodge = 3
	///The mob that is currently inside the bullet
	var/mob/stored_mob

/obj/projectile/bullet/lionhunter/get_ru_names()
	return alist(
		NOMINATIVE = "охотничья пуля",
		GENITIVE = "охотничьей пули",
		DATIVE = "охотничьей пуле",
		ACCUSATIVE = "охотничью пулю",
		INSTRUMENTAL = "охотничьей пулей",
		PREPOSITIONAL = "охотничьей пуле",
	)

/obj/projectile/bullet/lionhunter/fire(setAngle)
	. = ..()
	if(QDELETED(src) || !isliving(firer) || !isliving(original))
		return

	var/mob/living/living_firer = firer
	if(!IS_HERETIC(living_firer))
		return

	living_firer.forceMove(src)
	stored_mob = living_firer

	var/obj/item/gun/projectile/gun = firer_source_atom
	if(istype(gun))
		gun.zoom(living_firer, FALSE)
		gun.azoom?.Remove(living_firer)


/obj/projectile/bullet/lionhunter/Exited(atom/movable/gone)
	if(gone == stored_mob)
		stored_mob = null

	return ..()


/obj/projectile/bullet/lionhunter/on_range()
	stored_mob?.forceMove(get_turf(src))
	return ..()


/obj/projectile/bullet/lionhunter/on_hit(atom/target, blocked, pierce_hit)
	stored_mob?.forceMove(get_turf(src))
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/victim = target
	var/mob/firing_mob = firer
	if(IS_HERETIC_OR_MONSTER(victim) || !IS_HERETIC(firing_mob))
		return

	SEND_SIGNAL(firer, COMSIG_LIONHUNTER_ON_HIT, victim)
	return


/obj/projectile/bullet/lionhunter/Destroy()
	if(!stored_mob)
		return ..()

	stored_mob.forceMove(get_turf(src))
	return ..()


/obj/item/ammo_box/speedloader/lionhunter
	name = "ammo box .310 hunter"
	desc = "Обойма с загадочными патронами. Она не подходит к обычным баллистическим винтовкам."
	gender = FEMALE
	caliber = CALIBER_DOT_310
	icon_state = "310_strip"
	gun_name = "винтовки охотника на львов"
	ammo_type = /obj/item/ammo_casing/lionhunter
	max_ammo = 3


/obj/effect/temp_visual/bullet_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2


#undef MAX_LIONHUNTER_RANGE
#undef LIONHUNTER_TURN_SPEED
