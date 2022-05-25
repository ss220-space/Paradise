/datum/action/innate/clockwork/clock_magic //Clockwork magic casting.
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. The magic you will cast depends on what's in your hand."
	var/datum/action/innate/clockwork/hand_spell/construction/midas_spell = null
	var/channeling = FALSE

//get_active_hand it gets the thing in active one
//put_in_hands it PUTS but i think it won't be needed

/datum/action/innate/clockwork/clock_magic/Remove()
	QDEL_NULL(midas_spell)
	. = ..()

// Datum for enchanting item. The name, amount of power, time needed, spell action itself from item.
/datum/spell_enchant
	var/name = "Spell Item Enchanter"
	var/enchantment = NO_SPELL
	var/req_amount = 0
	var/time = 3
	var/spell_action = FALSE // If we item needs an action button

/datum/spell_enchant/New(name, enchantment, req_amount = 0, time = 3, spell_action = FALSE)
	src.name = name
	src.enchantment = enchantment
	src.req_amount = req_amount
	src.time = time
	src.spell_action = spell_action

// The list clockwork_items you can find in defines/clockwork

/// Main proc on enchanting items/ making spell on hands
/datum/action/innate/clockwork/clock_magic/Activate()
	. = ..()
	var/obj/item/item = owner.get_active_hand()
	if(istype(item, /obj/item/gripper))
		var/obj/item/gripper/G = item
		item = G.gripped_item
	// If we having something in hand. Check if it can be enchanted. Else skip.
	var/can_enchanted = length(item?.enchants)
	if(can_enchanted) // it just works
		if(item.enchant_type == CASTING_SPELL)
			to_chat(owner, "<span class='warning'> You can't enchant [item] right now while spell is working!</span>")
			return
		if(item.enchant_type)
			to_chat(owner, "<span class='clockitalic'>There is already prepared spell in [item]! If you choose another spell it will overwrite old one!</span>")
		var/entered_spell_name
		var/list/possible_enchants = list()
		for(var/datum/spell_enchant/S in item.enchants)
			if(S.enchantment == item.enchant_type)
				continue
			possible_enchants[S.name] = S
		entered_spell_name = input(owner, "Pick a clock spell to prepare...", "Spell Choices") as null|anything in possible_enchants

		var/datum/spell_enchant/spell_enchant = possible_enchants[entered_spell_name]
		if(QDELETED(src) || owner.incapacitated() || !spell_enchant)
			return
		if(istype(item, /obj/item/gripper))
			var/obj/item/gripper/G = item
			if(item != G.gripped_item)
				return
		else
			if(item != owner.get_active_hand())
				return
		/*
		if(GLOB.clockwork_power < spell_enchant.req_amount)
			to_chat(owner, "<span class='warning'>There's no power left to use! Make some you fool!</span>")
			return
		adjust_clockwork_power(-spell_enchant.req_amount)
		*/

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in [item].</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		if(do_after(owner, spell_enchant.time SECONDS, target = owner))
			item.enchant_type = spell_enchant.enchantment
			if(spell_enchant.spell_action)
				new /datum/action/item_action/activate/once(item)
				owner.update_action_buttons()
			item.update_icon()
			to_chat(owner, "<span class='clock'>You sealed the power in [item], you have prepared a [spell_enchant.name] invocation!</span>")
		//else
		//	adjust_clockwork_power(spell_enchant.req_amount)

		channeling = FALSE
	// If it's empty or not an item we can enchant. Making a spell on hand.
	else
		if(!iscarbon(owner)) //This is to throw away non carbon who doesn't have hands, but silicon modules.
			to_chat(owner, "<span class='clockitalic'>You need an item that you can enchant!</span>")
			return
		if(midas_spell)
			to_chat(owner, "<span class='clockitalic'>You already prepared midas touch!</b></span>")
			return
		if(QDELETED(src) || owner.incapacitated())
			return

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in your hand.</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		if(do_after(owner, 50, target = owner))
			midas_spell = new /datum/action/innate/clockwork/hand_spell/construction(owner)
			midas_spell.Grant(owner, src)
			to_chat(owner, "<span class='clock'>You feel the power flows in your hand, you have prepared a [midas_spell.name] invocation!</span>")
		channeling = FALSE


// This is spells for hands only.
/datum/action/innate/clockwork/hand_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Clockwork Magic"
	button_icon_state = "telerune"
	desc = "Let the Gears Power."
	var/magic_path = null
	var/obj/item/melee/clock_magic/hand_magic
	var/datum/action/innate/clockwork/clock_magic/source_magic
	var/used = FALSE

/datum/action/innate/clockwork/hand_spell/Grant(mob/living/owner, datum/action/innate/clockwork/hand_spell/SM)
	source_magic = SM
	return ..()

