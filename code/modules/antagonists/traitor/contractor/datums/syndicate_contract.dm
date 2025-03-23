#define DEFAULT_NAME "Unknown"
#define DEFAULT_RANK "Unknown"
#define EXTRACTION_PHASE_PREPARE 5 SECONDS
#define EXTRACTION_PHASE_PORTAL 5 SECONDS
#define COMPLETION_NOTIFY_DELAY 5 SECONDS
#define RETURN_BRUISE_CHANCE 80
#define RETURN_BRUISE_DAMAGE 40
#define RETURN_SOUVENIR_CHANCE 10

/**
  * # Syndicate Contract
  *
  * Describes a contract that can be completed by a [/datum/antagonist/contractor].
  */
/datum/syndicate_contract
	// Settings
	/// Cooldown before making another extraction request in deciseconds.
	var/extraction_cooldown = 10 MINUTES
	/// How long an extraction portal remains before going away. Should be less than [/datum/syndicate_contract/var/extraction_cooldown].
	var/portal_duration = 5 MINUTES
	/// How long a target remains in the Syndicate jail.
	var/prison_time = 4 MINUTES
	/// List of items a target can get randomly after their return.
	var/list/obj/item/souvenirs = list(
		/obj/item/bedsheet/syndie,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/coin/antagtoken/syndicate,
		/obj/item/poster/syndicate_recruitment,
		/obj/item/reagent_containers/food/snacks/syndicake,
		/obj/item/reagent_containers/food/snacks/tatortot,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/storage/fancy/cigarettes/cigpack_syndicate,
		/obj/item/toy/figure/syndie,
		/obj/item/toy/nuke,
		/obj/item/toy/plushie/nukeplushie,
		/obj/item/toy/sword,
		/obj/item/toy/syndicateballoon,
	)
	/// The base credits reward upon completion. Multiplied by the two lower bounds below.
	var/credits_base = 100
	// The lower bound of the credits reward multiplier.
	var/credits_lower_mult = 50
	// The upper bound of the credits reward multiplier.
	var/credits_upper_mult = 75
	// Implants (non cybernetic ones) that shouldn't be removed when a victim gets kidnapped.
	// Typecache; initialized in New()
	var/static/implants_to_keep = null
	// Variables
	/// The owning contractor hub.
	var/datum/contractor_hub/owning_hub = null
	/// The [/datum/objective/contract] associated to this contract.
	var/datum/objective/contract/contract = null
	/// Current contract status.
	var/status = CONTRACT_STATUS_INVALID
	/// Formatted station time at which the contract was completed, if applicable.
	var/completed_time
	/// Whether the contract was completed with the victim being dead on extraction.
	var/dead_extraction = FALSE
	/// Visual reason as to why the contract failed, if applicable.
	var/fail_reason
	/// The selected difficulty.
	var/chosen_difficulty = -1
	/// The flare indicating the extraction point.
	var/obj/effect/contractor_flare/extraction_flare = null
	/// The extraction portal.
	var/obj/effect/portal/redspace/contractor/extraction_portal = null
	/// The world.time at which the current extraction fulton will vanish and another extraction can be requested.
	var/extraction_deadline = -1
	/// Name of the target to display on the UI.
	var/target_name
	/// Fluff message explaining why the kidnapee is the target.
	var/fluff_message
	/// The target's photo to display on the UI.
	var/image/target_photo = null
	/// Amount of telecrystals the contract will receive upon completion, depending on the chosen difficulty.
	/// Structure: EXTRACTION_DIFFICULTY_(EASY|MEDIUM|HARD) => number
	var/list/reward_tc = null
	/// Amount of credits the contractor will receive upon completion.
	var/reward_credits = 0
	/// The kidnapee's belongings. Set upon extraction by the contractor.
	var/list/obj/item/victim_belongings = null
	/// Temporary objects that are available to the kidnapee during their time in jail. These are deleted when the victim is returned.
	var/list/obj/temp_objs = null
	/// Deadline reached timer handle. Deletes the portal and tells the agent to call extraction again.
	var/extraction_timer_handle = null
	/// Prisoner jail timer handle. On completion, returns the prisoner back to station.
	var/prisoner_timer_handle = null
	/// Whether the additional fluff story from any contractor completing all of their contracts was made already or not.
	var/static/nt_am_board_resigned = FALSE

