/datum/devil_rank
	/// Antagonist datum of our owner
	var/datum/antagonist/devil/devil
	/// Rank owner
	var/mob/living/carbon/owner
	/// Which spells we'll give to rank owner when rank is applied
	var/list/rank_spells
	/// Regeneration things for devil. Used in devil elements
	var/regen_threshold
	var/regen_amount

/datum/devil_rank/Destroy(force)
	remove_spells()

	devil = null
	owner = null

	return ..()

/datum/devil_rank/proc/link_rank(mob/living/carbon/carbon)
	owner = carbon
	devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

/datum/devil_rank/proc/remove_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in owner.mind?.spell_list)
		if(!is_type_in_list(spell, rank_spells))
			continue

		owner.mind?.RemoveSpell(spell)

/datum/devil_rank/proc/apply_rank(mob/living/carbon/carbon)
	return

/datum/devil_rank/proc/give_spells()
	for(var/obj/effect/proc_holder/spell/spell as anything in rank_spells)
		owner.mind?.AddSpell(new spell)

/datum/devil_rank/basic_devil
	regen_threshold = BASIC_DEVIL_REGEN_THRESHOLD
	regen_amount = BASIC_DEVIL_REGEN_AMOUNT

	rank_spells = list() // TODO: new single spell which allows you to do rituals

/datum/devil_rank/enraged_devil
	regen_threshold = ENRAGED_DEVIL_REGEN_THRESHOLD
	regen_amount = ENRAGED_DEVIL_REGEN_AMOUNT

	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/dark_conversion
	)

/datum/devil_rank/blood_lizard
	regen_threshold = BLOOD_LIZARD_REGEN_THRESHOLD
	regen_amount = BLOOD_LIZARD_REGEN_AMOUNT

	rank_spells = list(
		/obj/effect/proc_holder/spell/conjure_item/pitchfork,
		/obj/effect/proc_holder/spell/fireball/hellish,
		/obj/effect/proc_holder/spell/aoe/devil_fire,
		/obj/effect/proc_holder/spell/infernal_jaunt,
		/obj/effect/proc_holder/spell/dark_conversion,
		/obj/effect/proc_holder/spell/aoe/devil_fire
	)

/datum/devil_rank/blood_lizard/apply_rank()
	if(!ishuman(owner))
		owner.color = "#501010"
		return

	var/mob/living/carbon/human/human = owner
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
	to_chat(owner, span_warning("You feel as though your current form is about to shed.  You will soon turn into a true devil."))
	var/mob/living/carbon/true_devil/A = new /mob/living/carbon/true_devil(owner.loc)

	owner.forceMove(A)
	A.oldform = owner
	owner.mind?.transfer_to(A)
	A.set_name()

	return
