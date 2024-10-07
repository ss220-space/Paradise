/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	var/is_renamed = FALSE //если слайм был заранее переименован
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	gender = NEUTER
	can_buckle_to = FALSE
	var/datum/slime_age/age_state = new /datum/slime_age/baby
	var/docile = 0
	faction = list("slime", "neutral")
	allows_unconscious = TRUE
	AI_delay_max = 0.5 SECONDS

	harm_intent_damage = 3
	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	tts_seed = "Chen"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	health = 150
	maxHealth = 150

	healable = 0
	gender = NEUTER

	nightvision = 8

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE | CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35
	var/chance_reproduce = 80

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Target = null // AI variable - tells the slime to hunt this down
	var/mob/living/Leader = null // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face
	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime
	var/force_stasis = FALSE

	var/static/regex/slime_name_regex = new("\\w+ (baby|adult|old|elder) slime \\(\\d+\\)")
	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/static/list/slime_colours = list("rainbow", "grey", "purple", "metal", "orange",
	"blue", "dark blue", "dark purple", "yellow", "silver", "pink", "red",
	"gold", "green", "adamantine", "oil", "light pink", "bluespace",
	"cerulean", "sepia", "black", "pyrite")

	///////////CORE-CROSSING CODE

	var/effectmod //What core modification is being used.
	var/applied = 0 //How many extracts of the modtype have been applied.


/mob/living/simple_animal/slime/Initialize(mapload, new_colour = "grey", age_state_new = new /datum/slime_age/baby, new_set_nutrition = 700)
	if (!(locate(/datum/action/innate/slime/feed) in actions))
		var/datum/action/innate/slime/feed/F = new
		F.Grant(src)
	if(age_state.age != SLIME_BABY && !(locate(/datum/action/innate/slime/reproduce) in actions))
		var/datum/action/innate/slime/reproduce/R = new
		R.Grant(src)
	if (!(locate(/datum/action/innate/slime/evolve) in actions))
		var/datum/action/innate/slime/evolve/E = new
		E.Grant(src)

	age_state = age_state_new
	set_health(age_state.health)
	update_state()

	create_reagents(100)
	set_colour(new_colour)
	. = ..()
	set_nutrition(new_set_nutrition)
	add_language(LANGUAGE_SLIME)

/mob/living/simple_animal/slime/Destroy()
	for(var/A in actions)
		var/datum/action/AC = A
		AC.Remove(src)
	Target = null
	Leader = null
	Friends.Cut()
	speech_buffer.Cut()
	return ..()

/mob/living/simple_animal/slime/proc/set_colour(new_colour)
	colour = new_colour
	update_appearance(UPDATE_NAME)
	slime_mutation = mutation_table(colour)
	var/sanitizedcolour = replacetext(colour, " ", "")
	coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	regenerate_icons()

/mob/living/simple_animal/slime/proc/update_state()
	harm_intent_damage = age_state.damage
	maxHealth = age_state.health
	transform = age_state.matrix_size
	if ((cores - age_state.cores) > 0)
		cores += age_state.cores
	else
		cores = age_state.cores

/mob/living/simple_animal/slime/update_name(updates = ALL)
	. = ..()
	if(is_renamed)
		return

	if(slime_name_regex.Find(name))
		number = rand(1, 1000)
		name = "[colour] [age_state.age] slime ([number])"
		real_name = name

/mob/living/simple_animal/slime/proc/random_colour()
	set_colour(pick(slime_colours))

/mob/living/simple_animal/slime/regenerate_icons()
	..()
	var/icon_text = "[colour] [(age_state.age != SLIME_BABY) ? "adult" : "baby"] slime"
	//icon_dead = "[icon_text] dead"
	icon_dead = "[colour] baby slime dead" //REMOVE THIS ONLY WHEN THERE WILL BE SPRITES OF ALL SLIME COLOURS AND SIZES!!!
	if(stat != DEAD)
		icon_state = icon_text
		if(mood && !stat)
			add_overlay("aslime-[mood]")
	else
		icon_state = icon_dead


/mob/living/simple_animal/slime/updatehealth(reason = "none given", should_log = FALSE)
	. = ..()
	update_movespeed_damage_modifiers()


