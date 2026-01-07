/client/proc/add_admin_verbs()
	SSadmin_verbs.assosciate_admin(src)
	if(check_rights_client(R_ADMIN|R_DEBUG|R_VIEWRUNTIMES, FALSE, src))
		// This setting exposes the profiler & client side tools
		spawn(1)
			control_freak = 0

/client/proc/remove_admin_verbs()
	SSadmin_verbs.deassosciate_admin(src)

ADMIN_VERB(hide_verbs, R_NONE, "Adminverbs - Hide All", "Hide most of your admin verbs.", ADMIN_CATEGORY_MAIN)
	user.remove_admin_verbs()
	add_verb(user, /client/proc/show_verbs)

	to_chat(user, span_interface("Almost all of your adminverbs have been hidden."), confidential = TRUE)
	BLACKBOX_LOG_ADMIN_VERB("Hide All Adminverbs")

ADMIN_VERB(admin_ghost, R_ADMIN|R_MOD|R_POSSESS, "AGhost", "Become a ghost without DNR.", ADMIN_CATEGORY_GAME)
	if(isobserver(user.mob))
		//re-enter
		var/mob/dead/observer/ghost = user.mob
		var/old_turf = get_turf(ghost)
		if(!ghost.can_reenter_corpse)
			log_admin("[key_name(user)] re-entered corpse")
			message_admins("[key_name_admin(user)] re-entered corpse")
		ghost.can_reenter_corpse = 1 // force re-entering even when otherwise not possible
		ghost.reenter_corpse()
		BLACKBOX_LOG_ADMIN_VERB("Admin Reenter")
		if(ishuman(user.mob))
			var/mob/living/carbon/human/H = user.mob
			H.regenerate_icons() // workaround for #13269
		if(isAI(user.mob)) // client.mob, built in byond client var
			var/mob/living/silicon/ai/ai = user.mob
			ai.eyeobj.setLoc(old_turf)
	else if(isnewplayer(user.mob))
		to_chat(user, span_red("Error: Aghost: Can't admin-ghost whilst in the lobby. Join or observe first."), confidential=TRUE)
	else
		//ghostize
		log_admin("[key_name(user)] admin ghosted.")
		message_admins("[key_name_admin(user)] admin ghosted.")
		var/mob/body = user.mob
		body.ghostize(1)
		if(body && !body.key)
			body.possess_by_player("@[user.key]") //Haaaaaaaack. But the people have spoken. If it breaks; blame adminbus
		// TODO: SStgui.on_transfer() to move windows from old and new
		BLACKBOX_LOG_ADMIN_VERB("Admin Ghost")

ADMIN_VERB(invisimin, R_ADMIN, "Invisimin", "Toggles ghost-like invisibility.", ADMIN_CATEGORY_GAME)
	if(!isliving(user.mob))
		return

	var/mob/living/user_mob = user.mob
	if(user_mob.invisibility == INVISIBILITY_OBSERVER)
		user_mob.invisibility = initial(user_mob.invisibility)
		user_mob.add_to_all_human_data_huds()
		to_chat(user, span_adminnotice(span_bold("Invisimin off. Invisibility reset.")), confidential = TRUE)
		log_admin("[key_name(user)] has turned Invisimin OFF")
	else
		user_mob.invisibility = INVISIBILITY_OBSERVER
		user_mob.remove_from_all_data_huds()
		to_chat(user, span_adminnotice(span_bold("Invisimin on. You are now as invisible as a ghost.")), confidential = TRUE)
		log_admin("[key_name(user)] has turned Invisimin ON")
	BLACKBOX_LOG_ADMIN_VERB("Invisimin")

ADMIN_VERB(check_security, R_ADMIN, "Check Security", "See all security for the round.", ADMIN_CATEGORY_GAME)
	user.holder.check_security()
	log_admin("[key_name(user)] checked security")
	BLACKBOX_LOG_ADMIN_VERB("Check Securitys")

