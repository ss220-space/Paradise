/datum/devil_rank
	/// Antagonist datum of our owner
	var/name
	var/datum/antagonist/devil/devil
	/// Which spells we'll give to rank owner when rank is applied
	var/list/rank_spells
	/// Regeneration things for devil. Used in devil elements
	var/regen_threshold
	var/regen_amount
	/// just OOP thing. Ranks without this designated as last rank.
	var/datum/devil_rank/next_rank_type
	/// How many souls we need to ascend to next rank.
	var/required_souls
	/// How many sacrifices we need to ascend to next rank.
	var/required_sacrifice = 0
	/// Is ritual needed to ascend to next rank.
	var/ritual_required = FALSE

/datum/devil_rank/Destroy(force)
	remove_spells()

	devil = null

	return ..()

/datum/devil_rank/proc/link_rank(mob/living/carbon/carbon)
	devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)


/datum/devil_rank/proc/remove_spells()
	if(!devil.owner)
		return

	for(var/obj/effect/proc_holder/spell/spell as anything in devil.owner.spell_list)
		if(!is_type_in_list(spell, rank_spells))
			continue

		devil.owner.RemoveSpell(spell)

/datum/devil_rank/proc/apply_rank(mob/living/carbon/carbon)
	return FALSE

/datum/devil_rank/proc/give_spells()
	if(!devil.owner)
		return

	for(var/obj/effect/proc_holder/spell/spell as anything in rank_spells)
		if(is_type_in_list(spell, rank_spells))
			continue
		devil.owner.AddSpell(new spell)

/datum/devil_rank/basic_devil
	name = "Низший дьявол"
	regen_threshold = BASIC_DEVIL_REGEN_THRESHOLD
	regen_amount = BASIC_DEVIL_REGEN_AMOUNT

	next_rank_type = ENRAGED_DEVIL_RANK
	required_souls = ENRAGED_THRESHOLD

	rank_spells = list(
		/obj/effect/proc_holder/spell/devil_panel,
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/summon_contract,
		/obj/effect/proc_holder/spell/return_soul
	)

/datum/devil_rank/enraged_devil
	name = "Злой дьявол"
	regen_threshold = ENRAGED_DEVIL_REGEN_THRESHOLD
	regen_amount = ENRAGED_DEVIL_REGEN_AMOUNT

	next_rank_type = BLOOD_LIZARD_RANK
	required_souls = BLOOD_THRESHOLD
	required_sacrifice = BLOOD_SACRIFICE

	rank_spells = list(
		/obj/effect/proc_holder/spell/devil_panel,
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/summon_contract,
		/obj/effect/proc_holder/spell/return_soul,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/dark_conversion
	)

/datum/devil_rank/blood_lizard
	name = "Кровавый ящер"

	regen_threshold = BLOOD_LIZARD_REGEN_THRESHOLD
	regen_amount = BLOOD_LIZARD_REGEN_AMOUNT

	next_rank_type = TRUE_DEVIL_RANK
	required_souls = TRUE_THRESHOLD
	required_sacrifice = TRUE_SACRIFICE

	rank_spells = list(
		/obj/effect/proc_holder/spell/devil_panel,
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/summon_contract,
		/obj/effect/proc_holder/spell/return_soul,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/dark_conversion
	)

/datum/devil_rank/blood_lizard/apply_rank()
	var/mob/living/carbon/human/human = devil.owner.current
	var/list/language_temp = LAZYLEN(human.languages) ? human.languages.Copy() : null
	human.RemoveElement(/datum/element/devil_regeneration) // Species change call organ removing
	human.set_species(/datum/species/unathi)
	human.AddElement(/datum/element/devil_regeneration)
	if(language_temp)
		human.languages |= language_temp

	human.underwear = "Nude"
	human.undershirt = "Nude"
	human.socks = "Nude"
	human.change_skin_color(BLOOD_COLOR_RED) //A deep red
	human.regenerate_icons()

	return FALSE

/datum/devil_rank/true_devil
	name = "Истинный дьявол"
	regen_threshold = TRUE_DEVIL_REGEN_THRESHOLD
	regen_amount = TRUE_DEVIL_REGEN_AMOUNT

	next_rank_type = ASCEND_DEVIL_RANK
	required_souls = ASCEND_THRESHOLD
	ritual_required = TRUE

	rank_spells = list(
		/obj/effect/proc_holder/spell/devil_panel,
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/summon_contract,
		/obj/effect/proc_holder/spell/return_soul,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/sintouch,
		/obj/effect/proc_holder/spell/dark_conversion
	)

/datum/devil_rank/true_devil/apply_rank()
	var/mob/devil_mob = devil.owner.current
	if(istype(devil_mob.loc, /obj/effect/dummy/slaughter))
		devil_mob.forceMove(get_turf(devil_mob))
	var/mob/living/carbon/true_devil/true_devil
	if(isdevil(devil_mob))
		to_chat(devil_mob, span_revenbignotice("Вы чувствуете, как ваше тело меняется."))
		true_devil = devil_mob
		return FALSE
	true_devil = new (get_turf(devil_mob))
	ADD_TRAIT(devil_mob, TRAIT_NO_BREATH, DEVIL_TRAIT)
	devil_mob.forceMove(true_devil)
	true_devil.oldform = devil_mob
	devil.owner.transfer_to(true_devil)
	return TRUE

/datum/devil_rank/ascend
	name = "Архидьявол"
	regen_threshold = ASCEND_DEVIL_REGEN_THRESHOLD
	regen_amount = ASCEND_DEVIL_REGEN_AMOUNT

	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork/ascended,
		/obj/effect/proc_holder/spell/fireball/hellish/acsend,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/devil_broadcast
	)

/datum/devil_rank/ascend/apply_rank()
	var/mob/devil_mob = devil.owner.current
	if(istype(devil_mob.loc, /obj/effect/dummy/slaughter))
		devil_mob.forceMove(get_turf(devil_mob))
	var/mob/living/carbon/true_devil/ascended/true_devil
	if(isascendeddevil(devil_mob))
		true_devil = devil_mob
		true_devil.devilinfo = devil.owner.has_antag_datum(/datum/antagonist/devil)
		true_devil.set_name()
		return FALSE
	true_devil = new (get_turf(devil_mob))
	if(isdevil(devil_mob))
		var/mob/living/carbon/true_devil/old_devil = devil_mob
		old_devil.oldform?.forceMove(true_devil)
		true_devil.oldform = old_devil.oldform
		old_devil.oldform = null
		old_devil.forceMove(true_devil)
		QDEL_IN(old_devil, 1 SECONDS)
	else
		ADD_TRAIT(devil_mob, TRAIT_NO_BREATH, DEVIL_TRAIT)
		devil_mob.forceMove(true_devil)
		true_devil.oldform = devil_mob
	devil.owner.transfer_to(true_devil)
	return TRUE

