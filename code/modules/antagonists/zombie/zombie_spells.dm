/datum/action/cooldown/spell/zombie_claws
	name = "Когти зомби"
	desc = "Переключает ваши когти, позволяя вам резать и заражать других людей."
	button_icon_state = "vampire_claws"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = NONE
	var/list/our_claws = list()
	var/infection_stage = 1 // mostly for adminbus and testing
	var/disease
	var/damage_mod = 1

/datum/action/cooldown/spell/zombie_claws/Destroy()
	QDEL_LIST_CONTENTS(our_claws)
	return ..()

/datum/action/cooldown/spell/zombie_claws/cast(atom/cast_on)
	. = ..()
	if(dispel())
		return

	var/obj/item/zombie_claw/claws
	if(HAS_TRAIT(owner, TRAIT_PLAGUE_ZOMBIE))
		claws = new /obj/item/zombie_claw/plague_claw(owner.loc, src, disease)
	else
		claws = new /obj/item/zombie_claw(owner.loc, src)
		claws.infection_stage = infection_stage

	claws.force *= damage_mod
	claws.damage_mod = damage_mod

	if(owner.put_in_hands(claws))
		our_claws += claws
		RegisterSignal(owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(dispel))
	else
		qdel(claws)
		to_chat(owner, span_warning(span_zombie("У нас нет когтей...")))


/datum/action/cooldown/spell/zombie_claws/proc/dispel()
	var/mob/living/carbon/human/user = owner
	var/obj/item/zombie_claw/claw = user.get_active_hand()
	if(istype(claw, /obj/item/zombie_claw) || istype(claw, /obj/item/zombie_claw/plague_claw))
		qdel(claw)
		return TRUE

/datum/action/cooldown/spell/zombie_claws/before_cast(atom/cast_on)
	var/mob/living/living_owner = owner
	if(living_owner.get_active_hand() || living_owner.is_holding_item_of_type(/obj/item/zombie_claw))
		return SPELL_CANCEL_CAST
	return ..()

/obj/item/zombie_claw
	name = "claws"
	desc = "Когти, выдвигающиеся из ваших гниющих рук — идеально подходят для того, чтобы вскрывать черепа и добираться до мозгов внутри."
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	lefthand_file = 'icons/mob/inhands/twohanded_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/twohanded_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	item_flags = ABSTRACT | DROPDEL
	gender = PLURAL
	force = 21 // allows them to break down doors aka NOT FUCKING AROUND
	armour_penetration = -10
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("полоснул", "уколол", "поранил", "порезал", "поцарапал")
	sprite_sheets_inhand = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/held.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/held.dmi',
	)
	var/datum/action/cooldown/spell/zombie_claws/parent_spell
	var/force_weak = 10
	var/infection_stage = 1
	var/claw_disease
	var/damage_mod = 1

/obj/item/zombie_claw/get_ru_names()
	return alist(
		NOMINATIVE = "когти",
		GENITIVE = "когтей",
		DATIVE = "когтям",
		ACCUSATIVE = "когти",
		INSTRUMENTAL = "когтями",
		PREPOSITIONAL = "когтях",
	)

/obj/item/zombie_claw/Initialize(mapload, new_parent_spell)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	AddComponent(/datum/component/two_handed, require_twohands = TRUE)
	if(new_parent_spell)
		parent_spell = new_parent_spell