ADMIN_VERB(check_antagonists, R_ADMIN, "Check Antagonists", "See all antagonists for the round.", ADMIN_CATEGORY_GAME)
	user.holder.check_antagonists()
	log_admin("[key_name(user)] checked antagonists.")
	if(!isobserver(user.mob) && SSticker.HasRoundStarted())
		message_admins("[key_name_admin(user)] checked antagonists.")
	BLACKBOX_LOG_ADMIN_VERB("Check Antagonists")

ADMIN_VERB(check_antagonists_tgui, R_ADMIN, "Antagonists Menu", "Opens the antagonists menu.", ADMIN_CATEGORY_GAME)
	if(!SSticker)
		to_chat(user, span_warning("Игра еще не началась!"))
		return

	if(SSticker.current_state <= GAME_STATE_PREGAME)
		to_chat(user, span_warning("Раунд еще не начался!"))
		return

	var/datum/ui_module/admin = get_admin_ui_module(/datum/ui_module/admin/antagonist_menu)
	admin.ui_interact(user.mob)
	log_admin("[key_name(user)] checked antagonists")
	BLACKBOX_LOG_ADMIN_VERB("Antagonists Menu")

ADMIN_VERB(ban_panel, R_BAN, "Ban Panel", "Ban players here.", ADMIN_CATEGORY_BAN)
	if(CONFIG_GET(flag/ban_legacy_system))
		user.holder.unbanpanel()
	else
		user.holder.DB_ban_panel()
	BLACKBOX_LOG_ADMIN_VERB("Ban Panel")

ADMIN_VERB(game_panel, R_ADMIN|R_EVENT, "Game Panel", "Look at the state of the game.", ADMIN_CATEGORY_EVENTS)
	user.holder.Game()
	BLACKBOX_LOG_ADMIN_VERB("Game Panel")

ADMIN_VERB(secrets, R_ADMIN|R_EVENT, "Secrets", "Abuse harder than you ever have before with this handy dandy semi-misc stuff menu.", ADMIN_CATEGORY_EVENTS)
	user.holder.Secrets()
	BLACKBOX_LOG_ADMIN_VERB("Secrets Panel")

/// Returns this client's stealthed ckey
/client/proc/getStealthKey()
	return GLOB.stealthminID[ckey]

/client/proc/createStealthKey()
	var/num = (rand(0,1000))
	var/i = 0
	while(i == 0)
		i = 1
		for(var/P in GLOB.stealthminID)
			if(num == GLOB.stealthminID[P])
				num++
				i = 0
	GLOB.stealthminID["[ckey]"] = "@[num2text(num)]"

ADMIN_VERB(stealth_mode, R_ADMIN, "Stealth Mode", "Toggle stealth.", ADMIN_CATEGORY_MAIN)
	var/datum/admins/holder = user.holder
	if(istype(holder))
		holder.big_brother = FALSE
		if(holder.fakekey)
			holder.fakekey = null
		else
			var/new_key = ckeyEx(tgui_input_text(user, "Enter your desired display name.", "Fake Key", user.key))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			user.createStealthKey()
		log_and_message_admins("has turned stealth mode [holder.fakekey ? "ON with fake key: [holder.fakekey]" : "OFF"]")
	BLACKBOX_LOG_ADMIN_VERB("Stealth Mode")

ADMIN_VERB(big_brother, R_PERMISSIONS, "Big Brother Mode", "Toggle Big Brother mode.", ADMIN_CATEGORY_MAIN)
	var/datum/admins/holder = user.holder
	if(holder)
		if(holder.fakekey)
			holder.fakekey = null
			holder.big_brother = FALSE
		else
			var/new_key = ckeyEx(tgui_input_text(user, "Enter your desired display name. Unlike normal stealth mode, this will not appear in Who at all, except for other heads.", "Fake Key", user.key))
			if(!new_key)
				return
			if(length(new_key) >= 26)
				new_key = copytext(new_key, 1, 26)
			holder.fakekey = new_key
			holder.big_brother = TRUE
			if(isobserver(user.mob))
				user.mob.invisibility = INVISIBILITY_BIG_BROTHER
				user.mob.see_invisible = SEE_INVISIBLE_BIG_BROTHER
			user.createStealthKey()
		log_admin("[key_name(user)] has turned BB mode [holder.fakekey ? "ON" : "OFF"]", TRUE)
		BLACKBOX_LOG_ADMIN_VERB("Big Brother Mode")

