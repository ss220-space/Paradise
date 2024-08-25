//Revenants: based off of wraiths from Goon
//"Ghosts" that are invisible and move like ghosts, cannot take damage while invsible
//Don't hear deadchat and are NOT normal ghosts
//Admin-spawn or random event

#define INVISIBILITY_REVENANT 50
#define REVENANT_NAME_FILE "revenant_names.json"

/mob/living/simple_animal/revenant
	name = "revenant"
	desc = "A malevolent spirit."
	icon = 'icons/mob/mob.dmi'
	icon_state = "revenant_idle"
	var/icon_idle = "revenant_idle"
	var/icon_reveal = "revenant_revealed"
	var/icon_stun = "revenant_stun"
	var/icon_drain = "revenant_draining"
	incorporeal_move = INCORPOREAL_REVENANT
	see_invisible = INVISIBILITY_REVENANT
	invisibility = INVISIBILITY_REVENANT
	health =  INFINITY //Revenants don't use health, they use essence instead
	maxHealth =  INFINITY
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	universal_understand = 1
	response_help   = "passes through"
	response_disarm = "swings at"
	response_harm   = "punches"
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = INFINITY
	harm_intent_damage = 0
	friendly = "touches"
	status_flags = 0
	wander = 0
	density = FALSE
	move_resist = INFINITY
	mob_size = MOB_SIZE_TINY
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	speed = 1
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	tts_seed = "Sylvanas"

	var/essence = 75 //The resource of revenants. Max health is equal to three times this amount
	var/essence_regen_cap = 75 //The regeneration cap of essence (go figure); regenerates every Life() tick up to this amount.
	var/essence_regenerating = 1 //If the revenant regenerates essence or not; 1 for yes, 0 for no
	var/essence_regen_amount = 5 //How much essence regenerates
	var/essence_accumulated = 0 //How much essence the revenant has stolen
	var/revealed = 0 //If the revenant can take damage from normal sources.
	var/unreveal_time = 0 //How long the revenant is revealed for, is about 2 seconds times this var.
	var/unstun_time = 0 //How long the revenant is stunned for, is about 2 seconds times this var.
	var/inhibited = 0 //If the revenant's abilities are blocked by a chaplain's power.
	var/essence_drained = 0 //How much essence the revenant has drained.
	var/draining = 0 //If the revenant is draining someone.
	var/list/drained_mobs = list() //Cannot harvest the same mob twice
	var/perfectsouls = 0 //How many perfect, regen-cap increasing souls the revenant has.


/mob/living/simple_animal/revenant/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)
	AddElement(/datum/element/simple_flying)


/mob/living/simple_animal/revenant/Life(seconds, times_fired)
	..()
	if(revealed && essence <= 0)
		death()
	if(essence_regenerating && !inhibited && essence < essence_regen_cap) //While inhibited, essence will not regenerate
		essence = min(essence_regen_cap, essence+essence_regen_amount)
	if(unreveal_time && world.time >= unreveal_time)
		unreveal_time = 0
		revealed = 0
		incorporeal_move = INCORPOREAL_REVENANT
		invisibility = INVISIBILITY_REVENANT
		to_chat(src, "<span class='revenboldnotice'>You are once more concealed.</span>")
	if(unstun_time && world.time >= unstun_time)
		unstun_time = 0
		REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, REVENANT_TRAIT)
		to_chat(src, "<span class='revenboldnotice'>You can move again!</span>")
	update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/revenant/ex_act(severity)
	return 1 //Immune to the effects of explosions.

/mob/living/simple_animal/revenant/blob_act(obj/structure/blob/B)
	return //blah blah blobs aren't in tune with the spirit world, or something.

/mob/living/simple_animal/revenant/singularity_act()
	return //don't walk into the singularity expecting to find corpses, okay?

/mob/living/simple_animal/revenant/narsie_act()
	return //most humans will now be either bones or harvesters, but we're still un-alive.

/mob/living/simple_animal/revenant/ratvar_act()
	return

/mob/living/simple_animal/revenant/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE, jitter_time = 10 SECONDS, stutter_time = 6 SECONDS, stun_duration = 4 SECONDS)
	return FALSE //You are a ghost, atmos and grill makes sparks, and you make your own shocks with lights.


/mob/living/simple_animal/revenant/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = STATUS_UPDATE_NONE
	if(!revealed)
		return .
	essence = max(0, essence-amount)
	if(essence == 0)
		to_chat(src, "<span class='revendanger'>You feel your essence fraying!</span>")


