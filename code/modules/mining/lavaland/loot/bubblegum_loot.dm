/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"
	ru_names = list(
		NOMINATIVE = "сундук Бубльгума",
		GENITIVE = "сундука Бубльгума",
		DATIVE = "сундуку Бубльгума",
		ACCUSATIVE = "сундук Бубльгума",
		INSTRUMENTAL = "сундуком Бубльгума",
		PREPOSITIONAL = "сундуке Бубльгума"
	)

/obj/structure/closet/crate/necropolis/bubblegum/populate_contents()
	new /obj/item/clothing/suit/space/hostile_environment(src)
	new /obj/item/clothing/head/helmet/space/hostile_environment(src)
	new /obj/item/gem/bloodstone(src)
	new /obj/item/soulscythe(src)

/obj/structure/closet/crate/necropolis/bubblegum/crusher
	name = "bloody bubblegum chest"
	ru_names = list(
		NOMINATIVE = "кровавый сундук Бубльгума",
		GENITIVE = "кровавого сундука Бубльгума",
		DATIVE = "кровавому сундуку Бубльгума",
		ACCUSATIVE = "кровавый сундук Бубльгума",
		INSTRUMENTAL = "кровавым сундуком Бубльгума",
		PREPOSITIONAL = "кровавом сундуке Бубльгума"
	)

/obj/structure/closet/crate/necropolis/bubblegum/crusher/populate_contents()
	. = ..()
	new /obj/item/crusher_trophy/demon_claws(src)

