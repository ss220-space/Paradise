/mob/living/carbon/human/New(loc)
	icon = null // This is now handled by overlays -- we just keep an icon for the sake of the map editor.
	. = ..()


/mob/living/carbon/human/Initialize(mapload, datum/species/new_species = /datum/species/human)
	create_dna()

	. = ..()

	if(!tts_seed)
		tts_seed = SStts.get_random_seed(src)

	setup_dna(new_species)
	med_hud_set_health()	// Updating med huds is necessary after `setup_dna()` due to the fact that while
	med_hud_set_status()	// a human does not have a heart, the hud status is displayed incorrectly.

	create_reagents(330)

	handcrafting = new()

	AddComponent(/datum/component/footstep, FOOTSTEP_MOB_HUMAN, 1, -6)
	UpdateAppearance()
	GLOB.human_list += src


/mob/living/carbon/human/OpenCraftingMenu()
	handcrafting.ui_interact(src)

/mob/living/carbon/human/prepare_data_huds()
	//...sec hud images...
	sec_hud_set_ID()
	sec_hud_set_implants()
	sec_hud_set_security_status()
	//...and display them.
	add_to_all_human_data_huds()

/mob/living/carbon/human/Destroy()
	. = ..()
	SSmobs.cubemonkeys -= src
	QDEL_LIST(bodyparts)
	GLOB.human_list -= src

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	status_flags = GODMODE|CANPUSH

/mob/living/carbon/human/skrell/Initialize(mapload)
	. = ..(mapload, /datum/species/skrell)

/mob/living/carbon/human/tajaran/Initialize(mapload)
	. = ..(mapload, /datum/species/tajaran)

/mob/living/carbon/human/vulpkanin/Initialize(mapload)
	. = ..(mapload, /datum/species/vulpkanin)

/mob/living/carbon/human/unathi/Initialize(mapload)
	. = ..(mapload, /datum/species/unathi)

/mob/living/carbon/human/unathi_draconid/Initialize(mapload)
	. = ..(mapload, /datum/species/unathi/draconid)

/mob/living/carbon/human/unathi_ashwalker/Initialize(mapload)
	. = ..(mapload, /datum/species/unathi/ashwalker)

/mob/living/carbon/human/unathi_ashwalker_shaman/Initialize(mapload)
	. = ..(mapload, /datum/species/unathi/ashwalker/shaman)

/mob/living/carbon/human/vox/Initialize(mapload)
	. = ..(mapload, /datum/species/vox)

/mob/living/carbon/human/voxarmalis/Initialize(mapload)
	. = ..(mapload, /datum/species/vox/armalis)

/mob/living/carbon/human/skeleton/Initialize(mapload)
	. = ..(mapload, /datum/species/skeleton)

/mob/living/carbon/human/kidan/Initialize(mapload)
	. = ..(mapload, /datum/species/kidan)

/mob/living/carbon/human/plasma/Initialize(mapload)
	. = ..(mapload, /datum/species/plasmaman)

/mob/living/carbon/human/slime/Initialize(mapload)
	. = ..(mapload, /datum/species/slime)

/mob/living/carbon/human/grey/Initialize(mapload)
	. = ..(mapload, /datum/species/grey)

/mob/living/carbon/human/abductor/Initialize(mapload)
	. = ..(mapload, /datum/species/abductor)

/mob/living/carbon/human/diona/Initialize(mapload)
	. = ..(mapload, /datum/species/diona)
	if (!tts_seed)
		tts_seed = "Priest"

/mob/living/carbon/human/pod_diona/Initialize(mapload)
	. = ..(mapload, /datum/species/diona/pod)
	if (!tts_seed)
		tts_seed = "Priest"

/mob/living/carbon/human/machine/Initialize(mapload)
	. = ..(mapload, /datum/species/machine)

/mob/living/carbon/human/machine/created
	name = "Integrated Robotic Chassis"

/mob/living/carbon/human/machine/created/Initialize(mapload)
	. = ..()
	rename_character(null, "Integrated Robotic Chassis ([rand(1, 9999)])")
	update_dna()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(istype(bodypart, /obj/item/organ/external/chest) || istype(bodypart, /obj/item/organ/external/groin))
			continue
		qdel(bodypart)
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		qdel(organ)
	regenerate_icons()
	death()

/mob/living/carbon/human/shadow/Initialize(mapload)
	. = ..(mapload, /datum/species/shadow)

/mob/living/carbon/human/shadowling/Initialize(mapload)
	. = ..(mapload, /datum/species/shadow/ling)

/mob/living/carbon/human/golem/Initialize(mapload)
	. = ..(mapload, /datum/species/golem)

/mob/living/carbon/human/golem_random/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/random)

/mob/living/carbon/human/golem_adamantine/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/adamantine)

/mob/living/carbon/human/golem_plasma/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/plasma)

/mob/living/carbon/human/golem_diamond/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/diamond)

/mob/living/carbon/human/golem_gold/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/gold)

/mob/living/carbon/human/golem_silver/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/silver)

/mob/living/carbon/human/golem_plasteel/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/plasteel)

/mob/living/carbon/human/golem_titanium/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/titanium)

/mob/living/carbon/human/golem_plastitanium/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/plastitanium)

/mob/living/carbon/human/golem_alien_alloy/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/alloy)

/mob/living/carbon/human/golem_uranium/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/uranium)

/mob/living/carbon/human/golem_plastic/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/plastic)

/mob/living/carbon/human/golem_sand/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/sand)

/mob/living/carbon/human/golem_glass/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/glass)

/mob/living/carbon/human/golem_bluespace/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/bluespace)

/mob/living/carbon/human/golem_bananium/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/bananium)

/mob/living/carbon/human/golem_tranquillite/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/tranquillite)

/mob/living/carbon/human/golem_clockwork/Initialize(mapload)
	. = ..(mapload, /datum/species/golem/clockwork)

/mob/living/carbon/human/wryn/Initialize(mapload)
	. = ..(mapload, /datum/species/wryn)

/mob/living/carbon/human/nucleation/Initialize(mapload)
	. = ..(mapload, /datum/species/nucleation)

/mob/living/carbon/human/drask/Initialize(mapload)
	. = ..(mapload, /datum/species/drask)

/mob/living/carbon/human/moth/Initialize(mapload)
	. = ..(mapload, /datum/species/moth)
	if(!body_accessory)
		change_body_accessory("Plain Wings")

/mob/living/carbon/human/Stat()
	..()
	statpanel("Status")

	stat(null, "Intent: [a_intent]")
	stat(null, "Move Mode: [m_intent]")

	show_stat_emergency_shuttle_eta()

	if(client.statpanel == "Status")
		var/total_user_contents = GetAllContents() // cache it
		if(locate(/obj/item/gps) in total_user_contents)
			var/turf/T = get_turf(src)
			stat(null, "GPS: [COORD(T)]")
		if(locate(/obj/item/assembly/health) in total_user_contents)
			stat(null, "Health: [health]")
		if(internal)
			if(!internal.air_contents)
				qdel(internal)
			else
				stat(null, "Internals: [internal.name]")

		// I REALLY need to split up status panel things into datums
		var/mob/living/simple_animal/borer/B = has_brain_worms()
		if(B && B.controlling)
			stat("Chemicals", B.chemicals)

		if(mind)
			var/datum/antagonist/changeling/cling = mind.has_antag_datum(/datum/antagonist/changeling)
			if(cling)
				stat("Chemical Storage", "[cling.chem_charges]/[cling.chem_storage]")
				stat("Absorbed DNA", cling.absorbed_count)

			var/datum/antagonist/vampire/vamp = mind.has_antag_datum(/datum/antagonist/vampire)
			if(vamp)
				stat("Total Blood", "[vamp.bloodtotal]")
				stat("Usable Blood", "[vamp.bloodusable]")

			var/datum/antagonist/goon_vampire/g_vamp = mind.has_antag_datum(/datum/antagonist/goon_vampire)
			if(g_vamp)
				stat("Всего крови", "[g_vamp.bloodtotal]")
				stat("Доступная кровь", "[g_vamp.bloodusable]")

			if(isclocker(mind.current))
				stat("Total Power", "[GLOB.clockwork_power]")

			var/datum/antagonist/ninja/ninja = mind?.has_antag_datum(/datum/antagonist/ninja)
			if(ninja?.my_suit)
				stat("Заряд костюма","[ninja.get_cell_charge()]")
				stat("Заряд рывков","[ninja.get_dash_charge()]")

	if(istype(loc, /obj/spacepod)) // Spacdpods!
		var/obj/spacepod/S = loc
		stat("Spacepod Charge", "[istype(S.battery) ? "[(S.battery.charge / S.battery.maxcharge) * 100]" : "No cell detected"]")
		stat("Spacepod Integrity", "[!S.health ? "0" : "[(S.health / initial(S.health)) * 100]"]%")

///Define used for calculating explosve damage and effects upon humanoids. Result is >= 0
#define ex_armor_reduction(value, armor) (clamp(value * (1 - (armor / 100)), 0, INFINITY))

/mob/living/carbon/human/ex_act(severity)
	var/bruteloss = 0
	var/burnloss = 0

	if(status_flags & GODMODE)
		return 0

	var/armor = getarmor(null, "bomb")	//Average bomb protection
	var/limb_loss_reduction = FLOOR(armor / 25, 1) //It's guaranteed that every 25th armor point will protect from one delimb
	var/limbs_affected = 0

	switch(severity)
		if(1)
			if(prob(ex_armor_reduction(100, armor)) && armor < 100)
				gib()
				return 0
			else
				bruteloss += 500
				limbs_affected = pick(2,3,4)
				var/throw_distance = ex_armor_reduction(200, armor)
				var/throw_speed = ex_armor_reduction(4, armor)
				var/atom/target = get_edge_target_turf(src, get_dir(src, get_step_away(src, src)))
				throw_at(target, throw_distance, throw_speed)
		if(2)
			bruteloss += 60
			burnloss += 60
			limbs_affected = pick(1, 2, 3)

			if(check_ear_prot() < HEARING_PROTECTION_TOTAL)
				AdjustDeaf(ex_armor_reduction(120 SECONDS, armor))
				var/obj/item/organ/internal/ears/ears = get_int_organ(/obj/item/organ/internal/ears)
				if(istype(ears))
					ears.receive_damage(ex_armor_reduction(30, armor))

			Paralyse(ex_armor_reduction(20 SECONDS, armor))

		if(3)
			bruteloss += 30
			limbs_affected = pick(0, 1)

			if(check_ear_prot() < HEARING_PROTECTION_TOTAL)
				AdjustDeaf(ex_armor_reduction(60 SECONDS, armor))

			Paralyse(ex_armor_reduction(20 SECONDS, armor))

	limbs_affected = max(limbs_affected - limb_loss_reduction, 0)

	if(limbs_affected > 0)
		process_dismember(limbs_affected)
	bruteloss = ex_armor_reduction(bruteloss, armor)
	burnloss = ex_armor_reduction(burnloss, armor)
	take_overall_damage(bruteloss,burnloss, TRUE, used_weapon = "Explosive Blast")

	..()