/datum/syndicate_contract/New(datum/contractor_hub/hub, datum/mind/owner, list/datum/mind/target_blacklist, target_override)
	// Init settings
	if(!implants_to_keep)
		implants_to_keep = typecacheof(list(
			// These two are specifically handled in code to prevent usage, but are included here for clarity.
			/obj/item/implant/storage,
			/obj/item/implant/uplink,
			// The rest
			/obj/item/implant/adrenalin,
			/obj/item/implant/emp,
			/obj/item/implant/explosive,
			/obj/item/implant/freedom,
			/obj/item/implant/traitor,
		))
	// Initialize
	owning_hub = hub
	contract = new /datum/objective/contract(src)
	contract.owner = owner
	contract.target_blacklist = target_blacklist
	generate(target_override)

/**
  * Fills the contract with valid data to be used.
  */
/datum/syndicate_contract/proc/generate(target_override)
	. = FALSE
	// Select the target
	var/datum/mind/T
	if(target_override)
		contract.target = target_override
		T = target_override
	else
		contract.find_target()
		T = contract.target
	if(!T)
		return

	// In case the contract is invalidated
	contract.extraction_zone = null
	contract.target_blacklist |= T
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		contract.pick_candidate_zone(difficulty)

	// Fill data
	var/datum/data/record/R = find_record("name", T.name, GLOB.data_core.general)
	target_name = "[R?.fields["name"] || T.current?.real_name || DEFAULT_NAME], the [R?.fields["rank"] || T.assigned_role || DEFAULT_RANK]"
	reward_credits = credits_base * rand(credits_lower_mult, credits_upper_mult)

	// Fluff message
	var/base = pick(strings(CONTRACT_STRINGS_WANTED, "basemessage"))
	var/verb_string = pick(strings(CONTRACT_STRINGS_WANTED, "verb"))
	var/noun = pickweight(strings(CONTRACT_STRINGS_WANTED, "noun"))
	var/location = pickweight(strings(CONTRACT_STRINGS_WANTED, "location"))
	fluff_message = "[base] [verb_string] [noun] [location]."

	// Photo
	if(R?.fields["photo"])
		var/icon/temp = new('icons/turf/floors.dmi', pick("floor", "wood", "darkfull", "stairs"))
		temp.Blend(R.fields["photo"], ICON_OVERLAY)
		target_photo = temp

	// OK
	status = CONTRACT_STATUS_INACTIVE
	fail_reason = ""

	return TRUE

/**
  * Begins the contract if possible.
  *
  * Arguments:
  * * M - The contractor.
  * * difficulty - The chosen difficulty level.
  */
/datum/syndicate_contract/proc/initiate(mob/living/M, difficulty = EXTRACTION_DIFFICULTY_EASY)
	. = FALSE
	if(status != CONTRACT_STATUS_INACTIVE || !ISINDEXSAFE(reward_tc, difficulty))
		return
	else if(owning_hub.current_contract)
		to_chat(M, span_warning("У вас уже есть действующий контракт!"))
		return

	if(!contract.choose_difficulty(difficulty, src))
		return FALSE

	status = CONTRACT_STATUS_ACTIVE
	chosen_difficulty = difficulty
	owning_hub.current_contract = src
	owning_hub.contractor_uplink?.message_holder("Запрос на этот контракт подтверждён. Удачи, агент!", 'sound/machines/terminal_prompt.ogg')

	return TRUE

/**
  * Marks the contract as completed and gives the rewards to the contractor.
  *
  * Arguments:
  * * target_dead - Whether the target was extracted dead.
  */
