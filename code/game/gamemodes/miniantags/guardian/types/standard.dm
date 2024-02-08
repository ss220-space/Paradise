/mob/living/simple_animal/hostile/guardian/punch
	melee_damage_lower = 20
	melee_damage_upper = 20
	armour_penetration = 100
	obj_damage = 100
	damage_transfer = 0.4
	tts_seed = "Heavy"
	playstyle_string = "Будучи <b>Стандартным</b> типом, вы обладаете огромной броней, сильными ударами пробивающими даже стены и ваше присутствие ужасает врагов, замедляя их. Кричите, повергая врагов в страх!"
	environment_smash = 2
	magic_fluff_string = "..И вытаскиваете Ассистента, безликого и типичного, но которого никогда нельзя недооценивать."
	tech_fluff_string = "Инициализация завершена. Стандартные модули загружены. Рой голопаразитов активирован."
	bio_fluff_string = "Ваш рой скарабеев оживает, готовый разорвать ваших врагов на части."
	var/battlecry = "ORA"

/mob/living/simple_animal/hostile/guardian/punch/Initialize(mapload, mob/living/host)
	. = ..()
	AddSpell(new /obj/effect/proc_holder/spell/choose_battlecry(null))

/mob/living/simple_animal/hostile/guardian/punch/AttackingTarget()
	. = ..()
	if(iscarbon(target) && target != summoner)
		if(length(battlecry) > 8)//no more then 8 letters in a battle cry.
			visible_message("<span class='danger'>[src] punches [target]!</span>")
		else
			say("[battlecry]", TRUE)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)
		playsound(loc, attack_sound, 50, 1, 1)

/mob/living/simple_animal/hostile/guardian/punch/Life(seconds, times_fired)
	. = ..()
	for(var/mob/living/carbon/human/L in view(2, src))
		if(L.stat != DEAD && L != summoner)
			L.Slowed(4 SECONDS)

/obj/effect/proc_holder/spell/choose_battlecry
	name = "Change battlecry"
	desc = "Changes your battlecry."
	clothes_req = FALSE
	base_cooldown = 1 SECONDS
	action_icon_state = "no_state"
	action_background_icon_state = "communicate"
	action_icon = 'icons/mob/guardian.dmi'

/obj/effect/proc_holder/spell/choose_battlecry/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/choose_battlecry/cast(list/targets, mob/living/user = usr)
	var/mob/living/simple_animal/hostile/guardian/punch/guardian_user = user
	var/input = stripped_input(guardian_user, "What do you want your battlecry to be? Max length of 5 characters.", ,"", 6)
	if(!input)
		revert_cast()
		return
	guardian_user.battlecry = input

/mob/living/simple_animal/hostile/guardian/punch/sealpunch
	name = "Seal Sprit"
	real_name = "Seal Sprit"
	icon = 'icons/mob/animal.dmi'
	icon_living = "seal"
	icon_state = "seal"
	attacktext = "шлёпает"
	speak_emote = list("barks")
	melee_damage_lower = 0
	melee_damage_upper = 0
	melee_damage_type = STAMINA
	damage_transfer = 0
	playstyle_string = "URK URK!"
	environment_smash = 2
	battlecry = "URK"
	admin_spawned = TRUE
