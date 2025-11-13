// Reward will be given to humans near the died owner.
/datum/component/killing_reward
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Reward that will be given to humans near the died owner.
	var/reward

/datum/component/killing_reward/Initialize(reward)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.reward = reward

/datum/component/killing_reward/RegisterSignal(datum/target, sig_type_or_types, proctype, override)
	RegisterSignal(parent, COMSIG_MOB_DEATH, PROC_REF(on_death))

/datum/component/killing_reward/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_DEATH)

/datum/component/killing_reward/proc/on_death()
	SIGNAL_HANDLER
	var/list/datum/money_account/killers_accs = list()
	for(var/mob/living/carbon/human/killer in view(7, src))
		if(killer.stat == DEAD || !killer.ckey)
			continue

		var/obj/item/card/id/killer_id = killer.get_id_card()
		var/datum/money_account/account = get_money_account(killer_id.associated_account_number)
		if(!account)
			continue

		killers_accs += account

	if(!length(killers_accs))
		qdel(src)
		return

	var/bounty = round(reward / length(killers_accs))
	for(var/datum/money_account/account as anything in killers_accs)
		if(!account.charge(bounty, account, "Выплата вознаграждения персоналу.", "Nanotrasen personal departament" , "Поступление зарплаты.", "Поступление зарплаты" ,"Biesel TCD Terminal #[rand(111,333)]"))
			continue

		account.notify_pda_owner("<b>Поступление вознаграждения </b>\"На ваш привязанный аккаунт поступил[declension_ru(bounty, "", "о", "о")] [bounty] кредит[DECL_CREDIT(bounty)].\" (Невозможно Ответить)", FALSE)

	qdel(src)

/datum/component/killing_reward/InheritComponent(old_comp, original, reward)
	if(!original)
		return

	src.reward += reward