/mob/living/carbon/human/proc/process_dismember(limbs_affected)
	var/list/valid_limbs = bodyparts.Copy()

	while(limbs_affected && length(valid_limbs))
		var/obj/item/organ/external/processing_dismember = pick_n_take(valid_limbs)
		if(processing_dismember.limb_zone != BODY_ZONE_CHEST && processing_dismember.limb_zone != BODY_ZONE_HEAD && processing_dismember.limb_zone != BODY_ZONE_PRECISE_GROIN)
			processing_dismember.droplimb(TRUE, DROPLIMB_SHARP, FALSE, TRUE)
			limbs_affected--

#undef ex_armor_reduction

/mob/living/carbon/human/blob_act(obj/structure/blob/B)
	if(stat == DEAD)
		return
	SEND_SIGNAL(src, COMSIG_ATOM_BLOB_ACT, B)
	show_message("<span class='userdanger'>The blob attacks you!</span>")
	var/dam_zone = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_R_FOOT,
	)
	var/obj/item/organ/external/affecting = get_organ(ran_zone(dam_zone))
	apply_damage(5, BRUTE, affecting, run_armor_check(affecting, "melee"))

/mob/living/carbon/human/get_restraining_item()
	. = ..()
	if(!. && istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		. = wear_suit

/mob/living/carbon/human/var/temperature_resistance = T0C+75


/mob/living/carbon/human/show_inv(mob/user)
	user.set_machine(src)
	var/has_breathable_mask = istype(wear_mask, /obj/item/clothing/mask) || get_organ_slot(INTERNAL_ORGAN_BREATHING_TUBE)
	var/list/obscured = check_obscured_slots()

	var/dat = {"<meta charset="UTF-8"><table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[slot_l_hand]'>[(l_hand && !(l_hand.flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[slot_r_hand]'>[(r_hand && !(r_hand.flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[slot_back]'>[(back && !(back.flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A>"
	if(has_breathable_mask && istype(back, /obj/item/tank))
		dat += "&nbsp;<A href='?src=[UID()];internal=[slot_back]'>[internal ? "Disable Internals" : "Set Internals"]</A>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[slot_head]'>[(head && !(head.flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	var/obj/item/organ/internal/headpocket/C = get_int_organ(/obj/item/organ/internal/headpocket)
	if(C)
		if(slot_wear_mask in obscured)
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Headpocket:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			var/list/items = C.get_contents()
			if(items.len)
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><A href='?src=[UID()];dislodge_headpocket=1'>Dislodge Items</A></td></tr>"
			else
				dat += "<tr><td>&nbsp;&#8627;<B>Headpocket:</B></td><td><font color=grey>Empty</font></td></tr>"

	if(slot_wear_mask in obscured)
		dat += "<tr><td><font color=grey><B>Mask:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[slot_wear_mask]'>[(wear_mask && !(wear_mask.flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A>"

		if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
			var/obj/item/clothing/mask/muzzle/M = wear_mask
			if(M.security_lock)
				dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

	if(slot_neck in obscured)
		dat += "<tr><td><font color=grey><B>Neck:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Neck:</B></td><td><A href='?src=[UID()];item=[slot_neck]'>[(neck && !(neck.flags&ABSTRACT))	? html_encode(neck) : "<font color=grey>Empty</font>"]</A></td></tr>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(slot_glasses in obscured)
		dat += "<tr><td><font color=grey><B>Eyes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Eyes:</B></td><td><A href='?src=[UID()];item=[slot_glasses]'>[(glasses && !(glasses.flags&ABSTRACT))	? glasses : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_l_ear in obscured)
		dat += "<tr><td><font color=grey><B>Left Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Left Ear:</B></td><td><A href='?src=[UID()];item=[slot_l_ear]'>[(l_ear && !(l_ear.flags&ABSTRACT))		? l_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_r_ear in obscured)
		dat += "<tr><td><font color=grey><B>Right Ear:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Right Ear:</B></td><td><A href='?src=[UID()];item=[slot_r_ear]'>[(r_ear && !(r_ear.flags&ABSTRACT))		? r_ear		: "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Exosuit:</B></td><td><A href='?src=[UID()];item=[slot_wear_suit]'>[(wear_suit && !(wear_suit.flags&ABSTRACT)) ? wear_suit : "<font color=grey>Empty</font>"]</A></td></tr>"
	if(wear_suit)
		dat += "<tr><td>&nbsp;&#8627;<B>Suit Storage:</B></td><td><A href='?src=[UID()];item=[slot_s_store]'>[(s_store && !(s_store.flags&ABSTRACT)) ? s_store : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(s_store, /obj/item/tank))
			dat += "&nbsp;<A href='?src=[UID()];internal=[slot_s_store]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
	else
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Storage:</B></font></td></tr>"

	if(slot_shoes in obscured)
		dat += "<tr><td><font color=grey><B>Shoes:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Shoes:</B></td><td><A href='?src=[UID()];item=[slot_shoes]'>[(shoes && !(shoes.flags&ABSTRACT))		? shoes		: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(!issmall(src))
		if(slot_gloves in obscured)
			dat += "<tr><td><font color=grey><B>Gloves:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
		else
			dat += "<tr><td><B>Gloves:</B></td><td><A href='?src=[UID()];item=[slot_gloves]'>[(gloves && !(gloves.flags&ABSTRACT))		? gloves	: "<font color=grey>Empty</font>"]</A></td></tr>"

	if(slot_w_uniform in obscured)
		dat += "<tr><td><font color=grey><B>Uniform:</B></font></td><td><font color=grey>Obscured</font></td></tr>"
	else
		dat += "<tr><td><B>Uniform:</B></td><td><A href='?src=[UID()];item=[slot_w_uniform]'>[(w_uniform && !(w_uniform.flags&ABSTRACT)) ? w_uniform : "<font color=grey>Empty</font>"]</A></td></tr>"

	if((w_uniform == null && !(dna && dna.species.nojumpsuit)) || (slot_w_uniform in obscured))
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Pockets:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>ID:</B></font></td></tr>"
		if(!issmall(src))
			dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Belt:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>Suit Sensors:</B></font></td></tr>"
		dat += "<tr><td><font color=grey>&nbsp;&#8627;<B>PDA:</B></font></td></tr>"
	else
		if(!issmall(src))
			dat += "<tr><td>&nbsp;&#8627;<B>Belt:</B></td><td><A href='?src=[UID()];item=[slot_belt]'>[(belt && !(belt.flags&ABSTRACT)) ? belt : "<font color=grey>Empty</font>"]</A>"
		if(has_breathable_mask && istype(belt, /obj/item/tank))
			dat += "&nbsp;<A href='?src=[UID()];internal=[slot_belt]'>[internal ? "Disable Internals" : "Set Internals"]</A>"
		dat += "</td></tr>"
		// Pockets
		dat += "<tr><td>&nbsp;&#8627;<B>Pockets:</B></td><td><A href='?src=[UID()];pockets=left'>"
		if(l_store && internal && l_store == internal)
			dat += "[l_store]"
		else if(l_store && !(l_store.flags&ABSTRACT))
			dat += "Left (Full)"
		else
			dat += "<font color=grey>Left (Empty)</font>"
		dat += "</A>&nbsp;<A href='?src=[UID()];pockets=right'>"
		if(r_store && internal && r_store == internal)
			dat += "[r_store]"
		else if(r_store && !(r_store.flags&ABSTRACT))
			dat += "Right (Full)"
		else
			dat += "<font color=grey>Right (Empty)</font>"
		dat += "</A></td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>ID:</B></td><td><A href='?src=[UID()];item=[slot_wear_id]'>[(wear_id && !(wear_id.flags&ABSTRACT)) ? wear_id : "<font color=grey>Empty</font>"]</A></td></tr>"
		dat += "<tr><td>&nbsp;&#8627;<B>PDA:</B></td><td><A href='?src=[UID()];item=[slot_wear_pda]'>[(wear_pda && !(wear_pda.flags&ABSTRACT)) ? wear_pda : "<font color=grey>Empty</font>"]</A></td></tr>"

		if(istype(w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = w_uniform
			dat += "<tr><td>&nbsp;&#8627;<B>Suit Sensors:</b></td><td><A href='?src=[UID()];set_sensor=1'>[U.has_sensor >= 2 ? "</a><font color=grey>--SENSORS LOCKED--</font>" : "Set Sensors</a>"]</td></tr>"

			if(U.accessories.len)
				dat += "<tr><td>&nbsp;&#8627;<A href='?src=[UID()];strip_accessory=1'>Remove Accessory</a></td></tr>"


	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[slot_handcuffed]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[slot_legcuffed]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 540)
	popup.set_content(dat)
	popup.open()

// Get rank from ID from hands, wear_id, pda, and then from uniform
/mob/living/carbon/human/proc/get_authentification_rank(var/if_no_id = "No id", var/if_no_job = "No job")
	var/obj/item/card/id/id = get_id_card()
	if(id)
		return id.rank ? id.rank : if_no_job
	return if_no_id

//gets assignment from wear_id ID or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_assignment(if_no_id = "No id", if_no_job = "No job")
	if(!wear_id)
		return if_no_id
	var/obj/item/card/id/id = wear_id.GetID()
	if(istype(id))
		return id.assignment
	var/obj/item/pda/pda = wear_id
	if(istype(pda))
		return pda.ownjob
	return if_no_job

//gets name from ID or ID inside PDA or PDA itself
//Useful when player do something with computers
/mob/living/carbon/human/proc/get_authentification_name(var/if_no_id = "Unknown")
	var/name = if_no_id
	if(wear_id)
		if(wear_id.GetID())
			var/obj/item/card/id/id = wear_id.GetID()
			name = id.registered_name
		else if(ispda(wear_id))
			var/obj/item/pda/pda = wear_id
			name = pda.owner
	return name

//repurposed proc. Now it combines get_id_name() and get_face_name() to determine a mob's name variable. Made into a seperate proc as it'll be useful elsewhere
/mob/living/carbon/human/get_visible_name(var/id_override = FALSE)
	if(name_override)
		return name_override
	if(wear_mask && (wear_mask.flags_inv & HIDENAME))	//Wearing a mask which hides our face, use id-name if possible
		return get_id_name("Unknown")
	if(head && (head.flags_inv & HIDENAME))
		return get_id_name("Unknown")		//Likewise for hats
	var/face_name = get_face_name()
	var/id_name = get_id_name("")
	if(id_name && (id_name != face_name) && !id_override)
		return "[face_name] (as [id_name])"
	return face_name

//Returns "Unknown" if facially disfigured and real_name if not. Useful for setting name when polyacided or when updating a human's name variable
/mob/living/carbon/human/proc/get_face_name()
	var/obj/item/organ/external/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!head_organ || head_organ.is_disfigured() || cloneloss > 50 || !real_name || (HUSK in mutations))	//disfigured. use id-name if possible
		return "Unknown"
	return real_name


/**
 * Gets name from ID or PDA itself, ID inside PDA doesn't matter.
 * Useful when player is being seen by other mobs.
 */
/mob/living/carbon/human/proc/get_id_name(if_no_id = "Unknown")
	var/obj/item/card/id/id = wear_id?.GetID()
	if(istype(id))
		return id.registered_name

	if(is_pda(wear_id))
		var/obj/item/pda/pda = wear_id
		return pda.owner

	if(istype(wear_id, /obj/item/storage/wallet))
		var/obj/item/storage/wallet/wallet = wear_id
		return wallet.front_id ? wallet.front_id.registered_name : if_no_id

	return if_no_id	//to prevent null-names making the mob unclickable


//Gets ID card object from hands only
/mob/living/carbon/human/proc/get_id_from_hands()
	var/obj/item/card/id/id = null
	var/obj/item/active_hand = get_active_hand()
	var/obj/item/inactive_hand = get_inactive_hand()
	if(istype(active_hand) && active_hand.GetID())
		id = active_hand.GetID()
	else if(istype(inactive_hand) && inactive_hand.GetID())
		id = inactive_hand.GetID()
	return id

/mob/living/carbon/human/update_sight()
	if(!client)
		return

	if(stat == DEAD)
		grant_death_vision()
		return

	dna.species.update_sight(src)
	SEND_SIGNAL(src, COMSIG_MOB_UPDATE_SIGHT)
	sync_lighting_plane_alpha()

//Added a safety check in case you want to shock a human mob directly through electrocute_act.
/mob/living/carbon/human/electrocute_act(shock_damage, obj/source, siemens_coeff = 1, safety = FALSE, override = FALSE, tesla_shock = FALSE, illusion = FALSE, stun = TRUE)
	if(tesla_shock)
		var/total_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			if(G.siemens_coefficient <= 0)
				total_coeff -= 0.5
		if(wear_suit)
			var/obj/item/clothing/suit/S = wear_suit
			if(S.siemens_coefficient <= 0)
				total_coeff -= 0.95
			else if(S.siemens_coefficient == (-1))
				total_coeff -= 1
		siemens_coeff = total_coeff
		if(tesla_ignore)
			siemens_coeff = 0
	else if(!safety)
		var/gloves_siemens_coeff = 1
		if(gloves)
			var/obj/item/clothing/gloves/G = gloves
			gloves_siemens_coeff = G.siemens_coefficient
		siemens_coeff = gloves_siemens_coeff
	if(undergoing_cardiac_arrest() && !illusion)
		if(shock_damage * siemens_coeff >= 1 && prob(25))
			set_heartattack(FALSE)
			if(stat == CONSCIOUS)
				to_chat(src, "<span class='notice'>You feel your heart beating again!</span>")

	dna.species.spec_electrocute_act(src, shock_damage, source, siemens_coeff, safety, override, tesla_shock, illusion, stun)
	. = ..(shock_damage, source, siemens_coeff, safety, override, tesla_shock, illusion, stun)

/mob/living/carbon/human/Topic(href, href_list)
	if(!usr.stat && usr.canmove && !usr.restrained() && in_range(src, usr))
		var/thief_mode = 0
		if(ishuman(usr))
			var/mob/living/carbon/human/H = usr
			var/obj/item/clothing/gloves/G = H.gloves
			if(G && G.pickpocket)
				thief_mode = 1

		if(href_list["embedded_object"])
			var/obj/item/organ/external/bodypart = locate(href_list["embedded_limb"]) in bodyparts
			if(QDELETED(bodypart) || !LAZYLEN(bodypart.embedded_objects))
				return
			var/obj/item/thing = locate(href_list["embedded_object"]) in bodypart.embedded_objects
			if(QDELETED(thing) || thing.loc != bodypart) //no item, no limb, or item is not in limb or in the person anymore
				return
			var/time_taken = thing.embedded_unsafe_removal_time * thing.w_class
			usr.visible_message(
				span_warning("[usr] attempts to remove [thing] from [usr.p_their()] [bodypart.name]."),
				span_notice("You attempt to remove [thing] from your [bodypart.name]... (It will take [time_taken/10] seconds.)"),
			)
			if(do_after(usr, time_taken, needhand = TRUE, target = src))
				if(QDELETED(thing) || QDELETED(bodypart) || thing.loc != bodypart || !LAZYIN(bodypart.embedded_objects, thing))
					return
				bodypart.remove_embedded_object(thing)
				bodypart.receive_damage(thing.embedded_unsafe_removal_pain_multiplier * thing.w_class)//It hurts to rip it out, get surgery you dingus.
				usr.put_in_hands(thing)
				if(ishuman(usr))
					var/mob/living/carbon/human/h_user = usr
					if(h_user.has_pain())
						h_user.emote("scream")
				usr.visible_message(
					span_warning("[usr] successfully rips [thing] out of [usr.p_their()] [bodypart.name]!"),
					span_notice("You successfully remove [thing] from your [bodypart.name]."),
				)
			return

		if(href_list["item"])
			var/slot = text2num(href_list["item"])
			if(slot in check_obscured_slots())
				to_chat(usr, "<span class='warning'>You can't reach that! Something is covering it.</span>")
				return

		if(href_list["pockets"])
			var/pocket_side = href_list["pockets"]
			var/pocket_id = (pocket_side == "right" ? slot_r_store : slot_l_store)
			var/obj/item/pocket_item = (pocket_id == slot_r_store ? r_store : l_store)
			var/obj/item/place_item = usr.get_active_hand() // Item to place in the pocket, if it's empty

			var/delay_denominator = 1
			if(pocket_item && !(pocket_item.flags&ABSTRACT))
				if(pocket_item.flags & NODROP)
					to_chat(usr, "<span class='warning'>You try to empty [src]'s [pocket_side] pocket, it seems to be stuck!</span>")
				to_chat(usr, "<span class='notice'>You try to empty [src]'s [pocket_side] pocket.</span>")
			else if(place_item && place_item.mob_can_equip(src, pocket_id, TRUE) && !(place_item.flags&ABSTRACT))
				to_chat(usr, "<span class='notice'>You try to place [place_item] into [src]'s [pocket_side] pocket.</span>")
				delay_denominator = 4
			else
				return

			if(do_mob(usr, src, POCKET_STRIP_DELAY/delay_denominator)) //placing an item into the pocket is 4 times faster
				if(pocket_item)
					if(pocket_item == (pocket_id == slot_r_store ? r_store : l_store)) //item still in the pocket we search
						if(drop_item_ground(pocket_item))
							if(thief_mode)
								usr.put_in_hands(pocket_item)
							add_attack_logs(usr, src, "Stripped of [pocket_item]")
				else
					if(place_item)
						usr.drop_item_ground(place_item)
						equip_to_slot_if_possible(place_item, pocket_id, disable_warning = TRUE)
						add_attack_logs(usr, src, "Equipped with [place_item]")

				// Update strip window
				if(usr.machine == src && in_range(src, usr))
					show_inv(usr)
			else
				// Display a warning if the user mocks up if they don't have pickpocket gloves.
				if(!thief_mode)
					to_chat(src, "<span class='warning'>You feel your [pocket_side] pocket being fumbled with!</span>")
				add_attack_logs(usr, src, "Attempted strip of [pocket_item]")

		if(href_list["set_sensor"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				U.set_sensors(usr)

		if(href_list["dislodge_headpocket"])
			usr.visible_message("<span class='danger'>[usr] is trying to remove something from [src]'s head!</span>",
													"<span class='danger'>You start to dislodge whatever's inside [src]'s headpocket!</span>")
			if(do_mob(usr, src, POCKET_STRIP_DELAY))
				usr.visible_message("<span class='danger'>[usr] has dislodged something from [src]'s head!</span>",
														"<span class='danger'>You have dislodged everything from [src]'s headpocket!</span>")
				var/obj/item/organ/internal/headpocket/C = get_int_organ(/obj/item/organ/internal/headpocket)
				C.empty_contents()
				add_attack_logs(usr, src, "Stripped of headpocket items")

		if(href_list["strip_accessory"])
			if(istype(w_uniform, /obj/item/clothing/under))
				var/obj/item/clothing/under/U = w_uniform
				if(U.accessories.len)
					var/obj/item/clothing/accessory/A = U.accessories[1]
					if(!thief_mode)
						usr.visible_message("<span class='danger'>\The [usr] starts to take off \the [A] from \the [src]'s [U]!</span>", \
											"<span class='danger'>You start to take off \the [A] from \the [src]'s [U]!</span>")

					if(do_mob(usr, src, 40) && A && U.accessories.len)
						if(!thief_mode)
							usr.visible_message("<span class='danger'>\The [usr] takes \the [A] off of \the [src]'s [U]!</span>", \
												"<span class='danger'>You take \the [A] off of \the [src]'s [U]!</span>")
						A.on_removed(usr)
						U.accessories -= A
						update_inv_w_uniform()

	if(href_list["criminal"])
		if(hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
			if(usr.incapacitated())
				return
			var/found_record = 0
			var/perpname = get_visible_name(TRUE)

			if(perpname != "Unknown")
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == perpname)
						for(var/datum/data/record/R in GLOB.data_core.security)
							if(R.fields["id"] == E.fields["id"])

								var/setcriminal = tgui_input_list(usr, "Specify a new criminal status for this person.", "Security HUD", list(SEC_RECORD_STATUS_NONE, SEC_RECORD_STATUS_ARREST, SEC_RECORD_STATUS_SEARCH, SEC_RECORD_STATUS_MONITOR, SEC_RECORD_STATUS_DEMOTE, SEC_RECORD_STATUS_INCARCERATED, SEC_RECORD_STATUS_PAROLLED, SEC_RECORD_STATUS_RELEASED), R.fields["criminal"])
								if(!setcriminal)
									return
								var/t1 = copytext(trim(sanitize(input("Enter Reason:", "Security HUD", null, null) as text)), 1, MAX_MESSAGE_LEN)
								if(!t1)
									t1 = "(none)"

								if(hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE) && setcriminal != "Cancel")
									found_record = 1
									if(R.fields["criminal"] == SEC_RECORD_STATUS_EXECUTE)
										to_chat(usr, "<span class='warning'>Unable to modify the sec status of a person with an active Execution order. Use a security computer instead.</span>")
									else
										var/rank
										if(ishuman(usr))
											var/mob/living/carbon/human/U = usr
											rank = U.get_assignment()
										else if(isrobot(usr))
											var/mob/living/silicon/robot/U = usr
											rank = "[U.modtype] [U.braintype]"
										else if(isAI(usr))
											rank = "AI"
										set_criminal_status(usr, R, setcriminal, t1, rank)
								break // Git out of the securiy records loop!
						if(found_record)
							break // Git out of the general records

			if(!found_record)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecord"])
		if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
			if(usr.incapacitated())
				return
			var/perpname = get_visible_name(TRUE)
			var/read = 0

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Criminal Status:</b> [R.fields["criminal"]]")
								to_chat(usr, "<b>Minor Crimes:</b> [R.fields["mi_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_crim_d"]]")
								to_chat(usr, "<b>Major Crimes:</b> [R.fields["ma_crim"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_crim_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=[UID()];secrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordComment"])
		if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
			if(usr.incapacitated() && !isobserver(usr)) //give the ghosts access to "View Comment Log" while they can't manipulate it
				return
			var/perpname = get_visible_name(TRUE)
			var/read = 0

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_SECURITY_READ))
								read = 1
								if(LAZYLEN(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comments found</span>")
								if(hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
									to_chat(usr, "<a href='?src=[UID()];secrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["secrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_SECURITY_WRITE))
			return
		var/raw_input = input("Add Comment:", "Security records", null, null) as message
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_SECURITY_WRITE))
			return
		add_comment(usr, "security", sanitized)

	if(href_list["medical"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/modified = 0
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.general)
						if(R.fields["id"] == E.fields["id"])
							var/setmedical = input(usr, "Specify a new medical status for this person.", "Medical HUD", R.fields["p_stat"]) in list("*SSD*", "*Deceased*", "Physically Unfit", "Active", "Disabled", "Cancel")

							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								if(setmedical != "Cancel")
									R.fields["p_stat"] = setmedical
									modified = 1
									if(GLOB.PDA_Manifest.len)
										GLOB.PDA_Manifest.Cut()

									spawn()
										sec_hud_set_security_status()

			if(!modified)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecord"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/read = 0
			var/perpname = get_visible_name(TRUE)

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								to_chat(usr, "<b>Name:</b> [R.fields["name"]]	<b>Blood Type:</b> [R.fields["b_type"]]")
								to_chat(usr, "<b>DNA:</b> [R.fields["b_dna"]]")
								to_chat(usr, "<b>Minor Disabilities:</b> [R.fields["mi_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["mi_dis_d"]]")
								to_chat(usr, "<b>Major Disabilities:</b> [R.fields["ma_dis"]]")
								to_chat(usr, "<b>Details:</b> [R.fields["ma_dis_d"]]")
								to_chat(usr, "<b>Notes:</b> [R.fields["notes"]]")
								to_chat(usr, "<a href='?src=[UID()];medrecordComment=`'>\[View Comment Log\]</a>")
								read = 1

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordComment"])
		if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
			if(usr.incapacitated())
				return
			var/perpname = get_visible_name(TRUE)
			var/read = FALSE

			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.medical)
						if(R.fields["id"] == E.fields["id"])
							if(hasHUD(usr, EXAMINE_HUD_MEDICAL))
								read = TRUE
								if(LAZYLEN(R.fields["comments"]))
									for(var/c in R.fields["comments"])
										to_chat(usr, c)
								else
									to_chat(usr, "<span class='warning'>No comment found</span>")
								to_chat(usr, "<a href='?src=[UID()];medrecordadd=`'>\[Add comment\]</a>")

			if(!read)
				to_chat(usr, "<span class='warning'>Unable to locate a data core entry for this person.</span>")

	if(href_list["medrecordadd"])
		if(usr.incapacitated() || !hasHUD(usr, EXAMINE_HUD_MEDICAL))
			return
		var/raw_input = input("Add Comment:", "Medical records", null, null) as message
		var/sanitized = copytext(trim(sanitize(raw_input)), 1, MAX_MESSAGE_LEN)
		if(!sanitized || usr.stat || usr.restrained() || !hasHUD(usr,  EXAMINE_HUD_MEDICAL))
			return
		add_comment(usr, "medical", sanitized)

	if(href_list["employment_more"])
		if(hasHUD(usr, EXAMINE_HUD_SKILLS))
			if(usr.incapacitated() && !isobserver(usr))
				return

			var/skills
			var/perpname = get_visible_name(TRUE)
			if(perpname)
				for(var/datum/data/record/E in GLOB.data_core.general)
					if(E.fields["name"] == perpname)
						skills = E.fields["notes"]
						break
				if(skills)
					to_chat(usr, "<span class='deptradio'>Employment records: [skills]</span>\n")

	if(href_list["lookitem"])
		var/obj/item/I = locate(href_list["lookitem"])
		src.examinate(I)

	if(href_list["lookmob"])
		var/mob/M = locate(href_list["lookmob"])
		src.examinate(M)
	. = ..()


