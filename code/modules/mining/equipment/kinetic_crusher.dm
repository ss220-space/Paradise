/*********************Mining Hammer****************/
/obj/item/twohanded/kinetic_crusher
	icon = 'icons/obj/mining.dmi'
	icon_state = "crusher"
	item_state = "crusher0"
	name = "proto-kinetic crusher"
	desc = "Ранняя версия Кинетического Акселератора, по сути являющаяся кучей шахтёрских инструментов прибитых друг к другу в форму топора. Эффективен, но опасен в использовании, особенно для неопытных шахтеров."
	ru_names = list(
            NOMINATIVE = "прото-кинетический крушитель",
            GENITIVE = "прото-кинетического крушителя",
            DATIVE = "прото-кинетическому крушителю",
            ACCUSATIVE = "прото-кинетический крушитель",
            INSTRUMENTAL = "прото-кинетическим крушителем",
            PREPOSITIONAL = "прото-кинетическом крушителе"
	)
	gender = MALE
	force = 0 //You can't hit stuff unless wielded
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	force_unwielded = 0
	force_wielded = 20
	throwforce = 5
	throw_speed = 4
	armour_penetration = 10
	materials = list(MAT_METAL = 1150, MAT_GLASS = 2075)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("сокрушил", "рубанул", "ударил")
	sharp = TRUE
	actions_types = list(/datum/action/item_action/toggle_light)
	var/list/trophies = list()
	var/charged = TRUE
	var/charge_time = 15
	var/detonation_damage = 50
	var/backstab_bonus = 30
	light_system = MOVABLE_LIGHT
	light_range = 5
	light_on = FALSE
	var/adaptive_damage_bonus = 0
	var/upgraded = FALSE //whether is our crusher is magmite-upgraded
	var/obj/projectile/destabilizer/destab = /obj/projectile/destabilizer

/obj/item/twohanded/kinetic_crusher/Destroy()
	QDEL_LIST(trophies)
	return ..()

/obj/item/twohanded/kinetic_crusher/examine(mob/living/user)
	. = ..()
	. += span_notice("Возьмите в обе руки и нажмите по любой клетке чтобы выстрелить дестабилизатором, способным разрушать породу. При попадании по фауне отмечает её дестабилизирующим полем")
	. += span_notice("Удары по отмеченной дестабилизатором фауне наносят <b>[force + detonation_damage]</b> единиц[declension_ru(force + detonation_damage, "у", "ы", "")] урона.")
	. += span_notice("Наносит <b>[force + detonation_damage + backstab_bonus]</b> единиц[declension_ru(force + detonation_damage + backstab_bonus, "у", "ы", "")] урона вместо <b>[force + detonation_damage]</b> при ударе в спину. \n")
	. += span_notice("<b>К Крушителю прикреплены следующие трофеи</b>:")
	for(var/t in trophies)
		var/obj/item/crusher_trophy/T = t
		. += span_notice("<b>[capitalize(T.declent_ru(NOMINATIVE))]</b>, эффект: [T.effect_desc()].")


