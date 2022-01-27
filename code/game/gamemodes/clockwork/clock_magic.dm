/datum/action/innate/clockwork/clock_magic //Clockwork magic casting.
	name = "Prepare Clockwork Magic"
	button_icon_state = "carve"
	desc = "Prepare clockwork magic powering yourself from Ratvar's pool of power. The magic you will cast depends on what's in your hand."
	//The spells on his hands!
	var/list/spells = list()
	var/channeling = FALSE

//get_active_hand it gets the thing in active one
//put_in_hands it PUTS but i think it won't be needed

/datum/action/innate/clockwork/clock_magic/Remove()
	for(var/X in spells)
		qdel(X)
	..()

// Datum for enchanting item. The name, amount of power, time needed, spell action itself from item.
/datum/spell_enchant
	var/name = "Spell Item Enchanter"
	var/enchantment = NO_SPELL
	var/req_amount = 0
	var/time = 10
	var/spell_action = FALSE // If we item needs an action button

/datum/spell_enchant/New(name, enchantment, req_amount = 0, time = 10, spell_action = FALSE)
	src.name = name
	src.enchantment = enchantment
	src.req_amount = req_amount
	src.time = time
	src.spell_action = spell_action

// The list clockwork_items you can find in defines/clockwork

/datum/action/innate/clockwork/clock_magic/Activate()
	. = ..()
	var/obj/item/I = owner.get_active_hand()
	// If we having something in hand. Check if it can be enchanted. Else skip.
	var/can_enchanted = FALSE
	if(I)
		can_enchanted = length(I.enchants)
	if(can_enchanted) // it just works
		if(I.enchanted)
			to_chat(owner, "<span class='clockitalic'>There is already prepared spell in [I]! If you choose another spell it will overwrite old one!</span>")
		var/entered_spell_name
		var/list/possible_enchants = list()
		for(var/datum/spell_enchant/S in I.enchants)
			if(S.enchantment == I.enchant_type)
				continue
			possible_enchants[S.name] = S
		entered_spell_name = input(owner, "Pick a clock spell to prepare...", "Spell Choices") as null|anything in possible_enchants

		var/datum/spell_enchant/ES = possible_enchants[entered_spell_name]
		if(QDELETED(src) || owner.incapacitated() || !ES || I != owner.get_active_hand())
			return

		if(GLOB.clockwork_power < ES.req_amount)
			to_chat(owner, "<span class='warning'>There's no power left to use! Make some you fool!</span>")
			return

		adjust_clockwork_power(-ES.req_amount)

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in [I].</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		if(do_after(owner, ES.time*10, target = owner))
			I.enchant_type = ES.enchantment
			I.enchanted = TRUE
			if(ES.spell_action)
				new /datum/action/item_action/activate/once(I)
			to_chat(owner, "<span class='clock'>You sealed the power in [I], you have prepared a [ES.name] invocation!</span>")
		else
			adjust_clockwork_power(ES.req_amount)

		channeling = FALSE
	// If it's empty or not an item we can enchant. Making a spell on hand.
	else
		var/max_spells = CLOCK_MAX_HANDSPELLS
		if(length(spells) >= max_spells)
			to_chat(owner, "<span class='clockitalic'>You cannot store more than [max_spells] spell\s. <b>Pick a spell to remove.</b></span>")
			remove_spell("You cannot store more than [max_spells] spell\s, pick a spell to remove.")
			return
		var/entered_spell_name
		var/datum/action/innate/clockwork/hand_spell/BS
		var/list/possible_spells = list()

		for(var/S in subtypesof(/datum/action/innate/clockwork/hand_spell))
			var/datum/action/innate/clockwork/hand_spell/J = S
			var/clock_name = initial(J.name)
			possible_spells[clock_name] = J
		if(length(spells))
			possible_spells += "(REMOVE SPELL)"
		entered_spell_name = input(owner, "Pick a clock spell to prepare...", "Spell Choices") as null|anything in possible_spells
		if(entered_spell_name == "(REMOVE SPELL)")
			remove_spell()
			return
		BS = possible_spells[entered_spell_name]
		if(QDELETED(src) || owner.incapacitated() || !BS || (length(spells) >= max_spells))
			return

		if(!channeling)
			channeling = TRUE
			to_chat(owner, "<span class='clockitalic'>You start to concentrate on your power to seal the magic in your hand.</span>")
		else
			to_chat(owner, "<span class='warning'>You are already invoking clock magic!</span>")
			return

		if(do_after(owner, 50, target = owner))
			var/datum/action/innate/clockwork/hand_spell/new_spell = new BS(owner)
			spells += new_spell
			new_spell.Grant(owner, src)
			to_chat(owner, "<span class='clock'>You feel the power flows in your hand, you have prepared a [new_spell.name] invocation!</span>")
		channeling = FALSE

/datum/action/innate/clockwork/clock_magic/proc/remove_spell(message = "Pick a spell to remove.")
	var/nullify_spell = input(owner, message, "Current Spells") as null|anything in spells
	if(nullify_spell)
		qdel(nullify_spell)


