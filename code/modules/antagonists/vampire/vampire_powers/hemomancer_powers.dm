//  I think it's better to do it using spell/conjure_item but I'm too lazy
/datum/action/cooldown/spell/vamp_claws
	name = "Когти"
	desc = "Вы используете магию крови, чтобы выковать смертоносные вампирские когти, которые высасывают кровь и наносят стремительные удары. Их нельзя использовать, если вы держите что-то, что нельзя уронить."
	gain_desc = "Вы получили способность превращать свои руки в вампирские когти."
	cooldown_time = 15 SECONDS
	var/required_blood = 15
	spell_requirements = SPELL_REQUIRES_HUMAN | SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	button_icon_state = "vampire_claws"
	background_icon_state = "bg_vampire"

/datum/action/cooldown/spell/vamp_claws/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/vamp_claws/cast(atom/cast_on)
	. = ..()
	if(owner.l_hand || owner.r_hand)
		to_chat(owner, span_notice("Вы роняете то, что было у вас в руках, и из ваших пальцев вылетают огромные лезвия!"))
		owner.drop_l_hand()
		owner.drop_r_hand()
	else
		to_chat(owner, span_notice("Из ваших пальцев брызжет кровь!"))
	var/obj/item/twohanded/required/vamp_claws/claws = new /obj/item/twohanded/required/vamp_claws(owner.loc, src)
	RegisterSignal(owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(dispel))
	owner.put_in_hands(claws)

/datum/action/cooldown/spell/vamp_claws/proc/dispel()
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = owner
	if(!user.mind.has_antag_datum(/datum/antagonist/vampire))
		return

	var/current
	if(istype(user.l_hand, /obj/item/twohanded/required/vamp_claws))
		current = user.l_hand

	if(istype(user.r_hand, /obj/item/twohanded/required/vamp_claws))
		current = user.r_hand

	if(current)
		qdel(current)
		to_chat(user, span_notice("Вы рассеиваете когти!"))
		return COMPONENT_CANCEL_DROP

/datum/action/cooldown/spell/vamp_claws/can_cast_spell(feedback)
	var/mob/living/L = owner
	if(L.can_unEquip(L.l_hand) && L.can_unEquip(L.r_hand))
		return ..()
	return FALSE

/obj/item/twohanded/required/vamp_claws
	name = "vampiric claws"
	desc = "Пара древних когтей из живой крови, они кажутся текучими и в то же время твердыми."
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "vamp_claws"
	w_class = WEIGHT_CLASS_BULKY
	item_flags = ABSTRACT|DROPDEL
	force = 15
	force_wielded = 15
	armour_penetration = 40
	sharp = TRUE
	attack_speed = 0.4 SECONDS
	attack_effect_override = ATTACK_EFFECT_CLAW
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("полоснул", "уколол", "поранил", "порезал", "поцарапал")
	sprite_sheets_inhand = list(SPECIES_VOX = 'icons/mob/clothing/species/vox/held.dmi', SPECIES_DRASK = 'icons/mob/clothing/species/drask/held.dmi')
	var/durability = 15
	var/blood_drain_amount = 15
	var/blood_absorbed_amount = 5
	var/datum/action/cooldown/spell/vamp_claws/parent_spell

/obj/item/twohanded/required/vamp_claws/get_ru_names()
	return alist(
		NOMINATIVE = "вампирические когти",
		GENITIVE = "вампирических когтей",
		DATIVE = "вампирическим когтям",
		ACCUSATIVE = "вампирические когти",
		INSTRUMENTAL = "вампирическими когтями",
		PREPOSITIONAL = "вампирических когтях",
	)

/obj/item/twohanded/required/vamp_claws/Initialize(mapload, new_parent_spell)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	parent_spell = new_parent_spell

