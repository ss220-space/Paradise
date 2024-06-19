/datum/job

	//The name of the job
	var/title = "NOPE"

	//Job access. The use of minimal_access or access is determined by a config setting: CONFIG_GET(flag/jobs_have_minimal_access)
	var/list/minimal_access = list()		//Useful for servers which prefer to only have access given to the places a job absolutely needs (Larger server population)
	var/list/access = list()				//Useful for servers which either have fewer players, so each person needs to fill more than one role, or servers which like to give more access, so players can't hide forever in their super secure departments (I'm looking at you, chemistry!)

	//Bitflags for the job
	var/flag = 0
	var/department_flag = 0
	var/department_head = list()

	//How many players can be this job
	var/total_positions = 0

	//How many players can spawn in as this job
	var/spawn_positions = 0

	//Position count override from config/jobs.txt and jobs_highpop.txt
	var/positions_lowpop = null
	var/positions_highpop = null

	//How many players have this job
	var/current_positions = 0

	//Supervisors, who this person answers to directly
	var/supervisors = ""

	//Sellection screen color
	var/selection_color = "#ffffff"

	//List of alternate titles, if any
	var/list/alt_titles

	//If this is set to 1, a text is printed to the player when jobs are assigned, telling him that he should let admins know that he has to disconnect.
	var/req_admin_notify

	//Various Departmental identifiers
	var/is_supply
	var/is_service
	var/is_command
	var/is_legal
	var/is_engineering
	var/is_medical
	var/is_science
	var/is_security
	var/is_novice

	//If you have use_age_restriction_for_jobs config option enabled and the database set up, this option will add a requirement for players to be at least minimal_player_age days old. (meaning they first signed in at least that many days before.)
	var/minimal_player_age = 0

	var/exp_requirements = 0
	var/exp_type = ""
	var/exp_max = 0	//Max EXP, then hide
	var/exp_type_max = ""

	var/min_age_allowed = 0
	var/disabilities_allowed = 1
	var/transfer_allowed = TRUE // If false, ID computer will always discourage transfers to this job, even if player is eligible
	var/hidden_from_job_prefs = FALSE // if true, job preferences screen never shows this job.

	var/admin_only = 0
	var/spawn_ert = 0
	var/syndicate_command = 0

	var/money_factor = 1 // multiplier of starting funds
	var/random_money_factor = FALSE // is miltiplier randomized (from 4x to 0.25x for now)

	var/outfit = null

	/////////////////////////////////
	// /vg/ feature: Job Objectives!
	/////////////////////////////////
	var/required_objectives=list() // Objectives that are ALWAYS added.
	var/optional_objectives=list() // Objectives that are SOMETIMES added.

//Only override this proc
/datum/job/proc/after_spawn(mob/living/carbon/human/H)

/datum/job/proc/announce(mob/living/carbon/human/H)

/datum/job/proc/equip(mob/living/carbon/human/H, visualsOnly = FALSE, announce = TRUE)
	if(!H)
		return 0

	H.dna.species.before_equip_job(src, H, visualsOnly)

	if(outfit)
		H.equipOutfit(outfit, visualsOnly)

	H.dna.species.after_equip_job(src, H, visualsOnly)

	if(!visualsOnly && announce)
		announce(H)

/datum/job/proc/get_access()
	if(!config)	//Needed for robots.
		return src.minimal_access.Copy()

	if(CONFIG_GET(flag/jobs_have_minimal_access))
		return src.minimal_access.Copy()
	else
		return src.access.Copy()

//If the configuration option is set to require players to be logged as old enough to play certain jobs, then this proc checks that they are, otherwise it just returns 1
/datum/job/proc/player_old_enough(client/C)
	if(available_in_days(C) == 0)
		return 1	//Available in 0 days = available right now = player is old enough to play.
	return 0


/datum/job/proc/available_in_days(client/C)
	if(!C)
		return 0
	if(!CONFIG_GET(flag/use_age_restriction_for_jobs))
		return 0
	if(!isnum(C.player_age))
		return 0 //This is only a number if the db connection is established, otherwise it is text: "Requires database", meaning these restrictions cannot be enforced
	if(!isnum(minimal_player_age))
		return 0

	return max(0, minimal_player_age - C.player_age)

/datum/job/proc/barred_by_disability(client/C)
	if(!C)
		return 0
	if(disabilities_allowed)
		return 0
	var/list/prohibited_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	for(var/i = 1, i < prohibited_disabilities.len, i++)
		var/this_disability = prohibited_disabilities[i]
		if(C.prefs.disabilities & this_disability)
			return 1
	return 0

/datum/job/proc/character_old_enough(client/C)
	if(!C)
		return FALSE
	if(C.prefs.age >= min_age_allowed)
		return TRUE
	return FALSE

/datum/job/proc/is_position_available()
	return (current_positions < total_positions) || (total_positions == -1)

/datum/outfit/job
	name = "Standard Gear"
	collect_not_del = TRUE // we don't want anyone to lose their job shit

	var/allow_loadout = TRUE
	var/allow_backbag_choice = TRUE
	var/jobtype = null

	uniform = /obj/item/clothing/under/color/grey
	id = /obj/item/card/id
	l_ear = /obj/item/radio/headset
	back = /obj/item/storage/backpack
	shoes = /obj/item/clothing/shoes/black
	pda = /obj/item/pda

	var/backpack = /obj/item/storage/backpack
	var/satchel = /obj/item/storage/backpack/satchel_norm
	var/dufflebag = /obj/item/storage/backpack/duffel
	box = /obj/item/storage/box/survival

	var/tmp/list/gear_leftovers = list()

