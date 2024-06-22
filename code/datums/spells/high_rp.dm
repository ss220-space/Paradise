/obj/item/organ/internal/high_rp_tumor
	slot = INTERNAL_ORGAN_HIGHRP_TUMOR
	unremovable = TRUE
	actions_types = list(/datum/action/item_action/organ_action/manual_breath)
	var/last_pump = 0
	var/pump_delay = 30 SECONDS
	var/pump_window = 1 SECONDS
	var/oxy_loss = 45
	var/warned = FALSE

/obj/item/organ/internal/high_rp_tumor/insert(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(. && target)
		to_chat(target, span_userdanger("Вы чувствуете неприятное шевеление в груди... Внутренний голос подсказывает, что теперь придётся дышать самостоятельно!"))


/obj/item/organ/internal/high_rp_tumor/remove(mob/living/carbon/target, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(. && target)
		to_chat(target, span_userdanger("Вы чувствуете, что Вам более не требуется дышать самостоятельно!"))



/mob/living/carbon/human/proc/curse_high_rp(delay = 30 SECONDS, oxyloss = 45)
	var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = new
	hrp_tumor.last_pump = world.time
	hrp_tumor.pump_delay = delay
	hrp_tumor.oxy_loss = oxyloss
	hrp_tumor.pump_window = delay/5
	hrp_tumor.insert(src)


/obj/item/organ/internal/high_rp_tumor/on_life()
	if(world.time > (last_pump + (pump_delay - pump_window)))
		to_chat(owner, span_userdanger("Я долж[genderize_ru(owner.gender, "ен", "на", "но", "ны")] дышать, иначе просто задохн[pluralize_ru(owner.gender, "усь", "ёмся")]!"))
		warned = TRUE

	if(world.time > (last_pump + pump_delay))
		var/mob/living/carbon/human/H = owner
		H.setOxyLoss(H.oxyloss + oxy_loss)
		H.emote("gasp", ignore_cooldowns = TRUE)
		last_pump = world.time
		warned = FALSE


/datum/action/item_action/organ_action/manual_breath
	name = "Дышать"
	use_itemicon = FALSE
	icon_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "lungs"
	check_flags = NONE


/datum/action/item_action/organ_action/manual_breath/Trigger(left_click = TRUE)
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/high_rp_tumor))
		var/obj/item/organ/internal/high_rp_tumor/hrp_tumor = target

		if(world.time < (hrp_tumor.last_pump + (hrp_tumor.pump_delay - hrp_tumor.pump_window))) //no spam
			owner.balloon_alert(owner, "слишком рано!")
			hrp_tumor.owner.setOxyLoss(hrp_tumor.owner.oxyloss + hrp_tumor.oxy_loss/5)
			return

		hrp_tumor.last_pump = world.time
		owner.custom_emote(EMOTE_VISIBLE, "дыш%(ит,ат)%.")