/obj/item/twohanded/required/vamp_claws/Destroy()
	if(parent_spell)
		parent_spell.UnregisterSignal(parent_spell.owner, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		parent_spell.UpdateButtonIcon()
		parent_spell = null
	return ..()

/obj/item/twohanded/required/vamp_claws/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if(!proximity_flag)
		return

	var/datum/antagonist/vampire/V = user.mind?.has_antag_datum(/datum/antagonist/vampire)
	var/mob/living/attacker = user

	if(!V)
		return

	if(iscarbon(target))
		var/mob/living/carbon/C = target
		// no parameter in [affects_vampire()] so holy always protects
		if(C.ckey && C.stat != DEAD && C.affects_vampire() && !HAS_TRAIT(C, TRAIT_NO_BLOOD))
			C.bleed(blood_drain_amount)
			attacker.adjustStaminaLoss(-20) // security is dead
			attacker.heal_overall_damage(4, 4) // the station is full
			attacker.AdjustKnockdown(-1 SECONDS) // blood is fuel
			if(!HAS_TRAIT(C, TRAIT_EXOTIC_BLOOD))
				V.adjust_blood(C, blood_absorbed_amount)

	if(!V.get_ability(/datum/vampire_passive/blood_spill))
		durability--
		if(durability <= 0)
			qdel(src)
			to_chat(user, span_warning("Ваши когти сломаны!"))

/obj/item/twohanded/required/vamp_claws/attack_self(mob/user)
	qdel(src)
	to_chat(user, span_notice("Вы рассеиваете когти!"))

/datum/action/cooldown/spell/pointed/blood_tendrils
	name = "Кровавые щупальца"
	desc = "Используя силу блюспейса, после небольшой задержки вы призываете кровавые щупальца, которые опутывают цели в зоне действия, замедляя их и нанося умеренный токсичный урон."
	gain_desc = "Вы получили способность вызывать кровавые щупальца, чтобы замедлять людей в выбранной вами области."
	var/required_blood = 10
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "blood_tendrils"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	sound = 'sound/misc/enter_blood.ogg'
	var/area_of_affect = 1
	active_msg = span_notice_alt("Вы используете магию крови, чтобы ослабить завесу блюспейса.")
	deactive_msg = span_notice_alt("Ваша магия ослабевает.")

/datum/action/cooldown/spell/pointed/blood_tendrils/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/blood_tendrils/cast(atom/cast_on)
	. = ..()
	var/turf/T = get_turf(cast_on)

	for(var/turf/simulated/blood_turf in view(area_of_affect, T))
		if(blood_turf.density)
			continue
		new /obj/effect/temp_visual/blood_tendril(blood_turf)

	addtimer(CALLBACK(src, PROC_REF(apply_slowdown), T, area_of_affect, 6 SECONDS, owner), 1 SECONDS)

/datum/action/cooldown/spell/pointed/blood_tendrils/proc/apply_slowdown(turf/T, distance, slowed_amount, mob/user)
	for(var/mob/living/L in range(distance, T))
		if(L.affects_vampire(user))
			L.Slowed(slowed_amount)
			L.apply_damage(33, TOX)
			L.visible_message(span_warning("[L] опутыва[PLUR_ET_YUT(L)]ся кровавыми щупальцами, которые ограничивают [GEND_HIS_HER(L)] движение!"))
			var/turf/target_turf = get_turf(L)
			playsound(target_turf, 'sound/magic/tail_swing.ogg', 50, TRUE)
			new /obj/effect/decal/cleanable/blood(target_turf)
			new /obj/effect/temp_visual/blood_tendril/long(target_turf)

/obj/effect/temp_visual/blood_tendril
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "blood_tendril"

/obj/effect/temp_visual/blood_tendril/long
	duration = 2 SECONDS

/datum/action/cooldown/spell/pointed/blood_barrier
	name = "Кровавый барьер"
	desc = "Выберите две точки в пределах трёх тайлов друг от друга и создайте между ними барьер. Вы можете наложить заклинание на себя, чтобы мгновенно создать барьер на вашей текущей позиции."
	gain_desc = "Вы получили способность вызывать кристаллическую стену крови между двумя точками, барьер легко разрушается, однако вы можете свободно проходить сквозь него. Вы можете наложить на себя заклинание, чтобы мгновенно создать барьер на вашем текущем местоположении."
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "blood_barrier"
	background_icon_state = "bg_vampire"
	background_icon_state_active = "bg_vampire"
	cooldown_time = 30 SECONDS
	var/required_blood = 15
	var/turf/old_mouse_turf
	var/indicator_timer = null
	var/list/images = list()
	var/max_walls = 3
	var/turf/start_turf = null

/datum/action/cooldown/spell/pointed/blood_barrier/is_valid_target(atom/cast_on)
	return TRUE

/datum/action/cooldown/spell/pointed/blood_barrier/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/blood_barrier/unset_click_ability(mob/on_who, refund_cooldown)
	. = ..()
	if(refund_cooldown) // this is only true if the user intentionally turned off the spell
		start_turf = null
		cooldown_time = initial(cooldown_time)

/datum/action/cooldown/spell/pointed/blood_barrier/cast(atom/cast_on)
	. = ..()
	unset_after_click = TRUE
	// First we check if vampire clicks on himself
	var/turf/target_turf = get_turf(cast_on)
	var/user_found = FALSE
	for(var/mob/living/check in target_turf.contents)
		if(check == owner)
			user_found = TRUE
			break

	if(user_found && !start_turf)
		var/odd_number = max_walls % 2
		var/walls_amount = odd_number ? ((max_walls - 1) / 2) : (max_walls / 2 - 1)
		var/dir_right = turn(owner.dir, 90)
		var/dir_left = turn(owner.dir, 270)

		new /obj/structure/blood_barrier(target_turf)
		for(var/i in 1 to walls_amount)
			new /obj/structure/blood_barrier(get_step(target_turf, dir_right))

		for(var/i in 1 to (odd_number ? walls_amount : walls_amount + 1))
			new /obj/structure/blood_barrier(get_step(target_turf, dir_left))

		var/datum/spell_handler/vampire/V = custom_handler
		var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)
		var/blood_cost = V.calculate_blood_cost(vampire)
		vampire.bloodusable -= blood_cost
		return

	// Otherwise we will try to build a wall by two clicks
	if(target_turf == start_turf)
		to_chat(owner, span_notice("Вы убираете пометку с тайла."))
		start_turf = null
		cooldown_time = 0
		deltimer(indicator_timer)
		return

	if(!start_turf)
		start_turf = target_turf
		cooldown_time = 0
		indicator_timer = addtimer(CALLBACK(src, PROC_REF(update_indicator)), 0.1, TIMER_STOPPABLE | TIMER_LOOP)
		unset_after_click = FALSE
		return

	var/wall_count
	for(var/turf/T as anything in get_line(start_turf, target_turf))
		if(max_walls <= wall_count)
			break
		new /obj/structure/blood_barrier(T)
		wall_count++
	deltimer(indicator_timer)
	var/datum/spell_handler/vampire/V = custom_handler
	var/datum/antagonist/vampire/vampire = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	var/blood_cost = V.calculate_blood_cost(vampire)
	vampire.bloodusable -= blood_cost
	start_turf = null
	remove_indicator()
	cooldown_time = initial(cooldown_time)

