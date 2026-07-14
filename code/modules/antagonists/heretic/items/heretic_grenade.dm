/*!
 * Contains Heretic grenades
 * They spread rust and obliterate borgs/mechs
 */

/obj/item/grenade/chem_grenade/rust_sower
	name = "rust sower"
	desc = "Отличная штука, превращающаяся в облоко ржавчины после взрыва. Борги и мехи будут полностью уничтожены."
	stage = GRENADE_READY
	base_icon_state = "rustgrenade"
	item_state = "rustgrenade"
	prime_sound = 'sound/weapons/rust_sower_armbomb.ogg'


/obj/item/grenade/chem_grenade/rust_sower/get_ru_names()
	return alist(
		NOMINATIVE = "граната \"Сеятель Ржавчины\"",
		GENITIVE = "гранаты \"Сеятель Ржавчины\"",
		DATIVE = "гранате \"Сеятель Ржавчины\"",
		ACCUSATIVE = "гранату \"Сеятель Ржавчины\"",
		INSTRUMENTAL = "гранатой \"Сеятель Ржавчины\"",
		PREPOSITIONAL = "гранате \"Сеятель Ржавчины\"",
	)


/obj/item/grenade/chem_grenade/rust_sower/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][active ? "_active" : ""]"


/obj/item/grenade/chem_grenade/rust_sower/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/glass/beaker/large/beaker_one = new(src)
	var/obj/item/reagent_containers/glass/beaker/large/beaker_two = new(src)

	beaker_one.reagents.add_reagent(/datum/reagent/heretic_rust, 50)
	beaker_one.reagents.add_reagent(/datum/reagent/potassium, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/phosphorus, 50)
	beaker_two.reagents.add_reagent(/datum/reagent/consumable/sugar, 50)

	beakers += beaker_one
	beakers += beaker_two


/obj/item/grenade/chem_grenade/rust_sower/prime(mob/living/lanced_by)
	. = ..()
	playsound(src, 'sound/weapons/rust_sower_explode.ogg', 70, FALSE)
	qdel(src)


/obj/item/grenade/chem_grenade/rust_sower/screwdriver_act(mob/living/user, obj/item/tool)
	return NONE


/obj/item/grenade/chem_grenade/rust_sower/wrench_act(mob/living/user, obj/item/tool)
	return NONE


/obj/item/grenade/chem_grenade/rust_sower/multitool_act(mob/living/user, obj/item/tool)
	return NONE

/*
/// Returns -1 so that you cant extract the chems
/obj/item/grenade/chem_grenade/rust_sower/proc/on_try_grind()
	SIGNAL_HANDLER
	return -1
*/

/datum/reagent/heretic_rust
	name = "heretic rust"
	description = "Вязкая, густая коричневая жидкость."
	id = "heretic_rust"
	color = COLOR_CARGO_BROWN // Rust color
	taste_description = "гнилая медь"


/datum/reagent/heretic_rust/reaction_obj(obj/exposed_atom, volume)
	. = ..()
	if(!ismecha(exposed_atom))
		return

	var/obj/mecha/to_wreck = exposed_atom
	to_wreck.take_damage(300, BURN)


/datum/reagent/heretic_rust/reaction_mob(mob/living/exposed_mob, methods = REAGENT_TOUCH, reac_volume, show_message)
	. = ..()
	if(!ishuman(exposed_mob))
		if(issilicon(exposed_mob) || ismecha(exposed_mob) || isbot(exposed_mob))
			exposed_mob.adjustBruteLoss(500)

		return

	if(isheretic(exposed_mob))
		return

	if(exposed_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return

	var/mob/living/carbon/human/victim = exposed_mob
	if(HASBIT(methods, REAGENT_TOUCH))
		if(!victim.is_pepper_proof()) // you need both eye and mouth protection
			if(prob(5))
				victim.emote("scream")

			victim.emote("cry")
			victim.EyeBlurry(10 SECONDS)
			victim.EyeBlind(6 SECONDS)
			victim.Confused(5 SECONDS)
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(/datum/movespeed_modifier/reagent/pepperspray)
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/reagent/pepperspray), 10 SECONDS)

		victim.update_damage_hud()
		victim.Disgust(5)
		for(var/obj/item/organ/external/robotic_limb in victim.bodyparts)
			if(!isroboticorgan(robotic_limb))
				continue

			robotic_limb.internal_receive_damage(5, 5)

	if(!HASBIT(methods, REAGENT_INGEST))
		return

	if(holder.has_reagent("milk"))
		return

	if(prob(15))
		to_chat(exposed_mob, span_danger("[pick("Голова раскалывается.", "Ваши внутренности горят!", "Вы чувствуете головокружение.")]"))

	if(prob(10))
		victim.EyeBlurry(2 SECONDS)

	if(prob(10))
		victim.Dizzy(2 SECONDS)

	if(prob(5))
		victim.vomit()


/datum/reagent/heretic_rust/reaction_turf(turf/exposed_turf, reac_volume, color)
	. = ..()
	exposed_turf.rust_turf()


/datum/reagent/heretic_rust/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	if(holder.has_reagent("milk"))
		return

	if(!SPT_PROB(5, seconds_per_tick))
		return

	affected_mob.visible_message(span_warning("[affected_mob.declent_ru(NOMINATIVE)] [pick("щурится!","кашляет!", "брызгает слюной!")]"))


/// Returns TRUE only if both the eyes and the mouth are covered.
/mob/living/carbon/human/proc/is_pepper_proof()
	var/eyes_covered = (glasses?.flags_cover & GLASSESCOVERSEYES) || (wear_mask?.flags_cover & MASKCOVERSEYES) || (head?.flags_cover & HEADCOVERSEYES)
	var/mouth_covered = (wear_mask?.flags_cover & MASKCOVERSMOUTH) || (head?.flags_cover & HEADCOVERSMOUTH)
	return eyes_covered && mouth_covered