/obj/item/twohanded/kinetic_crusher/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/crusher_trophy))
		var/obj/item/crusher_trophy/trophy = I
		add_fingerprint(user)
		if(trophy.add_to(src, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/twohanded/kinetic_crusher/crowbar_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(LAZYLEN(trophies))
		balloon_alert(user, "трофеи сняты")
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.remove_from(src, user)
	else
		balloon_alert(user, "нет трофеев!")


/obj/item/twohanded/kinetic_crusher/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		var/warn_message = "[capitalize(declent_ru(NOMINATIVE))] слишком тяжёл, чтобы использовать его одной рукой."
		if(user.drop_item_ground(src))
			warn_message += "Вы роняете [declent_ru(ACCUSATIVE)] на землю."
		to_chat(user, span_warning(warn_message))
		return ATTACK_CHAIN_BLOCKED_ALL
	var/datum/status_effect/crusher_damage/damage_track = target.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	if(!damage_track)
		damage_track = target.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
	var/target_health = target.health
	var/temp_force_bonus = 0
	var/datum/status_effect/adaptive_learning/learning = target.has_status_effect(STATUS_EFFECT_ADAPTIVELEARNING)
	if(!learning && adaptive_damage_bonus)
		learning = target.apply_status_effect(STATUS_EFFECT_ADAPTIVELEARNING)
	if(learning)
		temp_force_bonus = learning.bonus_damage
		learning.bonus_damage = min((learning.bonus_damage + adaptive_damage_bonus), 20)
	force += temp_force_bonus
	. = ..()
	force -= temp_force_bonus
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || QDELETED(target))
		return .
	for(var/obj/item/crusher_trophy/trophy as anything in trophies)
		if(!QDELETED(target))
			trophy.on_melee_hit(target, user)
	if(!QDELETED(damage_track) && !QDELETED(target))
		damage_track.total_damage += target_health - target.health //we did some damage, but let's not assume how much we did


/obj/item/twohanded/kinetic_crusher/afterattack(atom/target, mob/living/user, proximity_flag, clickparams)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(user.has_status_effect(STATUS_EFFECT_DASH) && user.a_intent == INTENT_HELP)
		if(user.throw_at(target, range = 3, speed = 3, spin = FALSE, diagonals_first = TRUE))
			playsound(src, 'sound/effects/stealthoff.ogg', 50, 1, 1)
			user.visible_message(span_warning("[user] соверша[pluralize_ru(user, "ет", "ют")] рывок!"))
		else
			to_chat(user, span_warning("Что-то не даёт вам совершить рывок!"))
		user.remove_status_effect(STATUS_EFFECT_DASH)
		return
	if(!proximity_flag && charged)//Mark a target, or mine a tile.
		var/turf/proj_turf = user.loc
		if(!isturf(proj_turf))
			return
		var/obj/projectile/destabilizer/D = new destab(proj_turf)
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_projectile_fire(D, user)
		D.preparePixelProjectile(target, get_turf(target), user, clickparams)
		D.firer = user
		D.firer_source_atom = src
		D.hammer_synced = src
		playsound(user, 'sound/weapons/crusher_shot.ogg', 160, 1)
		D.fire()
		charged = FALSE
		update_icon()
		addtimer(CALLBACK(src, PROC_REF(Recharge)), charge_time)
		return
	if(proximity_flag && isliving(target))
		var/mob/living/L = target
		var/datum/status_effect/crusher_mark/CM = L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)
		if(!CM || CM.hammer_synced != src || !L.remove_status_effect(STATUS_EFFECT_CRUSHERMARK))
			return
		var/datum/status_effect/crusher_damage/C = L.has_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		if(!C)
			C = L.apply_status_effect(STATUS_EFFECT_CRUSHERDAMAGETRACKING)
		var/target_health = L.health
		for(var/t in trophies)
			var/obj/item/crusher_trophy/T = t
			T.on_mark_detonation(target, user)
		if(!QDELETED(L))
			if(!QDELETED(C))
				C.total_damage += target_health - L.health //we did some damage, but let's not assume how much we did
			new /obj/effect/temp_visual/kinetic_blast(get_turf(L))
			var/backstab_dir = get_dir(user, L)
			var/def_check = L.getarmor(attack_flag = BOMB)
			if((user.dir & backstab_dir) && (L.dir & backstab_dir))
				if(!QDELETED(C))
					C.total_damage += detonation_damage + backstab_bonus //cheat a little and add the total before killing it, so certain mobs don't have much lower chances of giving an item
				L.apply_damage(detonation_damage + backstab_bonus, BRUTE, blocked = def_check)
				playsound(user, 'sound/weapons/crusher_backstab.ogg', 130) //Seriously who spelled it wrong
			else
				if(!QDELETED(C))
					C.total_damage += detonation_damage
				L.apply_damage(detonation_damage, BRUTE, blocked = def_check)

/obj/item/twohanded/kinetic_crusher/proc/Recharge()
	if(!charged)
		charged = TRUE
		update_icon()
		playsound(src.loc, 'sound/weapons/crusher_reload.ogg', 135)