#define SMALL_BOMB "Маленькая бомба (1, 2, 3, 3)"
#define MEDIUM_BOMB "Средняя бомба (2, 3, 4, 4)"
#define BIG_BOMB "Большая бомба (3, 5, 7, 5)"
#define CUSTOM_BOMB "Настраиваемая бомба"

ADMIN_VERB(drop_bomb, R_EVENT, "Drop Bomb", "Cause an explosion of varying strength at your location.", ADMIN_CATEGORY_FUN)
	var/turf/epicenter = user.mob.loc
	var/list/choices = list(SMALL_BOMB, MEDIUM_BOMB, BIG_BOMB, CUSTOM_BOMB)
	var/choice = tgui_input_list(user, "Взрыв какого размера вы хотели бы произвести? ПРИМЕЧАНИЕ: Вы можете сделать все это в IC поле (используя крылатые ракеты!) с помощью кнопки Launch Supplypod.", items = choices)
	switch(choice)
		if(null)
			return 0
		if(SMALL_BOMB)
			explosion(epicenter, devastation_range = 1, heavy_impact_range = 2, light_impact_range = 3, flash_range = 3, cause = user.mob)
		if(MEDIUM_BOMB)
			explosion(epicenter, devastation_range = 2, heavy_impact_range = 3, light_impact_range = 4, flash_range = 4, cause = user.mob)
		if(BIG_BOMB)
			explosion(epicenter, devastation_range = 3, heavy_impact_range = 5, light_impact_range = 7, flash_range = 5, cause = user.mob)
		if(CUSTOM_BOMB)
			var/devastation_range = tgui_input_number(user, "Дальность тотального разрушения. (в тайлах):", CUSTOM_BOMB, max_value = 255)
			if(isnull(devastation_range))
				return
			var/heavy_impact_range = tgui_input_number(user, "Дальность сильного удара. (в тайлах):", CUSTOM_BOMB, max_value = 255)
			if(isnull(heavy_impact_range))
				return
			var/light_impact_range = tgui_input_number(user, "Дальность легкого удара. (в тайлах):", CUSTOM_BOMB, max_value = 255)
			if(isnull(light_impact_range))
				return
			var/flash_range = tgui_input_number(user, "Дальность вспышки. (в тайлах):", CUSTOM_BOMB, max_value = 255)
			if(isnull(flash_range))
				return
			explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = TRUE, cause = user.mob)

	message_admins("[ADMIN_LOOKUPFLW(user.mob)] creating an admin explosion at [epicenter.loc].")
	log_admin("[key_name(user)] created an admin explosion at [epicenter.loc].")
	BLACKBOX_LOG_ADMIN_VERB("Drop Bomb")

#undef SMALL_BOMB
#undef MEDIUM_BOMB
#undef BIG_BOMB
#undef CUSTOM_BOMB

