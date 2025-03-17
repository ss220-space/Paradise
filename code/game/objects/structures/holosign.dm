
//holographic signs and barriers

/obj/structure/holosign
	name = "holo sign"
	ru_names = list(
		NOMINATIVE = "голографическая табличка",
		GENITIVE = "голографической таблички",
		DATIVE = "голографической табличке",
		ACCUSATIVE = "голографическую табличку",
		INSTRUMENTAL = "голографической табличкой",
		PREPOSITIONAL = "голографической табличке"
	)
	icon = 'icons/effects/effects.dmi'
	anchored = TRUE
	max_integrity = 1
	armor = list("melee" = 0, "bullet" = 50, "laser" = 50, "energy" = 50, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 20)
	var/obj/item/projector

/obj/structure/holosign/Initialize(mapload, source_projector)
	. = ..()
	if(istype(source_projector, /obj/item/holosign_creator))
		var/obj/item/holosign_creator/holosign = source_projector
		holosign.signs += src
		projector = holosign
	else if(istype(source_projector, /obj/item/mecha_parts/mecha_equipment/holowall))
		var/obj/item/mecha_parts/mecha_equipment/holowall/holoproj = source_projector
		holoproj.barriers += src
		projector = holoproj

/obj/structure/holosign/Destroy()
	if(istype(projector, /obj/item/holosign_creator))
		var/obj/item/holosign_creator/holosign = projector
		holosign.signs -= src
		projector = null
	else if(istype(projector, /obj/item/mecha_parts/mecha_equipment/holowall))
		var/obj/item/mecha_parts/mecha_equipment/holowall/holoproj = projector
		holoproj.barriers -= src
		projector = null
	return ..()

/obj/structure/holosign/has_prints()
	return FALSE

/obj/structure/holosign/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	take_damage(5 , BRUTE, "melee", 1)

/obj/structure/holosign/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)
		if(BURN)
			playsound(loc, 'sound/weapons/egloves.ogg', 80, TRUE)

/obj/structure/holosign/wetsign
	name = "wet floor sign"
	desc = "Слова пролетают мимо, как будто они ничего не значат."
	ru_names = list(
		NOMINATIVE = "знак мокрого пола",
		GENITIVE = "знака мокрого пола",
		DATIVE = "знаку мокрого пола",
		ACCUSATIVE = "знак мокрого пола",
		INSTRUMENTAL = "знаком мокрого пола",
		PREPOSITIONAL = "знаке мокрого пола"
	)
	icon_state = "holosign"

/obj/structure/holosign/wetsign/proc/wet_timer_start(obj/item/holosign_creator/HS_C)
	addtimer(CALLBACK(src, PROC_REF(wet_timer_finish), HS_C), 82 SECONDS, TIMER_UNIQUE)

/obj/structure/holosign/wetsign/proc/wet_timer_finish(obj/item/holosign_creator/HS_C)
	playsound(HS_C.loc, 'sound/machines/chime.ogg', 20, 1)
	qdel(src)


/obj/structure/holosign/wetsign/mine
	desc = "Слова пролетают мимо, как будто они что-то точно значат."


/obj/structure/holosign/wetsign/mine/Initialize(mapload, source_projector)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/holosign/wetsign/mine/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(isliving(arrived))
		INVOKE_ASYNC(src, PROC_REF(triggermine), arrived)


/obj/structure/holosign/wetsign/mine/proc/triggermine(mob/living/victim)
	empulse(src, 1, 1, TRUE, "[victim] активировал[genderize_ru(victim.gender, "", "а", "о", "и")] [declent_ru(ACCUSATIVE)]")
	if(ishuman(victim))
		victim.apply_damage(100, STAMINA)
	qdel(src)


/obj/structure/holosign/barrier
	name = "holo barrier"
	desc = "Небольшое голографическое препятствие, преодолеть которое можно только пешком."
	ru_names = list(
		NOMINATIVE = "голографический барьер",
		GENITIVE = "голографического барьера",
		DATIVE = "голографическому барьеру",
		ACCUSATIVE = "голографический барьер",
		INSTRUMENTAL = "голографическим барьером",
		PREPOSITIONAL = "голографическом барьере"
	)
	icon_state = "holosign_sec"
	pass_flags_self = PASSTABLE|PASSGRILLE|PASSGLASS|LETPASSTHROW
	density = TRUE
	max_integrity = 20
	var/allow_walk = TRUE //can we pass through it on walk intent


