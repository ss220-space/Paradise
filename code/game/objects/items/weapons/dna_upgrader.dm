#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Hardened Skin"
#define VAULT_SPEED "Leg Muscle Stimulus"
#define VAULT_QUICK "Arm Muscle Stimulus"

/obj/item/dna_upgrader
	name = "dna upgrader"
	desc = "Somebody could say that such great modification may be reached only by station goal... Fools."
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnaupgrader"
	var/used = FALSE

/obj/item/dna_upgrader/update_icon_state()
	icon_state = "dnaupgrader[used ? "0" : ""]"

/obj/item/dna_upgrader/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)

/obj/item/dna_upgrader/attack_self(mob/user)
	if(!used)
		choose_genes(user)
	else
		to_chat(user, span_notice("Looks like it is already used."))

/obj/item/dna_upgrader/proc/choose_genes(mob/user)
	var/choosen_mod = tgui_input_list(user, "Choose a modification", name, list(VAULT_TOXIN, VAULT_NOBREATH, VAULT_FIREPROOF, VAULT_STUNTIME, VAULT_ARMOUR, VAULT_SPEED, VAULT_QUICK), ui_state = GLOB.not_incapacitated_state)
	if(!choosen_mod)
		return
	var/mob/living/carbon/human/H = user
	if(HAS_TRAIT(H, TRAIT_NO_DNA))
		to_chat(H, "<span class='warning'>Error, no DNA detected.</span>")
		return
	switch(choosen_mod)
		if(VAULT_TOXIN)
			to_chat(H, "<span class='notice'>You feel resistant to airborne toxins.</span>")
			var/obj/item/organ/internal/lungs/L = H.get_int_organ(/obj/item/organ/internal/lungs)
			if(L)
				L.tox_breath_dam_min = 0
				L.tox_breath_dam_max = 0
			ADD_TRAIT(H, TRAIT_VIRUSIMMUNE, name)
		if(VAULT_NOBREATH)
			to_chat(H, "<span class='notice'>Your lungs feel great.</span>")
			ADD_TRAIT(H, TRAIT_NO_BREATH, name)
		if(VAULT_FIREPROOF)
			to_chat(H, "<span class='notice'>You feel fireproof.</span>")
			H.physiology.burn_mod *= 0.5
			ADD_TRAIT(H, TRAIT_RESIST_HEAT, name)
		if(VAULT_STUNTIME)
			to_chat(H, "<span class='notice'>Nothing can keep you down for long.</span>")
			H.physiology.stun_mod *= 0.5
			H.physiology.stamina_mod *= 0.5
			H.stam_regen_start_modifier *= 0.5
		if(VAULT_ARMOUR)
			to_chat(H, "<span class='notice'>You feel tough.</span>")
			H.physiology.brute_mod *= 0.7
			H.physiology.burn_mod *= 0.7
			H.physiology.tox_mod *= 0.7
			H.physiology.oxy_mod *= 0.7
			H.physiology.clone_mod *= 0.7
			H.physiology.brain_mod *= 0.7
			H.physiology.stamina_mod *= 0.7
			ADD_TRAIT(H, TRAIT_PIERCEIMMUNE, name)
		if(VAULT_SPEED)
			to_chat(H, "<span class='notice'>You feel very fast and agile.</span>")
			H.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
		if(VAULT_QUICK)
			to_chat(H, "<span class='notice'>Your arms move as fast as lightning.</span>")
			H.next_move_modifier *= 0.5
	H.gene_stability += 25
	to_chat(H, span_notice("You feel like your body rebasing."))
	used = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
