/obj/item/storage/bible
	name = "bible"
	desc = "Многократно прислоняйте к голове."
	gender = FEMALE
	lefthand_file = 'icons/mob/inhands/chaplain_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chaplain_righthand.dmi'
	icon = 'icons/obj/library.dmi'
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	drop_sound = 'sound/items/handling/drop/book_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/book_pickup.ogg'
	var/mob/affecting = null
	var/deity_name = "Господь-Бог"
	/// Is the sprite of this bible customisable
	var/customisable = FALSE
	var/god_punishment = 0 //used for diffrent abuse with bible (healing self is one of them)
	var/last_used = 0

	/// Associative list of accociative lists of bible variants, used for the radial menu
	var/static/list/bible_variants = list(
		"Библия" =				list("state" = "bible",		 			"inhand" = "bible"),
		"Коран" =				list("state" = "bible_koran",		 	"inhand" = "koran"),
		"Скрапбук" =			list("state" = "bible_scrapbook",	 	"inhand" = "scrapbook"),
		"Крипер" =				list("state" = "bible_creeper",	 		"inhand" = "creeper"),
		"Белая Библия" =		list("state" = "bible_white",		 	"inhand" = "white"),
		"Благодатный огонь" =	list("state" = "bible_holylight",	 	"inhand" = "somebiblebook"),
		"Красная обложка" =		list("state" = "bible_atheist",	  		"inhand" = "atheist"),
		"Том" =					list("state" = "bible_tome",		  	"inhand" = "somebiblebook"),
		"Король в Жёлтом" = 	list("state" = "bible_kingyellow",  	"inhand" = "kingyellow"),
		"Итакуа" =				list("state" = "bible_ithaqua",	  		"inhand" = "ithaqua"),
		"Саентология" =			list("state" = "bible_scientology", 	"inhand" = "scientology"),
		"Плавленная Библия" =	list("state" = "bible_melted",	  		"inhand" = "melted"),
		"Некрономикон" =	 	list("state" = "bible_necronomicon",	"inhand" = "necronomicon"),
		"Грин текст" =			list("state" = "bible_greentext",	  	"inhand" = "greentext"),
)

/obj/item/storage/bible/get_ru_names()
	return list(
		NOMINATIVE = "Библия",
		GENITIVE = "Библии",
		DATIVE = "Библии",
		ACCUSATIVE = "Библию",
		INSTRUMENTAL = "Библией",
		PREPOSITIONAL = "Библии"
	)

/obj/item/storage/bible/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] смотр[pluralize_ru(user.gender, "ит", "ят")] в [declent_ru(ACCUSATIVE)] и пыта[pluralize_ru(user.gender, "ет", "ют")]ся превзойти собственное понимание Вселенной!"))
	user.dust()
	return OBLITERATION


/obj/item/storage/bible/fart_act(mob/living/user)
	if(QDELETED(user) || user.stat == DEAD)
		return FALSE
	user.visible_message(span_danger("[user] перд[pluralize_ru(user.gender, "ит", "ят")] на [declent_ru(ACCUSATIVE)]!"))
	user.visible_message(span_userdanger("Загадочная сила поражает [user]!"))
	user.suiciding = TRUE
	do_sparks(3, TRUE, user)
	user.gib()
	return TRUE // Don't run the fart emote


/obj/item/storage/bible/booze
	name = "bible"
	desc = "Многократно прислоняйте к голове."
	icon_state ="bible"

/obj/item/storage/bible/booze/get_ru_names()
	return list(
		NOMINATIVE = "Библия",
		GENITIVE = "Библии",
		DATIVE = "Библии",
		ACCUSATIVE = "Библию",
		INSTRUMENTAL = "Библией",
		PREPOSITIONAL = "Библии"
	)

/obj/item/storage/bible/booze/populate_contents()
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/reagent_containers/food/drinks/cans/beer(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)
	new /obj/item/stack/spacecash(src)


//BS12 EDIT
 // All cult functionality moved to Null Rod
