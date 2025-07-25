// The rune carver, a heretic knife that can draw rune traps.
/obj/item/melee/rune_carver
	name = "разделочный нож"
	ru_names = list(
		NOMINATIVE = "разделочный нож",
		GENITIVE = "разделочного ножа",
		DATIVE = "разделочному ножу",
		ACCUSATIVE = "разделочный нож",
		INSTRUMENTAL = "разделочным ножом",
		PREPOSITIONAL = "разделочном ноже",
	)
	desc = "Небольшой нож из холодной стали, чистый и совершенный. Его острота может прорезать даже титан - \
			но лишь немногие способны пробудить опасности, таящиеся под реальностью."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "rune_carver"
	sharp = TRUE
	w_class = WEIGHT_CLASS_SMALL
	//wound_bonus = 20
	force = 10
	throwforce = 20
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("атакует", "рубит", "режет", "раздирает", "терзает", "распарывает", "нарезает", "бьет")
	actions_types = list(/datum/action/item_action/rune_shatter)
	embed_chance = 75
	embedded_pain_multiplier = 3

	/// Whether we're currently drawing a rune
	var/drawing = FALSE
	/// Max amount of runes that can be drawn
	var/max_rune_amt = 3
	/// A list of weakrefs to all of ourc urrent runes
	var/list/datum/weakref/current_runes = list()
	/// Turfs that you cannot draw carvings on
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/space, /turf/space/openspace, /turf/simulated/floor/lava, /turf/simulated/floor/chasm))

/*
/datum/embedding/rune_carver
	ignore_throwspeed_threshold = TRUE
	embed_chance = 75
	jostle_chance = 2
	jostle_pain_mult = 5
	pain_stam_pct = 0.4
	pain_mult = 3
	rip_time = 1.5 SECONDS
*/

/obj/item/melee/rune_carver/examine(mob/user)
	. = ..()
	if(!IS_HERETIC_OR_MONSTER(user) && !isobserver(user))
		return

	. += span_notice("Было вырезанно рун: <b>[length(current_runes)] / [max_rune_amt]</b>")
	. += span_notice("Руны которые можно вырезать:")
	for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
		var/potion_string = span_notice(initial(trap.name) + " - " + initial(trap.carver_tip))
		. += potion_string


/obj/item/melee/rune_carver/afterattack(atom/target, mob/user, proximity, params)
	if(!IS_HERETIC_OR_MONSTER(user))
		return

	if(iswallturf(target) || is_type_in_typecache(target, blacklisted_turfs) || ismob(target))
		return

	INVOKE_ASYNC(src, PROC_REF(try_carve_rune), target, user)
	return


/*
 * Begin trying to carve a rune. Go through a few checks, then call do_carve_rune if successful.
 */
/obj/item/melee/rune_carver/proc/try_carve_rune(turf/space/target_turf, mob/user)
	if(drawing)
		target_turf.balloon_alert(user, "черчение идет!")
		return

	if(locate(/obj/structure/trap/eldritch) in range(1, target_turf))
		target_turf.balloon_alert(user, "рядом другая руна!")
		return

	for(var/datum/weakref/rune_ref as anything in current_runes)
		if(!rune_ref?.resolve())
			current_runes -= rune_ref

	if(length(current_runes) >= max_rune_amt)
		target_turf.balloon_alert(user, "лимит рун!")
		return

	drawing = TRUE
	do_carve_rune(target_turf, user)
	drawing = FALSE


/*
 * The actual proc that handles selecting the rune to draw and creating it.
 */
/obj/item/melee/rune_carver/proc/do_carve_rune(turf/space/target_turf, mob/user)
	// Assoc list of [name] to [image] for the radial (to show tooltips)
	var/static/list/choices = list()
	// Assoc list of [name] to [path] for after the radial
	var/static/list/names_to_path = list()
	if(!choices.len || !names_to_path.len)
		for(var/obj/structure/trap/eldritch/trap as anything in subtypesof(/obj/structure/trap/eldritch))
			names_to_path[initial(trap.name)] = trap
			choices[initial(trap.name)] = image(icon = initial(trap.icon), icon_state = initial(trap.icon_state))

	var/picked_choice = show_radial_menu(
		user,
		target_turf,
		choices,
		require_near = TRUE,
		//tooltips = TRUE,
	)

	if(isnull(picked_choice))
		return

	var/to_make = names_to_path[picked_choice]
	if(!ispath(to_make, /obj/structure/trap/eldritch))
		CRASH("[type] attempted to create a rune of incorrect type! (got: [to_make])")

	target_turf.balloon_alert(user, "черчение [picked_choice]...")
	user.playsound_local(target_turf, 'sound/items/sheath.ogg', 50, TRUE)
	if(!do_after(user, 5 SECONDS, target = target_turf))
		target_turf.balloon_alert(user, "прервано!")
		return

	target_turf.balloon_alert(user, "[picked_choice] начерчена")
	var/obj/structure/trap/eldritch/new_rune = new to_make(target_turf, user)
	current_runes += WEAKREF(new_rune)


/datum/action/item_action/rune_shatter
	name = "Разрушить руны"
	desc = "Уничтожает все руны, вырезанные этим клинком."
	background_icon_state = "bg_heretic"
	//overlay_icon_state = "bg_heretic_border"
	button_icon_state = "rune_break"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'


/datum/action/item_action/rune_shatter/New(Target)
	. = ..()
	if(istype(Target, /obj/item/melee/rune_carver))
		return

	qdel(src)
	return


/datum/action/item_action/rune_shatter/Grant(mob/granted)
	if(!IS_HERETIC_OR_MONSTER(granted))
		return

	return ..()


