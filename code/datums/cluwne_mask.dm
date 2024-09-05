#define CLUWNE_PDA_SLIP_DAMAGE 10

#define CLUWNE_BIKEHORN_KNOCKDOWN_TIME (4 SECONDS)

#define CLUWNE_UNARMED_ATTACK_BLIND_TIME (2 SECONDS)
#define CLUWNE_UNARMED_ATTACK_HALLUCINATION_TIME (30 SECONDS)
#define CLUWNE_UNARMED_ATTACK_MAX_HALLUCINATION_TIME (90 SECONDS)

/datum/cluwne_mask
	/// Type of mob which we will transform into fake cluwne
	var/mob/living/carbon/human/cluwne
	/// Our cluwne pda. Used to receive heal when somebody slips on it and deal damage to victim.
	var/obj/item/pda/pda
	/// Linked bikehorn, we will use him to give various effects to target.
	var/obj/item/bikehorn/bikehorn
	/// Global cooldown of our actions. If true - your abilities won't work.
	COOLDOWN_DECLARE(global_cooldown)
	
/datum/cluwne_mask/proc/transform(mob/living/carbon/human/human)
	if(!istype(human))
		return
	if(!human.mind)
		return
	cluwne = human
	pda = human.wear_pda
	bikehorn = human.find_item(/obj/item/bikehorn)
	init_cluwne()
	
/datum/cluwne_mask/proc/init_cluwne(
	should_transform = TRUE,
	should_gain_effects = TRUE
)
	
	if(should_transform)
		transform_cluwne()
	if(should_gain_effects)
		init_cluwne_signals()
		init_pda_signals()
		init_bikehorn_signals()

/datum/cluwne_mask/proc/init_cluwne_signals()
	RegisterSignal(cluwne, COMSIG_HUMAN_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(cluwne, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, PROC_REF(unarmed_attack))

/datum/cluwne_mask/proc/transform_cluwne()
	cluwne.mind.assigned_role = "Cluwne"
	cluwne.rename_character(newname = "cluwne")
	cluwne.drop_item_ground(cluwne.w_uniform, force = TRUE)
	cluwne.drop_item_ground(cluwne.shoes, force = TRUE)
	cluwne.drop_item_ground(cluwne.gloves, force = TRUE)
	cluwne.equip_to_slot_or_del(new /obj/item/clothing/under/cursedclown, ITEM_SLOT_CLOTH_INNER)
	cluwne.equip_to_slot_or_del(new /obj/item/clothing/gloves/cursedclown, ITEM_SLOT_GLOVES)
	cluwne.equip_to_slot_or_del(new /obj/item/clothing/shoes/cursedclown, ITEM_SLOT_FEET)
	cluwne.grant_mimicking()

/datum/cluwne_mask/proc/init_pda_signals()
	if(!pda)
		return
		
	RegisterSignal(pda, COMSIG_QDELETING, PROC_REF(on_pda_delete))
	RegisterSignal(pda, COMSIG_COMPONENT_PARENT_SLIP, PROC_REF(on_pda_slip))
	
	if(!pda.GetComponent(/datum/component/slippery))
		pda.AddComponent(/datum/component/slippery)

/datum/cluwne_mask/proc/init_bikehorn_signals()
	if(!bikehorn)
		return
		
	RegisterSignal(bikehorn, COMSIG_ITEM_DROPPED, PROC_REF(bikehorn_unequip))
	RegisterSignal(bikehorn, COMSIG_ITEM_AFTERATTACK, PROC_REF(after_attack_bikehorn))

/datum/cluwne_mask/Destroy(force)
	UnregisterSignal(cluwne, COMSIG_HUMAN_EQUIPPED_ITEM)
	UnregisterSignal(cluwne, COMSIG_HUMAN_MELEE_UNARMED_ATTACK)
	if(bikehorn)
		UnregisterSignal(bikehorn, COMSIG_ITEM_DROPPED)
		UnregisterSignal(bikehorn, COMSIG_ITEM_AFTERATTACK)
		bikehorn = null
	if(pda)
		UnregisterSignal(pda, COMSIG_QDELETING)
		UnregisterSignal(pda, COMSIG_COMPONENT_PARENT_SLIP)
		pda = null
	cluwne.dust() // This is your new curse
	cluwne = null
	return ..()
	
/datum/cluwne_mask/proc/on_equip(obj/item/item, slot, initial)
	SIGNAL_HANDLER
	
	switch(item.type)
		if(/obj/item/bikehorn)
			if(bikehorn)
				return
			bikehorn = item
			init_bikehorn_signals()
		if(/obj/item/pda)
			if(pda) // we link that only once. And re-link only when pda was destroyed
				return
			pda = item
			init_pda_signals()

/datum/cluwne_mask/proc/unarmed_attack(mob/living/carbon/human/target, proximity)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, global_cooldown))
		return
	if(!istype(target))
		return

	target.AdjustHallucinate(CLUWNE_UNARMED_ATTACK_HALLUCINATION_TIME, bound_upper = CLUWNE_UNARMED_ATTACK_MAX_HALLUCINATION_TIME)
	target.EyeBlind(CLUWNE_UNARMED_ATTACK_BLIND_TIME)
	send_honk(target)
	COOLDOWN_START(src, global_cooldown, CLUWNE_UNARMED_ATTACK_GLOBALCOOLDOWN)
	
/datum/cluwne_mask/proc/after_attack_bikehorn(obj/item/item, mob/living/carbon/human/target, mob/user, proximity, params)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, global_cooldown))
		return
	if(!istype(target))
		return
		
	target.SetKnockdown(CLUWNE_BIKEHORN_KNOCKDOWN_TIME)
	send_honk(target)
	COOLDOWN_START(src, global_cooldown, CLUWNE_BIKEHORN_GLOBALCOOLDOWN)
	
/datum/cluwne_mask/proc/on_pda_delete()
	SIGNAL_HANDLER

	UnregisterSignal(pda, COMSIG_QDELETING)
	UnregisterSignal(pda, COMSIG_COMPONENT_PARENT_SLIP)
	pda = null
	
/datum/cluwne_mask/proc/bikehorn_unequip()
	SIGNAL_HANDLER

	UnregisterSignal(bikehorn, COMSIG_ITEM_DROPPED)
	UnregisterSignal(bikehorn, COMSIG_ITEM_AFTERATTACK)
	bikehorn = null

/datum/cluwne_mask/proc/on_pda_slip(mob/living/carbon/human/victim, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, global_cooldown))
		return
	if(!istype(victim))
		return
	if(victim != cluwne)
		var/applied_damage = CLUWNE_PDA_SLIP_DAMAGE + (victim.health / 10)
		victim.apply_damage(applied_damage, TOX)
		send_honk(victim)
	cluwne.heal_overall_damage(5, 5)
	COOLDOWN_START(src, global_cooldown, CLUWNE_PDA_SLIP_GLOBALCOOLDOWN)

/datum/cluwne_mask/proc/send_honk(mob/target)
	to_chat(target, "<font color='red' size='7'>HONK</font>")
	SEND_SOUND(target, sound('sound/items/airhorn.ogg'))

#undef CLUWNE_PDA_SLIP_DAMAGE
#undef CLUWNE_BIKEHORN_KNOCKDOWN_TIME
#undef CLUWNE_UNARMED_ATTACK_BLIND_TIME
#undef CLUWNE_UNARMED_ATTACK_HALLUCINATION_TIME
#undef CLUWNE_UNARMED_ATTACK_MAX_HALLUCINATION_TIME
                                              
