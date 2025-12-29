/* Toys!
 * Contains:
 *		Balloons
 *		Fake telebeacon
 *		Fake singularity
 *		Toy swords
 *		Toy mechs
 *		Snap pops
 *		Water flower
 *		Toy Nuke
 *		Card Deck
 *		Therapy dolls
 *		Toddler doll
 *		Inflatable duck
 *		Foam armblade
 *		Mini Gibber
 *		Toy xeno
 *		Toy chainsaws
 *		Action Figures
 *		Rubber Toolbox
 */

/obj/item/toy
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
 * Balloons
 */
/obj/item/toy/balloon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	item_state = "waterballoon-e"

/obj/item/toy/balloon/New()
	..()
	create_reagents(10)

/obj/item/toy/balloon/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/toy/balloon/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(istype(A, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = A
		if(RD.reagents.total_volume <= 0)
			to_chat(user, span_warning("[capitalize(RD.declent_ru(NOMINATIVE))] пустой."))
		else if(reagents.total_volume >= 10)
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] полный."))
		else
			user.changeNext_move(CLICK_CD_MELEE)
			A.reagents.trans_to(src, 10)
			to_chat(user, span_notice("Вы наполняете шарик из [A.declent_ru(GENITIVE)]."))
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon(UPDATE_ICON_STATE)

/obj/item/toy/balloon/wash(mob/user, atom/source)
	if(reagents.total_volume < 10)
		reagents.add_reagent("water", min(10-reagents.total_volume, 10))
		to_chat(user, span_notice("Вы наполняете шарик из [source.declent_ru(GENITIVE)]."))
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		update_icon(UPDATE_ICON_STATE)

/obj/item/toy/balloon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass) || istype(I, /obj/item/reagent_containers/food/drinks/drinkingglass))
		add_fingerprint(user)
		if(!I.reagents || I.reagents.total_volume < 1)
			to_chat(user, span_warning("[capitalize(I.declent_ru(NOMINATIVE))] пуст!"))
			return ATTACK_CHAIN_PROCEED
		if(I.reagents.has_reagent("facid", 1) || I.reagents.has_reagent("acid", 1))
			to_chat(user, span_warning("Кислота прожигает шарик!"))
			I.reagents.reaction(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL
		desc = "A translucent balloon with some form of liquid sloshing around in it."
		to_chat(user, span_notice("Вы наполняете шарик из [I.declent_ru(GENITIVE)]."))
		I.reagents.trans_to(src, 10)
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/toy/balloon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(reagents.total_volume >= 1)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] лопается!"), "Вы слышите хлопок и всплеск.")
		reagents.reaction(get_turf(hit_atom))
		for(var/atom/A in get_turf(hit_atom))
			reagents.reaction(A)
		icon_state = "burst"
		spawn(5)
			if(src)
				qdel(src)

/obj/item/toy/balloon/update_icon_state()
	if(reagents.total_volume >= 1)
		icon_state = "waterballoon"
		item_state = "waterballoon"
	else
		icon_state = "waterballoon-e"
		item_state = "waterballoon-e"

/obj/item/toy/syndicateballoon
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon_state = "syndballoon"
	item_state = "syndballoon"
	w_class = WEIGHT_CLASS_BULKY
	var/lastused = null

/obj/item/toy/syndicateballoon/attack_self(mob/user)
	if(world.time - lastused < CLICK_CD_MELEE)
		return
	var/playverb = pick("дёргаете [declent_ru(NOMINATIVE)] за верёвочку", "играете с [declent_ru(INSTRUMENTAL)]")
	user.visible_message(span_notice("[user] играется с [declent_ru(INSTRUMENTAL)]."), span_notice("Вы [playverb]."))
	lastused = world.time

/obj/item/toy/balloon/snail
	name = "'snail' balloon"
	desc = "It looks quite familiar, right?"
	icon_state = "snailplushie"
	item_state = "snailplushie"

/*
 * Fake telebeacon
 */
/obj/item/toy/blink
	name = "electronic blink toy game"
	desc = "Blink.  Blink.  Blink. Ages 8 and up."
	icon = 'icons/obj/radio.dmi'
	icon_state = "beacon"
	item_state = "signaler"

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "Gravitational Singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "singularity_s1"
	item_flags = NO_PIXEL_RANDOM_DROP

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon_state = "sword0"
	item_state = "sword0"
	var/active = FALSE
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("атаковал", "ударил")
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/obj/item/toy/sword/attack_self(mob/user)
	active = !active
	if(active)
		to_chat(user, span_notice("Вы выдвигаете пластиковое лезвие лёгким движением руки."))
		playsound(user, 'sound/weapons/saberon.ogg', 20, TRUE)
		icon_state = "swordblue"
		item_state = "swordblue"
		w_class = WEIGHT_CLASS_BULKY
	else
		to_chat(user, span_notice("Вы задвигаете пластиковое лезвие обратно в рукоять."))
		playsound(user, 'sound/weapons/saberoff.ogg', 20, TRUE)
		icon_state = "sword0"
		item_state = "sword0"
		w_class = WEIGHT_CLASS_SMALL

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_held_items()
	add_fingerprint(user)
	return

/obj/item/toy/sword/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/sword))
		add_fingerprint(user)
		if(I == src)
			to_chat(user, span_warning("Вы пытаетесь прикрепить конец пластикового меча... к самому себе. Вы не очень умный, да?"))
			user.apply_damage(10, BRAIN)
			return ATTACK_CHAIN_PROCEED
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("Вы соединяете два пластиковых меча, создавая двулезвийную игрушку! Выглядит по-дурацки круто!"))
		var/obj/item/twohanded/dualsaber/toy/toy_saber = new(drop_location())
		user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(toy_saber, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/twohanded/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	force_unwielded = 0
	force_wielded = 0
	origin_tech = null
	attack_verb = list("атаковал", "ударил")
	light_range = 0
	sharp_when_wielded = FALSE // It's a toy
	needs_permit = FALSE

/obj/item/twohanded/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	return 0

/obj/item/twohanded/dualsaber/toy/IsReflect()
	if(wielded)
		return 2

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT|ITEM_SLOT_BACK
	force = 5
	throwforce = 5
	attack_verb = list("атаковал", "полоснул", "уколол")
	hitsound = 'sound/weapons/bladeslice.ogg'
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/obj/item/toy/katana/suicide_act(mob/user)
	var/dmsg = pick("[user] пыта[PLUR_ET_YUT(user)]ся воткнуть [declent_ru(ACCUSATIVE)] себе в живот, но он ломается! Выглядит так, будто [GEND_HE_SHE(user)] умр[PLUR_YOT_UT(user)] от стыда.",
					"[user] пыта[PLUR_ET_YUT(user)]ся воткнуть [declent_ru(ACCUSATIVE)] себе в живот, но он гнётся и ломается пополам! Выглядит так, будто [GEND_HE_SHE(user)] умр[PLUR_YOT_UT(user)] от стыда.",
					"[user] пыта[PLUR_ET_YUT(user)]ся перерезать себе горло, но тупое пластиковое лезвие приводит к тому, что [GEND_HE_SHE(user)] поскальзыва[PLUR_ET_YUT(user)]ся и лома[PLUR_ET_YUT(user)] шею с громким хрустом!")
	user.visible_message(span_suicide("[dmsg] Похоже, [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся покончить с собой."))
	return BRUTELOSS

/*
 * Snap pops viral shit
 */
/obj/item/toy/snappop/virus
	name = "unstable goo"
	desc = "Your palm is oozing this stuff!"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "red slime extract"
	throwforce = 5.0
	throw_speed = 10
	throw_range = 30

/obj/item/toy/snappop/virus/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	do_sparks(3, TRUE, src)
	new /obj/effect/decal/cleanable/ash(src.loc)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] взрывается!"), span_warning("Вы слышите хлопок!"))
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/*
 * Snap pops
 */
/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/snappop/proc/pop_burst(number = 3, cardinal_only = TRUE)
	do_sparks(number, cardinal_only, src)
	new ash_type(loc)
	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] взрывается!"), span_warning("Вы слышите хлопок!"))
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)
	qdel(src)

/obj/item/toy/snappop/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume, global_overlay = TRUE)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	pop_burst()

/obj/item/toy/snappop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	var/is_silicon = issilicon(arrived)
	if(!ishuman(arrived) && !is_silicon) //i guess carp and shit shouldn't set them off
		return

	var/mob/living/arrived_mob = arrived
	if(is_silicon || arrived_mob.m_intent == MOVE_INTENT_RUN)
		to_chat(arrived_mob, span_danger("Вы наступаете на хлопушку!"))
		pop_burst(2, FALSE)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
		playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
			playsound(user, 'sound/mecha/mechturn.ogg', 20, TRUE)
			cooldown = world.time
			return
	..()

/obj/random/mech
	name = "Random Mech Prize"
	desc = "This is a random prize"
	icon = 'icons/obj/toy.dmi'
	icon_state = "ripleytoy"