/datum/action/cooldown/spell/pointed/blood_barrier/proc/update_indicator()
	var/turf/mouse_turf = get_turf(SSmouse_entered.hovers[owner.client])
	if(isnull(mouse_turf) || mouse_turf == old_mouse_turf)
		return
	remove_indicator()
	if(start_turf)
		draw_indicator(mouse_turf)
	old_mouse_turf = mouse_turf

/datum/action/cooldown/spell/pointed/blood_barrier/proc/draw_indicator(turf/draw_to)
	var/indicator_count
	for(var/turf/T as anything in get_line(start_turf, draw_to))
		if(max_walls <= indicator_count)
			break
		var/image/indicator = image('icons/effects/vampire_effects.dmi', T, "blood_barrier", ABOVE_LIGHTING_LAYER)
		indicator.alpha = 100
		images += indicator
		add_image_to_client(indicator, owner.client)
		indicator_count++

/datum/action/cooldown/spell/pointed/blood_barrier/proc/remove_indicator()
	for(var/image in images)
		remove_image_from_client(image, owner.client)
		qdel(image)

/obj/structure/blood_barrier
	name = "blood barrier"
	desc = "Гротескная структура из кристаллизованной крови. Она медленно тает..."
	max_integrity = 100
	icon_state = "blood_barrier"
	icon = 'icons/effects/vampire_effects.dmi'
	density = TRUE
	anchored = TRUE

