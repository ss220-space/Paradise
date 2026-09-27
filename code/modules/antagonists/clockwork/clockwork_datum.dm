/datum/antagonist/clockwork
	name = "Clockwork Cultist"
	roundend_category = "Культистами Ратвара"
	show_in_roundend = FALSE
	job_rank = ROLE_CLOCKER
	special_role = SPECIAL_ROLE_CLOCKER
	antag_hud_type = ANTAG_HUD_CLOCK
	antag_hud_name = "hudclocker"
	antag_menu_name = "Культист Ратвара"
	greet_box_class = "yellow_box"
	clown_gain_text = "A dark power has allowed you to overcome your clownish nature, letting you wield weapons without harming yourself."
	stinger_sound = 'sound/ambience/antag/clockcult.ogg'
	default_team_type = /datum/team/clockwork_cult

/datum/antagonist/clockwork/Destroy(force)
	if(owner?.current)
		for(var/datum/action/innate/clockwork/action in owner.current.actions)
			qdel(action)
	return ..()

/datum/antagonist/clockwork/is_banned(mob/user)
	if(!user)
		return FALSE
	return ..() || jobban_isbanned(user, ROLE_CULTIST)

/datum/antagonist/clockwork/give_objectives()
	add_objective(/datum/objective/serveclock)

/datum/antagonist/clockwork/greet()
	return CLOCK_GREETING

/datum/antagonist/clockwork/farewell()
	if(owner?.current && !silent)
		owner.current.visible_message(
			span_clock("[owner.current] looks like [owner.current.p_they()] just reverted to [owner.current.p_their()] old faith!"),
			span_userdanger("An unfamiliar white light flashes through your mind, cleansing the taint of Ratvar and the memories of your time as their servant with it."),
		)

/datum/antagonist/clockwork/apply_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction |= "clockwork_cult"
	if(iscarbon(user))
		user.AddElement(/datum/element/halo_attach, GLOB.halo_overlays["clockwork"], GLOB.halo_callbacks["clockwork"])
	var/datum/team/clockwork_cult/clock_team = get_clockwork_cult_team()
	if(clock_team?.power_reveal)
		clock_team.powered(user)
		clock_team.powered_borgs(user)
	if(clock_team?.crew_reveal)
		clock_team.clocked(user)

	if(locate(/datum/action/innate/clockwork/comm) in user.actions)
		return
	var/datum/action/innate/clockwork/comm/communion = new
	communion.Grant(user)
	var/datum/action/innate/clockwork/check_progress/progress = new
	progress.Grant(user)
	if(ishuman(user) || issilicon(user) && !isAI(user))
		var/datum/action/innate/clockwork/clock_magic/magic = new
		magic.Grant(user)
	user.update_action_buttons(TRUE)

/datum/antagonist/clockwork/remove_innate_effects(mob/living/mob_override)
	var/mob/living/user = ..()
	user.faction -= "clockwork_cult"
	user.RemoveElement(/datum/element/halo_attach, GLOB.halo_overlays["clockwork"], GLOB.halo_callbacks["clockwork"])
	if(ishuman(user))
		var/mob/living/carbon/human/human_user = user
		REMOVE_TRAIT(human_user, TRAIT_CLOCK_HANDS, CLOCK_TRAIT)
		human_user.update_worn_gloves()
		human_user.remove_overlay(HALO_LAYER)
		human_user.update_body()

/proc/isclocker(mob/living/user)
	return istype(user) && user.mind?.has_antag_datum(/datum/antagonist/clockwork)

/proc/isclocker_ascended(mob/living/user)
	var/datum/team/clockwork_cult/clock_team = get_clockwork_cult_team()
	return isclocker(user) && clock_team?.crew_reveal