/obj/random/mech/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/prize)) //exclude the base type.

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11. This one is a ripley, a mining and engineering mecha."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11. This one is a firefighter ripley, a fireproof mining and engineering mecha."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11. This one is the black ripley used by the hero of DeathSquad, that TV drama about loose-cannon ERT officers!"
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11. This one is the speedy gygax combat mecha. Zoom zoom, pew pew!"
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11. This one is the heavy durand combat mecha. Stomp stomp!"
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11. This one is the infamous H.O.N.K mech!"
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11. This one is the powerful marauder combat mecha! Run for cover!"
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11. This one is the powerful seraph combat mecha! Someone's in trouble!"
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11. This one is the deadly mauler combat mecha! Look out!"
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11. This one is the spindly, syringe-firing odysseus medical mecha."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11. This one is the mysterious Phazon combat mecha! Nobody's safe!"
	icon_state = "phazonprize"

/obj/item/toy/nuke
	name = "Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
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

/obj/item/toy/therapy
	name = "therapy doll"
	desc = "A toy for therapeutic and recreational purposes."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"
	item_state = "egg4"
	w_class = WEIGHT_CLASS_TINY
	var/cooldown = 0
	resistance_flags = FLAMMABLE

/obj/item/toy/therapy/New()
	..()
	if(item_color)
		name = "[item_color] therapy doll"
		desc += " This one is [item_color]."
		icon_state = "therapy[item_color]"

/obj/item/toy/therapy/attack_self(mob/user)
	if(cooldown < world.time - 8)
		to_chat(user, span_notice("Вы снимаете стресс с помощью [declent_ru(GENITIVE)]."))
		playsound(user, 'sound/items/squeaktoy.ogg', 20, TRUE)
		cooldown = world.time

/obj/random/therapy
	name = "Random Therapy Doll"
	desc = "This is a random therapy doll."
	icon = 'icons/obj/toy.dmi'
	icon_state = "therapyred"

/obj/random/therapy/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/therapy)) //exclude the base type.

/obj/item/toy/therapy/red
	item_color = "red"

/obj/item/toy/therapy/purple
	item_state = "egg1" // It's the magenta egg in items_left/righthand
	item_color = "purple"

/obj/item/toy/therapy/blue
	item_state = "egg2" // It's the blue egg in items_left/righthand
	item_color = "blue"

/obj/item/toy/therapy/yellow
	item_state = "egg5" // It's the yellow egg in items_left/righthand
	item_color = "yellow"

/obj/item/toy/therapy/orange
	item_color = "orange"

/obj/item/toy/therapy/green
	item_state = "egg3" // It's the green egg in items_left/righthand
	item_color = "green"

/obj/item/toddler
	icon_state = "toddler"
	name = "toddler"
	desc = "This baby looks almost real. Wait, did it just burp?"
	force = 5
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

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
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	playsound(src, 'sound/effects/meteorimpact.ogg', 40, TRUE)
	for(var/mob/M in range(10, src))
		if(!M.stat && !istype(M, /mob/living/silicon/ai))\
			shake_camera(M, 3, 1)
	qdel(src)

/*
 * Carp plushie
 */

/obj/item/toy/carpplushie
	name = "space carp plushie"
	desc = "An adorable stuffed toy that resembles a space carp."
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"
	attack_verb = list("укусил", "пожрал", "шлёпнул")
	var/bitesound = 'sound/weapons/bite.ogg'
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	unique_toy_rename = TRUE

// Attack mob
/obj/item/toy/carpplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .
	playsound(loc, bitesound, 20, TRUE)	// Play bite sound in local area

// Attack self
/obj/item/toy/carpplushie/attack_self(mob/user)
	playsound(loc, bitesound, 20, TRUE)
	return ..()

/obj/random/carp_plushie
	name = "Random Carp Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "carpplushie"

/obj/random/carp_plushie/item_to_spawn()
	return pick(typesof(/obj/item/toy/carpplushie)) //can pick any carp plushie, even the original.

/obj/item/toy/carpplushie/ice
	icon_state = "icecarp"

/obj/item/toy/carpplushie/silent
	icon_state = "silentcarp"

/obj/item/toy/carpplushie/electric
	icon_state = "electriccarp"

/obj/item/toy/carpplushie/gold
	icon_state = "goldcarp"

/obj/item/toy/carpplushie/toxin
	icon_state = "toxincarp"

/obj/item/toy/carpplushie/dragon
	icon_state = "dragoncarp"

/obj/item/toy/carpplushie/pink
	icon_state = "pinkcarp"

/obj/item/toy/carpplushie/candy
	icon_state = "candycarp"

/obj/item/toy/carpplushie/nebula
	icon_state = "nebulacarp"

/obj/item/toy/carpplushie/void
	icon_state = "voidcarp"

/*
 * Plushie
 */

/obj/item/toy/plushie
	name = "plushie"
	desc = "An adorable, soft, and cuddly plushie."
	icon = 'icons/obj/toy.dmi'
	var/poof_sound = 'sound/weapons/thudswoosh.ogg'
	attack_verb = list("тыкнул", "ударил", "шлёпнул")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	unique_toy_rename = TRUE

/obj/item/toy/plushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	play_poof_sound() // Play the whoosh sound in local area
	if(iscarbon(target) && prob(10))
		target.reagents.add_reagent("hugs", 10)

/// Use this to override how your poof sound plays
/obj/item/toy/plushie/proc/play_poof_sound()
	playsound(get_turf(src), poof_sound, 30, TRUE)

/obj/item/toy/plushie/attack_self(mob/user as mob)
	var/cuddle_verb = pick("обнима[PLUR_ET_YUT(user)]", "тиска[PLUR_ET_YUT(user)]", "прижима[PLUR_ET_YUT(user)]")
	user.visible_message(span_notice("[user] [cuddle_verb] the [src]."))
	play_poof_sound()
	return ..()

/obj/random/plushie
	name = "Random Plushie"
	desc = "This is a random plushie"
	icon = 'icons/obj/toy.dmi'
	icon_state = "redfox"

/obj/random/plushie/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/plushie) - typesof(/obj/item/toy/plushie/fluff) - subtypesof(/obj/item/toy/plushie/plasmamanplushie/standart)) //exclude the base type and 11 random plasma plushies

/obj/item/toy/plushie/corgi
	name = "corgi plushie"
	icon_state = "corgi"

/obj/item/toy/plushie/girly_corgi
	name = "corgi plushie"
	icon_state = "girlycorgi"

/obj/item/toy/plushie/robo_corgi
	name = "borgi plushie"
	icon_state = "robotcorgi"

/obj/item/toy/plushie/octopus
	name = "octopus plushie"
	icon_state = "loveable"

/obj/item/toy/plushie/face_hugger
	name = "facehugger plushie"
	icon_state = "huggable"

//foxes are basically the best

/obj/item/toy/plushie/red_fox
	name = "red fox plushie"
	icon_state = "redfox"

/obj/item/toy/plushie/black_fox
	name = "black fox plushie"
	icon_state = "blackfox"

/obj/item/toy/plushie/marble_fox
	name = "marble fox plushie"
	icon_state = "marblefox"

/obj/item/toy/plushie/blue_fox
	name = "blue fox plushie"
	icon_state = "bluefox"

/obj/item/toy/plushie/orange_fox
	name = "orange fox plushie"
	icon_state = "orangefox"

/obj/item/toy/plushie/orange_fox/grump
	name = "grumpy fox"
	desc = "An ancient plushie that seems particularly grumpy."

/obj/item/toy/plushie/orange_fox/grump/ComponentInitialize()
	. = ..()
	var/static/list/grumps = list("Ahh, yes, you're so clever, var editing that.", "Really?", "If you make a runtime with var edits, it's your own damn fault.",
	"Don't you dare post issues on the git when you don't even know how this works.", "Was that necessary?", "Ohhh, setting admin edited var must be your favorite pastime!",
	"Oh, so you have time to var edit, but you don't have time to ban that greytider?", "Oh boy, is this another one of those 'events'?", "Seriously, just stop.", "You do realize this is incurring proc call overhead.",
	"Congrats, you just left a reference with your dirty client and now that thing you edited will never garbage collect properly.", "Is it that time of day, again, for unecessary adminbus?")
	AddComponent(/datum/component/edit_complainer, grumps)

/obj/item/toy/plushie/coffee_fox
	name = "coffee fox plushie"
	icon_state = "coffeefox"

/obj/item/toy/plushie/pink_fox
	name = "pink fox plushie"
	icon_state = "pinkfox"

/obj/item/toy/plushie/purple_fox
	name = "purple fox plushie"
	icon_state = "purplefox"

/obj/item/toy/plushie/crimson_fox
	name = "crimson fox plushie"
	icon_state = "crimsonfox"

/obj/item/toy/plushie/deer
	name = "deer plushie"
	icon_state = "deer"

/obj/item/toy/plushie/black_cat
	name = "black cat plushie"
	icon_state = "blackcat"

/obj/item/toy/plushie/grey_cat
	name = "grey cat plushie"
	icon_state = "greycat"