/obj/item/twohanded/kinetic_crusher/ui_action_click(mob/user, datum/action/action, leftclick)
	set_light_on(!light_on)
	playsound(user, 'sound/weapons/empty.ogg', 100, TRUE)
	update_icon()

/obj/item/twohanded/kinetic_crusher/update_icon(updates = ALL)
	. = ..()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()

/obj/item/twohanded/kinetic_crusher/update_icon_state()
	if(upgraded)
		item_state = "magmite_crusher[HAS_TRAIT(src, TRAIT_WIELDED)]"
	else
		item_state = "crusher[HAS_TRAIT(src, TRAIT_WIELDED)]"


/obj/item/twohanded/kinetic_crusher/update_overlays()
	. = ..()
	if(!charged)
		. += "[icon_state]_uncharged"
	if(light_on)
		. += "[icon_state]_lit"


//destablizing force
/obj/projectile/destabilizer
	name = "destabilizing force"
	icon_state = "pulse1"
	nodamage = TRUE
	damage = 0 //We're just here to mark people. This is still a melee weapon.
	damage_type = BRUTE
	flag = "bomb"
	range = 6
	log_override = TRUE
	var/obj/item/twohanded/kinetic_crusher/hammer_synced

/obj/projectile/destabilizer/Destroy()
	hammer_synced = null
	return ..()

/obj/projectile/destabilizer/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		var/had_effect = (L.has_status_effect(STATUS_EFFECT_CRUSHERMARK)) //used as a boolean
		var/datum/status_effect/crusher_mark/CM = L.apply_status_effect(STATUS_EFFECT_CRUSHERMARK, hammer_synced)
		if(hammer_synced)
			for(var/t in hammer_synced.trophies)
				var/obj/item/crusher_trophy/T = t
				T.on_mark_application(target, CM, had_effect)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		if(isancientturf(target_turf))
			visible_message(span_notice("Похоже, что эту породу возьмёт только кирка!"))
		else
			var/turf/simulated/mineral/M = target_turf
			new /obj/effect/temp_visual/kinetic_blast(M)
			M.attempt_drill(firer)
	..()

//trophies
/obj/item/crusher_trophy
	name = "tail spike"
	desc = "Странный шип без применений."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "tail_spike"
	var/bonus_value = 10 //if it has a bonus effect, this is how much that effect is
	var/denied_type = /obj/item/crusher_trophy

/obj/item/crusher_trophy/examine(mob/living/user)
	. = ..()
	. += span_notice("Вызывает следующий эффект, если используется как трофей крушителя: [effect_desc()].")

/obj/item/crusher_trophy/proc/effect_desc()
	return "errors"


/obj/item/crusher_trophy/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/twohanded/kinetic_crusher))
		add_fingerprint(user)
		if(add_to(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED
	return ..()


/obj/item/crusher_trophy/proc/add_to(obj/item/twohanded/kinetic_crusher/crusher, mob/living/user)
	for(var/obj/item/crusher_trophy/crusher_trophy as anything in crusher.trophies)
		if(istype(crusher_trophy, denied_type) || istype(src, crusher_trophy.denied_type))
			balloon_alert(user, "нет места!")
			return FALSE
	if(loc == user)
		if(!user.drop_transfer_item_to_loc(src, crusher))
			return FALSE
	else
		forceMove(crusher)
	crusher.trophies += src
	balloon_alert(user, "прикреплено")
	return TRUE

/obj/item/crusher_trophy/proc/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	forceMove(get_turf(H))
	H.trophies -= src
	return TRUE

/obj/item/crusher_trophy/proc/on_melee_hit(mob/living/target, mob/living/user) //the target and the user

/obj/item/crusher_trophy/proc/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user) //the projectile fired and the user

/obj/item/crusher_trophy/proc/on_mark_application(mob/living/target, datum/status_effect/crusher_mark/mark, had_mark) //the target, the mark applied, and if the target had a mark before

/obj/item/crusher_trophy/proc/on_mark_detonation(mob/living/target, mob/living/user) //the target and the user

//goliath
/obj/item/crusher_trophy/goliath_tentacle
	name = "goliath tentacle"
	desc = "Отрубленное щупальце голиафа. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "щупальце голиафа",
            GENITIVE = "щупальца голиафа",
            DATIVE = "щупальцу голиафа",
            ACCUSATIVE = "щупальце голиафа",
            INSTRUMENTAL = "щупальцем голиафа",
            PREPOSITIONAL = "щупальце голиафа"
	)
	gender = NEUTER
	icon_state = "goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/goliath_tentacle
	bonus_value = 2
	var/missing_health_ratio = 0.1
	var/missing_health_desc = 10

