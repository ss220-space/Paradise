/datum/devil_rank
	/// Antagonist datum of our owner
	var/datum/antagonist/devil/devil
	/// Which spells we'll give to rank owner when rank is applied
	var/list/rank_spells
	/// Regeneration things for devil. Used in devil elements
	var/regen_threshold
	var/regen_amount
	/// just OOP thing. Ranks without this designated as last rank.
	var/next_rank_type
	/// How many souls we need to ascend to next rank.
	var/required_souls

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
	return

/datum/devil_rank/proc/give_spells()
	if(!devil.owner)
		return

	for(var/obj/effect/proc_holder/spell/spell as anything in rank_spells)
		devil.owner.AddSpell(new spell)

/datum/devil_rank/basic_devil
	regen_threshold = BASIC_DEVIL_REGEN_THRESHOLD
	regen_amount = BASIC_DEVIL_REGEN_AMOUNT

	next_rank_type = ENRAGED_DEVIL_RANK
	required_souls = ENRAGED_THRESHOLD

	rank_spells = list(/obj/effect/proc_holder/spell/sacrifice_circle)

/datum/devil_rank/enraged_devil
	regen_threshold = ENRAGED_DEVIL_REGEN_THRESHOLD
	regen_amount = ENRAGED_DEVIL_REGEN_AMOUNT

	next_rank_type = BLOOD_LIZARD_RANK
	required_souls = BLOOD_THRESHOLD

	rank_spells = list(
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/dark_conversion
	)

/datum/devil_rank/blood_lizard
	regen_threshold = BLOOD_LIZARD_REGEN_THRESHOLD
	regen_amount = BLOOD_LIZARD_REGEN_AMOUNT

	next_rank_type = TRUE_DEVIL_RANK
	required_souls = TRUE_THRESHOLD

	rank_spells = list(
		/obj/effect/proc_holder/spell/sacrifice_circle,
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/dark_conversion,
		/obj/effect/proc_holder/spell/aoe/devil_fire
	)

/datum/devil_rank/blood_lizard/apply_rank()
	var/mob/living/carbon/human/human = devil.owner.current
	var/list/language_temp = LAZYLEN(human.languages) ? human.languages.Copy() : null

	human.set_species(/datum/species/unathi)
	if(language_temp)
		human.languages = language_temp

	human.underwear = "Nude"
	human.undershirt = "Nude"
	human.socks = "Nude"
	human.change_skin_color(80, 16, 16) //A deep red
	human.regenerate_icons()

	return

/datum/devil_rank/true_devil
	regen_threshold = TRUE_DEVIL_REGEN_THRESHOLD
	regen_amount = TRUE_DEVIL_REGEN_AMOUNT

	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/sintouch,
		/obj/effect/proc_holder/spell/dark_conversion,
		/obj/effect/proc_holder/spell/aoe/devil_fire
	)

/datum/devil_rank/true_devil/apply_rank()
	to_chat(devil.owner.current, span_revenbignotice("Вы чувствуете, как ваше тело меняется."))
	var/mob/living/carbon/true_devil/true_devil = new /mob/living/carbon/true_devil(get_turf(devil.owner.current))

	devil.owner.current.forceMove(true_devil)
	true_devil.oldform = devil.owner.current
	devil.owner.transfer_to(true_devil)
	true_devil.set_name()

	return