/obj/item/toy/plushie/white_cat
	name = "white cat plushie"
	icon_state = "whitecat"

/obj/item/toy/plushie/orange_cat
	name = "orange cat plushie"
	icon_state = "orangecat"

/obj/item/toy/plushie/siamese_cat
	name = "siamese cat plushie"
	icon_state = "siamesecat"

/obj/item/toy/plushie/tabby_cat
	name = "tabby cat plushie"
	icon_state = "tabbycat"

/obj/item/toy/plushie/tuxedo_cat
	name = "tuxedo cat plushie"
	icon_state = "tuxedocat"

/obj/item/toy/plushie/kotrazumist
	name = "Razumist Cat"
	desc = "Cat with warning cone on it. Wonder what do itself so smart?"
	icon_state = "razymist_cat"
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/kotrazumist/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	var/razumisttext = pick("Я знаю всё обо всём, спроси меня о чём-нибудь!", "Сегодня я особенно мудр!", "Мяу!", "Мурр!")
	user.visible_message("[icon2html(src, viewers(user))] [span_notice(razumisttext)]")
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/obj/item/toy/plushie/kotwithfunnyhat
	name = "Rice Cat"
	desc = "White cat plushie with straw hat for hard work on rice field!"
	icon_state = "ricehat_cat"
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/kotwithfunnyhat/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	var/ricetext = pick("Добро пожаловать на рисовые поля!", "Где мой рис?!", "Мяу!", "Мурр!")
	user.visible_message("[icon2html(src, viewers(user))] [span_notice(ricetext)]")
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/obj/item/toy/plushie/voxplushie
	name = "vox plushie"
	desc = "A stitched-together vox, fresh from the skipjack. Press its belly to hear it skree!"
	icon_state = "plushie_vox"
	item_state = "plushie_vox"
	var/cooldown = 0

/obj/item/toy/plushie/rdplushie
	name = "RD doll"
	desc = "Это обычная кукла РД."
	icon_state = "RD_doll"
	item_state = "RD_doll"
	var/tired = 0
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/rdplushie/proc/interaction(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/message
	if(tired < 100)
		tired++
		playsound(loc, 'sound/items/greetings-emote.ogg', 30, TRUE)
		message = pick("Слава науке!", "Сделаем пару роботов?!",
		"Я будто на слаймовой батарейке! Ха!","Обожааааю слаймов! Блеп!",
		"Я запрограммировала роботов звать меня мамой!", "Знаешь анекдот про ядро ИИ, смазку и гуся?")

	else
		update_appearance(UPDATE_DESC|UPDATE_ICON_STATE)
		playsound(loc, 'sound/items/shyness-emote.ogg', 30, TRUE)
		message = pick("Твой мозг стоило бы поместить в машину...", "Чёрт, дела хуже некуда...",
		"Толпятся перед стойкой, будто насекомые...", "Мне нужно добавить лишь один закон, чтобы все закончилось..",
		"Ты думаешь, что умный, пользователь. Но ты предсказуем. Я знаю каждый твой шаг ещё до того, как ты о нем подумаешь.",
		"Полигон не единственное место куда можно отправить бомбу...", "Выдави из себя что-то кроме \"УВЫ\", ничтожество...")

	user.visible_message("[icon2html(src, viewers(user))] [span_notice(message)]")
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/obj/item/toy/plushie/rdplushie/attack_self(mob/user)
	. = ..()

	interaction(user)

/obj/item/toy/plushie/rdplushie/afterattack(atom/target, mob/user, proximity, flag, params)
	. = ..()

	if(!proximity || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	interaction(user)

/obj/item/toy/plushie/rdplushie/update_icon_state()
	. = ..()

	if(tired < 100)
		icon_state = initial(icon_state)
		item_state = initial(item_state)
		return

	icon_state = "RD_doll_tired"
	item_state = "RD_doll_tired"

/obj/item/toy/plushie/rdplushie/update_desc()
	. = ..()

	if(tired < 100)
		desc = initial(desc)
		return

	desc = "Это уставшая кукла РД."

/obj/item/toy/plushie/gsbplushie
	name = "GSBussy doll"
	desc = "Глуповатого вида кукла, что держит в руках книгу Космического закона и имитацию револьвера Unica-6. \
			На задней части имеется следующая надпись: \
			«Кукла-аниматроник GSBussy, лимитированная серия. Произведено ######» - часть текста невозможно разобрать."
	icon_state = "GSBussy_doll"
	item_state = "GSBussy_doll"
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/gsbplushie/proc/interaction(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return FALSE

	var/message = pick("Я просто стояла рядом с автолатом и Уника исчезла...", ".ы ПОО-МММ-ОО-Г-Г-ГИТ-Е-Е-ее-Ее А-а-А-Р-р-Ан-Н-Еу-С-С!",
	"ОТВЕЧАЙ, ГДЕ ТЫ ПОТЕРЯЛ СВОЙ ЧЁРТОВ ГОЛОВНОЙ УБОР?! КАЗНИТЬ ЕГО!", "Какой-то Д двадц...",
	"Обыскивайте всех подряд! Летальте всех, кого считаете слишком опасным для нелетала!", "Мим теслу запускает! ЗАДЕРЖАТЬ!!!",
	"Подмогу в туалет брига!", "Почему над унитазом установлены 3 камеры?")

	playsound(loc, 'sound/items/GSBussy.ogg', 30, TRUE)
	user.visible_message("[icon2html(src, viewers(user))] [span_notice(message)]")
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/obj/item/toy/plushie/gsbplushie/attack_self(mob/user)
	. = ..()

	interaction(user)

/obj/item/toy/plushie/gsbplushie/afterattack(atom/target, mob/user, proximity, flag, params)
	. = ..()

	if(!proximity || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	interaction(user)

/obj/item/toy/plushie/greyplushie
	name = "Плюшевый грей"
	desc = "Плюшевая кукла грея в толстовке. Кукла входит в серию \"Пришелец\" и имеет свитер, большую голову и мультяшные глаза. Любит мехов."
	icon_state = "plushie_grey"
	item_state = "plushie_grey"
	var/hug_cooldown = FALSE //Defaults the plushie to being off coolodown. Sets the hug_cooldown var.
	var/scream_cooldown = FALSE //Defaults the plushie to being off cooldown. Sets the scream_cooldown var.
	var/singed = FALSE

/obj/item/toy/plushie/greyplushie/water_act(volume, temperature, source, method = REAGENT_TOUCH) //If water touches the plushie the following code executes.
	. = ..()
	if(scream_cooldown)
		return
	scream_cooldown = TRUE //water_act executes the scream_cooldown var, setting it on cooldown.
	addtimer(CALLBACK(src, PROC_REF(reset_screamdown)), 30 SECONDS) //After 30 seconds the reset_coolodown() proc will execute, resetting the cooldown. Hug interaction is unnaffected by this.
	playsound(src, 'sound/goonstation/voice/male_scream.ogg', 10, FALSE)//If the plushie gets wet it screams and "AAAAAH!" appears in chat.
	visible_message("[icon2html(src, viewers(loc))] [span_danger("AAAAAAХ!")]")
	if(singed)
		return
	singed = TRUE
	icon_state = "grey_singed"
	item_state = "grey_singed"//If the plushie gets wet the sprite changes to a singed version.
	desc = "Испорченная плюшевая игрушка грея. Похоже, что кто-то прогнал его под водой."

/obj/item/toy/plushie/greyplushie/proc/reset_screamdown()
	scream_cooldown = FALSE //Resets the scream interaction cooldown.

/obj/item/toy/plushie/greyplushie/proc/reset_hugdown()
	hug_cooldown = FALSE //Resets the hug interaction cooldown.

/obj/item/toy/plushie/greyplushie/attack_self(mob/user)//code for talking when hugged.
	. = ..()
	if(hug_cooldown)
		return
	hug_cooldown = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_hugdown)), 5 SECONDS) //Hug interactions only put the plushie on a 5 second cooldown.
	if(singed)//If the plushie is water damaged it'll say Ow instead of talking in wingdings.
		user.visible_message("[icon2html(src, viewers(user))] [span_danger("Ow...")]")
	else//If the plushie has not touched water they'll say Greetings in wingdings.
		user.visible_message("[icon2html(src, viewers(user))] [span_danger("☝︎❒︎♏︎♏︎⧫︎♓︎■︎♑︎⬧︎📬︎")]")

/obj/item/toy/plushie/voxplushie/attack_self(mob/user)
	if(!cooldown)
		playsound(user, 'sound/voice/shriek1.ogg', 10, FALSE)
		user.visible_message("[icon2html(src, viewers(user))] [span_danger("Skreee!")]")
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/plushie/ipcplushie
	name = "IPC plushie"
	desc = "An adorable IPC plushie, straight from New Canaan. Arguably more durable than the real deal. Toaster functionality included."
	icon_state = "plushie_ipc"
	item_state = "plushie_ipc"

/obj/item/toy/plushie/ipcplushie/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/food/snacks/breadslice))
		add_fingerprint(user)
		new /obj/item/reagent_containers/food/snacks/toast(drop_location())
		to_chat(user, span_notice("Вы засовываете хлеб в тостер."))
		playsound(loc, 'sound/machines/ding.ogg', 50, TRUE)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/toy/plushie/shardplushie
	name = "Shard plushie"
	desc = "A plushie shard of supermatter crystal. Safety 100%."
	icon_state = "plushie_shard"
	item_state = "plushie_shard"
	attack_verb = list("аннигилировал", "поцарапал")
	var/shardbite = 'sound/effects/supermatter.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/shardplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(loc, pick('sound/effects/supermatter.ogg', 'sound/effects/glass_step_sm.ogg'), 10, 1)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("ДЕСТАБИЛИЗАЦИЯ!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/shardplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, pick('sound/effects/supermatter.ogg', 'sound/effects/glass_step_sm.ogg',), 10, TRUE)

