/// Scout and assassin who can appear and disappear from glass surfaces. Damaged by being examined.
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror
	name = "Горничная в Зеркале"
	ru_names = list(
		NOMINATIVE = "Горничная в Зеркале",
		GENITIVE = "Горничную в Зеркале",
		DATIVE = "Горничной в Зеркале",
		ACCUSATIVE = "Горничную в Зеркале",
		INSTRUMENTAL = "Горничной в Зеркале",
		PREPOSITIONAL = "Горничной в Зеркале",
	)
	real_name = "Горничная в Зеркале"
	desc = "Плавающий, струящийся поток холодного воздуха. При постороннем взгляде, начинает слегка мерцать."
	gender = FEMALE
	icon = 'icons/mob/mob.dmi'
	icon_state = "stand"
	icon_living = "stand" // Placeholder sprite... still
	speak_emote = list("шепчет")
	movement_type = FLOATING
	status_flags = CANSTUN | CANPUSH
	attack_sound = 'sound/effects/glassbr1.ogg'
	maxHealth = 80
	health = 80
	melee_damage_lower = 12
	melee_damage_upper = 16
	sight = SEE_MOBS | SEE_OBJS | SEE_TURFS
	deathmessage = "разбивается на тысячи осколков и рассеивается, выпуская порыв холодного воздуха."
	/// Whether we take damage when someone looks at us
	var/harmed_by_examine = TRUE
	/// How often being examined by a specific mob can hurt us
	var/recent_examine_damage_cooldown = 10 SECONDS
	/// A list of REFs to people who recently examined us
	var/list/recent_examiner_refs = list()


/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/Initialize(mapload)
	. = ..()
	var/static/list/loot = list(
		/obj/effect/decal/cleanable/ash,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/organ/internal/lungs,
		/obj/item/shard,
	)
	AddElement(/datum/element/death_drops, loot)
	mind.AddSpell(new /obj/effect/proc_holder/spell/jaunt/mirror_walk)


/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/death(gibbed)
	var/turf/simulated/death_turf = get_turf(src)
	death_turf.air.temperature = (death_turf.air.temperature - 40)
	death_turf.air_update_turf()
	return ..()


// Examining them will harm them, on a cooldown.
/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/examine(mob/user)
	. = ..()
	if(!harmed_by_examine || user == src || user.stat == DEAD || !isliving(user) || IS_HERETIC_OR_MONSTER(user))
		return

	var/user_ref = UID()
	if(user_ref in recent_examiner_refs)
		return

	// If we have health, we take some damage
	if(health > (maxHealth * 0.125))
		visible_message(
				span_warning("[declent_ru(NOMINATIVE)] едва заметно мерцает."),
				span_userdanger("Взгляд пронзает все твое существо!"),
		)

		recent_examiner_refs += user_ref
		apply_damage(maxHealth * 0.1) // We take 10% of our health as damage upon being examined
		playsound(src, 'sound/effects/ghost2.ogg', 40, TRUE)
		addtimer(CALLBACK(src, PROC_REF(clear_recent_examiner), user_ref), recent_examine_damage_cooldown, TIMER_DELETE_ME)
		animate(src, alpha = 120, time = 0.5 SECONDS, easing = ELASTIC_EASING, loop = 2, flags = ANIMATION_PARALLEL)
		animate(alpha = 255, time = 0.5 SECONDS, easing = ELASTIC_EASING)
		return

	// If we're examined on low enough health we die straight up
	visible_message(
			span_danger("[declent_ru(NOMINATIVE)] рассеивается"),
			span_userdanger("Чужой взгляд полностью разрушает вас!"),
	)
	death()


/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/proc/clear_recent_examiner(mob_ref)
	if(!(mob_ref in recent_examiner_refs))
		return

	recent_examiner_refs -= mob_ref
	heal_overall_damage(5)


/mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror/AttackingTarget()
	attack_sound = pick(
		'sound/effects/glassbr1.ogg',
		'sound/effects/glassbr2.ogg',
		'sound/effects/glassbr3.ogg',
	)
	. = ..()
