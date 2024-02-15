#define VAULT_TOXIN "Toxin Adaptation"
#define VAULT_NOBREATH "Lung Enhancement"
#define VAULT_FIREPROOF "Thermal Regulation"
#define VAULT_STUNTIME "Neural Repathing"
#define VAULT_ARMOUR "Hardened Skin"
#define VAULT_SPEED "Leg Muscle Stimulus"
#define VAULT_QUICK "Arm Muscle Stimulus"

/obj/item/dna_upgrader
	name = "dna upgrader"
	desc = "test"
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
		ui_interact(user)
	else
		to_chat(user, span_notice("Looks like it is already used."))

/obj/item/dna_upgrader/ui_interact(mob/user, ui_key, datum/tgui/ui, force_open, datum/tgui/master_ui, datum/ui_state/state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)

	if(!ui)
		ui = new(user, src, ui_key, "DNAModifyer", name, 400, 150, master_ui, state)
		ui.open()

/obj/item/dna_upgrader/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)

	if(..())
		return

	switch(action)
		if("gene")
			var/mob/living/carbon/human/H = ui.user
			var/datum/species/S = H.dna.species
			if(NO_DNA in S.species_traits)
				to_chat(H, "<span class='warning'>Error, no DNA detected.</span>")
				return
			var/modification = params["modification"]
			switch(modification)
				if(VAULT_TOXIN)
					to_chat(H, "<span class='notice'>You feel resistant to airborne toxins.</span>")
					var/obj/item/organ/internal/lungs/L = H.get_int_organ(/obj/item/organ/internal/lungs)
					if(L)
						L.tox_breath_dam_min = 0
						L.tox_breath_dam_max = 0
					S.species_traits |= VIRUSIMMUNE
				if(VAULT_NOBREATH)
					to_chat(H, "<span class='notice'>Your lungs feel great.</span>")
					S.species_traits |= NO_BREATHE
				if(VAULT_FIREPROOF)
					to_chat(H, "<span class='notice'>You feel fireproof.</span>")
					S.burn_mod *= 0.5
					S.species_traits |= RESISTHOT
				if(VAULT_STUNTIME)
					to_chat(H, "<span class='notice'>Nothing can keep you down for long.</span>")
					S.stun_mod *= 0.5
					S.stamina_mod *= 0.5
					H.stam_regen_start_modifier *= 0.5
				if(VAULT_ARMOUR)
					to_chat(H, "<span class='notice'>You feel tough.</span>")
					S.brute_mod *= 0.7
					S.burn_mod *= 0.7
					S.tox_mod *= 0.7
					S.oxy_mod *= 0.7
					S.clone_mod *= 0.7
					S.brain_mod *= 0.7
					S.stamina_mod *= 0.7
					S.species_traits |= PIERCEIMMUNE
				if(VAULT_SPEED)
					to_chat(H, "<span class='notice'>You feel very fast and agile.</span>")
					S.speed_mod = -1
				if(VAULT_QUICK)
					to_chat(H, "<span class='notice'>Your arms move as fast as lightning.</span>")
					H.next_move_modifier = 0.5
			ui.close()
			H.gene_stability += 25
			to_chat(H, span_notice("You feel like your body rebasing."))
			used = TRUE
			update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)
			return TRUE

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
