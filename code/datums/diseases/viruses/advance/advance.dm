/*

	Advance Disease is a system for Virologist to Engineer their own disease with symptoms that have effects and properties
	which add onto the overall disease.

*/

#define VIRUS_SYMPTOM_LIMIT	6
#define VIRUS_MAX_SYMPTOM_LEVEL	6

// The order goes from easy to cure to hard to cure.
GLOBAL_LIST_INIT(advance_cures, list(
									"sodiumchloride", "sugar", "orangejuice",
									"spaceacillin", "salglu_solution", "ethanol",
									"teporone", "diphenhydramine", "lipolicide",
									"silver", "gold"
))

GLOBAL_LIST_EMPTY(archive_diseases)

/*

	PROPERTIES

 */

/datum/disease/virus/advance

	name = "Unknown" // We will always let our Virologist name our disease.
	desc = "Спроектированная болезнь, может содержать сразу несколько симптомов."
	form = "Продвинутая болезнь" // Will let med-scanners know that this disease was engineered.
	agent = "advance microbes"
	max_stages = 5

	// NEW VARS

	var/list/symptoms = list() // The symptoms of the disease.
	var/id = ""
	var/processing = 0

/datum/disease/virus/advance/New()
	if(!symptoms || !symptoms.len)
		symptoms = GenerateSymptoms(1, 2)

	AssignProperties(GenerateProperties())
	id = GetDiseaseID()
	..()

/datum/disease/virus/advance/Destroy()
	if(processing)
		for(var/datum/symptom/S in symptoms)
			S.End(src)
	return ..()

// Randomly pick a symptom to activate.
/datum/disease/virus/advance/stage_act()
	if(!..())
		return FALSE
	if(symptoms && symptoms.len)

		if(!processing)
			processing = 1
			for(var/datum/symptom/S in symptoms)
				S.Start(src)

		for(var/datum/symptom/S in symptoms)
			S.Activate(src)
	else
		CRASH("We do not have any symptoms during stage_act()!")
	return TRUE

// Compares type then ID.
/datum/disease/virus/advance/IsSame(datum/disease/virus/advance/D)
	if(!(istype(D, /datum/disease/virus/advance)))
		return FALSE

	if(GetDiseaseID() != D.GetDiseaseID())
		return FALSE
	return TRUE

// To add special resistances.
/datum/disease/virus/advance/cure(id, need_immunity)
	..(GetDiseaseID(), need_immunity)

/datum/disease/virus/advance/Contract(mob/living/M, act_type, is_carrier = FALSE, need_protection_check = FALSE, zone)
	var/datum/disease/virus/advance/A = ..()
	if(!istype(A))
		return FALSE
	A.Refresh(update_properties = FALSE)

// Returns the advance disease with a different reference memory.
/datum/disease/virus/advance/Copy()
	var/datum/disease/virus/advance/copy = new
	var/list/required_vars = list(
		"name","severity","id","visibility_flags","spread_flags", "additional_info", "stage_prob", "cures",
		"cure_prob","cure_text", "permeability_mod", "mutation_chance", "mutation_reagents", "possible_mutations")
	for(var/V in required_vars)
		if(istype(vars[V], /list))
			var/list/L = vars[V]
			copy.vars[V] = L.Copy()
		else
			copy.vars[V] = vars[V]
	copy.symptoms = list()
	for(var/datum/symptom/S in symptoms)
		copy.symptoms += new S.type
	return copy

// Mix the symptoms of two diseases (the src and the argument)
/datum/disease/virus/advance/proc/Mix(datum/disease/virus/advance/D)
	if(!(IsSame(D)))
		var/list/possible_symptoms = shuffle(D.symptoms)
		for(var/datum/symptom/S in possible_symptoms)
			AddSymptom(new S.type)

/datum/disease/virus/advance/proc/HasSymptom(datum/symptom/S)
	for(var/datum/symptom/symp in symptoms)
		if(symp.id == S.id)
			return TRUE
	return FALSE

// Will generate new unique symptoms, use this if there are none. Returns a list of symptoms that were generated.
/datum/disease/virus/advance/proc/GenerateSymptoms(level_min = 1, level_max = VIRUS_MAX_SYMPTOM_LEVEL, count_of_symptoms = 0, override_symptoms = FALSE)

	var/list/generated = list() // Symptoms we generated.

	// Generate symptoms. By default, we only choose non-deadly symptoms.
	var/list/possible_symptoms = list()
	for(var/symp in GLOB.list_symptoms)
		var/datum/symptom/S = new symp
		if(S.level >= level_min && S.level <= level_max)
			if(!HasSymptom(S) || override_symptoms)
				possible_symptoms += S

	if(!possible_symptoms.len)
		return generated

	var/N = 1
	if(count_of_symptoms)
		N = count_of_symptoms
	else
		while(prob(20) && N < VIRUS_SYMPTOM_LIMIT)
			N++

	for(var/i = 1; i <= N && possible_symptoms.len; i++)
		generated += pick_n_take(possible_symptoms)

	return generated