///check_eye_prot()
///Returns a number between -1 to 2
/mob/living/carbon/human/check_eye_prot()
	var/number = ..()
	if(istype(head, /obj/item/clothing/head))			//are they wearing something on their head
		var/obj/item/clothing/head/HFP = head			//if yes gets the flash protection value from that item
		number += HFP.flash_protect
	if(istype(glasses, /obj/item/clothing/glasses))		//glasses
		var/obj/item/clothing/glasses/GFP = glasses
		number += GFP.flash_protect
	if(istype(wear_mask, /obj/item/clothing/mask))		//mask
		var/obj/item/clothing/mask/MFP = wear_mask
		number += MFP.flash_protect
	for(var/obj/item/organ/internal/cyberimp/eyes/EFP in internal_organs)
		number += EFP.flash_protect
	return number


/mob/living/carbon/human/check_ear_prot()
	. = ..()
	if(.)
		return
	if(!can_hear())
		return HEARING_PROTECTION_TOTAL
	if(istype(l_ear, /obj/item/clothing/ears/earmuffs))
		return HEARING_PROTECTION_TOTAL
	if(istype(r_ear, /obj/item/clothing/ears/earmuffs))
		return HEARING_PROTECTION_TOTAL
	if(head && (head.flags & HEADBANGPROTECT))
		return HEARING_PROTECTION_MINOR
	if(l_ear && (l_ear.flags & EARBANGPROTECT))
		return HEARING_PROTECTION_MINOR
	if(r_ear && (r_ear.flags & EARBANGPROTECT))
		return HEARING_PROTECTION_MINOR


