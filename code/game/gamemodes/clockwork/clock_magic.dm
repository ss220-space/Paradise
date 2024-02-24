/datum/action/innate/clockwork/clock_magic //Clockwork magic casting.
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. The magic you will cast depends on what's in your hand."
	var/datum/action/innate/clockwork/midas_spell/midas_spell = null
	var/channeling = FALSE

/datum/action/innate/clockwork/clock_magic/Remove()
	QDEL_NULL(midas_spell)
	. = ..()

// Datum for enchanting item. The name, amount of power, time needed, spell action itself from item.
/datum/spell_enchant
	var/name = "Spell Item Enchanter"
	var/enchantment = NO_SPELL
	var/req_amount = 0 //this var is scraped (for now)
	var/time = 3
	var/spell_action = FALSE // If we item needs an action button

/datum/spell_enchant/New(name, enchantment, req_amount = 0, time = 3, spell_action = FALSE)
	src.name = name
	src.enchantment = enchantment
	src.req_amount = req_amount
	src.time = time
	src.spell_action = spell_action

// The list clockwork_items you can find in defines/clockwork

/* Main proc on enchanting items/ making spell on hands
 *
 * First it gets an item. Else spell midas.
 * Then check for spell_enchant component to enchant. Else spell midas.
 */
/datum/action/innate/clockwork/clock_magic/Activate()
	. = ..()
	var/obj/item/item = owner.get_active_hand()
	if(istype(item, /obj/item/gripper)) // cogs gripper
		var/obj/item/gripper/G = item
		item = G.gripped_item
	// If we having something in hand. Check if it can be enchanted. Else skip.
	if(!item) // Maybe we want to enchant our armor
		var/list/items = list()
		var/list/duplicates = list()
		var/list/possible_items = list()
		var/list/possible_icons = list()
		for(var/obj/item/I in owner.contents)
			if(istype(I, /obj/item/gripper)) // cogs gripper
				var/obj/item/gripper/G = I
				I = G.gripped_item
			var/datum/component/spell_enchant/SE = I.GetComponent(/datum/component/spell_enchant)
			if(!SE)
				continue
			if(I.name in items) // in case there are doubles clockslabs
				duplicates[I.name]++
				possible_items["[I.name] ([duplicates[I.name]])"] = I
				var/image/item_image = image(icon = I.icon, icon_state = I.icon_state)
				if(SE.current_enchant > NO_SPELL) //cause casting spell is -1
					item_image.add_overlay("[initial(I.icon_state)]_overlay_[SE.current_enchant]")
				possible_icons += list("[I.name] ([duplicates[I.name]])" = item_image)
			else
				items.Add(I.name)
				duplicates[I.name] = 1
				possible_items[I.name] = I
				var/image/item_image = image(icon = I.icon, icon_state = I.icon_state)
				if(SE.current_enchant > NO_SPELL) //cause casting spell is -1
					item_image.add_overlay("[initial(I.icon_state)]_overlay_[SE.current_enchant]")
				possible_icons += list(I.name = item_image)
		if(ishuman(owner))
			possible_items += "Spell hand"
			possible_icons += list("Spell hand" = image(icon = 'icons/mob/actions/actions_clockwork.dmi', icon_state = "hand"))
		var/item_to_enchant
		if(possible_items.len >= 2)
			item_to_enchant = show_radial_menu(owner, owner, possible_icons, require_near = TRUE)
		else if(possible_items.len == 1)
			item_to_enchant = possible_items[1]
		else
			item_to_enchant = null
		if(!item_to_enchant)
			if(possible_items.len) // we had a choice but declined
				return
			item_to_enchant = null
		if(item_to_enchant == "Spell hand")
			item_to_enchant = null
		else
			item = possible_items[item_to_enchant]
			if(!(item in owner.contents))
				var/obj/item/gripper/G = locate() in owner
				if(item != G?.gripped_item)
					return
		if(QDELETED(src) || owner.incapacitated())
			return
	var/datum/component/spell_enchant/enchanting = item?.GetComponent(/datum/component/spell_enchant)
	if(enchanting)
		enchanting.enchant(owner)
		return
	// If it's empty or not an item we can enchant. Making a spell on hand.
	if(!iscarbon(owner)) //This is to throw away non carbon who doesn't have hands, but silicon modules.
		to_chat(owner, span_clockitalic("You need an item that you can enchant!"))
		return
	if(midas_spell)
		to_chat(owner, span_warning("You already prepared midas touch!"))
		return
	if(QDELETED(src) || owner.incapacitated())
		return

	if(channeling)
		to_chat(owner, span_warning("You are already invoking clock magic!"))
		return
	channeling = TRUE
	to_chat(owner, span_clockitalic("You start to concentrate on your power to seal the magic in your hand."))

	if(do_after(owner, 50, target = owner))
		midas_spell = new /datum/action/innate/clockwork/midas_spell(owner)
		midas_spell.Grant(owner, src)
		to_chat(owner, span_clock("You feel the power flows in your hand, you have prepared a [midas_spell.name] invocation!"))
	channeling = FALSE

