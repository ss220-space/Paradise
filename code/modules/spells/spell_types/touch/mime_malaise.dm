/datum/action/cooldown/spell/touch/mime_malaise
	name = "Mime Malaise"
	desc = "A spell popular with theater nerd wizards and contrarian pranksters, this spell will put on a mime costume on the target, \
		stun them so that they may contemplate Art, and silence them. \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/mime_malaise
	school = SCHOOL_MIME
	invocation = ""
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS //50 deciseconds reduction per rank
	sound = null
	button_icon_state = "mime_curse"

/obj/item/melee/touch_attack/mime_malaise
	name = "mime hand"
	desc = "..."
	icon_state = "fleshtostone"
	item_state = "fleshtostone"

/datum/action/cooldown/spell/touch/mime_malaise/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/mime_malaise/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/datum/effect_system/fluid_spread/smoke/s = new
	s.set_up(amount = 5, location = victim)
	s.start()
	var/mob/living/carbon/human/H = victim
	H.mimetouched()
	return TRUE

/mob/living/carbon/human/proc/mimetouched()
	Weaken(14 SECONDS)
	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed mime outfit. Replace with mime robes if we add those.
		drop_item_ground(wear_mask, force = TRUE)
		drop_item_ground(w_uniform, force = TRUE)
		drop_item_ground(wear_suit, force = TRUE)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime, ITEM_SLOT_MASK)
		equip_to_slot_or_del(new /obj/item/clothing/under/mime, ITEM_SLOT_CLOTH_INNER)
		equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders, ITEM_SLOT_CLOTH_OUTER)
		Silence(14 SECONDS)
	else
		qdel(wear_mask)
		qdel(w_uniform)
		qdel(wear_suit)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/mime/nodrop, ITEM_SLOT_MASK)
		equip_to_slot_or_del(new /obj/item/clothing/under/mime/nodrop, ITEM_SLOT_CLOTH_INNER)
		equip_to_slot_or_del(new /obj/item/clothing/suit/suspenders/nodrop, ITEM_SLOT_CLOTH_OUTER)
		force_gene_block(GLOB.muteblock, TRUE, TRUE)

