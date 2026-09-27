/datum/movespeed_modifier/glitch_slowdown
	multiplicative_slowdown = 1.5

/datum/component/glitch
	var/datum/weakref/forge_ref

/datum/component/glitch/Initialize(obj/machinery/quantum_server/server, obj/machinery/byteforge/forge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	var/mob/living/owner = parent
	var/health_boost = 0

	if(forge)
		RegisterSignal(forge, COMSIG_MACHINERY_POWER_RESTORED, PROC_REF(on_forge_power_restored))
		RegisterSignals(forge, list(COMSIG_MACHINERY_BROKEN, COMSIG_MACHINERY_POWER_LOST), PROC_REF(on_forge_broken))
		forge_ref = WEAKREF(forge)
		server.remove_threat(owner)
		health_boost = ROUND_UP(server.threat * 0.2)

	owner.faction = list(ROLE_GLITCH)
	owner.maxHealth = clamp(owner.maxHealth + health_boost, 200, 500)
	owner.revive()

/datum/component/glitch/RegisterWithParent()
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/component/glitch/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_LIVING_DEATH)
	var/mob/living/owner = parent
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/glitch_slowdown)
	owner.clear_alert(ALERT_BITRUNNER_GLITCH)

/datum/component/glitch/proc/on_death()
	SIGNAL_HANDLER

	if(QDELETED(parent))
		return

	var/mob/living/owner = parent
	to_chat(owner, span_userdanger("Вас пробирает странное ощущение..."))

	var/obj/machinery/byteforge/forge = forge_ref?.resolve()
	forge?.setup_particles()

	owner.fade_into_nothing(3 SECONDS, 2 SECONDS)

/datum/component/glitch/proc/on_forge_broken(datum/source)
	SIGNAL_HANDLER

	var/mob/living/owner = parent
	owner.throw_alert(ALERT_BITRUNNER_GLITCH, /atom/movable/screen/alert/bitrunning/forge_broken, new_master = source)

	if(!iscarbon(parent))
		return

	owner.add_movespeed_modifier(/datum/movespeed_modifier/glitch_slowdown)
	to_chat(owner, span_danger("Тело наливается свинцом..."))

/datum/component/glitch/proc/on_forge_power_restored(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/byteforge/forge = source
	forge.setup_particles(TRUE)

	if(!iscarbon(parent))
		return

	var/mob/living/owner = parent
	owner.clear_alert(ALERT_BITRUNNER_GLITCH)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/glitch_slowdown)