/obj/structure/blood_barrier/get_ru_names()
	return alist(
		NOMINATIVE = "кровавый барьер",
		GENITIVE = "кровавого барьера",
		DATIVE = "кровавому барьеру",
		ACCUSATIVE = "кровавый барьер",
		INSTRUMENTAL = "кровавым барьером",
		PREPOSITIONAL = "о кровавом барьере",
	)

/obj/structure/blood_barrier/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/blood_barrier/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/blood_barrier/process()
	take_damage(8, sound_effect = FALSE)

/obj/structure/blood_barrier/obj_destruction(damage_flag)
	new /obj/effect/decal/cleanable/blood(loc)
	return ..()

/obj/structure/blood_barrier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE

	if(!isliving(mover))
		return FALSE

	var/mob/living/L = mover
	if(!L.mind)
		return FALSE

	var/datum/antagonist/vampire/V = L.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V)
		return FALSE

	if(is_type_in_list(V.subclass, list(SUBCLASS_HEMOMANCER, SUBCLASS_ANCIENT)))
		return TRUE

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blood_pool
	name = "Погружение в кровь"
	desc = "Вы превращаете свою форму в лужу крови, делая ее неуязвимой и способной перемещаться сквозь всё, что не является стеной или космосом. После этого за вами остаётся кровавый след."
	gain_desc = "Вы получили способность превращаться в лужу крови, что позволяет вам уходить от преследователей с большой мобильностью."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	background_icon_state = "bg_vampire"
	button_icon_state = "blood_pool"
	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/blood_pool
	jaunt_out_type = /obj/effect/temp_visual/dir_setting/cult/phase/out
	jaunt_in_type = /obj/effect/temp_visual/dir_setting/cult/phase
	jaunt_in_time = 0
	sound = 'sound/misc/enter_blood.ogg'
	exit_jaunt_sound = 'sound/misc/exit_blood.ogg'
	var/required_blood = 20

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blood_pool/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/obj/effect/dummy/phased_mob/spell_jaunt/blood_pool
	name = "sanguine pool"
	desc = "a pool of living blood."
	movespeed = 0.75
	phased_mob_icon_state = "blood_bolt"

/obj/effect/dummy/phased_mob/spell_jaunt/blood_pool/relaymove(mob/living/user, direction)
	. = ..()
	new /obj/effect/decal/cleanable/blood(loc)

/obj/effect/dummy/phased_mob/spell_jaunt/blood_pool/phased_check(mob/living/user, direction)
	var/turf/newloc = get_step_multiz(src,direction)
	if(isspaceturf(newloc) || newloc.density)
		return
	return ..()

/datum/action/cooldown/spell/list_target/predator_senses
	name = "Чутьё хищника"
	desc = "Выслеживайте свою добычу, здесь ей негде спрятаться... На короткое время оглушает её, если она окажется в вашем поле зрения."
	gain_desc = "Ваши чувства обострились, теперь никто не сможет от вас спрятаться."
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "predator_sense"
	background_icon_state = "bg_vampire"
	used_in_radius = FALSE

/datum/action/cooldown/spell/list_target/predator_senses/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src)
	return handler

/datum/action/cooldown/spell/list_target/predator_senses/get_list_targets(atom/center, target_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in GLOB.alive_mob_list)
		if(target.z != owner.z || !target.mind || target == owner)
			continue
		targets += target
	return targets

/datum/action/cooldown/spell/list_target/predator_senses/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on
	var/message = "[target.name] наход[PLUR_IT_YAT(target)]ся в локации [get_area(target)], на [dir2rustext(get_dir(owner, target))]е от вас."
	if(target.get_damage_amount() >= 40 || target.bleed_rate)
		message += "<i> Цель ранена...</i>"
	to_chat(owner, span_cultlarge("[message]"))

	if(target in view(owner))
		target.Knockdown(4 SECONDS)
		var/turf/target_turf = get_turf(target)
		playsound(target_turf, 'sound/effects/splat.ogg', 50, TRUE)
		new /obj/effect/decal/cleanable/blood(target_turf)

