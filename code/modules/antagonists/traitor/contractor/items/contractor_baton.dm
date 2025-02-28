#define UPGRADE_MUTE 1
#define UPGRADE_CUFFS 2
#define UPGRADE_FOCUS 3
#define UPGRADE_ANTIDROP 4


/obj/item/melee/baton/telescopic/contractor
	name = "contractor baton"
	desc = "A compact, specialised baton issued to Syndicate contractors. Applies light electrical shocks to targets."
	ru_names = list(
		NOMINATIVE = "дубинка контрактника",
		GENITIVE = "дубинки контрактника",
		DATIVE = "дубинке контрактника",
		ACCUSATIVE = "дубинку контрактника",
		INSTRUMENTAL = "дубинкой контрактника",
		PREPOSITIONAL = "дубинке контрактника"
	)
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
		. += span_info("В нём остал[declension_ru(cuffs_amount, "а", "о", "о")]сь <b>[cuffs_amount]</b> стяж[declension_ru(cuffs_amount, "ка", "ки", "ек")].")
	for(var/obj/item/baton_upgrade/upgrade as anything in upgrades)
		. += span_notice("В нём установлен <b>[upgrade.declent_ru(NOMINATIVE)]</b>, который [upgrade.upgrade_examine].")


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
	return span_danger("Дубинка ещё перезаряжается!")


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
				target.apply_damage(30, STAMINA)
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
		balloon_alert(user, "цель уже связана!")
		return

	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	target.visible_message(span_danger("[user] начина[pluralize_ru(user.gender, "ет", "ют")] связывать [target] [declent_ru(INSTRUMENTAL)]!"),
							span_userdanger("[user] пыта[pluralize_ru(user.gender, "ет", "ют")]ся связать вас!"))
	if(!do_after(user, 1 SECONDS, target, NONE) || target.handcuffed || !cuffs_amount)
		to_chat(user, span_warning("Вам не удается связать [target]."))
		return

	target.apply_restraints(new /obj/item/restraints/handcuffs/cable(null), ITEM_SLOT_HANDCUFFED, TRUE)
	to_chat(user, span_notice("Вы связываете [target]."))
	add_attack_logs(user, target, "shackled")
	cuffs_amount--


/obj/item/melee/baton/telescopic/contractor/on_transform(obj/item/source, mob/user, active)
	. = ..()
	if(!has_upgrade(UPGRADE_ANTIDROP))
		return .

	if(active)
		to_chat(user, span_notice("Шипы дубинки впиваются в руку, предотвращая случайное падение."))
		ADD_TRAIT(src, TRAIT_NODROP, CONTRACTOR_BATON_TRAIT)
	else
		to_chat(user, span_notice("Шипы дубинки складываются, позволяя свободно двигать рукой."))
		REMOVE_TRAIT(src, TRAIT_NODROP, CONTRACTOR_BATON_TRAIT)


//upgrades
/obj/item/baton_upgrade
	var/upgrade_examine
	gender = FEMALE

/obj/item/baton_upgrade/cuff
	name = "handcuff upgrade"
	desc = "Позволяет заряжать стяжки, которые будут автоматически надеваться на цель после удара дубинкой."
	ru_names = list(
		NOMINATIVE = "модуль \"Стяжки\"",
		GENITIVE = "модуля \"Стяжки\"",
		DATIVE = "модулю \"Стяжки\"",
		ACCUSATIVE = "модуль \"Стяжки\"",
		INSTRUMENTAL = "модулем \"Стяжки\"",
		PREPOSITIONAL = "модуле \"Стяжки\""
	)
	icon_state = "cuff_upgrade"
	upgrade_examine = "автоматически связывает цель, если она истощена. Сначала необходимо зарядить стяжками"


/obj/item/baton_upgrade/mute
	name = "mute upgrade"
	desc = "Удар дубинкой по цели заставит ее замолчать на короткое время."
	ru_names = list(
		NOMINATIVE = "модуль \"Безмолвие\"",
		GENITIVE = "модуля \"Безмолвие\"",
		DATIVE = "модулю \"Безмолвие\"",
		ACCUSATIVE = "модуль \"Безмолвие\"",
		INSTRUMENTAL = "модулем \"Безмолвие\"",
		PREPOSITIONAL = "модуле \"Безмолвие\""
	)
	icon_state = "mute_upgrade"
	upgrade_examine = "лишает жертву способности говорить на некоторое время"


/obj/item/baton_upgrade/focus
	name = "focus upgrade"
	desc = "Удар дубинкой по цели, если она является объектом вашего контракта, приведёт к дополнительному истощению."
	ru_names = list(
		NOMINATIVE = "модуль \"Фокусировка\"",
		GENITIVE = "модуля \"Фокусировка\"",
		DATIVE = "модулю \"Фокусировка\"",
		ACCUSATIVE = "модуль \"Фокусировка\"",
		INSTRUMENTAL = "модулем \"Фокусировка\"",
		PREPOSITIONAL = "модуле \"Фокусировка\""
	)
	icon_state = "focus_upgrade"
	upgrade_examine = "позволяет нанести дополнительный ущерб цели вашего текущего контракта"


/obj/item/baton_upgrade/antidrop
	name = "antidrop upgrade"
	desc = "Этот модуль фиксирует дубинку, не позволяя выронить её из рук ни при каких обстоятельствах."
	ru_names = list(
		NOMINATIVE = "модуль \"Защита от выпадения\"",
		GENITIVE = "модуля \"Защита от выпадения\"",
		DATIVE = "модулю \"Защита от выпадения\"",
		ACCUSATIVE = "модуль \"Защита от выпадения\"",
		INSTRUMENTAL = "модулем \"Защита от выпадения\"",
		PREPOSITIONAL = "модуле \"Защита от выпадения\""
	)
	icon_state = "antidrop_upgrade"
	upgrade_examine = "позволяет держать в руках дубинку, невзирая на происходящее с вами"


#undef UPGRADE_MUTE
#undef UPGRADE_CUFFS
#undef UPGRADE_FOCUS
#undef UPGRADE_ANTIDROP