/datum/outfit/job/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(allow_backbag_choice)
		switch(H.backbag)
			if(GBACKPACK)
				back = /obj/item/storage/backpack //Grey backpack
			if(GSATCHEL)
				back = /obj/item/storage/backpack/satchel_norm //Grey satchel
			if(GDUFFLEBAG)
				back = /obj/item/storage/backpack/duffel //Grey Dufflebag
			if(LSATCHEL)
				back = /obj/item/storage/backpack/satchel //Leather Satchel
			if(DSATCHEL)
				back = satchel //Department satchel
			if(DDUFFLEBAG)
				back = dufflebag //Department dufflebag
			else
				back = backpack //Department backpack

	if(box && H.dna.species.speciesbox)
		box = H.dna.species.speciesbox

	if(allow_loadout && H.client)
		for(var/gear in H.client.prefs.choosen_gears)
			var/datum/gear/G = H.client.prefs.choosen_gears[gear]
			if(!istype(G))
				continue
			var/permitted = FALSE

			if(G.allowed_roles)
				if(name in G.allowed_roles)
					permitted = TRUE
			else
				permitted = TRUE

			if(G.whitelisted && (G.whitelisted != H.dna.species.name || !is_alien_whitelisted(H, G.whitelisted)))
				permitted = FALSE

			if(H.client.donator_level < G?.donator_tier)
				permitted = FALSE

			if(!permitted)
				to_chat(H, "<span class='warning'>Your current job, donator tier or whitelist status does not permit you to spawn with [G.display_name]!</span>")
				continue

			if(G.implantable) //only works for organ-implants
				var/obj/item/organ/internal/I = new G.path
				I.insert(H)
				to_chat(H, span_notice("Implanting you with [G.display_name]!"))
				continue

			if(G.slot)
				if(H.equip_to_slot_or_del(G.spawn_item(H, H.client.prefs.loadout_gear[G.display_name]), G.slot))
					to_chat(H, "<span class='notice'>Equipping you with [G.display_name]!</span>")
				else
					gear_leftovers += G
			else
				gear_leftovers += G

/datum/outfit/job/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	imprint_idcard(H)

	H.sec_hud_set_ID()

	imprint_pda(H)

	if(gear_leftovers.len)
		for(var/datum/gear/G in gear_leftovers)
			var/obj/item/placed_in = G.spawn_item(get_turf(H), H.client.prefs.loadout_gear[G.display_name])
			if(placed_in.equip_to_best_slot(H))
				to_chat(H, "<span class='notice'>Placing [G.display_name] in your inventory!</span>")
				continue
			if(H.put_in_hands(placed_in))
				to_chat(H, "<span class='notice'>Placing [G.display_name] in your hands!</span>")
				continue
			to_chat(H, "<span class='danger'>Failed to locate a storage object on your mob, either you spawned with no hands free and no backpack or this is a bug.</span>")
			qdel(placed_in)

		qdel(gear_leftovers)

	return 1

/datum/outfit/job/proc/imprint_idcard(mob/living/carbon/human/H)
	var/datum/job/J = SSjobs.GetJobType(jobtype)
	if(!J)
		J = SSjobs.GetJob(H.job)

	var/alt_title
	if(H.mind)
		alt_title = H.mind.role_alt_title

	var/obj/item/card/id/C = H.wear_id
	if(istype(C))
		C.access = J.get_access()
		C.registered_name = H.real_name
		C.rank = J.title
		C.assignment = alt_title ? alt_title : J.title
		C.sex = capitalize(H.gender)
		C.age = H.age
		C.name = "[C.registered_name]'s ID Card ([C.assignment])"
		C.photo = get_id_photo(H)

		if(H.mind && H.mind.initial_account)
			C.associated_account_number = H.mind.initial_account.account_number
		C.owner_uid = H.UID()
		C.owner_ckey = H.ckey

/datum/outfit/job/proc/imprint_pda(mob/living/carbon/human/H)
	var/obj/item/pda/PDA = H.wear_pda
	var/obj/item/card/id/C = H.wear_id
	if(istype(PDA) && istype(C))
		PDA.owner = H.real_name
		PDA.ownjob = C.assignment
		PDA.ownrank = C.rank
		PDA.name = "PDA-[H.real_name] ([PDA.ownjob])"

/datum/outfit/job/proc/get_chameleon_disguise_info()
	var/on_back = (allow_backbag_choice) ? backpack : back
	var/list/types = list(uniform, suit, on_back, belt, gloves, shoes, head, mask, neck, l_ear, r_ear, glasses, id, l_pocket, r_pocket, suit_store, r_hand, l_hand, pda)
	types += chameleon_extras
	listclearnulls(types)
	return types

/datum/job/proc/would_accept_job_transfer_from_player(mob/player)
	if(!transfer_allowed)
		return FALSE
	if(!guest_jobbans(title)) // actually checks if job is a whitelisted position
		return TRUE
	if(!istype(player))
		return FALSE
	return is_job_whitelisted(player, title)


/datum/job/proc/can_novice_play(client/C)
	if(!is_novice)
		return TRUE
	if(exp_max && exp_type_max)
		var/list/play_records = params2list(C.prefs.exp)
		var/job_exp = text2num(play_records[exp_type_max])
		var/job_requirement = text2num(exp_max)
		if(job_exp >= job_requirement)
			return FALSE
	return TRUE