ADMIN_VERB(bless, R_EVENT, "Bless", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/living/M as mob)
	if(!istype(M))
		to_chat(user, span_warning("This can only be used on instances of type /mob/living"), confidential = TRUE)
		return
	var/bless_types = list("To Arrivals", "Moderate Heal")
	var/mob/living/carbon/human/H
	if(ishuman(M))
		H = M
		bless_types += "Spawn Cookie"
		bless_types += "Heal Over Time"
		bless_types += "Permanent Regeneration"
		bless_types += "Super Powers"
		bless_types += "Scarab Guardian"
		bless_types += "Human Protector"
		bless_types += "Sentient Pet"
		bless_types += "All Access"
	var/blessing = tgui_input_list(user, "How would you like to bless [M]?", "Its good to be good...", bless_types)
	if(!(blessing in bless_types))
		return
	var/logmsg = null
	switch(blessing)
		if("Spawn Cookie")
			H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_LEFT )
			if(!(istype(H.l_hand,/obj/item/reagent_containers/food/snacks/cookie)))
				H.equip_to_slot_or_del( new /obj/item/reagent_containers/food/snacks/cookie(H), ITEM_SLOT_HAND_RIGHT )
				if(!(istype(H.r_hand,/obj/item/reagent_containers/food/snacks/cookie)))
					log_and_message_admins("tried to spawn for [key_name(H)] a cookie, but their hands were full, so they did not receive their cookie.")
					return
			H.update_held_items()
			logmsg = "spawn cookie."
		if("To Arrivals")
			M.forceMove(pick(GLOB.latejoin))
			to_chat(M, span_userdanger("You are abruptly pulled through space!"), confidential=TRUE)
			logmsg = "a teleport to arrivals."
		if("Moderate Heal")
			var/update = NONE
			update |= M.heal_overall_damage(25, 25, updating_health = FALSE, affect_robotic = TRUE)
			update |= M.heal_damages(tox = 25, oxy = 25, updating_health = FALSE)
			if(update)
				M.updatehealth()
			to_chat(M,span_userdanger("You feel invigorated!"), confidential=TRUE)
			logmsg = "a moderate heal."
		if("Heal Over Time")
			H.reagents.add_reagent("salglu_solution", 30)
			H.reagents.add_reagent("salbutamol", 20)
			H.reagents.add_reagent("spaceacillin", 20)
			logmsg = "a heal over time."
		if("Permanent Regeneration")
			H.force_gene_block(GLOB.regenerateblock, TRUE)
			H.gene_stability = 100
			logmsg = "permanent regeneration."
		if("Super Powers")
			var/list/default_genes = list(GLOB.regenerateblock, GLOB.breathlessblock, GLOB.coldblock)
			for(var/gene in default_genes)
				H.force_gene_block(gene, TRUE)
			H.gene_stability = 100
			logmsg = "superpowers."
		if("Scarab Guardian")
			var/obj/item/guardiancreator/biological/scarab = new /obj/item/guardiancreator/biological(H)
			var/list/possible_guardians = list("Chaos", "Standard", "Ranged", "Support", "Explosive", "Random")
			var/typechoice = tgui_input_list(user, "Select Guardian Type", "Type", possible_guardians)
			if(isnull(typechoice))
				return
			if(typechoice != "Random")
				possible_guardians -= "Random"
				scarab.possible_guardians = list()
				scarab.possible_guardians += typechoice
			scarab.attack_self(H)
			spawn(700)
				qdel(scarab)
			logmsg = "scarab guardian."
		if("Sentient Pet")
			var/pets = subtypesof(/mob/living/simple_animal)
			var/petchoice = tgui_input_list(user, "Select pet type", "Pets", pets)
			if(isnull(petchoice))
				return
			var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Play as the special event pet [H]?", poll_time = 20 SECONDS, min_hours = 10, source = petchoice)
			var/mob/dead/observer/theghost = null

			if(QDELETED(H))
				return

			if(length(candidates))
				var/mob/living/simple_animal/pet/P = new petchoice(H.loc)
				theghost = pick(candidates)
				P.possess_by_player(theghost.key)
				P.master_commander = H
				P.universal_speak = TRUE
				P.universal_understand = TRUE
				P.set_can_collar(TRUE)
				P.faction = list("neutral")
				var/obj/item/clothing/accessory/petcollar/C = new
				P.add_collar(C)
				var/obj/item/card/id/I = H.wear_id
				if(I)
					var/obj/item/card/id/D = new /obj/item/card/id(C)
					D.access = I.access
					D.registered_name = P.name
					D.assignment = "Pet"
					C.access_id = D
				spawn(30)
					var/newname = sanitize(tgui_input_text(P, "You are [P], special event pet of [H]. Change your name to something else?", "Name change", P.name, max_length = MAX_NAME_LEN))
					if(newname && newname != P.name)
						P.name = newname
						if(P.mind)
							P.mind.name = newname
				logmsg = "pet ([P])."
			else
				to_chat(user, span_warning("WARNING: Nobody volunteered to play the special event pet."), confidential=TRUE)
				logmsg = "pet (no volunteers)."
		if("Human Protector")
			user.create_eventmob_for(H, 0)
			logmsg = "syndie protector."
		if("All Access")
			var/obj/item/card/id/I = H.wear_id
			if(I)
				var/list/access_to_give = get_all_accesses()
				for(var/this_access in access_to_give)
					if(!(this_access in I.access))
						// don't have it - add it
						I.access |= this_access
			else
				to_chat(user, span_warning("ERROR: [H] is not wearing an ID card."), confidential = TRUE)
			logmsg = "all access."
	if(logmsg)
		log_and_message_admins("blessed [key_name_log(M)] with: [logmsg]")