// This is spells for hands only.
/datum/action/innate/clockwork/hand_spell //The next generation of talismans, handles storage/creation of blood magic
	name = "Clockwork Magic"
	button_icon_state = "telerune"
	desc = "Let the Gears Power."
	var/charges = 1
	var/magic_path = null
	var/obj/item/melee/clock_magic/hand_magic
	var/datum/action/innate/clockwork/clock_magic/all_magic
	var/base_desc //To allow for updating tooltips
	var/invocation = "Hoi there something's wrong!"

/datum/action/innate/clockwork/hand_spell/Grant(mob/living/owner, datum/action/innate/clockwork/hand_spell/BM)
	base_desc = desc
	desc += "<br><b><u>Has [charges] use\s remaining</u></b>."
	all_magic = BM
	button.ordered = FALSE
	..()

/datum/action/innate/clockwork/hand_spell/Remove()
	if(all_magic)
		all_magic.spells -= src
	if(hand_magic)
		qdel(hand_magic)
		hand_magic = null
	..()

/datum/action/innate/clockwork/hand_spell/IsAvailable()
	if(!isclocker(owner) || owner.incapacitated() || !charges)
		return FALSE
	return ..()

/datum/action/innate/clockwork/hand_spell/Activate()
	if(magic_path) // If this spell flows from the hand
		if(!hand_magic) // If you don't already have the spell active
			hand_magic = new magic_path(owner, src)
			if(!owner.put_in_hands(hand_magic))
				qdel(hand_magic)
				hand_magic = null
				to_chat(owner, "<span class='warning'>You have no empty hand for invoking blood magic!</span>")
				return
			to_chat(owner, "<span class='cultitalic'>Your wounds glow as you invoke the [name].</span>")

		else // If the spell is active, and you clicked on the button for it
			qdel(hand_magic)
			hand_magic = null

//the spell list

/datum/action/innate/clockwork/hand_spell/stun
	name = "Stun"
	desc = "Empowers your hand to stun and mute a victim on contact."
	button_icon_state = "stun"
	magic_path = /obj/item/melee/clock_magic/stun

// The "magic hand" items
/obj/item/melee/clock_magic
	name = "\improper magical aura"
	desc = "A sinister looking aura that distorts the flow of reality around it."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	flags = ABSTRACT | DROPDEL

	w_class = WEIGHT_CLASS_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0

	var/invocation
	var/uses = 1
	var/datum/action/innate/clockwork/hand_spell/source

/obj/item/melee/clock_magic/New(loc, spell)
	source = spell
	uses = source.charges
	..()

/obj/item/melee/clock_magic/Destroy()
	if(!QDELETED(source))
		if(uses <= 0)
			source.hand_magic = null
			qdel(source)
			source = null
		else
			source.hand_magic = null
			source.charges = uses
			source.desc = source.base_desc
			source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
			source.UpdateButtonIcon()
	..()

/obj/item/melee/clock_magic/attack_self(mob/living/user)
	afterattack(user, user, TRUE)

/obj/item/melee/clock_magic/attack(mob/living/M, mob/living/carbon/user)
	if(!iscarbon(user) || !isclocker(user))
		uses = 0
		qdel(src)
		return
	add_attack_logs(user, M, "used a clock cult spell ([src]) on")
	M.lastattacker = user.real_name

/obj/item/melee/clock_magic/afterattack(atom/target, mob/living/carbon/user, proximity)
	. = ..()
	if(invocation)
		user.whisper(invocation)
	if(uses <= 0)
		qdel(src)
	else if(source)
		source.desc = source.base_desc
		source.desc += "<br><b><u>Has [uses] use\s remaining</u></b>."
		source.UpdateButtonIcon()


//The spell effects

//stun
/obj/item/melee/clock_magic/stun
	name = "Stunning Aura"
	desc = "Will stun and mute a victim on contact."
	color = RUNE_COLOR_RED
	invocation = "Fuu ma'jin!"

/obj/item/melee/clock_magic/stun/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(!isliving(target) || !proximity)
		return
	var/mob/living/L = target
	if(isclocker(target))
		return
	user.visible_message("<span class='warning'>[user] holds up [user.p_their()] hand, which explodes in a flash of red light!</span>", \
							"<span class='clockitalic'>You attempt to stun [L] with the spell!</span>")

	user.mob_light(LIGHT_COLOR_ORANGE, 3, _duration = 2)

	var/obj/item/N = L.null_rod_check()
	if(N)
		target.visible_message("<span class='warning'>[target]'s holy weapon absorbs the red light!</span>", \
							   "<span class='userdanger'>Your holy weapon absorbs the blinding light!</span>")
	else
		to_chat(user, "<span class='clockitalic'>In a brilliant flash of red, [L] falls to the ground!</span>")
		// These are in life cycles, so double the time that's stated.
		L.Weaken(5)
		L.Stun(5)
		L.flash_eyes(1, TRUE)
		if(issilicon(target))
			var/mob/living/silicon/S = L
			S.emp_act(EMP_HEAVY)
		else if(iscarbon(target))
			var/mob/living/carbon/C = L
			C.Silence(3)
			C.Stuttering(8)
			//C.CultSlur(10)
			C.Jitter(8)
	uses--
	..()
