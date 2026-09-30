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
	///The mob to return the spear to if thrown
	var/mob/living/carbon/returner
	/// Did our spear return to us, when we miss?
	var/recall_after_miss = FALSE
	/// Core of our spear, without it it's just a dud
	var/obj/item/mining_spear_core/core

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

	if(!thrower)
		return
	if(recall_after_miss)
		returner = thrower
		RegisterSignal(src, COMSIG_MOVABLE_THROW_LANDED, PROC_REF(return_spear_to_user))
	//point the spear in the direction it's being thrown
	var/angle = get_angle(target, thrower)
	var/matrix/turn_matrix = matrix(transform)
	turn_matrix.Turn(angle)
	turn_matrix.Turn(135) //because the javelin sprite itself is angled
	transform = turn_matrix

	return ..()

/obj/item/twohanded/mining_spear/after_throw(datum/callback/callback)
	var/matrix/turn_matrix = matrix()
	transform = turn_matrix
	return ..()

/obj/item/twohanded/mining_spear/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!core)
		throwforce = 0 //more like sanity check, because all that stuff already should be stated when core is removed
		sharp = FALSE
		return ..()
	return ..()

//obj/item/twohanded/mining_spear/on_human_ebedded(mob/living/carbon/human/target)

/obj/item/twohanded/mining_spear/proc/return_spear_to_user()
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_THROW_LANDED)
	if(returner)
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
	spear.force = 10
	spear.force_unwielded = 10
	spear.force_wielded = 18
	spear.throwforce = 15
	spear.armour_penetration = 10
	spear.sharp = TRUE
	embed_chance = 50

/obj/item/mining_spear_core/proc/on_remove(obj/item/twohanded/mining_spear/spear)
	spear.force = initial(spear.force)
	spear.force_unwielded = initial(spear.force_unwielded)
	spear.force_wielded = initial(spear.force_wielded)
	spear.throwforce = initial(spear.throwforce)
	spear.armour_penetration = initial(spear.armour_penetration)
	spear.sharp = initial(spear.sharp)
	spear.embed_chance = initial(spear.embed_chance)

/obj/item/mining_spear_core/standart
	name = "standart spear core"
	desc = "Стандартное ядро кинетического копья. Не имеет явных особенностей по сравнению с другими копьями."

/obj/item/mining_spear_core/standart/get_ru_names()
	return alist(
			NOMINATIVE = "стандартное ядро прото-кинетического попья",
			GENITIVE = "стандартного ядра прото-кинетического попья",
			DATIVE = "стандартному ядру прото-кинетического попья",
			ACCUSATIVE = "стандартное ядро прото-кинетического попья",
			INSTRUMENTAL = "стандартным ядром прото-кинетического попья",
			PREPOSITIONAL = "стандартном ядре прото-кинетического попья",
	)
