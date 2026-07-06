#define REVIVE_SPELL_TIME 5 MINUTES
#define REVIVE_SPELL_NECROSIS_PROB 30

/datum/action/cooldown/spell/touch/revive_touch
	name = "Воскрешающее косание"
	desc = "Чрезвычайно могущественное некромантическое заклинание"
	hand_path = /obj/item/melee/touch_attack/revive_touch
	school = SCHOOL_NECROMANCY
	invocation = "Surge e lecto!"
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	button_icon_state = "revive"
	sound = 'sound/magic/staff_healing.ogg'

/obj/item/melee/touch_attack/revive_touch
	name = "воскрешающее касание"
	desc = "Воскрешает тело умершего на определенное время."
	icon_state = "disintegrate"
	color = "#acb78e"

/obj/item/melee/touch_attack/revive_touch/get_ru_names()
	return alist(
		NOMINATIVE = "воскрешающее касание",
		GENITIVE = "воскрешающего касания",
		DATIVE = "воскрешающему касанию",
		ACCUSATIVE = "воскрешающее касание",
		INSTRUMENTAL = "воскрешающим касанием",
		PREPOSITIONAL = "воскрешающем касании",
	)

/datum/action/cooldown/spell/touch/revive_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/mob/living/mob = victim

	if(mob.stat != DEAD || !(mob.mind?.is_revivable()))
		return FALSE

	mob.revive()
	playsound(victim, 'sound/magic/staff_healing.ogg', 50, TRUE)
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(late_death), mob), REVIVE_SPELL_TIME)
	return TRUE

/proc/late_death(mob/living/mob)
	mob.death()

	if(!ishuman(mob))
		return

	necrotize_body(mob, REVIVE_SPELL_NECROSIS_PROB)

#undef REVIVE_SPELL_TIME
#undef REVIVE_SPELL_NECROSIS_PROB
