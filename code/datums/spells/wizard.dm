/obj/effect/proc_holder/spell/projectile/magic_missile
	name = "Magic Missile"
	desc = "Это заклинание выпускает несколько медленно движущихся магических снарядов по ближайшим целям."

	school = "evocation"
	base_cooldown = 20 SECONDS
	cooldown_min = 6 SECONDS //35 deciseconds reduction per rank
	clothes_req = TRUE
	invocation = "FORTI GY AMA"
	invocation_type = "shout"

	proj_icon_state = "magicm"
	proj_name = "a magic missile"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/inflict_handler/magic_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "magicmd"

	action_icon_state = "magicm"

	sound = 'sound/magic/magic_missile.ogg'

	var/max_targets = INFINITY


/obj/effect/proc_holder/spell/projectile/magic_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = max_targets
	return T


/obj/effect/proc_holder/spell/inflict_handler/magic_missile
	amt_weakened = 6 SECONDS
	sound = 'sound/magic/mm_hit.ogg'


/obj/effect/proc_holder/spell/projectile/honk_missile
	name = "Honk Missile"
	desc = "Это заклинание выстреливает несколькими медленно движущимися магическими велосипедными гудками по ближайшим целям."

	school = "evocation"
	base_cooldown = 6 SECONDS
	cooldown_min = 6 SECONDS
	clothes_req = FALSE
	invocation = "HONK GY AMA"
	invocation_type = "shout"

	proj_icon = 'icons/obj/items.dmi'
	proj_icon_state = "bike_horn"
	proj_name = "A bike horn"
	proj_lingering = 1
	proj_type = "/obj/effect/proc_holder/spell/inflict_handler/honk_missile"

	proj_lifespan = 20
	proj_step_delay = 5

	proj_trail_icon = 'icons/obj/items.dmi'
	proj_trail = 1
	proj_trail_lifespan = 5
	proj_trail_icon_state = "bike_horn"

	action_icon_state = "magicm"

	sound = 'sound/items/bikehorn.ogg'


/obj/effect/proc_holder/spell/projectile/honk_missile/create_new_targeting()
	var/datum/spell_targeting/targeted/T = new()
	T.allowed_type = /mob/living
	T.max_targets = INFINITY
	return T


/obj/effect/proc_holder/spell/inflict_handler/honk_missile
	amt_weakened = 6 SECONDS
	sound = 'sound/items/bikehorn.ogg'


/obj/effect/proc_holder/spell/noclothes
	name = "No Clothes"
	desc = "Это постоянно действующее заклинание позволяет вам колдовать без одежды."
	action_icon_state = "no_clothes"


/obj/effect/proc_holder/spell/noclothes/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value


/obj/effect/proc_holder/spell/genetic/mutate
	name = "Mutate"
	desc = "Это заклинание превращает вас в халка и позволяет на короткое время обрести лазерное зрение."

	school = "transmutation"
	base_cooldown = 40 SECONDS
	cooldown_min = 30 SECONDS //25 deciseconds reduction per rank
	clothes_req = TRUE
	invocation = "BIRUZ BENNAR"
	invocation_type = "shout"
	message = "<span class='notice'>Вы чувствуете себя сильным! Вы чувствуете, как в глазах нарастает давление!</span>"
	centcom_cancast = FALSE

	traits = list(TRAIT_LASEREYES)
	duration = 30 SECONDS

	action_icon_state = "mutate"
	sound = 'sound/magic/mutate.ogg'


/obj/effect/proc_holder/spell/genetic/mutate/Initialize(mapload)
	. = ..()
	mutations = list(GLOB.hulkblock)


/obj/effect/proc_holder/spell/genetic/mutate/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/smoke
	name = "Smoke"
	desc = "Это заклинание создает облако удушливого дыма на вашем месте. Для него не требуется роба"

	school = "conjuration"
	base_cooldown = 12 SECONDS
	cooldown_min = 2 SECONDS //25 deciseconds reduction per rank
	clothes_req = FALSE
	human_req = FALSE
	smoke_type = SMOKE_COUGHING
	smoke_amt = 10

	action_icon_state = "smoke"


/obj/effect/proc_holder/spell/smoke/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/emplosion/disable_tech
	name = "Disable Tech"
	desc = "Это заклинание отключает все оружие, камеры и большую часть другой техники в радиусе действия."
	base_cooldown = 40 SECONDS
	cooldown_min = 20 SECONDS //50 deciseconds reduction per rank
	clothes_req = FALSE
	invocation = "NEC CANTIO"
	invocation_type = "shout"

	emp_heavy = 6
	emp_light = 10

	sound = 'sound/magic/disable_tech.ogg'


