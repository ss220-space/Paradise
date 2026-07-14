#define VAULT_TOXIN "Устойчивость к токсинам"
#define VAULT_NOBREATH "Улучшение лёгких"
#define VAULT_FIREPROOF "Терморегуляция"
#define VAULT_STUNTIME "Нейронное восстановление"
#define VAULT_ARMOUR "Каменная кожа"
#define VAULT_SPEED "Стимулятор мышц ног"
#define VAULT_QUICK "Стимуляция мышц рук"

/obj/item/dna_upgrader
	name = "dna upgrader"
	desc = "Кто-то мог бы сказать, что для такой сильной модификации необходимо выполнить цель станции... Дураки!"
	icon = 'icons/obj/hypo.dmi'
	icon_state = "dnaupgrader"
	var/used = FALSE

/obj/item/dna_upgrader/get_ru_names()
	return alist(
		NOMINATIVE = "модификатор ДНК",
		GENITIVE = "модификатора ДНК",
		DATIVE = "модификатору ДНК",
		ACCUSATIVE = "модификатор ДНК",
		INSTRUMENTAL = "модификатором ДНК",
		PREPOSITIONAL = "модификаторе ДНК",
	)

/obj/item/dna_upgrader/update_icon_state()
	icon_state = "dnaupgrader[used ? "0" : ""]"

/obj/item/dna_upgrader/update_name(updates = ALL)
	. = ..()
	name = used ? "used [initial(name)]" : initial(name)

/obj/item/dna_upgrader/attack_self(mob/user)
	if(!used)
		choose_genes(user)
	else
		balloon_alert(user, "уже используется!")

/obj/item/dna_upgrader/proc/choose_genes(mob/user)
	var/choosen_mod = tgui_input_list(user, "Выберите модификацию", name, list(VAULT_TOXIN, VAULT_NOBREATH, VAULT_FIREPROOF, VAULT_STUNTIME, VAULT_ARMOUR, VAULT_SPEED, VAULT_QUICK), ui_state = GLOB.not_incapacitated_state)
	if(!choosen_mod)
		return
	var/mob/living/carbon/human/human = user
	if(HAS_TRAIT(human, TRAIT_NO_DNA))
		balloon_alert(human, UNLINT("ДНК не обнаружена!"))
		return
	switch(choosen_mod)
		if(VAULT_TOXIN)
			to_chat(human, span_notice("Вы ощущаете устойчивость к инфекциям, передающимся воздушно-капельным путём."))
			var/obj/item/organ/internal/lungs/lungs = human.get_int_organ(/obj/item/organ/internal/lungs)
			if(lungs)
				lungs.tox_breath_dam_min = 0
				lungs.tox_breath_dam_max = 0
			ADD_TRAIT(human, TRAIT_VIRUSIMMUNE, name)
		if(VAULT_NOBREATH)
			to_chat(human, span_notice("Вы чувствуете, что ваши лёгкие работают лучше."))
			ADD_TRAIT(human, TRAIT_NO_BREATH, name)
		if(VAULT_FIREPROOF)
			to_chat(human, span_notice("Вы ощущаете себя невосприимчивым к огню."))
			human.physiology.burn_mod *= 0.5
			ADD_TRAIT(human, TRAIT_RESIST_HEAT, name)
		if(VAULT_STUNTIME)
			to_chat(human, span_notice("Вы ощущаете, что ничто не может надолго вывести вас из равновесия."))
			human.physiology.stun_mod *= 0.5
			human.physiology.stamina_mod *= 0.5
			human.stam_regen_start_modifier *= 0.5
		if(VAULT_ARMOUR)
			to_chat(human, span_notice("Вы чувствуете себя крепче."))
			human.physiology.brute_mod *= 0.7
			human.physiology.burn_mod *= 0.7
			human.physiology.tox_mod *= 0.7
			human.physiology.oxy_mod *= 0.7
			human.physiology.clone_mod *= 0.7
			human.physiology.brain_mod *= 0.7
			human.physiology.stamina_mod *= 0.7
			ADD_TRAIT(human, TRAIT_PIERCEIMMUNE, name)
		if(VAULT_SPEED)
			to_chat(human, span_notice("Вы ощущаете невероятную скорость и лёгкость."))
			human.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
		if(VAULT_QUICK)
			to_chat(human, span_notice("Ваши руки двигаются с молниеносной скоростью."))
			human.next_move_modifier *= 0.5
	human.gene_stability += 25
	to_chat(human, span_notice("Вы ощущаете, как ваше тело изменяется."))
	used = TRUE
	update_appearance(UPDATE_ICON_STATE|UPDATE_NAME)

#undef VAULT_TOXIN
#undef VAULT_NOBREATH
#undef VAULT_FIREPROOF
#undef VAULT_STUNTIME
#undef VAULT_ARMOUR
#undef VAULT_SPEED
#undef VAULT_QUICK