ADMIN_VERB(give_spell, R_EVENT, "Give Spell", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/T in GLOB.mob_list)
	var/list/spell_list = list()
	var/type_length = length("/obj/effect/proc_holder/spell") + 2
	for(var/A in GLOB.spells)
		spell_list[copytext("[A]", type_length)] = A
	var/obj/effect/proc_holder/spell/S = tgui_input_list(user, "Choose the spell to give to that guy", "ABRAKADABRA", spell_list)
	if(!S)
		return
	S = spell_list[S]
	if(T.mind)
		T.mind.AddSpell(new S)
	else
		T.AddSpell(new S)

	BLACKBOX_LOG_ADMIN_VERB("Give Spell")
	log_and_message_admins("gave [key_name_log(T)] the spell [S].")

ADMIN_VERB(give_disease, R_EVENT, "Give Disease", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	var/choosen_disease = tgui_input_list(user, "Choose the disease to give to that guy", "ACHOO", GLOB.diseases)
	if(!choosen_disease)
		return

	var/datum/disease/disease = new choosen_disease()
	disease.Contract(target)
	BLACKBOX_LOG_ADMIN_VERB("Give Disease")
	log_and_message_admins("gave [key_name_log(target)] the disease [disease].")

ADMIN_VERB(cure_disease, R_EVENT, "Cure Disease", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target in GLOB.mob_list)
	if(!target.diseases)
		to_chat(user, span_warning("[target] doesn't have any diseases!"))

	var/datum/disease/choosen_disease = tgui_input_list(user, "Choose the disease to cure", "BLESS YA", target.diseases)
	if(!choosen_disease)
		return

	log_and_message_admins("cured [choosen_disease] for [key_name(target)].")
	choosen_disease.cure()

ADMIN_VERB_ONLY_CONTEXT_MENU(make_sound, R_SOUNDS, "Make Sound", obj/target in view())
	if(!target)
		return
	var/message = tgui_input_text(user, "What do you want the message to be?", "Make Sound")
	if(!message)
		return
	for(var/mob/viewer in hearers(target))
		viewer.show_message(admin_pencode_to_html(message), 2)
	log_and_message_admins("made [target] at [AREACOORD(target)] make a sound")
	BLACKBOX_LOG_ADMIN_VERB("Make Sound")

ADMIN_VERB(build_mode_self, R_EVENT, "Toggle Build Mode Self", "Toggle build mode for yourself.", ADMIN_CATEGORY_EVENTS)
	if(user.mob)
		togglebuildmode(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Toggle Build Mode")

ADMIN_VERB_AND_CONTEXT_MENU(object_say, R_EVENT, "OSay", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, msg as text)
	var/datum/component/object_possession/possession_comp = user.mob.GetComponent(/datum/component/object_possession)

	if(!possession_comp || !possession_comp.possessed || !msg)
		return

	for(var/mob/hearer in hearers(possession_comp.possessed))
		hearer.show_message("<b>[possession_comp.possessed.name]</b> says: \"" + msg + "\"", 2)

	log_and_message_admins("[key_name_admin(user)] used OSay on [possession_comp.possessed]: [msg]")
	BLACKBOX_LOG_ADMIN_VERB("OSay")

ADMIN_VERB(deadmin_self, R_ADMIN|R_MENTOR|R_VIEWRUNTIMES, "De-admin self", "De-admin yourself.", ADMIN_CATEGORY_MAIN)
	// TODO: shit code, refactor deadmin
	if(check_rights(R_ADMIN, FALSE))
		GLOB.de_admins |= user.ckey
	else if(check_rights(R_MENTOR, FALSE))
		GLOB.de_mentors |= user.ckey
	else
		GLOB.de_devs |= user.ckey

	user.deadmin()
	add_verb(user, /client/proc/readmin)
	user.update_active_keybindings()
	update_byond_admin_configs(user.ckey, R_NONE)

	to_chat(user, span_interface("You are now a normal player."), confidential=TRUE)
	log_admin("[key_name(user)] deadmined themself.")
	message_admins("[key_name_admin(user)] deadmined themself.")
	BLACKBOX_LOG_ADMIN_VERB("De-admin")

ADMIN_VERB(select_next_map, R_SERVER|R_EVENT, "Select next map", "Select the next map.", ADMIN_CATEGORY_EVENTS)
	var/list/all_maps = subtypesof(/datum/map)
	var/next_map = tgui_input_list(user, "Select next map:", "Next map", all_maps, SSmapping.map_datum.type)
	if(!next_map)
		return

	message_admins("[key_name_admin(user)] select [next_map] as next map")
	log_admin("[key_name(user)] select [next_map] as next map")
	SSmapping.next_map = new next_map
	to_chat(world, "<b>The next map is - [SSmapping.next_map.name]!</b>")

ADMIN_VERB(toggle_log_hrefs, R_SERVER, "Toggle href logging", "Toggle href logging", ADMIN_CATEGORY_DEBUG)
	if(!config)
		return

	if(CONFIG_GET(flag/log_hrefs))
		CONFIG_SET(flag/log_hrefs, FALSE)
		to_chat(user, "<b>Stopped logging hrefs</b>", confidential=TRUE)
	else
		CONFIG_SET(flag/log_hrefs, TRUE)
		to_chat(user, "<b>Started logging hrefs</b>", confidential=TRUE)

ADMIN_VERB(toggle_twitch_censor, R_SERVER, "Toggle Twitch censor", "Toggle Twitch censor.", ADMIN_CATEGORY_TOGGLES)
	if(!config)
		return

	CONFIG_SET(flag/twitch_censor, !CONFIG_GET(flag/twitch_censor))
	to_chat(user, "<b>Twitch censor is [CONFIG_GET(flag/twitch_censor) ? "enabled" : "disabled"]</b>", confidential=TRUE)

ADMIN_VERB(check_ai_laws, R_ADMIN, "Check AI Laws", "View the current AI laws.", ADMIN_CATEGORY_GAME)
	user.holder.output_ai_laws()

ADMIN_VERB(open_law_manager, R_ADMIN, "Manage Silicon Laws", "Open the law manager.", ADMIN_CATEGORY_GAME)
	var/mob/living/silicon/silicon = tgui_input_list(user, "Select silicon.", "Manage Silicon Laws", GLOB.silicon_mob_list)
	if(!silicon)
		return

	var/datum/ui_module/law_manager/law_manager = new(silicon)
	law_manager.ui_interact(user.mob)
	log_and_message_admins("has opened [silicon]'s law manager.")
	BLACKBOX_LOG_ADMIN_VERB("Manage Silicon Laws")

ADMIN_VERB_ONLY_CONTEXT_MENU(change_human_appearance_admin, R_EVENT, "C.M.A. - Admin", mob/living/carbon/human/H in GLOB.mob_list)
	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(user.holder)
		log_and_message_admins("is altering the appearance of [H].")
		H.change_appearance(APPEARANCE_ALL, user.mob, user.mob, check_species_whitelist = 0)
	BLACKBOX_LOG_ADMIN_VERB("CMA - Admin")

ADMIN_VERB_ONLY_CONTEXT_MENU(change_human_appearance_self, R_EVENT, "C.M.A. - Self", mob/living/carbon/human/H in GLOB.mob_list)
	if(!istype(H))
		if(isbrain(H))
			var/mob/living/carbon/brain/B = H
			if(istype(B.container, /obj/item/mmi/robotic_brain/positronic))
				var/obj/item/mmi/robotic_brain/positronic/C = B.container
				var/obj/item/organ/internal/brain/mmi_holder/posibrain/P = C.loc
				if(ishuman(P.owner))
					H = P.owner
			else
				return
		else
			return

	if(!H.client)
		to_chat(user, "Only mobs with clients can alter their own appearance.", confidential=TRUE)
		return

	switch(tgui_alert(user, "Do you wish for [H] to be allowed to select non-whitelisted races?", "Alter Mob Appearance", list("Yes", "No", "Cancel")))
		if("Yes")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, without whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 0)
		if("No")
			log_and_message_admins("has allowed [H] to change [H.p_their()] appearance, with whitelisting of races.")
			H.change_appearance(APPEARANCE_ALL, H.loc, check_species_whitelist = 1)
	BLACKBOX_LOG_ADMIN_VERB("CMA - Self")

ADMIN_VERB(admin_observe_target, R_ADMIN|R_MOD|R_MENTOR, "AObserve", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/target as mob, look_into_inventory = FALSE)
	if(isnewplayer(user.mob))
		to_chat(user, span_warning("Вы не можете а-гостнуться, пока находитесь в лобби. Сначала зайдите в раунд (как игрок или как призрак)."))
		return

	if(isnewplayer(target))
		to_chat(user, span_warning("[target] сейчас находится в лобби."))
		return

	if(!isobserver(user.mob) && !check_rights(R_MENTOR, FALSE, user))
		SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/admin_ghost)

	if(isobserver(user.mob))
		addtimer(CALLBACK(user.mob, TYPE_PROC_REF(/mob, ManualFollow), target), 5 DECISECONDS)

	if(!look_into_inventory)
		return

	if(!target.client)
		to_chat(user, span_warning("[target] не имеет за собой игрока(Disconnected)."))
		return

	if(!isobserver(user.mob) && !check_rights(R_MENTOR, FALSE, user))
		addtimer(CALLBACK(user.mob, TYPE_PROC_REF(/mob/dead/observer, do_observe), target), 10 DECISECONDS)