// Mayhem

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "Зачарованная бутыль с кровью, чей аромат повергает всех вокруг в убийственное безумие."
	ru_names = list(
		NOMINATIVE = "бутылка хаоса",
		GENITIVE = "бутылки хаоса",
		DATIVE = "бутылке хаоса",
		ACCUSATIVE = "бутылку хаоса",
		INSTRUMENTAL = "бутылкой хаоса",
		PREPOSITIONAL = "бутылке хаоса"
	)
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(H)
			B.mineEffect(H)
	to_chat(user, span_notice("Вы разбиваете бутылку!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, TRUE)
	qdel(src)

// Blood Contract

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Отметьте цель для смертной казни."
	ru_names = list(
		NOMINATIVE = "кровавый контракт",
		GENITIVE = "кровавого контракта",
		DATIVE = "кровавому контракту",
		ACCUSATIVE = "кровавый контракт",
		INSTRUMENTAL = "кровавым контрактом",
		PREPOSITIONAL = "кровавом контракте"
	)
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return

	used = TRUE
	var/choice = tgui_input_list(user, "Кого вы желаете уничтожить?", "Выбор жертвы", GLOB.player_list)

	if(!choice)
		used = FALSE
		return
	else if(!isliving(choice))
		to_chat(user, "[choice] уже мертв!")
		used = FALSE
		return
	else if(choice == user)
		to_chat(user, "Писать собственное имя в проклятый смертный приказ было бы неразумно.")
		used = FALSE
		return
	else
		var/mob/living/L = choice

		message_admins("[key_name_admin(L)] has been marked for death by [key_name_admin(user)].")
		log_admin("[key_name(L)] has been marked for death by [key_name(user)].")

		var/datum/objective/survive/survive = new
		survive.owner = L.mind
		L.mind.objectives += survive
		to_chat(L, span_userdanger("Вы обречены на смерть! Не дайте демонам добраться до вас!"))
		L.color = "#FF0000"
		spawn()
			var/obj/effect/mine/pickup/bloodbath/B = new(L)
			B.mineEffect(L)

		for(var/mob/living/carbon/human/H in GLOB.player_list)
			if(H.stat == DEAD || H == L)
				continue
			to_chat(H, span_userdanger("Вы испытываете непреодолимое желание убить [L]. [genderize_ru(L.gender,"Он","Она","Оно","Они")] помечен[genderize_ru(L.gender,"","а","о","ы")] красным! УБЕЙТЕ [genderize_ru(L.gender,"ЕГО","ЕЁ","ЕГО","ИХ")]!"))
			H.put_in_hands(new /obj/item/kitchen/knife/butcher(H))

	qdel(src)

//hard-mode

/obj/structure/closet/crate/necropolis/bubblegum/bait/populate_contents()
	return

/obj/effect/bubblegum_trigger
	var/list/targets_to_fuck_up = list()

/obj/effect/bubblegum_trigger/Initialize(mapload, target_list)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 15 SECONDS) //We try to auto engage the fun 15 seconds after death.
	targets_to_fuck_up = target_list

/obj/effect/bubblegum_trigger/proc/activate()
	if(!length(targets_to_fuck_up))
		return
	var/spawn_locs = list()
	for(var/obj/effect/landmark/spawner/bubblegum_arena/R in GLOB.landmarks_list)
		spawn_locs += get_turf(R)
	for(var/mob/living/M in targets_to_fuck_up)
		var/turf/T = get_turf(M)
		M.Immobilize(1 SECONDS)
		to_chat(M, span_colossus("<b>НЕТ! Я НЕ ПОЗВОЛЮ ТЕБЕ ДУМАТЬ, ЧТО ТЫ ПОБЕДИЛ! Я ПОЛОЖУ КОНЕЦ ТВОЕЙ ЖАЛКОЙ ЖИЗНИ!</b>"))
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
		sleep(8)
		playsound(T, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
		var/turf/target_turf = pick(spawn_locs)
		M.forceMove(target_turf)
		playsound(target_turf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	for(var/obj/effect/landmark/spawner/bubblegum/B in GLOB.landmarks_list)
		new /mob/living/simple_animal/hostile/megafauna/bubblegum/round_2(get_turf(B))

/obj/effect/bubblegum_exit/Initialize(mapload, target_list)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(activate)), 10 SECONDS)

/obj/effect/bubblegum_exit/proc/activate()
	var/spawn_exit = list()
	for(var/obj/effect/landmark/spawner/bubblegum_exit/E in GLOB.landmarks_list)
		for(var/turf/T in range(4, E))
			if(T.density)
				continue
			spawn_exit += get_turf(T)
	var/area/probably_bubblearena = get_area(src)
	for(var/mob/living/M in probably_bubblearena)
		var/turf/T = get_turf(M)
		M.Immobilize(1 SECONDS)
		to_chat(M, span_colossus("<b>А теперь... убирайся из моего дома.</b>"))
		new /obj/effect/temp_visual/bubblegum_hands/leftpaw(T)
		new /obj/effect/temp_visual/bubblegum_hands/leftthumb(T)
		sleep(8)
		playsound(T, 'sound/misc/enter_blood.ogg', 100, TRUE, -1)
		var/turf/target_turf = pick(spawn_exit)
		M.forceMove(target_turf)
		playsound(target_turf, 'sound/misc/exit_blood.ogg', 100, TRUE, -1)
	for(var/obj/O in probably_bubblearena) //Mobs are out, lets get items / limbs / brains. Lets also exclude blood..
		if(iseffect(O))
			continue
		if(istype(O, /obj/structure/stone_tile)) //Taking the tiles from the arena is funny, but a bit stupid
			continue
		var/turf/target_turf = pick(spawn_exit)
		O.forceMove(target_turf)


// Soulscythe

#define MAX_BLOOD_LEVEL 100
#define BLOOD_LEVEL_PER_SECOND 1

/obj/item/soulscythe
	name = "soulscythe"
	desc = "Старый пережиток ада, созданный дьяволами, чтобы утвердить себя в качестве лидера над демонами. Он становится сильнее, пока в нем заточена мощная душа."
	ru_names = list(
		NOMINATIVE = "коса души",
		GENITIVE = "косы души",
		DATIVE = "косе души",
		ACCUSATIVE = "косу души",
		INSTRUMENTAL = "косой души",
		PREPOSITIONAL = "косе души"
	)
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "soulscythe"
	item_state = "soulscythe"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	attack_verb = list("рубит", "режет", "нарезает", "пожинает")
	hitsound = 'sound/weapons/bladeslice.ogg'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	force = 20
	throwforce = 17
	armour_penetration = 50
	sharp = TRUE
	layer = MOB_LAYER
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	/// Soulscythe mob in the scythe
	var/mob/living/simple_animal/soulscythe/soul
	/// Are we grabbing a spirit?
	var/using = FALSE
	/// Currently charging?
	var/charging = FALSE
	/// Cooldown between moves
	COOLDOWN_DECLARE(move_cooldown)
	/// Cooldown between attacks
	COOLDOWN_DECLARE(attack_cooldown)

/obj/item/soulscythe/Initialize(mapload)
	. = ..()
	soul = new(src)
	RegisterSignal(soul, COMSIG_LIVING_RESIST, PROC_REF(on_resist))
	RegisterSignal(soul, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_attack))
	RegisterSignal(soul, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_attack))
	RegisterSignal(soul, COMSIG_MOB_ATTACK_RANGED_SECONDARY, PROC_REF(on_secondary_attack))
	RegisterSignal(soul, COMSIG_MOB_LOGIN, PROC_REF(on_login))
	RegisterSignal(soul, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	RegisterSignal(src, COMSIG_OBJ_INTEGRITY_CHANGED, PROC_REF(on_integrity_change))
	RegisterSignal(soul, COMSIG_BLOOD_LEVEL_TICK, PROC_REF(on_blood_level_tick))
	ADD_TRAIT(src, TRAIT_CHASM_DESTROYED, INNATE_TRAIT)

/obj/item/soulscythe/examine(mob/user)
	. = ..()
	. += soul.ckey ? span_green("В нем заточена душа.") : span_danger("В нем нет души.")

/obj/item/soulscythe/attack(mob/living/attacked, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(attacked.stat != DEAD)
		give_blood(10)

/obj/item/soulscythe/attack_hand(mob/user, list/modifiers)
	if(soul.ckey && !soul.faction_check_mob(user))
		to_chat(user, span_warning("Ты не можешь поднять [src.declent_ru(ACCUSATIVE)]!"))
		return
	return ..()

/obj/item/soulscythe/pickup(mob/user)
	. = ..()
	if(soul.ckey)
		animate(src) //stop spinnage

/obj/item/soulscythe/dropped(mob/user, silent)
	. = ..()
	if(soul.ckey)
		reset_spin() //resume spinnage

/obj/item/soulscythe/proc/on_login(mob/source)
	SIGNAL_HANDLER
	source.client.show_popup_menus = FALSE

/obj/item/soulscythe/proc/on_logout(mob/source)
	SIGNAL_HANDLER
	source?.canon_client?.show_popup_menus = TRUE


/obj/item/soulscythe/attack_self(mob/user, modifiers)
	if(using || soul.ckey || soul.stat)
		return
	using = TRUE
	balloon_alert(user, "ты поднимаешь косу...")
	ADD_TRAIT(src, TRAIT_NODROP, type)
	var/mob/chosen_one = safepick(SSghost_spawns.poll_candidates(question = "Вы хотите сыгрыть за косу душ?", role = ROLE_PAI, poll_time = 20 SECONDS, source = src, role_cleanname = src.declent_ru(ACCUSATIVE)))
	on_poll_concluded(user, chosen_one)

/// Ghost poll has concluded and a candidate has been chosen.
/obj/item/soulscythe/proc/on_poll_concluded(mob/living/master, mob/dead/observer/ghost)
	if(isnull(ghost))
		balloon_alert(master, "коса бездействует!")
		REMOVE_TRAIT(src, TRAIT_NODROP, type)
		using = FALSE
		return

	soul.possess_by_player(ghost.ckey)
	LAZYOR(soul.languages, master.languages) //Make sure the sword can understand and communicate with the master.
	soul.faction = list("\ref[master]")
	soul.default_language = master.get_default_language()
	balloon_alert(master, "коса светится")
	add_overlay("soulscythe_gem")
	density = TRUE
	if(!ismob(loc))
		reset_spin()

	REMOVE_TRAIT(src, TRAIT_NODROP, type)
	using = FALSE

/obj/item/soulscythe/relaymove(mob/living/user, direction)
	if(!COOLDOWN_FINISHED(src, move_cooldown) || charging)
		return

	if(!isturf(loc))
		balloon_alert(user, "для перемещения нужно вырваться!")
		COOLDOWN_START(src, move_cooldown, 1 SECONDS)
		return

	if(!use_blood(1, FALSE))
		return

	if(pixel_x != base_pixel_x || pixel_y != base_pixel_y)
		animate(src, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y, flags = ANIMATION_PARALLEL)

	try_step_multiz(direction)
	COOLDOWN_START(src, move_cooldown, (direction in GLOB.cardinal) ? 0.1 SECONDS : 0.2 SECONDS)

/obj/item/soulscythe/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isliving(hit_atom))
		var/mob/living/mob = hit_atom
		if(soul.faction_check_mob(mob))
			return
	. = ..()
	if(!charging)
		return
	charging = FALSE
	throwforce *= 0.5
	reset_spin()

	if(ismineralturf(hit_atom))
		var/turf/simulated/mineral/hit_rock = hit_atom
		hit_rock.gets_drilled()

	if(isliving(hit_atom))
		var/mob/living/hit_mob = hit_atom
		if(hit_mob.stat != DEAD)
			give_blood(15)

/obj/item/soulscythe/allow_click()
	return TRUE

/obj/item/soulscythe/proc/on_blood_level_tick(datum/source, amount)
	SIGNAL_HANDLER
	give_blood(amount)

/obj/item/soulscythe/proc/use_blood(amount = 0, message = TRUE)
	if(amount > soul.blood_level)
		if(message)
			to_chat(soul, span_warning("Недостаточно крови!"))
		return FALSE
	soul.blood_level -= amount
	return TRUE

/obj/item/soulscythe/proc/give_blood(amount)
	soul.blood_level = min(MAX_BLOOD_LEVEL, soul.blood_level + amount)
	repair_damage(amount * 0.1)

/obj/item/soulscythe/proc/on_resist(mob/living/user)
	SIGNAL_HANDLER
	if(isturf(loc))
		return
	INVOKE_ASYNC(src, PROC_REF(break_out))

/obj/item/soulscythe/proc/break_out()
	if(!use_blood(10))
		return
	balloon_alert(soul, "ты начинаешь сопротивляться...")
	if(!do_after(soul, 5 SECONDS, target = src, timed_action_flags = DA_IGNORE_TARGET_LOC_CHANGE))
		balloon_alert(soul, "прервано!")
		return
	balloon_alert(soul, "ты вырываешься")
	if(ismob(loc))
		var/mob/holder = loc
		holder.temporarily_remove_item_from_inventory(src)
	else if(soul.ckey)
		addtimer(CALLBACK(src, PROC_REF(reset_spin)), 0.1 SECONDS)
	forceMove(get_turf(loc))

/obj/item/soulscythe/proc/on_integrity_change(datum/source, old_value, new_value)
	SIGNAL_HANDLER
	soul.set_health(new_value)
	soul.update_stat("itemBodyDamaged")

/obj/item/soulscythe/proc/on_attack(mob/living/source, atom/attacked_atom, modifiers)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, attack_cooldown) || !isturf(loc))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(GLOB.pacifism_after_gt || HAS_TRAIT(source, TRAIT_PACIFISM))
		to_chat(source, span_notice("Немного подумав, Вы решаете не трогать [attacked_atom.declent_ru(ACCUSATIVE)]."))
		return

	if(isliving(attacked_atom))
		var/mob/living/mob = attacked_atom
		if(soul.faction_check_mob(mob))
			return

	if(get_dist(source, attacked_atom) > 1)
		INVOKE_ASYNC(src, PROC_REF(shoot_target), attacked_atom)
	else
		INVOKE_ASYNC(src, PROC_REF(slash_target), attacked_atom)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/soulscythe/proc/on_secondary_attack(mob/living/source, atom/attacked_atom, modifiers)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, attack_cooldown) || !isturf(loc))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(GLOB.pacifism_after_gt || HAS_TRAIT(source, TRAIT_PACIFISM))
		to_chat(source, span_notice("Немного подумав, Вы решаете не трогать [attacked_atom.declent_ru(ACCUSATIVE)]."))
		return

	if(faction_check(list("[attacked_atom.UID()]"), soul.faction))
		return

	INVOKE_ASYNC(src, PROC_REF(charge_target), attacked_atom)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/item/soulscythe/proc/shoot_target(atom/attacked_atom)
	if(!use_blood(15))
		return
	COOLDOWN_START(src, attack_cooldown, 3 SECONDS)
	var/obj/projectile/projectile = new /obj/projectile/soulscythe(get_turf(src))
	projectile.preparePixelProjectile(attacked_atom, get_turf(attacked_atom), soul)
	projectile.firer = soul
	projectile.firer_source_atom = src
	projectile.fire(null, attacked_atom)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] стреля[pluralize_ru(gender,"ет","ют")] в [attacked_atom.declent_ru(ACCUSATIVE)]!"), span_notice("Вы стреляете в [attacked_atom.declent_ru(ACCUSATIVE)]!"))
	playsound(src, 'sound/magic/fireball.ogg', 50, TRUE)

