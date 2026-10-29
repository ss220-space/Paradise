/datum/status_effect/revenant_hallucinations
	id = "rev_hallucinations"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/cursed_hallucinations
	var/mob/living/simple_animal/revenant/inflicter
//	COOLDOWN_DECLARE(fireball_cooldown)

/datum/status_effect/revenant_hallucinations/New(list/arguments)
	. = ..()
	inflicter = arguments[1]
	if(!istype(inflicter))
		inflicter = null

/datum/status_effect/revenant_hallucinations/tick(seconds_between_ticks)
//.	if(COOLDOWN_FINISHED(src, fireball_cooldown))
	fire()
	owner.overlay_fullscreen("revenant", /atom/movable/screen/fullscreen/revenant, (min(owner.getStaminaLoss(), 100)/20)+5) //states 5-10

/datum/status_effect/revenant_hallucinations/Destroy()
	owner.clear_fullscreen("revenant")
	. = ..()

/datum/status_effect/revenant_hallucinations/proc/fire()
	var/turf/fire_turf = pick(get_hollow_turfs_circle(owner, 5))
	var/obj/projectile/to_fire = new /obj/projectile/cursed_fireball
	to_fire.firer = inflicter
	to_fire.current = fire_turf
	to_fire.original = owner
	to_fire.preparePixelProjectile(owner, fire_turf)
	to_fire.fire()
//	COOLDOWN_START(src, fireball_cooldown, 0.1 SECONDS)

/obj/projectile/cursed_fireball
	name = "ghostly fireball"
	icon_state = null
	speed = 3
	damage = 0
	nodamage = TRUE
	stamina = 20
	forcedodge = -1
	ricochets_max = 0
	suppressed = TRUE
	var/image/image
	var/mob/living/mobtarget
	var/image_icon = 'icons/effects/revenant.dmi'
	var/image_icon_state = "ghostlyfireball"

/obj/projectile/cursed_fireball/get_ru_names()
	return alist(
		NOMINATIVE = "снаряд призрачного пламени",
		GENITIVE = "снаряда призрачного пламени",
		DATIVE = "снаряду призрачного пламени",
		ACCUSATIVE = "снаряд призрачного пламени",
		INSTRUMENTAL = "снарядом призрачного пламени",
		PREPOSITIONAL = "снаряде призрачного пламени",
	)

/obj/projectile/cursed_fireball/preparePixelProjectile(atom/target, atom/source, list/modifiers, deviation)
	if(!isliving(original))
		qdel(src)
		return
	image = image(image_icon, src, image_icon_state)
	mobtarget = original
	add_image_to_client(image, mobtarget.client)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 3 SECONDS)
	. = ..()

/obj/projectile/cursed_fireball/Destroy()
	. = ..()
	if(image)
		remove_image_from_client(image, mobtarget.client)
		qdel(image)

/obj/projectile/cursed_fireball/on_hit(atom/target, blocked, hit_zone)
	if(target != original)
		return FALSE
	. = ..()
	if(prob(15))
		mobtarget.apply_status_effect(/datum/status_effect/cursed_flame, 5 SECONDS, firer)
	qdel(src)

/atom/movable/screen/alert/status_effect/cursed_hallucinations
	name = "Призрачные снаряды"
	desc = "Кажется, в вас со всех сторон летят странные огненные шары! Не стоит попадать под их траекторию..."
	icon_state = "cursed_hallucinations"