/mob/living/carbon/human/abiotic(var/full_body = 0)
	if(full_body && ((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)) || (src.back || src.wear_mask || src.head || src.shoes || src.w_uniform || src.wear_suit || src.glasses || src.l_ear || src.r_ear || src.gloves)))
		return 1

	if((src.l_hand && !(src.l_hand.flags & ABSTRACT)) || (src.r_hand && !(src.r_hand.flags & ABSTRACT)))
		return 1

	return 0


/mob/living/carbon/human/proc/check_dna()
	dna.check_integrity(src)

/mob/living/carbon/human/proc/play_xylophone()
	if(!src.xylophone)
		visible_message("<span class='warning'>[src] begins playing [p_their()] ribcage like a xylophone. It's quite spooky.</span>","<span class='notice'>You begin to play a spooky refrain on your ribcage.</span>","<span class='warning'>You hear a spooky xylophone melody.</span>")
		var/song = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(loc, song, 50, 1, -1)
		xylophone = 1
		spawn(1200)
			xylophone=0
	return

/mob/living/carbon/human/can_inject(mob/user, error_msg, target_zone, penetrate_thick = FALSE, ignore_pierceimmune = FALSE)
	. = TRUE

	if(!target_zone)
		if(!user)
			. = FALSE
			CRASH("can_inject() called on a human mob with neither a user nor a targeting zone selected.")
		else
			target_zone = user.zone_selected

	var/obj/item/organ/external/affecting = get_organ(target_zone)
	var/fail_msg
	if(!affecting)
		. = FALSE
		fail_msg = "[p_they(TRUE)] [p_are()] missing that limb."
	else if(affecting.is_robotic())
		. = FALSE
		fail_msg = "That limb is robotic."
	// affecting.open = 2 after scalpel->hemostat->retractor
	else if((PIERCEIMMUNE in dna.species.species_traits) && !ignore_pierceimmune && affecting.open < 2)
		. = FALSE
	else
		switch(target_zone)
			if(BODY_ZONE_HEAD)
				if(head && head.flags & THICKMATERIAL && !penetrate_thick)
					. = FALSE
			else
				if(wear_suit && wear_suit.flags & THICKMATERIAL && !penetrate_thick)
					. = FALSE
	if(!. && error_msg && user)
		if(!fail_msg)
			fail_msg = "There is no exposed flesh or thin material [target_zone == BODY_ZONE_HEAD ? "on [p_their()] head" : "on [p_their()] body"] to inject into."
		to_chat(user, "<span class='alert'>[fail_msg]</span>")

/mob/living/carbon/human/proc/check_obscured_slots()
	var/list/obscured = list()

	if(wear_suit)
		if(wear_suit.flags_inv & HIDEGLOVES)
			obscured |= slot_gloves
		if(wear_suit.flags_inv & HIDEJUMPSUIT)
			obscured |= slot_w_uniform
		if(wear_suit.flags_inv & HIDESHOES)
			obscured |= slot_shoes

	if(head)
		if(head.flags_inv & HIDEMASK)
			obscured |= slot_wear_mask
		if(head.flags_inv & HIDEGLASSES)
			obscured |= slot_glasses
		if(head.flags_inv & HIDEHEADSETS)
			obscured |= slot_r_ear
			obscured |= slot_l_ear

	if(wear_mask)
		if(wear_mask.flags_inv & HIDEGLASSES)
			obscured |= slot_glasses
		if(wear_mask.flags_inv & HIDEHEADSETS)
			obscured |= slot_r_ear
			obscured |= slot_l_ear

	if(obscured.len > 0)
		return obscured
	else
		return null

