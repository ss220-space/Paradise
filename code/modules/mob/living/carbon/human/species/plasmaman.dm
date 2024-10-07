/datum/species/plasmaman
	name = SPECIES_PLASMAMAN
	name_plural = "Plasmamen"
	icobase = 'icons/mob/human_races/r_plasmaman_sb.dmi'
	deform = 'icons/mob/human_races/r_plasmaman_pb.dmi'  // TODO: Need deform.
	dangerous_existence = TRUE //So so much
	//language = "Clatter"

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_PAIN,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_GERMS,
		TRAIT_NO_DECAY,
		TRAIT_NO_HUNGER,
	)
	forced_heartattack = TRUE // Plasmamen have no blood, but they should still get heart-attacks
	skinned_type = /obj/item/stack/sheet/mineral/plasma // We're low on plasma, R&D! *eyes plasmaman co-worker intently*
	reagent_tag = PROCESS_ORG

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE //skeletons can't taste anything

	butt_sprite = "plasma"

	breathid = "tox"

	brute_mod = 0.9
	burn_mod = 1.5
	heatmod = 1.5

	//Has default darksight of 2.

	suicide_messages = list(
		"сворачивает себе шею!",
		"впускает себе немного O2!",
		"осознает экзистенциальную проблему быть рождённым из плазмы!",
		"показывает свою истинную природу, которая оказывается плазмой!")

	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart/plasmaman,
		INTERNAL_ORGAN_LUNGS = /obj/item/organ/internal/lungs/plasmaman,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver/plasmaman,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys/plasmaman,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/plasmaman,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/plasmaman,
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/plasmaman

	speciesbox = /obj/item/storage/box/survival_plasmaman
	flesh_color = "#8b3fba"

	toxic_food = NONE
	disliked_food = NONE
	liked_food = NONE


/datum/species/plasmaman/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	add_verb(H, /mob/living/carbon/human/proc/emote_rattle)
	RegisterSignal(H, COMSIG_CARBON_RECEIVE_FRACTURE, PROC_REF(on_fracture))


/datum/species/plasmaman/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	remove_verb(H, /mob/living/carbon/human/proc/emote_rattle)
	UnregisterSignal(H, COMSIG_CARBON_RECEIVE_FRACTURE)

//внёс перевод акцента речи, шипящий звук. Но я не смог осилить и он почему-то по прежнему не работает, похоже не тут настраивается -- ПУПС
/datum/species/plasmaman/say_filter(mob/M, message, datum/language/speaking)
	if(copytext(message, 1, 2) != "*")
		message = replacetext(message, "s", stutter("ss"))
		message = replacetextEx_char(message, "С", "ш")
		message = replacetextEx_char(message, "с", "ш")
		message = replacetextEx_char(message, "Ш", stutter("Шш"))
		message = replacetextEx_char(message, "ш", stutter("шш"))
		message = replacetextEx_char(message, "Щ", stutter("Щщ"))
		message = replacetextEx_char(message, "щ", stutter("щщ"))
	return message