/datum/syndicate_contract/proc/complete(target_dead = FALSE)
	if(status != CONTRACT_STATUS_ACTIVE)
		return
	var/final_tc_reward = reward_tc[chosen_difficulty]
	if(target_dead)
		final_tc_reward = CEILING(final_tc_reward * owning_hub.dead_penalty, 1)
	// Notify the Hub
	owning_hub.on_completion(final_tc_reward, reward_credits)
	// Finalize
	status = CONTRACT_STATUS_COMPLETED
	completed_time = station_time_timestamp()
	dead_extraction = target_dead
	addtimer(CALLBACK(src, PROC_REF(notify_completion), final_tc_reward, reward_credits, target_dead), COMPLETION_NOTIFY_DELAY)

/**
  * Marks the contract as invalid and effectively cancels it for later use.
  */
/datum/syndicate_contract/proc/invalidate()
	if(!owning_hub)
		return
	if(status in list(CONTRACT_STATUS_COMPLETED, CONTRACT_STATUS_FAILED))
		return

	clean_up()

	var/pre_text
	if(src == owning_hub.current_contract)
		owning_hub.current_contract = null
		pre_text = "Агент, цель вашего похищения более недоступна."
	else
		pre_text = "Агент, неактивный контракт более не может быть выполнен, так как цель исчезла с наших сенсоров."

	var/outcome_text
	if(generate())
		status = CONTRACT_STATUS_INACTIVE
		outcome_text = "К счастью, на станции есть ещё одна цель, которую мы можем похитить. Новый контракт можно получить в аплинке."
	else
		// Too bad.
		status = CONTRACT_STATUS_INVALID
		outcome_text = "К сожалению, мы не смогли найти другую цель для похищения и поэтому не можем предоставить вам ещё один контракт."

	if(owning_hub.contractor_uplink)
		owning_hub.contractor_uplink.message_holder("[pre_text] [outcome_text]", 'sound/machines/terminal_prompt_deny.ogg')
		SStgui.update_uis(owning_hub)

/**
  * Marks the contract as failed and stops it.
  *
  * Arguments:
  * * difficulty - The visual reason as to why the contract failed.
  */
/datum/syndicate_contract/proc/fail(reason)
	if(status != CONTRACT_STATUS_ACTIVE)
		return

	// Update info
	owning_hub.current_contract = null
	status = CONTRACT_STATUS_FAILED
	fail_reason = reason
	// Notify
	clean_up()
	owning_hub.contractor_uplink?.message_holder("Вам не удалось похитить цель, агент. Впредь постарайтесь так не разочаровывать нас!", 'sound/machines/terminal_prompt_deny.ogg')

/**
  * Initiates the extraction process if conditions are met.
  *
  * Arguments:
  * * M - The contractor.
  */
/datum/syndicate_contract/proc/start_extraction_process(obj/item/contractor_uplink/U, mob/living/carbon/human/M)
	if(!U?.Adjacent(M))
		return "Где ваш чёртов аплинк?!"
	else if(status != CONTRACT_STATUS_ACTIVE)
		return "Данный контракт не активен."
	else if(extraction_deadline > world.time)
		return "Новая попытка похищения пока не может быть предпринята."

	var/mob/target = contract.target.current
	if(!target)
		invalidate()
		return "Цель более не фиксируется нашими датчиками. Ваш контракт будет аннулирован и заменён на другой."
	else if(!contract.can_start_extraction_process(M, target))
		return "Чтобы начать процесс похищения, вы и цель должны находиться в нужной локации."

	M.visible_message(span_notice("[M] начина[pluralize_ru(M.gender, "ет", "ют")] вводить загадочную серию символов в [U.declent_ru(ACCUSATIVE)]..."),\
					  span_notice("Вы начинаете подавать сигнал для эвакуации своим кураторам через [U.declent_ru(ACCUSATIVE)]..."))
	if(do_after(M, EXTRACTION_PHASE_PREPARE, M))
		if(!U.Adjacent(M) || extraction_deadline > world.time)
			return
		var/obj/effect/contractor_flare/F = new(get_turf(M))
		extraction_flare = F
		extraction_deadline = world.time + extraction_cooldown
		M.visible_message(span_notice("[M] ввод[pluralize_ru(M.gender, "ит", "ят")] таинственный код в [U.declent_ru(ACCUSATIVE)] и доста[pluralize_ru(M.gender, "ёт", "ют")] \
							чёрно-золотую сигнальную ракету, после чего зажига[pluralize_ru(M.gender, "ет", "ют")] её."),\
						  span_notice("Вы завершаете ввод сигнала в [U.declent_ru(ACCUSATIVE)] и зажигаете сигнальную ракету, начиная процесс эвакуации."))
		addtimer(CALLBACK(src, PROC_REF(open_extraction_portal), U, M, F), EXTRACTION_PHASE_PORTAL)
		extraction_timer_handle = addtimer(CALLBACK(src, PROC_REF(deadline_reached)), portal_duration, TIMER_STOPPABLE)

