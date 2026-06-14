/obj/effect/proc_holder/spell/touch/mime_malaise
	name = "Mime Malaise"
	desc = "A spell popular with theater nerd wizards and contrarian pranksters, this spell will put on a mime costume on the target, \
		stun them so that they may contemplate Art, and silence them. \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/mime_malaise
	school = "transmutation"

	base_cooldown = 30 SECONDS
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank

	action_icon_state = "mime_curse"

/obj/item/melee/touch_attack/mime_malaise
	name = "mime hand"
	desc = "..."
	catchphrase = null
	on_use_sound = null
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/obj/item/melee/touch_attack/mime_malaise/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag || target == user || !ishuman(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/datum/effect_system/fluid_spread/smoke/s = new
	s.set_up(amount = 5, location = target)
	s.start()

	var/mob/living/carbon/human/H = target
	H.mimetouched()
	..()