/datum/disease/virus/advance/proc/Refresh(reset_name = FALSE, update_properties = TRUE)
	if(update_properties)
		AssignProperties(GenerateProperties())
	id = GetDiseaseID()

	var/datum/disease/virus/advance/A = GLOB.archive_diseases[id]
	UpdateMutationsProps(A)

	if(A)
		name = A.name
	else
		if(reset_name)
			name = "Unknown"
		AddToArchive()

/datum/disease/virus/advance/proc/AddToArchive()
	GLOB.archive_diseases[id] = Copy()

/datum/disease/virus/advance/proc/UpdateMutationsProps(datum/disease/virus/advance/A)
	var/datum/disease/virus/advance/AA = A ? A : new

	mutation_reagents = AA.mutation_reagents.Copy()
	possible_mutations = AA.possible_mutations?.Copy()

//Generate disease properties based on the effects. Returns an associated list.
/datum/disease/virus/advance/proc/GenerateProperties()

	if(!symptoms || !symptoms.len)
		CRASH("We did not have any symptoms before generating properties.")

	var/list/properties = list("resistance" = 1, "stealth" = 0, "stage_speed" = 1, "transmittable" = 1, "severity" = 0)

	for(var/datum/symptom/S in symptoms)

		properties["resistance"] += S.resistance
		properties["stealth"] += S.stealth
		properties["stage_speed"] += S.stage_speed
		properties["transmittable"] += S.transmittable
		properties["severity"] = max(properties["severity"], S.severity) // severity is based on the highest severity symptom

	return properties

// Assign the properties that are in the list.
/datum/disease/virus/advance/proc/AssignProperties(list/properties = list())
	if(properties && properties.len)
		// stealth
		switch(properties["stealth"])
			if(1)
				visibility_flags = HIDDEN_HUD
			if(2)
				visibility_flags = HIDDEN_HUD|HIDDEN_SCANNER
			if(3 to INFINITY)
				visibility_flags = HIDDEN_HUD|HIDDEN_SCANNER|HIDDEN_PANDEMIC
			else
				visibility_flags = VISIBLE

		// transmittable
		switch(properties["transmittable"] - round(symptoms.len/2))
			if(-INFINITY to 1)
				spread_flags = BLOOD
			if(2 to 3)
				spread_flags = CONTACT
			if(4 to INFINITY)
				spread_flags = AIRBORNE
		additional_info = spread_text()
		permeability_mod = clamp((0.25 * properties["transmittable"]), 0.2, 2)

		//stage speed
		stage_prob = clamp(max(1.3 * sqrtor0(properties["stage_speed"] + 11), properties["stage_speed"]), 1, 40)

		//severity
		switch(properties["severity"])
			if(-INFINITY to 0)
				severity = NONTHREAT
			if(1)
				severity = MINOR
			if(2)
				severity = MEDIUM
			if(3)
				severity = HARMFUL
			if(4)
				severity = DANGEROUS
			if(5 to INFINITY)
				severity = BIOHAZARD

		//resistance
		cure_prob = clamp(15 - properties["resistance"], 5, 40)
		GenerateCure(properties["resistance"])
	else
		CRASH("Our properties were empty or null!")

//TODO: доделать эту хуйню
// Will generate a random cure, the less resistance the symptoms have, the harder the cure.
/datum/disease/virus/advance/proc/GenerateCure(resistance)
	var/res = round(clamp(resistance - (symptoms.len / 2), 1, GLOB.advance_cures.len))

	// Get the cure name from the cure_id
	var/datum/reagent/D = GLOB.chemical_reagents_list[GLOB.advance_cures[res]]
	cures = list(GLOB.advance_cures[res])
	cure_text = D.name

// Randomly generate a symptom, has a chance to lose or gain a symptom.
/datum/disease/virus/advance/proc/Evolve(min_level, max_level)
	var/s = safepick(GenerateSymptoms(min_level, max_level, 1))
	if(s)
		AddSymptom(s)
		Refresh(reset_name = TRUE)
	return

// Randomly remove a symptom.
/datum/disease/virus/advance/proc/Devolve()
	if(symptoms.len > 1)
		var/s = safepick(symptoms)
		if(s)
			RemoveSymptom(s)
			Refresh(reset_name = TRUE)
	return

// Name the disease.
/datum/disease/virus/advance/proc/AssignName(name = "Unknown")
	src.name = name
	return

// Return a unique ID of the disease.
/datum/disease/virus/advance/GetDiseaseID()
	var/list/L = list()
	for(var/datum/symptom/S in symptoms)
		L += S.id
	L = sortList(L) // Sort the list so it doesn't matter which order the symptoms are in.
	return jointext(L, ":")

// Add a symptom, if it is over the limit (with a small chance to be able to go over)
// we take a random symptom away and add the new one.
/datum/disease/virus/advance/proc/AddSymptom(datum/symptom/S)

	if(HasSymptom(S))
		return

	if(symptoms.len < (VIRUS_SYMPTOM_LIMIT - 1) + rand(-1, 1))
		symptoms += S
	else
		RemoveSymptom(pick(symptoms))
		symptoms += S
	return

