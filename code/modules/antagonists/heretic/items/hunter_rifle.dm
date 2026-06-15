/// The max range we can zoom in on people from.
#define MAX_LIONHUNTER_RANGE 30

// The Lionhunter, a gun for heretics
// The ammo it uses takes time to "charge" before firing, releasing a very damaging projectile.
// Matching TG it is a BOLT-ACTION rifle: you have to rack the bolt between shots (open/close the bolt
// via the unique action / unloading), and reloads are done with a stripper clip while the bolt is open.
/obj/item/gun/projectile/shotgun/boltaction/lionhunter
	name = "винтовка охотника на львов"
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
	// wide_guns.dmi has no "lionhunter_reload" state, so skip the pump reload animation (the bolt-open sprite
	// swap itself IS supported — see update_icon_state below).
	available_reload_animation = FALSE
	// Paradise-native scope: instead of TG's /datum/component/scope, use the built-in zoom action that
	// every /obj/item/gun supports. Holding the rifle grants a "Масштаб" toggle that pans the view forward.
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
	// Chamber the first round so the rifle spawns ready to fire; the heretic still has to rack the bolt
	// after every shot to load the next round.
	bolt_open = TRUE
	pump()


// wide_guns.dmi ships the tg-style bolt sprites: "lionhunter" (bolt closed), "lionhunter_bolt" (bolt open with
// rounds still in the mag) and "lionhunter_bolt_locked" (bolt locked open on an empty mag). The base boltaction
// builds a "[icon_state]-open" suffix that doesn't exist for this gun, so map to the real states here.
/obj/item/gun/projectile/shotgun/boltaction/lionhunter/update_icon_state()
	if(!bolt_open)
		icon_state = initial(icon_state)
		return
	icon_state = "[initial(icon_state)][get_ammo(countchambered = FALSE, countempties = FALSE) ? "_bolt" : "_bolt_locked"]"


// Bolt-action internal magazine for the lionhunter. No caliber set, so ammo suitability falls back to an
// exact ammo-type match (only lionhunter .310 rounds fit), matching how the crafted stripper clip loads.
/obj/item/ammo_box/magazine/internal/lionhunter
	name = "внутренний магазин винтовки охотника на львов"
	gun_name = "винтовки охотника на львов"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	caliber = null
	max_ammo = 3


/obj/item/ammo_casing/strilka310/lionhunter
	projectile_type = /obj/projectile/bullet/strilka310/lionhunter
	/// Whether we're currently aiming this casing at something
	var/currently_aiming = FALSE
	/// How many seconds it takes to aim per tile of distance between the target
	var/seconds_per_distance = 0.2 SECONDS
	/// The minimum distance required to gain a damage bonus from aiming
	var/min_distance = 4


