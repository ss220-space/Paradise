/mob/living/simple_animal/hostile/giant_rat
	name = "Giant rat"
	desc = "A big dirty fat rat with sharp teeth and claws."
	icon = 'icons/mob/animal.dmi'
	icon_state = "regalrat"
	icon_living = "regalrat"
	icon_dead = "regalrat_dead"
	icon_gib = "regalrat_dead"
	speak_chance = 0
	turns_per_move = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/rotten = 3)
	response_help = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm = "hits the"
	stop_automated_movement_when_pulled = 0
	maxHealth = 60
	health = 60

	speed = 0.8

	emote_taunt = list("nashes")
	taunt_chance = 20

	harm_intent_damage = 10
	melee_damage_lower = 15
	melee_damage_upper = 20
	attacktext = "кромсает"
	attack_sound = 'sound/weapons/bite.ogg'

	layer = MOB_LAYER
	var/stalk_tick_delay = 3
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/giant_rat/AttackingTarget()
	. = ..()
	if(.)
		if(prob(15) && iscarbon(target))
			var/mob/living/carbon/C = target
			C.Weaken(6 SECONDS)
			C.visible_message("<span class='danger'>\the [src] knocks down \the [C]!</span>")