/mob/living/carbon/human/proc/check_has_mouth()
	// Todo, check stomach organ when implemented.
	var/obj/item/organ/external/head/H = get_organ(BODY_ZONE_HEAD)
	if(!H || !H.can_intake_reagents)
		return 0
	return 1

/mob/living/carbon/human/get_visible_gender()
	var/list/obscured = check_obscured_slots()
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDENAME)) || (head && (head.flags_inv & HIDENAME))
	if((slot_w_uniform in obscured) && skipface)
		return PLURAL
	return gender

/mob/living/carbon/human/get_visible_species()
	var/displayed_species = dna.species.name
	for(var/obj/item/clothing/C in src)			//Disguise checks
		if(C == head || C == wear_suit || C == wear_mask || C == w_uniform || C == belt || C == back)
			if(C.species_disguise)
				displayed_species = C.species_disguise
	return displayed_species

/mob/living/carbon/human/proc/increase_germ_level(n)
	if(gloves)
		gloves.germ_level += n
	else
		germ_level += n


/**
 * Regenerate missing limbs/organs with defined in species datum.
 */
/mob/living/carbon/human/proc/check_and_regenerate_organs()
	var/datum/species/species = dna?.species
	if(!species)
		return FALSE

	for(var/limb_zone in species.has_limbs)
		if(!bodyparts_by_name[limb_zone])
			var/list/organ_data = species.has_limbs[limb_zone]
			var/limb_path = organ_data["path"]
			var/obj/item/organ/new_organ = new limb_path(src)
			organ_data["descriptor"] = new_organ.name

	for(var/organ_slot in species.has_organ)
		if(!internal_organs_slot[organ_slot])
			var/organ_path = species.has_organ[organ_slot]
			new organ_path(src)

	return TRUE


/mob/living/carbon/human/revive()
	//Fix up all organs and replace lost ones.
	restore_all_organs() //Rejuvenate and reset all existing organs.
	check_and_regenerate_organs() //Regenerate limbs and organs only if they're really missing.
	surgeries.Cut() //End all surgeries.

	if(!isskeleton(src) && (SKELETON in mutations))
		mutations.Remove(SKELETON)
	if(NOCLONE in mutations)
		mutations.Remove(NOCLONE)
	if(HUSK in mutations)
		mutations.Remove(HUSK)

	if(!client || !key) //Don't boot out anyone already in the mob.
		for(var/obj/item/organ/internal/brain/H in world)
			if(H.brainmob)
				if(H.brainmob.real_name == src.real_name)
					if(H.brainmob.mind)
						H.brainmob.mind.transfer_to(src)
						qdel(H)

	..()

/mob/living/carbon/human/proc/is_lung_ruptured()
	var/obj/item/organ/internal/lungs/L = get_int_organ(/obj/item/organ/internal/lungs)
	if(!L)
		return 0

	return L.is_bruised()

/mob/living/carbon/human/proc/rupture_lung()
	var/obj/item/organ/internal/lungs/L = get_int_organ(/obj/item/organ/internal/lungs)
	if(!L)
		return 0

	if(!L.is_bruised())
		custom_pain("You feel a stabbing pain in your chest!")
		L.damage = L.min_bruised_damage

/mob/living/carbon/human/cuff_resist(obj/item/I)
	if(HULK in mutations)
		say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
		if(..(I, cuff_break = TRUE))
			drop_item_ground(I, force = TRUE)
	else
		if(..())
			drop_item_ground(I, force = TRUE)

/mob/living/carbon/human/resist_restraints()
	if(wear_suit && wear_suit.breakouttime)
		cuff_resist(wear_suit)
	else
		..()

/mob/living/carbon/human/generate_name()
	name = dna.species.get_random_name(gender)
	real_name = name
	if(dna)
		dna.real_name = name
	return name