/datum/action/innate/clockwork/hand_spell/Remove()
	if(source_magic)
		source_magic.midas_spell = null
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	return ..()

/datum/action/innate/clockwork/hand_spell/IsAvailable()
	if(!isclocker(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockwork/hand_spell/Activate()
	if(!magic_path) // If this spell flows from the hand
		return
	if(!hand_magic) // If you don't already have the spell active
		hand_magic = new magic_path(owner, src)
		if(!owner.put_in_hands(hand_magic))
			QDEL_NULL(hand_magic)
			to_chat(owner, "<span class='warning'>You have no empty hand for invoking clockwork magic!</span>")
			return
		to_chat(owner, "<span class='cultitalic'>Your wounds glow as you invoke the [name].</span>")
	else // If the spell is active, and you clicked on the button for it
		QDEL_NULL(hand_magic)

//the spell list

/datum/action/innate/clockwork/hand_spell/construction
	name = "Midas Touch"
	desc = "Empowers your hand to cover metalic objects into brass.<br><u>Converts:</u><br>Plasteel and metal into brass metal<br>Brass metal into integration cog or clockwork slab<br>Airlocks into brightish airlocks after a delay (harm intent)"
	button_icon_state = "midas_touch"
	magic_path = /obj/item/melee/clock_magic/construction

// The "magic hand" items
/obj/item/melee/clock_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/clockwork.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "clocked_hand"
	item_state = "clocked_hand"
	flags = ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0

	var/datum/action/innate/clockwork/hand_spell/source

/obj/item/melee/clock_magic/New(loc, spell)
	source = spell
	..()

/obj/item/melee/clock_magic/Destroy()
	if(!QDELETED(source))
		source.hand_magic = null
		if(source.used)
			qdel(source)
			source = null
		else
	return ..()

//The spell effects

/obj/item/melee/clock_magic/construction
	name = "Midas Aura"
	desc = "A dripping brass from hand charged to twist metal."
	color = "#FFDF00"
	var/channeling = FALSE

/obj/item/melee/clock_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into runed metal\n
	[CLOCK_METAL_TO_BRASS] metal into a brass\n
	Robots into cult"}

/obj/item/melee/clock_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(channeling)
		to_chat(user, "<span class='clockitalic'>You are already invoking midas touch!</span>")
		return

	//Metal to brass metal
	if(istype(target, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/candidate = target
		var/quantity = candidate.amount
		if(candidate.use(quantity*CLOCK_METAL_TO_BRASS))
			new /obj/item/stack/sheet/brass(get_turf(target), quantity*CLOCK_METAL_TO_BRASS)
			to_chat(user, "<span class='warning'>Your hand starts to shine very bright onto the metal, transforming it into brass!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
		else
			to_chat(user, "<span class='warning'>You need [CLOCK_METAL_TO_BRASS] metal to produce a single brass!</span>")
			return

	//Plasteel to brass metal
	else if(istype(target, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/candidate = target
		var/quantity = candidate.amount
		if(candidate.use(quantity))
			new /obj/item/stack/sheet/brass(get_turf(target), quantity)
			to_chat(user, "<span class='warning'>Your hand starts to shine very bright onto the plasteel, transforming it into brass!</span>")
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	else if(istype(target, /obj/item/stack/sheet/brass))
		var/obj/item/stack/sheet/brass/candidate = target
		var/list/choosable_items = list("Clock Slab" = /obj/item/clockwork/clockslab, "Integration Cog" = /obj/item/clockwork/integration_cog)
		var/choice = show_radial_menu(user, src, choosable_items, require_near = TRUE)
		var/picked_type = choosable_items[choice]
		if(QDELETED(src) || !picked_type || !target.Adjacent(user) || user.incapacitated())
			return
		var/obj/O = new picked_type
		if(!user.put_in_hands(O))
			O.forceMove(get_turf(src))
		candidate.use(1)
		to_chat(user, "<span class='warning'>With you magic hand you re-materialize brass into [O.name]!</span>")
		playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	else if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/candidate = target
		if(candidate.mmi || candidate.ghost_can_reenter() || !isclocker(candidate))
			channeling = TRUE
			user.visible_message("<span class='warning'>A [user]'s hand touches [candidate] and rapidly turns all his metal into cogs and brass gears!</span>")
			playsound(get_turf(src), 'sound/machines/airlockforced.ogg', 80, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 90, target = candidate))
				candidate.emp_act(EMP_HEAVY)
				candidate.ratvar_act(weak = TRUE)
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>Your hand finalizes [candidate] - twisting it into a marauder!</span>")
			new /obj/item/clockwork/marauder(get_turf(src))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
			qdel(candidate)
	else
		to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
		return
	user.whisper("Rqu-en qy'qby!")
	source.used = TRUE
	qdel(src)