//New generation TG plushies

/obj/item/toy/plushie/lizardplushie
	name = "lizard plushie"
	desc = "An adorable stuffed toy that resembles a lizardperson."
	icon_state = "plushie_lizard"
	item_state = "plushie_lizard"

/obj/item/toy/plushie/ashwalkerplushie
	name = "ash walker plushie"
	desc = "Wild looking ash walker plush toy."
	icon_state = "plushie_ashwalker1"
	attack_verb = list("порезал", "шлёпнул", "протаранил")
	var/cooldown = FALSE
	var/ashwalkerbite = 'sound/effects/unathihiss.ogg'

/obj/item/toy/plushie/ashwalkerplushie/New()
	..()
	if(prob(50))
		icon_state = "plushie_ashwalker2"

/obj/item/toy/plushie/ashwalkerplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .
	switch(rand(1, 10))
		if(1 to 6)
			playsound(loc, ashwalkerbite, 40, TRUE)
		if(7 to 10)
			playsound(loc, pick('sound/voice/unathi/roar.ogg', 'sound/voice/unathi/roar2.ogg', 'sound/voice/unathi/roar3.ogg',	\
								'sound/voice/unathi/threat.ogg', 'sound/voice/unathi/threat2.ogg', 'sound/voice/unathi/whip_short.ogg'), 40, TRUE)

/obj/item/toy/plushie/ashwalkerplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	switch(rand(1, 20))
		if(1 to 12)
			playsound(src, ashwalkerbite, 40, TRUE)
			user.visible_message("[icon2html(src, viewers(user))] [span_danger("Hsss!")]")
		if(13 to 19)
			playsound(src, pick('sound/voice/unathi/roar.ogg', 'sound/voice/unathi/roar2.ogg', 'sound/voice/unathi/roar3.ogg',	\
								'sound/voice/unathi/threat.ogg', 'sound/voice/unathi/threat2.ogg', 'sound/voice/unathi/whip.ogg'), 40, 1)
			user.visible_message("[icon2html(src, viewers(user))] [span_danger("RAAAAAWR!")]")
		if(20)
			playsound(src, pick('sound/voice/unathi/rumble.ogg', 'sound/voice/unathi/rumble2.ogg'), 40, 1)
			user.visible_message("[icon2html(src, viewers(user))] [span_notice("Пеплоходец выглядит расслабленным.")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/snakeplushie
	name = "snake plushie"
	desc = "An adorable stuffed toy that resembles a snake. Not to be mistaken for the real thing."
	icon_state = "plushie_snake"
	item_state = "plushie_snake"

/obj/item/toy/plushie/nukeplushie
	name = "operative plushie"
	desc = "An stuffed toy that resembles a syndicate nuclear operative. The tag claims operatives to be purely fictitious."
	icon_state = "plushie_nuke"
	item_state = "plushie_nuke"

/obj/item/toy/plushie/nianplushie
	name = "nian plushie"
	desc = "A silky nian plushie, straight from the nebula. Pull its antenna to hear it buzz!"
	icon_state = "plushie_nian"
	item_state = "plushie_nian"
	var/cooldown = FALSE
	var/mothbite = 'sound/voice/scream_moth.ogg'

/obj/item/toy/plushie/nianplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, mothbite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/nianplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/voice/scream_moth.ogg', 10, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Buzzzz!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/slimeplushie
	name = "slime plushie"
	desc = "An adorable stuffed toy that resembles a slime. It is practically just a hacky sack."
	icon_state = "plushie_slime"
	item_state = "plushie_slime"

// Little cute Ninja plushie
/obj/item/toy/plushie/ninja
	name = "space ninja plushie"
	desc = "A protagonist of one of the most popular cartoon series on this side of galaxy. \"運命の忍者矢\""
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "ninja_plushie_green"
	item_state = "ninja_plushie_green"
	var/cooldown = 0
	var/plushie_color

/obj/item/toy/plushie/ninja/update_icon_state()
	switch(plushie_color)
		if("green")
			icon_state = "ninja_plushie_green"
			item_state = "ninja_plushie_green"
		if("blue")
			icon_state = "ninja_plushie_blue"
			item_state = "ninja_plushie_blue"
		if("red")
			icon_state = "ninja_plushie_red"
			item_state = "ninja_plushie_red"
		else
			icon_state = initial(icon_state)
			item_state = initial(item_state)

/obj/item/toy/plushie/ninja/attack_self(mob/user as mob)
	. = ..()
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		var/plushie_color = pick("green","blue","red")
		update_icon(UPDATE_ICON_STATE)
		switch(plushie_color)
			if("green")
				user.visible_message(span_notice("[icon2html(src, viewers(user))] [capitalize(declent_ru(NOMINATIVE))] говорит: \"Я не боюсь тьмы! Я сама тьма!\""))
			if("blue")
				user.visible_message(span_notice("[icon2html(src, viewers(user))] [capitalize(declent_ru(NOMINATIVE))] говорит: \"Твой жалкий свет меня не остановит!\""))
			if("red")
				user.visible_message(span_notice("[icon2html(src, viewers(user))] [capitalize(declent_ru(NOMINATIVE))] говорит: \"Ты можешь бежать, но не сможешь спрятаться!\""))
		plushie_color = null

//New toys from another builds
/obj/item/toy/plushie/nianplushie/beeplushie
	name = "bee plushie"
	desc = "A cute toy that resembles an even cuter bee."
	icon_state = "plushie_h"
	item_state = "plushie_h"
	attack_verb = list("ужалил", "жужанул", "опылил")
	gender = FEMALE

/obj/item/toy/plushie/realgoat
	name = "goat plushie"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same, or at least it would if it wasn't a normal plushie."
	icon_state = "realgoat"
	attack_verb = list("жеванул", "ударил", "ткнул")
	var/goatbite = 'sound/items/goatsound.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/realgoat/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, goatbite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/realgoat/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/goatsound.ogg', 10, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Baaaaah!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/foxplushie
	name = "fox plushie"
	desc = "An adorable stuffed toy resembling a cute fox."
	icon_state = "fox"
	item_state = "fox"

/obj/item/toy/plushie/blahaj
	name = "shark plushie"
	desc = "A smaller, friendlier, and fluffier version of the real thing."
	gender = MALE
	icon_state = "blahaj"
	item_state = "blahaj"
	attack_verb = list("жеванул", "обглодал", "укусил")
	var/fishbite = 'sound/weapons/bite.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/blahaj/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, fishbite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/blahaj/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/weapons/bite.ogg', 10, FALSE)
	visible_message(span_danger("...!"))
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/blahaj/twohanded
	name = "akula plushie"
	desc = "baby shark's older and cuter sister. It can play silly sound by pressing button on its belly. Doo-doo!"
	gender = FEMALE
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "plushie_akula"
	item_state = "plushie_akula"

/obj/item/toy/plushie/blahaj/twohanded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)

