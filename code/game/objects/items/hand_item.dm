/obj/item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	icon_state = "latexballon"
	item_state = "nothing"
	force = 0
	throwforce = 0
	item_flags = DROPDEL|ABSTRACT
	attack_verb = list("slapped")
	hitsound = 'sound/weapons/slap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3


/obj/item/slapper/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	user.do_attack_animation(target)
	playsound(target, hitsound, 50, TRUE, -1)
	user.visible_message(
		span_danger("[user] slaps [target]!"),
		span_notice("You slap [target]!"),
		span_italics("You hear a slap."),
	)
	if(iscarbon(target) && target.IsSleeping())
		target.AdjustSleeping(-15 SECONDS)
	if(!force)
		return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()


/obj/item/slapper/attack_self(mob/living/user)
	. = ..()
	if(!isliving(user))
		return
	user.emote("highfive", intentional = TRUE)


/obj/item/slapper/attack_obj(obj/object, mob/living/user, params)
	if(!istype(object, /obj/structure/table))
		return ..()

	. = ATTACK_CHAIN_PROCEED_SUCCESS
	var/obj/structure/table/the_table = object

	if(user.a_intent == INTENT_HARM && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		. = ATTACK_CHAIN_BLOCKED
		transform = transform.Scale(1.5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			if(istype(human_user.shoes, /obj/item/clothing/shoes/cowboy))
				human_user.say(pick("Вот чёрт!", "Чёрт подери!", "Чёрт возьми!"))

		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 120, TRUE)
		user.visible_message(
			span_danger("<b>[user] slams [user.p_their()] fist down on [the_table]!</b>"),
			span_danger("<b>You slam your fist down on [the_table]!</b>"),
		)
		qdel(src)
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message(
			span_notice("[user] slaps [user.p_their()] hand on [the_table]."),
			span_notice("You slap your hand on [the_table]."),
		)
		table_smacks_left--
		if(table_smacks_left <= 0)
			. = ATTACK_CHAIN_BLOCKED
			qdel(src)


/obj/item/slapper/get_clamped_volume() //Without this, you would hear the slap twice if it has force.
	return 0


/*
/obj/item/slapper/parry
	desc = "This is how real men win fights."
	force = 5
	attack_verb = list("slapped", "backhanded", "smacked", "discombobulated")
	table_smacks_left = 10 //Much more smackitude

/obj/item/slapper/parry/Initialize(mapload)
	AddComponent(/datum/component/parry, _stamina_constant = 2, _stamina_coefficient = 0.5, _parryable_attack_types = NON_PROJECTILE_ATTACKS, _parry_cooldown = (1 / 3) SECONDS) //75% uptime
	return ..()

/obj/item/slapper/parry/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(isliving(target))
		SEND_SOUND(creature, sound('sound/weapons/flash_ring.ogg'))
		creature.Confused(10 SECONDS) //SMACK CAM
		creature.EyeBlind(2 SECONDS) //OH GOD MY EARS ARE RINGING
		creature.Deaf(4 SECONDS) //OH MY HEAD
	return ..()
*/
