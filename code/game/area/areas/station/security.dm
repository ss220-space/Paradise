/area/security
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/security/brig
	name = "Brig"
	icon_state = "brig"

/area/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/security/permabrig
	name = "Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE
	can_get_auto_cryod = FALSE

/area/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/security/prison/cell_block
	name = "Prison Cell Block"
	icon_state = "brig"

/area/security/prison/cell_block/A
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/security/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/security/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/security/permahallway
	name = "Permabrig Hallway"
	icon_state = "sec_prison_perma"

/area/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/security/seceqstorage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/security/brigstaff
	name = "Brig Staff Room"
	icon_state = "brig"

/area/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/security/visiting_room
	name = "Visiting Room"
	icon_state = "visiting-room"

/area/security/prisonlockers
	name = "Prisoner Lockers"
	icon_state = "sec_prison_lockers"
	can_get_auto_cryod = FALSE

/area/security/medbay
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/security/prisonershuttle
	name = "Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/security/warden
	name = "Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/security/securearmory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/security/securehallway
	name = "Brig Secure Hallway"
	icon_state = "securehall"

/area/security/hos
	name = "Head of Security's Office"
	icon_state = "sec_hos"

/area/security/podbay
	name = "Security Podbay"
	icon_state = "securitypodbay"

/area/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/security/nuke_storage
	name = "Vault"
	icon_state = "nuke_storage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/security/customs2
	name = "Customs"
	icon_state = "security"

/area/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/security/checkpoint/south
	name = "Escape Security Checkpoint"
	icon_state = "security"

/area/lawoffice
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/bridge/checkpoint
	name = "Command Checkpoint"

/area/bridge/checkpoint/north
	name = "North Command Checkpoint"

/area/bridge/checkpoint/south
	name = "South Command Checkpoint"
