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

		for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
			if(account.owner_name != killer.real_name)
				continue

			killers_accs += account
			break

	if(!killers_accs.len)
		qdel(src)
		return

	var/bounty = round(reward / killers_accs.len)
	for(var/datum/money_account/account as anything in killers_accs)
		if(!account.charge(bounty, account, "Выплата вознаграждения персоналу.", "Nanotrasen personal departament" , "Поступление зарплаты.", "Поступление зарплаты" ,"Biesel TCD Terminal #[rand(111,333)]"))
			continue

		account.notify_pda_owner("<b>Поступление вознаграждения </b>\"На ваш привязанный аккаунт поступило [bounty] кредит[(bounty % 10 >= 5 || bounty % 100 >= 10 && bounty <= 20) ? "ов" : (bounty % 10 == 1 ? "" : "а")]\" (Невозможно Ответить)", FALSE)

	qdel(src)


/datum/component/killing_reward/InheritComponent(old_comp, original, reward)
	if(!original)
		return

	src.reward += reward
