/datum/antagonist/morph
	name = "Morph"
	show_in_roundend = TRUE
	job_rank = ROLE_MORPH
	special_role = SPECIAL_ROLE_MORPH
	roundend_category = "morphs"
	show_in_orbit = TRUE

	var/is_magical = FALSE
	var/mob/living/simple_animal/hostile/morph/morph
	
	/// morph default abilities are going here.
	var/obj/effect/proc_holder/spell/mimic/morph/mimic_spell = new
	var/obj/effect/proc_holder/spell/morph_spell/ambush/ambush_spell = new
	var/obj/effect/proc_holder/spell/morph_spell/open_vent/open_vent_spell = new
	var/obj/effect/proc_holder/spell/morph_spell/pass_airlock/pass_airlock_spell = new
	var/obj/effect/proc_holder/spell/morph_spell/reproduce/reproduce_spell = new

/datum/antagonist/morph/Destroy(force)
	morph = null
	return ..()

/datum/antagonist/morph/can_be_owned(datum/mind/new_mind)
	. = ..()
	if(!.)
		return FALSE
		
	var/datum/mind/mind = new_mind || owner

	if(!mind || !ismorph(mind.current))
		return FALSE

	return TRUE

/datum/antagonist/morph/add_owner_to_gamemode()
	SSticker.mode.traitors |= owner

/datum/antagonist/morph/remove_owner_from_gamemode()
	SSticker.mode.traitors -= owner

/datum/antagonist/morph/apply_innate_effects(mob/living/mob_override)
	. = ..()
	morph = owner.current || mob_override
	grant_abilities()

/datum/antagonist/morph/remove_innate_effects(mob/living/mob_override)
	. = ..()
	remove_abilities()

/// should be separated to avoid garbage in mind things.
/datum/antagonist/morph/proc/grant_abilities()
	owner.AddSpell(mimic_spell)
	owner.AddSpell(ambush_spell)
	owner.AddSpell(open_vent_spell)
	owner.AddSpell(pass_airlock_spell)

	if(morph.can_reproduce)
		owner.AddSpell(reproduce_spell)

	if(is_magical)
		grant_magic()

	return

/datum/antagonist/morph/proc/remove_abilities()
	owner.RemoveSpell(mimic_spell)
	owner.RemoveSpell(ambush_spell)
	owner.RemoveSpell(open_vent_spell)
	owner.RemoveSpell(pass_airlock_spell)

	if(morph.can_reproduce)
		owner.RemoveSpell(reproduce_spell)

	if(is_magical)
		remove_magic()

	return

/datum/antagonist/morph/proc/grant_magic()
	var/obj/effect/proc_holder/spell/smoke/smoke = new
	var/obj/effect/proc_holder/spell/forcewall/forcewall = new

	smoke.human_req = FALSE
	forcewall.human_req = FALSE

	owner.AddSpell(smoke)
	owner.AddSpell(forcewall)

/datum/antagonist/morph/proc/remove_magic()
	owner.RemoveSpell(/obj/effect/proc_holder/spell/smoke)
	owner.RemoveSpell(/obj/effect/proc_holder/spell/forcewall)

/datum/antagonist/morph/proc/switch_reproduce()
	if(morph.can_reproduce)
		morph.can_reproduce = FALSE
		owner.RemoveSpell(reproduce_spell)
		return

	morph.can_reproduce = TRUE
	owner.AddSpell(reproduce_spell)
	return

/datum/antagonist/morph/give_objectives()
	add_objective(/datum/objective/eat)
	add_objective(/datum/objective/procreate)

/datum/antagonist/morph/greet()
	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>You are a morph.</font><br></b>")
	messages.Add(span_sinister("You hunger for living beings and desire to procreate. Achieve this goal by ambushing unsuspecting pray using your abilities."))
	messages.Add("[span_specialnotice("As an abomination created primarily with changeling cells you may take the form of anything nearby by using your")] [span_specialnoticebold("Mimic ability.")]")
	messages.Add(span_specialnotice("The transformation will not go unnoticed for bystanding observers."))
	messages.Add("[span_specialnoticebold("While morphed")][span_specialnotice(", you move slower and do less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you.")]")
	messages.Add("[span_specialnotice("From this form you can however.")] [span_specialnoticebold("Prepare an Ambush using your ability.")]")
	messages.Add(span_specialnotice("This will allow you to deal a lot of damage the first hit. And if they touch you then even more."))
	messages.Add(span_specialnotice("Finally, you can attack any item or dead creature to consume it - creatures will restore 1/3 of your max health and will add to your stored food while eating items will reduce your stored food."))
	SEND_SOUND(owner.current, 'sound/magic/mutate.ogg')
	return messages

/datum/objective/eat
	explanation_text = "Eat as many living beings as possible to still the hunger within you."
	completed = TRUE
	needs_target = FALSE

/datum/objective/procreate
	explanation_text = "Split yourself in as many other morph's as possible!"
	completed = TRUE
	needs_target = FALSE