/obj/item/soulscythe/proc/slash_target(atom/attacked_atom)
	if(isliving(attacked_atom) && use_blood(10))
		var/mob/living/attacked_mob = attacked_atom
		if(attacked_mob.stat != DEAD)
			give_blood(15)
		attacked_mob.apply_damage(damage = force * (faction_check(attacked_mob.faction, MINING_FACTIONS) ? 2 : 1), sharp = TRUE)
		to_chat(attacked_mob, span_userdanger("Вас разруба[pluralize_ru(gender,"ет","ют")] [declent_ru(NOMINATIVE)]!"))
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] разруба[pluralize_ru(gender,"ет","ют")] [attacked_atom.declent_ru(ACCUSATIVE)]!"), span_notice("Вы разрубаете [attacked_atom.declent_ru(ACCUSATIVE)]!"))
		playsound(src, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	else if((ismachinery(attacked_atom) || isstructure(attacked_atom)) && use_blood(5))
		var/obj/attacked_obj = attacked_atom
		attacked_obj.take_damage(force, BRUTE, MELEE, FALSE)
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] бь[pluralize_ru(gender,"ёт","ют")] [attacked_atom.declent_ru(ACCUSATIVE)]!"), span_notice("Вы бьёте [attacked_atom.declent_ru(ACCUSATIVE)]!"))
		playsound(src, 'sound/effects/meteorimpact.ogg', 50, TRUE)
	else
		return
	COOLDOWN_START(src, attack_cooldown, 1 SECONDS)
	animate(src)
	SpinAnimation(5)
	addtimer(CALLBACK(src, PROC_REF(reset_spin)), 1 SECONDS)
	soul.forceMove(get_turf(src))
	do_attack_animation(attacked_atom, ATTACK_EFFECT_SLASH, src)
	soul.forceMove(src)

