/turf/simulated/wall/mineral/titanium/reinforced
	name = "reinforced titanium wall"
	desc = "TEMP123TEMP"
	icon = 'icons/turf/walls/ship_titanium.dmi'
	icon_state = "ship_wall-0"
	base_icon_state = "ship_wall"
	damage_cap = 125

/turf/simulated/wall/mineral/titanium/reinforced/get_ru_names()
	return alist(
		NOMINATIVE = "укреплённая титановая стена",
		GENITIVE = "укреплённой титановой стены",
		DATIVE = "укреплённой титановой стене",
		ACCUSATIVE = "укреплённую титановую стену",
		INSTRUMENTAL = "укреплённой титановой стеной",
		PREPOSITIONAL = "укреплённой титановой стене",
	)

/turf/simulated/wall/mineral/plastitanium/get_ru_names()
	return alist(
		NOMINATIVE = "пластитановая стена",
		GENITIVE = "пластитановой стены",
		DATIVE = "пластитановой стене",
		ACCUSATIVE = "пластитановую стену",
		INSTRUMENTAL = "пластитановой стеной",
		PREPOSITIONAL = "пластитановой стене",
	)

/turf/simulated/wall/mineral/plastitanium/attackby(obj/item/item, mob/user, params)
	if(!reinforcement_type || !istype(item, reinforcement_material))
		return ..()
	var/obj/item/stack/material = item
	if(!isturf(user.loc) || material.loc != user || !user.Adjacent(src))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(material.get_amount() < reinforcement_amount)
		to_chat(user, span_warning("Необходимо [reinforcement_amount] ед. материала."))
		return ATTACK_CHAIN_BLOCKED_ALL
	var/original_type = type
	to_chat(user, span_notice("Вы начинаете укреплять [declent_ru(ACCUSATIVE)]."))
	CALCULATE_SKILL_MOD(user, BUILDING_SPEED_MOD, building_mod)
	if(!do_after(user, 4 SECONDS * building_mod, src, category = DA_CAT_TOOL, max_interact_count = 1))
		return ATTACK_CHAIN_BLOCKED_ALL
	if(QDELETED(src) || type != original_type)
		return ATTACK_CHAIN_BLOCKED_ALL
	if(apply_reinforcement(material, user))
		to_chat(user, span_notice("Стена укреплена."))
	return ATTACK_CHAIN_BLOCKED_ALL

/turf/simulated/wall/mineral/plastitanium/proc/apply_reinforcement(obj/item/stack/material, mob/user)
	if(!reinforcement_type || QDELETED(material) || !istype(material, reinforcement_material) || !user || !isturf(user.loc) || !user.Adjacent(src) || material.loc != user)
		return null
	if(!material.use(reinforcement_amount))
		return null
	var/previous_damage = damage
	var/turf/simulated/wall/upgraded = ChangeTurf(reinforcement_type)
	upgraded.damage = previous_damage
	upgraded.add_fingerprint(user)
	upgraded.update_damage()
	return upgraded

/turf/simulated/wall/mineral/plastitanium/composite
	name = "composite wall"
	desc = "TEMP123TEMP"
	icon = 'icons/turf/walls/ship_plastitanium.dmi'
	icon_state = "ship_wall-0"
	base_icon_state = "ship_wall"
	damage_cap = 400
	reinforcement_material = /obj/item/stack/rods/fireproof
	reinforcement_amount = 4
	reinforcement_type = /turf/simulated/wall/mineral/plastitanium/reinforced

/turf/simulated/wall/mineral/plastitanium/composite/get_ru_names()
	return alist(
		NOMINATIVE = "композитная стена",
		GENITIVE = "композитной стены",
		DATIVE = "композитной стене",
		ACCUSATIVE = "композитную стену",
		INSTRUMENTAL = "композитной стеной",
		PREPOSITIONAL = "композитной стене",
	)

/turf/simulated/wall/mineral/plastitanium/reinforced
	parent_type = /turf/simulated/wall/mineral/plastitanium/composite
	name = "reinforced plastitanium wall"
	icon = 'icons/turf/walls/ship_reinforced_plastitanium.dmi'
	damage_cap = 650
	reinforcement_material = /obj/item/stack/sheet/mineral/abductor
	reinforcement_amount = 6
	reinforcement_type = /turf/simulated/wall/mineral/plastitanium/reinforced/xeno

/turf/simulated/wall/mineral/plastitanium/reinforced/get_ru_names()
	return alist(
		NOMINATIVE = "укреплённая пластитановая стена",
		GENITIVE = "укреплённой пластитановой стены",
		DATIVE = "укреплённой пластитановой стене",
		ACCUSATIVE = "укреплённую пластитановую стену",
		INSTRUMENTAL = "укреплённой пластитановой стеной",
		PREPOSITIONAL = "укреплённой пластитановой стене",
	)

/turf/simulated/wall/mineral/plastitanium/reinforced/xeno
	name = "xeno-alloy wall"
	icon = 'icons/turf/walls/ship_xeno.dmi'
	damage_cap = 1150
	reinforcement_material = null
	reinforcement_amount = 0
	reinforcement_type = null

/turf/simulated/wall/mineral/plastitanium/reinforced/xeno/get_ru_names()
	return alist(
		NOMINATIVE = "ксеносплавная стена",
		GENITIVE = "ксеносплавной стены",
		DATIVE = "ксеносплавной стене",
		ACCUSATIVE = "ксеносплавную стену",
		INSTRUMENTAL = "ксеносплавной стеной",
		PREPOSITIONAL = "ксеносплавной стене",
	)
