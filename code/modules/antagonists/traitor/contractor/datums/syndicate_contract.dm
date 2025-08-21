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
	var/obj/structure/closet/supplypod/extractionpod/pod = null
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
	///timerid for stuff that handles victim chat messages, effects and returnal
	var/victim_timerid

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
	var/datum/mind/target
	if(target_override)
		contract.target = target_override
		target = target_override
	else
		contract.find_target()
		target = contract.target

	if(!target)
		return

	// In case the contract is invalidated
	contract.extraction_zone = null
	contract.target_blacklist |= target
	for(var/difficulty in EXTRACTION_DIFFICULTY_EASY to EXTRACTION_DIFFICULTY_HARD)
		contract.pick_candidate_zone(difficulty)

	// Fill data
	var/datum/data/record/record = find_record("name", target.name, GLOB.data_core.general)
	target_name = "[record?.fields["name"] || target.current?.real_name || DEFAULT_NAME], the [record?.fields["rank"] || target.assigned_role || DEFAULT_RANK]"
	reward_credits = credits_base * rand(credits_lower_mult, credits_upper_mult)

	// Fluff message
	var/base = pick(strings(CONTRACT_STRINGS_WANTED, "basemessage"))
	var/verb_string = pick(strings(CONTRACT_STRINGS_WANTED, "verb"))
	var/noun = pickweight(strings(CONTRACT_STRINGS_WANTED, "noun"))
	var/location = pickweight(strings(CONTRACT_STRINGS_WANTED, "location"))
	fluff_message = "[base] [verb_string] [noun] [location]."

	// Photo
	if(record?.fields["photo"])
		var/icon/temp = new('icons/turf/floors.dmi', pick("floor", "wood", "darkfull", "stairs"))
		temp.Blend(record.fields["photo"], ICON_OVERLAY)
		target_photo = temp

	// OK
	status = CONTRACT_STATUS_INACTIVE
	fail_reason = ""

	return TRUE

/**
  * Begins the contract if possible.
  *
  * Arguments:
  * * contractor - The contractor.
  * * difficulty - The chosen difficulty level.
  */
/datum/syndicate_contract/proc/initiate(mob/living/contractor, difficulty = EXTRACTION_DIFFICULTY_EASY)
	. = FALSE
	if(status != CONTRACT_STATUS_INACTIVE || !ISINDEXSAFE(reward_tc, difficulty))
		return
	else if(owning_hub.current_contract)
		to_chat(contractor, span_warning("У вас уже есть действующий контракт!"))
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
	clean_up(FALSE)
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
  * * contractor - The contractor.
  */
/datum/syndicate_contract/proc/start_extraction_process(obj/item/contractor_uplink/uplink, mob/living/carbon/human/contractor)
	if(!uplink?.Adjacent(contractor))
		return "Где ваш чёртов аплинк?!"
	else if(status != CONTRACT_STATUS_ACTIVE)
		return "Данный контракт не активен."
	else if(extraction_deadline > world.time)
		return "Новая попытка похищения пока не может быть предпринята."

	var/mob/target = contract.target.current
	if(!target)
		invalidate()
		return "Цель более не фиксируется нашими датчиками. Ваш контракт будет аннулирован и заменён на другой."
	else if(!contract.can_start_extraction_process(contractor, target))
		return "Чтобы начать процесс похищения, вы и цель должны находиться в нужной локации."

	contractor.visible_message(span_notice("[contractor] начина[pluralize_ru(contractor.gender, "ет", "ют")] вводить загадочную серию символов в [uplink.declent_ru(ACCUSATIVE)]..."),\
					  span_notice("Вы начинаете подавать сигнал для эвакуации своим кураторам через [uplink.declent_ru(ACCUSATIVE)]..."))
	if(!do_after(contractor, EXTRACTION_PHASE_PREPARE, contractor))
		return
	if(!uplink.Adjacent(contractor) || extraction_deadline > world.time)
		return
	var/obj/effect/contractor_flare/flare = new(get_turf(contractor))
	extraction_flare = flare
	extraction_deadline = world.time + extraction_cooldown
	contractor.visible_message(span_notice("[contractor] ввод[pluralize_ru(contractor.gender, "ит", "ят")] таинственный код в [uplink.declent_ru(ACCUSATIVE)] и доста[pluralize_ru(contractor.gender, "ёт", "ют")] \
						чёрно-золотую сигнальную ракету, после чего зажига[pluralize_ru(contractor.gender, "ет", "ют")] её."),\
						span_notice("Вы завершаете ввод сигнала в [uplink.declent_ru(ACCUSATIVE)] и зажигаете сигнальную ракету, начиная процесс эвакуации."))
	addtimer(CALLBACK(src, PROC_REF(open_extraction_portal), uplink, contractor, flare), EXTRACTION_PHASE_PORTAL)
	extraction_timer_handle = addtimer(CALLBACK(src, PROC_REF(deadline_reached)), portal_duration, TIMER_STOPPABLE)