/mob/living/simple_animal/slime/update_movespeed_damage_modifiers()
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		var/health_deficiency = (maxHealth - health)
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_health_mod, multiplicative_slowdown = mod)


/mob/living/simple_animal/slime/adjust_bodytemperature(amount, min_temp = 0, max_temp = INFINITY)
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1 // slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_temp_mod, multiplicative_slowdown = mod)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/slime_temp_mod)


/mob/living/simple_animal/slime/update_health_hud()
	if(hud_used)
		if(!client)
			return

		if(healths)
			var/severity = 0
			var/healthpercent = (health / maxHealth) * 100
			switch(healthpercent)
				if(100 to INFINITY)
					healths.icon_state = "slime_health0"
				if(80 to 100)
					healths.icon_state = "slime_health1"
					severity = 1
				if(60 to 80)
					healths.icon_state = "slime_health2"
					severity = 2
				if(40 to 60)
					healths.icon_state = "slime_health3"
					severity = 3
				if(20 to 40)
					healths.icon_state = "slime_health4"
					severity = 4
				if(1 to 20)
					healths.icon_state = "slime_health5"
					severity = 5
				else
					healths.icon_state = "slime_health7"
					severity = 6
			if(severity > 0)
				overlay_fullscreen("brute", /atom/movable/screen/fullscreen/brute, severity)
			else
				clear_fullscreen("brute")


/mob/living/simple_animal/slime/ObjBump(obj/object)
	if(client || Atkcool || powerlevel <= 0 || age_state.age == SLIME_BABY || nutrition > get_hunger_nutrition() || (istype(object, /obj/structure/window) && !istype(object, /obj/structure/grille)))
		return

	var/probab = 10
	switch(powerlevel)
		if(1 to 2)
			probab = 20
		if(3 to 4)
			probab = 30
		if(5 to 6)
			probab = 40
		if(7 to 8)
			probab = 60
		if(9)
			probab = 70
		if(10)
			probab = 95

	if(!prob(probab))
		return

	object.attack_slime(src)
	Atkcool = TRUE
	addtimer(VARSET_CALLBACK(src, Atkcool, FALSE), 4.5 SECONDS)


/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE

/mob/living/simple_animal/slime/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data

	if(!docile)
		status_tab_data[++status_tab_data.len] = list("Nutrition:", "[nutrition]/[get_max_nutrition()]")

	if(amount_grown >= age_state.amount_grown_for_split)
		status_tab_data[++status_tab_data.len] = list("You can:", "[age_state.stat_text][amount_grown >= age_state.amount_grown ? " [age_state.stat_text_evolve]" : ""]!")

	if(stat == UNCONSCIOUS)
		status_tab_data[++status_tab_data.len] = list("Power Level:", "You are knocked out by high levels of BZ!")
	else
		status_tab_data[++status_tab_data.len] = list("Power Level:", "[powerlevel]")


/mob/living/simple_animal/slime/adjustFireLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/bullet_act(obj/item/projectile/Proj)
	if(!Proj)
		return
	attacked += 10 - age_state.attacked
	if((Proj.damage_type == BURN))
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src)
	else
		..(Proj)
	return FALSE

/mob/living/simple_animal/slime/emp_act(severity)
	..()
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(isliving(over_object) && over_object != src && usr == src && CanFeedon(over_object))
		Feedon(over_object)
		return FALSE
	return ..()


/mob/living/simple_animal/slime/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	return


/mob/living/simple_animal/slime/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	return FALSE


/mob/living/simple_animal/slime/attack_ui(slot)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(buckled)
			Feedstop(silent = TRUE)
			visible_message("<span class='danger'>[M] pulls [src] off!</span>", \
				"<span class='danger'>You pull [src] off!</span>")
			return
		attacked += 5 - age_state.attacked
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + M.age_state.nutrition_steal))
			M.add_nutrition(50 + M.age_state.nutrition_steal)
		if(health > 0)
			M.adjustBruteLoss(-10 + (-M.age_state.damage * 2))