// Simply removes the symptom.
/datum/disease/virus/advance/proc/RemoveSymptom(datum/symptom/S)
	symptoms -= S
	return

/datum/disease/virus/advance/CanContract(mob/living/M, act_type, need_protection_check, zone)
	. = ..()
	if(count_by_type(M.diseases, /datum/disease/virus/advance) > 0)
		. = FALSE

/*

	Static Procs

*/

// Mix a list of advance diseases and return the mixed result.
/proc/Advance_Mix(var/list/D_list)

	var/list/diseases = list()

	for(var/datum/disease/virus/advance/A in D_list)
		diseases += A.Copy()

	if(!diseases.len)
		return null
	if(diseases.len <= 1)
		return pick(diseases) // Just return the only entry.

	var/i = 0
	// Mix our diseases until we are left with only one result.
	while(i < 20 && diseases.len > 1)

		i++

		var/datum/disease/virus/advance/D1 = pick(diseases)
		diseases -= D1

		var/datum/disease/virus/advance/D2 = pick(diseases)
		D2.Mix(D1)

	 // Should be only 1 entry left, but if not let's only return a single entry
//	to_chat(world, "END MIXING!!!!!")
	var/datum/disease/virus/advance/to_return = pick(diseases)
	to_return.Refresh(reset_name = TRUE)
	return to_return

/proc/SetViruses(datum/reagent/R, list/data)
	if(data)
		var/list/preserve = list()
		if(istype(data) && data["diseases"])
			for(var/datum/disease/D in data["diseases"])
				preserve += D.Copy()
			R.data = data.Copy()
		if(preserve.len)
			R.data["diseases"] = preserve

/proc/AdminCreateVirus(client/user)

	if(!user)
		return

	var/i = VIRUS_SYMPTOM_LIMIT

	var/datum/disease/virus/advance/D = new
	D.Refresh()
	D.symptoms = list()

	var/list/symptoms = list()
	symptoms += "Done"
	symptoms += GLOB.list_symptoms.Copy()
	do
		if(user)
			var/symptom = input(user, "Choose a symptom to add ([i] remaining)", "Choose a Symptom") in symptoms
			if(isnull(symptom))
				return
			else if(istext(symptom))
				i = 0
			else if(ispath(symptom))
				var/datum/symptom/S = new symptom
				if(!D.HasSymptom(S))
					D.symptoms += S
					i -= 1
	while(i > 0)

	if(D.symptoms.len > 0)

		var/new_name = stripped_input(user, "Name your new disease.", "New Name")
		if(!new_name)
			return
		D.AssignName(new_name)
		D.Refresh()

		for(var/datum/disease/virus/advance/AD in GLOB.active_diseases)
			AD.Refresh()

		for(var/thing in shuffle(GLOB.human_list))
			var/mob/living/carbon/human/H = thing
			if(H.stat == DEAD || !is_station_level(H.z))
				continue
			if(!H.HasDisease(D))
				D.Contract(H)
				break

		var/list/name_symptoms = list()
		for(var/datum/symptom/S in D.symptoms)
			name_symptoms += S.name
		message_admins("[key_name_admin(user)] has triggered a custom virus outbreak of [D.name]! It has these symptoms: [english_list(name_symptoms)]")

/**
 * Creates and returns a random virus with properties independent of symptoms properties
 */
/proc/CreateRandomVirus(level_min = 1, level_max = VIRUS_MAX_SYMPTOM_LEVEL, count_of_symptoms = 6,
						resistance, stealth, stage_rate, transmittable, severity)

	var/datum/disease/virus/advance/A = new
	A.name = capitalize(pick(GLOB.adjectives)) + " " + capitalize(pick(GLOB.nouns + GLOB.verbs))
	A.symptoms = A.GenerateSymptoms(count_of_symptoms = rand(4, 6), override_symptoms = TRUE)
	A.AssignProperties(list("resistance" = resistance, "stealth" = stealth, "stage_rate" = stage_rate, "transmittable" = transmittable, "severity" = severity))
	A.Refresh(update_properties = FALSE)
	return A


/datum/disease/virus/advance/proc/totalStageSpeed()
	var/total_stage_speed = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stage_speed += S.stage_speed
	return total_stage_speed

/datum/disease/virus/advance/proc/totalStealth()
	var/total_stealth = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_stealth += S.stealth
	return total_stealth

/datum/disease/virus/advance/proc/totalResistance()
	var/total_resistance = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_resistance += S.resistance
	return total_resistance

/datum/disease/virus/advance/proc/totalTransmittable()
	var/total_transmittable = 0
	for(var/i in symptoms)
		var/datum/symptom/S = i
		total_transmittable += S.transmittable
	return total_transmittable

#undef VIRUS_SYMPTOM_LIMIT
#undef VIRUS_MAX_SYMPTOM_LEVEL