/datum/species/plasmaman/before_equip_job(datum/job/J, mob/living/carbon/human/H, visualsOnly = FALSE)
	var/current_job = J.title
	var/datum/outfit/plasmaman/O = new /datum/outfit/plasmaman
	switch(current_job)
		if(JOB_TITLE_CHAPLAIN)
			O = new /datum/outfit/plasmaman/chaplain

		if(JOB_TITLE_LIBRARIAN)
			O = new /datum/outfit/plasmaman/librarian

		if(JOB_TITLE_JANITOR)
			O = new /datum/outfit/plasmaman/janitor

		if(JOB_TITLE_BOTANIST)
			O = new /datum/outfit/plasmaman/botany

		if(JOB_TITLE_BARTENDER)
			O = new /datum/outfit/plasmaman/bar

		if(JOB_TITLE_LAWYER, JOB_TITLE_JUDGE)
			O = new /datum/outfit/plasmaman/nt

		if(JOB_TITLE_REPRESENTATIVE)
			O = new /datum/outfit/plasmaman/nt_rep

		if(JOB_TITLE_CHEF)
			O = new /datum/outfit/plasmaman/chef

		if(JOB_TITLE_OFFICER)
			O = new /datum/outfit/plasmaman/security

		if(JOB_TITLE_CCSPECOPS, JOB_TITLE_CCOFFICER, JOB_TITLE_CCFIELD)
			O = new /datum/outfit/plasmaman/specops_officer

		if(JOB_TITLE_SYNDICATE)
			O = new /datum/outfit/plasmaman/syndicate_officer

		if(JOB_TITLE_PILOT)
			O = new /datum/outfit/plasmaman/security/pod

		if(JOB_TITLE_DETECTIVE)
			O = new /datum/outfit/plasmaman/detective

		if(JOB_TITLE_WARDEN)
			O = new /datum/outfit/plasmaman/warden

		if(JOB_TITLE_HOS)
			O = new /datum/outfit/plasmaman/hos

		if(JOB_TITLE_CARGOTECH, JOB_TITLE_QUARTERMASTER)
			O = new /datum/outfit/plasmaman/cargo

		if(JOB_TITLE_MINER)
			O = new /datum/outfit/plasmaman/mining

		if(JOB_TITLE_DOCTOR, JOB_TITLE_INTERN, JOB_TITLE_BRIGDOC, JOB_TITLE_PARAMEDIC, JOB_TITLE_CORONER)
			O = new /datum/outfit/plasmaman/medical

		if(JOB_TITLE_CMO)
			O = new /datum/outfit/plasmaman/cmo

		if(JOB_TITLE_CHEMIST)
			O = new /datum/outfit/plasmaman/chemist

		if(JOB_TITLE_GENETICIST)
			O = new /datum/outfit/plasmaman/genetics

		if(JOB_TITLE_ROBOTICIST)
			O = new /datum/outfit/plasmaman/robotics

		if(JOB_TITLE_VIROLOGIST)
			O = new /datum/outfit/plasmaman/viro

		if(JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT)
			O = new /datum/outfit/plasmaman/science

		if("Xenobiologist")
			O = new /datum/outfit/plasmaman/xeno

		if(JOB_TITLE_RD)
			O = new /datum/outfit/plasmaman/rd

		if(JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE)
			O = new /datum/outfit/plasmaman/engineering

		if(JOB_TITLE_MECHANIC)
			O = new /datum/outfit/plasmaman/engineering/mecha

		if(JOB_TITLE_CHIEF)
			O = new /datum/outfit/plasmaman/ce

		if(JOB_TITLE_ATMOSTECH)
			O = new /datum/outfit/plasmaman/atmospherics

		if(JOB_TITLE_MIME)
			O = new /datum/outfit/plasmaman/mime

		if(JOB_TITLE_CLOWN)
			O = new /datum/outfit/plasmaman/clown

		if(JOB_TITLE_HOP)
			O = new /datum/outfit/plasmaman/hop

		if(JOB_TITLE_CAPTAIN)
			O = new /datum/outfit/plasmaman/captain

		if(JOB_TITLE_BLUESHIELD)
			O = new /datum/outfit/plasmaman/blueshield

	H.equipOutfit(O, visualsOnly)
	H.internal = H.r_hand
	H.update_action_buttons_icon()
	return FALSE

/datum/species/plasmaman/handle_life(mob/living/carbon/human/H)
	var/datum/gas_mixture/environment = H.loc.return_air()
	var/atmos_sealed = FALSE
	if(isclothing(H.wear_suit) && isclothing(H.head))
		var/obj/item/clothing/suit = H.wear_suit
		var/obj/item/clothing/helmet = H.head
		if(suit.clothing_flags & helmet.clothing_flags & STOPSPRESSUREDMAGE)
			atmos_sealed = TRUE
	if(!atmos_sealed && (!istype(H.w_uniform, /obj/item/clothing/under/plasmaman) || !istype(H.head, /obj/item/clothing/head/helmet/space/plasmaman)))
		if(environment)
			if(environment.total_moles())
				if(environment.oxygen && environment.oxygen >= OXYCONCEN_PLASMEN_IGNITION) //Same threshhold that extinguishes fire
					H.adjust_fire_stacks(0.5)
					if(!H.on_fire && H.fire_stacks > 0)
						H.visible_message("<span class='danger'>Тело [H] вступает в реакцию с атмосферой и загорается!</span>","<span class='userdanger'>Ваше тело вступает в реакцию с атмосферой и загорается!</span>")
					H.IgniteMob()
	else
		if(H.fire_stacks)
			var/obj/item/clothing/under/plasmaman/P = H.w_uniform
			if(istype(P))
				P.Extinguish(H)
	H.update_fire()
	..()
	if(H.stat == DEAD)
		return
	if(H.reagents.get_reagent_amount("pure_plasma") < 5) //increasing chock_reduction by 20
		H.reagents.add_reagent("pure_plasma", 5)

/datum/species/plasmaman/proc/on_fracture(mob/living/carbon/human/H)
	SIGNAL_HANDLER
	H.reagents.add_reagent("plasma_dust", 15)

/datum/species/plasmaman/handle_reagents(mob/living/carbon/human/H, datum/reagent/R)
	switch(R.id)
		if("plasma")
			H.heal_overall_damage(0.25, 0.25)
			H.adjust_alien_plasma(20)
			H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
			return FALSE //Handling reagent removal on our own. Prevents plasma from dealing toxin damage to Plasmaman
		if("plasma_dust")
			H.heal_overall_damage(0.25, 0.25)
			H.adjust_alien_plasma(20)
			if(prob(1))
				var/list/fractured_organs = H.check_fractures()
				shuffle(fractured_organs)
				for(var/obj/item/organ/external/bodypart as anything in fractured_organs)
					if(bodypart.mend_fracture())
						break
			H.reagents.remove_reagent(R.id, REAGENTS_METABOLISM)
			return FALSE
	return ..()