/mob/living/simple_animal/revenant/say(message)
	if(!message)
		return

	add_say_logs(src, message)

	if(copytext(message, 1, 2) == "*")
		return emote(copytext(message, 2), intentional = TRUE)

	for(var/mob/M in GLOB.mob_list)
		var/rendered = "<span class='revennotice'><b>[src]</b> [(isobserver(M) ? ("([ghost_follow_link(src, ghost=M)])") : "")] says, \"[message]\"</span>"
		if(istype(M, /mob/living/simple_animal/revenant) || isobserver(M))
			to_chat(M, rendered)


/mob/living/simple_animal/revenant/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Current essence:", "[essence]/[essence_regen_cap]E")
	status_tab_data[++status_tab_data.len] = list("Stolen essence:", "[essence_accumulated]E")
	status_tab_data[++status_tab_data.len] = list("Stolen perfect souls:", "[perfectsouls]")

/mob/living/simple_animal/revenant/New()
	..()

	remove_from_all_data_huds()
	random_revenant_name()

	addtimer(CALLBACK(src, PROC_REF(firstSetupAttempt)), 15 SECONDS) // Give admin 15 seconds to put in a ghost (Or wait 15 seconds before giving it objectives)

/mob/living/simple_animal/revenant/proc/random_revenant_name()
	var/built_name = ""
	built_name += pick(strings(REVENANT_NAME_FILE, "spirit_type"))
	built_name += " of "
	built_name += pick(strings(REVENANT_NAME_FILE, "adjective"))
	built_name += pick(strings(REVENANT_NAME_FILE, "theme"))
	name = built_name

/mob/living/simple_animal/revenant/proc/firstSetupAttempt()
	if(mind)
		giveObjectivesandGoals()
		giveSpells()
	else
		message_admins("Revenant was created but has no mind. Put a ghost inside, or a poll will be made in one minute.")
		addtimer(CALLBACK(src, PROC_REF(setupOrDelete)), 1 MINUTES)

/mob/living/simple_animal/revenant/proc/setupOrDelete()
	if(mind)
		giveObjectivesandGoals()
		giveSpells()
	else
		var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Do you want to play as a revenant?", poll_time = 15 SECONDS, source = /mob/living/simple_animal/revenant)
		var/mob/dead/observer/theghost = null
		if(candidates.len)
			theghost = pick(candidates)
			key = theghost.key
			message_admins("[key_name_admin(src)] has taken control of a revenant created without a mind")
			giveObjectivesandGoals()
			giveSpells()
		else
			message_admins("No ghost was willing to take control of a mindless revenant. Deleting...")
			qdel(src)

/mob/living/simple_animal/revenant/proc/giveObjectivesandGoals()
			mind.wipe_memory()
			SEND_SOUND(src, 'sound/effects/ghost.ogg')
			var/list/messages = list()
			messages.Add("<span class='deadsay'><font size=3><b>You are a revenant.</b></font></span>")
			messages.Add("<b>Your formerly mundane spirit has been infused with alien energies and empowered into a revenant.</b>")
			messages.Add("<b>You are not dead, not alive, but somewhere in between. You are capable of limited interaction with both worlds.</b>")
			messages.Add("<b>You are invincible and invisible to everyone but other ghosts. Most abilities will reveal you, rendering you vulnerable.</b>")
			messages.Add("<b>To function, you are to drain the life essence from humans. This essence is a resource, as well as your health, and will power all of your abilities.</b>")
			messages.Add("<b><i>You do not remember anything of your past lives, nor will you remember anything about this one after your death.</i></b>")
			messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"https://wiki.ss220.space/index.php/Revenant\">Ревенант</a></span>")
			var/datum/objective/revenant/objective = new
			objective.owner = mind
			mind.objectives += objective
			var/datum/objective/revenantFluff/objective2 = new
			objective2.owner = mind
			mind.objectives += objective2
			SSticker.mode.traitors |= mind //Necessary for announcing
			messages.Add(mind.prepare_announce_objectives(FALSE))
			to_chat(src, chat_box_red(messages.Join("<br>")))