/obj/effect/proc_holder/spell/turf_teleport/blink
	name = "Blink"
	desc = "Это заклинание случайным образом телепортирует вас на небольшое расстояние."

	school = "abjuration"
	base_cooldown = 2 SECONDS
	clothes_req = TRUE
	cooldown_min = 5 //4 deciseconds reduction per rank

	smoke_type = SMOKE_HARMLESS
	smoke_amt = 1

	inner_tele_radius = 0
	outer_tele_radius = 6

	centcom_cancast = FALSE //prevent people from getting to centcom

	action_icon_state = "blink"

	sound_in = 'sound/magic/blink.ogg'
	sound_out = 'sound/magic/blink.ogg'


/obj/effect/proc_holder/spell/area_teleport/teleport
	name = "Teleport"
	desc = "Это заклинание телепортирует вас в выбранную вами область."

	school = "abjuration"
	base_cooldown = 60 SECONDS
	cooldown_min = 20 SECONDS //100 deciseconds reduction per rank
	clothes_req = TRUE
	invocation = "SCYAR NILA"
	invocation_type = "shout"

	smoke_amt = 5
	action_icon_state = "spell_teleport"

	sound_in = 'sound/magic/teleport_diss.ogg'
	sound_out = 'sound/magic/teleport_app.ogg'


/obj/effect/proc_holder/spell/area_teleport/teleport/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/forcewall
	name = "Force Wall"
	desc = "Это заклинание создает небольшую нерушимую стену, через которую можете пройти только вы, и для него не требуется роба. Длится 30 секунд."

	school = "transmutation"
	base_cooldown = 10 SECONDS
	cooldown_min = 5 SECONDS //12 deciseconds reduction per rank
	clothes_req = FALSE
	human_req = FALSE
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "whisper"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	var/wall_type = /obj/effect/forcefield/wizard
	var/large = FALSE


/obj/effect/proc_holder/spell/forcewall/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/forcewall/cast(list/targets, mob/user = usr)
	new wall_type(get_turf(user), user)
	if(large) //Extra THICK
		if(user.dir == SOUTH || user.dir == NORTH)
			new wall_type(get_step(user, EAST), user)
			new wall_type(get_step(user, WEST), user)
		else
			new wall_type(get_step(user, NORTH), user)
			new wall_type(get_step(user, SOUTH), user)


/obj/effect/proc_holder/spell/forcewall/greater
	name = "Greater Force Wall"
	desc = "Создайте магический барьер большего размера, который сможете преодолеть только вы, но для этого потребуется роба. Длится 30 секунд."
	clothes_req = TRUE
	invocation = "TARCOL GRANDI ZHERI"
	invocation_type = "shout"
	action_icon_state = "shield_greater"
	large = TRUE


/obj/effect/proc_holder/spell/aoe/conjure/timestop
	name = "Stop Time"
	desc = "Это заклинание останавливает время для всех, кроме вас, позволяя вам свободно передвигаться, в то время как ваши враги и даже снаряды заморожены."
	base_cooldown = 50 SECONDS
	cooldown_min = 10 SECONDS
	clothes_req = TRUE
	invocation = "TOKI WO TOMARE"
	invocation_type = "shout"

	summon_amt = 1

	action_icon_state = "time"

	summon_type = list(/obj/effect/timestop/wizard)
	aoe_range = 0


/obj/effect/proc_holder/spell/aoe/conjure/carp
	name = "Summon Carp"
	desc = "Это заклинание вызывает простого карпа."

	school = "conjuration"
	base_cooldown = 2 MINUTES
	clothes_req = TRUE
	invocation = "NOUK FHUNMM SACP RISSKA"
	invocation_type = "shout"

	summon_type = list(/mob/living/simple_animal/hostile/carp)

	cast_sound = 'sound/magic/summon_karp.ogg'
	aoe_range = 1


/obj/effect/proc_holder/spell/aoe/conjure/construct
	name = "Artificer"
	desc = "Это заклинание создает конструкт, которым могут управлять Тени."

	school = "conjuration"
	base_cooldown = 60 SECONDS
	clothes_req = FALSE

	summon_type = list(/obj/structure/constructshell)

	action_icon_state = "artificer"
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 0


/obj/effect/proc_holder/spell/aoe/conjure/creature
	name = "Summon Creature Swarm"
	desc = "Это заклинание разрывает ткань реальности, позволяя истинному ужасу вырваться наружу."

	school = "conjuration"
	base_cooldown = 2 MINUTES
	clothes_req = FALSE
	human_req = FALSE
	invocation = "IA IA"
	invocation_type = "shout"
	summon_amt = 10

	summon_type = list(/mob/living/simple_animal/hostile/creature)
	cast_sound = 'sound/magic/summonitems_generic.ogg'
	aoe_range = 3