/obj/item/soulscythe/proc/charge_target(atom/attacked_atom)
	if(charging || !use_blood(30))
		return
	COOLDOWN_START(src, attack_cooldown, 5 SECONDS)
	animate(src)
	charging = TRUE
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] начинает заряжаться..."))
	balloon_alert(soul, "ты начинаешь заряжаться...")
	if(!do_after(soul, 2 SECONDS, target = src, timed_action_flags = DA_IGNORE_TARGET_LOC_CHANGE))
		balloon_alert(soul, "прервано!")
		return
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] бросается на [attacked_atom.declent_ru(ACCUSATIVE)]!"), span_notice("Ты бросаешься на [attacked_atom.declent_ru(ACCUSATIVE)]!"))
	new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
	SpinAnimation(1)
	throwforce *= 2
	throw_at(attacked_atom, 10, 3, soul, FALSE)

/obj/item/soulscythe/proc/reset_spin()
	animate(src)
	SpinAnimation(15)

/obj/item/soulscythe/Destroy(force)
	soul.ghostize()
	QDEL_NULL(soul)
	. = ..()

/mob/living/simple_animal/soulscythe
	name = "mysterious spirit"
	ru_names = list(
		NOMINATIVE = "таинственный дух",
		GENITIVE = "таинственного духа",
		DATIVE = "таинственному духу",
		ACCUSATIVE = "таинственный дух",
		INSTRUMENTAL = "таинственным духом",
		PREPOSITIONAL = "таинственном духе"
	)
	maxHealth = 200
	health = 200
	icon = 'icons/mob/mob.dmi'
	icon_state = "ghost"
	gender = NEUTER
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	faction = list()
	weather_immunities = list(TRAIT_ASHSTORM_IMMUNE, TRAIT_SNOWSTORM_IMMUNE)
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hud_type = /datum/hud/simple_animal/lang
	/// Blood level, used for movement and abilities in a soulscythe
	var/blood_level = MAX_BLOOD_LEVEL