// Signature MUST match the base /obj/item/ammo_casing/fire() exactly: gun.dm fires via NAMED args
// (chambered.fire(modifiers = ..., damage_mod = ..., stamina_mod = ...)). Renaming/omitting params
// (the old override used `params` and dropped damage_mod/stamina_mod) breaks named-arg binding at
// runtime -> the casing never fires -> "the rifle doesn't shoot".
/obj/item/ammo_casing/strilka310/lionhunter/fire(atom/target, mob/living/user, list/modifiers, distro, quiet, zone_override = "", spread, atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	if(!check_fire(target, user))
		return

	return ..()


/// Checks if we can successfully fire our projectile.
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire(atom/target, mob/living/user)
	// In case someone puts this in turrets or something wacky, just fire like normal
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
	// The shooter might be out of view, but they should be included
	viewers |= user

	for(var/mob/viewer as anything in viewers)
		viewer.client?.images |= reticle

	// Animate the fade in
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
/obj/item/ammo_casing/strilka310/lionhunter/proc/check_fire_callback(mob/living/target, mob/living/user)
	if(!isturf(target.loc))
		return FALSE

	return TRUE


/obj/item/ammo_casing/strilka310/lionhunter/ready_proj(atom/target, mob/living/user, quiet, zone_override = "", atom/firer_source_atom, damage_mod = 1, stamina_mod = 1)
	if(!BB)
		return

	var/distance = get_dist(user, target)
	// If we're close range, or the target's not a living, OR for some reason a non-carbon is firing the gun
	// The projectile is dry-fired, and gains no buffs.
	// BUT, if we're at a decent range and the target's a living mob, the projectile's been channel fired:
	// it has full effects and carries the heretic to whoever it strikes.
	if(distance > min_distance && isliving(target) && iscarbon(user))
		BB.stamina *= 2
		BB.knockdown = 0.5 SECONDS
		BB.stutter = 6 SECONDS

	return ..()


/obj/projectile/bullet/strilka310/lionhunter
	name = "пуля охотника калибра .310"
	// These stats are only applied if the weapon is fired fully aimed
	// If fired without aiming or at someone too close, it will do much less
	damage = 30
	stamina = 30
	forcedodge = 3
	///The mob that is currently inside the bullet
	var/mob/stored_mob


// Base /obj/projectile/fire() only takes setAngle; the heretic firer rides inside the bullet so they are
// carried to wherever it lands (see on_hit/on_range), which is what produces the "teleport to your target"
// effect. Only happens when shooting a living target (matching TG).
/obj/projectile/bullet/strilka310/lionhunter/fire(setAngle)
	. = ..()
	if(QDELETED(src) || !isliving(firer) || !isliving(original))
		return

	var/mob/living/living_firer = firer
	if(!isheretic(living_firer))
		return

	living_firer.forceMove(src)
	stored_mob = living_firer

	// Drop out of the scope when we launch ourselves down-range.
	var/obj/item/gun/projectile/gun = firer_source_atom
	if(istype(gun))
		gun.zoom(living_firer, FALSE)
		gun.azoom?.Remove(living_firer)


/obj/projectile/bullet/strilka310/lionhunter/Exited(atom/movable/gone)
	if(gone == stored_mob)
		stored_mob = null

	return ..()


/obj/projectile/bullet/strilka310/lionhunter/on_range()
	stored_mob?.forceMove(get_turf(src))
	return ..()


/obj/projectile/bullet/strilka310/lionhunter/on_hit(atom/target, blocked, pierce_hit)
	// Deposit the heretic onto the turf they struck: they teleport to their victim on a hit.
	stored_mob?.forceMove(get_turf(src))
	. = ..()
	if(!isliving(target))
		return

	var/mob/living/victim = target
	var/mob/firing_mob = firer
	if(IS_HERETIC_OR_MONSTER(victim) || !isheretic(firing_mob))
		return

	// Applies the heretic's currently-equipped mark to the victim (same path Mansus Grasp uses).
	SEND_SIGNAL(firer, COMSIG_LIONHUNTER_ON_HIT, victim)
	return


/obj/projectile/bullet/strilka310/lionhunter/Destroy()
	if(!stored_mob)
		return ..()

	stored_mob.forceMove(get_turf(src))
	return ..()


// Extra ammunition can be made with a heretic ritual. A stripper clip, loaded into the rifle's internal
// magazine while the bolt is open (matching TG's reload flow).
/obj/item/ammo_box/speedloader/strilka310/lionhunter
	name = "обойма (.310 охотник)"
	desc = "Обойма с загадочными, необычными патронами. Она не подходит к обычным баллистическим винтовкам."
	gender = FEMALE
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "310_strip"
	gun_name = "винтовки охотника на львов"
	ammo_type = /obj/item/ammo_casing/strilka310/lionhunter
	max_ammo = 3


/obj/item/ammo_box/speedloader/strilka310/lionhunter/get_ru_names()
	return alist(
		NOMINATIVE = "обойма (.310 охотник)",
		GENITIVE = "обоймы (.310 охотник)",
		DATIVE = "обойме (.310 охотник)",
		ACCUSATIVE = "обойму (.310 охотник)",
		INSTRUMENTAL = "обоймой (.310 охотник)",
		PREPOSITIONAL = "обойме (.310 охотник)",
	)


/obj/effect/temp_visual/bullet_target
	icon = 'icons/mob/actions/actions_items.dmi'
	icon_state = "sniper_zoom"
	layer = BELOW_MOB_LAYER
	light_range = 2


#undef MAX_LIONHUNTER_RANGE