/obj/item/crusher_trophy/goliath_tentacle/effect_desc()
	return "Взрыв метки наносит <b>[bonus_value]</b> едениц[declension_ru(bonus_value, "у", "ы", "")] дополнительного урона за каждые <b>[missing_health_desc]</b> единиц[declension_ru(missing_health_desc, "у", "ы", "")] недостающего у вас здоровья"

/obj/item/crusher_trophy/goliath_tentacle/on_mark_detonation(mob/living/target, mob/living/user)
	var/missing_health = user.health - user.maxHealth
	missing_health *= missing_health_ratio //bonus is active at all times, even if you're above 90 health
	missing_health *= bonus_value //multiply the remaining amount by bonus_value
	if(missing_health > 0)
		target.adjustBruteLoss(missing_health) //and do that much damage

//watcher
/obj/item/crusher_trophy/watcher_wing
	name = "watcher wing"
	desc = "Оторванное крыло наблюдателя. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "крыло наблюдателя",
            GENITIVE = "крыла наблюдателя",
            DATIVE = "крылу наблюдателя",
            ACCUSATIVE = "крыло наблюдателя",
            INSTRUMENTAL = "крылом наблюдателя",
            PREPOSITIONAL = "крыле наблюдателя"
	)
	gender = NEUTER
	icon_state = "watcher_wing"
	denied_type = /obj/item/crusher_trophy/watcher_wing
	bonus_value = 5

/obj/item/crusher_trophy/watcher_wing/effect_desc()
	return "Взрыв метки не позволяет фауне использовать дальние атаки в течении <b>[bonus_value * 0.1]</b> секунд[declension_ru(bonus_value * 0.1, "ы", "", "")]"

/obj/item/crusher_trophy/watcher_wing/on_mark_detonation(mob/living/target, mob/living/user)
	if(ishostile(target))
		var/mob/living/simple_animal/hostile/H = target
		if(H.ranged) //briefly delay ranged attacks
			if(H.ranged_cooldown >= world.time)
				H.ranged_cooldown += bonus_value
			else
				H.ranged_cooldown = bonus_value + world.time

//magmawing watcher
/obj/item/crusher_trophy/blaster_tubes/magma_wing
	name = "magmawing watcher wing"
	desc = "Всё ещё пылающее крыло магмакрылого наблюдателя. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "крыло магмакрылого наблюдателя",
            GENITIVE = "крыла магмакрылого наблюдателя",
            DATIVE = "крылу магмакрылого наблюдателя",
            ACCUSATIVE = "крыло магмакрылого наблюдателя",
            INSTRUMENTAL = "крылом магмакрылого наблюдателя",
            PREPOSITIONAL = "крыле магмакрылого наблюдателя"
	)
	icon_state = "magma_wing"
	gender = NEUTER
	bonus_value = 5

/obj/item/crusher_trophy/blaster_tubes/magma_wing/effect_desc()
	return "Следующий за взрывом метки снаряд дестабилизатора наносит <b>[bonus_value]</b> единиц[declension_ru(bonus_value, "у", "ы", "")] урона"

/obj/item/crusher_trophy/blaster_tubes/magma_wing/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "heated [marker.name]"
		marker.icon_state = "lava"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		deadly_shot = FALSE

