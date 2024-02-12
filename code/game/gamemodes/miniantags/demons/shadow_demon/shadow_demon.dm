/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	desc = "A creature that's barely tangible, you can feel its gaze piercing you"
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	speed = 0
	maxHealth = 300
	health = 300
	move_resist = MOVE_FORCE_STRONG
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE // so they can tell where the darkness is
	loot = list(/obj/item/organ/internal/heart/demon/shadow)
	var/thrown_alert = FALSE
	var/wrapping = FALSE
	var/list/wrapped_victims


/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)
	var/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/crawl = new
	AddSpell(crawl)
	whisper_action.button_icon_state = "shadow_whisper"
	whisper_action.background_icon_state = "shadow_demon_bg"
	if(istype(loc, /obj/effect/dummy/slaughter))
		crawl.phased = TRUE
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/demon/shadow, check_darkness))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_darkness))
	add_overlay(emissive_appearance(icon, "shadow_demon_eye_glow_overlay"))


/mob/living/simple_animal/demon/shadow/Life(seconds, times_fired)
	. = ..()
	var/lum_count = check_darkness()
	var/damage_mod = istype(loc, /obj/effect/dummy/slaughter) ? 0.5 : 1
	if(lum_count > 0.2)
		adjustBruteLoss(30 * damage_mod) // 20 seconds in light and you are done
		SEND_SOUND(src, sound('sound/weapons/sear.ogg'))
		to_chat(src, span_dangerbigger("The light scalds you!"))
	else
		adjustBruteLoss(-30)


/mob/living/simple_animal/demon/shadow/proc/check_darkness()
	var/turf/source_turf = get_turf(src)
	var/lum_count = source_turf.get_lumcount()
	if(lum_count > 0.2)
		if(!thrown_alert)
			thrown_alert = TRUE
			throw_alert("light", /obj/screen/alert/lightexposure)
		animate(src, alpha = 255, time = 0.5 SECONDS)
		speed = initial(speed)
	else
		if(thrown_alert)
			thrown_alert = FALSE
			clear_alert("light")
		animate(src, alpha = 125, time = 0.5 SECONDS)
		speed = -0.3
	return lum_count


/mob/living/simple_animal/demon/shadow/UnarmedAttack(atom/target)
	if(!ishuman(target))
		if(isitem(target))
			target.extinguish_light(TRUE)
		return ..()

	var/mob/living/carbon/human/h_target = target
	if(h_target.stat != DEAD)
		return ..()

	if(isLivingSSD(h_target) && client.send_ssd_warning(h_target)) //Similar to revenants, only wrap SSD targets if you've accepted the SSD warning
		return

	if(wrapping)
		to_chat(src, span_notice("We are already wrapping something."))
		return

	visible_message(span_danger("[src] begins wrapping [h_target] in shadowy threads."))
	wrapping = TRUE
	if(!do_after(src, 4 SECONDS, FALSE, target = h_target))
		wrapping = FALSE
		return

	h_target.visible_message(span_warning("<b>[src] envelops [h_target] into an ethereal cocoon, and darkness begins to creep from it.</b>"))
	var/obj/structure/shadowcocoon/cocoon = new(get_turf(h_target))
	h_target.extinguish_light(TRUE) // may as well be safe
	h_target.forceMove(cocoon)
	wrapping = FALSE

	if(!h_target.mind)
		return

	if(!wrapped_victims)
		wrapped_victims = list()
	var/human_UID = h_target.UID()
	if(!(human_UID in wrapped_victims))
		wrapped_victims += human_UID


/obj/structure/shadowcocoon
	name = "shadowy cocoon"
	desc = "Something wrapped in what seems to be manifested darkness. Its surface distorts unnaturally, and it emanates deep shadows."
	icon = 'icons/effects/effects.dmi'
	icon_state = "shadowcocoon"
	light_power = -4
	light_range = 6
	max_integrity = 100
	light_color = "#ddd6cf"
	anchored = TRUE
	/// Amount of SSobj ticks (Roughly 2 seconds) since the last hallucination proc'd
	var/time_since_last_hallucination = 0
	/// Will we play hallucination sounds or not
	var/silent = TRUE


/obj/structure/shadowcocoon/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)


/obj/structure/shadowcocoon/process()
	time_since_last_hallucination++
	for(var/atom/to_darken in range(4, src))
		if(prob(60) || !length(to_darken.light_sources))
			continue
		if(iswelder(to_darken) && length(to_darken.light_sources))
			to_darken.visible_message(span_notice("The shadows swarm around and overwhelm the flame of [to_darken]."))
		to_darken.extinguish_light(TRUE)
	if(!silent && time_since_last_hallucination >= rand(8, 12))
		playsound(src, pick('sound/items/deconstruct.ogg', 'sound/weapons/handcuffs.ogg', 'sound/machines/airlock_open.ogg',  'sound/machines/airlock_close.ogg', 'sound/machines/boltsup.ogg', 'sound/effects/eleczap.ogg', get_sfx("bodyfall"), get_sfx("gunshot"), 'sound/weapons/egloves.ogg'), 50)
		time_since_last_hallucination = 0


/obj/structure/shadowcocoon/AltClick(mob/user)
	if(!isdemon(user))
		return ..()
	if(silent)
		to_chat(user, span_notice("You twist and change your trapped victim in [src] to lure in more prey."))
		silent = FALSE
		return
	to_chat(user, span_notice("The tendrils from [src] snap back to their orignal form."))
	silent = TRUE