/mob/living/carbon/human/verb/check_pulse()
	set category = null
	set name = "Check pulse"
	set desc = "Approximately count somebody's pulse. Requires you to stand still at least 6 seconds."
	set src in view(1)
	var/self = 0

	if(usr.stat == 1 || usr.restrained() || !isliving(usr) || usr.is_dead()) return

	if(usr == src)
		self = 1
	if(!self)
		usr.visible_message("<span class='notice'>[usr] kneels down, puts [usr.p_their()] hand on [src]'s wrist and begins counting [p_their()] pulse.</span>",\
		"You begin counting [src]'s pulse")
	else
		usr.visible_message("<span class='notice'>[usr] begins counting [p_their()] pulse.</span>",\
		"You begin counting your pulse.")

	if(src.pulse)
		to_chat(usr, "<span class='notice'>[self ? "You have a" : "[src] has a"] pulse! Counting...</span>")
	else
		to_chat(usr, "<span class='warning'>[src] has no pulse!</span>")//it is REALLY UNLIKELY that a dead person would check his own pulse

		return

	to_chat(usr, "Don't move until counting is finished.")
	var/time = world.time
	sleep(60)
	if(usr.l_move_time >= time)	//checks if our mob has moved during the sleep()
		to_chat(usr, "You moved while counting. Try again.")
	else
		to_chat(usr, "<span class='notice'>[self ? "Your" : "[src]'s"] pulse is [src.get_pulse(GETPULSE_HAND)].</span>")


/**
  * Set up DNA and species.
  *
  * Arguments:
  * * new_species - The new species to assign.
  */
/mob/living/carbon/human/proc/setup_dna(datum/species/new_species)
	set_species(new_species, use_default_color = TRUE, delay_icon_update = TRUE, skip_same_check = TRUE)
	// Name
	real_name = dna.species.get_random_name(gender)
	name = real_name
	if(mind)
		mind.name = real_name

	// DNA ready
	dna.ready_dna(src)
	dna.species.handle_dna(src)
	dna.real_name = real_name
	dna.tts_seed_dna = tts_seed
	sync_organ_dna()


/mob/living/carbon/human/proc/change_dna(datum/dna/new_dna, include_species_change = FALSE, keep_flavor_text = FALSE)
	if(include_species_change)
		set_species(new_dna.species.type, retain_damage = TRUE, transformation = TRUE, keep_missing_bodyparts = TRUE)
	dna = new_dna.Clone()
	if(include_species_change) //We have to call this after new_dna.Clone() so that species actions don't get overwritten
		dna.species.on_species_gain(src)
	real_name = new_dna.real_name
	domutcheck(src, null, MUTCHK_FORCED) //Ensures species that get powers by the species proc handle_dna keep them
	if(!keep_flavor_text)
		flavor_text = ""
	dna.UpdateSE()
	dna.UpdateUI()
	sync_organ_dna()
	UpdateAppearance()
	sec_hud_set_ID()


/**
 * Change a mob's species.
 *
 * Arguments:
 * * new_species - The user's new species.
 * * use_default_color - If `TRUE`, use the species' default color for the new mob.
 * * delay_icon_update - If `TRUE`, UpdateAppearance() won't be called in this proc.
 * * skip_same_check - If `TRUE`, don't bail out early if we would be changing to our current species and run through everything anyway.
 * * retain_damage - If `TRUE`, damage on the mob will be re-applied post-transform. Otherwise, the mob will have its organs healed.
 * * transformation - If `TRUE`, don't apply new species traits to the mob. A false value should be used when creating a new mob instead of transforming into a new species.
 * * keep_missing_bodyparts - If `TRUE`, any bodyparts (legs, head, etc.) and racial internal organs (heart, liver, etc.) that were missing on the mob before species change will be missing post-change as well. Note that racial internal organs of new species (kidan lantern, wryn antennae, etc.) will be always created.
 * * transfer_special_internals - If `TRUE`, all special internal organs (implants, spider eggs, xeno embryos, etc.), will be present on the mob post-change. Does not affect racial internal organs (heart, liver, etc.).
 * * save_appearance - If `TRUE`, all bodyparts appearances (head hair style, body tattoos, tail type, etc.) will be transfered to new species.
 */
/mob/living/carbon/human/proc/set_species(datum/species/new_species, use_default_color, delay_icon_update = FALSE, skip_same_check = FALSE, retain_damage = FALSE, transformation = FALSE, keep_missing_bodyparts = FALSE, transfer_special_internals = TRUE, save_appearance = FALSE)
	if(!skip_same_check && dna.species.name == initial(new_species.name))
		return

	var/datum/species/oldspecies = dna.species

	if(oldspecies)
		if(oldspecies.language)
			remove_language(oldspecies.language)

		if(oldspecies.default_language)
			remove_language(oldspecies.default_language)

		if(gender == PLURAL && oldspecies.has_gender)
			change_gender(pick(MALE, FEMALE))

		oldspecies.handle_dna(src, remove = TRUE) // Remove any genes that belong to the old species

		oldspecies.on_species_loss(src)

	dna.species = new new_species()

	tail = (save_appearance && oldspecies) ? oldspecies.tail : dna.species.tail

	wing = (save_appearance && oldspecies) ? oldspecies.wing : dna.species.wing

	maxHealth = dna.species.total_health

	if(dna.species.language)
		add_language(dna.species.language)

	if(dna.species.default_language)
		add_language(dna.species.default_language)

	hunger_drain = dna.species.hunger_drain
	digestion_ratio = dna.species.digestion_ratio

	if(dna.species.base_color && use_default_color)
		//Apply colour.
		skin_colour = dna.species.base_color
	else
		skin_colour = "#000000"

	if(!(dna.species.bodyflags & HAS_SKIN_TONE))
		s_tone = 0

	var/list/thing_to_check = list(slot_wear_mask, slot_head, slot_shoes, slot_gloves, slot_l_ear, slot_r_ear, slot_glasses, slot_l_hand, slot_r_hand, slot_neck)
	var/list/kept_items = list()
	var/list/item_flags = list()
	for(var/thing in thing_to_check)
		var/obj/item/I = get_item_by_slot(thing)
		if(I)
			kept_items[I] = thing
			item_flags[I] = I.flags
			I.flags = NONE // Temporary set the flags to NONE

	if(!transformation) //Distinguish between creating a mob and switching species
		dna.species.on_species_gain(src)

	var/list/missing_bodyparts = list()  // should line up here to pop out only what's missing
	if(keep_missing_bodyparts)
		if(!oldspecies)
			stack_trace("Keep missing bodypart argument set to true, [src] has no original species to compare.")

		for(var/limb_zone in dna.species.has_limbs)
			if(!(limb_zone in oldspecies.has_limbs))	// we are good with species specific new bodyparts (tail/wings etc.)
				continue
			if(isnull(bodyparts_by_name[limb_zone]))
				missing_bodyparts += limb_zone

		for(var/organ_slot in dna.species.has_organ)
			if(!(organ_slot in oldspecies.has_organ))	// species specific new internals are also fine
				continue
			if(isnull(internal_organs_slot[organ_slot]))
				missing_bodyparts += organ_slot

	var/list/additional_organs = list()
	if(transfer_special_internals)
		if(!oldspecies)
			stack_trace("Transfer special internals argument set to true, [src] has no original species to compare.")

		var/list/racial_organs = (oldspecies.has_organ|dna.species.has_organ)	// all internal organs, except racial, will be recreated
		for(var/obj/item/organ/internal/existing_organ as anything in internal_organs)
			var/organ_found = FALSE
			for(var/organ_slot in racial_organs)
				var/obj/item/organ/internal/racial_organ = racial_organs[organ_slot]
				organ_found = (existing_organ.slot == initial(racial_organ.slot))
				if(organ_found)
					break
			if(!organ_found)
				additional_organs += existing_organ.type

	var/list/old_bodyparts
	if(save_appearance)
		old_bodyparts = bodyparts_by_name.Copy()

	if(retain_damage)
		//Create a list of body parts which are damaged by burn or brute and save them to apply after new organs are generated. First we just handle external organs.
		var/bodypart_damages = list()
		//Loop through all external organs and save the damage states for brute and burn
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			var/list/stats = list()
			stats["zone"] = bodypart.limb_zone
			stats["brute"] = bodypart.brute_dam
			stats["burn"] = bodypart.burn_dam
			stats["status"] = bodypart.status
			bodypart_damages += list(stats)

		//Now we do the same for internal organs via the same proceedure.
		var/internal_damages = list()
		for(var/obj/item/organ/internal/organ as anything in internal_organs)
			var/list/stats = list()
			stats["slot"] = organ.slot
			stats["damage"] = organ.damage
			stats["status"] = organ.status
			internal_damages += list(stats)

		//Create the new organs for the species change
		dna.species.create_organs(src, missing_bodyparts, additional_organs)

		//Apply relevant damages and variables to the new organs.
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			for(var/stats in bodypart_damages)
				if(bodypart.limb_zone == stats["zone"])
					var/brute_dmg = stats["brute"]
					var/burn_dmg = stats["burn"]
					if(brute_dmg || burn_dmg)
						bodypart.receive_damage(brute_dmg, burn_dmg, ignore_resists = TRUE, silent = TRUE)
					var/status = stats["status"]
					if(status & ORGAN_INT_BLEED)
						bodypart.internal_bleeding(silent = TRUE)
					if(status & ORGAN_BROKEN)
						bodypart.fracture(silent = TRUE)
					if(status & ORGAN_SPLINTED)
						bodypart.apply_splint()
					if(status & ORGAN_DEAD)
						bodypart.necrotize(silent = TRUE)
					if(status & ORGAN_MUTATED)
						bodypart.mutate(silent = TRUE)
					break

		for(var/obj/item/organ/internal/organ as anything in internal_organs)
			for(var/stats in internal_damages)
				if(organ.slot == stats["slot"])
					var/damage = stats["damage"]
					if(damage)
						organ.receive_damage(damage, silent = TRUE)
					if(stats["status"] & ORGAN_DEAD)
						organ.necrotize(silent = TRUE)
					break

	else
		dna.species.create_organs(src, missing_bodyparts, additional_organs)

	for(var/obj/item/thing in kept_items)
		var/equipped = equip_to_slot(thing, kept_items[thing], initial = TRUE)	// we can skip [mob_can_equip()] checks here
		thing.flags = item_flags[thing] // Reset the flags to the original ones
		if(!equipped)
			thing.dropped() // Ensures items know they are dropped. Using their original flags

	//Handle hair/head accessories for created mobs.
	var/obj/item/organ/external/head/H = get_organ(BODY_ZONE_HEAD)
	if(save_appearance && old_bodyparts)
		var/obj/item/organ/external/head/old_head = old_bodyparts[BODY_ZONE_HEAD]
		if(istype(old_head))
			if(old_head.h_style)
				H.h_style = old_head.h_style
			if(old_head.f_style)
				H.f_style = old_head.f_style
			if(old_head.ha_style)
				H.ha_style = old_head.ha_style
			if(old_head.hair_colour)
				H.hair_colour = old_head.hair_colour
			if(old_head.facial_colour)
				H.facial_colour = old_head.facial_colour
			if(old_head.headacc_colour)
				H.headacc_colour = old_head.headacc_colour

	else if(istype(H))
		if(dna.species.default_hair)
			H.h_style = dna.species.default_hair
		else
			H.h_style = "Bald"
		if(dna.species.default_fhair)
			H.f_style = dna.species.default_fhair
		else
			H.f_style = "Shaved"
		if(dna.species.default_headacc)
			H.ha_style = dna.species.default_headacc
		else
			H.ha_style = "None"

		if(dna.species.default_hair_colour)
			//Apply colour.
			H.hair_colour = dna.species.default_hair_colour
		else
			H.hair_colour = "#000000"
		if(dna.species.default_fhair_colour)
			H.facial_colour = dna.species.default_fhair_colour
		else
			H.facial_colour = "#000000"
		if(dna.species.default_headacc_colour)
			H.headacc_colour = dna.species.default_headacc_colour
		else
			H.headacc_colour = "#000000"

		m_styles = DEFAULT_MARKING_STYLES //Wipes out markings, setting them all to "None".
		m_colours = DEFAULT_MARKING_COLOURS //Defaults colour to #00000 for all markings.
		if(dna.species.bodyflags & HAS_BODY_ACCESSORY)
			body_accessory = GLOB.body_accessory_by_name[dna.species.default_bodyacc]
		else
			body_accessory = null

	dna.real_name = real_name

	update_sight()

	dna.species.handle_dna(src) //Give them whatever special dna business they got.

	update_client_colour(0)

	if(!delay_icon_update)
		UpdateAppearance()

	cut_overlays()
	update_mutantrace()
	regenerate_icons()

	if(dna.species)
		return TRUE
	else
		return FALSE


/mob/living/carbon/human/get_default_language()
	if(default_language)
		return default_language

	if(!dna.species)
		return null
	return dna.species.default_language ? GLOB.all_languages[dna.species.default_language] : null

/mob/living/carbon/human/proc/bloody_doodle()
	set category = "IC"
	set name = "Write in blood"
	set desc = "Use blood on your hands to write a short message on the floor or a wall, murder mystery style."

	if(usr != src)
		return 0 //something is terribly wrong
	if(incapacitated())
		to_chat(src, "<span class='warning'>You can't write on the floor in your current state!</span>")
		return
	if(!bloody_hands)
		verbs -= /mob/living/carbon/human/proc/bloody_doodle

	if(gloves)
		to_chat(src, "<span class='warning'>[gloves] are preventing you from writing anything down!</span>")
		return

	var/turf/simulated/T = loc
	if(!istype(T)) //to prevent doodling out of mechs and lockers
		to_chat(src, "<span class='warning'>You cannot reach the floor.</span>")
		return

	var/turf/origin = T
	var/direction = input(src,"Which way?","Tile selection") as anything in list("Here","North","South","East","West")
	if(direction != "Here")
		T = get_step(T,text2dir(direction))
	if(!istype(T))
		to_chat(src, "<span class='warning'>You cannot doodle there.</span>")
		return

	var/num_doodles = 0
	for(var/obj/effect/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if(num_doodles > 4)
		to_chat(src, "<span class='warning'>There is no space to write on!</span>")
		return

	var/max_length = bloody_hands * 30 //tweeter style

	var/message = stripped_input(src,"Write a message. It cannot be longer than [max_length] characters.","Blood writing", "")
	if(origin != loc)
		to_chat(src, "<span class='notice'>Stay still while writing!</span>")
		return
	if(message)
		var/used_blood_amount = round(length(message) / 30, 1)
		bloody_hands = max(0, bloody_hands - used_blood_amount) //use up some blood

		if(length(message) > max_length)
			message += "-"
			to_chat(src, "<span class='warning'>You ran out of blood to write with!</span>")
		else
			to_chat(src, "<span class='notice'>You daub '[message]' on [T] in shiny red lettering.</span>")
		var/obj/effect/decal/cleanable/blood/writing/W = new(T)
		W.message = message
		W.add_fingerprint(src)

/mob/living/carbon/human/proc/get_eyecon()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/cyberimp/eyes/eye_implant = get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
	if(istype(dna.species) && dna.species.eyes)
		var/icon/eyes_icon
		if(eye_implant) //Eye implants override native DNA eye colo(u)r
			eyes_icon = eye_implant.generate_icon()
		else if(eyes)
			eyes_icon = eyes.generate_icon()
		else //Error 404: Eyes not found!
			eyes_icon = new('icons/mob/human_face.dmi', dna.species.eyes)
			eyes_icon.Blend("#800000", ICON_ADD)

		return eyes_icon

/mob/living/carbon/human/proc/get_eye_shine() //Referenced cult constructs for shining in the dark. Needs to be above lighting effects such as shading.
	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(!istype(head_organ))
		return
	var/datum/sprite_accessory/hair/hair_style = GLOB.hair_styles_full_list[head_organ.h_style]
	var/icon/hair = new /icon("icon" = hair_style.icon, "icon_state" = "[hair_style.icon_state]_s")
	var/mutable_appearance/MA = mutable_appearance(get_icon_difference(get_eyecon(), hair), layer = ABOVE_LIGHTING_LAYER)
	MA.plane = ABOVE_LIGHTING_PLANE
	return MA //Cut the hair's pixels from the eyes icon so eyes covered by bangs stay hidden even while on a higher layer.

/*Used to check if eyes should shine in the dark. Returns the image of the eyes on the layer where they will appear to shine.
Eyes need to have significantly high darksight to shine unless the mob has the XRAY vision mutation. Eyes will not shine if they are covered in any way.*/
/mob/living/carbon/human/proc/eyes_shine()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	var/obj/item/organ/internal/cyberimp/eyes/eye_implant = get_int_organ(/obj/item/organ/internal/cyberimp/eyes)
	if(!get_location_accessible(src, BODY_ZONE_PRECISE_EYES))
		return FALSE
	// Natural eyeshine, any implants, and XRAY - all give shiny appearance.
	if((istype(eyes) && eyes.shine()) || istype(eye_implant) || (XRAY in mutations))
		return TRUE

	return FALSE

/mob/living/carbon/human/assess_threat(var/mob/living/simple_animal/bot/secbot/judgebot, var/lasercolor)
	if(judgebot.emagged == 2)
		return 10 //Everyone is a criminal!

	var/threatcount = 0

	//Lasertag bullshit
	if(lasercolor)
		if(lasercolor == "b")//Lasertag turrets target the opposing team, how great is that? -Sieve
			if(istype(wear_suit, /obj/item/clothing/suit/redtag))
				threatcount += 4
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/red)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/red)))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/tag/red))
				threatcount += 2

		if(lasercolor == "r")
			if(istype(wear_suit, /obj/item/clothing/suit/bluetag))
				threatcount += 4
			if((istype(r_hand,/obj/item/gun/energy/laser/tag/blue)) || (istype(l_hand,/obj/item/gun/energy/laser/tag/blue)))
				threatcount += 4
			if(istype(belt, /obj/item/gun/energy/laser/tag/blue))
				threatcount += 2

		return threatcount

	//Check for ID
	if(judgebot.idcheck && !length(get_all_id_cards()))
		threatcount += 4

	//Check for weapons
	if(judgebot.weaponscheck && !(ACCESS_WEAPONS in get_access()))
		if(judgebot.check_for_weapons(l_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(r_hand))
			threatcount += 4
		if(judgebot.check_for_weapons(belt))
			threatcount += 4
		if(judgebot.check_for_weapons(s_store))
			threatcount += 4


	//Check for arrest warrant
	if(judgebot.check_records)
		var/perpname = get_visible_name(TRUE)
		var/datum/data/record/R = find_record("name", perpname, GLOB.data_core.security)
		if(R && R.fields["criminal"])
			switch(R.fields["criminal"])
				if(SEC_RECORD_STATUS_EXECUTE)
					threatcount += 7
				if(SEC_RECORD_STATUS_ARREST)
					threatcount += 5
				if(SEC_RECORD_STATUS_INCARCERATED)
					threatcount += 2
				if(SEC_RECORD_STATUS_PAROLLED)
					threatcount += 2

	//Check for dresscode violations
	if(istype(head, /obj/item/clothing/head/wizard) || istype(head, /obj/item/clothing/head/helmet/space/hardsuit/wizard))
		threatcount += 2


	//Mindshield implants imply slight trustworthiness
	if(ismindshielded(src))
		threatcount -= 1

	//Agent cards lower threatlevel.
	if(locate(/obj/item/card/id/syndicate) in get_all_id_cards())
		threatcount -= 5

	return threatcount

/mob/living/carbon/human/singularity_act()
	. = 20
	if(mind)
		if((mind.assigned_role == "Station Engineer") || (mind.assigned_role == "Chief Engineer") )
			. = 100
		if(mind.assigned_role == "Trainee Engineer")	//Чем глупее, тем вкуснее
			. = 300
		if(mind.assigned_role == "Clown")
			. = rand(-1000, 1000)
	..() //Called afterwards because getting the mind after getting gibbed is sketchy

/mob/living/carbon/human/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_THREE)
		var/list/handlist = list(l_hand, r_hand)
		for(var/obj/item/hand in handlist)
			if(prob(current_size * 5) && hand.w_class >= ((11-current_size)/2)	&& drop_item_ground(hand))
				step_towards(hand, src)
				to_chat(src, "<span class='warning'>\The [S] pulls \the [hand] from your grip!</span>")
	apply_effect(current_size * 3, IRRADIATE)