/obj/effect/proc_holder/spell/trigger/blind
	name = "Blind"
	desc = "Это заклинание временно ослепляет окружающих вас людей."
	school = "transmutation"
	action_icon_state = "blind"
	clothes_req = FALSE
	human_req = FALSE
	invocation = "STI KALY"
	invocation_type = "whisper"
	message = "<span class='notice'>Твои глаза кричат от боли!</span>"
	base_cooldown = 30 SECONDS
	cooldown_min = 5 SECONDS //12 deciseconds reduction per rank
	need_active_overlay = TRUE

	starting_spells = list("/obj/effect/proc_holder/spell/inflict_handler/blind", "/obj/effect/proc_holder/spell/genetic/blind")




/obj/effect/proc_holder/spell/trigger/blind/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/inflict_handler/blind
	amt_eye_blind = 10 SECONDS
	sound = 'sound/magic/blind.ogg'


/obj/effect/proc_holder/spell/genetic/blind // 10 sec
	sound = 'sound/magic/blind.ogg'


/obj/effect/proc_holder/spell/genetic/blind/Initialize(mapload)
	. = ..()
	mutations = list(GLOB.blindblock)


/obj/effect/proc_holder/spell/genetic/blind/create_new_targeting()
	return new /datum/spell_targeting/self // Dummy value since it is never used by an user directly


/obj/effect/proc_holder/spell/fireball
	name = "Fireball"
	desc = "Это заклинание запускает в цель огненный шар."

	school = "evocation"
	base_cooldown = 6 SECONDS
	cooldown_min = 2 SECONDS //10 deciseconds reduction per rank
	clothes_req = FALSE
	human_req = FALSE
	invocation = "ONI SOMA"
	invocation_type = "shout"

	selection_activated_message		= "<span class='notice'>Вы готовитесь произнести заклинание огненного шара! <B>Нажмите левую кнопку чтобы запустить шар в цель!</B></span>"
	selection_deactivated_message	= "<span class='notice'>Вы гасите огненный шар... пока что.</span>"

	var/fireball_type = /obj/item/projectile/magic/fireball
	action_icon_state = "fireball0"
	sound = 'sound/magic/fireball.ogg'


/obj/effect/proc_holder/spell/fireball/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/T = new()
	T.range = 20
	return T


/obj/effect/proc_holder/spell/fireball/update_icon_state()
	if(!action)
		return
	action.button_icon_state = "fireball[active]"
	action.UpdateButtonIcon()


/obj/effect/proc_holder/spell/fireball/cast(list/targets, mob/living/user = usr)
	var/target = targets[1] //There is only ever one target for fireball
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // Get the tile infront of the move, based on their direction
	if(!isturf(U) || !isturf(T))
		return FALSE

	var/obj/item/projectile/magic/fireball/FB = new fireball_type(user.loc)
	FB.current = get_turf(user)
	FB.original = target
	FB.firer = user
	var/turf/target_turf = get_turf(target)
	FB.preparePixelProjectile(target, target_turf, user, targeting.click_params)
	FB.fire()
	user.newtonian_move(get_dir(target_turf, T))

	return TRUE


/obj/effect/proc_holder/spell/aoe/repulse
	name = "Repulse"
	desc = "Это заклинание отбрасывает все, что находится вокруг заклинателя."
	base_cooldown = 40 SECONDS
	cooldown_min = 15 SECONDS
	clothes_req = TRUE
	invocation = "GITTAH WEIGH"
	invocation_type = "shout"

	sound = 'sound/magic/repulse.ogg'
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	action_icon_state = "repulse"
	aoe_range = 5


/obj/effect/proc_holder/spell/aoe/repulse/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/repulse/cast(list/targets, mob/user = usr, stun_amt = 3 SECONDS)
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	playMagSound()
	for(var/turf/T in targets) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored || AM.move_resist == INFINITY)
			continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(10 SECONDS)
				M.adjustBruteLoss(5)
				to_chat(M, "<span class='userdanger'>Вас швыряет на пол какая-то мистическая сила!</span>")
		else
			new sparkle_path(get_turf(AM), get_dir(user, AM)) //created sparkles will disappear on their own
			if(isliving(AM))
				var/mob/living/M = AM
				M.Weaken(stun_amt)
				to_chat(M, "<span class='userdanger'>Вас отбрасывает назад мистическая сила!</span>")
			spawn(0)
				AM.throw_at(throwtarget, ((clamp((maxthrow - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1)//So stuff gets tossed around at the same time.


/obj/effect/proc_holder/spell/sacred_flame
	name = "Sacred Flame"
	desc = "Делает всех вокруг вас огнеопасными и поджигает вас."
	base_cooldown = 6 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation = "FI'RAN DADISKO"
	invocation_type = "shout"
	action_icon_state = "sacredflame"
	sound = 'sound/magic/fireball.ogg'


/obj/effect/proc_holder/spell/sacred_flame/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.include_user = TRUE
	T.range = 6
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/sacred_flame/cast(list/targets, mob/user = usr)
	for(var/mob/living/L in targets)
		L.adjust_fire_stacks(20)
	if(isliving(user))
		var/mob/living/U = user
		U.IgniteMob()

