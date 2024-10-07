/obj/item/forensics/swab
	name = "swab kit"
	desc = "A sterilized cotton swab and vial used to take forensic samples."
	icon_state = "swab"
	var/dispenser = 0
	var/gsr = 0
	var/list/dna
	var/used
	var/inuse = 0

/obj/item/forensics/swab/proc/is_used()
	return used


/obj/item/forensics/swab/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!ishuman(target))
		return ..()

	. = ATTACK_CHAIN_PROCEED

	if(is_used())
		to_chat(user, span_warning("This swab has already been used."))
		return .

	inuse = TRUE
	to_chat(user, span_notice("You start collecting an evidence..."))
	if(!do_after(user, 2 SECONDS, src))
		inuse = FALSE
		return .

	if(!target.dna || !target.dna.unique_enzymes)
		to_chat(user, span_warning("They don't seem to have DNA!"))
		return .

	if(user != target && target.a_intent != INTENT_HELP && target.body_position != LYING_DOWN)
		user.visible_message(span_danger("[user] tries to take prints from [target], but they move away."))
		return .

	if(user.zone_selected != BODY_ZONE_PRECISE_L_HAND || user.zone_selected != BODY_ZONE_PRECISE_R_HAND || user.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		to_chat(user, span_warning("You cannot obtain any data from this bodypart."))
		return .

	if(!get_location_accessible(target, user.zone_selected))
		to_chat(user, span_warning("This bodypart is covered with clothing!"))
		return .

	if(!target.get_organ(user.zone_selected))
		to_chat(user, span_warning("They don't have this bodypart!"))
		return .

	var/sample_type
	var/target_dna
	var/target_gsr
	switch(user.zone_selected)
		if(BODY_ZONE_PRECISE_MOUTH)
			if(!target.check_has_mouth())
				to_chat(user, span_warning("They don't have a mouth."))
				return .
			user.visible_message(span_notice("[user] swabs [target]'s mouth for a saliva sample."))
			target_dna = list(target.dna.unique_enzymes)
			sample_type = "DNA"
		if(BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND)
			user.visible_message("[user] swabs [target]'s palm for a sample.")
			sample_type = "GSR"
			target_gsr = target.gunshot_residue

	if(!sample_type)
		return .

	. |= ATTACK_CHAIN_SUCCESS

	if(!dispenser)
		dna = target_dna
		gsr = target_gsr
		set_used(sample_type, target)
	else
		var/obj/item/forensics/swab/swab = new(get_turf(user))
		swab.dna = target_dna
		swab.gsr = target_gsr
		swab.set_used(sample_type, target)


/obj/item/forensics/swab/afterattack(atom/A, mob/user, proximity, params)

	if(!proximity || istype(A, /obj/machinery/dnaforensics))
		return

	if(isliving(A))
		return

	if(is_used())
		to_chat(user, "<span class='warning'>This swab has already been used.</span>")
		return

	add_fingerprint(user)
	inuse = 1
	to_chat(user, "<span class='notice'>You begin collecting evidence.</span>")
	if(do_after(user, 2 SECONDS, src))
		var/list/choices = list()
		if(A.blood_DNA)
			choices |= "Blood"
		if(isclothing(A))
			choices |= "Gunshot Residue"

		var/choice
		if(!choices.len)
			to_chat(user, "<span class='warning'>There is no evidence on \the [A].</span>")
			inuse = 0
			return
		else if(choices.len == 1)
			choice = choices[1]
		else
			choice = input("What kind of evidence are you looking for?","Evidence Collection") as null|anything in choices

		if(!choice)
			inuse = 0
			return

		var/sample_type
		var/target_dna
		var/target_gsr
		if(choice == "Blood")
			if(!A.blood_DNA || !A.blood_DNA.len)
				inuse = 0
				return
			target_dna = A.blood_DNA.Copy()
			sample_type = "blood"

		else if(choice == "Gunshot Residue")
			var/obj/item/clothing/B = A
			if(!istype(B) || !B.gunshot_residue)
				to_chat(user, "<span class='warning'>There is no residue on \the [A].</span>")
				inuse = 0
				return
			target_gsr = B.gunshot_residue
			sample_type = "residue"

		if(sample_type)
			user.visible_message("\The [user] swabs \the [A] for a sample.", "You swab \the [A] for a sample.")
			if (!dispenser)
				dna = target_dna
				gsr = target_gsr
				set_used(sample_type, A)
			else
				var/obj/item/forensics/swab/S = new(get_turf(user))
				S.dna = target_dna
				S.gsr = target_gsr
				S.set_used(sample_type, A)
	inuse = 0

/obj/item/forensics/swab/proc/set_used(sample_str, atom/source)
	name = ("[initial(name)] ([sample_str] - [source])")
	desc = "[initial(desc)] The label on the vial reads 'Sample of [sample_str] from [source].'."
	icon_state = "swab_used"
	used = 1

/obj/item/forensics/swab/cyborg
	name = "swab kit"
	desc = "A sterilized cotton swab and vial used to take forensic samples."
	dispenser = 1
