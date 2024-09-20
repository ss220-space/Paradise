/mob/living/simple_animal/spiderbot
	name = "Spider-bot"
	desc = "A skittering robotic friend!" //More like ultimate shitter
	icon = 'icons/mob/robots.dmi'
	icon_state = "spiderbot-chassis"
	icon_living = "spiderbot-chassis"
	icon_dead = "spiderbot-smashed"
	wander = 0
	universal_speak = 1
	health = 40
	maxHealth = 40
	pass_flags = PASSTABLE

	melee_damage_lower = 2
	melee_damage_upper = 2
	melee_damage_type = BURN
	attacktext = "бьёт током"
	attack_sound = "sparks"

	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	speed = 0
	mob_size = MOB_SIZE_SMALL
	speak_emote = list("beeps","clicks","chirps")
	tts_seed = "Antimage"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 500

	can_hide = 1
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = 1

	var/emagged = 0               //is it getting ready to explode?
	var/obj/item/mmi/mmi = null
	var/mob/emagged_master = null //for administrative purposes, to see who emagged the spiderbot; also for a holder for if someone emags an empty frame first then inserts an MMI.

/mob/living/simple_animal/spiderbot/Destroy()
	if(emagged)
		QDEL_NULL(mmi)
		explosion(get_turf(src), -1, -1, 3, 5, cause = src)
	else
		eject_brain()
	return ..()


/mob/living/simple_animal/spiderbot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/mmi))
		add_fingerprint(user)
		var/obj/item/mmi/new_mmi = I
		if(mmi) //There's already a brain in it.
			to_chat(user, span_warning("There is already [mmi] installed into [src]."))
			return ATTACK_CHAIN_PROCEED

		if(!new_mmi.brainmob)
			to_chat(user, span_warning("Sticking an empty MMI would sort of defeat the purpose."))
			return ATTACK_CHAIN_PROCEED

		if(!new_mmi.brainmob.key)
			var/ghost_can_reenter = FALSE
			if(new_mmi.brainmob.mind)
				for(var/mob/dead/observer/observer in GLOB.player_list)
					if(observer.can_reenter_corpse && observer.mind == new_mmi.brainmob.mind)
						ghost_can_reenter = TRUE
						if(new_mmi.next_possible_ghost_ping < world.time)
							observer.notify_cloning("Somebody is trying to spiderize you! Re-enter your corpse if you want to be a spider bot!", 'sound/voice/liveagain.ogg', src)
							new_mmi.next_possible_ghost_ping = world.time + 30 SECONDS // Avoid spam
						break
			if(ghost_can_reenter)
				to_chat(user, span_warning("The [new_mmi.name] is currently inactive. Try again later."))
			else
				to_chat(user, span_warning("The [new_mmi.name] is completely unresponsive; there's no point to use it."))
			return ATTACK_CHAIN_PROCEED

		if(new_mmi.brainmob.stat == DEAD)
			to_chat(user, span_warning("Sticking an MMI with dead occupant would sort of defeat the purpose."))
			return ATTACK_CHAIN_PROCEED

		if(jobban_isbanned(new_mmi.brainmob, JOB_TITLE_CYBORG) || jobban_isbanned(new_mmi.brainmob, "nonhumandept"))
			to_chat(user, span_warning("This [new_mmi.name] does not seem to fit."))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(mmi, src))
			return ..()

		to_chat(user, span_notice("You have inserted [new_mmi] into [src]."))
		mmi = new_mmi
		transfer_personality(new_mmi)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/obj/item/card/id/id_card = I.GetID()
	if(id_card)
		add_fingerprint(user)
		if(!mmi)
			to_chat(user, span_warning("There's no reason to swipe your ID - the spiderbot has no brain to remove."))
			return ATTACK_CHAIN_PROCEED
		if(emagged)
			to_chat(user, span_warning("[src] doesn't seem to respond."))
			return ATTACK_CHAIN_PROCEED
		if(!(ACCESS_ROBOTICS in id_card.access))
			to_chat(user, span_warning("Access Denied."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You swipe your access card and pop [mmi] out of [src]."))
		eject_brain()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/mob/living/simple_animal/spiderbot/welder_act(mob/user, obj/item/I)
	if(user.a_intent != INTENT_HELP)
		return
	if(user == src) //No self-repair dummy
		return
	if(health >= maxHealth)
		to_chat(user, "<span class='warning'>[src] does not need repairing!</span>")
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	adjustHealth(-5)
	add_fingerprint(user)
	user.visible_message("[user] repairs [src]!","<span class='notice'>You repair [src].</span>")

/mob/living/simple_animal/spiderbot/emag_act(mob/living/user)
	if(emagged)
		to_chat(user, "<span class='warning'>[src] doesn't seem to respond.</span>")
		return 0
	else if(istype(user))
		emagged = 1
		to_chat(user, "<span class='notice'>You short out the security protocols and rewrite [src]'s internal memory.</span>")
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [user] and [user.p_their()] every order!</span>")
		emagged_master = user
		add_attack_logs(user, src, "Emagged")
		maxHealth = 60
		health = 60
		melee_damage_lower = 15
		melee_damage_upper = 15
		attack_sound = 'sound/machines/defib_zap.ogg'


/mob/living/simple_animal/spiderbot/proc/transfer_personality(obj/item/mmi/M)
	mind = M.brainmob.mind
	mind.key = M.brainmob.key
	ckey = M.brainmob.ckey
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
	if(emagged)
		to_chat(src, "<span class='userdanger'>You have been emagged; you are now completely loyal to [emagged_master] and [emagged_master.p_their()] every order!</span>")


/mob/living/simple_animal/spiderbot/update_name(updates = ALL)
	. = ..()
	if(mmi)
		name = "Spider-bot ([mmi.brainmob.name])"
	else
		name = "Spider-bot"


/mob/living/simple_animal/spiderbot/update_icon_state()
	if(mmi)
		if(istype(mmi, /obj/item/mmi))
			icon_state = "spiderbot-chassis-mmi"
			icon_living = "spiderbot-chassis-mmi"
		if(istype(mmi, /obj/item/mmi/robotic_brain))
			icon_state = "spiderbot-chassis-posi"
			icon_living = "spiderbot-chassis-posi"

	else
		icon_state = "spiderbot-chassis"
		icon_living = "spiderbot-chassis"


/mob/living/simple_animal/spiderbot/proc/eject_brain()
	if(mmi)
		var/turf/T = get_turf(src)
		mmi.forceMove(T)
		if(mind)
			mind.transfer_to(mmi.brainmob)
		mmi = null
		update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