ADMIN_VERB(free_job_slot, R_ADMIN, "Free Job Slot", "Frees a station job role.", ADMIN_CATEGORY_GAME)
	var/list/jobs = list()
	for(var/datum/job/job in SSjobs.occupations)
		if(job.current_positions >= job.total_positions && job.total_positions != -1)
			jobs += job.title
	if(!length(jobs))
		to_chat(user, "There are no fully staffed jobs.", confidential=TRUE)
		return
	var/selected_job = tgui_input_list(user, "Please select job slot to free", "Free Job Slot", jobs)
	if(selected_job)
		SSjobs.FreeRole(selected_job)
		log_admin("[key_name(user)] has freed a job slot for [selected_job].")
		message_admins("[key_name_admin(user)] has freed a job slot for [selected_job].")
	BLACKBOX_LOG_ADMIN_VERB("Free Job Slot")

ADMIN_VERB(man_up, R_ADMIN, "Man Up", "Tells to man up and deal with it.", ADMIN_CATEGORY_FUN, mob/player_mob as mob in GLOB.player_list)
	to_chat(player_mob, chat_box_notice_thick(span_notice("[span_fontsize4("<b>Man up.<br> Deal with it.</b>")]<br>Move on.")))
	SEND_SOUND(player_mob, sound('sound/voice/manup1.ogg'))

	log_and_message_admins("told [key_name_log(player_mob)] to man up and deal with it.")