/obj/item/zombie_claw/Destroy()
	if(parent_spell)
		parent_spell.UnregisterSignal(parent_spell.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		if(parent_spell)
			parent_spell.our_claws -= src
			parent_spell = null
	return ..()

/obj/item/zombie_claw/attack(mob/living/target, mob/living/user, list/modifiers, def_zone, skip_attack_anim)
	if(!HAS_TRAIT(user, TRAIT_PLAGUE_ZOMBIE))
		if(user.reagents.has_reagent(/datum/reagent/zombie_cure/second))
			force = force_weak
		else
			force = initial(force) * damage_mod
	return ..()

/obj/item/zombie_claw/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(!proximity_flag)
		return
	if(!ishuman(target) || ismachineperson(target))
		return
	var/mob/living/carbon/human/attack_target = target

	if(HAS_TRAIT(user, TRAIT_PLAGUE_ZOMBIE))
		try_virus_infect(attack_target, user, claw_disease)
		return
	else
		try_infect(attack_target, user)

	var/obj/item/organ/internal/brain/eat_brain = attack_target.get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(!eat_brain)
		return
	var/obj/item/organ/external/brain_holder = attack_target.get_organ(eat_brain.parent_organ_zone)
	if(!brain_holder || brain_holder.open || brain_holder.limb_zone != user.zone_selected)
		return

	// Max damage - 5
	if(brain_holder.brute_dam + brain_holder.burn_dam <= brain_holder.max_damage - 5) // Deal more damage
		return

	if(attack_target.getarmor(brain_holder, MELEE) > 0) // dont count negative armor
		to_chat(user, span_warning(span_zombie("Мозги [target.declent_ru(GENITIVE)] заблокированы.")))
		return // Armor blocks zombies trying to eat your brains!

	to_chat(target, span_userdanger("Когти [user.declent_ru(GENITIVE)] вонзаются в ваш [brain_holder.encased]!"))
	user.visible_message(span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] вонзает когти в [brain_holder.encased] [target.declent_ru(GENITIVE)]!"), span_danger(span_zombie("Мы вонзаем когти в [brain_holder.encased] [target.declent_ru(GENITIVE)]...")))
	playsound(user, 'sound/weapons/armblade.ogg', 50, TRUE)
	if(!do_after(user, 3 SECONDS, target))
		return FALSE

	playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
	brain_holder.fracture()

	brain_holder.open = ORGAN_ORGANIC_VIOLENT_OPEN
	to_chat(target, span_userdanger("Ваш [brain_holder.name] жестоко вскрыт!"))
	user.visible_message(span_danger("[DECLENT_RU_CAP(user, NOMINATIVE)] жестоко раскалывает [brain_holder.declent_ru(ACCUSATIVE)] [target.declent_ru(GENITIVE)]!"), span_danger(span_zombie("Мы раскалываем [brain_holder.declent_ru(ACCUSATIVE)] [target.declent_ru(GENITIVE)]!")))
	return TRUE

/obj/item/zombie_claw/proc/try_infect(mob/living/carbon/human/target, mob/living/user)
	if(!ishuman(target) || HAS_TRAIT(user, TRAIT_NON_INFECTIOUS_ZOMBIE))
		return
	if(HAS_TRAIT(target, TRAIT_PIERCEIMMUNE))
		return FALSE
	if(target.reagents.has_reagent(/datum/reagent/zombie_cure) || target.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		return
	var/obj/item/organ/external/affecting = target.get_organ(user.zone_selected) // Head, or Chest.
	if(affecting.is_robotic())
		return // We don't want people to be infected via zombie claws if they're augmented or have robotic limbs. Bites are handled differently.
	if(prob(3 * target.getarmor(user.zone_selected, MELEE)) || prob(50)) // more than 33.34 melee armor will always protect you! Or just get lucky B)
		return // Armor blocks zombies trying to eat your brains!
	for(var/datum/disease/virus/virus as anything in user.diseases)
		virus.Contract(target, BLOOD|BITES, need_protection_check = TRUE, zone = user.zone_selected)
	// already have the disease, or have contracted it. Good for feedback when being attacked while wearing a biosuit
	if(target.HasDisease(/datum/disease/virus/zombie))
		playsound(user.loc, 'sound/misc/moist_impact.ogg', 50, TRUE)
		target.bleed_rate = max(5, target.bleed_rate + 1) // it transfers via blood, you know. It had to get in somehow.
		for(var/datum/disease/virus/zombie/zomb in target.diseases)
			zomb.stage = max(zomb.stage, infection_stage)

/obj/item/zombie_claw/attack_self(mob/user)
	. = ..()
	qdel(src)

//wizard plague zombie claws
/datum/action/cooldown/spell/zombie_claws/plague_claws
	name = "Чумные когти"
	desc = "Переключает ваши когти, позволяя вам резать и заражать людей смертельными болезнями."

/obj/item/zombie_claw/plague_claw
	name = "Plague Claws"
	desc = "Когти, выдвигающиеся из ваших гниющих рук и сочащиеся гнилостной ихорой. Идеально подходят для разрывания плоти и костей ради вашего хозяина."
	armour_penetration = 15
	force = 13

/obj/item/zombie_claw/plague_claw/get_ru_names()
	return alist(
		NOMINATIVE = "чумные когти",
		GENITIVE = "чумных когтей",
		DATIVE = "чумным когтям",
		ACCUSATIVE = "чумные когти",
		INSTRUMENTAL = "чумным когтями",
		PREPOSITIONAL = "чумных когтях",
	)

/obj/item/zombie_claw/plague_claw/Initialize(mapload, new_parent_spell, disease)
	. = ..()
	claw_disease = disease

/obj/item/zombie_claw/proc/try_virus_infect(mob/living/carbon/human/target, mob/living/user)
	if(!target.HasDisease(claw_disease))
		var/datum/disease/plague = new claw_disease
		plague.Contract(target)
	else if(prob(40)) // 40% chance to advance the disease
		for(var/datum/disease/D in target.diseases)
			if(D.type == claw_disease && D.stage < D.max_stages)
				D.stage += 1
	target.bleed_rate = max(5, target.bleed_rate + 1) // Very sharp, ouch!

/datum/action/cooldown/spell/pointed/zombie_leap
	name = "Безумный прыжок"
	desc = "На мгновение снимает ограничители с ваших мышц, чтобы совершить прыжок на большое расстояние в сторону вашей цели."
	button_icon_state = "mutate"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = NONE
	cooldown_time = 30 SECONDS

/datum/action/cooldown/spell/pointed/zombie_leap/before_cast(atom/cast_on)
	if(iscarbon(owner))
		var/mob/living/carbon/caster = owner
		return ..() && caster.body_position != LYING_DOWN
	return ..()

/datum/action/cooldown/spell/pointed/zombie_leap/cast(atom/cast_on)
	. = ..()
	if(isliving(owner))
		playsound(owner, 'sound/voice/zombie_leap.ogg', 80, FALSE)
		var/mob/living/living_owner = owner
		living_owner.apply_status_effect(STATUS_EFFECT_CHARGING)
		living_owner.throw_at(cast_on, 5, 1, living_owner, FALSE, callback = CALLBACK(living_owner, TYPE_PROC_REF(/mob/living, remove_status_effect), STATUS_EFFECT_CHARGING))

/datum/action/cooldown/spell/stomp/zombie/target_validation(mob/living/target, mob/user)
	return !HAS_TRAIT(target, TRAIT_I_WANT_BRAINS)

/datum/action/cooldown/spell/stomp/zombie/create_new_handler()
	return NONE

/datum/action/cooldown/spell/smoke/zombie
	name = "Тошнотворный дым"
	desc = "Вы испускаете зловонный дым, заставляющий всех вокруг блевать."
	button_icon_state = "parasmoke"
	background_icon_state = "bg_vampire"
	smoke_type = /datum/effect_system/fluid_spread/smoke/zombie

/datum/action/cooldown/spell/pointed/projectile/acid_spit
	name = "Кислотный плевок"
	desc = "Эта способность позволяет вам плеваться кислотой. При попадании наносит урон токсинами."
	cooldown_time = 5 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS
	active_msg = span_noticealien_alt("<b>Вы подготавливаете немного кислоты!</b>")
	deactive_msg = span_noticealien_alt("<b>Вы перевариваете подготовленную кислоту.</b>")
	projectile_type = /obj/projectile/bullet/acid_split
	button_icon_state = "alien_neurotoxin_0"
	background_icon_state = "bg_vampire"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	unset_after_click = FALSE

/datum/action/cooldown/spell/select_zombie_class
	name = "Выбрать класс"
	desc = "Выберите, каким зомби вы хотите стать."
	school = SCHOOL_SANGUINE
	button_icon_state = "select_class"
	background_icon_state = "bg_vampire"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	gain_desc = "Теперь вы можете выбрать, каким зомби вы хотите стать."

/datum/action/cooldown/spell/select_zombie_class/before_cast(atom/cast_on)
	var/mob/living/living_owner = owner
	if(!living_owner?.mind?.has_antag_datum(/datum/antagonist/zombie))
		return SPELL_CANCEL_CAST
	return ..()

/datum/action/cooldown/spell/select_zombie_class/cast(atom/cast_on)
	var/mob/living/living_owner = owner
	var/datum/antagonist/zombie/datum = living_owner.mind.has_antag_datum(/datum/antagonist/zombie)
	var/selected_class = tgui_input_list(owner, "Выберите класс зомби", "Класс зомби", GLOB.zombie_classes)
	if(isnull(selected_class))
		return ..()
	datum.class = GLOB.zombie_classes[selected_class]
	datum.class.apply(living_owner)
	qdel(src)