/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		attacked += 10 - age_state.attacked

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		attacked += 10 - age_state.attacked

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M)
	if(buckled)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(buckled == M)
			if(prob(60))
				M.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>", \
					"<span class='danger'>You attempt to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				M.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off!</span>", \
					"<span class='notice'>You manage to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)

		else
			if(prob(30))
				buckled.visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='warning'>[M] attempts to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)

			else
				buckled.visible_message("<span class='warning'>[M] manages to wrestle \the [name] off of [buckled]!</span>", \
					"<span class='notice'>[M] manage to wrestle \the [name] off of you!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)

				discipline_slime(M)
	else
		if(stat == DEAD && surgeries.len)
			if(M.a_intent == INTENT_HELP || M.a_intent == INTENT_DISARM)
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M, src))
						return 1
		if(..()) //successful attack
			attacked += 10 - age_state.attacked

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		attacked += 10 - age_state.attacked
		discipline_slime(M)


/mob/living/simple_animal/slime/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		if(I.force && prob(25))
			user.do_attack_animation(src)
			visible_message(span_danger("[I] passes right through [src]!"))
			playsound(loc, 'sound/effects/footstep/slime1.ogg', 50, TRUE, -1)
			return ATTACK_CHAIN_BLOCKED_ALL
		. = ..()
		if(!ATTACK_CHAIN_CANCEL_CHECK(.))
			discipline_on_attack(I.force, user)
		return .

	if(user.a_intent == INTENT_HELP && stat == DEAD && length(surgeries))
		for(var/datum/surgery/surgery as anything in surgeries)
			if(surgery.next_step(user, src))
				add_fingerprint(user)
				return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/mineral/plasma)) //Let's you feed slimes plasma.
		add_fingerprint(user)
		var/obj/item/stack/sheet/mineral/plasma/plasma = I
		if(stat != CONSCIOUS)
			to_chat(user, span_warning("[src] has problems with health."))
			return ATTACK_CHAIN_PROCEED
		if(!plasma.use(1))
			to_chat(user, span_warning("You don't have enough plasma to feed [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(user in Friends)
			Friends[user]++
		else
			Friends[user] = 1
			RegisterSignal(user, COMSIG_QDELETING, PROC_REF(clear_friend))
		user.visible_message(
			span_notice("[user] hand-feeds plasma to [src]. It chirps happily."),
			span_notice("You hand-feed plasma to [src]. It chirps happily."),
		)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(I.force && prob(25))
		user.do_attack_animation(src)
		visible_message(span_danger("[I] passes right through [src]!"))
		playsound(loc, 'sound/effects/footstep/slime1.ogg', 50, TRUE, -1)
		return ATTACK_CHAIN_BLOCKED_ALL

	. = ..()
	if(!ATTACK_CHAIN_CANCEL_CHECK(.))
		discipline_on_attack(I.force, user)


/mob/living/simple_animal/slime/proc/discipline_on_attack(force = 0, mob/user)
	attacked += 10 - age_state.attacked
	if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
		Discipline = 0
	if(force < 3)
		return
	var/force_effect = 2 * force
	if(age_state.age != SLIME_BABY)
		force_effect = round(force / 2)
	if(prob(10 + force_effect))
		discipline_slime(user)


/mob/living/simple_animal/slime/proc/clear_friend(mob/living/friend)
	UnregisterSignal(friend, COMSIG_QDELETING)
	Friends -= friend

/mob/living/simple_animal/slime/water_act(volume, temperature, source, method = REAGENT_TOUCH)
	. = ..()
	var/water_damage = (rand(10, 15) - age_state.attacked) * volume

	adjustBruteLoss(water_damage)
	if(!client && Target && volume >= 3) // Like cats
		Target = null
		++Discipline

/mob/living/simple_animal/slime/examine(mob/user)
	. = ..()
	. += "<span class='notice'>This is [bicon(src)] \a <EM>[src]</EM>!"
	if(stat == DEAD)
		. += "<span class='deadsay'>It is limp and unresponsive.</span>"
	else
		if(stat == UNCONSCIOUS) // Slime stasis
			. += "<span class='deadsay'>It appears to be alive but unresponsive.</span>"
		if(getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += "<span class='warning'>It is glowing brightly with high levels of electrical activity.</span>"

			if(10)
				. += "<span class='warning'><B>It is radiating with massive levels of electrical activity!</B></span>"

	. += "</span>"

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		Discipline++

		if(age_state.age == SLIME_BABY)
			if(Discipline == 1)
				attacked = 0

	if(Target)
		Target = null
	if(buckled)
		Feedstop(silent = TRUE) //we unbuckle the slime from the mob it latched onto.

	SStun = world.time + rand(20,60)
	spawn(0)
		ADD_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)
		if(user)
			step_away(src,user,15)
		sleep(3)
		if(user)
			step_away(src,user,15)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, SLIME_TRAIT)

/mob/living/simple_animal/slime/pet
	docile = TRUE


/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, age_state_new, new_set_nutrition)
	age_state_new = new /datum/slime_age/baby
	new_set_nutrition = 700
	if (prob(10))
		age_state_new = new /datum/slime_age/elder
		new_set_nutrition = 2000
	else if (prob(30))
		age_state_new = new /datum/slime_age/old
		new_set_nutrition = 1200
	else if (prob(50))
		age_state_new = new /datum/slime_age/adult
		new_set_nutrition = 900
	if (!new_colour)
		new_colour = pick(slime_colours)
	. = ..(mapload, new_colour, age_state_new, new_set_nutrition)

