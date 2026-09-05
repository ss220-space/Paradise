/mob/living/simple_animal/hostile/guardian/fire
	melee_damage_type = BURN
	attack_sound = 'sound/items/welder.ogg'
	attacktext = "жжёт"
	damage_transfer = 0.8
	playstyle_string = "Как <b>Хаос</b>, вы обладаете лишь легким сопротивлением урону, но поджигаете любого врага, с которым столкнетесь. Кроме того, ваши атаки ближнего боя случайным образом телепортируют врагов. У вас есть мощное заклинание, призывающее сильнейшие галлюцинации."
	environment_smash = 1
	magic_fluff_string = "....и вытаскиваете Колдуна, создателя бесконечного хаоса!"
	tech_fluff_string = "Последовательность загрузки завершена. Модуль контроля толпы активирован. Рой голопаразитов активирован."
	bio_fluff_string = "Ваш рой скарабеев заканчивает мутировать и оживает, готовый сеять хаос в произвольном порядке."
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/fire/Initialize(mapload, mob/living/host)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/hostile/guardian/fire/Life(seconds, times_fired) //Dies if the summoner dies
	..()
	if(summoner)
		summoner.ExtinguishMob()
		summoner.adjust_fire_stacks(-20)

/mob/living/simple_animal/hostile/guardian/fire/Initialize(mapload)
	. = ..()
	var/datum/action/cooldown/spell/aoe/guardian_hallucination/spell = new
	spell.summoner = summoner
	AddSpell(spell)

/mob/living/simple_animal/hostile/guardian/fire/AttackingTarget()
	. = ..()
	if(prob(45))
		if(ismovable(target))
			var/atom/movable/M = target
			if(!M.anchored && M != summoner)
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
				var/turf/T = get_turf(M)
				do_teleport(M, M, 10)
				investigate_log("[key_name_log(src)] teleported [key_name_log(target)] from [COORD(T)] to [COORD(M)].", INVESTIGATE_TELEPORTATION)
				new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
				summoner.AdjustHallucinate(10 SECONDS)

/mob/living/simple_animal/hostile/guardian/fire/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	collision_ignite(arrived)

/mob/living/simple_animal/hostile/guardian/fire/MobBump(mob/living/bumped_mob)
	. = ..()
	collision_ignite(bumped_mob)

/mob/living/simple_animal/hostile/guardian/fire/proc/collision_ignite(atom/movable/AM)
	if(isliving(AM))
		var/mob/living/M = AM
		if(AM != summoner && M.fire_stacks < 7)
			M.fire_stacks = 7
			M.IgniteMob()

/datum/action/cooldown/spell/aoe/guardian_hallucination
	name = "Волна галлюцинаций"
	desc = "Призовите самый темный страх на ваших жертв. Хозяин невосприимчив к эффекту."
	button_icon_state = "blight"
	cooldown_time = 12 SECONDS
	spell_requirements = NONE
	check_flags = AB_CHECK_CONSCIOUS | AB_TRANSFER_MIND | AB_CHECK_INCAPACITATED
	var/mob/living/summoner = null
	var/list/stunning_hallucinations = list("singulo", "koolaid", "fake")
	aoe_radius = 10
	targeting_type = /datum/aoe_targeting/living

/datum/action/cooldown/spell/aoe/guardian_hallucination/Remove(mob/living/remove_from)
	. = ..()
	summoner = null

/datum/action/cooldown/spell/aoe/guardian_hallucination/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(victim == summoner)
		return
	if(iscarbon(victim))
		var/mob/living/carbon/M = victim
		var/random_hallucination = pick(stunning_hallucinations)
		M.AdjustHallucinate(50 SECONDS)
		M.hallucinate_living(random_hallucination)
		return
	if(issilicon(victim))
		var/mob/living/silicon/silicon = victim
		to_chat(silicon, span_warning("<b>ОШИБКА #!^: ПЕРЕГРУЗКА СЕНСОРОВ\[$(!@#</b>"))
		SEND_SOUND(silicon, sound('sound/misc/interference.ogg'))
		playsound(silicon, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, TRUE, silicon)
		silicon.Weaken(6 SECONDS)
