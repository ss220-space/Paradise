/area/ruin/space/USSP_gorky17/solpanel1
	name = "Gorky17 North sol panels"
	icon_state = "away1"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/solpanel2
	name = "Gorky17 South sol panels"
	icon_state = "away2"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/medbay
	name = "Gorky17 Medbay zone"
	icon_state = "away3"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/gate
	name = "Gorky17 Gate zone"
	icon_state = "away4"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/angar
	name = "Gorky17 Space pods zone"
	icon_state = "away5"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/utility
	name = "Gorky17 Utility room"
	icon_state = "away6"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/kitchen
	name = "Gorky17 Kitchen"
	icon_state = "away7"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/dinning
	name = "Gorky17 Dinning room"
	icon_state = "away8"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/engineering
	name = "Gorky17 Engineering room"
	icon_state = "away9"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Gorky17 Arrivals zone"
	icon_state = "away10"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Gorky17 Arrivals zone"
	icon_state = "away11"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/check1
	name = "Gorky17 Arrivals check point room"
	icon_state = "away12"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/check2
	name = "Gorky17 Gate check point room"
	icon_state = "away13"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/arrival
	name = "Gorky17 Arrivals zone"
	icon_state = "away14"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/dorms
	name = "Gorky17 Dormitories zone"
	icon_state = "away15"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/common
	name = "Gorky17 Common hall zone"
	icon_state = "away16"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/bridge
	name = "Gorky17 Bridge zone"
	icon_state = "away17"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/core
	name = "Gorky17 Data centre room"
	icon_state = "away18"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/rnd
	name = "Gorky17 Gorky17 RnD zone"
	icon_state = "away19"
	requires_power = TRUE

/area/ruin/space/USSP_gorky17mining
	name = "Gorky17 Ore melting zone"
	icon_state = "away20"
	requires_power = TRUE
	has_gravity = FALSE

/area/ruin/space/USSP_gorky17/asteroids
	name = "Gorky17 Asteroids"
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
	var/ranktogive = "Soviet Tourist"

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
			giverank(D)
			to_chat(user, "<span class='notice'>New rank has been assigned to comrade.</span>")
			playsound(src, 'sound/machines/chime.ogg', 30, 0)
		else
			to_chat(user, "<span class='notice'>This ID card already has all the access this machine can give.</span>")
		return
	return ..()

/obj/machinery/computer/id_upgrader/ussp/proc/giverank(obj/item/card/id/D)
	if(D)
		D.rank = ranktogive
		D.assignment = ranktogive
		D.UpdateName()

/obj/machinery/computer/id_upgrader/ussp/conscript
	access_to_give = list(ACCESS_USSP_CONSCRIPT)
	ranktogive = "Soviet Conscript"

/obj/machinery/computer/id_upgrader/ussp/soldier
	access_to_give = list(ACCESS_USSP_SOLDIER)
	ranktogive = "Soviet Soldier"

/obj/machinery/computer/id_upgrader/ussp/soldier
	access_to_give = list(ACCESS_USSP_MARINE)
	ranktogive = "Soviet Marine"