/mob/living/simple_animal/soulscythe/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Кровь:", "[blood_level]/[MAX_BLOOD_LEVEL]")

/mob/living/simple_animal/soulscythe/Life(seconds_per_tick, times_fired)
	. = ..()
	if(!stat)
		SEND_SIGNAL(src, COMSIG_BLOOD_LEVEL_TICK, round(BLOOD_LEVEL_PER_SECOND * seconds_per_tick))

/mob/living/simple_animal/soulscythe/adjustHealth(amount, updating_health, blocked, damage_type, forced)
	return STATUS_UPDATE_NONE

/obj/projectile/soulscythe
	name = "soulslash"
	ru_names = list(
		NOMINATIVE = "рассечение души",
		GENITIVE = "рассечения души",
		DATIVE = "рассечению души",
		ACCUSATIVE = "рассечение души",
		INSTRUMENTAL = "рассечением души",
		PREPOSITIONAL = "рассечении души"
	)
	icon_state = "soulslash"
	flag = MELEE //jokair
	damage = 15
	light_range = 1
	light_power = 1
	light_color = LIGHT_COLOR_BLOOD_MAGIC

/obj/projectile/soulscythe/on_hit(atom/target, blocked = 0, pierce_hit)
	if (isliving(target))
		var/mob/living/as_living = target
		if(firer.faction_check_mob(as_living))
			damage *= 0
		if(faction_check(as_living.faction, MINING_FACTIONS))
			damage *= 2
	return ..()

#undef MAX_BLOOD_LEVEL
