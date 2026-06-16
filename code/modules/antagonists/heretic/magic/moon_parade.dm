/obj/effect/proc_holder/spell/pointed/projectile/moon_parade
	name = "Лунный парад"
	desc = "Оно жаждет парада, заставляя всех, кто окажется на пути, \
			присоединиться к нему и страдать от галлюцинаций."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "moon_parade"
	ranged_mousepointer = 'icons/effects/mouse_pointers/moon_target.dmi'

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "Л'НН'Й П'Р'Д!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Вы готовитесь заставить их присоединиться к параду!"
	deactive_msg = "Вы останавливаете музыку и прекращаете парад... на время."
	cast_range = 12
	projectile_type = /obj/projectile/moon_parade


/obj/projectile/moon_parade
	name = "Лунный парад"
	icon_state = "lunar_parade"
	damage = 0
	damage_type = BURN
	// Slow, deliberate drift - the parade "shield" should crawl along so the crowd can march after it,
	// not zip across the screen. (Paradise's projectile speed is "deciseconds per move", so higher = slower;
	// a default bullet is 0.5, this is a leisurely 2.)
	speed = 2
	range = 75
	// flag is BULLET by default, which lets it ricochet off normal walls (RICOCHET_BALLISTIC).
	ricochets_max = 40
	ricochet_chance = 500
	///looping sound datum for our projectile.
	var/datum/looping_sound/moon_parade/soundloop

/obj/projectile/moon_parade/Initialize(mapload)
	. = ..()
	soundloop = new(src, TRUE)

/// TG pierces mobs/vehicles via projectile_piercing. Paradise has no such var - instead a projectile
/// passes through whatever it hits when bullet_act()/on_hit() returns -1 (see shooting_range.dm). So we
/// hit each living mob, then return -1 to keep flying (and keep ricocheting off walls) so the whole crowd
/// gets dragged into the parade, exactly like on TG.
/obj/projectile/moon_parade/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	if(!isliving(target))
		return .

	var/mob/living/victim = target

	// The caster and their own minions/summons are never caught - just phase straight through them.
	if(victim == firer || is_parade_ally(victim))
		return -1

	// Anti-magic shrugs the parade off and pops the projectile - counterplay, matches TG.
	if(victim.can_block_magic(MAGIC_RESISTANCE | MAGIC_RESISTANCE_MIND))
		visible_message(span_warning("Парад врезается в [victim.declent_ru(ACCUSATIVE)], и внезапная волна ясности накрывает [genderize_ru(victim.gender, "его", "её", "его", "их")]!"))
		return // returns a non -1 value, so Bump() deletes the projectile and the parade stops

	// Already marching - just refresh the madness, don't re-leash.
	if(victim.has_status_effect(/datum/status_effect/moon_parade))
		victim.cause_hallucination(/datum/hallucination/delusion/preset/moon, name)
		return -1

	// Leash the victim to the parade PROJECTILE itself (the "shield"), passing src as the anchor. Both
	// players and basic mobs then trail after the shield as it drifts and ricochets - NOT after the caster,
	// which is how it works on TG. The status effect owns the leash, the 20s timer and the cleanup.
	victim.apply_status_effect(/datum/status_effect/moon_parade, src)
	victim.cause_hallucination(/datum/hallucination/delusion/preset/moon, name)
	victim.Hallucinate(60 SECONDS)
	return -1 // keep flying so everyone in its path joins the parade


/// Returns TRUE if the victim is on the heretic's side (a summon/minion or a lunatic thrall) and so
/// should be ignored by the parade instead of being made to march.
/obj/projectile/moon_parade/proc/is_parade_ally(mob/living/victim)
	if(!isliving(firer))
		return FALSE
	var/mob/living/caster = firer
	if(!caster.mind || !victim.mind)
		return FALSE

	var/datum/antagonist/heretic_monster/monster = victim.mind.has_antag_datum(/datum/antagonist/heretic_monster)
	if(monster?.master == caster.mind)
		return TRUE

	var/datum/antagonist/lunatic/lunatic = victim.mind.has_antag_datum(/datum/antagonist/lunatic)
	if(lunatic?.ascended_heretic == caster.mind)
		return TRUE

	return FALSE


/obj/projectile/moon_parade/Destroy()
	// Each victim's /datum/status_effect/moon_parade watches us for COMSIG_QDELETING and frees itself
	// (dropping its leash), so destroying the projectile releases the whole parade automatically.
	QDEL_NULL(soundloop)
	return ..()


/// Status effect that transfixes a victim to the parade projectile: it leashes them to the "shield" so they
/// trail after it, blocks their own movement to sell the illusion, and releases them after 20s or 50 damage.
/// Faithful port of TG's /datum/status_effect/moon_parade.
/datum/status_effect/moon_parade
	id = "moon_parade"
	alert_type = /atom/movable/screen/alert/status_effect/moon_parade
	duration = 20 SECONDS
	tick_interval = -1
	/// The component that leashes us to the parade.
	var/datum/component/leash/leash_component
	/// What atom we are leashed to (the parade projectile / "shield").
	var/atom/leashed_to
	/// How much damage we must take before the leash breaks and we're freed.
	var/damage_release_threshold = 50
	/// How much damage we have received so far.
	var/damage_received = 0


/datum/status_effect/moon_parade/on_creation(mob/living/new_owner, atom/leashed_by)
	leashed_to = leashed_by
	return ..()


/datum/status_effect/moon_parade/on_apply()
	if(!istype(leashed_to))
		return FALSE
	owner.balloon_alert(owner, "вас тянет за парадом!")
	leash_component = owner.AddComponent(/datum/component/leash, leashed_to, distance = 1)
	RegisterSignal(leashed_to, COMSIG_QDELETING, PROC_REF(delete_self))
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(block_move))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage_received))
	return TRUE


/datum/status_effect/moon_parade/on_remove()
	QDEL_NULL(leash_component)
	UnregisterSignal(owner, list(COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, COMSIG_MOB_APPLY_DAMAGE))
	if(leashed_to)
		UnregisterSignal(leashed_to, COMSIG_QDELETING)
	return ..()


/datum/status_effect/moon_parade/proc/delete_self(datum/source)
	SIGNAL_HANDLER
	qdel(src)


/datum/status_effect/moon_parade/proc/on_damage_received(datum/source, damage_amount, damagetype)
	SIGNAL_HANDLER
	if(damagetype == STAMINA)
		return
	damage_received += damage_amount
	if(damage_received >= damage_release_threshold)
		owner.balloon_alert(owner, "вы свободны!")
		qdel(src)


// Blocks the victim's own movement so they appear transfixed, wandering after the parade. Coded this way
// because it's a simple way to hold the illusion compared to other methods. (Only affects player-controlled
// mobs; basic/AI mobs are dragged along by the leash itself.)
/datum/status_effect/moon_parade/proc/block_move(datum/source)
	SIGNAL_HANDLER
	return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE


/atom/movable/screen/alert/status_effect/moon_parade
	name = "Лунный парад"
	desc = "Вы не в силах оторваться от парада и обязаны следовать за ним!"
	icon = 'icons/mob/actions/actions_ecult.dmi'
	icon_state = "moon_parade"


/// The marching-band music that follows the parade projectile. (Paradise has no sound tokens, so omitted.)
/datum/looping_sound/moon_parade
	mid_sounds = list('sound/effects/moon_parade_soundloop.ogg' = 1)
	mid_length = 2 SECONDS
	volume = 20