//icewing watcher
/obj/item/crusher_trophy/watcher_wing/ice_wing
	name = "icewing watcher wing"
	desc = "Хрупкое, замороженное крыло ледокрылого наблюдателя. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "крыло ледокрылого наблюдателя",
            GENITIVE = "крыла ледокрылого наблюдателя",
            DATIVE = "крылу ледокрылого наблюдателя",
            ACCUSATIVE = "крыло ледокрылого наблюдателя",
            INSTRUMENTAL = "крылом ледокрылого наблюдателя",
            PREPOSITIONAL = "крыле ледокрылого наблюдателя"
	)
	gender = NEUTER
	icon_state = "ice_wing"
	bonus_value = 8

//legion
/obj/item/crusher_trophy/legion_skull
	name = "legion skull"
	desc = "Разбитый, безжизненный череп легиона. Может быть установлен на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "череп легиона",
            GENITIVE = "черепа легиона",
            DATIVE = "черепу легиона",
            ACCUSATIVE = "череп легиона",
            INSTRUMENTAL = "черепом легиона",
            PREPOSITIONAL = "черепе легиона"
	)
	gender = MALE
	icon_state = "legion_skull"
	denied_type = /obj/item/crusher_trophy/legion_skull
	bonus_value = 3

/obj/item/crusher_trophy/legion_skull/effect_desc()
	return "Перезарядка дестабилизатора ускорена на <b>[bonus_value * 0.1]</b> секунд[declension_ru(bonus_value * 0.1, "у", "ы", "")]"

/obj/item/crusher_trophy/legion_skull/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time -= bonus_value

/obj/item/crusher_trophy/legion_skull/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.charge_time += bonus_value

/// Massive eyed tentacle
/obj/item/crusher_trophy/eyed_tentacle
	name = "Massive eyed tentacle"
	desc = "Большое и глазастое щупальце древнего голиафа. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "огромное щупальце голиафа",
            GENITIVE = "огромного щупальца голиафа",
            DATIVE = "огромному щупальцу голиафа",
            ACCUSATIVE = "огромное щупальце голиафа",
            INSTRUMENTAL = "огромным щупальцем голиафа",
            PREPOSITIONAL = "огромном щупальце голиафа"
	)
	gender = NEUTER
	icon_state = "ancient_goliath_tentacle"
	denied_type = /obj/item/crusher_trophy/eyed_tentacle
	bonus_value = 1

/obj/item/crusher_trophy/eyed_tentacle/effect_desc()
	return "Крушитель наносит на <b>50%</b> больше урона, если у цели больше <b>90%</b> здоровья"

/obj/item/crusher_trophy/eyed_tentacle/on_melee_hit(mob/living/target, mob/living/user)
	var/procent = (target.health / target.maxHealth) * 100
	if(procent < 90)
		return

	var/obj/item/twohanded/kinetic_crusher/crusher = user.get_active_hand()
	if(!crusher)
		return

	target.apply_damage(crusher.force * bonus_value, crusher.damtype, user.zone_selected)

/// Poison fang
/obj/item/crusher_trophy/fang
	name = "Poison fang"
	desc = "Уродливый и ядовитый клык. Может быть установлен на крушитель в качестве трофея." 
	ru_names = list(
            NOMINATIVE = "ядовитый клык",
            GENITIVE = "ядовитого клыка",
            DATIVE = "ядовитому клыку",
            ACCUSATIVE = "ядовитый клык",
            INSTRUMENTAL = "ядовитым клыком",
            PREPOSITIONAL = "ядовытом клыке"
	)
	gender = MALE
	icon_state = "ob_gniga"
	denied_type = /obj/item/crusher_trophy/fang
	bonus_value = 1.1

/obj/item/crusher_trophy/fang/effect_desc()
	return "Фауна получает на <b>10%</b> больше урона в течении <b>2</b> секунд после взрыва метки"

/obj/item/crusher_trophy/fang/on_mark_detonation(mob/living/target, mob/living/user)
	target.apply_status_effect(STATUS_EFFECT_FANG_EXHAUSTION, bonus_value)

/// Frost gland
/obj/item/crusher_trophy/gland
	name = "Frost gland"
	desc = "Замороженная железа. Может быть установлена на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "морозная железа",
            GENITIVE = "морозной железы",
            DATIVE = "морозной железе",
            ACCUSATIVE = "морозную железу",
            INSTRUMENTAL = "морозной железой",
            PREPOSITIONAL = "морозной железе"
	)
	gender = FEMALE
	icon_state = "ice_gniga"
	denied_type = /obj/item/crusher_trophy/gland
	bonus_value = 0.9

