/datum/datacore
	var/list/medical = list()
	var/list/general = list()
	var/list/security = list()
	//This list tracks characters spawned in the world and cannot be modified in-game. Currently referenced by respawn_character().
	var/list/locked = list()

/*
We can't just insert in HTML into the TGUI so we need the raw data to play with.
Instead of creating this list over and over when someone leaves their PDA open to the page
we'll only update it when it changes.  The PDA_Manifest global list is zeroed out upon any change
using /datum/datacore/proc/manifest_inject(), or manifest_insert()
*/

GLOBAL_LIST_EMPTY(PDA_Manifest)

/datum/datacore/proc/get_manifest_json()
	if(length(GLOB.PDA_Manifest))
		return
	var/heads[0]
	var/pro[0]
	var/sec[0]
	var/eng[0]
	var/med[0]
	var/sci[0]
	var/ser[0]
	var/sup[0]
	var/bot[0]
	var/misc[0]
	for(var/datum/data/record/record in GLOB.data_core.general)
		var/name = sanitize(record.fields["name"])
		var/rank = sanitize(record.fields["rank"])
		var/real_rank = record.fields["real_rank"]

		var/isactive = record.fields["p_stat"]
		var/department = 0
		var/depthead = 0 // Department Heads will be placed at the top of their lists.
		if(real_rank in GLOB.command_positions)
			heads[++heads.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			depthead = 1
			if(real_rank == JOB_TITLE_CAPTAIN && length(heads) != 1)
				heads.Swap(1,  length(heads))

		if((real_rank == JOB_TITLE_MAGISTRATE) || (real_rank == JOB_TITLE_LAWYER) || (real_rank == JOB_TITLE_REPRESENTATIVE))
			pro[++pro.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if((real_rank == JOB_TITLE_MAGISTRATE) && length(pro) != 1)
				pro.Swap(1,  length(pro))

		if(real_rank in GLOB.security_positions)
			sec[++sec.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(sec) != 1)
				sec.Swap(1, length(sec))

		if(real_rank in GLOB.engineering_positions)
			eng[++eng.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(eng) != 1)
				eng.Swap(1, length(eng))

		if(real_rank in GLOB.medical_positions)
			med[++med.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(med) != 1)
				med.Swap(1, length(med))

		if(real_rank in GLOB.science_positions)
			sci[++sci.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(sci) != 1)
				sci.Swap(1, length(sci))

		if(real_rank in GLOB.service_positions)
			ser[++ser.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(ser) != 1)
				ser.Swap(1, length(ser))

		if(real_rank in GLOB.supply_positions)
			sup[++sup.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1
			if(depthead && length(sup) != 1)
				sup.Swap(1, length(sup))

		if(real_rank in GLOB.nonhuman_positions)
			bot[++bot.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)
			department = 1

		if(!department && !(name in heads))
			misc[++misc.len] = list("name" = name, "rank" = rank, "real_rank" = real_rank, "active" = isactive)

	GLOB.PDA_Manifest = list(\
		"heads" = heads,\
		"pro" = pro,\
		"sec" = sec,\
		"eng" = eng,\
		"med" = med,\
		"sci" = sci,\
		"ser" = ser,\
		"sup" = sup,\
		"bot" = bot,\
		"misc" = misc\
		)
	return

/datum/datacore/proc/manifest()
	for(var/mob/living/carbon/human/human in GLOB.player_list)
		manifest_inject(human)

/datum/datacore/proc/manifest_modify(name, rank, assignment)
	if(length(GLOB.PDA_Manifest))
		GLOB.PDA_Manifest.Cut()
	var/datum/data/record/foundrecord

	for(var/datum/data/record/record in GLOB.data_core.general)
		if(record)
			if(record.fields["name"] == name)
				foundrecord = record
				break

	if(foundrecord)
		foundrecord.fields["rank"] = get_job_title_ru(assignment)
		foundrecord.fields["real_rank"] = rank

GLOBAL_VAR_INIT(record_id_num, 1001)
/datum/datacore/proc/manifest_inject(mob/living/carbon/human/H)
	if(length(GLOB.PDA_Manifest))
		GLOB.PDA_Manifest.Cut()

	if(H.mind && (H.mind.assigned_role != H.mind.special_role))
		var/assignment
		if(H.mind.role_alt_title)
			assignment = H.mind.role_alt_title
		else if(H.mind.assigned_role)
			assignment = H.mind.assigned_role
		else if(H.job)
			assignment = H.job
		else
			assignment = "Неназначенный"

		var/id = num2hex(GLOB.record_id_num++, 6)

		//General Record
		var/datum/data/record/record = new()
		record.fields["id"] = id
		record.fields["name"] = H.real_name
		record.fields["real_rank"] = H.mind.assigned_role
		record.fields["rank"] = get_job_title_ru(assignment)
		record.fields["age"] = H.age
		record.fields["fingerprint"] = md5(H.dna.uni_identity)
		record.fields["p_stat"] = "Активный"
		record.fields["m_stat"] = "Стабильное"
		record.fields["sex"] = capitalize(H.gender)
		record.fields["species"] = H.dna.species.name
		record.fields["photo"] = get_id_photo(H)
		record.fields["photo-south"] = "data:image/png;base64,[icon2base64(icon(record.fields["photo"], dir = SOUTH))]"
		record.fields["photo-west"] = "data:image/png;base64,[icon2base64(icon(record.fields["photo"], dir = WEST))]"
		if(H.gen_record && !jobban_isbanned(H, "Records"))
			record.fields["notes"] = H.gen_record
		else
			record.fields["notes"] = "Дополнительная информация отсутствует."
		if(H.exploit_record && !jobban_isbanned(H, "Records"))
			record.fields["exploit_record"] = H.exploit_record
		else
			record.fields["exploit_record"] = "Дополнительная информация отсутствует."
		general += record

		//Medical Record
		var/datum/data/record/medical_record = new()
		medical_record.fields["id"] = id
		medical_record.fields["name"] = H.real_name
		medical_record.fields["blood_type"] = H.dna.blood_type
		medical_record.fields["b_dna"] = H.dna.unique_enzymes
		medical_record.fields["mi_dis"] = "Отсутствуют"
		medical_record.fields["mi_dis_d"] = "Незначительные отклонения не указаны."
		medical_record.fields["ma_dis"] = "Отсутствуют"
		medical_record.fields["ma_dis_d"] = "Инвалидности не указаны."
		medical_record.fields["alg"] = "Отсутствуют"
		medical_record.fields["alg_d"] = "Аллергии не указаны."
		medical_record.fields["cdi"] = "Отсутствуют"
		medical_record.fields["cdi_d"] = "Текущие заболевания не указаны."
		if(H.med_record && !jobban_isbanned(H, "Records"))
			medical_record.fields["notes"] = H.med_record
		else
			medical_record.fields["notes"] = "Дополнительная информация отсутствует."
		medical += medical_record

		//Security Record
		var/datum/data/record/sec_record = find_security_record("name", H.real_name)
		if(sec_record) //records exists, set correct id and name
			sec_record.name = text("Security Record #[id]")
			sec_record.fields["id"] = id
		else //create new record
			sec_record = CreateSecurityRecord(H.real_name, id)
		if(H.sec_record && !jobban_isbanned(H, "Records"))
			sec_record.fields["notes"] = H.sec_record
		else
			sec_record.fields["notes"] = "Дополнительная информация отсутствует."

		//Locked Record
		var/datum/data/record/locked_record = new()
		locked_record.fields["id"] = md5("[H.real_name][H.mind.assigned_role]")
		locked_record.fields["name"] = H.real_name
		locked_record.fields["rank"] = H.mind.assigned_role
		locked_record.fields["age"] = H.age
		locked_record.fields["sex"] = capitalize(H.gender)
		locked_record.fields["blood_type"] = H.dna.blood_type
		locked_record.fields["b_dna"] = H.dna.unique_enzymes
		locked_record.fields["enzymes"] = H.dna.SE // Used in respawning
		locked_record.fields["identity"] = H.dna.UI // "
		locked_record.fields["image"] = getFlatIcon(H) //This is god-awful
		locked_record.fields["reference"] = WEAKREF(H)
		locked += record
	return

/proc/get_id_photo(mob/living/carbon/human/H, custom_job = null)
	var/icon/preview_icon = null
	var/obj/item/organ/external/head/head_organ = H.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/eyes/eyes_organ = H.get_int_organ(/obj/item/organ/internal/eyes)

	var/g = "m"
	if(H.gender == FEMALE)
		g = "f"

	var/icon/icobase = head_organ.icobase //At this point all the organs would have the same icobase, so this is just recycling.

	preview_icon = new /icon(icobase, "torso_[g]")
	var/icon/temp
	temp = new /icon(icobase, "groin_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)
	var/head = "head"
	if(head_organ.alt_head && head_organ.dna.species.bodyflags & HAS_ALT_HEADS)
		var/datum/sprite_accessory/alt_heads/alternate_head = GLOB.alt_heads_list[head_organ.alt_head]
		if(alternate_head.icon_state)
			head = alternate_head.icon_state
	temp = new /icon(icobase, "[head]_[g]")
	preview_icon.Blend(temp, ICON_OVERLAY)

	//Tail
	if(H.body_accessory && (istype(H.body_accessory, /datum/body_accessory/tail) || istype(H.body_accessory, /datum/body_accessory/wing)))
		temp = new/icon("icon" = H.body_accessory.icon, "icon_state" = H.body_accessory.icon_state)
		if(H.dna.species.bodyflags & HAS_SKIN_COLOR  && !(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
			temp.Blend(H.skin_colour, H.body_accessory.blend_mode)
		preview_icon.Blend(temp, ICON_OVERLAY)
	else if(H.tail && H.dna.species.bodyflags & HAS_TAIL)
		temp = new/icon("icon" = 'icons/effects/species.dmi', "icon_state" = "[H.tail]_s")
		if(H.dna.species.bodyflags & HAS_SKIN_COLOR  && !(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
			temp.Blend(H.skin_colour, ICON_ADD)
		preview_icon.Blend(temp, ICON_OVERLAY)

	for(var/obj/item/organ/external/bodypart as anything in H.bodyparts)
		if(istype(bodypart, /obj/item/organ/external/tail))
			continue
		if(istype(bodypart, /obj/item/organ/external/wing))
			continue
		preview_icon.Blend(bodypart.get_icon(), ICON_OVERLAY)

/* At this point all bodyparts already colored!
	// Skin tone
	if(H.dna.species.bodyflags & HAS_SKIN_TONE)
		if(H.s_tone >= 0)
			preview_icon.Blend(rgb(H.s_tone, H.s_tone, H.s_tone), ICON_ADD)
		else
			preview_icon.Blend(rgb(-H.s_tone,  -H.s_tone,  -H.s_tone), ICON_SUBTRACT)

	// Proper Skin color - Fix, you can't have HAS_SKIN_TONE *and* HAS_SKIN_COLOR
	if(H.dna.species.bodyflags & HAS_SKIN_COLOR  && !(H.dna.species.bodyflags & HAS_ICON_SKIN_TONE))
		preview_icon.Blend(H.skin_colour, ICON_ADD)
*/
	//Tail Markings
	var/icon/t_marking_s
	if(H.dna.species.bodyflags & HAS_TAIL_MARKINGS)
		var/tail_marking = H.m_styles["tail"]
		var/datum/sprite_accessory/tail_marking_style = GLOB.marking_styles_list[tail_marking]
		if(tail_marking_style?.species_allowed)
			t_marking_s = new/icon("icon" = tail_marking_style.icon, "icon_state" = "[tail_marking_style.icon_state]_s")
			t_marking_s.Blend(H.m_colours["tail"], ICON_ADD)
			if(!(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/body)))
				preview_icon.Blend(t_marking_s, ICON_OVERLAY)

	var/icon/face_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "bald_s")
	if(!(H.dna.species.bodyflags & NO_EYES))
		var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = H.dna.species ? H.dna.species.eyes : "eyes_s")
		if(!eyes_organ)
			return
		eyes_s.Blend(eyes_organ.eye_colour, ICON_ADD)
		face_s.Blend(eyes_s, ICON_OVERLAY)

	var/datum/sprite_accessory/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	if(hair_style)
		var/icon/hair_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
		// I'll want to make a species-specific proc for this sooner or later
		// But this'll do for now
		if(isslimeperson(head_organ))
			hair_s.Blend("[H.skin_colour]A0", ICON_AND) //A0 = 160 alpha.
		else
			hair_s.Blend(head_organ.hair_colour, ICON_ADD)

		if(hair_style.secondary_theme)
			var/icon/hair_secondary_s = new/icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_[hair_style.secondary_theme]_s")
			if(!hair_style.no_sec_colour)
				hair_secondary_s.Blend(head_organ.sec_hair_colour, ICON_ADD)
			hair_s.Blend(hair_secondary_s, ICON_OVERLAY)

		face_s.Blend(hair_s, ICON_OVERLAY)

	//Head Accessory
	if(head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
		var/datum/sprite_accessory/head_accessory_style = GLOB.head_accessory_styles_list[head_organ.ha_style]
		if(head_accessory_style?.species_allowed)
			var/icon/head_accessory_s = new/icon("icon" = head_accessory_style.icon, "icon_state" = "[head_accessory_style.icon_state]_s")
			head_accessory_s.Blend(head_organ.headacc_colour, ICON_ADD)
			face_s.Blend(head_accessory_s, ICON_OVERLAY)

	var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[head_organ.f_style]
	if(facial_hair_style?.species_allowed)
		var/icon/facial_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_s")
		if(isslimeperson(head_organ))
			facial_s.Blend("[H.skin_colour]A0", ICON_ADD) //A0 = 160 alpha.
		else
			facial_s.Blend(head_organ.facial_colour, ICON_ADD)

		if(facial_hair_style.secondary_theme)
			var/icon/facial_secondary_s = new/icon("icon" = facial_hair_style.icon, "icon_state" = "[facial_hair_style.icon_state]_[facial_hair_style.secondary_theme]_s")
			if(!facial_hair_style.no_sec_colour)
				facial_secondary_s.Blend(head_organ.sec_facial_colour, ICON_ADD)
			facial_s.Blend(facial_secondary_s, ICON_OVERLAY)

		face_s.Blend(facial_s, ICON_OVERLAY)

	//Markings
	if((H.dna.species.bodyflags & HAS_HEAD_MARKINGS) || (H.dna.species.bodyflags & HAS_BODY_MARKINGS))
		if(H.dna.species.bodyflags & HAS_BODY_MARKINGS) //Body markings.
			var/body_marking = H.m_styles["body"]
			var/datum/sprite_accessory/body_marking_style = GLOB.marking_styles_list[body_marking]
			if(body_marking_style?.species_allowed)
				var/icon/b_marking_s = new/icon("icon" = body_marking_style.icon, "icon_state" = "[body_marking_style.icon_state]_s")
				b_marking_s.Blend(H.m_colours["body"], ICON_ADD)
				face_s.Blend(b_marking_s, ICON_OVERLAY)
		if(H.dna.species.bodyflags & HAS_HEAD_MARKINGS) //Head markings.
			var/head_marking = H.m_styles["head"]
			var/datum/sprite_accessory/head_marking_style = GLOB.marking_styles_list[head_marking]
			if(head_marking_style?.species_allowed)
				var/icon/h_marking_s = new/icon("icon" = head_marking_style.icon, "icon_state" = "[head_marking_style.icon_state]_s")
				h_marking_s.Blend(H.m_colours["head"], ICON_ADD)
				face_s.Blend(h_marking_s, ICON_OVERLAY)

	preview_icon.Blend(face_s, ICON_OVERLAY)

	var/icon/clothes_s = null
	var/job_clothes = null
	if(custom_job)
		job_clothes = custom_job
	else if(H.mind)
		job_clothes = H.mind.assigned_role
	switch(job_clothes)
		if(JOB_TITLE_HOP)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "hop_alt_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
		if(JOB_TITLE_REPRESENTATIVE)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "officer_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
		if(JOB_TITLE_BLUESHIELD)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "officer_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "swat_gl"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "blueshield"), ICON_OVERLAY)
		if(JOB_TITLE_MAGISTRATE)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "really_black_suit_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "judge"), ICON_OVERLAY)
		if(JOB_TITLE_BARTENDER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "ba_suit_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_BOTANIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "hydroponics_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_CHEF)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "chef_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_JANITOR)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "janitor_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_LIBRARIAN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "red_suit_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_CLOWN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "clown_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "clown"), ICON_UNDERLAY)
		if(JOB_TITLE_MIME)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "mime_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_QUARTERMASTER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "qm_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
		if(JOB_TITLE_CARGOTECH)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "cargotech_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_MINER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "explorer_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "explorer"), ICON_UNDERLAY)
		if(JOB_TITLE_MINING_MEDIC)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "mining_medic_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
		if(JOB_TITLE_LAWYER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "internalaffairs_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
		if(JOB_TITLE_CHAPLAIN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "chaplain_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_RD)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "director_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if(JOB_TITLE_SCIENTIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "science_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
		if(JOB_TITLE_SCIENCE_STUDENT)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "student_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_tox_open"), ICON_OVERLAY)
		if(JOB_TITLE_CHEMIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "chemistry_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_chem_open"), ICON_OVERLAY)
		if(JOB_TITLE_CMO)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "cmo_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_cmo_open"), ICON_OVERLAY)
		if(JOB_TITLE_DOCTOR)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if(JOB_TITLE_CORONER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "scrubsblack_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_mort_open"), ICON_OVERLAY)
		if(JOB_TITLE_GENETICIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "genetics_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_gen_open"), ICON_OVERLAY)
		if(JOB_TITLE_VIROLOGIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "virology_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_vir_open"), ICON_OVERLAY)
		if(JOB_TITLE_PSYCHIATRIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "psych_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_UNDERLAY)
		if(JOB_TITLE_PARAMEDIC)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "paramedic_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_MEDICAL_INTERN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "intern_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if(JOB_TITLE_CAPTAIN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "captain_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
		if(JOB_TITLE_HOS)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "hos_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if(JOB_TITLE_WARDEN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "warden_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if(JOB_TITLE_DETECTIVE)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "detective_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "detective"), ICON_OVERLAY)
		if(JOB_TITLE_PILOT)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "security_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "bomber"), ICON_OVERLAY)
		if(JOB_TITLE_BRIGDOC)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "medical_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "white"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "fr_jacket_open"), ICON_OVERLAY)
		if(JOB_TITLE_OFFICER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "security_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
		if(JOB_TITLE_CHIEF_ENGINEER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "chief_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "brown"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
		if(JOB_TITLE_ENGINEER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "engine_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
		if(JOB_TITLE_ATMOSTECH)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "atmos_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
		if(JOB_TITLE_SPACEPOD_TECHNICIAN)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "mechanic_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
		if(JOB_TITLE_ENGINEER_TRAINEE)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "trainee_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/belt.dmi', "utility"), ICON_OVERLAY)
		if(JOB_TITLE_ROBOTICIST)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "robotics_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/suit.dmi', "labcoat_open"), ICON_OVERLAY)
		if(JOB_TITLE_SYNDICATE_AGENT)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "syndicate_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)
		if(JOB_TITLE_SYNDICATE_OFFICER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "syndicate_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "swat_gl"), ICON_UNDERLAY)
		if(JOB_TITLE_SYNDICATE_OPERATIVE)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "syndicate_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "jackboots"), ICON_UNDERLAY)
			clothes_s.Blend(new /icon('icons/mob/clothing/hands.dmi', "swat_gl"), ICON_UNDERLAY)
		if(JOB_TITLE_PRISONER)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "orange_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "orange"), ICON_UNDERLAY)
		if(JOB_TITLE_INVESTOR)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "really_black_suit_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
		if(JOB_TITLE_TEAM1)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "green_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "green"), ICON_UNDERLAY)
		if(JOB_TITLE_TEAM2)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "red_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "red"), ICON_UNDERLAY)
		if(JOB_TITLE_TEAM3)
			clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "blue_s")
			clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "blue"), ICON_UNDERLAY)
		else
			if(H.mind && (H.mind.assigned_role in get_all_centcom_jobs()))
				clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "officer_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "laceups"), ICON_UNDERLAY)
			else
				clothes_s = new /icon('icons/mob/clothing/uniform.dmi', "grey_s")
				clothes_s.Blend(new /icon('icons/mob/clothing/feet.dmi', "black"), ICON_UNDERLAY)

	preview_icon.Blend(face_s, ICON_OVERLAY) // Why do we do this twice
	if(clothes_s)
		preview_icon.Blend(clothes_s, ICON_OVERLAY)
	//Bus body accessories that go over clothes.
	if(H.body_accessory && istype(H.body_accessory, /datum/body_accessory/body))
		temp = new/icon("icon" = H.body_accessory.icon, "icon_state" = H.body_accessory.icon_state)
		if(H.body_accessory.pixel_x_offset)
			temp.Shift(EAST, H.body_accessory.pixel_x_offset)
		if(H.body_accessory.pixel_y_offset)
			temp.Shift(NORTH, H.body_accessory.pixel_y_offset)
		if(H.dna.species.bodyflags & HAS_SKIN_COLOR)
			temp.Blend(H.skin_colour, H.body_accessory.blend_mode)
		if(t_marking_s)
			temp.Blend(t_marking_s, ICON_OVERLAY)
		preview_icon.Blend(temp, ICON_OVERLAY)
	qdel(face_s)
	qdel(clothes_s)

	return preview_icon