/mob/living/simple_animal/revenant/proc/giveSpells()
	mind.AddSpell(new /obj/effect/proc_holder/spell/night_vision/revenant(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/revenant_transmit(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/revenant/defile(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/revenant/malfunction(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/revenant/overload(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/revenant/haunt_object(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/revenant/hallucinations(null))
	return TRUE


/mob/living/simple_animal/revenant/dust()
	. = death()

/mob/living/simple_animal/revenant/gib()
	. = death()

/mob/living/simple_animal/revenant/death(gibbed)
	if(!revealed)
		return FALSE
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE

	to_chat(src, "<span class='revendanger'>NO! No... it's too late, you can feel your essence breaking apart...</span>")
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, REVENANT_TRAIT)
	revealed = 1
	invisibility = 0
	playsound(src, 'sound/effects/screech.ogg', 100, 1)
	visible_message("<span class='warning'>[src] lets out a waning screech as violet mist swirls around its dissolving body!</span>")
	update_icon(UPDATE_ICON_STATE)
	delayed_death()


/mob/living/simple_animal/revenant/proc/delayed_death()
	set waitfor = FALSE
	animate(src, alpha = 0, time = 2.5 SECONDS)
	sleep(2.5 SECONDS)
	if(QDELETED(src))
		return
	visible_message("<span class='danger'>[src]'s body breaks apart into a fine pile of blue dust.</span>")
	var/obj/item/ectoplasm/revenant/R = new (get_turf(src))
	var/reforming_essence = essence_regen_cap //retain the gained essence capacity
	R.essence = max(reforming_essence - 15 * perfectsouls, 75) //minus any perfect souls
	R.client_to_revive = src.client //If the essence reforms, the old revenant is put back in the body
	R.reforming = TRUE
	ghostize()
	qdel(src)


/mob/living/simple_animal/revenant/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/nullrod))
		visible_message(
			span_warning("[src] violently flinches!"),
			span_revendanger("As [I.name] passes through you, you feel your essence draining away!"),
		)
		apply_damage(25) //hella effective
		inhibited = TRUE
		addtimer(VARSET_CALLBACK(src, inhibited, FALSE), 3 SECONDS)
	return ..()


/mob/living/simple_animal/revenant/proc/castcheck(essence_cost)
	if(!src)
		return
	var/turf/T = get_turf(src)
	if(iswallturf(T))
		to_chat(src, "<span class='revenwarning'>You cannot use abilities from inside of a wall.</span>")
		return 0
	if(src.inhibited)
		to_chat(src, "<span class='revenwarning'>Your powers have been suppressed by nulling energy!</span>")
		return 0
	if(!src.change_essence_amount(essence_cost, 1))
		to_chat(src, "<span class='revenwarning'>You lack the essence to use that ability.</span>")
		return 0
	return 1

/mob/living/simple_animal/revenant/proc/change_essence_amount(essence_amt, silent = 0, source = null)
	if(!src)
		return
	if(essence + essence_amt <= 0)
		return
	essence = max(0, essence+essence_amt)
	if(essence_amt > 0)
		essence_accumulated = max(0, essence_accumulated+essence_amt)
	if(!silent)
		if(essence_amt > 0)
			to_chat(src, "<span class='revennotice'>Gained [essence_amt]E from [source].</span>")
		else
			to_chat(src, "<span class='revenminor'>Lost [essence_amt]E from [source].</span>")
	return 1

/mob/living/simple_animal/revenant/proc/reveal(time)
	if(!src)
		return
	if(time <= 0)
		return
	revealed = 1
	invisibility = 0
	incorporeal_move = INCORPOREAL_NONE
	if(!unreveal_time)
		to_chat(src, "<span class='revendanger'>You have been revealed!</span>")
		unreveal_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You have been revealed!</span>")
		unreveal_time = unreveal_time + time
	update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/revenant/proc/stun(time)
	if(!src)
		return
	if(time <= 0)
		return
	ADD_TRAIT(src, TRAIT_NO_TRANSFORM, REVENANT_TRAIT)
	if(!unstun_time)
		to_chat(src, "<span class='revendanger'>You cannot move!</span>")
		unstun_time = world.time + time
	else
		to_chat(src, "<span class='revenwarning'>You cannot move!</span>")
		unstun_time = unstun_time + time
	update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/revenant/update_icon_state()
	if(revealed)
		if(HAS_TRAIT_FROM(src, TRAIT_NO_TRANSFORM, REVENANT_TRAIT))
			if(draining)
				icon_state = icon_drain
			else
				icon_state = icon_stun
		else
			icon_state = icon_reveal
	else
		icon_state = icon_idle


/datum/objective/revenant
	needs_target = FALSE
	var/targetAmount = 100


/datum/objective/revenant/New()
	targetAmount = rand(350,600)
	explanation_text = "Absorb [targetAmount] points of essence from humans."
	..()


/datum/objective/revenant/check_completion()
	var/total_essence = 0

	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/revenant) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/revenant/revenant = player.current
		total_essence += revenant.essence_accumulated

	if(total_essence < targetAmount)
		return FALSE

	return TRUE


/datum/objective/revenantFluff
	needs_target = FALSE



/datum/objective/revenantFluff/New()
	var/list/explanationTexts = list("Assist and exacerbate existing threats at critical moments.", \
									 "Cause as much chaos and anger as you can without being killed.", \
									 "Damage and render as much of the station rusted and unusable as possible.", \
									 "Disable and cause malfunctions in as many machines as possible.", \
									 "Ensure that any holy weapons are rendered unusable.", \
									 "Hinder the crew while attempting to avoid being noticed.", \
									 "Make the crew as miserable as possible.", \
									 "Make the clown as miserable as possible.", \
									 "Make the captain as miserable as possible.", \
									 "Make the AI as miserable as possible.", \
									 "Annoy the ones that insult you the most.", \
									 "Whisper ghost jokes into peoples heads.", \
									 "Help the crew in critical situations, but take your payments in souls.", \
									 "Prevent the use of energy weapons where possible.")
	explanation_text = pick(explanationTexts)
	..()


/datum/objective/revenantFluff/check_completion()
	return TRUE


/obj/item/ectoplasm/revenant
	name = "glimmering residue"
	desc = "A pile of fine blue dust. Small tendrils of violet mist swirl around it."
	icon = 'icons/effects/effects.dmi'
	icon_state = "revenantEctoplasm"
	w_class = WEIGHT_CLASS_SMALL
	var/reforming = FALSE
	var/reform_time = 60 SECONDS
	var/essence = 75 //the maximum essence of the reforming revenant
	var/inert = FALSE
	var/client/client_to_revive


/obj/item/ectoplasm/revenant/New()
	..()
	addtimer(CALLBACK(src, PROC_REF(reform)), reform_time)


/obj/item/ectoplasm/revenant/Destroy()
	client_to_revive = null
	return ..()


/obj/item/ectoplasm/revenant/attack_self(mob/user)
	if(!reforming || inert)
		return ..()
	user.visible_message(span_notice("[user] scatters [src] in all directions."), \
						 span_notice("You scatter [src] across the area. The particles slowly fade away."))
	user.drop_from_active_hand()
	qdel(src)


/obj/item/ectoplasm/revenant/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..()
	if(inert)
		return
	visible_message(span_notice("[src] breaks into particles upon impact, which fade away to nothingness."))
	qdel(src)


/obj/item/ectoplasm/revenant/examine(mob/user)
	. = ..()
	if(inert)
		. += span_revennotice("It seems inert.")
	else if(reforming)
		. += span_revenwarning("It is shifting and distorted. It would be wise to destroy this.")


/obj/item/ectoplasm/revenant/proc/reform()
	if(QDELETED(src))
		return

	if(!reforming)
		inert = TRUE
		visible_message(span_warning("[src] settles down and seems lifeless."))
		return

	var/key_of_revenant
	message_admins("Revenant ectoplasm was left undestroyed for [reform_time/10] seconds and is reforming into a new revenant.")
	forceMove_turf() //In case it's in a backpack or someone's hand
	var/mob/living/simple_animal/revenant/new_revenant = new(get_turf(src))

	if(client_to_revive)
		for(var/mob/ghost in GLOB.dead_mob_list)
			if(ghost.client == client_to_revive) //Only recreates the mob if the mob the client is in is dead
				new_revenant.client = client_to_revive
				key_of_revenant = client_to_revive.key


	if(!key_of_revenant)
		message_admins("The new revenant's old client either could not be found or is in a new, living mob - grabbing a random candidate instead...")
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a revenant?", ROLE_REVENANT, TRUE, source = /mob/living/simple_animal/revenant)

		if(length(candidates))
			var/mob/new_owner = pick(candidates)
			key_of_revenant = new_owner.key

	if(!key_of_revenant)
		qdel(new_revenant)
		inert = TRUE
		visible_message(span_revenwarning("[src] settles down and seems lifeless."))
		message_admins("No candidates were found for the new revenant. Oh well!")
		return

	if(QDELETED(src))	// in case it was destroyed during the vote
		message_admins("Revenant ectoplasm was destroyed during the ghost poll.")
		return

	var/datum/mind/player_mind = new(key_of_revenant)
	player_mind.active = TRUE
	player_mind.assigned_role = SPECIAL_ROLE_REVENANT
	player_mind.special_role = SPECIAL_ROLE_REVENANT
	SSticker.mode.traitors |= player_mind
	player_mind.current = new_revenant
	new_revenant.essence = essence
	new_revenant.mind = player_mind
	new_revenant.key = player_mind.key

	visible_message(span_revenboldnotice("[src] suddenly rises into the air before fading away."))
	message_admins("[key_name_admin(new_revenant)] has been [client_to_revive ? "re":""]made into a revenant by reforming ectoplasm.")
	add_game_logs("was [client_to_revive ? "re":""]made as a revenant by reforming ectoplasm.", new_revenant)

	qdel(src)