/**
  * Opens the extraction portal.
  *
  * Arguments:
  * * uplink - The uplink.
  * * contractor - The contractor.
  * * flare - The flare.
  */
/datum/syndicate_contract/proc/open_extraction_portal(obj/item/contractor_uplink/uplink, mob/living/carbon/human/contractor, obj/effect/contractor_flare/flare)
	if(!uplink || !contractor || status != CONTRACT_STATUS_ACTIVE)
		invalidate()
		return
	else if(!flare)
		uplink.message_holder("Агент, нам не удалось обнаружить [flare.declent_ru(ACCUSATIVE)]. Убедитесь, что зона эвакуации свободна, прежде чем посылать нам сигнал.", 'sound/machines/terminal_prompt_deny.ogg')
		return
	else if(!ismob(contract.target.current))
		invalidate()
		return
	uplink.message_holder("Агент, мы получили сигнал эвакуации. Системы помех, мешающих навигации в секторе станции НСС [SSmapping.map_datum.station_name], были саботированы. "\
				   + "Мы направляем эвакуационную капсулу на место вашей сигнальной ракеты. Поместите цель в капсулу, чтобы завершить процесс эвакуации.", 'sound/effects/confirmdropoff.ogg')
	// Open a portal
	launch_extraction_pod(get_turf(flare))


// Launch the pod to collect our victim.
/datum/syndicate_contract/proc/launch_extraction_pod(turf/empty_pod_turf)
	pod = new()

	RegisterSignal(pod, COMSIG_SUPPLYPOD_ENTERED, PROC_REF(enter_check))
	RegisterSignal(pod, COMSIG_SUPPLYPOD_PRE_RETURN, PROC_REF(on_sypplypod_pre_return))

	pod.stay_after_drop = TRUE
	pod.reversing = TRUE
	pod.leavingSound = 'sound/effects/podwoosh.ogg'

	new /obj/effect/pod_landingzone(empty_pod_turf, pod)

/datum/syndicate_contract/proc/on_sypplypod_pre_return(obj/structure/closet/supplypod/pod)
	SIGNAL_HANDLER
	var/list/cords = pod.reverse_dropoff_coords
	spawn_food(locate(cords[1], cords[2], cords[3]))
	UnregisterSignal(pod, COMSIG_SUPPLYPOD_PRE_RETURN)


/datum/syndicate_contract/proc/check_target(mob/living/sent_mob)

	if(!istype(sent_mob))
		return FALSE

	if(!sent_mob.mind || sent_mob.mind != contract.target)
		return FALSE

	return TRUE

/datum/syndicate_contract/proc/enter_check(datum/source, sent_mob)
	SIGNAL_HANDLER

	if(!istype(source, /obj/structure/closet/supplypod/extractionpod))
		return

	if(!isliving(sent_mob))
		return

	if(!check_target(sent_mob))
		return

	UnregisterSignal(source, COMSIG_SUPPLYPOD_ENTERED)
	var/mob/living/person_sent = sent_mob

	LAZYSET(GLOB.prisoner_belongings.prisoners, person_sent, src)
	remove_victim_items(person_sent, get_turf(source))

	var/obj/structure/closet/supplypod/extractionpod/pod = source
	// Handle the pod returning
	pod.startExitSequence(pod)
	person_sent.buckled?.unbuckle_mob(src)
	person_sent.forceMove(pod)

	// Give some species the necessary to survive. Courtesy of the Syndicate.
	INVOKE_ASYNC(src, PROC_REF(give_important_for_life), person_sent)
	person_sent.update_icons()

	//we'll start the effects in a few seconds since it takes a moment for the pod to leave.
	addtimer(CALLBACK(src, PROC_REF(handle_victim_experience), person_sent), 3 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(finish_enter), person_sent), 3 SECONDS)

/datum/syndicate_contract/proc/finish_enter(mob/living/person_sent)
	complete(person_sent.stat == DEAD)

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