/obj/item/storage/bible/proc/bless(mob/living/carbon/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/heal_amt = 10
		var/should_update_health = FALSE
		var/update_damage_icon = NONE
		for(var/obj/item/organ/external/affecting as anything in H.bodyparts)
			var/brute_was = affecting.brute_dam
			var/burn_was = affecting.burn_dam
			update_damage_icon |= affecting.heal_damage(heal_amt, heal_amt, updating_health = FALSE)
			if(affecting.brute_dam != brute_was || affecting.burn_dam != burn_was)
				should_update_health = TRUE
		if(should_update_health)
			M.updatehealth("bless heal")
		if(update_damage_icon)
			M.UpdateDamageIcon()


/obj/item/storage/bible/proc/god_forgive()
	god_punishment = max(0, god_punishment - round((world.time - last_used) / (30 SECONDS))) //forgive 1 sin every 30 seconds
	last_used = world.time


/obj/item/storage/bible/attack(mob/living/carbon/human/target, mob/living/carbon/human/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!ishuman(user) || is_monkeybasic(user))
		to_chat(user, span_warning("Вам не хватит проворности, чтобы это сделать!"))
		return .

	god_forgive()

	if(!user.mind || !user.mind.isholy)
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] начинает шипеть в ваших руках."))
		add_attack_logs(user, target, "Hit themselves with [src]")
		user.take_organ_damage(0, 10)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] вылетает из ваших рук и падает на вашу голову."))
		add_attack_logs(user, target, "Hit themselves with [src]")
		user.take_organ_damage(10)
		user.Paralyse(40 SECONDS)
		return ATTACK_CHAIN_BLOCKED_ALL

	add_attack_logs(user, target, "Hit with [src]")

	if(iscarbon(user))
		target.LAssailant = user
	else
		target.LAssailant = null

	if(target.stat == DEAD)
		target.visible_message(
			span_danger("[user] ударя[pluralize_ru(user.gender, "ет", "ют")]  безжизненное тело [target] [declent_ru(INSTRUMENTAL)]."),
			span_warning("Вы ударяете безжизненное тело [target].")
		)
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)
		return .|ATTACK_CHAIN_SUCCESS

	if(!ishuman(target))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(prob(60))
		bless(target)
		if(user == target)
			target.visible_message(
				span_danger("[user] излечива[pluralize_ru(user.gender, "ет", "ют")] себя с силой Бога \"[deity_name]\"!"),
				span_danger("Да поможет вам Бог \"[deity_name]\", да побудит он вас к исцелению!"),
			)
		else
			target.visible_message(
				span_danger("[user] излечива[pluralize_ru(user.gender, "ет", "ют")] [target] с силой Бога \"[deity_name]\"!"),
				span_danger("Да поможет вам Бог \"[deity_name]\", да побудит он вас к исцелению!"),
			)
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)
	else
		if(!istype(target.head, /obj/item/clothing/head/helmet))
			target.apply_damage(10, BRAIN)
			to_chat(target, span_warning("Вы ощущаете себя глупее, чем раньше."))
		if(user == target)
			target.visible_message(
				span_danger("[user] огрева[pluralize_ru(user.gender, "ет", "ют")] себя [declent_ru(INSTRUMENTAL)] по голове!"),
				span_danger("Вы огреваете себя [declent_ru(INSTRUMENTAL)] по голове!"),
			)
		else
			target.visible_message(
				span_danger("[user] огрева[pluralize_ru(user.gender, "ет", "ют")] [target] [declent_ru(INSTRUMENTAL)] по голове!"),
				span_danger("Вы огреваете [target] [declent_ru(INSTRUMENTAL)] по голове!"),
			)
		playsound(loc, SFX_PUNCH, 25, TRUE, -1)

	if(target == user)
		god_punishment++

	if(god_punishment == 5)
		to_chat(user, span_danger("<h1>Вы злоупотребляете покровительством Бога \"[deity_name]\", остановитесь и подумайте.</h1>"))
	else if(god_punishment > 5) //lets apply punishment AFTER heal
		user.electrocute_act(5, "молнии", flags = SHOCK_NOGLOVES)
		user.apply_damage(65, BURN)
		user.Knockdown(10 SECONDS)
		to_chat(user, span_userdanger("Вы злоупотребили волей Бога и были за это наказаны!"))


/obj/item/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(isfloorturf(target))
		to_chat(user, span_notice("Вы ударяете пол [declent_ru(INSTRUMENTAL)]."))
		if(user.mind?.isholy)
			for(var/obj/O in target)
				O.cult_reveal()
	if(istype(target, /obj/machinery/door/airlock))
		to_chat(user, span_notice("Вы ударяете шлюз [declent_ru(INSTRUMENTAL)]."))
		if(user.mind?.isholy)
			var/obj/airlock = target
			airlock.cult_reveal()

	if(user.mind?.isholy && target.reagents)
		add_holy_water(user, target)

/obj/item/storage/bible/proc/add_holy_water(mob/user, atom/target)
	if(target.reagents.has_reagent("water")) //blesses all the water in the holder
		to_chat(user, span_notice("Вы освящаете [target.declent_ru(GENITIVE)]."))
		var/water2holy = target.reagents.get_reagent_amount("water")
		target.reagents.del_reagent("water")
		target.reagents.add_reagent("holywater", water2holy)

	if(target.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
		to_chat(user, span_notice("Вы очищаете [target.declent_ru(GENITIVE)]."))
		var/unholy2clean = target.reagents.get_reagent_amount("unholywater")
		target.reagents.del_reagent("unholywater")
		target.reagents.add_reagent("holywater", unholy2clean)

/obj/item/storage/bible/attack_self(mob/user)
	. = ..()
	if(!customisable || !user.mind?.isholy)
		return

	var/list/skins = list()
	for(var/I in bible_variants)
		var/icons = bible_variants[I] // Get the accociated list
		var/image/bible_image = image('icons/obj/library.dmi', icon_state = icons["state"])
		skins[I] = bible_image

	var/choice = show_radial_menu(user, src, skins, null, 40, CALLBACK(src, PROC_REF(radial_check), user), TRUE)
	if(!choice || !radial_check(user))
		return
	var/choice_icons = bible_variants[choice]

	icon_state = choice_icons["state"]
	item_state = choice_icons["inhand"]
	customisable = FALSE

	SSblackbox.record_feedback("text", "religion_book", 1, "[choice]", 1)

	if(SSticker)
		SSticker.Bible_name = name
		SSticker.Bible_icon_state = icon_state
		SSticker.Bible_item_state = item_state

/obj/item/storage/bible/proc/radial_check(mob/user)
	if(!user?.mind.isholy || !ishuman(user))
		return FALSE
	var/mob/living/carbon/human/H = user
	if(!src || !H.is_type_in_hands(src) || H.incapacitated())
		return FALSE
	return TRUE
