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
	var/time = 3
	var/spell_action = FALSE // If we item needs an action button

/datum/spell_enchant/New(name, enchantment, req_amount = 0, time = 3, spell_action = FALSE)
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
		if(I.enchant_type == CASTING_SPELL)
			to_chat(owner, "<span class='warning'> You can't enchant [I] right now while spell is working!</span>")
			return
		if(I.enchant_type)
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

		if(do_after(owner, ES.time SECONDS, target = owner))
			I.enchant_type = ES.enchantment
			if(ES.spell_action)
				new /datum/action/item_action/activate/once(I)
				owner.update_action_buttons()
			I.update_icon()
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

/datum/action/innate/clockwork/hand_spell/equipment
	name = "Summon Equipment"
	desc = "Allows you to empower your hand to summon combat gear onto a cultist you touch, including cult armor, a cult bola, and a cult sword."
	button_icon_state = "equip"
	magic_path = /obj/item/melee/clock_magic/armor

/datum/action/innate/clockwork/hand_spell/construction
	name = "Twisted Construction"
	desc = "Empowers your hand to corrupt certain metalic objects.<br><u>Converts:</u><br>Plasteel into runed metal<br>50 metal into a construct shell<br>Cyborg shells into construct shells<br>Airlocks into brittle runed airlocks after a delay (harm intent)"
	button_icon_state = "transmute"
	magic_path = /obj/item/melee/clock_magic/construction

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
	return ..()

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
	return ..()

/obj/item/melee/clock_magic/armor
	name = "Arming Aura"
	desc = "Will equip simplish robe on a clocker."
	color = "#33cc33" // green

/obj/item/melee/clock_magic/armor/afterattack(atom/target, mob/living/carbon/user, proximity)
	if(iscarbon(target) && proximity)
		uses--
		var/mob/living/carbon/C = target
		var/armour = C.equip_to_slot_or_del(new /obj/item/clothing/suit/hooded/clockrobe(user), slot_wear_suit)
		if(C == user)
			qdel(src) //Clears the hands
		C.visible_message("<span class='warning'>Otherworldly [armour ? "armour" : "equipment"] suddenly appears on [C]!</span>")

/obj/item/melee/clock_magic/construction
	name = "Twisting Aura"
	desc = "Corrupts certain metalic objects on contact."
	invocation = "Ethra p'ni dedol!"
	color = "#000000" // black
	var/channeling = FALSE

/obj/item/melee/blood_magic/construction/examine(mob/user)
	. = ..()
	. += {"<u>A sinister spell used to convert:</u>\n
	Plasteel into runed metal\n
	[METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal into a construct shell\n
	Airlocks into brittle runed airlocks after a delay (harm intent)"}

/obj/item/melee/blood_magic/construction/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		if(channeling)
			to_chat(user, "<span class='cultitalic'>You are already invoking twisted construction!</span>")
			return
		var/turf/T = get_turf(target)

		//Metal to construct shell
		if(istype(target, /obj/item/stack/sheet/metal))
			var/obj/item/stack/sheet/candidate = target
			if(candidate.use(METAL_TO_CONSTRUCT_SHELL_CONVERSION))
				uses--
				to_chat(user, "<span class='warning'>A dark cloud emanates from your hand and swirls around the metal, twisting it into a construct shell!</span>")
				new /obj/structure/constructshell(T)
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
			else
				to_chat(user, "<span class='warning'>You need [METAL_TO_CONSTRUCT_SHELL_CONVERSION] metal to produce a construct shell!</span>")
				return

		//Plasteel to runed metal
		else if(istype(target, /obj/item/stack/sheet/plasteel))
			var/obj/item/stack/sheet/plasteel/candidate = target
			var/quantity = candidate.amount
			if(candidate.use(quantity))
				uses--
				new /obj/item/stack/sheet/runed_metal(T, quantity)
				to_chat(user, "<span class='warning'>A dark cloud emanates from you hand and swirls around the plasteel, transforming it into runed metal!</span>")
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)

		//Airlock to cult airlock
		else if(istype(target, /obj/machinery/door/airlock) && !istype(target, /obj/machinery/door/airlock/cult))
			channeling = TRUE
			playsound(T, 'sound/machines/airlockforced.ogg', 50, TRUE)
			do_sparks(5, TRUE, target)
			if(do_after(user, 50, target = target))
				target.narsie_act(TRUE)
				uses--
				user.visible_message("<span class='warning'>Black ribbons suddenly emanate from [user]'s hand and cling to the airlock - twisting and corrupting it!</span>")
				playsound(user, 'sound/magic/cult_spell.ogg', 25, TRUE)
				channeling = FALSE
			else
				channeling = FALSE
				return
		else
			to_chat(user, "<span class='warning'>The spell will not work on [target]!</span>")
			return
		..()