/datum/syndicate_contract/proc/remove_victim_items(mob/living/victim, turf/portal_turf)
	var/mob/living/carbon/human/human_victim = victim
	// Shove all of the victim's items in the secure locker.
	victim_belongings = list()
	var/list/obj/item/stuff_to_transfer = list()

	// Speciall skrell headpocket handling
	var/obj/item/organ/internal/headpocket/headpocket = victim.get_organ_slot(INTERNAL_ORGAN_HEADPOCKET)
	if(headpocket)
		var/turf/target_turf = get_turf(victim)
		for(var/obj/item/item in headpocket.pocket.contents)
			stuff_to_transfer += item
			headpocket.pocket.remove_from_storage(item, target_turf)

	// Cybernetic implants get removed first (to deal with NODROP stuff)
	for(var/obj/item/organ/internal/cyberimp/implant in human_victim.internal_organs)
		// Greys get to keep their implant
		if(istype(implant, /obj/item/organ/internal/cyberimp/mouth/translator/grey_retraslator))
			continue
		// Try removing it
		implant = implant.remove(human_victim)

		if(!implant)
			continue

		stuff_to_transfer += implant

	// Regular items get removed in second
	for(var/obj/item/item in victim.contents)
		// Any items we don't want to take from them?
		if(istype(human_victim))
			// Keep their uniform and shoes
			if(item == human_victim.w_uniform || item == human_victim.shoes)
				continue
			// Plasmamen are no use if they're crispy
			if(isplasmaman(human_victim) && item == human_victim.head)
				continue

		// Any kind of non-syndie implant gets potentially removed (mindshield, etc)
		if(istype(item, /obj/item/implant))
			if(istype(item, /obj/item/implant/storage)) // Storage stays, but items within get confiscated
				var/obj/item/implant/storage/storage_implant = item
				for(var/storage_item in storage_implant.storage)
					storage_implant.storage.remove_from_storage(storage_item)
					stuff_to_transfer += storage_item
				continue
			if(istype(item, /obj/item/implant/uplink)) // Uplink stays, but is jammed while in jail
				var/obj/item/implant/uplink/uplink_implant = item
				uplink_implant.hidden_uplink.is_jammed = TRUE
				continue
			if(is_type_in_typecache(item, implants_to_keep))
				continue
			qdel(item)
			continue

		if(!victim.drop_item_ground(item))
			continue

		stuff_to_transfer += item

	// Remove accessories from the suit if present
	if(LAZYLEN(human_victim.w_uniform?.accessories))
		for(var/obj/item/clothing/accessory/accessory as anything in human_victim.w_uniform.accessories)
			accessory.on_removed()
			accessory.forceMove_turf()
			stuff_to_transfer += accessory

	// Transfer it all (or drop it if not possible)
	for(var/obj/item/item as anything in stuff_to_transfer)
		if(GLOB.prisoner_belongings.give_item(item))
			victim_belongings += item
			continue

		if(!(item.item_flags & ABSTRACT) && !HAS_TRAIT(item, TRAIT_NODROP)) // Anything that can't be put on hold, just drop it on the ground
			item.forceMove(portal_turf)

/datum/syndicate_contract/proc/give_important_for_life(mob/living/carbon/human/human)
	if(!istype(human))
		return

	var/obj/item/tank/internals/emergency_oxygen/tank
	var/obj/item/clothing/mask/breath/mask

	if(isvox(human))
		tank = new /obj/item/tank/internals/emergency_oxygen/nitrogen(human)
		mask = new /obj/item/clothing/mask/breath/vox(human)

	if(isplasmaman(human))
		tank = new /obj/item/tank/internals/emergency_oxygen/plasma(human)
		mask = new /obj/item/clothing/mask/breath(human)

	if(!tank)
		return

	tank.equip_to_best_slot(human)
	mask.equip_to_best_slot(human)
	tank.toggle_internals(human, TRUE)

/datum/syndicate_contract/proc/spawn_food(turf/spawn_turf)
	var/bread_type = (prob(10)) && /obj/item/reagent_containers/food/snacks/breadslice/moldy \
	|| /obj/item/reagent_containers/food/snacks/breadslice/stale
	// Supply them with some chow. How generous is the Syndicate?
	var/obj/item/reagent_containers/food/snacks/breadslice/food = new bread_type(spawn_turf)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/drink = new(spawn_turf)
	drink.reagents.add_reagent("tea", 25) // British coders beware, tea in glasses
	temp_objs = list(food, drink)


#define VICTIM_EXPERIENCE_START 0
#define VICTIM_EXPERIENCE_FIRST_HIT 1
#define VICTIM_EXPERIENCE_SECOND_HIT 2
#define VICTIM_EXPERIENCE_THIRD_HIT 3
#define VICTIM_EXPERIENCE_LAST_HIT 4

