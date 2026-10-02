/*
MARK: Mining Spear
Kinetic spear - alternative mining weapon, used as... spear.
*/
/obj/item/twohanded/mining_spear
	name = "kinetic spear"
	desc = "Экспериментальный прототип кинетического энергокопья, используемый шахтерами для охоты на фауну и уничтожения породы."
	icon = 'icons/obj/mining.dmi'
	icon_state = "mining_spear"
	attack_verb = list("атаковал", "ткнул", "уколол", "поранил", "пронзил")
	sharp = TRUE
	embedded_ignore_throwspeed_threshold = TRUE
	no_spin_thrown = TRUE
	can_actually_embed = FALSE
	hitsound = 'sound/weapons/bladeslice.ogg'
	mob_throw_hit_sound = 'sound/weapons/pierce.ogg'
	///The mob to return the spear to if thrown
	var/mob/living/carbon/returner
	/// Did our spear return to us, when we miss?
	var/recall_after_miss = FALSE
	/// Core of our spear, without it it's just a dud
	var/obj/item/mining_spear_core/core
	/// Timer for our spear to return to user
	var/spear_return_timer = 1 SECONDS
	/// Bonus fauna damage, used in cores
	var/bonus_fauna_damage = 0
	/// Cashed throwforce, that we check after throwforce
	var/cached_throwforce
	/// Can our spear skip lavaland pressure check? Used in syndie-core
	var/can_hurt_on_station = FALSE

/obj/item/twohanded/mining_spear/standart
	core = /obj/item/mining_spear_core/standart

/obj/item/twohanded/mining_spear/get_ru_names()
	return alist(
			NOMINATIVE = "прото-кинетическое копьё",
			GENITIVE = "прото-кинетического попья",
			DATIVE = "прото-кинетическому копью",
			ACCUSATIVE = "прото-кинетическое копьё",
			INSTRUMENTAL = "прото-кинетическим копьем",
			PREPOSITIONAL = "прото-кинетическом копье",
	)

/obj/item/twohanded/mining_spear/Initialize(mapload)
	. = ..()
	if(core)
		core = new core(src)
		core.on_insert(src)
		update_icon(UPDATE_OVERLAYS)

/obj/item/twohanded/mining_spear/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!held_item)
		context[SCREENTIP_CONTEXT_RMB] = "Бросок копья (по цели)"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item) && held_item.tool_behaviour == TOOL_CROWBAR && core)
		context[SCREENTIP_CONTEXT_LMB] = "Снять ядро"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_mining_spear_core(held_item) && !core)
		context[SCREENTIP_CONTEXT_LMB] = "Установить ядро"
		return CONTEXTUAL_SCREENTIP_SET

/obj/item/twohanded/mining_spear/examine(mob/user)
	. = ..()
	if(!core)
		. += span_boldwarning("Без ядра копье практически бесполезно..")
		return

	. += "[recall_after_miss ? "Любой бросок копья" : "Успешное попадание по фауне, гуманоиду или горной породе"] [can_hurt_on_station ? "где угодно" : "в разряженной атмосфере"] приведёт к возвращению копья в ваши руки."

/obj/item/twohanded/mining_spear/attackby(obj/item/item, mob/living/user, params)
	if(!is_mining_spear_core(item))
		return ..()
	if(core)
		user.balloon_alert(user, "снимите старое ядро!")
		return ATTACK_CHAIN_BLOCKED_ALL
	if(!user.drop_transfer_item_to_loc(item, src))
		return ATTACK_CHAIN_BLOCKED_ALL
	user.balloon_alert(user, "ядро установлено!")
	core = item
	update_icon(UPDATE_OVERLAYS)
	core.on_insert(src)
	return ATTACK_CHAIN_BLOCKED_ALL

/obj/item/twohanded/mining_spear/crowbar_act(mob/living/user, obj/item/tool)
	if(!core)
		user.balloon_alert(user, "нечего снимать!")
		return

	user.balloon_alert(user, "ядро снято")
	core.on_remove(src)
	core.forceMove(get_turf(user))
	core = null
	update_icon(UPDATE_OVERLAYS)

/obj/item/twohanded/mining_spear/update_overlays()
	. = ..()
	cut_overlays()
	if(!core)
		return
	. += core.spear_overlay

/obj/item/twohanded/mining_spear/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	. = ..()
	if(!core)
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	user.throw_item(interacting_with)
	user.changeNext_move(CLICK_CD_MELEE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/twohanded/mining_spear/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	//point the spear in the direction it's being thrown
	var/angle = get_angle(target, thrower)
	var/matrix/turn_matrix = matrix(transform)
	turn_matrix.Turn(angle)
	turn_matrix.Turn(135) //because the javelin sprite itself is angled
	transform = turn_matrix
	var/turf/target_turf = get_turf(target)

	if(!thrower)
		return ..()
	if(recall_after_miss && lavaland_equipment_pressure_check(target_turf))
		returner = thrower
		RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(return_spear_to_user))

	return ..()

/obj/item/twohanded/mining_spear/after_throw(datum/callback/callback)
	var/matrix/turn_matrix = matrix()
	transform = turn_matrix
	throwforce = cached_throwforce
	return ..()