/obj/structure/shadowcocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	if(damage_type != BURN) //I unashamedly stole this from spider cocoon code
		return
	playsound(loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/structure/shadowcocoon/obj_destruction()
	visible_message(span_danger("[src] splits open, and the shadows dancing around it fade."))
	return ..()


/obj/structure/shadowcocoon/Destroy()
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)
	return..()


/mob/living/simple_animal/demon/shadow/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isliving(AM)) // when a living creature is thrown at it, dont knock it back
		return
	..()


/obj/effect/proc_holder/spell/fireball/shadow_grapple
	name = "Shadow Grapple"
	desc = "Fire one of your hands, if it hits a person it pulls them in. If you hit a structure you get pulled to the structure."
	panel = "Demon"
	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_grapple"
	invocation_type = "none"
	invocation = null
	sound = null
	need_active_overlay = TRUE
	human_req = FALSE
	selection_activated_message = span_notice("You raise your hand, full of demonic energy! <b>Left-click to cast at a target!</b>")
	selection_deactivated_message = span_notice("You re-absorb the energy...for now.")
	base_cooldown = 10 SECONDS
	fireball_type = /obj/item/projectile/magic/shadow_hand


/obj/effect/proc_holder/spell/fireball/shadow_grapple/update_icon_state()
	return


/obj/item/projectile/magic/shadow_hand
	name = "shadow hand"
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE
	speed = 1
	var/hit = FALSE


/obj/item/projectile/magic/shadow_hand/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1, beam_type = /obj/effect/ebeam/floor)
	return ..()


/obj/item/projectile/magic/shadow_hand/on_hit(atom/target, blocked, hit_zone)
	if(hit)
		return
	hit = TRUE // to prevent double hits from the pull
	. = ..()
	for(var/atom/extinguish_target in range(2, src))
		extinguish_target.extinguish_light(TRUE)
	if(isliving(target))
		var/mob/living/l_target = target
		l_target.Immobilize(4 SECONDS)
		l_target.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		l_target.throw_at(get_step(firer, get_dir(firer, target)), 50, 10)
	else
		firer.throw_at(get_step(target, get_dir(target, firer)), 50, 10)


/obj/effect/ebeam/floor
	plane = FLOOR_PLANE


/obj/item/organ/internal/heart/demon/shadow
	name = "heart of darkness"
	desc = "It still beats furiously, emitting an aura of fear."
	color = COLOR_BLACK


/obj/item/organ/internal/heart/demon/shadow/attack_self(mob/living/user)
	. = ..()
	user.drop_from_active_hand()
	insert(user)


/obj/item/organ/internal/heart/demon/shadow/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M?.mind?.AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)


/obj/item/organ/internal/heart/demon/shadow/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M?.mind?.RemoveSpell(/obj/effect/proc_holder/spell/fireball/shadow_grapple)
	. = ..()


/mob/living/simple_animal/demon/shadow/attempt_objectives()
	if(!..())
		return

	var/list/messages = list()
	messages.Add("<b><font size=3 color='red'>You are a Shadow Demon.</font><br></b>")
	messages.Add("<B>You are a terrible creature from another existence. You have only two desires to survive and to lurk and ambush careless preys.</B>")
	messages.Add("<B>You may use the Shadow Crawl ability when near the dark spots, appearing and dissapearing from the station at will.</B>")
	messages.Add("<B>Your Shadow Grapple ability allows you to pull living preys or to push yourself to the other objects. Also extinguishes all light sources at the area of impact.</B>")
	messages.Add("<B>You can wrap dead humanoid bodies by attacking them, use Alt+Click on the shadow cocoon afterwards to lure more victims.</B>")
	messages.Add("<B>You move quickly and regenerate fast in the shadows, but any light source will hurt you to the death. STAY AWAY FROM THE LIGHT! </B>")
	messages.Add(span_notice("<B>You are not currently in the same plane of existence as the station. Use the shadow crawl action near any dark spot.</B>"))
	messages.Add("<span class='motd'>С полной информацией вы можете ознакомиться на вики: <a href=\"https://wiki.ss220.space/index.php/Shadow_Demon\">Теневой демон</a></span>")
	src << 'sound/misc/demon_dies.ogg'
	if(vialspawned)
		return

	var/datum/objective/wrap/wrap_objective = new
	var/datum/objective/survive/survive_objective = new
	wrap_objective.owner = mind
	survive_objective.owner = mind
	mind.objectives += wrap_objective
	mind.objectives += survive_objective
	messages.Add(mind.prepare_announce_objectives())
	to_chat(src, chat_box_red(messages.Join("<br>")))


/datum/objective/wrap
	name = "Wrap"
	needs_target = FALSE
	target_amount = 10


/datum/objective/wrap/New(text, datum/team/team_to_join)
	target_amount = rand(10,20)
	explanation_text = "Ambush those who dare to challenge the shadows. Wrap at least [target_amount] mortals."
	..()


/datum/objective/wrap/check_completion()
	var/wrap_count = 0
	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/demon/shadow) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/demon/shadow/demon = player.current
		if(!demon.wrapped_victims || !length(demon.wrapped_victims))
			continue

		wrap_count += length(demon.wrapped_victims)

	return wrap_count >= target_amount

