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
	switch(caster.lighting_cutoff)
		if(LIGHTING_CUTOFF_VISIBLE)
			caster.lighting_cutoff = LIGHTING_CUTOFF_MEDIUM
			name = "Toggle Nightvision \[More]"
		if(LIGHTING_CUTOFF_MEDIUM)
			caster.lighting_cutoff = LIGHTING_CUTOFF_HIGH
			name = "Toggle Nightvision \[Full]"
		if(LIGHTING_CUTOFF_HIGH)
			caster.lighting_cutoff = LIGHTING_CUTOFF_FULLBRIGHT
			name = "Toggle Nightvision \[OFF]"
		else
			caster.lighting_cutoff = LIGHTING_CUTOFF_VISIBLE
			name = "Toggle Nightvision \[ON]"
	caster.update_sight()
	to_chat(caster, span_notice("Вы переключаете ночное зрение."))

