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

/datum/anomaly_impulse/proc/animate_shake(atom/target, shake_count = 5, x_amplitude = 2, y_amplitude = 2)
    // Wiggles the sprite around on its tile then returns it to normal
    if(!istype(target))
        return
    if(!isnum(shake_count) || !isnum(x_amplitude) || !isnum(y_amplitude))
        return

    shake_count = max(1, min(shake_count, 50))
    x_amplitude = max(-32, min(x_amplitude, 32))
    y_amplitude = max(-32, min(y_amplitude, 32))

    var/negative_x_amplitude = 0 - x_amplitude
    var/negative_y_amplitude = 0 - y_amplitude

    animate(
        target,
        transform = null,
        pixel_y = rand(negative_y_amplitude, y_amplitude),
        pixel_x = rand(negative_x_amplitude, x_amplitude),
        time = 1,
        loop = shake_count,
        easing = ELASTIC_EASING,
        flags = ANIMATION_PARALLEL
    )

    addtimer(CALLBACK(src, PROC_REF(reset_animation), target), shake_count)

/datum/anomaly_impulse/proc/reset_animation(atom/target)
    if(!istype(target))
        return

    animate(
        target,
        transform = null,
        pixel_y = 0,
        pixel_x = 0,
        time = 1,
        loop = 1,
        easing = LINEAR_EASING,
        flags = ANIMATION_PARALLEL
    )

/datum/anomaly_impulse/proc/scale_by_strength(l_val, r_val)
	return round(l_val + (r_val - l_val) * owner.get_strength() / 100)