/obj/item/crusher_trophy/gland/effect_desc()
	return "Отмеченная дестабилизатором фауна наносит на <b>10%</b> меньше урона"

/obj/item/crusher_trophy/gland/on_mark_application(mob/living/simple_animal/target, datum/status_effect/crusher_mark/mark, had_mark)
	if(had_mark)
		return

	if(!istype(target))
		return

	target.melee_damage_lower *= bonus_value
	target.melee_damage_upper *= bonus_value

/obj/item/crusher_trophy/gland/on_mark_detonation(mob/living/simple_animal/target, mob/living/user)
	if(!istype(target)) // double check
		return

	target.melee_damage_lower /= bonus_value
	target.melee_damage_upper /= bonus_value

//blood-drunk hunter
/obj/item/crusher_trophy/miner_eye
	name = "eye of a blood-drunk hunter"
	desc = "Человеческий глаз с раздробленным в кашу зрачком. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "глаз кровожадного шахтёра",
            GENITIVE = "глаза кровожадного шахтёра",
            DATIVE = "глазу кровожадного шахтёра",
            ACCUSATIVE = "глаз кровожадного шахтёра",
            INSTRUMENTAL = "глазом кровожадного шахтёра",
            PREPOSITIONAL = "глазе кровожадного шахтёра"
	)
	gender = MALE
	icon_state = "hunter_eye"
	denied_type = /obj/item/crusher_trophy/miner_eye

/obj/item/crusher_trophy/miner_eye/effect_desc()
	return "Даёт иммунитет к оглушению и снижает получаемый урона на <b>90%</b> на <b>1</b> секунду после взрыва метки"

/obj/item/crusher_trophy/miner_eye/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_BLOODDRUNK)

//ash drake
/obj/item/crusher_trophy/tail_spike
	desc = "Шип, срезанный с хвоста пепельного дрейка. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "хвостновой шип",
            GENITIVE = "хвостового шипа",
            DATIVE = "хвостовому шипу",
            ACCUSATIVE = "хвостовой шип",
            INSTRUMENTAL = "хвостовым шипом",
            PREPOSITIONAL = "хвостовом шипе"
	)
	gender = MALE
	denied_type = /obj/item/crusher_trophy/tail_spike
	bonus_value = 5

/obj/item/crusher_trophy/tail_spike/effect_desc()
	return "Взрыв метки отталкивает врага и наносит близлежащим существам <b>[bonus_value]</b> единиц[declension_ru(bonus_value, "у", "ы", "")] урона"

/obj/item/crusher_trophy/tail_spike/on_mark_detonation(mob/living/target, mob/living/user)
	for(var/mob/living/L in oview(2, user))
		if(L.stat == DEAD)
			continue
		playsound(L, 'sound/magic/fireball.ogg', 20, 1)
		new /obj/effect/temp_visual/fire(L.loc)
		addtimer(CALLBACK(src, PROC_REF(pushback), L, user), 1) //no free backstabs, we push AFTER module stuff is done
		L.adjustFireLoss(bonus_value)

/obj/item/crusher_trophy/tail_spike/proc/pushback(mob/living/target, mob/living/user)
	if(!QDELETED(target) && !QDELETED(user) && (!target.anchored || ismegafauna(target))) //megafauna will always be pushed
		step(target, get_dir(user, target))

//bubblegum
/obj/item/crusher_trophy/demon_claws
	name = "demon claws"
	desc = "Набор окровавленных когтей, вырванных с руки огромного демона. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "демонические когти",
            GENITIVE = "демонических когтей",
            DATIVE = "демоническим когтям",
            ACCUSATIVE = "демонические когти",
            INSTRUMENTAL = "демоническими когтями",
            PREPOSITIONAL = "демонических когтях"
	)
	icon_state = "demon_claws"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/demon_claws
	bonus_value = 10
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/crusher_trophy/demon_claws/effect_desc()
	return "Ваши удары наносят <b>[bonus_value * 0.2]</b> бонусного урона и восстанавливают вам <b>[bonus_value * 0.1]</b> единиц[declension_ru(bonus_value * 0.1, "у", "ы", "")] здоровья. При взрыве метки эффект пятерной"