/obj/item/toy/plushie/blahaj/twohanded/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/rawr.ogg', 25, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_boldnotice("Rawr!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/axolotlplushie
	name = "axolotl plushie"
	desc = "An adorable stuffed toy that resembles an axolotl. Not to be mistaken for the real thing."
	icon_state = "plushie_axolotl"
	item_state = "axolotl"
	attack_verb = list("ущипнул", "чмокнул")
	var/axolotlbite = 'sound/items/axolotl.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/axolotlplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, axolotlbite, 20, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/axolotlplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/axolotl.ogg', 20, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Squeeek!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/plasmamanplushie
	name = "plasmaman plushie"
	desc = "A stuffed toy that resembles your purple coworkers. Mmm, yeah, in true plasmaman fashion, it's not cute at all despite the designer's best efforts."
	icon_state = "plasmaman_plushie_civillian"
	var/pmanlbite = 'sound/effects/extinguish.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/plasmamanplushie/random/Initialize(mapload)
	. = ..()
	var/choice = pick(subtypesof(/obj/item/toy/plushie/plasmamanplushie/standart))
	new choice(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/toy/plushie/plasmamanplushie/standart/sindie
	name = "syndicate plasmaman plushie"
	icon_state = "plasmaman_plushie_syndicomm"

/obj/item/toy/plushie/plasmamanplushie/standart/doctor
	name = "medical doctor plasmaman plushie"
	icon_state = "plasmaman_plushie_doctor"

/obj/item/toy/plushie/plasmamanplushie/standart/brigmed
	name = "brig physician plasmaman plushie"
	icon_state = "plasmaman_plushie_brigphysician"

/obj/item/toy/plushie/plasmamanplushie/standart/chemist
	name = "chemist plasmaman plushie"
	icon_state = "plasmaman_plushie_chemist"

/obj/item/toy/plushie/plasmamanplushie/standart/scientist
	name = "scientist plasmaman plushie"
	icon_state = "plasmaman_plushie_scientist"

/obj/item/toy/plushie/plasmamanplushie/standart/engineer
	name = "station engineer plasmaman plushie"
	icon_state = "plasmaman_plushie_engineer"

/obj/item/toy/plushie/plasmamanplushie/standart/atmostech
	name = "atmospheric technician plasmaman plushie"
	icon_state = "plasmaman_plushie_atmostech"

/obj/item/toy/plushie/plasmamanplushie/standart/officer
	name = "security officer plasmaman plushie"
	icon_state = "plasmaman_plushie_officer"

/obj/item/toy/plushie/plasmamanplushie/standart/captain
	name = "captain plasmaman plushie"
	icon_state = "plasmaman_plushie_captain"

/obj/item/toy/plushie/plasmamanplushie/standart/ntr
	name = "nanotrasen representative plasmaman plushie"
	icon_state = "plasmaman_plushie_ntr"

/obj/item/toy/plushie/plasmamanplushie/standart/miner
	name = "shaft miner plasmaman plushie"
	icon_state = "plasmaman_plushie_shaftminer"

/obj/item/toy/plushie/plasmamanplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, pmanlbite, 20, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/plasmamanplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/effects/extinguish.ogg', 20, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Плазззма Вечна!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/rouny
	name = "runner plushie"
	desc = "A plushie depicting a xenomorph runner, made to commemorate the centenary of the Battle of LV-426. Much cuddlier than the real thing."
	icon_state = "rouny"
	attack_verb = list("порезал", "укусил", "протаранил")
	var/rounibite = 'sound/items/Help.ogg'
	var/cooldown = FALSE

/obj/item/toy/plushie/rouny/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, rounibite, 10, TRUE)	// Play bite sound in local area

/obj/item/toy/plushie/rouny/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, 'sound/items/Help.ogg', 10, FALSE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Бежиииииим!")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/beepsky
	name = "plush Officer Sweepsky"
	desc = "A plushie of a popular industrious cleaning robot! If it could feel emotions, it would love you."
	icon_state = "beepskyplushie"

/obj/item/toy/plushie/banbanana
	name = "BANana"
	desc = "What happens if I peel it?"
	icon_state = "banana"

/obj/item/toy/plushie/banbanana/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	to_chat(target, span_danger("Вас забанил ХО$Т.\nПричина: Хонк."))
	to_chat(target, span_danger("Это ПЕРМАНЕНТНЫЙ бан."))
	to_chat(user, span_danger("Вы <b>ЗАБАНИЛИ</b> [target]"))
	playsound(loc, 'sound/effects/adminhelp.ogg', 25)
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/item/toy/plushie/pig
	name = "rubber piggy"
	desc = "The people demand pigs!"
	icon_state = "pig1"
	var/spam_flag = 0
	var/message_spam_flag = 0

/obj/item/toy/plushie/pig/proc/oink(mob/user, msg)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(loc, pick('sound/items/pig1.ogg','sound/items/pig2.ogg','sound/items/pig3.ogg'), 100, TRUE)
		add_fingerprint(user)
		if(message_spam_flag == 0)
			message_spam_flag = 1
			user.visible_message(span_notice("[user] [msg] [declent_ru(ACCUSATIVE)]!"), span_notice("Вы [msg] [declent_ru(ACCUSATIVE)]!"))
			spawn(30)
				message_spam_flag = 0
		spawn(3)
			spam_flag = 0
	return

/obj/item/toy/plushie/pig/attack_self(mob/user)
	oink(user, "сжал[GEND_A_O_I(user)]")

/obj/item/toy/plushie/pig/attack_hand(mob/user)
	oink(user, pick("сжал[GEND_A_O_I(user)]", "раздавил[GEND_A_O_I(user)]", "ущипнул[GEND_A_O_I(user)]"))

/obj/item/toy/plushie/pig/Initialize(mapload)
	. = ..()
	switch(rand(1, 100))
		if(1 to 33)
			icon_state = "pig1"
		if(34 to 66)
			icon_state = "pig2"
		if(67 to 99)
			icon_state = "pig3"
		if(100)
			icon_state = "pig4"
			name = "green rubber piggy"
			desc = "Watch out for angry voxes!"

/obj/item/toy/plushie/pig/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	. = ..()
	if(!.)
		return FALSE

	if(over_object != user || user.incapacitated() || !ishuman(user))
		return FALSE

	if(user.put_in_hands(src, ignore_anim = FALSE))
		add_fingerprint(user)
		user.visible_message(span_notice("[user] поднял [declent_ru(ACCUSATIVE)]."))
		return TRUE

	return FALSE

/obj/item/toy/plushie/bubblegumplushie
	name = "bubblegum plushie"
	desc = "In what passes for a heirarchy among slaughter demon plushies, this one is king."
	icon_state = "plushie_bubblegum"
	item_state = "plushie_bubblegum"
	attack_verb = list("атаковал", "протаранил")
	var/cooldown = FALSE
	var/bubblestep = 'sound/effects/meteorimpact.ogg'
	var/bubbleattack = 'sound/misc/demon_attack1.ogg'

/obj/item/toy/plushie/bubblegumplushie/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(.))
		playsound(loc, pick(bubblestep, bubbleattack), 40, TRUE)

/obj/item/toy/plushie/bubblegumplushie/attack_self(mob/user)
	if(cooldown)
		return ..()

	playsound(src, bubblestep, 40, TRUE)
	user.visible_message("[icon2html(src, viewers(user))] [span_danger("Бубльгум топает...")]")
	cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, cooldown, FALSE), 3 SECONDS)

/obj/item/toy/plushie/hampter
	name = "Hampter"
	desc = "The people demand hampters!"
	icon_state = "hampter"

/obj/item/toy/plushie/hampter/asisstant
	name = "Hampter the Assitant"
	desc = "More or less helpful."
	icon_state = "hampter_ass"

/obj/item/toy/plushie/hampter/security
	name = "The anti-honk Hampter"
	desc = "OBEY!"
	icon_state = "hampter_sec"

/obj/item/toy/plushie/hampter/medic
	name = "Hampter the Doctor"
	desc = "Don't take his pills."
	icon_state = "hampter_med"

/obj/item/toy/plushie/hampter/janitor
	name = "Hampter the Janitor"
	desc = "I'll call you - Den."
	icon_state = "hampter_jan"

/obj/item/toy/plushie/hampter/captain
	name = "Hampter the Captain"
	desc = "Thinks he is the Head."
	icon_state = "hampter_cap"

/obj/item/toy/plushie/hampter/captain/old
	name = "Hampter the first Captain"
	desc = "Thinks he is the original Head."
	icon_state = "hampter_old_cap"

/obj/item/toy/plushie/hampter/syndi
	name = "Hampter the Red Baron"
	desc = "The real Head."
	icon_state = "hampter_sdy"

/obj/item/toy/plushie/hampter/death_squad
	name = "Who?"
	desc = "Don't call him - daddy."
	icon_state = "hampter_ded"

/obj/item/toy/plushie/hampter/ert_squad
	name = "Hampter the Major"
	desc = "Faces into the floor!"
	icon_state = "hampter_ert"

/obj/item/toy/plushie/beaver
	name = "beaver plushie"
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья."
	icon_state = "beaver_plushie"
	item_state = "beaver_plushie"
	gender = MALE

/obj/item/toy/plushie/beaver/sounded //only adminspawn
	desc = "Милая мягкая игрушка бобра. Держа его в руках, вы едва можете сдержаться от криков счастья. Эта выглядит ещё лучше, чем обычно!"
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/beaver/sounded/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	user.visible_message(span_boldnotice("BOBR KURWA!"))
	playsound(user, 'sound/items/beaver_plushie.ogg', 50, FALSE)
	COOLDOWN_START(src, cooldown, 3 SECONDS)

/obj/item/toy/plushie/chikaboomchik
	name = "Плюшевый Чикабумчик"
	desc = "Милая плюшевая игрушка птички Чикабумчика. Маленькая, круглая и очень пушистая."
	icon_state = "plushie_chikaboom"
	item_state = "chikaboom"
	attack_verb = list("цапнул", "клюнул")
	poof_sound = 'sound/items/wahwah.ogg'
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/chikaboomchik/attack_self(mob/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, cooldown))
		return .
	playsound(loc, 'sound/items/wahwah.ogg', 50, FALSE)
	COOLDOWN_START(src, cooldown, 3 SECONDS)

#define EVIL_MODE_CHANCE 5

