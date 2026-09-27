/mob/living/simple_animal/hostile/megafauna/proc/make_virtual_megafauna()
	var/new_max = clamp(maxHealth * 0.5, 600, 1300)
	maxHealth = new_max
	health = new_max

	true_spawn = FALSE
	achievement_type = null
	crusher_achievement_type = null
	score_achievement_type = null
	crusher_loot = null
	enraged_loot = null
	enraged_unique_loot = null

	loot = list(/obj/structure/closet/crate/secure/bitrunning/encrypted)

/mob/living/simple_animal/hostile/megafauna/dragon/virtual_domain
	true_spawn = FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/virtual_domain
	true_spawn = FALSE

/mob/living/simple_animal/hostile/megafauna/colossus/virtual_domain
	true_spawn = FALSE

/mob/living/simple_animal/hostile/megafauna/hierophant/virtual_domain
	true_spawn = FALSE

/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/virtual_domain
	true_spawn = FALSE
