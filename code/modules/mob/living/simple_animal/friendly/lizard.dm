/mob/living/simple_animal/lizard
	name = "lizard"
	desc = "Милая маленькая ящерица."
	ru_names = list(
		NOMINATIVE = "ящерица",
		GENITIVE = "ящерицы",
		DATIVE = "ящерице",
		ACCUSATIVE = "ящерицу",
		INSTRUMENTAL = "ящерицей",
		PREPOSITIONAL = "ящерице"
	)
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	icon_gib = "lizard_gib"
	speak_emote = list("шипит")
	tts_seed = "Ladyvashj"
	death_sound = 'sound/creatures/lizard_death.ogg'
	health = 5
	maxHealth = 5
	attacktext = "кусает"
	obj_damage = 0
	melee_damage_lower = 1
	melee_damage_upper = 2
	response_help  = "гладит"
	response_disarm = "пинает"
	response_harm   = "топчет"
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 1)
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	holder_type = /obj/item/holder/lizard

/mob/living/simple_animal/lizard/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message("<span class='notice'>[user] sucks [src] into its decompiler. There's a horrible crunching noise.</span>", \
		"<span class='warning'>It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises.</span>")
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["wood"] += 2
		C.stored_comms["glass"] += 2
		qdel(src)
		return TRUE
	return ..()

/mob/living/simple_animal/lizard/axolotl
	name = "axolotl"
	desc = "Маленький милый аксолотль."
	ru_names = list(
		NOMINATIVE = "аксолотль",
		GENITIVE = "аксолотля",
		DATIVE = "аксолотлю",
		ACCUSATIVE = "аксолотля",
		INSTRUMENTAL = "аксолотлем",
		PREPOSITIONAL = "аксолотле"
	)
	icon_state = "axolotl"
	icon_living = "axolotl"
	icon_dead = "axolotl_dead"
	holder_type = /obj/item/holder/axolotl
