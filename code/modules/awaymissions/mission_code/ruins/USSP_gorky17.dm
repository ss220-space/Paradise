/area/ruin/space/USSP_gorky17/solpanel1
	name = "North sol panels"
	icon_state = "away1"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/solpanel2
	name = "South sol panels"
	icon_state = "away2"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/medbay
	name = "Medbay zone"
	icon_state = "away3"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/gate
	name = "Gate zone"
	icon_state = "away4"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/angar
	name = "Space pods zone"
	icon_state = "away5"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/utility
	name = "Utility room"
	icon_state = "away6"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/kitchen
	name = "Kitchen"
	icon_state = "away7"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/dinning
	name = "Dinning room"
	icon_state = "away8"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/engineering
	name = "Engineering room"
	icon_state = "away9"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Arrivals zone"
	icon_state = "away10"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Arrivals zone"
	icon_state = "away11"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/check1
	name = "Arrivals check point room"
	icon_state = "away12"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/check2
	name = "Gate check point room"
	icon_state = "away13"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Arrivals zone"
	icon_state = "away14"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/dorms
	name = "Dormitories zone"
	icon_state = "away15"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/common
	name = "Common hall zone"
	icon_state = "away16"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/bridge
	name = "Bridge zone"
	icon_state = "away17"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/core
	name = "Data centre zone"
	icon_state = "away18"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/rnd
	name = "RnD zone"
	icon_state = "away19"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17mining
	name = "Ore melting zone"
	icon_state = "away20"
	requires_power = TRUE
	has_gravity = FALSE

/area/ruin/space/USSP_gorky17/asteroids
	name = "Asteroids"
	icon_state = "away21"
	requires_power = FALSE
	has_gravity = FALSE

//// Safe with secret documets

/obj/item/paper/researchnotes/mat_bio_prog

/obj/item/paper/researchnotes/mat_bio_prog/New()
	..()
	var/list/possible_techs = list("materials", "biotech", "programming")
	var/mytech = pick(possible_techs)
	var/mylevel = rand(6, 8)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

/obj/structure/safe/random_researchnotes_MatBioProg/Initialize()
	var/tech_spawn = pick(list(/obj/item/paper/researchnotes/mat_bio_prog))
	new tech_spawn(loc)
	return ..()

/obj/structure/safe/floor/random_researchnotes_MatBioProg/Initialize()
	var/tech_spawn = pick(list(/obj/item/paper/researchnotes/mat_bio_prog))
	new tech_spawn(loc)
	return ..()

/obj/structure/safe/random_documents/Initialize()
	var/doc_spawn = pick(list(/obj/item/documents, /obj/item/documents/nanotrasen, /obj/item/documents/syndicate, /obj/item/documents/syndicate/yellow/trapped))
	new doc_spawn(loc)
	return ..()

////// USSP access update

/obj/machinery/computer/id_upgrader/ussp
	name = "ID Upgrade Machine"
	icon_state = "guest"
	icon_screen = "pass"
	access_to_give = list(ACCESS_USSP_TOURIST)
	beenused = 0

/obj/machinery/computer/id_upgrader/ussp/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		var/obj/item/card/id/D = I.GetID()
		if(!access_to_give.len)
			to_chat(user, "<span class='notice'>This machine appears to be configured incorrectly.</span>")
			return
		var/did_upgrade = 0
		var/list/id_access = D.GetAccess()
		for(var/this_access in access_to_give)
			if(!(this_access in id_access))
				// don't have it - add it
				D.access |= this_access
				did_upgrade = 1
		if(did_upgrade)
			to_chat(user, "<span class='notice'>New rank has been assigned to comrade.</span>")
			playsound(src, 'sound/machines/chime.ogg', 30, 0)
			if(beenused)
				return
		else
			to_chat(user, "<span class='notice'>This ID card already has all the access this machine can give.</span>")
		return
	return ..()

/obj/machinery/computer/id_upgrader/ussp/conscript
	access_to_give = list(ACCESS_USSP_CONSCRIPT)

/obj/machinery/computer/id_upgrader/ussp/soldier
	access_to_give = list(ACCESS_USSP_SOLDIER)