/obj/structure/holosign/barrier/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return TRUE
	if(iscarbon(mover))
		var/mob/living/carbon/carbon_mover = mover
		if(allow_walk && (carbon_mover.m_intent == MOVE_INTENT_WALK || carbon_mover.pulledby?.m_intent == MOVE_INTENT_WALK))
			return TRUE
	else if(issilicon(mover))
		var/mob/living/silicon/silicon_mover = mover
		if(allow_walk && (silicon_mover.m_intent == MOVE_INTENT_WALK || silicon_mover.pulledby?.m_intent == MOVE_INTENT_WALK))
			return TRUE


/obj/structure/holosign/barrier/engineering
	icon_state = "holosign_engi"

/obj/structure/holosign/barrier/atmos
	name = "holo firelock"
	desc = "Голографический барьер, похожий на пожарный шлюз. Он не препятствует прохождению твёрдых предметов, но не позволяет газу проникать внутрь."
	ru_names = list(
		NOMINATIVE = "голографический пожарный шлюз",
		GENITIVE = "голографического пожарного шлюза",
		DATIVE = "голографическому пожарному шлюзу",
		ACCUSATIVE = "голографический пожарный шлюз",
		INSTRUMENTAL = "голографическим пожарным шлюзом",
		PREPOSITIONAL = "голографическом пожарном шлюзе"
	)
	icon_state = "holo_firelock"
	density = FALSE
	layer = ABOVE_MOB_LAYER
	anchored = TRUE
	layer = ABOVE_MOB_LAYER
	alpha = 150

/obj/structure/holosign/barrier/atmos/Initialize(mapload)
	. = ..()
	air_update_turf(TRUE)

/obj/structure/holosign/barrier/atmos/CanAtmosPass(turf/T, vertical)
	return FALSE

/obj/structure/holosign/barrier/atmos/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/holosign/barrier/cyborg
	name = "Energy Field"
	desc = "Хрупкое энергетическое поле, которое блокирует движение. Отлично защищает от смертоносных снарядов."
	ru_names = list(
		NOMINATIVE = "энергетический барьер",
		GENITIVE = "энергетического барьера",
		DATIVE = "энергетическому барьеру",
		ACCUSATIVE = "энергетический барьер",
		INSTRUMENTAL = "энергетическим барьером",
		PREPOSITIONAL = "энергетическом барьере"
	)
	density = TRUE
	max_integrity = 10
	allow_walk = FALSE

/obj/structure/holosign/barrier/cyborg/bullet_act(obj/projectile/P)
	take_damage((P.damage / 5) , BRUTE, "melee", 1)	//Doesn't really matter what damage flag it is.
	if(istype(P, /obj/projectile/energy/electrode))
		take_damage(10, BRUTE, "melee", 1)	//Tasers aren't harmful.
	if(istype(P, /obj/projectile/beam/disabler))
		take_damage(5, BRUTE, "melee", 1)	//Disablers aren't harmful.

/obj/structure/holosign/barrier/cyborg/hacked
	name = "Charged Energy Field"
	desc = "Мощный энергетический барьер, который блокирует движение. От него исходит энергия."
	ru_names = list(
		NOMINATIVE = "заряженный энергетический барьер",
		GENITIVE = "заряженного энергетического барьера",
		DATIVE = "заряженному энергетическому барьеру",
		ACCUSATIVE = "заряженный энергетический барьер",
		INSTRUMENTAL = "заряженным энергетическим барьером",
		PREPOSITIONAL = "заряженном энергетическом барьере"
	)
	max_integrity = 20
	COOLDOWN_DECLARE(shock_cooldown)


/obj/structure/holosign/barrier/cyborg/hacked/bullet_act(obj/projectile/P)
	take_damage(P.damage, BRUTE, "melee", 1)	//Yeah no this doesn't get projectile resistance.


/obj/structure/holosign/barrier/cyborg/hacked/attack_hand(mob/living/user)
	. = ..()
	if(. || !COOLDOWN_FINISHED(src, shock_cooldown) || !isliving(user))
		return
	user.electrocute_act(15, "энергетического барьера", flags = SHOCK_NOGLOVES)
	COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)


/obj/structure/holosign/barrier/cyborg/hacked/Bumped(mob/living/moving_living)
	. = ..()
	if(!COOLDOWN_FINISHED(src, shock_cooldown) || !isliving(moving_living))
		return .
	moving_living.electrocute_act(15, "энергетического барьера", flags = SHOCK_NOGLOVES)
	COOLDOWN_START(src, shock_cooldown, 0.5 SECONDS)

