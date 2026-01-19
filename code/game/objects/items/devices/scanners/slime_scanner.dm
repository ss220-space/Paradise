/obj/item/slime_scanner
	name = "slime scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "adv_spectrometer_s"
	item_state = "analyzer"
	origin_tech = "biotech=2"
	w_class = WEIGHT_CLASS_SMALL
	flags = CONDUCT
	throw_speed = 3
	materials = list(MAT_METAL=30, MAT_GLASS=20)

/obj/item/slime_scanner/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED
	if(user.incapacitated() || user.AmountBlinded())
		return .
	if(!isslime(target))
		to_chat(user, span_warning("This device can only scan slimes!"))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	playsound(src, SFX_INDUSTRIAL_SCAN, 20, TRUE, -2, TRUE, FALSE)
	slime_scan(target, user)

/proc/slime_scan(mob/living/simple_animal/slime/T, mob/living/user)
	var/list/msgs = list()
	msgs += "<b>Slime scan results:</b>"
	msgs += span_notice("[T.colour] [T.age_state.age] slime")
	msgs += "Nutrition: [T.nutrition]/[T.get_max_nutrition()]"
	if(T.nutrition < T.get_starve_nutrition())
		msgs += span_warning("Warning: slime is starving!")
	else if(T.nutrition < T.get_hunger_nutrition())
		msgs += span_warning("Warning: slime is hungry")
	msgs += "Electric change strength: [T.powerlevel]"
	msgs += "Health: [round(T.health/T.maxHealth,0.01)*100]%"
	if(T.slime_mutation[4] == T.colour)
		msgs += "This slime does not evolve any further."
	else
		if(T.slime_mutation[3] == T.slime_mutation[4])
			if(T.slime_mutation[2] == T.slime_mutation[1])
				msgs += "Possible mutation: [T.slime_mutation[3]]"
				msgs += "Genetic destability: [T.mutation_chance/2] % chance of mutation on splitting"
			else
				msgs += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]] (x2)"
				msgs += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
		else
			msgs += "Possible mutations: [T.slime_mutation[1]], [T.slime_mutation[2]], [T.slime_mutation[3]], [T.slime_mutation[4]]"
			msgs += "Genetic destability: [T.mutation_chance] % chance of mutation on splitting"
	if(T.cores > 1)
		msgs += "Multiple cores detected"
	msgs += "Growth progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown)]/[T.age_state.amount_grown]"
	msgs += "Split progress: [clamp(T.amount_grown, 0, T.age_state.amount_grown_for_split)]/[T.age_state.amount_grown_for_split]"
	msgs += "Evolve: preparing for [(T.amount_grown < T.age_state.amount_grown_for_split) ? (T.age_state.stat_text) : (T.age_state.age != SLIME_ELDER ? T.age_state.stat_text_evolve : T.age_state.stat_text)]"
	if(T.effectmod)
		msgs += span_notice("Core mutation in progress: [T.effectmod]")
		msgs += span_notice("Progress in core mutation: [T.applied] / [SLIME_EXTRACT_CROSSING_REQUIRED]")
	to_chat(user, chat_box_healthscan(msgs.Join("<br>")))
