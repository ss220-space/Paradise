/datum/action/cooldown/spell/aoe/devil_fire
	name = "Дьявольский огонь"
	desc = "Призывает огненные волны в радиусе заклинания."
	button_icon_state = "explosion_old"

	cooldown_time = 15 SECONDS
	aoe_radius = 10
	invocation = "Che? non ' stimiti te faccende del inferno!"
	invocation_type = INVOCATION_SHOUT

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	targeting_type = /datum/aoe_targeting/living_and_turf
	var/fire_prob = 50
	var/slow_time = 5 SECONDS

/datum/action/cooldown/spell/aoe/devil_fire/cast(atom/cast_on)
	var/obj/item/clothing/suit/straight_jacket/jacket = owner.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)

	if(istype(jacket))
		owner.temporarily_remove_item_from_inventory(jacket, force = TRUE)
		owner.visible_message(span_warning("[jacket.declent_ru(NOMINATIVE)] сгорает в адском пламени!"), \
							span_warning("Вы испепеляете сковывающую вас [jacket.declent_ru(ACCUSATIVE)]!"))
		qdel(jacket)
	. = ..()

/datum/action/cooldown/spell/aoe/devil_fire/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(isliving(victim))
		cast_on_mob(victim)
		return
	cast_on_turf(victim)

/datum/action/cooldown/spell/aoe/devil_fire/proc/cast_on_mob(mob/living/victim)
	victim.Slowed(slow_time)

/datum/action/cooldown/spell/aoe/devil_fire/proc/cast_on_turf(turf/target)
	if(!prob(fire_prob))
		return

	var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(target)
	hotspot.temperature = 3000
	hotspot.recolor()
	target.hotspot_expose(2000, 50)

