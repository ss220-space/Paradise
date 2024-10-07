/obj/item/storage/bible
	name = "bible"
	desc = "Apply to head repeatedly."
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = FIRE_PROOF
	drop_sound = 'sound/items/handling/book_drop.ogg'
	pickup_sound =  'sound/items/handling/book_pickup.ogg'
	var/mob/affecting = null
	var/deity_name = "Christ"
	/// Is the sprite of this bible customisable
	var/customisable = FALSE
	var/god_punishment = 0 //used for diffrent abuse with bible (healing self is one of them)
	var/last_used = 0

	/// Associative list of accociative lists of bible variants, used for the radial menu
	var/static/list/bible_variants = list(
		"Bible" =			   list("state" = "bible",		  "inhand" = "bible"),
		"Koran" =			   list("state" = "koran",		  "inhand" = "koran"),
		"Scrapbook" =		   list("state" = "scrapbook",	  "inhand" = "scrapbook"),
		"Creeper" =			   list("state" = "creeper",	  "inhand" = "syringe_kit"),
		"White Bible" =		   list("state" = "white",		  "inhand" = "syringe_kit"),
		"Holy Light" =		   list("state" = "holylight",	  "inhand" = "syringe_kit"),
		"PlainRed" =		   list("state" = "athiest",	  "inhand" = "syringe_kit"),
		"Tome" =			   list("state" = "tome",		  "inhand" = "syringe_kit"),
		"The King in Yellow" = list("state" = "kingyellow",	  "inhand" = "kingyellow"),
		"Ithaqua" =			   list("state" = "ithaqua",	  "inhand" = "ithaqua"),
		"Scientology" =		   list("state" = "scientology",  "inhand" = "scientology"),
		"the bible melts" =	   list("state" = "melted",		  "inhand" = "melted"),
		"Necronomicon" =	   list("state" = "necronomicon", "inhand" = "necronomicon"),
		"Greentext" =		   list("state" = "greentext",	  "inhand" = "greentext"),
	)

/obj/item/storage/bible/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] stares into [name] and attempts to transcend understanding of the universe!</span>")
	user.dust()
	return OBLITERATION


/obj/item/storage/bible/fart_act(mob/living/user)
	if(QDELETED(user) || user.stat == DEAD)
		return FALSE
	user.visible_message(span_danger("[user] farts on \the [name]!"))
	user.visible_message(span_userdanger("A mysterious force smites [user]!"))
	user.suiciding = TRUE
	do_sparks(3, 1, user)
	user.gib()
	return TRUE // Don't run the fart emote


/obj/item/storage/bible/booze
	name = "bible"
	desc = "To be applied to the head repeatedly."
	icon_state ="bible"

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
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return .

	god_forgive()

	if(!user.mind || !user.mind.isholy)
		to_chat(user, span_warning("The book sizzles in your hands."))
		add_attack_logs(user, target, "Hit themselves with [src]")
		user.take_organ_damage(0, 10)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, span_warning("The [src] slips out of your hand and hits your head."))
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
			span_danger("[user] smacks [target]'s lifeless corpse with [src]."),
			span_warning("You smacks [target]'s lifeless corpse."),
		)
		playsound(loc, "punch", 25, TRUE, -1)
		return .|ATTACK_CHAIN_SUCCESS

	if(!ishuman(target))
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(prob(60))
		bless(target)
		target.visible_message(
			span_danger("[user] heals [target == user ? "[user.p_them()]self" : "[target]"] with the power of [deity_name]!"),
			span_danger("May the power of [deity_name] compel you to be healed!"),
		)
		playsound(loc, "punch", 25, TRUE, -1)
	else
		if(!istype(target.head, /obj/item/clothing/head/helmet))
			target.apply_damage(10, BRAIN)
			to_chat(target, span_warning("You feel dumber."))
		target.visible_message(
			span_danger("[user] beats [target == user ? "[user.p_them()]self" : "[target]"] over the head with [src]!"),
			span_danger("You beat [target == user ? "yourself" : "[target]"] over the head!"),
		)
		playsound(src.loc, "punch", 25, TRUE, -1)

	if(target == user)
		god_punishment++

	if(god_punishment == 5)
		to_chat(user, span_danger("<h1>Вы злоупотребляете покровительством бога [deity_name], остановитесь и подумайте.</h1>"))
	else if(god_punishment > 5) //lets apply punishment AFTER heal
		user.electrocute_act(5, "молнии", flags = SHOCK_NOGLOVES)
		user.apply_damage(65, BURN)
		user.Knockdown(10 SECONDS)
		to_chat(user, span_userdanger("Вы злоупотребили волей бога и были за это наказаны!"))


/obj/item/storage/bible/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(isfloorturf(target))
		to_chat(user, "<span class='notice'>You hit the floor with the bible.</span>")
		if(user.mind?.isholy)
			for(var/obj/O in target)
				O.cult_reveal()
	if(istype(target, /obj/machinery/door/airlock))
		to_chat(user, "<span class='notice'>You hit the airlock with the bible.</span>")
		if(user.mind?.isholy)
			var/obj/airlock = target
			airlock.cult_reveal()

	if(user.mind?.isholy && target.reagents)
		add_holy_water(user, target)

/obj/item/storage/bible/proc/add_holy_water(mob/user, atom/target)
	if(target.reagents.has_reagent("water")) //blesses all the water in the holder
		to_chat(user, "<span class='notice'>You bless [target].</span>")
		var/water2holy = target.reagents.get_reagent_amount("water")
		target.reagents.del_reagent("water")
		target.reagents.add_reagent("holywater", water2holy)

	if(target.reagents.has_reagent("unholywater")) //yeah yeah, copy pasted code - sue me
		to_chat(user, "<span class='notice'>You purify [target].</span>")
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
		var/image/bible_image = image('icons/obj/storage.dmi', icon_state = icons["state"])
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
