/obj/item/organ/internal/brain/high_rp
	actions_types = list(/datum/action/item_action/organ_action/manual_breath)
	var/last_pump = 0
	var/pump_delay = 300
	var/oxy_loss = 45
	var/obj/item/organ/internal/brain/old_brain

/obj/item/organ/internal/brain/high_rp/insert(mob/living/target, special = 0, high_rp = 1)
	..(target, special = special)
	if(target)
		to_chat(target, "<span class='userdanger'>Я должен дышать, иначе просто задохнусь!</span>")

/mob/living/carbon/human/proc/curse_high_rp()
	var/mob/living/carbon/human/H = src
	var/obj/item/organ/internal/brain/high_rp/O = new
	var/obj/item/organ/internal/brain/brain = H.get_int_organ(/obj/item/organ/internal/brain)
	if(brain)
		O.name = brain.name
		O.desc = brain.desc
		O.icon = brain.icon
		O.icon_state = brain.icon_state
		O.mmi_icon_state = brain.mmi_icon_state
		O.parent_organ = brain.parent_organ
		O.old_brain = brain
		O.dna = H.dna.Clone()
		O.insert(H)

/obj/item/organ/internal/brain/high_rp/on_life()
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client)
			var/mob/living/carbon/human/H = owner
			if(!(NO_BLOOD in H.dna.species.species_traits))
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

/datum/action/item_action/organ_action/manual_breath/Trigger()
	. = ..()
	if(. && istype(target, /obj/item/organ/internal/brain/high_rp))
		var/obj/item/organ/internal/brain/high_rp/cursed_brain = target

		if(world.time < (cursed_brain.last_pump + (cursed_brain.pump_delay - 100))) //no spam
			to_chat(owner, "<span class='userdanger'>Слишком рано!</span>")
			return

		cursed_brain.last_pump = world.time
		to_chat(owner, "<span class = 'notice'>Вы дышите.</span>")
		owner.custom_emote(1, "дышит")
