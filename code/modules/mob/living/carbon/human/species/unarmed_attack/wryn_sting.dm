/datum/unarmed_attack/wryn_sting
	name = "sting"
	attack_verb = list("колет", "жалит", "ужалил")
	attack_object = "жалом"
	damage_min = 3
	damage_max = 7
	attack_sound = 'sound/weapons/bladeslice.ogg'
	icon_state = "sting_armblade"

/datum/unarmed_attack/wryn_sting/can_attack(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.wear_suit)	//Is your Wryn wearing a Hardsuit or a Laboat that's blocking their Stinger?
		to_chat(user, "<span class='notice'>Для использования жала нужно снять верхнюю одежду.</span>")
		return FALSE
	if(user.getStaminaLoss() >= 50)	//Does your Wryn have enough Stamina to sting?
		to_chat(user, "<span class='notice'>Вы слишком устали для использования жала.</span>")
		return FALSE
	return TRUE

/datum/unarmed_attack/wryn_sting/attack(mob/living/carbon/human/user, mob/living/carbon/human/target, zone)
	zone = target.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_GROIN))
	user.adjustStaminaLoss(20)
	. = ..()