/**
  * Opens the extraction portal.
  *
  * Arguments:
  * * U - The uplink.
  * * M - The contractor.
  * * F - The flare.
  */
/datum/syndicate_contract/proc/open_extraction_portal(obj/item/contractor_uplink/U, mob/living/carbon/human/M, obj/effect/contractor_flare/F)
	if(!U || !M || status != CONTRACT_STATUS_ACTIVE)
		invalidate()
		return
	else if(!F)
		U.message_holder("Агент, нам не удалось обнаружить [F.declent_ru(ACCUSATIVE)]. Убедитесь, что зона эвакуации свободна, прежде чем посылать нам сигнал.", 'sound/machines/terminal_prompt_deny.ogg')
		return
	else if(!ismob(contract.target.current))
		invalidate()
		return
	U.message_holder("Агент, мы получили сигнал эвакуации. Системы помех блюспейс транспорту на борту НСС [SSmapping.map_datum.station_name], были саботированы. "\
			 	   + "Мы открыли временный портал на месте вашей сигнальной ракеты. Поместите цель в портал, чтобы завершить процесс эвакуации.", 'sound/effects/confirmdropoff.ogg')
	// Open a portal
	var/obj/effect/portal/redspace/contractor/P = new(get_turf(F), pick(GLOB.syndieprisonwarp), F, 0, M)
	P.contract = src
	P.contractor_mind = M.mind
	P.target_mind = contract.target
	extraction_portal = P
	do_sparks(4, FALSE, P.loc)

/**
  * Called when a contract target has been extracted through the portal.
  *
  * Arguments:
  * * M - The target mob.
  * * P - The extraction portal.
  */
/datum/syndicate_contract/proc/target_received(mob/living/M, obj/effect/portal/redspace/contractor/P)
	INVOKE_ASYNC(src, PROC_REF(clean_up))
	complete(M.stat == DEAD)
	handle_target_experience(M, P)

/**
  * Notifies the uplink's holder that a contract has been completed.
  *
  * Arguments:
  * * tc - How many telecrystals they have received.
  * * creds - How many credits they have received.
  * * target_dead - Whether the target was extracted dead.
  */
/datum/syndicate_contract/proc/notify_completion(tc, creds, target_dead)
	var/penalty_text = ""
	if(target_dead)
		penalty_text = " (штраф применяется, если цель была эвакуирована мёртвой)"
	owning_hub.contractor_uplink?.message_holder("Отличная работа, агент! Цель доставлена и в ближайшее время её обработают, после чего отправят обратно. "\
									 + "Как и было оговорено, вам начислено [tc] ТК[penalty_text] и [creds] кредит[declension_ru(creds, "", "а", "ов")].", 'sound/machines/terminal_prompt_confirm.ogg')

/**
  * Handles the target's experience from extraction.
  *
  * Arguments:
  * * M - The target mob.
  * * P - The extraction portal.
  */