/obj/item/crusher_trophy/demon_claws/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force += bonus_value * 0.2
		H.force_unwielded += bonus_value * 0.2
		// don't update force since KCs have 0 force by default
		H.AddComponent(/datum/component/two_handed, force_wielded = H.force_wielded, force_unwielded = H.force)
		H.detonation_damage += bonus_value * 0.8

/obj/item/crusher_trophy/demon_claws/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.force -= bonus_value * 0.2
		H.force_unwielded -= bonus_value * 0.2
		H.AddComponent(/datum/component/two_handed, force_wielded = H.force_wielded, force_unwielded = H.force)
		H.detonation_damage -= bonus_value * 0.8

/obj/item/crusher_trophy/demon_claws/on_melee_hit(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.1, damage_heal_order)

/obj/item/crusher_trophy/demon_claws/on_mark_detonation(mob/living/target, mob/living/user)
	user.heal_ordered_damage(bonus_value * 0.4, damage_heal_order)

//colossus
/obj/item/crusher_trophy/blaster_tubes
	name = "blaster tubes"
	desc = "Бластерные трубки, взятые с руки колосса. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "бластерные трубки",
            GENITIVE = "бластерных трубок",
            DATIVE = "бластерным трубкам",
            ACCUSATIVE = "бластерные трубки",
            INSTRUMENTAL = "бластерными трубками",
            PREPOSITIONAL = "бластерных трубках"
	)
	icon_state = "blaster_tubes"
	gender = PLURAL
	denied_type = /obj/item/crusher_trophy/blaster_tubes
	bonus_value = 15
	var/deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/effect_desc()
	return "После взрыва метки, заменяет дестабилизатор медленным снарядом, наносящим <b>[bonus_value]</b> единиц[declension_ru(bonus_value, "у", "ы", "")] урона."

/obj/item/crusher_trophy/blaster_tubes/on_projectile_fire(obj/projectile/destabilizer/marker, mob/living/user)
	if(deadly_shot)
		marker.name = "deadly [marker.name]"
		marker.icon_state = "chronobolt"
		marker.damage = bonus_value
		marker.nodamage = FALSE
		marker.speed = 2
		deadly_shot = FALSE

/obj/item/crusher_trophy/blaster_tubes/on_mark_detonation(mob/living/target, mob/living/user)
	deadly_shot = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_deadly_shot)), 300, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/crusher_trophy/blaster_tubes/proc/reset_deadly_shot()
	deadly_shot = FALSE

//hierophant
/obj/item/crusher_trophy/vortex_talisman
	name = "vortex talisman"
	desc = "Мерцающий талисман, ранее бывший маяком Иерофанта. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "талисман вихря",
            GENITIVE = "талисмана вихря",
            DATIVE = "талисману вихря",
            ACCUSATIVE = "талисман вихря",
            INSTRUMENTAL = "талисманом вихря",
            PREPOSITIONAL = "талисмане вихря"
	)
	gender = MALE
	icon_state = "vortex_talisman"
	denied_type = /obj/item/crusher_trophy/vortex_talisman

/obj/item/crusher_trophy/vortex_talisman/effect_desc()
	return "Взрыв метки призывает трёх самонаводящихся гончих Иерофанта" //Wall was way too cheesy and allowed miners to be nearly invincible while dumb mob AI just rubbed its face on the wall.

/obj/item/crusher_trophy/vortex_talisman/on_mark_detonation(mob/living/target, mob/living/user)
	if(isliving(target))
		var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(user), user, target, 3, TRUE)
		C.damage = 10 // Weaker because there is no cooldown
		C.monster_damage_boost = FALSE
		add_attack_logs(user, target, "выстрелил гончей в")

