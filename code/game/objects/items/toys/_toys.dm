/* Toys!
 *	The main toy file, the toys themselves are divided into categories:
 *		Action figures
 *		Balloons
 *		Misc
 *		Plushies
 *		Weapons
 *	If you add a toy, place it in a separate file for this purpose; toys without a category are stored in this file.
 */

/obj/item/toy
	abstract_type = /obj/item/toy
	icon = 'icons/obj/toy.dmi'
	throw_speed = 4
	throw_range = 20
	var/unique_toy_rename = FALSE

/obj/item/toy/examine(mob/user)
	. = ..()
	if(unique_toy_rename)
		. += span_notice("Используй ручку на игрушке, чтобы переименовать её.")

/obj/item/toy/attackby(obj/item/I, mob/user, params)
	if(unique_toy_rename && is_pen(I))
		add_fingerprint(user)
		var/new_name = rename_interactive(user, I, use_prefix = FALSE)
		if(!isnull(new_name))
			to_chat(user, span_notice("Вы называете игрушку '[name]'. Поздоровайся со своим новым другом."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "singularity_s1"
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/toy/nuke
	name = "Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/animation_stage = 0

/obj/item/toy/nuke/update_icon_state()
	switch(animation_stage)
		if(1)
			icon_state = "nuketoy"
		if(2)
			icon_state = "nuketoycool"
		else
			icon_state = initial(icon_state)

/obj/item/toy/nuke/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = world.time + 3 MINUTES
		user.visible_message(span_warning("[user] нажима[PLUR_ET_YUT(user)] кнопку на [declent_ru(GENITIVE)]"), span_notice("Вы активируете [declent_ru(NOMINATIVE)], раздаётся громкий звук!"), span_notice("Слышишь щелчок кнопки."))
		INVOKE_ASYNC(src, PROC_REF(async_animation))
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "[span_alert("Ничего не происходит, и число '")][round(timeleft/10)][span_alert("' появляется на маленьком дисплее.")]")

/obj/item/toy/nuke/proc/async_animation()
	animation_stage++
	update_icon(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/alarm.ogg', 100, FALSE, 0)
	sleep(13 SECONDS)
	animation_stage++
	update_icon(UPDATE_ICON_STATE)
	sleep(cooldown - world.time)
	animation_stage = 0
	update_icon(UPDATE_ICON_STATE)

/obj/item/inflatable_duck
	name = "inflatable duck"
	desc = "No bother to sink or swim when you can just float!"
	icon_state = "inflatable"
	item_state = "inflatable"
	icon = 'icons/obj/clothing/belts.dmi'
	slot_flags = ITEM_SLOT_BELT

/*
 * Fake meteor
 */
/obj/item/toy/minimeteor
	name = "Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	playsound(src, 'sound/effects/meteorimpact.ogg', 40, TRUE)
	for(var/mob/M in range(10, src))
		if(!M.stat && !isAI(M))\
			shake_camera(M, 3, 1)
	qdel(src)

/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		to_chat(user, span_notice("Вы нажимаете кнопку на [declent_ru(GENITIVE)]."))
		playsound(user, 'sound/machines/click.ogg', 20, TRUE)
		user.visible_message(span_danger("[get_examine_icon(viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/*
 * Pet Rocks
 */
/obj/item/toy/pet_rock
	name = "pet rock"
	desc = "The perfect pet!"
	icon_state = "pet_rock"
	w_class = WEIGHT_CLASS_SMALL
	force = 5
	throwforce = 5
	attack_verb = list("атаковал", "ударил", "окаменил")
	hitsound = SFX_SWING_HIT

/obj/item/toy/pet_rock/fred
	name = "fred"
	desc = "Fred, the bestest boy pet in the whole wide universe!"
	icon_state = "fred"

/obj/item/toy/pet_rock/roxie
	name = "roxie"
	desc = "Roxie, the bestest girl pet in the whole wide universe!"
	icon_state = "roxie"

/obj/item/toy/pet_rock/naughty_coal
	name = "Naughty coal"
	desc = "You've been very bad this year! And the only thing you deserve as a gift is this piece of coal!"
	icon = 'icons/obj/items.dmi'
	icon_state = "naughty_coal"
	resistance_flags = FLAMMABLE
