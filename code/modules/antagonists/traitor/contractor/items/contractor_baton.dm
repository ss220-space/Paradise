#define UPGRADE_MUTE 1
#define UPGRADE_CUFFS 2
#define UPGRADE_FOCUS 3
#define UPGRADE_ANTIDROP 4


/obj/item/melee/baton/telescopic/contractor
	name = "contractor baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets."
	icon_state = "contractor_baton"
	affect_cyborgs = TRUE
	affect_bots = TRUE
	cooldown = 2.5 SECONDS
	clumsy_knockdown_time = 24 SECONDS
	stamina_damage = 75
	force = 5
	extend_force = 20
	block_chance = 30
	force_say_chance = 80 //very high force say chance because it's funny
	on_stun_sound = 'sound/weapons/contractorbatonhit.ogg'
	extend_sound = 'sound/weapons/contractorbatonextend.ogg'
	extend_item_state = "contractor_baton_extended"
	/// Currently applied upgrades.
	var/list/upgrades
	/// Current amount of cuffs left, used with cuffs upgrade.
	var/cuffs_amount = 0


/obj/item/melee/baton/telescopic/contractor/examine(mob/user)
	. = ..()
	if(has_upgrade(UPGRADE_CUFFS))
		. += span_info("It has <b>[cuffs_amount]</b> cabble restraints remaining.")
	for(var/obj/item/baton_upgrade/upgrade as anything in upgrades)
		. += span_notice("It has <b>[upgrade.name]</b> installed, which [upgrade.upgrade_examine].")


/obj/item/melee/baton/telescopic/contractor/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/baton_upgrade))
		add_fingerprint(user)
		add_upgrade(I, user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/restraints/handcuffs))
		add_fingerprint(user)
		if(!has_upgrade(UPGRADE_CUFFS))
			balloon_alert(user, "модуль стяжек не установлен!")
			return ATTACK_CHAIN_PROCEED
		if(!istype(I, /obj/item/restraints/handcuffs/cable))
			balloon_alert(user, "подойдут только стяжки!")
			return ATTACK_CHAIN_PROCEED
		if(cuffs_amount >= 3)
			balloon_alert(user, "больше не поместится!")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		cuffs_amount++
		balloon_alert(user, "хранилище стяжек пополнено")
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/melee/baton/telescopic/contractor/get_wait_description()
	return span_danger("The baton is still charging!")


/obj/item/melee/baton/telescopic/contractor/additional_effects_non_cyborg(mob/living/carbon/human/target, mob/living/user)
	target.AdjustJitter(5 SECONDS, bound_upper = 40 SECONDS)
	target.AdjustStuttering(10 SECONDS, bound_upper = 40 SECONDS)
	if(has_upgrade(UPGRADE_MUTE))
		target.AdjustSilence(10 SECONDS, bound_upper = 10 SECONDS)
	if(has_upgrade(UPGRADE_CUFFS) && cuffs_amount > 0)
		if(target.getStaminaLoss() > 90 || target.health <= HEALTH_THRESHOLD_CRIT || target.IsSleeping())
			CuffAttack(target, user)
	if(has_upgrade(UPGRADE_FOCUS) && ishuman(target))
		for(var/datum/antagonist/contractor/antag_datum in user.mind.antag_datums)
			if(target == antag_datum?.contractor_uplink?.hub?.current_contract?.contract?.target.current)
				target.apply_damage(20, STAMINA)
				target.AdjustJitter(20 SECONDS, bound_upper = 40 SECONDS)
				break


/obj/item/melee/baton/telescopic/contractor/proc/add_upgrade(obj/item/baton_upgrade/new_upgrade, mob/user)
	if(!istype(new_upgrade))
		return FALSE
	if(!upgrades)
		upgrades = list()
	if(locate(new_upgrade.type, upgrades))
		if(user)
			balloon_alert(user, "уже установлено!")
		return FALSE
	if(user && !user.drop_transfer_item_to_loc(new_upgrade, src))
		return FALSE
	upgrades += new_upgrade
	if(user)
		balloon_alert(user, "установлено")
	else
		new_upgrade.forceMove(src)


/obj/item/melee/baton/telescopic/contractor/proc/has_upgrade(upgrade_type)
	if(!length(upgrades))
		return FALSE
	switch(upgrade_type)
		if(UPGRADE_MUTE)
			return locate(/obj/item/baton_upgrade/mute, upgrades)
		if(UPGRADE_CUFFS)
			return locate(/obj/item/baton_upgrade/cuff, upgrades)
		if(UPGRADE_FOCUS)
			return locate(/obj/item/baton_upgrade/focus, upgrades)
		if(UPGRADE_ANTIDROP)
			return locate(/obj/item/baton_upgrade/antidrop, upgrades)


/obj/item/melee/baton/telescopic/contractor/proc/CuffAttack(mob/living/carbon/target, mob/living/user)
	if(target.handcuffed)
		to_chat(user, span_warning("[target] is already handcuffed!"))
		return

	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	target.visible_message(
		span_danger("[user] begins restraining [target] with contractor baton!"),
		span_userdanger("[user] is trying to put handcuffs on you!"),
	)
	if(!do_after(user, 1 SECONDS, target, NONE) || target.handcuffed || !cuffs_amount)
		to_chat(user, span_warning("You fail to shackle [target]."))
		return

	target.apply_restraints(new /obj/item/restraints/handcuffs/cable(null), ITEM_SLOT_HANDCUFFED, TRUE)
	to_chat(user, span_notice("You shackle [target]."))
	add_attack_logs(user, target, "shackled")
	cuffs_amount--


/obj/item/melee/baton/telescopic/contractor/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(!has_upgrade(UPGRADE_ANTIDROP))
		return .

	if(active)
		to_chat(user, span_notice("The baton spikes burrows into your arm, preventing accidential dropping."))
		ADD_TRAIT(src, TRAIT_NODROP, CONTRACTOR_BATON_TRAIT)
	else
		to_chat(user, span_notice("The baton spikes fold back, allowing you to move your hand freely."))
		REMOVE_TRAIT(src, TRAIT_NODROP, CONTRACTOR_BATON_TRAIT)


//upgrades
/obj/item/baton_upgrade
	var/upgrade_examine


/obj/item/baton_upgrade/cuff
	name = "handcuff upgrade"
	desc = "Allows the user to apply cabble restraints to a target via baton, requires to be loaded with up to three prior."
	icon_state = "cuff_upgrade"
	upgrade_examine = "allows you to cabble cuff your target if your target is exhausted. Required to be loaded first"


/obj/item/baton_upgrade/mute
	name = "mute upgrade"
	desc = "Use of the baton on a target will mute them for a short period."
	icon_state = "mute_upgrade"
	upgrade_examine = "deprives the victim of the ability to speak for a small time"


/obj/item/baton_upgrade/focus
	name = "focus upgrade"
	desc = "Use of the baton on a target, should they be the subject of your contract, will be extra exhausted."
	icon_state = "focus_upgrade"
	upgrade_examine = "allows you to cause additional damage to the target of your current contract"


/obj/item/baton_upgrade/antidrop
	name = "antidrop upgrade"
	desc = "This module grips the hand, not allowing the user to drop extended baton under any circumstances."
	icon_state = "antidrop_upgrade"
	upgrade_examine = "allows you to keep your extended baton in hands no matter what happens with you"


#undef UPGRADE_MUTE
#undef UPGRADE_CUFFS
#undef UPGRADE_FOCUS
#undef UPGRADE_ANTIDROP