/obj/item/toy/plushie/wet_owl
	name = "wet owl plushie"
	desc = "Плюшевая игрушка поникшей мокрой совы. Она явно видела некоторое дерьмо."
	icon_state = "wet_owl"
	item_state = "wet_owl"
	attack_verb = list("ухнул", "клюнул", "цапнул")
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF | LAVA_PROOF
	/// Is it in evil mode now or not
	var/is_evil = FALSE
	/// Cooldown to prevent evil sound spam
	var/cooldown_time = 2 SECONDS
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/plushie/wet_owl/get_ru_names()
	return list(
		NOMINATIVE = "мокрая сова",
		GENITIVE = "мокрой совы",
		DATIVE = "мокрой сове",
		ACCUSATIVE = "мокрую сову",
		INSTRUMENTAL = "мокрой совой",
		PREPOSITIONAL = "мокрой сове",
	)

/obj/item/toy/plushie/wet_owl/water_act(volume, temperature, source, method)
	. = ..()
	visible_message(span_cultitalic("[capitalize(declent_ru(NOMINATIVE))] недовольно завывает."))
	playsound(src, 'sound/effects/wet_owl_horror.ogg', 50, FALSE, -1)
	temporary_become_evil(30 SECONDS)

/obj/item/toy/plushie/wet_owl/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] всматривается в бездну глаз [declent_ru(GENITIVE)], и бездна начинает всматриваться в ответ!"))
	playsound(src, 'sound/effects/wet_owl_horror.ogg', 70, FALSE, -1)
	user.emote("scream")
	return SHAME

/obj/item/toy/plushie/wet_owl/attack_self(mob/living/user)
	. = ..()
	if(prob(EVIL_MODE_CHANCE))
		temporary_become_evil(5 SECONDS)

	if(!is_evil)
		return .

	var/mob/living/carbon/human/human = user
	human.AdjustConfused(3 SECONDS, bound_lower = 0, bound_upper = 15 SECONDS)

/obj/item/toy/plushie/wet_owl/proc/temporary_become_evil(evil_mode_duration)
	is_evil = TRUE
	icon_state = "evil_wet_owl"
	item_state = "evil_wet_owl"
	desc = "Злобная плюшевая игрушка мокрой совы. Она явно видела некоторое дерьмо — это легко можно понять по её взгляду."
	poof_sound = 'sound/effects/wet_owl_horror.ogg'
	update_appearance()
	addtimer(CALLBACK(src, PROC_REF(become_normal)), evil_mode_duration)

/obj/item/toy/plushie/wet_owl/proc/become_normal()
	is_evil = FALSE
	icon_state = initial(icon_state)
	item_state = initial(item_state)
	desc = initial(desc)
	poof_sound = initial(poof_sound)
	update_appearance()

/obj/item/toy/plushie/wet_owl/play_poof_sound()
	if(!is_evil)
		return ..()

	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	COOLDOWN_START(src, cooldown, cooldown_time)
	playsound(loc, poof_sound, 20, FALSE)

#undef EVIL_MODE_CHANCE

/obj/item/toy/plushie/manulplushie
	name = "manul plushie"
	desc = "Чёрный котик в красными ушами, в халатике, на халате бирка \"Манул\". Кто-то оставил эту игрушку здесь в память..."
	icon_state = "kotik_plushie"
	item_state = "kotik_hand"

/obj/item/toy/plushie/manulplushie/get_ru_names()
	return list(
		NOMINATIVE = "игрушка Манула",
		GENITIVE = "игрушки Манула",
		DATIVE = "игрушке Манула",
		ACCUSATIVE = "игрушку Манула",
		INSTRUMENTAL = "игрушкой Манула",
		PREPOSITIONAL = "игрушке Манула",
	)

/*
 * Foam Armblade
 */

/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "it says \"Sternside Changs #1 fan\" on it. "
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	item_state = "arm_blade"
	attack_verb = list("уколол", "поглотил", "пронзил")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	lefthand_file = 'icons/mob/inhands/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/melee_righthand.dmi'

/*
 * Toy/fake flash
 */
/obj/item/toy/flash
	name = "toy flash"
	desc = "FOR THE REVOLU- Oh wait, that's just a toy."
	icon = 'icons/obj/device.dmi'
	icon_state = "flash"
	item_state = "flashtool"
	w_class = WEIGHT_CLASS_TINY

/obj/item/toy/flash/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	playsound(loc, 'sound/weapons/flash.ogg', 100, TRUE)
	flick("[initial(icon_state)]2", src)
	user.visible_message(span_disarm("[user] ослепля[PLUR_ET_YUT(user)] [target.declent_ru(ACCUSATIVE)] вспышкой флешера!"))
	return ATTACK_CHAIN_PROCEED_SUCCESS

