/area/station/security
	ambience_index = AMBIENCE_DANGER
	sound_environment = SOUND_AREA_STANDARD_STATION
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/station/security/main
	name = "Security Office"
	icon_state = "securityoffice"

/area/station/security/lobby
	name = "Security Lobby"
	icon_state = "securitylobby"

/area/station/security/brig
	name = "Brig"
	icon_state = "brig"

/area/station/security/brig/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/station/security/prison/perma
	name = "Perma Prison Wing"
	icon_state = "sec_prison_perma"
	fast_despawn = TRUE

/area/station/security/prison
	name = "Prison Wing"
	icon_state = "sec_prison"
	can_get_auto_cryod = FALSE

/area/station/security/prison/prison_break()
	for(var/obj/structure/closet/secure_closet/brig/temp_closet in src)
		temp_closet.locked = 0
		temp_closet.update_icon()
	for(var/obj/machinery/door_timer/temp_timer in machinery_cache)
		temp_timer.releasetime = 1
	return ..()

/area/station/security/prison/cell_block
	name = "Prison Cell Block"
	icon_state = "brig"

/area/station/security/prison/cell_block/secondary
	name = "Prison Cell Block A"
	icon_state = "brigcella"

/area/station/security/hallway/reception
	name = "Brig Reception"
	icon_state = "brig"

/area/station/security/hallway/execution
	name = "Execution"
	icon_state = "execution"
	can_get_auto_cryod = FALSE

/area/station/security/hallway/perma
	name = "Permabrig Hallway"
	icon_state = "sec_prison_perma"

/area/station/security/processing
	name = "Prisoner Processing"
	icon_state = "prisonerprocessing"
	can_get_auto_cryod = FALSE

/area/station/security/interrogation
	name = "Interrogation"
	icon_state = "interrogation"
	can_get_auto_cryod = FALSE

/area/station/security/storage
	name = "Security Equipment Storage"
	icon_state = "securityequipmentstorage"

/area/station/security/courtroom
	name = "Brig Staff Room"
	icon_state = "brig"

/area/station/security/evidence
	name = "Evidence Room"
	icon_state = "evidence"

/area/station/security/prison/visit
	name = "Visiting Room"
	icon_state = "visiting-room"

/area/station/security/prison/lockers
	name = "Prisoner Lockers"
	icon_state = "sec_prison_lockers"

/area/station/security/medical
	name = "Security Medbay"
	icon_state = "security_medbay"

/area/station/security/prisoner_shuttle
	name = "Security Prisoner Shuttle"
	icon_state = "security"
	can_get_auto_cryod = FALSE

/area/station/security/warden
	name = "Warden's Office"
	icon_state = "Warden"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR

/area/station/security/hallway/armory
	name = "Secure Armory"
	icon_state = "secarmory"

/area/station/security/hallway/secure
	name = "Brig Secure Hallway"
	icon_state = "securehall"

/area/station/security/podbay
	name = "Security Podbay"
	icon_state = "securitypodbay"

/area/station/security/detectives_office
	name = "Detective's Office"
	icon_state = "detective"
	ambientsounds = list(
		'sound/ambience/security/ambidet1.ogg',
		'sound/ambience/security/ambidet2.ogg',
	)

/area/station/security/range
	name = "Firing Range"
	icon_state = "firingrange"

/area/station/command/vault
	name = "Vault"
	icon_state = "nuke_storage"
	holomap_color = HOLOMAP_AREACOLOR_COMMAND

/area/station/security/customs
	name = "Customs"
	icon_state = "checkpoint1"

/area/station/security/customs/secondary
	name = "Customs Secondary"
	icon_state = "security"

/area/station/security/checkpoint
	name = "Security Checkpoint"
	icon_state = "checkpoint1"

/area/station/security/checkpoint/south
	name = "Escape Security Checkpoint"
	icon_state = "security"

/area/station/legal/office/law
	name = "Law Office"
	icon_state = "law"
	sound_environment = SOUND_AREA_SMALL_SOFTFLOOR
	holomap_color = HOLOMAP_AREACOLOR_SECURITY

/area/station/security/checkpoint/customs
	name = "Command Checkpoint"

/area/station/security/checkpoint/fore
	name = "North Command Checkpoint"

/area/station/security/checkpoint/aft
	name = "South Command Checkpoint"