ADMIN_VERB(global_man_up, R_ADMIN, "Man Up Global", "Tells EVERYONE to man up and deal with it.", ADMIN_CATEGORY_FUN)
	var/confirm = tgui_alert(user, "Are you sure you want to send the global message?", "Confirm Man Up Global", list("Yes", "No"))
	if(confirm == "Yes")
		var/manned_up_sound = sound('sound/voice/manup1.ogg')
		for(var/sissy in GLOB.player_list)
			to_chat(sissy, chat_box_notice_thick(span_notice("[span_fontsize4("<b>Man up.<br> Deal with it.</b>")]<br>Move on.")))
			SEND_SOUND(sissy, manned_up_sound)

		log_admin("[key_name(user)] told everyone to man up and deal with it.")
		message_admins("[key_name_admin(user)] told everyone to man up and deal with it.")
	BLACKBOX_LOG_ADMIN_VERB("Man Up Global")

ADMIN_VERB(toggle_advanced_interaction, R_ADMIN, "Toggle Advanced Admin Interaction", "Allows you to interact with atoms such as buttons and doors, on top of regular machinery interaction.", ADMIN_CATEGORY_GAME)
	user.advanced_admin_interaction = !user.advanced_admin_interaction

	log_admin("[key_name(user)] has [user.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")
	message_admins("[key_name_admin(user)] has [user.advanced_admin_interaction ? "activated" : "deactivated"] their advanced admin interaction.")