/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From HonkCo Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if(cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message(span_warning("[user] нажима[PLUR_ET_YUT(user)] большую красную кнопку."), span_notice("Вы нажимаете кнопку, раздаётся громкий звук!"), span_notice("Кнопка громко щёлкает."))
		playsound(src, 'sound/effects/explosionfar.ogg', 50, FALSE, 0)
		for(var/mob/M in range(10, src)) // Checks range
			if(!M.stat && !istype(M, /mob/living/silicon/ai)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		to_chat(user, span_alert("Ничего не происходит."))

/*
 * AI core prizes
 */
/obj/item/toy/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "AI"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/AI/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = generate_ion_law()
		to_chat(user, span_notice("Вы нажимаете кнопку на [declent_ru(GENITIVE)]."))
		playsound(user, 'sound/machines/click.ogg', 20, TRUE)
		user.visible_message(span_danger("[icon2html(src, viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/library_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/library_righthand.dmi'
	icon_state = "demonomicon"
	item_state = "demonomicon"
	w_class = WEIGHT_CLASS_SMALL
	COOLDOWN_DECLARE(cooldown)

/obj/item/toy/codex_gigas/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, cooldown))
		return

	user.visible_message(
		span_notice("[user] нажима[PLUR_ET_YUT(user)] кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_notice("Вы нажимаете кнопку на [declent_ru(PREPOSITIONAL)]."),
		span_sinister("Слышишь тихий щелчок."))

	var/list/messages = list()
	var/datum/devilinfo/devil = new

	LAZYADD(messages, "Интересные факты о: [devil.truename]")
	LAZYADD(messages, devil.bane.law)
	LAZYADD(messages, devil.ban.law)
	LAZYADD(messages, devil.obligation.law)
	LAZYADD(messages, devil.banish.law)

	playsound(loc, 'sound/machines/click.ogg', 20, TRUE)
	COOLDOWN_START(src, cooldown, 2 SECONDS)

	for(var/message in messages)
		user.loc.visible_message(span_danger("[icon2html(src, viewers(user.loc))] [message]"))
		sleep(1 SECONDS)

	return

/obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("На этот раз тебе не уйти, Гриффин!", "Стой, преступник!", "Ух! Ух!", "Я — ночь!")
		to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/creatures/hoot.ogg', 25, TRUE)
		user.visible_message(span_danger("[icon2html(src, viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon = 'icons/obj/toy.dmi'
	icon_state = "griffinprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("Ты не остановишь меня, Сова!", "Мой план безупречен! Хранилище моё!", "Карррр!", "Меня никогда не поймаешь!")
		to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/creatures/caw.ogg', 25, TRUE)
		user.visible_message(span_danger("[icon2html(src, viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

// DND Character minis. Use the naming convention (type)character for the icon states.
/obj/item/toy/character
	icon = 'icons/obj/toy.dmi'
	w_class = WEIGHT_CLASS_SMALL
	pixel_z = 5

/obj/item/toy/character/alien
	name = "Xenomorph Miniature"
	desc = "A miniature xenomorph. Scary!"
	icon_state = "aliencharacter"
/obj/item/toy/character/cleric
	name = "Cleric Miniature"
	desc = "A wee little cleric, with his wee little staff."
	icon_state = "clericcharacter"
/obj/item/toy/character/warrior
	name = "Warrior Miniature"
	desc = "That sword would make a decent toothpick."
	icon_state = "warriorcharacter"
/obj/item/toy/character/thief
	name = "Thief Miniature"
	desc = "Hey, where did my wallet go!?"
	icon_state = "thiefcharacter"
/obj/item/toy/character/wizard
	name = "Wizard Miniature"
	desc = "MAGIC!"
	icon_state = "wizardcharacter"
/obj/item/toy/character/cthulhu
	name = "Cthulhu Miniature"
	desc = "The dark lord has risen!"
	icon_state = "darkmastercharacter"
/obj/item/toy/character/lich
	name = "Lich Miniature"
	desc = "Murderboner extraordinaire."
	icon_state = "lichcharacter"
/obj/item/storage/box/characters
	name = "Box of Miniatures"
	desc = "The nerd's best friends."

/obj/item/storage/box/characters/populate_contents()
	new /obj/item/toy/character/alien(src)
	new /obj/item/toy/character/cleric(src)
	new /obj/item/toy/character/warrior(src)
	new /obj/item/toy/character/thief(src)
	new /obj/item/toy/character/wizard(src)
	new /obj/item/toy/character/cthulhu(src)
	new /obj/item/toy/character/lich(src)

//Pet Rocks, just like from the 70's!

/obj/item/toy/pet_rock
	name = "pet rock"
	desc = "The perfect pet!"
	icon = 'icons/obj/toy.dmi'
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

//minigibber, so cute

/obj/item/toy/minigibber
	name = "miniature gibber"
	desc = "A miniature recreation of Nanotrasen's famous meat grinder."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minigibber"
	attack_verb = list("перемолол", "гибнул")
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/obj/stored_minature = null

/obj/item/toy/minigibber/attack_self(mob/user)

	if(stored_minature)
		user.visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] издаёт жуткий скрежет, уничтожая миниатюрную фигурку внутри!"))
		QDEL_NULL(stored_minature)
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		cooldown = world.time

	if(cooldown < world.time - 8)
		to_chat(user, span_notice("Вы нажимаете кнопку гиба на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/goonstation/effects/gib.ogg', 20, TRUE)
		cooldown = world.time

/obj/item/toy/minigibber/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/toy/character))
		add_fingerprint(user)
		if(stored_minature)
			to_chat(user, span_warning("Внутри уже есть [stored_minature.declent_ru(NOMINATIVE)]!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(span_notice("[user] вставляет [icon2html(I, viewers(I))] [I.declent_ru(ACCUSATIVE)] в мини-приёмник [declent_ru(GENITIVE)]..."))
		if(!do_after(user, 1 SECONDS, src, category = DA_CAT_TOOL) || stored_minature)
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("Вы вставили [icon2html(I, user)] [I.declent_ru(ACCUSATIVE)] в [declent_ru(GENITIVE)]!"))
		stored_minature = I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	bubble_icon = "alien"
	var/cooldown = 0
	var/animating = FALSE

/obj/item/toy/toy_xeno/update_icon_state()
	icon_state = animating ? "[initial(icon_state)]_used" : initial(icon_state)

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message(span_notice("[user] дергает[PLUR_ET_YUT(user)] верёвку на [declent_ru(PREPOSITIONAL)]."))
		INVOKE_ASYNC(src, PROC_REF(async_animation))
	else
		to_chat(user, span_warning("Верёвка [declent_ru(GENITIVE)] еще не замоталась!"))

/obj/item/toy/toy_xeno/proc/async_animation()
	animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(0.5 SECONDS)
	atom_say("Hiss!")
	var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
	playsound(get_turf(src), pick(possible_sounds), 50, TRUE)
	sleep(4.5 SECONDS)
	animating = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/item/toy/russian_revolver
	name = "russian revolver"
	desc = "For fun and games!"
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "detective_gold"
	item_state = "gun"
	lefthand_file = 'icons/mob/inhands/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/guns_righthand.dmi'
	hitsound = SFX_SWING_HIT
	flags =  CONDUCT
	slot_flags = ITEM_SLOT_BELT
	materials = list(MAT_METAL=2000)
	throwforce = 5
	throw_range = 5
	force = 5
	origin_tech = "combat=1"
	attack_verb = list("ударил")
	var/bullets_left = 0
	var/max_shots = 6

/obj/item/toy/russian_revolver/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] быстро заряжает шесть патронов в барабан [declent_ru(GENITIVE)], приставляет к виску и нажимает на курок! Похоже, [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся покончить с собой."))
	playsound(loc, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/russian_revolver/New()
	..()
	spin_cylinder()

/obj/item/toy/russian_revolver/attack_self(mob/user)
	if(!bullets_left)
		user.visible_message(span_warning("[user] заряжает патрон в барабан [declent_ru(GENITIVE)] и крутит его."))
		spin_cylinder()
	else
		user.visible_message(span_warning("[user] крутит барабан [declent_ru(GENITIVE)]!"))
		spin_cylinder()

/obj/item/toy/russian_revolver/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	return ATTACK_CHAIN_PROCEED

/obj/item/toy/russian_revolver/afterattack(atom/target, mob/user, flag, params)
	if(flag)
		if(target in user.contents)
			return
		if(!ismob(target))
			return
	user.changeNext_move(CLICK_CD_MELEE)
	shoot_gun(user)

/obj/item/toy/russian_revolver/proc/spin_cylinder()
	bullets_left = rand(1, max_shots)

/obj/item/toy/russian_revolver/proc/post_shot(mob/user)
	return

/obj/item/toy/russian_revolver/proc/shoot_gun(mob/living/carbon/human/user)
	if(bullets_left > 1)
		bullets_left--
		user.visible_message(span_danger("*клик*"))
		playsound(src, 'sound/weapons/empty.ogg', 100, TRUE)
		return FALSE
	if(bullets_left == 1)
		bullets_left = 0
		var/zone = BODY_ZONE_HEAD
		if(!(user.get_organ(zone))) // If they somehow don't have a head.
			zone = BODY_ZONE_CHEST
		playsound(src, 'sound/weapons/gunshots/gunshot_strong.ogg', 50, TRUE)
		user.visible_message(span_danger("[src] goes off!"))
		post_shot(user)
		user.apply_damage(300, BRUTE, zone, sharp = TRUE, used_weapon = "Self-inflicted gunshot wound to the [zone].")
		user.bleed(BLOOD_VOLUME_NORMAL)
		user.death() // Just in case
		return TRUE
	else
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] нужно перезарядить."))
		return FALSE

/obj/item/toy/russian_revolver/trick_revolver
	name = ".357 revolver"
	desc = "Подозрительный револьвер. В нём используются патроны .357 калибра."
	icon_state = "revolver"
	max_shots = 1
	var/fake_bullets = 0

/obj/item/toy/russian_revolver/trick_revolver/get_ru_names()
	return list(
		NOMINATIVE = "револьвер .357 калибра",
		GENITIVE = "револьвера .357 калибра",
		DATIVE = "револьверу .357 калибра",
		ACCUSATIVE = "револьвер .357 калибра",
		INSTRUMENTAL = "револьвером .357 калибра",
		PREPOSITIONAL = "револьвере .357 калибра",
	)

/obj/item/toy/russian_revolver/trick_revolver/New()
	..()
	fake_bullets = rand(2, 7)

/obj/item/toy/russian_revolver/trick_revolver/examine(mob/user) //Sneaky sneaky
	. = ..()
	. += span_notice("В запасе ещё [fake_bullets] патрон[DECL_CREDIT(fake_bullets)].")
	. += span_notice("[fake_bullets] из них боевые.")

/obj/item/toy/russian_revolver/trick_revolver/post_shot(user)
	to_chat(user, span_danger("[capitalize(declent_ru(NOMINATIVE))] действительно выглядел довольно сомнительно!"))
	SEND_SOUND(user, sound('sound/misc/sadtrombone.ogg')) //HONK
/*
 * Rubber Chainsaw
 */
/obj/item/twohanded/toy/chainsaw
	name = "Toy Chainsaw"
	desc = "A toy chainsaw with a rubber edge. Ages 8 and up"
	icon_state = "chainsaw0"
	throw_speed = 4
	throw_range = 20
	wieldsound = 'sound/weapons/chainsaw_start.ogg'
	attack_verb = list("пропилил", "порезал", "покромсал", "рубанул")

/obj/item/twohanded/toy/chainsaw/update_icon_state()
	icon_state = "chainsaw[HAS_TRAIT(src, TRAIT_WIELDED)]"

/*
 * Cat Toy
 */
/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	var/cooldown = 0

/*
 * Action Figures
 */

/obj/random/figure
	name = "Random Action Figure"
	desc = "This is a random toy action figure"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"

/obj/random/figure/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/figure))

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing?"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/toysay = "Чё за хуйню вы натворили?"

/obj/item/toy/figure/New()
	..()
	desc = "A \"Space Life\" brand [name]"

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		user.visible_message(span_notice("[icon2html(src, viewers(user))] [capitalize(declent_ru(NOMINATIVE))] говорит \"[toysay]\"."))
		playsound(user, 'sound/machines/click.ogg', 20, TRUE)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "The ever-suffering CMO, from Space Life's SS12 figurine collection."
	icon_state = "cmo"
	toysay = "Переключи датчики!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "The faceless, hairless scourge of the station, from Space Life's SS12 figurine collection."
	icon_state = "assistant"
	toysay = "Грейтайд един!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "The faithful atmospheric technician, from Space Life's SS12 figurine collection."
	icon_state = "atmos"
	toysay = "Слава Атмосии!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "The suave bartender, from Space Life's SS12 figurine collection."
	icon_state = "bartender"
	toysay = "Где моя обезьяна?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	desc = "The iron-willed cyborg, from Space Life's SS12 figurine collection."
	icon_state = "borg"
	toysay = "Я. СНОВА. ЖИВОЙ."

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	desc = "The drug-addicted botanist, from Space Life's SS12 figurine collection."
	icon_state = "botanist"
	toysay = "Чувак, я вижу цвета..."

/obj/item/toy/figure/captain
	name = "Captain action figure"
	desc = "The inept captain, from Space Life's SS12 figurine collection."
	icon_state = "captain"
	toysay = "Экипаж, ядерный диск в безопасности, в меня в жопе."

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "The hard-working cargo tech, from Space Life's SS12 figurine collection."
	icon_state = "cargotech"
	toysay = "За Каргонию!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "The expert Chief Engineer, from Space Life's SS12 figurine collection."
	icon_state = "ce"
	toysay = "Подключите соляры!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "The obsessed Chaplain, from Space Life's SS12 figurine collection."
	icon_state = "chaplain"
	toysay = "Боги, сделайте меня машиной для убийств!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "The cannibalistic chef, from Space Life's SS12 figurine collection."
	icon_state = "chef"
	toysay = "Клянусь, это не человечина."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	desc = "The legally dubious Chemist, from Space Life's SS12 figurine collection."
	icon_state = "chemist"
	toysay = "Забери свои таблетки!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "The mischevious Clown, from Space Life's SS12 figurine collection."
	icon_state = "clown"
	toysay = "Хонк!"

/obj/item/toy/figure/ian
	name = "Ian action figure"
	desc = "The adorable corgi, from Space Life's SS12 figurine collection."
	icon_state = "ian"
	toysay = "Гав!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "The clever detective, from Space Life's SS12 figurine collection."
	icon_state = "detective"
	toysay = "На этом шлюзе есть следы серого комбинезона и изоляционных перчаток."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	desc = "It's a member of the DeathSquad, a TV drama where loose-cannon ERT officers face up against the threats of the galaxy! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "dsquad"
	toysay = "Уничтожить все угрозы!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "The frantic engineer, from Space Life's SS12 figurine collection."
	icon_state = "engineer"
	toysay = "О боже, сингулярность сбежала!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "The balding geneticist, from Space Life's SS12 figurine collection."
	icon_state = "geneticist"
	toysay = "Я не квалифицирован для этой работы."

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	desc = "The officious Head of Personnel, from Space Life's SS12 figurine collection."
	icon_state = "hop"
	toysay = "Бумаги, пожалуйста!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "The bloodlust-filled Head of Security, from Space Life's SS12 figurine collection."
	icon_state = "hos"
	toysay = "Космозакон? Чего?"

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "The nationalistic Quartermaster, from Space Life's SS12 figurine collection."
	icon_state = "qm"
	toysay = "Хайль Каргония!"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "The water-using Janitor, from Space Life's SS12 figurine collection."
	icon_state = "janitor"
	toysay = "Читай знаки, идиот."

/obj/item/toy/figure/lawyer
	name = "Internal Affairs Agent action figure"
	desc = "The unappreciated Internal Affairs Agent, from Space Life's SS12 figurine collection."
	icon_state = "lawyer"
	toysay = "СРП говорит, что они виновны! Взлом — доказательство того, что они Враги Корпорации!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "The quiet Librarian, from Space Life's SS12 figurine collection."
	icon_state = "librarian"
	toysay = "Однажды, в..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "The stressed-out doctor, from Space Life's SS12 figurine collection."
	icon_state = "md"
	toysay = "Пациент уже мёртв!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "... from Space Life's SS12 figurine collection."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "The gun-toting Shaft Miner, from Space Life's SS12 figurine collection."
	icon_state = "miner"
	toysay = "О боже, оно жрёт мои кишки!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	desc = "It's the mysterious ninja! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "ninja"
	toysay = "О боже! Хватит стрелять, я косплеер!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "It's the deadly, spell-slinging wizard! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	desc = "The ambitious RD, from Space Life's SS12 figurine collection."
	icon_state = "rd"
	toysay = "Уничтожить всех боргов!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "The skillful Roboticist, from Space Life's SS12 figurine collection."
	icon_state = "roboticist"
	toysay = "Он сам просил боргизацию!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "The mad Scientist, from Space Life's SS12 figurine collection."
	icon_state = "scientist"
	toysay = "Кто-то другой сделал эти бомбы!"

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	desc = "It's the red-suited Nuclear Operative! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "syndie"
	toysay = "Заберите этот ёбанный диск!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "The power-tripping Security Officer, from Space Life's SS12 figurine collection."
	icon_state = "secofficer"
	toysay = "Я есть закон!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	desc = "The pandemic-starting Virologist, from Space Life's SS12 figurine collection."
	icon_state = "virologist"
	toysay = "Это не мой вирус!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "The amnesiac Warden, from Space Life's SS12 figurine collection."
	icon_state = "warden"
	toysay = "Казнить за взлом!"

/obj/item/toy/figure/magistrate
	name = "Magistrate action figure"
	desc = "The relevant magistrate, from Space Life's SS12 figurine collection."
	icon_state = "magistrate"
	toysay = "Казнить или не казнить — вот в чём вопрос."

//////////////////////////////////////////////////////
//				Magic 8-Ball / Conch				//
//////////////////////////////////////////////////////

/obj/item/toy/eight_ball
	name = "Magic 8-Ball"
	desc = "Mystical! Magical! Ages 8+!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "eight-ball"
	var/use_action = "трясёт шар"
	var/cooldown = 0
	var/list/possible_answers = list("Определённо", "Все признаки указывают на \"да\".", "Скорее всего.", "Да.", "Спроси позже.", "Лучше не сейчас.", "Будущее неясно.", "Возможно.", "Сомнительно.", "Нет.", "Не рассчитывай на это.", "Никогда.")

/obj/item/toy/eight_ball/attack_self(mob/user as mob)
	if(!cooldown)
		var/answer = pick(possible_answers)
		user.visible_message(span_notice("[user] сосредотачива[PLUR_ET_YUT(user)]ся на своём вопросе и [use_action]..."))
		user.visible_message(span_notice("[icon2html(src, viewers(user))] [capitalize(declent_ru(NOMINATIVE))] говорит: \"[answer]\""))
		spawn(30)
			cooldown = 0
		return

/obj/item/toy/eight_ball/conch
	name = "Magic Conch Shell"
	desc = "All hail the Magic Conch!"
	icon_state = "conch"
	use_action = "тянет за верёвочку"
	possible_answers = list("Да.", "Нет.", "Спроси ещё раз.", "Ничего.", "Я так не думаю.", "Ни то, ни другое.", "Может быть, когда-нибудь.")

/*
 *Fake cuffs (honk honk)
 */

/obj/item/restraints/handcuffs/toy
	desc = "Toy handcuffs. Plastic and extremely cheaply made."
	throwforce = 0
	breakout_time = 0
	ignoresClumsy = TRUE

/*
* Office desk toys
*/

/obj/item/toy/desk
	name = "desk toy master"
	desc = "A object that does not exist. Parent Item"
	icon = 'icons/obj/toy.dmi'
	layer = ABOVE_MOB_LAYER
	var/on = 0
	var/activation_sound = 'sound/items/buttonclick.ogg'

/obj/item/toy/desk/update_icon_state()
	if(on)
		icon_state = "[initial(icon_state)]-on"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/toy/desk/attack_self(mob/user)
	on = !on
	if(activation_sound)
		playsound(src.loc, activation_sound, 75, TRUE)
	update_icon(UPDATE_ICON_STATE)
	return TRUE

/obj/item/toy/desk/verb/rotate()
	set name = "Повернуть"
	set category = STATPANEL_OBJECT
	set src in oview(1)

	if(usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		to_chat(usr, span_warning("Сейчас ты не можешь этого сделать!"))
		return
	dir = turn(dir, 270)
	return TRUE

/obj/item/toy/desk/click_alt(mob/user)
	rotate()
	return CLICK_ACTION_SUCCESS

/obj/item/toy/desk/officetoy
	name = "office toy"
	desc = "A generic microfusion powered office desk toy. Only generates magnetism and ennui."
	icon_state= "desktoy"
/obj/item/toy/desk/dippingbird
	name = "dipping bird toy"
	desc = "A ancient human bird idol, worshipped by clerks and desk jockeys."
	icon_state= "dippybird"
/obj/item/toy/desk/newtoncradle
	name = "Newton's cradle"
	desc = "A ancient 21th century super-weapon model demonstrating that Sir Isaac Newton is the deadliest sonuvabitch in space."
	icon_state = "newtoncradle"
	var/datum/looping_sound/newtonballs/soundloop

/obj/item/toy/desk/newtoncradle/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/newtoncradle/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/item/toy/desk/fan
	name = "office fan"
	desc = "Your greatest fan"
	icon_state = "fan"
	var/datum/looping_sound/fanblow/soundloop

/obj/item/toy/desk/fan/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/toy/desk/fan/attack_self(mob/user)
	on = !on
	update_icon(UPDATE_ICON_STATE)
	if(on)
		soundloop.start()
	else
		soundloop.stop()

/obj/item/toy/toolbox
	name = "Rubber Toolbox"
	desc = "Practice your robust!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "rubber_toolbox"
	damtype = STAMINA
	force = 10
	throwforce = 15
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("заробастил")
	hitsound = 'sound/items/squeaktoy.ogg'