/mob/living/simple_animal/slime/adult/Initialize(mapload, new_colour, age_state_new, new_set_nutrition)
	. = ..(mapload, pick(slime_colours), age_state_new = new /datum/slime_age/adult, new_set_nutrition = 900)

/mob/living/simple_animal/slime/old/Initialize(mapload, new_colour, age_state_new, new_set_nutrition)
	. = ..(mapload, pick(slime_colours), age_state_new = new /datum/slime_age/old, new_set_nutrition = 1200)

/mob/living/simple_animal/slime/elder/Initialize(mapload, new_colour, age_state_new, new_set_nutrition)
	. = ..(mapload, pick(slime_colours), age_state_new = new /datum/slime_age/elder, new_set_nutrition = 2000)


/mob/living/simple_animal/slime/can_ventcrawl(obj/machinery/atmospherics/ventcrawl_target, provide_feedback = TRUE, entering = FALSE)
	if(buckled)
		if(provide_feedback)
			to_chat(src, span_warning("Вы не можете залезть в вентиляцию пока кормитесь!"))
		return FALSE
	return ..()


/mob/living/simple_animal/slime/invalid
	var/dead_for_sure = FALSE
	var/obj/effect/proc_holder/spell/slime_degradation/parent_spell
	var/mob/living/carbon/human/sman
	powerlevel = 10

/mob/living/simple_animal/slime/invalid/Initialize(mapload, new_colour = "grey", age_state_new = new /datum/slime_age/baby, new_set_nutrition = 700, mob/living/carbon/human/slimeman, obj/effect/proc_holder/spell/slime_degradation/slime_spell)
	..()
	for(var/datum/action/innate/slime/A in actions)
		if(!istype(A,/datum/action/innate/slime/feed))
			A.Remove(src)
	if(slimeman)
		sman = slimeman
	if(slime_spell)
		parent_spell = slime_spell
	remove_verb(src, /mob/living/simple_animal/slime/verb/Evolve)
	remove_verb(src, /mob/living/simple_animal/slime/verb/Reproduce)

/mob/living/simple_animal/slime/invalid/Destroy()
	parent_spell = null
	return ..()


/mob/living/simple_animal/slime/invalid/death(gibbed)
	if(dead_for_sure)
		return
	dead_for_sure = TRUE
	if(parent_spell)
		transform_back()
		return
	qdel(src)

/mob/living/simple_animal/slime/invalid/proc/transform_back()
	var/mob/living/carbon/human/our_slime = sman
	parent_spell.slime_transform_back(src, death_provoked = TRUE)
	our_slime.emote("moan")
	our_slime.Stun(5 SECONDS)
	our_slime.AdjustConfused(5 SECONDS)
	our_slime.Jitter(6 SECONDS)


