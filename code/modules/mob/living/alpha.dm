/mob/living/proc/alpha_update()
	var/result = 1
	for(var/source in alphas)
		result *= alphas[source]

	alpha = LIGHTING_PLANE_ALPHA_VISIBLE * result


/mob/living/proc/alpha_prepare(source)
	if(!alphas)
		alphas = list(ALPHA_SOURCE_DEFAULT = 1)

	if(!(source in alphas))
		alphas[source] = 1


/mob/living/proc/alpha_finalise(source)
	alphas[source] = clamp(alphas[source], 0, 1)
	if(alphas[source] == 1 && source != ALPHA_SOURCE_DEFAULT)
		alphas.Remove(source)

	alpha_update()
	if(alphas.len != 1 || alphas[ALPHA_SOURCE_DEFAULT] != 1)
		return

	alphas = null


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
	alpha_prepare(source)
	var/result = alphas[source]
	alpha_finalise(source)
	return result