ADMIN_VERB(show_watchlist, R_ADMIN, "Show Watchlist", "Show the watchlist.", ADMIN_CATEGORY_MAIN)
	user.watchlist_show()

ADMIN_VERB(cmd_admin_alert_message, R_ADMIN, "Send Alert Message", ADMIN_VERB_NO_DESCRIPTION, ADMIN_CATEGORY_HIDDEN, mob/about_to_be_banned in GLOB.mob_list)
	if(!ismob(about_to_be_banned))
		return

	var/default_message = "Администратор пытается связаться с Вами! \nОткройте диалоговое окно с администратором, нажав на его сикей в чате, в случае игнорирования, вы можете получить бан!"
	var/custom_message = tgui_input_text(user, "Введите сообщение или используйте стандартное:", "Админ-сообщение", default_message, 500, TRUE)

	if(!custom_message)
		return

	if(custom_message == default_message)
		show_blurb(about_to_be_banned, 15, custom_message, null, "center", "center", COLOR_RED, null, null, 1)
		log_admin("[key_name(user)] sent a default admin alert to [key_name(about_to_be_banned)].")
		message_admins("[key_name(user)] sent a default admin alert to [key_name(about_to_be_banned)].")
		return

	custom_message = strip_html(custom_message, 500)

	var/message_color = tgui_input_color(user, "Выберите цвет сообщения:", "Выбор цвета", COLOR_RED)
	if(isnull(message_color))
		return

	var/speed_choice = tgui_alert(user, "Изменить скорость отображения сообщения? (Нет — стандартная скорость)", null, list("Да", "Нет"))
	if(speed_choice == "Да")
		var/speed_input = tgui_input_text(user, "Введите множитель скорости (0.5 — в 2 раза быстрее, 2 — в 2 раза медленнее):", "Скорость", encode = FALSE)
		if(!speed_input)
			return
		var/speed_mult = text2num(speed_input)
		show_blurb(about_to_be_banned, 15, custom_message, null, "center", "center", message_color, null, null, speed_mult)
	else if(speed_choice == "Нет")
		show_blurb(about_to_be_banned, 15, custom_message, null, "center", "center", message_color, null, null, 1)
	else
		return

	log_admin("[key_name(user)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[custom_message]\".")
	message_admins("[key_name(user)] sent an admin alert to [key_name(about_to_be_banned)] with custom message \"[custom_message]\".")
	BLACKBOX_LOG_ADMIN_VERB("Send Alert Message")

ADMIN_VERB(cmd_admin_alert_message_in_list, R_ADMIN, "Send Alert Message in List", "Send an admin alert to player.", ADMIN_CATEGORY_MAIN)
	var/mob/about_to_be_banned = tgui_input_list(user, "Please, select a player!", "Send Alert Message", GLOB.mob_list)
	if(!about_to_be_banned)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/cmd_admin_alert_message, about_to_be_banned)

ADMIN_VERB(debug_statpanel, R_DEBUG, "Debug Stat Panel", "Toggles local debug of the stat panel.", ADMIN_CATEGORY_DEBUG)
	user.stat_panel.send_message("create_debug")

ADMIN_VERB(force_hijack, R_EVENT, "Toggle Shuttle Force Hijack", "Force shuttle fly to syndicate base.", ADMIN_CATEGORY_TOGGLES)
	var/obj/docking_port/mobile/emergency/shuttle = locate()
	if(!shuttle)
		return

	shuttle.force_hijacked = !shuttle.force_hijacked
	log_and_message_admins("[shuttle.force_hijacked ? "enabled" : "disabled"] forced shuttle hijack.")
	BLACKBOX_LOG_ADMIN_VERB("Shuttle Force Hijack")