/obj/item/twohanded/mining_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!core)
		throwforce = 0 //more like sanity check, because all that stuff already should be stated when core is removed
		sharp = FALSE
		return ..()
	var/turf/target_turf = get_turf(hit_atom)
	var/mob/user = throwingdatum.get_thrower()
	if(user)
		returner = user

	new /obj/effect/temp_visual/kinetic_blast(target_turf)

	// we are changing our throwforce, so before all that, we need to remember it
	cached_throwforce = throwforce

	if(ismineralturf(hit_atom))
		var/turf/simulated/mineral/hit_rock = hit_atom
		if(!recall_after_miss)
			return_spear_to_user()
		if(user)
			hit_rock.attempt_drill(user, FALSE, 1)
		return ..()

	if(isliving(hit_atom) && (can_hurt_on_station || lavaland_equipment_pressure_check(target_turf)))
		if(!recall_after_miss)
			return_spear_to_user()
		return ..()

	if(is_lavaland_fauna(hit_atom) || ismegafauna(hit_atom))
		throwforce = cached_throwforce + bonus_fauna_damage
		if(!recall_after_miss)
			return_spear_to_user()
		return ..()

	return ..()

//obj/item/twohanded/mining_spear/on_human_ebedded(mob/living/carbon/human/target)

/obj/item/twohanded/mining_spear/proc/return_spear_to_user()
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_THROW_LANDED)
	if(!returner)
		return
	addtimer(CALLBACK(src, PROC_REF(actual_spear_return)), spear_return_timer)

/obj/item/twohanded/mining_spear/proc/actual_spear_return()
	var/turf/spear_turf = get_turf(src)
	if(returner) //double check
		spear_turf.Beam(returner, "spear_recall", time = 0.2 SECONDS)
		returner.visible_message(
			span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] возвращается в руку [returner]!"),
			span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] возвращается вам в руку!"),
		)
		returner.put_in_hands(src)
		returner = null

/*
MARK: Spear core
Spear cores. Gives spear special abilities and quirks
*/

/obj/item/mining_spear_core
	name = "spear core"
	desc = "базовое ядро копья. Вы не должны это видеть."
	icon = 'icons/obj/mining.dmi'
	icon_state = "standart_core"
	/// Spear overlay, that we use
	var/spear_overlay = "overlay_blue"
	/// All force variables, that used to modify spear
	var/spear_force = 10
	var/spear_force_unwielded = 10
	var/spear_force_wielded = 18
	var/spear_throwforce = 15
	var/spear_armour_penetration = 10
	var/spear_sharp = TRUE
	var/spear_embed_chance = 50
	var/spear_bonus_fauna_damage = 30
	var/spear_recall_after_miss = FALSE
	var/spear_can_hurt_on_station = FALSE

/obj/item/mining_spear_core/get_ru_names()
	return alist(
			NOMINATIVE = "ядро прото-кинетического попья",
			GENITIVE = "ядра прото-кинетического попья",
			DATIVE = "ядру прото-кинетического попья",
			ACCUSATIVE = "ядро прото-кинетического попья",
			INSTRUMENTAL = "ядром прото-кинетического попья",
			PREPOSITIONAL = "ядре прото-кинетического попья",
	)

/obj/item/mining_spear_core/proc/on_insert(obj/item/twohanded/mining_spear/spear)
	spear.force = spear_force
	spear.force_unwielded = spear_force_unwielded
	spear.force_wielded = spear_force_wielded
	spear.throwforce = spear_throwforce
	spear.armour_penetration = spear_armour_penetration
	spear.sharp = spear_sharp
	spear.embed_chance = spear_embed_chance
	spear.bonus_fauna_damage = spear_bonus_fauna_damage
	spear.recall_after_miss = spear_recall_after_miss
	spear.can_hurt_on_station = spear_can_hurt_on_station

/obj/item/mining_spear_core/proc/on_remove(obj/item/twohanded/mining_spear/spear)
	spear.force = initial(spear.force)
	spear.force_unwielded = initial(spear.force_unwielded)
	spear.force_wielded = initial(spear.force_wielded)
	spear.throwforce = initial(spear.throwforce)
	spear.armour_penetration = initial(spear.armour_penetration)
	spear.sharp = initial(spear.sharp)
	spear.embed_chance = initial(spear.embed_chance)
	spear.bonus_fauna_damage = initial(spear.bonus_fauna_damage)
	spear.recall_after_miss = initial(spear.recall_after_miss)
	spear.can_hurt_on_station = initial(spear.can_hurt_on_station)

/obj/item/mining_spear_core/standart
	name = "standart spear core"
	desc = "Стандартное ядро кинетического копья. Не имеет явных особенностей по сравнению с другими ядрами."

/obj/item/mining_spear_core/standart/get_ru_names()
	return alist(
			NOMINATIVE = "стандартное ядро прото-кинетического копья",
			GENITIVE = "стандартного ядра прото-кинетического копья",
			DATIVE = "стандартному ядру прото-кинетического копья",
			ACCUSATIVE = "стандартное ядро прото-кинетического копья",
			INSTRUMENTAL = "стандартным ядром прото-кинетического копья",
			PREPOSITIONAL = "стандартном ядре прото-кинетического копья",
	)

/obj/item/mining_spear_core/recall
	name = "advanced spear core"
	icon_state = "recall_core"
	desc = "Улучшенное ядро кинетического копья, позволяющее пользователю вернуть копье в руки даже в случае промаха по цели."
	spear_recall_after_miss = TRUE
	spear_overlay = "overlay_green"