/datum/action/cooldown/spell/aoe/blood_eruption
	name = "Извержение крови"
	desc = "Каждая лужа крови в 4 тайлах от вас извергается шипом живой крови, нанося урон всем, кто стоит на ней."
	gain_desc = "Вы получили способность использовать лужи крови для нанесения урона тем, кто на них стоит."
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 1 MINUTES
	button_icon_state = "blood_spikes"
	background_icon_state = "bg_vampire"
	aoe_radius = 4
	targeting_type = /datum/aoe_targeting/blood_eruption
	var/required_blood = 25

/datum/action/cooldown/spell/aoe/blood_eruption/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/aoe/blood_eruption/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/victim_mob = victim
	var/turf/turf = get_turf(victim_mob)
	var/obj/effect/decal/cleanable/blood/B = locate(/obj/effect/decal/cleanable/blood) in turf
	var/obj/effect/temp_visual/blood_spike/spike = new /obj/effect/temp_visual/blood_spike(turf)
	spike.color = B.basecolor
	playsound(victim_mob, 'sound/misc/demon_attack1.ogg', 50, TRUE)
	victim_mob.apply_damage(50, BRUTE, BODY_ZONE_CHEST)
	victim_mob.Stun(3 SECONDS)
	victim_mob.visible_message(span_warning("<b>[victim_mob] пронзен[GEND_A_O_Y(victim_mob)] шипом живой крови!</b>"))

/obj/effect/temp_visual/blood_spike
	icon = 'icons/effects/vampire_effects.dmi'
	icon_state = "bloodspike_white"
	duration = 0.3 SECONDS

/datum/action/cooldown/spell/blood_spill
	name = "Кровавый обряд"
	desc = "При переключении все вокруг начнут обильно кровоточить. Вы будете поглощать их кровь и напитываться силой."
	gain_desc = "Вы обрели способность извлекать жизненную силу из гуманоидов и поглощать её, исцеляя себя."
	button_icon_state = "blood_bringers_rite"
	background_icon_state = "bg_vampire"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	var/required_blood = 10

/datum/action/cooldown/spell/blood_spill/create_new_handler()
	var/datum/spell_handler/vampire/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/blood_spill/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	if(!V.get_ability(/datum/vampire_passive/blood_spill))
		V.force_add_ability(/datum/vampire_passive/blood_spill)
	else
		for(var/datum/vampire_passive/blood_spill/B in V.powers)
			V.remove_ability(B)

/datum/vampire_passive/blood_spill
	var/max_beams = 10

/datum/vampire_passive/blood_spill/New()
	..()
	START_PROCESSING(SSobj, src)

/datum/vampire_passive/blood_spill/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/vampire_passive/blood_spill/process()
	var/beam_number = 0
	var/datum/antagonist/vampire/V = owner.mind.has_antag_datum(/datum/antagonist/vampire)
	for(var/mob/living/carbon/human/H in view(7, owner))
		if(HAS_TRAIT(H, TRAIT_NO_BLOOD))
			continue

		if(!H.affects_vampire(owner) || H.stat)
			continue

		var/drain_amount = rand(5, 10)
		beam_number++
		H.bleed(drain_amount)
		H.Beam(owner, icon_state = "drainbeam", time = 2 SECONDS)
		H.adjustBruteLoss(5)
		var/update = NONE
		update |= owner.heal_overall_damage(8, 2, updating_health = FALSE, affect_robotic = TRUE)
		update |= owner.heal_damage_type(15, STAMINA, updating_health = FALSE)
		if(update)
			owner.updatehealth()
		owner.AdjustStunned(-2 SECONDS)
		owner.AdjustWeakened(-2 SECONDS)
		if(drain_amount == 10)
			to_chat(H, span_warning("<b>Вы чувствуете, как из вас утекает жизненная сила!</b>"))

		if(beam_number >= max_beams)
			break

	V.bloodusable = max(V.bloodusable - 5, 0)

	if(!V.bloodusable || owner.stat == DEAD)
		V.remove_ability(src)

