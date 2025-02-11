//Academy Areas

/area/awaymission/academy
	name = "\improper Academy Asteroids"
	icon_state = "away"
	report_alerts = FALSE
	no_teleportlocs = TRUE
	tele_proof = TRUE

/area/awaymission/academy/headmaster
	name = "\improper Academy Fore Block"
	icon_state = "away1"

/area/awaymission/academy/classrooms
	name = "\improper Academy Classroom Block"
	icon_state = "away2"

/area/awaymission/academy/academyaft
	name = "\improper Academy Ship Aft Block"
	icon_state = "away3"

/area/awaymission/academy/academygate
	name = "\improper Academy Gateway"
	icon_state = "away4"

//Academy Items

/obj/singularity/academy
	dissipate = 0
	move_self = 0
	grav_pull = 1

/obj/singularity/academy/admin_investigate_setup()
	return

/obj/singularity/academy/process()
	eat()
	if(prob(1))
		mezzer()

/obj/item/clothing/glasses/meson/truesight
	name = "The Lens of Truesight"
	desc = "I can see forever!"
	icon_state = "monocle"
	item_state = "headset"


// Butler outfit
/datum/outfit/butler
	name = "Butler"
	uniform = /obj/item/clothing/under/suit_jacket/really_black
	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowlerhat
	glasses = /obj/item/clothing/glasses/monocle
	gloves = /obj/item/clothing/gloves/color/white

/obj/effect/bump_teleporter/academy_no_mesons
    var/list/items_to_remove = list(
		/obj/item/clothing/glasses/meson,
		/obj/item/clothing/glasses/hud/health/meson,
		/obj/item/clothing/head/helmet/meson,
		/obj/item/organ/internal/cyberimp/eyes/meson,
		/obj/item/organ/internal/cyberimp/eyes/xray
	)

/obj/effect/bump_teleporter/academy_no_mesons/process_special_effects(mob/living/target)
	process_item_removal(target)

/obj/effect/bump_teleporter/academy_no_mesons/proc/process_item_removal(mob/living/target)
	if(!istype(target))
		return
	for(var/item in items_to_remove)
		remove_item_type(target, item)

/obj/effect/bump_teleporter/academy_no_mesons/proc/remove_item_type(mob/living/target, item_type)
	var/list/items = target.search_contents_for(item_type)
	for(var/it in items)
		var/obj/item = it
		qdel(item)

