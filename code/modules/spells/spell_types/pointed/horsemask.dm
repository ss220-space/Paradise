/datum/action/cooldown/spell/pointed/horsemask
	name = "Curse of the Horseman"
	desc = "This spell triggers a curse on a target, causing them to wield an unremovable horse head mask. They will speak like a horse! Any masks they are wearing will be disintegrated. This spell does not require robes."
	school = SCHOOL_TRANSMUTATION
	cooldown_time = 15 SECONDS
	cooldown_reduction_per_rank = 3 SECONDS //30 deciseconds reduction per rank
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "KN'A FTAGHU, PUCK 'BTHNK!"
	invocation_type = INVOCATION_SHOUT
	active_msg = span_notice_alt("You start to quietly neigh an incantation.")
	deactive_msg = span_notice_alt("You stop neighing to yourself.")

	button_icon_state = "barn"
	sound = 'sound/magic/HorseHead_curse.ogg'

/datum/action/cooldown/spell/pointed/horsemask/is_valid_target(atom/cast_on)
	if(!iscarbon(cast_on))
		return FALSE
	return ..()

/datum/action/cooldown/spell/pointed/horsemask/cast(atom/cast_on)
	. = ..()

	var/mob/living/carbon/human/target = cast_on
	var/obj/item/clothing/mask/horsehead/magichead = new /obj/item/clothing/mask/horsehead
	magichead.item_flags |= DROPDEL	//curses!
	ADD_TRAIT(magichead, TRAIT_NODROP, CURSED_ITEM_TRAIT(magichead.type))
	magichead.flags_inv &= ~HIDENAME	//so you can still see their face
	magichead.voicechange = TRUE	//NEEEEIIGHH
	target.visible_message(	span_danger("[target]'s face  lights up in fire, and after the event a horse's head takes its place!"), \
							span_danger("Your face burns up, and shortly after the fire you realise you have the face of a horse!"))
	if(!target.drop_item_ground(target.wear_mask))
		qdel(target.wear_mask)
	target.equip_to_slot_or_del(magichead, ITEM_SLOT_MASK)

	target.flash_eyes()