/**
 * handle_victim_experience
 *
 * Handles the effects given to victims upon being contracted.
 * We heal them up and cause them immersive effects, just for fun.
 * Args:
 * victim - The person we're harassing
 * level - The current stage of harassement they are facing. This increases by itself, looping until finished.
 */
/datum/syndicate_contract/proc/handle_victim_experience(mob/living/victim, level = VICTIM_EXPERIENCE_START)
	// Ship 'em back - dead or alive
	// Even if they weren't the target, we're still treating them the same.
	if(!level)
		prisoner_timer_handle = addtimer(CALLBACK(src, PROC_REF(handle_target_return), victim), COME_BACK_FROM_CAPTURE_TIME, TIMER_STOPPABLE)

	if(victim.stat == DEAD)
		return

	var/time_until_next
	switch(level)
		if(VICTIM_EXPERIENCE_START)
			// Heal them up - gets them out of crit/soft crit. If omnizine is removed in the future, this needs to be replaced with a
			// method of healing them, consequence free, to a reasonable amount of health.
			victim.reagents.add_reagent(/datum/reagent/medicine/omnizine, amount = 20)
			victim.flash_eyes()
			victim.AdjustConfused(1 SECONDS)
			victim.AdjustEyeBlurry(5 SECONDS)
			to_chat(victim, span_warning("Вы чувствуете себя странно..."))
			time_until_next = 6 SECONDS
		if(VICTIM_EXPERIENCE_FIRST_HIT)
			to_chat(victim, span_warning("Этот под повлиял на вас..."))
			victim.AdjustDizzy(3.5 SECONDS)
			time_until_next = 6.5 SECONDS
		if(VICTIM_EXPERIENCE_SECOND_HIT)
			to_chat(victim, span_warning("Голова болит так сильно... что, кажется, сейчас лопнет!"))
			victim.flash_eyes()
			victim.AdjustConfused(2 SECONDS)
			victim.AdjustEyeBlurry(3 SECONDS)
			time_until_next = 3 SECONDS
		if(VICTIM_EXPERIENCE_THIRD_HIT)
			to_chat(victim, span_warning("Ваша голова раскалывается..."))
			time_until_next = 10 SECONDS
		if(VICTIM_EXPERIENCE_LAST_HIT)
			victim.flash_eyes()
			victim.unconscious(20 SECONDS)
			to_chat(victim, span_specialnotice("Миллионы голосов эхом отдаются в вашей голове... <i>\"В вашем сознании хранилось много ценных секретов — \
					мы благодарим вас за то, что вы их предоставили. Ваша ценность возросла, и вы будете выкуплены обратно на свою станцию. \
					Нам всегда платят, так что отправка вас обратно — лишь вопрос времени...\"</i>"))
			to_chat(victim, span_danger(span_fontsize3("Вас похитили и допросили, чтобы получить ценную информацию! \
					Через несколько минут вас отправят обратно на станцию...")))
			victim.AdjustEyeBlurry(10 SECONDS)
			victim.AdjustDizzy(1.5 SECONDS)
			victim.AdjustConfused(2 SECONDS)

	level++ //move onto the next level.
	if(time_until_next)
		victim_timerid = addtimer(CALLBACK(src, PROC_REF(handle_victim_experience), victim, level), time_until_next, TIMER_STOPPABLE)

#undef VICTIM_EXPERIENCE_START
#undef VICTIM_EXPERIENCE_FIRST_HIT
#undef VICTIM_EXPERIENCE_SECOND_HIT
#undef VICTIM_EXPERIENCE_THIRD_HIT
#undef VICTIM_EXPERIENCE_LAST_HIT

/**
  * Handles the target's return to station.
  *
  * Arguments:
  * * victim - The target mob.
  */
