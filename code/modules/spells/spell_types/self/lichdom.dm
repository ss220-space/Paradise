/datum/action/cooldown/spell/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing. So long as both your body and the item remain intact and on the same plane you can revive from death, though the time between reincarnations grows steadily with use."
	school = SCHOOL_NECROMANCY
	cooldown_time = 1 SECONDS
	check_flags = NONE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_NO_CENTCOM | SPELL_REQUIRES_HUMAN
	invocation = "NECREM IMORTIUM!"
	invocation_type = INVOCATION_SHOUT
	spell_max_level = 0 //cannot be improved
	var/phylactery_made = FALSE
	var/obj/item/marked_item
	var/mob/living/current_body
	var/resurrections = 0
	var/existence_stops_round_end = FALSE
	var/focusing = FALSE

	button_icon_state = "skeleton"

/datum/action/cooldown/spell/lichdom/Destroy()
	marked_item = null
	current_body = null
	for(var/datum/mind/w_mind in SSticker.mode.wizards) //Make sure no other bones are about
		for(var/datum/action/cooldown/spell/lichdom/spell in w_mind.spell_list)
			if(spell != src && spell.existence_stops_round_end)
				return ..()

	if(existence_stops_round_end)
		CONFIG_SET(flag/continuous_rounds, FALSE)

	return ..()

/datum/action/cooldown/spell/lichdom/can_cast_spell(feedback)
	if(focusing)
		return FALSE

	if(phylactery_made && owner.stat != DEAD)
		return FALSE
	return ..()

/datum/action/cooldown/spell/lichdom/cast(atom/cast_on)
	. = ..()
	if(!ishuman(cast_on))
		return
	var/mob/living/carbon/human/user = cast_on

	if(phylactery_made) //Death is not my end!
		if(!user.stat)
			to_chat(user, span_notice("You aren't dead enough to revive!"))	//Usually a good problem to have
			ResetCooldown()
			return

		if(QDELETED(marked_item)) //Wait nevermind
			to_chat(user, span_warning("Your phylactery is gone!"))
			return

		var/turf/user_turf = get_turf(user)
		var/turf/item_turf = get_turf(marked_item)

		if(user_turf.z != item_turf.z)
			to_chat(user, span_warning("Your phylactery is out of range!"))
			return

		var/mob/living/carbon/human/lich = new(item_turf)

		lich.real_name = user.mind.name
		lich.set_species(/datum/species/skeleton) // Wizard variant
		user.mind.transfer_to(lich)
		to_chat(lich, span_warning("Your bones clatter and shutter as they're pulled back into this world!"))
		cooldown_time += 1 MINUTES
		ResetCooldown()

		var/mob/old_body = current_body
		var/turf/body_turf = get_turf(old_body)
		current_body = lich
		var/stun_time = (1 + resurrections) STATUS_EFFECT_CONSTANT
		lich.Weaken(stun_time)
		resurrections++
		equip_lich(lich)

		if(old_body?.loc)
			if(iscarbon(old_body))
				for(var/obj/item/item in old_body.contents)
					old_body.drop_item_ground(item)

			var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
			if(wheres_wizdo)
				old_body.visible_message(span_warning("Suddenly [old_body.name]'s corpse falls to pieces! You see a strange energy rise from the remains, and speed off towards the [wheres_wizdo]!"))
				body_turf.Beam(item_turf,icon_state="lichbeam",icon='icons/effects/effects.dmi',time=stun_time,maxdistance=INFINITY)

			old_body.dust()

		return

	//linking item to the spell
	var/obj/item/item = user.get_active_hand()
	if(!item)
		to_chat(user, span_warning("You must hold an item you wish to make your phylactery..."))
		return

	if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP))
		to_chat(user, span_warning("[item.name] can not be used for the ritual..."))
		return

	to_chat(user, span_warning("You begin to focus your very being into [item]..."))

	focusing = TRUE
	if(!do_after(user, 5 SECONDS, user))
		focusing = FALSE
		return
	focusing = FALSE

	if(QDELETED(item) || item.loc != user) //I changed my mind I don't want to put my soul in a cheeseburger!
		to_chat(user, span_warning("Your soul snaps back to your body since [item] is out of reach!"))
		return

	if(!CONFIG_GET(flag/continuous_rounds))
		existence_stops_round_end = TRUE
		CONFIG_SET(flag/continuous_rounds, TRUE)

	name = "RISE!"
	desc = "Rise from the dead! You will reform at the location of your phylactery and your old body will crumble away."
	build_all_button_icons()

	cooldown_time = 3 MINUTES
	ResetCooldown()
	phylactery_made = TRUE

	current_body = user.mind.current
	marked_item = item
	marked_item.name = "Ensouled [marked_item.name]"
	marked_item.desc = "A terrible aura surrounds this item, its very existence is offensive to life itself..."
	marked_item.color = "#003300"
	to_chat(user, span_userdanger("With a hideous feeling of emptiness you watch in horrified fascination as skin sloughs off bone! Blood boils, nerves disintegrate, eyes boil in their sockets! As your organs crumble to dust in your fleshless chest you come to terms with your choice. You're a lich!"))

	if(!ishuman(user))
		return

	create_lich(user)

/datum/action/cooldown/spell/lichdom/proc/create_lich(mob/living/carbon/human/user)
	user.set_species(/datum/species/skeleton)
	user.drop_item_ground(user.wear_suit)
	user.drop_item_ground(user.head)
	user.drop_item_ground(user.shoes)
	user.drop_item_ground(user.head)
	equip_lich(user)

/datum/action/cooldown/spell/lichdom/proc/equip_lich(mob/living/carbon/human/user)
	user.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(user), ITEM_SLOT_CLOTH_OUTER)
	user.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(user), ITEM_SLOT_HEAD)
	user.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(user), ITEM_SLOT_FEET)
	user.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(user), ITEM_SLOT_CLOTH_INNER)

