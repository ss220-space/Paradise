/datum/action/cooldown/spell/aoe/knock
	name = "Knock"
	desc = "This spell opens nearby doors and does not require wizard garb."

	school = "transmutation"
	cooldown_time = 2 SECONDS //20 deciseconds reduction per rank
	spell_requirements = null
	invocation = "AULIE OXIN FIERA"
	invocation_type = INVOCATION_WHISPER

	button_icon_state = "knock"
	sound = 'sound/magic/knock.ogg'
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/knock/get_things_to_cast_on(atom/center)
	var/list/things = list()

	for(var/obj/machinery/door/door in range(aoe_radius, center))
		if(istype(door, /obj/machinery/door/airlock/hatch/gamma))
			continue
		things += door

	for(var/obj/structure/closet/closet in range(aoe_radius, center))
		things += closet

	return things

/datum/action/cooldown/spell/aoe/knock/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(is_door(victim))
		var/obj/machinery/door/door = victim
		if(is_airlock(door))
			var/obj/machinery/door/airlock/airlock = door
			airlock.unlock(TRUE)
		door.open()
		return
	if(is_closet(victim))
		var/obj/structure/closet/closet = victim
		if(is_secure_closet(closet))
			var/obj/structure/closet/secure_closet/s_closet = closet
			s_closet.locked = FALSE
		closet.open()
