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
	var/mob/living/carbon/human/servant = new
	servant.equipOutfit(/datum/outfit/butler)
	servant.forceMove(master)

	for(var/mob/ghost as anything in GLOB.dead_mob_list)
		if(ghost.client == servant_to_revive)
			servant.client = servant_to_revive
			servant_key = servant_to_revive.key

	if(!servant_key)
		var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите поиграть играть за слугу [master.real_name]?", ROLE_WIZARD, role_cleanname = "слугу", poll_time = 10 SECONDS, source = servant)
		if(length(candidates))
			var/mob/new_owner = pick(candidates)
			servant_key = new_owner.key

	if(!servant_key)
		qdel(servant)
		to_chat(master, span_userdanger("Вы чувствуете, как часть жизненной энергии возвращается к вам. В ваших руках появляется монета."))
		var/obj/item/coin/magic/new_coin = new(master.loc)
		master.put_in_hands(new_coin)
		return
	servant.possess_by_player(servant_key)
	var/datum/antagonist/servant/serv = new /datum/antagonist/servant(master)
	servant.mind.add_antag_datum(serv)
	qdel(src)

/datum/servant_revive/proc/stop()
	SIGNAL_HANDLER

	to_chat(master, span_userdanger("Умирая, вы чувствуете как связь с вашим слугой теряется."))
	qdel(src)

/datum/servant_revive/Destroy(force)
	UnregisterSignal(master, COMSIG_MOB_DEATH)
	. = ..()