/// Midas spell. Activating give you a Midas Touch in your hand(if mob has them)
/datum/action/innate/clockwork/midas_spell
	name = "Midas Touch"
	desc = "Empowers your hand to cover metalic objects into brass.<br><u>Converts:</u><br>Plasteel and metal into brass metal<br>Brass metal into integration cog or clockwork slab<br>Cyborgs or AI into Ratvar's servants after a short delay"
	button_icon_state = "midas_touch"
	var/obj/item/melee/midas_touch/midas
	var/datum/action/innate/clockwork/clock_magic/source_magic
	var/used = FALSE

/datum/action/innate/clockwork/midas_spell/Grant(mob/living/owner, datum/action/innate/clockwork/midas_spell/SM)
	source_magic = SM
	return ..()

/datum/action/innate/clockwork/midas_spell/Remove()
	if(source_magic)
		source_magic.midas_spell = null
	if(midas)
		QDEL_NULL(midas)
	return ..()

/datum/action/innate/clockwork/midas_spell/IsAvailable()
	if(!isclocker(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockwork/midas_spell/Activate()
	if(!midas) // If you don't already have the spell active
		midas = new /obj/item/melee/midas_touch(owner, src)
		if(!owner.put_in_hands(midas))
			QDEL_NULL(midas)
			to_chat(owner, span_warning("You have no empty hand for invoking clockwork magic!"))
			return
		to_chat(owner, span_clockitalic("Your wounds glow as you invoke the [name]."))
	else // If the spell is active, and you clicked on the button for it
		QDEL_NULL(midas)

// The "magic hand" items
/obj/item/melee/midas_touch
	name = "Midas Aura"
	desc = "A dripping brass from hand charged to twist metal."
	color = "#FFDF00"
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

	var/datum/action/innate/clockwork/midas_spell/source
	var/channeling = FALSE

/obj/item/melee/midas_touch/New(loc, spell)
	source = spell
	..()

/obj/item/melee/midas_touch/Destroy()
	if(!QDELETED(source))
		source.midas = null
		if(source.used)
			QDEL_NULL(source)
		else
	return ..()


/obj/item/melee/midas_touch/examine(mob/user)
	. = ..()
	. += "<u>A sinister spell used to convert:</u>"
	. += "1 Plasteel into brass"
	. += "[CLOCK_METAL_TO_BRASS] metal into brass"
	. += "Robots into cult"

/obj/item/melee/midas_touch/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(channeling)
		to_chat(user, span_clockitalic("You are already working on something!"))
		return
	var/turf/turf_target = get_turf(target)

	// Metal
	if(istype(target, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/candidate = target
		if(candidate.amount < CLOCK_METAL_TO_BRASS)
			to_chat(user, span_warning("You need [CLOCK_METAL_TO_BRASS] metal to produce a single brass!"))
			return
		var/quantity = (candidate.amount - (candidate.amount % CLOCK_METAL_TO_BRASS)) / CLOCK_METAL_TO_BRASS
		if(candidate.use(quantity * CLOCK_METAL_TO_BRASS))
			var/obj/item/stack/sheet/brass/B = new(turf_target, quantity)
			user.put_in_hands(B)
			to_chat(user, span_warning("Your hand starts to shine very bright onto the metal, transforming it into brass!"))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
		else
			to_chat(user, span_warning("You need [CLOCK_METAL_TO_BRASS] metal to produce a single brass!"))
			return

	// Plasteel
	else if(istype(target, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/candidate = target
		var/quantity = candidate.amount
		if(candidate.use(quantity))
			var/obj/item/stack/sheet/brass/B = new(turf_target, quantity)
			user.put_in_hands(B)
			to_chat(user, span_warning("Your hand starts to shine very bright onto the plasteel, transforming it into brass!"))
			playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	// Brass
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
		to_chat(user, span_warning("With you magic hand you re-materialize brass into [O.name]!"))
		playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

	// Cyborgs
	else if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/borg = target
		if(!isclocker(borg))
			if(borg.stat == DEAD)
				to_chat(user, span_warning("[borg] is useless in his current state! Try restoring it in order to convert."))
				return
			channeling = TRUE
			user.visible_message(span_warning("A [user]'s hand touches [borg] and rapidly turns all his metal into cogs and brass gears!"))
			playsound(get_turf(src), 'sound/machines/airlockforced.ogg', 80, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 9 SECONDS, target = borg))
				borg.emp_act(EMP_HEAVY)
				borg.ratvar_act(weak = TRUE)
				SSticker?.score?.save_silicon_laws(borg, user, "Ratvar act", log_all_laws = TRUE)
			channeling = FALSE
			return

	// AI
	else if(istype(target, /mob/living/silicon/ai))
		var/mob/living/silicon/ai/ai = target
		if(!isclocker(ai))
			if(ai.stat == DEAD)
				to_chat(user, span_warning("[ai] is useless in his current state! Try restoring it in order to convert."))
				return
			channeling = TRUE
			user.visible_message(span_warning("A [user]'s hand touches [ai] as he starts to manipulate every piece of technology inside!"))
			playsound(get_turf(src), 'sound/machines/airlockforced.ogg', 80, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 9 SECONDS, target = ai))
				ai.ratvar_act()
				SSticker?.score?.save_silicon_laws(ai, user, "Ratvar act", log_all_laws = TRUE)
			channeling = FALSE
			return
	else
		to_chat(user, span_warning("The spell will not work on [target]!"))
		return
	user.whisper("Rqu-en qy'qby!")
	source.used = TRUE
	qdel(src)