//vetus
/obj/item/crusher_trophy/adaptive_intelligence_core
	name = "adaptive intelligence core"
	desc = "Кажется, это одно из ядер огромного робота. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "адаптивное ядро ИИ",
            GENITIVE = "адаптивного ядра ИИ",
            DATIVE = "адаптивному ядру ИИ",
            ACCUSATIVE = "адаптивное ядро ИИ",
            INSTRUMENTAL = "адаптивным ядром ИИ",
            PREPOSITIONAL = "адаптивном ядре ИИ"
	)
	gender = NEUTER
	icon_state = "adaptive_core"
	denied_type = /obj/item/crusher_trophy/adaptive_intelligence_core
	bonus_value = 2

/obj/item/crusher_trophy/adaptive_intelligence_core/effect_desc()
	return "Увеличивает ваш урон на <b>[bonus_value]</b> единиц[declension_ru(bonus_value, "у", "ы", "")] с каждой атакой, до максимума в <b>[bonus_value * 10]</b> единиц[declension_ru(bonus_value, "у", "ы", "")]"

/obj/item/crusher_trophy/adaptive_intelligence_core/add_to(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.adaptive_damage_bonus += bonus_value

/obj/item/crusher_trophy/adaptive_intelligence_core/remove_from(obj/item/twohanded/kinetic_crusher/H, mob/living/user)
	. = ..()
	if(.)
		H.adaptive_damage_bonus -= bonus_value

//legion

/obj/item/crusher_trophy/empowered_legion_skull
	name = "empowered legion skull"
	desc = "Устрашающий череп с горящими красными глазами. Может быть установлено на крушитель в качестве трофея."
	ru_names = list(
            NOMINATIVE = "усиленный череп легиона",
            GENITIVE = "усиленного черепа легиона",
            DATIVE = "усиленному черепу легиона",
            ACCUSATIVE = "усиленный череп легиона",
            INSTRUMENTAL = "усиленным черепом легиона",
            PREPOSITIONAL = "усиленном черепе легиона"
	)
	gender = MALE
	icon_state = "ashen_skull"
	denied_type = /obj/item/crusher_trophy/empowered_legion_skull

/obj/item/crusher_trophy/empowered_legion_skull/effect_desc()
	return "После взрыва метки позволяет вам совершить рывок на <b>3</b> клетки, если вы находитесь в намерении помощи"

/obj/item/crusher_trophy/empowered_legion_skull/on_mark_detonation(mob/living/target, mob/living/user)
	user.apply_status_effect(STATUS_EFFECT_DASH)

//Magmite Crusher

/obj/item/twohanded/kinetic_crusher/mega
	icon_state = "magmite_crusher"
	item_state = "magmite_crusher0"
	name = "magmite proto-kinetic crusher"
	desc = "Ранняя версия Кинетического Акселератора, по сути высокотехнологичный топор улучшенный магмитом. Улучшенный дестабилизатор пробивает породу, как плазменный резак."
	ru_names = list(
            NOMINATIVE = "магмитовый прото-кинетический крушитель",
            GENITIVE = "магмитового прото-кинетического крушителя",
            DATIVE = "магмитовому прото-кинетическому крушителю",
            ACCUSATIVE = "магмитовый прото-кинетический крушитель",
            INSTRUMENTAL = "магмитовым прото-кинетическим крушителем",
            PREPOSITIONAL = "магмитовом прото-кинетическом крушителе"
	)
	gender = MALE
	destab = /obj/projectile/destabilizer/mega
	upgraded = TRUE

/obj/projectile/destabilizer/mega
	icon_state = "pulse0"
	range = 4 //you know....

/obj/projectile/destabilizer/mega/on_hit(atom/target, blocked = FALSE)
	var/target_turf = get_turf(target)
	if(ismineralturf(target_turf))
		if(isancientturf(target_turf))
			visible_message(span_notice("Похоже, что эту породу возьмёт только кирка!"))
			forcedodge = 0
		else
			var/turf/simulated/mineral/M = target_turf
			new /obj/effect/temp_visual/kinetic_blast(M)
			forcedodge = 1
			M.attempt_drill(firer)
	else
		forcedodge = 0
	..()
