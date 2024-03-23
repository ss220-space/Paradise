#define EVENT_CLING_GPOINTS 13

/mob/living/simple_animal/hostile/headslug/evented
	icon_state = "headslugevent"
	icon_living = "headslugevent"
	icon_dead = "headslug_deadevent"
	evented = TRUE


/mob/living/simple_animal/hostile/headslug/evented/proc/make_slug_antag(give_default_objectives = TRUE)
	mind.assigned_role = SPECIAL_ROLE_HEADSLUG
	mind.special_role = SPECIAL_ROLE_HEADSLUG
	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>We are a headslug.</font><br></b>")
	messages.Add(span_changeling("Our eggs can be laid in any dead humanoid, but not in small ones. Use <B>Alt-Click</B> on the valid mob and keep calm for 5 seconds."))
	messages.Add(span_notice("Though this form shall perish after laying the egg, our true self shall be reborn in time."))

	SEND_SOUND(src, sound('sound/vox_fem/changeling.ogg'))
	if(give_default_objectives)
		var/datum/objective/findhost = new /datum/objective // objective just for rofl
		findhost.owner = mind
		findhost.explanation_text = "Find the corpse to lay eggs in and evolve."
		findhost.completed = TRUE
		findhost.needs_target = FALSE
		mind.objectives += findhost
		messages.Add(mind.prepare_announce_objectives())
	to_chat(src, chat_box_red(messages.Join("<br>")))

/datum/antagonist/changeling/evented // make buffed changeling
	evented = TRUE
	genetic_points = EVENT_CLING_GPOINTS
	absorbed_dna = list()

/datum/antagonist/changeling/evented/on_gain()
	..()
	var/datum/action/changeling/lesserform/sluglesser = new /datum/action/changeling/lesserform // give new innate power
	sluglesser.power_type = "changeling_innate_power"
	sluglesser.dna_cost = 0
	give_power(sluglesser)
	absorbed_dna = list()

#undef EVENT_CLING_GPOINTS


