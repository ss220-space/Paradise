/datum/action/cooldown/spell/nightvision
	name = "Toggle Nightvision"
	desc = "Toggle your nightvision mode."
	cooldown_time = 1 SECONDS
	spell_requirements = NONE
	check_flags = NONE

/datum/action/cooldown/spell/nightvision/cast(atom/cast_on)
	. = ..()
	if(!isliving(cast_on))
		return
	var/mob/living/caster = cast_on
	switch(caster.lighting_alpha)
		if(LIGHTING_PLANE_ALPHA_VISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			name = "Toggle Nightvision \[More]"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
			name = "Toggle Nightvision \[Full]"
		if(LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE)
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
			name = "Toggle Nightvision \[OFF]"
		else
			caster.lighting_alpha = LIGHTING_PLANE_ALPHA_VISIBLE
			name = "Toggle Nightvision \[ON]"
	caster.update_sight()
	to_chat(caster, span_notice("Вы переключаете ночное зрение."))