/datum/action/item_action/rune_shatter/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return

	if(!IS_HERETIC_OR_MONSTER(owner))
		return FALSE

	var/obj/item/melee/rune_carver/target_sword = target
	if(!length(target_sword.current_runes))
		return FALSE


/datum/action/item_action/rune_shatter/do_effect(trigger_flags, left_click = TRUE)
	owner.playsound_local(get_turf(owner), 'sound/magic/blind.ogg', 50, TRUE)
	var/obj/item/melee/rune_carver/target_sword = target
	QDEL_LIST(target_sword.current_runes)
	target_sword.SpinAnimation(5, 1)
	return TRUE


// The actual rune traps the knife draws.
/obj/structure/trap/eldritch
	name = "древние письмена"
	ru_names = list(
		NOMINATIVE = "древние письмена",
		GENITIVE = "древних символов", // "древних письмен" sounds bad
		DATIVE = "древним письменм",
		ACCUSATIVE = "древние письмена",
		INSTRUMENTAL = "древними письменами",
		PREPOSITIONAL = "древних письменах",
	)
	desc = "Множество неизвестных символов, они напоминают вам о давно минувших днях..."
	gender = PLURAL
	icon = 'icons/obj/hand_of_god_structures.dmi'
	max_integrity = 60
	/// A tip displayed to heretics who examine the rune carver. Explains what the rune does.
	var/carver_tip
	/// Reference to trap owner mob
	var/datum/weakref/owner


/obj/structure/trap/eldritch/Initialize(mapload, new_owner)
	. = ..()
	if(!new_owner)
		return

	owner = WEAKREF(new_owner)


/obj/structure/trap/eldritch/on_entered(datum/source, atom/movable/entering_atom)
	if(!isliving(entering_atom))
		return

	var/mob/living/living_mob = entering_atom
	if(WEAKREF(living_mob) == owner)
		return

	if(IS_HERETIC_OR_MONSTER(living_mob))
		return

	return ..()


/obj/structure/trap/eldritch/attackby(obj/item/tool, mob/user, params)
	if(!istype(tool, /obj/item/melee/rune_carver) && !istype(tool, /obj/item/nullrod))
		return ..()

	loc.balloon_alert(user, "руна убрана")
	playsound(src, 'sound/items/sheath.ogg', 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, ignore_walls = FALSE)
	qdel(src)
	return ATTACK_CHAIN_SUCCESS


/obj/structure/trap/eldritch/alert
	name = "руна предупреждения"
	ru_names = list(
		NOMINATIVE = "руна предупреждения",
		GENITIVE = "руны предупреждения",
		DATIVE = "руне предупреждения",
		ACCUSATIVE = "руну предупреждения",
		INSTRUMENTAL = "руной предупреждения",
		PREPOSITIONAL = "руне предупреждения",
	)
	gender = FEMALE
	icon_state = "alert_rune"
	alpha = 10
	time_between_triggers = 5 SECONDS
	sparks = FALSE
	carver_tip = "Почти невидимая руна, которая, оповещает создавшего ее о том, кто и где на нее наступил."


/obj/structure/trap/eldritch/alert/trap_effect(mob/living/victim)
	var/mob/living/real_owner = owner?.resolve()
	if(!real_owner)
		return

	to_chat(real_owner, span_userdanger("[victim.real_name] наступил[genderize_ru(victim.gender, "", "а", "о", "и")] на [declent_ru(ACCUSATIVE)] в [get_area(src)]!"))
	real_owner.playsound_local(get_turf(real_owner), 'sound/magic/curse.ogg', 50, TRUE)


/obj/structure/trap/eldritch/tentacle
	name = "руна удержания"
	ru_names = list(
		NOMINATIVE = "руна удержания",
		GENITIVE = "руны удержания",
		DATIVE = "руне удержания",
		ACCUSATIVE = "руну удержания",
		INSTRUMENTAL = "руной удержания",
		PREPOSITIONAL = "руне удержания",
	)
	gender = FEMALE
	icon_state = "tentacle_rune"
	time_between_triggers = 45 SECONDS
	charges = 1
	carver_tip = "При наступании наносит значительные повреждения ногам и оглушает жертву на 5 секунд. Имеет 1 заряд."


/obj/structure/trap/eldritch/tentacle/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return

	var/mob/living/carbon/human/human_victim = victim
	human_victim.Paralyse(5 SECONDS)
	human_victim.apply_damage(20, BRUTE, BODY_ZONE_R_LEG)
	human_victim.apply_damage(20, BRUTE, BODY_ZONE_L_LEG)
	playsound(src, 'sound/magic/demon_attack1.ogg', 75, TRUE)


/obj/structure/trap/eldritch/mad
	name = "руна безумия"
	ru_names = list(
		NOMINATIVE = "руна безумия",
		GENITIVE = "руны безумия",
		DATIVE = "руне безумия",
		ACCUSATIVE = "руну безумия",
		INSTRUMENTAL = "руной безумия",
		PREPOSITIONAL = "руне безумия",
	)
	gender = FEMALE
	icon_state = "madness_rune"
	time_between_triggers = 20 SECONDS
	charges = 2
	carver_tip = "При наступании, наносит жертве сильный урон выносливости, слепоту и дает различные недуги. Имеет 2 заряда."


/obj/structure/trap/eldritch/mad/trap_effect(mob/living/victim)
	if(!iscarbon(victim))
		return

	var/mob/living/carbon/human/human_victim = victim
	human_victim.adjustStaminaLoss(80)
	human_victim.Silence(20 SECONDS)
	human_victim.Stuttering(1 MINUTES)
	human_victim.Confused(5 SECONDS)
	human_victim.Jitter(20 SECONDS)
	human_victim.Dizzy(40 SECONDS)
	human_victim.AdjustEyeBlind(4 SECONDS)
	playsound(src, 'sound/magic/blind.ogg', 75, TRUE)
