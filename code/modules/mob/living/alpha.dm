/mob/living/proc/alpha_update()
	var/result = 1
	for(var/source in alphas)
		result *= alphas[source]

	alpha = LIGHTING_PLANE_ALPHA_VISIBLE * result

/mob/living/proc/alpha_prepare(source)
	if(!(source in alphas))
		alphas[source] = 1

/mob/living/proc/alpha_finalise(source)
	alphas[source] = clamp(alphas[source], 0, 1)
	if(alphas[source] == 1 && source != ALPHA_SOURCE_DEFAULT)
		alphas.Remove(source)

	alpha_update()

/mob/living/proc/alpha_add(val, source = ALPHA_SOURCE_DEFAULT)
	alpha_prepare(source)
	alphas[source] += val
	alpha_finalise(source)

/mob/living/proc/alpha_multiply(val, source = ALPHA_SOURCE_DEFAULT)
	alpha_prepare(source)
	alphas[source] *= val
	alpha_finalise(source)

/mob/living/proc/alpha_set(val, source = ALPHA_SOURCE_DEFAULT)
	alpha_prepare(source)
	alphas[source] = val
	alpha_finalise(source)

/mob/living/proc/alpha_get(source = ALPHA_SOURCE_DEFAULT)
	return alphas[source]