/mob/living/carbon/human/narsie_act()
	if(iswizard(src) && iscultist(src)) //Wizard cultists are immune to narsie because it would prematurely end the wiz round that's about to end by the automated shuttle call anyway
		return
	..()

/mob/living/carbon/human/proc/do_cpr(mob/living/carbon/human/H)
	if(H == src)
		to_chat(src, "<span class='warning'>You cannot perform CPR on yourself!</span>")
		return
	if(H.stat == DEAD || HAS_TRAIT(H, TRAIT_FAKEDEATH))
		to_chat(src, "<span class='warning'>[H.name] is dead!</span>")
		return
	if(!check_has_mouth())
		to_chat(src, "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>")
		return
	if(!H.check_has_mouth())
		to_chat(src, "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>")
		return
	if((head && (head.flags_cover & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags_cover & MASKCOVERSMOUTH) && !wear_mask.up))
		to_chat(src, "<span class='warning'>Remove your mask first!</span>")
		return
	if((H.head && (H.head.flags_cover & HEADCOVERSMOUTH)) || (H.wear_mask && (H.wear_mask.flags_cover & MASKCOVERSMOUTH) && !H.wear_mask.up))
		to_chat(src, "<span class='warning'>Remove [H.p_their()] mask first!</span>")
		return
	if(H.receiving_cpr) // To prevent spam stacking
		to_chat(src, "<span class='warning'>They are already receiving CPR!</span>")
		return
	visible_message("<span class='danger'>[src] is trying to perform CPR on [H.name]!</span>", "<span class='danger'>You try to perform CPR on [H.name]!</span>")
	H.receiving_cpr = TRUE
	if(do_mob(src, H, 40))
		if(H.health <= HEALTH_THRESHOLD_CRIT)
			H.adjustOxyLoss(-15)
			H.SetLoseBreath(0)
			H.AdjustParalysis(-2 SECONDS)
			H.updatehealth("cpr")
			visible_message("<span class='danger'>[src] performs CPR on [H.name]!</span>", "<span class='notice'>You perform CPR on [H.name].</span>")

			to_chat(H, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
			H.receiving_cpr = FALSE
			add_attack_logs(src, H, "CPRed", ATKLOG_ALL)
			return TRUE
	else
		H.receiving_cpr = FALSE
		to_chat(src, "<span class='danger'>You need to stay still while performing CPR!</span>")

/mob/living/carbon/human/canBeHandcuffed()
	return get_num_arms() >= 2

/mob/living/carbon/human/has_mutated_organs()
	for(var/obj/item/organ/external/E as anything in bodyparts)
		if(E.status & ORGAN_MUTATED)
			return TRUE
	return FALSE

/mob/living/carbon/human/InCritical()
	return (health <= HEALTH_THRESHOLD_CRIT && stat == UNCONSCIOUS)


/mob/living/carbon/human/IsAdvancedToolUser()
	if(dna.species.has_fine_manipulation)
		return TRUE
	return FALSE

/mob/living/carbon/human/get_permeability_protection()
	var/list/prot = list("hands"=0, "chest"=0, "groin"=0, "legs"=0, "feet"=0, "arms"=0, "head"=0)
	for(var/obj/item/I in get_equipped_items())
		if(I.body_parts_covered & HANDS)
			prot["hands"] = max(1 - I.permeability_coefficient, prot["hands"])
		if(I.body_parts_covered & UPPER_TORSO)
			prot["chest"] = max(1 - I.permeability_coefficient, prot["chest"])
		if(I.body_parts_covered & LOWER_TORSO)
			prot["groin"] = max(1 - I.permeability_coefficient, prot["groin"])
		if(I.body_parts_covered & LEGS)
			prot["legs"] = max(1 - I.permeability_coefficient, prot["legs"])
		if(I.body_parts_covered & FEET)
			prot["feet"] = max(1 - I.permeability_coefficient, prot["feet"])
		if(I.body_parts_covered & ARMS)
			prot["arms"] = max(1 - I.permeability_coefficient, prot["arms"])
		if(I.body_parts_covered & HEAD)
			prot["head"] = max(1 - I.permeability_coefficient, prot["head"])
	var/protection = (prot["head"] + prot["arms"] + prot["feet"] + prot["legs"] + prot["groin"] + prot["chest"] + prot["hands"])/7
	return protection

/mob/living/carbon/human/proc/get_full_print()
	if(!dna || !dna.uni_identity)
		return
	return md5(dna.uni_identity)

/mob/living/carbon/human/can_see_reagents()
	var/slots_to_see = src.get_all_slots() - l_store - r_store
	for(var/obj/item/clothing/C in slots_to_see) //If they have some clothing equipped that lets them see reagents, they can see reagents
		if(C.scan_reagents)
			return TRUE

/mob/living/carbon/human/can_see_food()
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(organ.can_see_food)
			return TRUE

/mob/living/carbon/human/selfFeed(var/obj/item/reagent_containers/food/toEat, fullness)
	if(!check_has_mouth())
		to_chat(src, "Where do you intend to put \the [toEat]? You don't have a mouth!")
		return FALSE
	return ..()

/mob/living/carbon/human/forceFed(var/obj/item/reagent_containers/food/toEat, mob/user, fullness)
	if(!check_has_mouth())
		if(!((istype(toEat, /obj/item/reagent_containers/food/drinks) && (ismachineperson(src)))))
			to_chat(user, "Where do you intend to put \the [toEat]? \The [src] doesn't have a mouth!")
			return FALSE
	return ..()

/mob/living/carbon/human/selfDrink(var/obj/item/reagent_containers/food/drinks/toDrink)
	if(!check_has_mouth())
		if(!ismachineperson(src))
			to_chat(src, "Where do you intend to put \the [src]? You don't have a mouth!")
			return FALSE
		else
			to_chat(src, "<span class='notice'>You pour a bit of liquid from [toDrink] into your connection port.</span>")
	else
		to_chat(src, "<span class='notice'>You swallow a gulp of [toDrink].</span>")
	return TRUE

/mob/living/carbon/human/can_track(mob/living/user)
	if(wear_id)
		var/obj/item/card/id/id = wear_id
		if(istype(id) && id.is_untrackable())
			return FALSE
	if(wear_pda)
		var/obj/item/pda/pda = wear_pda
		if(istype(pda))
			var/obj/item/card/id/id = pda.id
			if(istype(id) && id.is_untrackable())
				return FALSE
	if(istype(head, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = head
		if(hat.blockTracking)
			return FALSE

	return ..()

/mob/living/carbon/human/proc/get_age_pitch(var/tolerance = 5)
	return 1.0 + 0.5*(30 - age)/80 + (0.01*rand(-tolerance,tolerance))

/mob/living/carbon/human/get_access_locations()
	. = ..()
	. |= list(wear_id, wear_pda, w_uniform)

/mob/living/carbon/human/is_mechanical()
	return ..() || (dna.species.bodyflags & ALL_RPARTS) != 0


/mob/living/carbon/human/can_use_guns(obj/item/gun/check_gun)
	. = ..()

	if(check_gun.trigger_guard == TRIGGER_GUARD_NORMAL)
		if((NOGUNS in dna.species.species_traits) || HAS_TRAIT(src, TRAIT_CHUNKYFINGERS))
			to_chat(src, span_warning("Your fingers don't fit in the trigger guard!"))
			return FALSE

	if(mind && mind.martial_art && mind.martial_art.no_guns) //great dishonor to famiry
		to_chat(src, span_warning("[mind.martial_art.no_guns_message]"))
		return FALSE

	// ninjas will not use default ranged weapons
	var/datum/antagonist/ninja/ninja = mind?.has_antag_datum(/datum/antagonist/ninja)
	if(ninja && !ninja.allow_guns && !check_gun.ninja_weapon)
		to_chat(src, span_warning("[ninja.no_guns_message]"))
		return FALSE


/mob/living/carbon/human/proc/change_icobase(var/new_icobase, var/new_deform, var/owner_sensitive)
	for(var/obj/item/organ/external/O as anything in bodyparts)
		O.change_organ_icobase(new_icobase, new_deform, owner_sensitive) //Change the icobase/deform of all our organs. If owner_sensitive is set, that means the proc won't mess with frankenstein limbs.

/mob/living/carbon/human/serialize()
	// Currently: Limbs/organs only
	var/list/data = ..()
	var/list/limbs_list = list()
	var/list/organs_list = list()
	var/list/equip_list = list()
	data["limbs"] = limbs_list
	data["iorgans"] = organs_list
	data["equip"] = equip_list

	data["dna"] = dna.serialize()
	data["age"] = age

	// No being naked
	data["ushirt"] = undershirt
	data["socks"] = socks
	data["uwear"] = underwear

	// Limbs
	for(var/index in bodyparts_by_name)
		var/obj/item/organ/external/bodypart = bodyparts_by_name[index]
		if(!bodypart)
			limbs_list[index] = "missing"
			continue

		limbs_list[index] = bodypart.serialize()

	// Internal organs/augments
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organs_list[organ.name] = organ.serialize()

	// Equipment
	equip_list.len = slots_amt
	for(var/i = 1, i < slots_amt, i++)
		var/obj/item/thing = get_item_by_slot(i)
		if(thing != null)
			equip_list[i] = thing.serialize()

	return data

/mob/living/carbon/human/deserialize(list/data)
	var/list/limbs_list = data["limbs"]
	var/list/organs_list = data["iorgans"]
	var/list/equip_list = data["equip"]
	var/turf/T = get_turf(src)
	if(!islist(data["limbs"]))
		throw EXCEPTION("Expected a limbs list, but found none")

	if(islist(data["dna"]))
		dna.deserialize(data["dna"])
		real_name = dna.real_name
		name = real_name
		set_species(dna.species.type, skip_same_check = TRUE)
	age = data["age"]
	undershirt = data["ushirt"]
	underwear = data["uwear"]
	socks = data["socks"]
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		qdel(organ)

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		qdel(bodypart)

	for(var/limb in limbs_list)
		// Missing means skip this part - it's missing
		if(limbs_list[limb] == "missing")
			continue
		// "New" code handles insertion and DNA sync'ing
		var/obj/item/organ/external/bodypart = list_to_object(limbs_list[limb], src)
		bodypart.sync_colour_to_dna()

	for(var/organ in organs_list)
		// As above, "New" code handles insertion, DNA sync
		list_to_object(organs_list[organ], src)

	UpdateAppearance()

	// De-serialize equipment
	// #1: Jumpsuit
	// #2: Outer suit
	// #3+: Everything else
	if(islist(equip_list[slot_w_uniform]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_w_uniform], T)
		equip_to_slot_if_possible(C, slot_w_uniform)

	if(islist(equip_list[slot_wear_suit]))
		var/obj/item/clothing/C = list_to_object(equip_list[slot_wear_suit], T)
		equip_to_slot_if_possible(C, slot_wear_suit)

	for(var/i = 1, i < slots_amt, i++)
		if(i == slot_w_uniform || i == slot_wear_suit)
			continue
		if(islist(equip_list[i]))
			var/obj/item/clothing/C = list_to_object(equip_list[i], T)
			equip_to_slot_if_possible(C, i)
	update_icons()

	..()


/mob/living/carbon/human/vv_get_dropdown()
	. = ..()
	. += "---"
	.["Set Species"] = "?_src_=vars;setspecies=[UID()]"
	.["Copy Outfit"] = "?_src_=vars;copyoutfit=[UID()]"
	.["Make AI"] = "?_src_=vars;makeai=[UID()]"
	.["Make cyborg"] = "?_src_=vars;makerobot=[UID()]"
	.["Make monkey"] = "?_src_=vars;makemonkey=[UID()]"
	.["Make alien"] = "?_src_=vars;makealien=[UID()]"
	.["Make slime"] = "?_src_=vars;makeslime=[UID()]"
	.["Make superhero"] = "?_src_=vars;makesuper=[UID()]"
	. += "---"

/mob/living/carbon/human/adjust_nutrition(change)
	if(NO_HUNGER in dna.species.species_traits)
		return FALSE
	return ..()

/mob/living/carbon/human/set_nutrition(change)
	if(NO_HUNGER in dna.species.species_traits)
		return FALSE
	return ..()

/mob/living/carbon/human/proc/special_post_clone_handling()
	if(mind && mind.assigned_role == "Cluwne") //HUNKE your suffering never stops
		makeCluwne()
	if(mind && ("high_rp" in mind.curses)) // Probably need to make a new proc to handle curses in case if there will be new ones
		curse_high_rp()

/mob/living/carbon/human/proc/influenceSin()
	var/datum/objective/sintouched/O
	switch(rand(1,7))//traditional seven deadly sins... except lust.
		if(1) // acedia
			add_game_logs("[src] was influenced by the sin of Acedia.", src)
			O = new /datum/objective/sintouched/acedia
		if(2) // Gluttony
			add_game_logs("[src] was influenced by the sin of gluttony.", src)
			O = new /datum/objective/sintouched/gluttony
		if(3) // Greed
			add_game_logs("[src] was influenced by the sin of greed.", src)
			O = new /datum/objective/sintouched/greed
		if(4) // sloth
			add_game_logs("[src] was influenced by the sin of sloth.", src)
			O = new /datum/objective/sintouched/sloth
		if(5) // Wrath
			add_game_logs("[src] was influenced by the sin of wrath.", src)
			O = new /datum/objective/sintouched/wrath
		if(6) // Envy
			add_game_logs("[src] was influenced by the sin of envy.", src)
			O = new /datum/objective/sintouched/envy
		if(7) // Pride
			add_game_logs("[src] was influenced by the sin of pride.", src)
			O = new /datum/objective/sintouched/pride
	SSticker.mode.sintouched += src.mind
	src.mind.objectives += O
	var/obj_count = 1
	to_chat(src, "<span class='notice'> Your current objectives:")
	for(var/datum/objective/objective in src.mind.objectives)
		to_chat(src, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
		obj_count++

/mob/living/carbon/human/is_literate()
	return getBrainLoss() < 100


/mob/living/carbon/human/fakefire()
	if(!overlays_standing[FIRE_LAYER])
		overlays_standing[FIRE_LAYER] = image(FIRE_DMI, icon_state = "Generic_mob_burning")
		update_icons()

/mob/living/carbon/human/fakefireextinguish()
	overlays_standing[FIRE_LAYER] = null
	update_icons()
/mob/living/carbon/human/proc/cleanSE()	//remove all disabilities/powers
	for(var/block = 1; block <= DNA_SE_LENGTH; block++)
		dna.SetSEState(block, FALSE, TRUE)
		genemutcheck(src, block, null, MUTCHK_FORCED)
	dna.UpdateSE()

/mob/living/carbon/human/get_spooked()
	to_chat(src, "<span class='whisper'>[pick(GLOB.boo_phrases)]</span>")
	return TRUE

/mob/living/carbon/human/extinguish_light(force = FALSE)
	// Parent function handles stuff the human may be holding
	..()

	var/obj/item/organ/internal/lantern/O = get_int_organ(/obj/item/organ/internal/lantern)
	if(O && O.glowing)
		O.toggle_biolum(TRUE)
		visible_message(span_danger("[src] is engulfed in shadows and fades into the darkness."), \
						span_danger("A sense of dread washes over you as you suddenly dim dark."))

/mob/living/carbon/human/proc/get_perceived_trauma(shock_reduction)
	return min(health, maxHealth) + shock_reduction

/mob/living/carbon/human/WakeUp(updating = TRUE)
	if(dna.species.spec_WakeUp(src))
		return
	..()

/**
  * Helper to get the mobs runechat colour span
  *
  * Basically just a quick redirect to the DNA handler that gets the species-specific colour handler
  */
/mob/living/carbon/human/get_runechat_color()
   return dna.species.get_species_runechat_color(src)

/mob/living/carbon/human/limb_attack_self()
	var/obj/item/organ/external/arm = hand ? get_organ(BODY_ZONE_L_ARM) : get_organ(BODY_ZONE_R_ARM)
	if(arm)
		arm.attack_self(src)
	return ..()


/mob/living/carbon/human/can_ventcrawl(atom/clicked_on, override = FALSE)

	if(!override && w_uniform && istype(w_uniform, /obj/item/clothing/under/contortionist))

		var/obj/item/clothing/under/contortionist/uniform = w_uniform
		if(!uniform.check_clothing(src))
			return FALSE

		return ..(clicked_on, override = TRUE)

	return ..()

/mob/living/carbon/human/verb/pose()
	set name = "Set Pose"
	set desc = "Устанавливает короткое описание отображаемое при омотре вас."
	set category = "IC"

	pose = sanitize(copytext_char(input(usr, "Это [src]. [p_they(TRUE)] [p_are()]...", "Pose", null)  as text, 1, MAX_MESSAGE_LEN))

/mob/living/carbon/human/verb/set_flavor()
	set name = "Set Flavour Text"
	set desc = "Устанавливает подробное описание внешности вашего персонажа."
	set category = "IC"

	update_flavor_text()

/mob/living/carbon/human/harvest(mob/living/user)
	if(QDELETED(src))
		return

	if(issmall(src))
		while(meatleft > 0)
			new dna.species.meat_type(loc)
			meatleft--
		visible_message(span_notice("[user] butchers [src]."))
		gib()