/datum/syndicate_contract/proc/handle_target_experience(mob/living/M, obj/effect/portal/redspace/contractor/P)
	var/turf/T = get_turf(P)
	var/mob/living/carbon/human/H = M

	// Prepare their return
	prisoner_timer_handle = addtimer(CALLBACK(src, PROC_REF(handle_target_return), M, T), prison_time, TIMER_STOPPABLE)
	LAZYSET(GLOB.prisoner_belongings.prisoners, M, src)

	// Shove all of the victim's items in the secure locker.
	victim_belongings = list()
	var/list/obj/item/stuff_to_transfer = list()

	// Speciall skrell headpocket handling
	var/obj/item/organ/internal/headpocket/headpocket = M.get_organ_slot(INTERNAL_ORGAN_HEADPOCKET)
	if(headpocket)
		var/turf/target_turf = get_turf(M)
		for(var/obj/item/item in headpocket.pocket.contents)
			stuff_to_transfer += item
			headpocket.pocket.remove_from_storage(item, target_turf)

	// Cybernetic implants get removed first (to deal with NODROP stuff)
	for(var/obj/item/organ/internal/cyberimp/I in H.internal_organs)
		// Greys get to keep their implant
		if(istype(I, /obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator))
			continue
		// Try removing it
		I = I.remove(H)
		if(I)
			stuff_to_transfer += I

	// Regular items get removed in second
	for(var/obj/item/I in M)
		// Any items we don't want to take from them?
		if(istype(H))
			// Keep their uniform and shoes
			if(I == H.w_uniform || I == H.shoes)
				continue
			// Plasmamen are no use if they're crispy
			if(isplasmaman(H) && I == H.head)
				continue

		// Any kind of non-syndie implant gets potentially removed (mindshield, etc)
		if(istype(I, /obj/item/implant))
			if(istype(I, /obj/item/implant/storage)) // Storage stays, but items within get confiscated
				var/obj/item/implant/storage/storage_implant = I
				for(var/it in storage_implant.storage)
					storage_implant.storage.remove_from_storage(it)
					stuff_to_transfer += it
				continue
			else if(istype(I, /obj/item/implant/uplink)) // Uplink stays, but is jammed while in jail
				var/obj/item/implant/uplink/uplink_implant = I
				uplink_implant.hidden_uplink.is_jammed = TRUE
				continue
			else if(is_type_in_typecache(I, implants_to_keep))
				continue
			qdel(I)
			continue

		if(M.drop_item_ground(I))
			stuff_to_transfer += I

	// Remove accessories from the suit if present
	if(LAZYLEN(H.w_uniform?.accessories))
		for(var/obj/item/clothing/accessory/accessory as anything in H.w_uniform.accessories)
			accessory.on_removed()
			accessory.forceMove_turf()
			stuff_to_transfer += accessory

	// Transfer it all (or drop it if not possible)
	for(var/i in stuff_to_transfer)
		var/obj/item/I = i
		if(GLOB.prisoner_belongings.give_item(I))
			victim_belongings += I
		else if(!(I.item_flags & ABSTRACT) && !HAS_TRAIT(I, TRAIT_NODROP)) // Anything that can't be put on hold, just drop it on the ground
			I.forceMove(T)

	// Give some species the necessary to survive. Courtesy of the Syndicate.
	if(istype(H))
		var/obj/item/tank/internals/emergency_oxygen/tank
		var/obj/item/clothing/mask/breath/mask
		if(isvox(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/nitrogen(H)
			mask = new /obj/item/clothing/mask/breath/vox(H)
		else if(isplasmaman(H))
			tank = new /obj/item/tank/internals/emergency_oxygen/plasma(H)
			mask = new /obj/item/clothing/mask/breath(H)

		if(tank)
			tank.equip_to_best_slot(H)
			mask.equip_to_best_slot(H)
			tank.toggle_internals(H, TRUE)

	M.update_icons()

	// Supply them with some chow. How generous is the Syndicate?
	var/obj/item/reagent_containers/food/snacks/breadslice/food = new(get_turf(M))
	food.name = "stale bread"
	food.desc = "Похоже, ваши похитители позаботились о вашем питании."
	food.ru_names = list(
		NOMINATIVE = "чёрствый хлеб",
		GENITIVE = "чёрствого хлеба",
		DATIVE = "чёрствому хлебу",
		ACCUSATIVE = "чёрствый хлеб",
		INSTRUMENTAL = "чёрствым хлебом",
		PREPOSITIONAL = "чёрством хлебе"
	)
	food.gender = MALE
	food.trash = null
	food.reagents.add_reagent("nutriment", 5) // It may be stale, but it still has to be nutritive enough for the whole duration!
	if(prob(10))
		// Mold adds a bit of spice to it
		food.name = "moldy bread"
		food.ru_names = list(
			NOMINATIVE = "заплесневелый хлеб",
			GENITIVE = "заплесневелого хлеба",
			DATIVE = "заплесневелому хлебу",
			ACCUSATIVE = "заплесневелый хлеб",
			INSTRUMENTAL = "заплесневелым хлебом",
			PREPOSITIONAL = "заплесневелом хлебе"
		)
		food.gender = MALE
		food.reagents.add_reagent("fungus", 1)

	var/obj/item/reagent_containers/food/drinks/drinkingglass/drink = new(get_turf(M))
	drink.reagents.add_reagent("tea", 25) // British coders beware, tea in glasses

	temp_objs = list(food, drink)

	// Narrate their kidnapping and torturing experience.
	if(M.stat != DEAD)
		// Heal them up - gets them out of crit/soft crit.
		M.reagents.add_reagent("omnizine", 20)

		to_chat(M, span_warning("Вы чувствуете себя странно..."))
		M.Paralyse(30 SECONDS)
		M.EyeBlind(35 SECONDS)
		M.EyeBlurry(35 SECONDS)
		M.AdjustConfused(35 SECONDS)

		sleep(6 SECONDS)
		to_chat(M, span_warning("Этот портал повлиял на вас..."))

		sleep(6.5 SECONDS)
		to_chat(M, span_warning("Голова болит так сильно... что, кажется, сейчас лопнет!"))

		sleep(3 SECONDS)
		to_chat(M, span_warning("Голова раскалывается..."))

		sleep(10 SECONDS)
		to_chat(M, span_specialnotice("Миллионы голосов эхом отдаются в вашей голове... <i>\"В вашем сознании хранилось много ценных секретов — \
					мы благодарим вас за то, что вы их предоставили. Ваша ценность возросла, и вы будете выкуплены обратно на свою станцию. \
					Нам всегда платят, так что отправка вас обратно — лишь вопрос времени...\"</i>"))

		to_chat(M, span_danger("<font size=3>Вас похитили и допросили, чтобы получить ценную информацию! \
					Через несколько минут вас отправят обратно на станцию...</font>"))

/**
  * Handles the target's return to station.
  *
  * Arguments:
  * * M - The target mob.
  */
/datum/syndicate_contract/proc/handle_target_return(mob/living/M)
	var/list/turf/possible_turfs = list()
	for(var/turf/T in contract.extraction_zone.contents)
		if(!isspaceturf(T) && !T.is_blocked_turf())
			possible_turfs += T

	var/turf/destination = length(possible_turfs) ? pick(possible_turfs) : pick(GLOB.latejoin)

	// Make a closet to return the target and their items neatly
	var/obj/structure/closet/closet = new
	closet.forceMove(destination)

	// Return their items
	for(var/i in victim_belongings)
		var/obj/item/I = GLOB.prisoner_belongings.remove_item(i)
		if(!I)
			continue
		I.forceMove(closet)

	victim_belongings = list()

	// Clean up
	var/obj/item/implant/uplink/uplink_implant = locate() in M
	uplink_implant?.hidden_uplink?.is_jammed = FALSE

	QDEL_LIST(temp_objs)

	// Chance for souvenir or bruises
	if(prob(RETURN_SOUVENIR_CHANCE))
		to_chat(M, span_notice("Ваши похитители оставили вам сувенир за доставленные вам хлопоты!"))
		var/obj/item/souvenir = pick(souvenirs)
		new souvenir(closet)
	else if(prob(RETURN_BRUISE_CHANCE) && M.health >= 50)
		var/mob/living/carbon/human/H = M
		if(istype(H))
			to_chat(M, span_warning("Похитители сильно избили вас, прежде чем отправить обратно!"))
			var/parts_to_fuck_up = pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
			var/obj/item/organ/external/BP = H.bodyparts_by_name[parts_to_fuck_up]
			if(!BP)
				BP = H.bodyparts_by_name[BODY_ZONE_CHEST]
			H.apply_damage(RETURN_BRUISE_DAMAGE, BRUTE, BP)
			BP.fracture()
		else
			M.take_overall_damage(RETURN_BRUISE_DAMAGE)

	// Return them a bit confused.
	M.visible_message(span_notice("[M] исчеза[pluralize_ru(M.gender, "ет", "ют")]..."))
	M.forceMove(closet)
	M.Paralyse(3 SECONDS)
	M.EyeBlurry(5 SECONDS)
	M.AdjustConfused(5 SECONDS)
	M.Dizzy(70 SECONDS)
	do_sparks(4, FALSE, destination)

	// Newscaster story
	var/datum/data/record/R = find_record("name", contract.target.name, GLOB.data_core.general)
	var/initials = ""
	for(var/s in splittext(R?.fields["name"] || M.real_name || DEFAULT_NAME, " "))
		initials = initials + "[s[1]]."

	var/datum/feed_message/FM = new
	FM.author = NEWS_CHANNEL_NYX
	FM.admin_locked = TRUE
	FM.body = "В системе зафиксирована подозрительная активность, предположительно связанная с Синдикатом. Появились слухи о том, что [R?.fields["rank"] || M?.mind.assigned_role || DEFAULT_RANK] на борту [SSmapping.map_datum.station_name] стал жертвой похищения.\n\n" +\
				"Надёжный источник сообщил следующее: Была найдена записка с инициалами жертвы — \"[initials]\", а также каракулями, гласящими: \"[fluff_message]\""
	GLOB.news_network.get_channel_by_name("Никс Дейли")?.add_message(FM)

	// Bonus story if the contractor has done all their contracts (appears only once per round)
	if(!nt_am_board_resigned && (owning_hub.completed_contracts >= owning_hub.num_contracts))
		nt_am_board_resigned = TRUE

		var/datum/feed_message/FM2 = new
		FM2.author = NEWS_CHANNEL_NYX
		FM2.admin_locked = TRUE
		FM2.body = "Совет по управлению активами НаноТрейзен сегодня ушёл в отставку после серии похищений на борту [SSmapping.map_datum.station_name]." +\
					"Один из бывших членов совета заявил: – Я больше не могу этого выносить. Как одна смена на этой проклятой станции может обойтись нам более чем в десять миллионов кредитов в виде выкупов? Неужели на борту совсем нет службы безопасности?!\""
		GLOB.news_network.get_channel_by_name("Никс Дейли")?.add_message(FM2)

	for(var/nc in GLOB.allNewscasters)
		var/obj/machinery/newscaster/NC = nc
		NC.alert_news(NEWS_CHANNEL_NYX)

	prisoner_timer_handle = null
	GLOB.prisoner_belongings.prisoners[M] = null

/**
  * Called when the extraction window closes.
  */
/datum/syndicate_contract/proc/deadline_reached()
	clean_up()
	owning_hub.contractor_uplink?.message_holder("Окно эвакуации закрылось, как и портал, агент. Вам придется начать процесс эвакуации ещё раз, чтобы мы могли открыть новый портал.")
	SStgui.update_uis(owning_hub)

/**
  * Cleans up the contract.
  */
/datum/syndicate_contract/proc/clean_up()
	QDEL_NULL(extraction_flare)
	QDEL_NULL(extraction_portal)
	deltimer(extraction_timer_handle)
	extraction_deadline = -1
	extraction_timer_handle = null

#undef DEFAULT_NAME
#undef DEFAULT_RANK
#undef EXTRACTION_PHASE_PREPARE
#undef EXTRACTION_PHASE_PORTAL
#undef COMPLETION_NOTIFY_DELAY
#undef RETURN_BRUISE_CHANCE
#undef RETURN_BRUISE_DAMAGE
#undef RETURN_SOUVENIR_CHANCE
