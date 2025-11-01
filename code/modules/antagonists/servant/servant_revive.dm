/datum/servant_revive
	var/client/servant_to_revive
	var/mob/living/carbon/human/master

/datum/servant_revive/New(mob/living/carbon/human/Servant_master, client/died_servant)
	servant_to_revive = died_servant
	master = Servant_master
	addtimer(CALLBACK(src, PROC_REF(respawn)), 5 MINUTES)
	RegisterSignal(master, COMSIG_MOB_DEATH, PROC_REF(stop))

/datum/servant_revive/proc/respawn()
	var/servant_key
	var/mob/living/carbon/human/Servant = new
	Servant.equipOutfit(/datum/outfit/butler)
	Servant.forceMove(master)

	for(var/mob/ghost in GLOB.dead_mob_list)
		if(ghost.client == servant_to_revive)
			Servant.client = servant_to_revive
			servant_key = servant_to_revive.key

	if(!servant_key)
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть играть за слугу [master.real_name]?", ROLE_WIZARD, role_cleanname = "слугу", poll_time = 10 SECONDS, source = Servant)
		if(length(candidates))
			var/mob/new_owner = pick(candidates)
			servant_key = new_owner.key

	if(!servant_key)
		qdel(Servant)
		to_chat(master, span_userdanger("Вы чувствуете, как часть жизненной энергии возвращается к вам. В ваших руках появляется монета."))
		var/obj/item/coin/magic/new_coin = new(master.loc)
		master.put_in_hands(new_coin)
		return

	var/datum/mind/servant_mind = new(servant_key)
	servant_mind.transfer_to(Servant)
	var/datum/antagonist/servant/serve = new(master)
	servant_mind.add_antag_datum(serve)
	var/datum/action/summon_servant/summon_action = new
	var/datum/action/servant_self_summon/self_summon_action = new
	summon_action.servant = Servant
	self_summon_action.master = master
	summon_action.servant = Servant
	self_summon_action.Grant(Servant)
	summon_action.Grant(master)
	qdel(src)

/datum/servant_revive/proc/stop()
	SIGNAL_HANDLER

	to_chat(master, span_userdanger("Умирая, вы чувствуете как связь с вашим слугой теряется."))
	qdel(src)

/datum/servant_revive/Destroy(force)
	UnregisterSignal(master, COMSIG_MOB_DEATH)
	. = ..()
