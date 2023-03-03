/obj/item/organ/internal/brain/high_rp
	actions_types = list(/datum/action/item_action/organ_action/manual_breath)
	var/last_pump = 0
	var/pump_delay = 300
	var/oxy_loss = 45
	var/pump_window = 10
	var/obj/item/organ/internal/brain/old_brain

/obj/item/organ/internal/brain/high_rp/insert(mob/living/target, special = 0, high_rp = 1)
	..(target, special = special)
	if(target)
		to_chat(target, "<span class='userdanger'>Я должен дышать, иначе просто задохнусь!</span>")

/mob/living/carbon/human/proc/curse_high_rp(delay = 300, oxyloss = 45)
	var/mob/living/carbon/human/H = src
	var/obj/item/organ/internal/brain/high_rp/cursed_brain = new
	cursed_brain.pump_delay = delay
	cursed_brain.oxy_loss = oxyloss
	cursed_brain.pump_window = delay/5
	var/obj/item/organ/internal/brain/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(brain)
		cursed_brain.name = brain.name
		cursed_brain.desc = brain.desc
		cursed_brain.icon = brain.icon
		cursed_brain.icon_state = brain.icon_state
		cursed_brain.mmi_icon_state = brain.mmi_icon_state
		cursed_brain.parent_organ = brain.parent_organ
		cursed_brain.old_brain = brain
		cursed_brain.dna = H.dna.Clone()
		cursed_brain.insert(H)

/obj/item/organ/internal/brain/high_rp/on_life()
	if(world.time > (last_pump + pump_delay))
		var/mob/living/carbon/human/H = owner
		H.setOxyLoss(H.oxyloss + oxy_loss)
		H.custom_emote(1, "задыхается!")
		to_chat(H, "<span class='userdanger'>Я должен дышать, иначе просто задохнусь!</span>")
		last_pump = world.time

/datum/action/item_action/organ_action/manual_breath
	name = "Дышать"
	use_itemicon = FALSE
	icon_icon = 'icons/obj/surgery.dmi'
	button_icon_state = "lungs"
	check_flags = null

/datum/action/item_action/organ_action/manual_breath/IsMayActive()
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/brain/high_rp))
		var/obj/item/organ/internal/brain/high_rp/cursed_brain = target
		if(world.time < (cursed_brain.last_pump + (cursed_brain.pump_delay - cursed_brain.pump_window)))
			return FALSE
		return TRUE
	return FALSE

/datum/action/item_action/organ_action/manual_breath/Trigger()
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/brain/high_rp))
		var/obj/item/organ/internal/brain/high_rp/cursed_brain = target

		if(world.time < (cursed_brain.last_pump + (cursed_brain.pump_delay - cursed_brain.pump_window))) //no spam
			to_chat(owner, "<span class='userdanger'>Слишком рано!</span>")
			return

		cursed_brain.last_pump = world.time
		to_chat(owner, "<span class = 'notice'>Вы дышите.</span>")
		owner.custom_emote(1, "дышит")