/datum/syndicate_contract/proc/handle_target_return(mob/living/victim)
	var/list/turf/possible_turfs = list()
	for(var/turf/turf in contract.extraction_zone.contents)
		if(!isspaceturf(turf) && !turf.is_blocked_turf())
			possible_turfs += turf

	var/turf/destination = length(possible_turfs) ? pick(possible_turfs) : pick(GLOB.latejoin)

	// Make a closet to return the target and their items neatly
	var/obj/structure/closet/supplypod/back_to_station/return_pod = new()
	return_pod.return_from_capture(victim, destination)

	// Return their items
	for(var/item in victim_belongings)
		var/obj/item/prisoner_item = GLOB.prisoner_belongings.remove_item(item)
		if(!prisoner_item)
			continue
		prisoner_item.forceMove(return_pod)

	victim_belongings = list()

	// Clean up
	var/obj/item/implant/uplink/uplink_implant = locate() in victim
	uplink_implant?.hidden_uplink?.is_jammed = FALSE

	QDEL_LIST(temp_objs)

	// Chance for souvenir or bruises
	if(prob(RETURN_SOUVENIR_CHANCE))
		to_chat(victim, span_notice("Ваши похитители оставили вам сувенир за доставленные вам хлопоты!"))
		var/obj/item/souvenir = pick(souvenirs)
		new souvenir(return_pod)
	else if(prob(RETURN_BRUISE_CHANCE) && victim.health >= 50)
		var/mob/living/carbon/human/human_victim = victim
		if(istype(human_victim))
			to_chat(victim, span_warning("Похитители сильно избили вас, прежде чем отправить обратно!"))
			var/parts_to_fuck_up = pick(BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_HEAD)
			var/obj/item/organ/external/body_part = human_victim.bodyparts_by_name[parts_to_fuck_up]
			if(!body_part)
				body_part = human_victim.bodyparts_by_name[BODY_ZONE_CHEST]
			human_victim.apply_damage(RETURN_BRUISE_DAMAGE, BRUTE, body_part)
			body_part.fracture()
		else
			victim.take_overall_damage(RETURN_BRUISE_DAMAGE)

	// Return them a bit confused.
	victim.visible_message(span_notice("[capitalize(victim.declent_ru(NOMINATIVE))] исчеза[pluralize_ru(victim.gender, "ет", "ют")]..."))
	victim.Paralyse(3 SECONDS)
	victim.EyeBlurry(5 SECONDS)
	victim.AdjustConfused(5 SECONDS)
	victim.Dizzy(70 SECONDS)

	// Newscaster story
	var/datum/data/record/record = find_record("name", contract.target.name, GLOB.data_core.general)
	var/initials = ""
	for(var/string in splittext(record?.fields["name"] || victim.real_name || DEFAULT_NAME, " "))
		initials = initials + "[string[1]]."

	var/datum/feed_message/news_message = new
	news_message.author = NEWS_CHANNEL_NYX
	news_message.admin_locked = TRUE
	news_message.body = "В системе зафиксирована подозрительная активность, предположительно связанная с Синдикатом. Появились слухи о том, что [record?.fields["rank"] || victim?.mind.assigned_role || DEFAULT_RANK] на борту [SSmapping.map_datum.station_name] стал жертвой похищения.\n\n" +\
				"Надёжный источник сообщил следующее: Была найдена записка с инициалами жертвы — \"[initials]\", а также каракулями, гласящими: \"[fluff_message]\""
	GLOB.news_network.get_channel_by_name("Никс Дейли")?.add_message(news_message)

	// Bonus story if the contractor has done all their contracts (appears only once per round)
	if(!nt_am_board_resigned && (owning_hub.completed_contracts >= owning_hub.num_contracts))
		nt_am_board_resigned = TRUE

		var/datum/feed_message/second_news_message = new
		second_news_message.author = NEWS_CHANNEL_NYX
		second_news_message.admin_locked = TRUE
		second_news_message.body = "Совет по управлению активами НаноТрейзен сегодня ушёл в отставку после серии похищений на борту [SSmapping.map_datum.station_name]." +\
					"Один из бывших членов совета заявил: – Я больше не могу этого выносить. Как одна смена на этой проклятой станции может обойтись нам более чем в десять миллионов кредитов в виде выкупов? Неужели на борту совсем нет службы безопасности?!\""
		GLOB.news_network.get_channel_by_name("Никс Дейли")?.add_message(second_news_message)

	for(var/obj/machinery/newscaster/newscaster as anything in GLOB.allNewscasters)
		newscaster.alert_news(NEWS_CHANNEL_NYX)

	prisoner_timer_handle = null
	GLOB.prisoner_belongings.prisoners[victim] = null

/**
  * Called when the extraction window closes.
  */
/datum/syndicate_contract/proc/deadline_reached()
	clean_up()
	owning_hub.contractor_uplink?.message_holder("Окно эвакуации закрылось, агент. Капсула возвращается на базу. Вам придется начать процесс эвакуации ещё раз, чтобы мы могли направить ее еще раз.")
	SStgui.update_uis(owning_hub)

/**
  * Cleans up the contract.
  */
/datum/syndicate_contract/proc/clean_up(clean_pod = TRUE)
	QDEL_NULL(extraction_flare)
	if(clean_pod)
		pod.reversing = FALSE
		pod.startExitSequence(pod)
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
