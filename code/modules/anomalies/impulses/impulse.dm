/datum/anomaly_impulse
	/// Name of this type of impulse. Used for scanning anomalies.
	var/name = ""
	/// Description of the effects of this type of pulses. Used when scanning anomalies.
	var/desc = ""
	/// Mimimum time between bursts of this type of impulse.
	var/period_low = -1
	/// Maximum time between bursts of this type of impulse.
	var/period_high = -1
	/// Maximum lewel of stability when impulse can activate.
	var/stability_high = 100
	/// If TRUE, anomaly will shake when this impulse activates.
	var/do_shake = TRUE
	/// The object emitting the pulse. If it does not exist, the pulse should be removed.
	var/obj/effect/anomaly/owner = null

/datum/anomaly_impulse/New(owner)
	. = ..()
	src.owner = owner

/datum/anomaly_impulse/proc/impulse_cycle()
	if(QDELETED(owner))
		return FALSE

	if(scale_by_strength(period_high, period_low) <= 0)
		return

	addtimer(CALLBACK(src, PROC_REF(impulse_cycle)), scale_by_strength(period_high, period_low))
	if(world.time < owner.move_impulse_moment && istype(src, /datum/anomaly_impulse/move))
		return

	if(owner.stability < stability_high)
		impulse()

/datum/anomaly_impulse/proc/impulse()
	if(do_shake)
		animate_shake(src)

/datum/anomaly_impulse/proc/scale_by_strength(l_val, r_val)
	return round(l_val + (r_val - l_val) * owner.get_strength() / 100)
