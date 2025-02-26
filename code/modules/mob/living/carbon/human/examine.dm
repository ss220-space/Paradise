/mob/living/carbon/human/examine(mob/user)
	var/skipgloves = 0
	var/skipsuitstorage = 0
	var/skipjumpsuit = 0
	var/skipshoes = 0
	var/skipmask = 0
	var/skipears = 0
	var/skipeyes = 0
	var/skipface = 0
	var/skipprostheses = 0

	//exosuits and helmets obscure our view and stuff.
	if(wear_suit)
		skipgloves = wear_suit.flags_inv & HIDEGLOVES
		skipsuitstorage = wear_suit.flags_inv & HIDESUITSTORAGE
		skipjumpsuit = wear_suit.flags_inv & HIDEJUMPSUIT
		skipshoes = wear_suit.flags_inv & HIDESHOES
		skipprostheses = wear_suit.flags_inv & (HIDEGLOVES|HIDEJUMPSUIT|HIDESHOES)

	if(head)
		skipmask = head.flags_inv & HIDEMASK
		skipeyes = head.flags_inv & HIDEGLASSES
		skipears = head.flags_inv & HIDEHEADSETS
		skipface = head.flags_inv & HIDENAME

	if(wear_mask)
		skipface |= wear_mask.flags_inv & HIDENAME
		skipeyes |= wear_mask.flags_inv & HIDEGLASSES
		skipears |= wear_mask.flags_inv & HIDEHEADSETS

	var/msg = "Это "

	if(!(skipjumpsuit && skipface) && icon) //big suits/masks/helmets make it hard to tell their gender
		msg += "[bicon(icon(icon, dir=SOUTH))] " //fucking BYOND: this should stop dreamseeker crashing if we -somehow- examine somebody before their icon is generated
	msg += "<EM>[name]</EM>"

	var/displayed_species = get_visible_species()
	var/examine_color = dna.species.flesh_color
	if(skipjumpsuit && (skipface || HAS_TRAIT(src, TRAIT_NO_SPECIES_EXAMINE))) //either obscured or on the nospecies list
		msg += "!\n"    //omit the species when examining
	else if(displayed_species == SPECIES_SLIMEPERSON) //snowflakey because Slime People are defined as a plural
		msg += ",<b><font color='[examine_color]'> слаймолюд</font></b>!\n"
	else if(displayed_species == SPECIES_UNATHI) //DAMN YOU, VOWELS
		msg += ",<b><font color='[examine_color]'> унатх</font></b>!\n"
	else
		msg += ",<b><font color='[examine_color]'> [lowertext(displayed_species)]</font></b>!\n"

	//uniform
	if(w_uniform && !skipjumpsuit && !(w_uniform.item_flags & ABSTRACT))
		//Ties
		var/tie_msg
		if(istype(w_uniform, /obj/item/clothing/under) && LAZYLEN(w_uniform.accessories))
			tie_msg += " c [accessory_list(w_uniform)]"

		if(w_uniform.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(w_uniform)] [w_uniform.declent_ru(ACCUSATIVE)] [w_uniform.blood_color != "#030303" ? "со следами крови":"со следами масла"][tie_msg]!\n")
		else
			msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(w_uniform)] [w_uniform.declent_ru(ACCUSATIVE)].\n"

	//head
	if(head && !(head.item_flags & ABSTRACT))
		if(head.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(head)] [head.declent_ru(ACCUSATIVE)] [head.blood_color != "#030303" ? "со следами крови":"со следами масла"] на голове!\n")
		else
			msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(head)] [head.declent_ru(ACCUSATIVE)] на голове.\n"

	//neck
	if(neck && !(neck.item_flags & ABSTRACT))
		if(neck.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(neck)] [neck.declent_ru(ACCUSATIVE)] [neck.blood_color != "#030303" ? "со следами крови":"со следами масла"] на шее!\n")
		else
			msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(neck)] [neck.declent_ru(ACCUSATIVE)] на шее.\n"

	//suit/armour
	if(wear_suit && !(wear_suit.item_flags & ABSTRACT))
		if(wear_suit.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(wear_suit)] [wear_suit.declent_ru(ACCUSATIVE)] [wear_suit.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(wear_suit)] [wear_suit.declent_ru(ACCUSATIVE)].\n"

		//suit/armour storage
		if(s_store && !skipsuitstorage)
			if(s_store.blood_DNA)
				msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] [bicon(wear_suit)] [wear_suit.declent_ru(PREPOSITIONAL)] вис[pluralize_ru(s_store.gender, "ит", "ят")] [s_store.declent_ru(NOMINATIVE)] [s_store.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "На [genderize_ru(gender, "его", "её", "его", "их")] [bicon(wear_suit)] [wear_suit.declent_ru(PREPOSITIONAL)] вис[pluralize_ru(s_store.gender, "ит", "ят")] [s_store.declent_ru(NOMINATIVE)].\n"

	//back
	if(back && !(back.item_flags & ABSTRACT))
		if(back.blood_DNA)
			msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] спине вис[pluralize_ru(back.gender, "ит", "ят")] [bicon(back)] [back.declent_ru(NOMINATIVE)] [back.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "На [genderize_ru(gender, "его", "её", "его", "их")] спине вис[pluralize_ru(back.gender, "ит", "ят")] [bicon(back)] [back.declent_ru(NOMINATIVE)].\n"

	//left hand
	if(l_hand && !(l_hand.item_flags & ABSTRACT))
		if(l_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] [l_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в левой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(l_hand)] [l_hand.declent_ru(ACCUSATIVE)] в левой руке.\n"

	//right hand
	if(r_hand && !(r_hand.item_flags & ABSTRACT))
		if(r_hand.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] [r_hand.blood_color != "#030303" ? "со следами крови":"со следами масла"] в правой руке!\n")
		else
			msg += "[genderize_ru(gender, "Он держит", "Она держит", "Оно держит", "Они держат")] [bicon(r_hand)] [r_hand.declent_ru(ACCUSATIVE)] в правой руке.\n"

	//gloves
	if(!skipgloves)
		if(gloves && !(gloves.item_flags & ABSTRACT))
			if(gloves.blood_DNA)
				msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] руках [bicon(gloves)] [gloves.declent_ru(NOMINATIVE)] [gloves.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "На [genderize_ru(gender, "его", "её", "его", "их")] руках [bicon(gloves)] [gloves.declent_ru(NOMINATIVE)].\n"
		else if(blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] руки [hand_blood_color != "#030303" ? "измазаны в крови":"измазаны в масле"]!\n")
		else if(isclocker(src) && HAS_TRAIT(src, CLOCK_HANDS))
			msg += span_clockitalic("[genderize_ru(gender, "Его", "Её", "Его", "Их")] руки сверкают янтарём!\n")

	//handcuffed?
	if(handcuffed)
		if(istype(handcuffed, /obj/item/restraints/handcuffs/cable/zipties))
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] стяжками!\n")
		else if(istype(handcuffed, /obj/item/restraints/handcuffs/cable))
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] самодельными стяжками!\n")
		else
			msg += span_warning("[genderize_ru(gender, "Он", "Она", "Оно", "Они")] [bicon(handcuffed)] скован[genderize_ru(gender, "", "а", "о", "ы")] наручниками!\n")

	//belt
	if(belt)
		if(belt.blood_DNA)
			msg += span_warning("На [genderize_ru(gender, "его", "её", "его", "их")] талии вис[pluralize_ru(belt.gender, "ит", "ят")] [bicon(belt)] [belt.declent_ru(NOMINATIVE)] [belt.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
		else
			msg += "На [genderize_ru(gender, "его", "её", "его", "их")] талии вис[pluralize_ru(belt.gender, "ит", "ят")] [bicon(belt)] [belt.declent_ru(NOMINATIVE)].\n"

	//shoes
	if(!skipshoes)
		if(shoes && !(shoes.item_flags & ABSTRACT))
			if(shoes.blood_DNA)
				msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(shoes)] [shoes.declent_ru(ACCUSATIVE)] [shoes.blood_color != "#030303" ? "со следами крови":"со следами масла"] на ногах!\n")
			else
				msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(shoes)] [shoes.declent_ru(ACCUSATIVE)] на ногах.\n"
		else if(blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] ступни [hand_blood_color != "#030303" ? "измазаны в крови":"измазаны в масле"]!\n")

	//legcuffed?
	if(legcuffed)
		msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] ноги [bicon(legcuffed)] скованы [legcuffed.declent_ru(INSTRUMENTAL)]!\n")

	//mask
	if(wear_mask && !skipmask && !(wear_mask.item_flags & ABSTRACT))
		if(wear_mask.blood_DNA)
			msg += span_warning("[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(wear_mask)] [wear_mask.declent_ru(ACCUSATIVE)] [wear_mask.blood_color != "#030303" ? "со следами крови":"со следами масла"] на лице!\n")
		else
			msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(wear_mask)] [wear_mask.declent_ru(ACCUSATIVE)] на лице.\n"

	//eyes
	if(!skipeyes)
		if(glasses && !(glasses.item_flags & ABSTRACT))
			if(glasses.blood_DNA)
				msg += span_warning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза закрыты [bicon(glasses)] [glasses.declent_ru(INSTRUMENTAL)] [glasses.blood_color != "#030303" ? "со следами крови":"со следами масла"]!\n")
			else
				msg += "[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза закрыты [bicon(glasses)] [glasses.declent_ru(INSTRUMENTAL)].\n"
		else if(iscultist(src) && HAS_TRAIT(src, CULT_EYES) && get_int_organ(/obj/item/organ/internal/eyes))
			msg += span_boldwarning("[genderize_ru(gender, "Его", "Её", "Его", "Их")] глаза неестественно горят кроваво-красным!\n")

	//left ear
	if(l_ear && !skipears)
		msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(l_ear)] [l_ear.declent_ru(ACCUSATIVE)] на левом ухе.\n"

	//right ear
	if(r_ear && !skipears)
		msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(r_ear)] [r_ear.declent_ru(ACCUSATIVE)] на правом ухе.\n"

	//ID
	if(wear_id)
		msg += "[genderize_ru(gender, "Он носит", "Она носит", "Оно носит", "Они носят")] [bicon(wear_id)] [wear_id.declent_ru(ACCUSATIVE)].\n"

	//Status effects
	var/status_examines = get_status_effect_examinations()
	if(status_examines)
		msg += status_examines

	var/appears_dead = FALSE
	if(stat == DEAD || HAS_TRAIT(src, TRAIT_FAKEDEATH))
		appears_dead = TRUE
		if(suiciding)
			msg += "<span class='warning'>[p_they(TRUE)] appear[p_s()] to have committed suicide... there is no hope of recovery.</span>\n"
		msg += "<span class='deadsay'>[p_they(TRUE)] [p_are()] limp and unresponsive; there are no signs of life"
		if(get_int_organ(/obj/item/organ/internal/brain))
			if(!key)
				var/foundghost = FALSE
				if(mind)
					for(var/mob/dead/observer/G in GLOB.player_list)
						if(G.mind == mind)
							foundghost = TRUE
							if(G.can_reenter_corpse == 0)
								foundghost = FALSE
							break
				if(!foundghost)
					msg += " and [p_their()] soul has departed"
		msg += "...</span>\n"

	if(!get_int_organ(/obj/item/organ/internal/brain))
		msg += "<span class='deadsay'>It appears that [p_their()] brain is missing...</span>\n"

	msg += "<span class='warning'>"

	var/list/wound_flavor_text = list()
	for(var/limb_zone in dna.species.has_limbs)

		var/list/organ_data = dna.species.has_limbs[limb_zone]
		var/organ_descriptor = organ_data["descriptor"]

		var/obj/item/organ/external/bodypart = bodyparts_by_name[limb_zone]
		if(!bodypart)
			wound_flavor_text[limb_zone] = "<B>[p_they(TRUE)] [p_are()] missing [p_their()] [organ_descriptor].</B>\n"
		else
			if(!ismachineperson(src) && !skipprostheses)
				if(bodypart.is_robotic())
					wound_flavor_text[limb_zone] = "[p_they(TRUE)] [p_have()] a robotic [bodypart.name]!\n"

				else if(bodypart.is_splinted())
					wound_flavor_text[limb_zone] = "[p_they(TRUE)] [p_have()] a splint on [p_their()] [bodypart.name]!\n"

				else if(!bodypart.properly_attached)
					wound_flavor_text[limb_zone] = "[p_their(TRUE)] [bodypart.name] is barely attached!\n"

			if(bodypart.open)
				if(bodypart.is_robotic())
					msg += "<b>The maintenance hatch on [p_their()] [ignore_limb_branding(limb_zone)] is open!</b>\n"
				else
					msg += "<b>[p_their(TRUE)] [ignore_limb_branding(limb_zone)] has an open incision!</b>\n"

			for(var/obj/item/embed in bodypart.embedded_objects)
				msg += "<B>[p_they(TRUE)] [p_have()] \a [bicon(embed)] [embed] embedded in [p_their()] [bodypart.name]!</B>\n"

	//Handles the text strings being added to the actual description.
	//If they have something that covers the limb, and it is not missing, put flavortext.  If it is covered but bleeding, add other flavortext.
	if(wound_flavor_text[BODY_ZONE_HEAD] && !skipmask && !(wear_mask && istype(wear_mask, /obj/item/clothing/mask/gas)))
		msg += wound_flavor_text[BODY_ZONE_HEAD]
	if(wound_flavor_text[BODY_ZONE_CHEST] && !w_uniform && !skipjumpsuit) //No need.  A missing chest gibs you.
		msg += wound_flavor_text[BODY_ZONE_CHEST]
	if(wound_flavor_text[BODY_ZONE_L_ARM] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_L_ARM]
	if(wound_flavor_text[BODY_ZONE_PRECISE_L_HAND] && !gloves && !skipgloves)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_L_HAND]
	if(wound_flavor_text[BODY_ZONE_R_ARM] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_R_ARM]
	if(wound_flavor_text[BODY_ZONE_PRECISE_R_HAND] && !gloves && !skipgloves)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_R_HAND]
	if(wound_flavor_text[BODY_ZONE_PRECISE_GROIN] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_GROIN]
	if(wound_flavor_text[BODY_ZONE_L_LEG] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_L_LEG]
	if(wound_flavor_text[BODY_ZONE_PRECISE_L_FOOT] && !shoes && !skipshoes)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_L_FOOT]
	if(wound_flavor_text[BODY_ZONE_R_LEG] && !w_uniform && !skipjumpsuit)
		msg += wound_flavor_text[BODY_ZONE_R_LEG]
	if(wound_flavor_text[BODY_ZONE_PRECISE_R_FOOT] && !shoes  && !skipshoes)
		msg += wound_flavor_text[BODY_ZONE_PRECISE_R_FOOT]

	var/damage = getBruteLoss() //no need to calculate each of these twice

	if(damage)
		var/brute_message = !ismachineperson(src) ? "bruising" : "denting"
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] [brute_message].\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe [brute_message]!</B>\n"

	damage = getFireLoss()
	if(damage)
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] burns.\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe burns!</B>\n"

	damage = getCloneLoss()
	if(damage)
		if(damage < 60)
			msg += "[p_they(TRUE)] [p_have()] [damage < 30 ? "minor" : "moderate"] cellular damage.\n"
		else
			msg += "<B>[p_they(TRUE)] [p_have()] severe cellular damage.</B>\n"


	if(fire_stacks > 0)
		msg += "[p_they(TRUE)] [p_are()] covered in something flammable.\n"
	if(fire_stacks < 0)
		msg += "[p_they(TRUE)] looks a little soaked.\n"

	switch(wetlevel)
		if(1)
			msg += "[p_they(TRUE)] looks a bit damp.\n"
		if(2)
			msg += "[p_they(TRUE)] looks a little bit wet.\n"
		if(3)
			msg += "[p_they(TRUE)] looks wet.\n"
		if(4)
			msg += "[p_they(TRUE)] looks very wet.\n"
		if(5)
			msg += "[p_they(TRUE)] looks absolutely soaked.\n"

	if(nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
		msg += "[p_they(TRUE)] [p_are()] severely malnourished.\n"

	if(HAS_TRAIT(src, TRAIT_FAT))
		msg += "[p_they(TRUE)] [p_are()] morbidly obese.\n"
		if(user.nutrition < NUTRITION_LEVEL_HYPOGLYCEMIA)
			msg += "[p_they(TRUE)] [p_are()] plump and delicious looking - Like a fat little piggy. A tasty piggy.\n"

	else if(nutrition >= NUTRITION_LEVEL_FAT)
		msg += "[p_they(TRUE)] [p_are()] quite chubby.\n"

	if(dna.species.can_be_pale && blood_volume < BLOOD_VOLUME_PALE && ((get_covered_bodyparts() & FULL_BODY) != FULL_BODY))
		msg += "[p_they(TRUE)] [p_have()] pale skin.\n"

	var/datum/antagonist/vampire/vampire_datum = mind?.has_antag_datum(/datum/antagonist/vampire)
	if(istype(vampire_datum) && vampire_datum.draining)
		msg += "<B>[p_they(TRUE)] bit into [vampire_datum.draining]'s neck with his fangs.\n</B>"

	if(bleedsuppress)
		msg += "[p_they(TRUE)] [p_are()] bandaged with something.\n"
	else if(bleed_rate)
		msg += "<B>[p_they(TRUE)] [p_are()] bleeding!</B>\n"

	if(reagents.has_reagent("teslium"))
		msg += "[p_they(TRUE)] [p_are()] emitting a gentle blue glow!\n"

	msg += "</span>"

	if(!appears_dead)
		if(stat == UNCONSCIOUS)
			msg += "[p_they(TRUE)] [p_are()]n't responding to anything around [p_them()] and seems to be asleep.\n"
		if(stat == CONSCIOUS)
			if(getBrainLoss() >= 60)
				msg += "[p_they(TRUE)] [p_have()] a stupid expression on [p_their()] face.\n"
			if(health < HEALTH_THRESHOLD_CRIT && health > HEALTH_THRESHOLD_DEAD)
				msg += span_warning("[p_they(TRUE)] [p_are()] barely conscious.\n")


		if(get_int_organ(/obj/item/organ/internal/brain))
			if(dna.species.show_ssd)
				if(!key)
					msg += "<span class='deadsay'>[p_they(TRUE)] [p_are()] totally catatonic. The stresses of life in deep-space must have been too much for [p_them()]. Any recovery is unlikely.</span>\n"
				else if(!client)
					msg += "[p_they(TRUE)] [p_have()] suddenly fallen asleep, suffering from Space Sleep Disorder. [p_they(TRUE)] may wake up soon.\n"

		if(HAS_TRAIT_FROM(src, TRAIT_AI_UNTRACKABLE, CHANGELING_TRAIT))
			msg += "[p_they(TRUE)] [p_are()] moving [p_their()] body in an unnatural and blatantly inhuman manner.\n"

	if(!(skipface || ( wear_mask && ( wear_mask.flags_inv & HIDENAME || wear_mask.flags_cover & MASKCOVERSMOUTH) ) ) && is_thrall(src) && in_range(user,src))
		msg += "Their features seem unnaturally tight and drawn.\n"

	var/obj/item/organ/internal/cyberimp/tail/blade/implant = get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	if(istype(implant) && implant.activated)
		msg += "Вы замечаете странный [implant.biological ? "нарост" : "блеск"] на [genderize_ru(gender, "его", "её", "его", "их")] хвосте.\n"

	if(decaylevel == 1)
		msg += "[p_they(TRUE)] [p_are()] starting to smell.\n"
	if(decaylevel == 2)
		msg += "[p_they(TRUE)] [p_are()] bloated and smells disgusting.\n"
	if(decaylevel == 3)
		msg += "[p_they(TRUE)] [p_are()] rotting and blackened, the skin sloughing off. The smell is indescribably foul.\n"
	if(decaylevel == 4)
		msg += "[p_they(TRUE)] [p_are()] mostly desiccated now, with only bones remaining of what used to be a person.\n"

	if(hasHUD(user, EXAMINE_HUD_SECURITY_READ))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/criminal = "None"
		var/commentLatest = "ERROR: Unable to locate a data core entry for this person." //If there is no datacore present, give this

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					for(var/datum/data/record/R in GLOB.data_core.security)
						if(R.fields["id"] == E.fields["id"])
							criminal = R.fields["criminal"]
							if(LAZYLEN(R.fields["comments"])) //if the commentlist is present
								var/list/comments = R.fields["comments"]
								commentLatest = LAZYACCESS(comments, comments.len) //get the latest entry from the comment log
							else
								commentLatest = "No entries." //If present but without entries (=target is recognized crew)

			var/criminal_status = hasHUD(user, EXAMINE_HUD_SECURITY_WRITE) ? "<a href='byond://?src=[UID()];criminal=1'>\[[criminal]\]</a>" : "\[[criminal]\]"
			msg += "<span class = 'deptradio'>Criminal status:</span> [criminal_status]\n"
			msg += "<span class = 'deptradio'>Security records:</span> <a href='byond://?src=[UID()];secrecordComment=`'>\[View comment log\]</a> <a href='byond://?src=[UID()];secrecordadd=`'>\[Add comment\]</a>\n"
			msg += "<span class = 'deptradio'>Latest entry:</span> [commentLatest]\n"

	if(hasHUD(user, EXAMINE_HUD_SKILLS))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/skills

		if(perpname)
			for(var/datum/data/record/E in GLOB.data_core.general)
				if(E.fields["name"] == perpname)
					skills = E.fields["notes"]
			if(skills)
				var/char_limit = 40
				if(length(skills) <= char_limit)
					msg += "<span class='deptradio'>Employment records:</span> [skills]\n"
				else
					msg += "<span class='deptradio'>Employment records: [copytext_preserve_html(skills, 1, char_limit-3)]...</span><a href='byond://?src=[UID()];employment_more=1'>More...</a>\n"


	if(hasHUD(user,EXAMINE_HUD_MEDICAL))
		var/perpname = get_visible_name(add_id_name = FALSE)
		var/medical = "None"

		for(var/datum/data/record/E in GLOB.data_core.general)
			if(E.fields["name"] == perpname)
				for(var/datum/data/record/R in GLOB.data_core.general)
					if(R.fields["id"] == E.fields["id"])
						medical = R.fields["p_stat"]

		msg += "<span class = 'deptradio'>Physical status:</span> <a href='byond://?src=[UID()];medical=1'>\[[medical]\]</a>\n"
		msg += "<span class = 'deptradio'>Medical records:</span> <a href='byond://?src=[UID()];medrecord=`'>\[View\]</a> <a href='byond://?src=[UID()];medrecordadd=`'>\[Add comment\]</a>\n"

	var/obj/item/organ/external/head/head_organ = get_organ(BODY_ZONE_HEAD)
	if(print_flavor_text() && !skipface && !head_organ?.is_disfigured())
		msg += "[print_flavor_text()]\n"

	if(pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\n[p_they(TRUE)] [p_are()] [pose]"

	. = list(msg)
	SEND_SIGNAL(src, COMSIG_PARENT_EXAMINE, user, .)


/mob/living/carbon/human/get_examine_time()
	return 1 SECONDS


/**
 * Shows any and all examine text related to any status effects the user has.
 */
/mob/living/proc/get_status_effect_examinations()
	var/list/examine_list = list()

	for(var/datum/status_effect/effect as anything in status_effects)
		var/effect_text = effect.get_examine_text()
		if(!effect_text)
			continue

		examine_list += effect_text

	if(!length(examine_list))
		return

	return examine_list.Join("\n") + "\n"


//Helper procedure. Called by /mob/living/carbon/human/examine() and /mob/living/carbon/human/Topic() to determine HUD access to security and medical records.
/proc/hasHUD(mob/M, hud_exam)
	if(ishuman(M))
		var/have_hud_exam = 0
		var/mob/living/carbon/human/H = M

		if(istype(H.glasses, /obj/item/clothing/glasses))
			var/obj/item/clothing/glasses/glasses = H.glasses
			if(glasses?.examine_extensions)
				have_hud_exam |= glasses.examine_extensions

		if(istype(H.head, /obj/item/clothing/head/helmet/space))
			var/obj/item/clothing/head/helmet/space/helmet = H.head
			if(helmet?.examine_extensions)
				have_hud_exam |= helmet.examine_extensions

		var/obj/item/organ/internal/cyberimp/eyes/hud/CIH = H.get_int_organ(/obj/item/organ/internal/cyberimp/eyes/hud)
		if(CIH?.examine_extensions)
			have_hud_exam |= CIH.examine_extensions

		if(H.check_smart_brain())
			have_hud_exam |= EXAMINE_HUD_SCIENCE

		return (have_hud_exam & hud_exam)

	else if(isrobot(M) || isAI(M)) //Stand-in/Stopgap to prevent pAIs from freely altering records, pending a more advanced Records system
		return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SECURITY_WRITE || hud_exam & EXAMINE_HUD_MEDICAL

	else if(ispAI(M))
		var/mob/living/silicon/pai/P = M
		if(P.adv_secHUD)
			return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SECURITY_WRITE

	else if(isobserver(M))
		var/mob/dead/observer/O = M
		if(DATA_HUD_SECURITY_ADVANCED in O.data_hud_seen)
			return hud_exam & EXAMINE_HUD_SECURITY_READ || hud_exam & EXAMINE_HUD_SKILLS

	return FALSE

// Ignores robotic limb branding prefixes like "Morpheus Cybernetics"
/proc/ignore_limb_branding(limb_zone)
	switch(limb_zone)
		if(BODY_ZONE_CHEST)
			. = "upper body"
		if(BODY_ZONE_PRECISE_GROIN)
			. = "lower body"
		if(BODY_ZONE_HEAD)
			. = "head"
		if(BODY_ZONE_L_ARM)
			. = "left arm"
		if(BODY_ZONE_R_ARM)
			. = "right arm"
		if(BODY_ZONE_L_LEG)
			. = "left leg"
		if(BODY_ZONE_R_LEG)
			. = "right leg"
		if(BODY_ZONE_PRECISE_L_FOOT)
			. = "left foot"
		if(BODY_ZONE_PRECISE_R_FOOT)
			. = "right foot"
		if(BODY_ZONE_PRECISE_L_HAND)
			. = "left hand"
		if(BODY_ZONE_PRECISE_R_HAND)
			. = "right hand"
