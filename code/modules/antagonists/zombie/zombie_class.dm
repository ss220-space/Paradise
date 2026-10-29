/datum/zombie_class
	abstract_type = /datum/zombie_class
	var/name
	var/desc
	var/healing_factor_mod = 1
	var/brute_mod = 1
	var/burn_mod = 1
	var/stamina_mod = 1
	var/movespeed_modifier = /datum/movespeed_modifier/zombie
	var/damage_mod = 1
	var/datum/action/cooldown/spell/special_skill

/datum/zombie_class/proc/apply(mob/living/carbon/human/zombie)
	zombie.remove_movespeed_modifier(/datum/movespeed_modifier/zombie)
	var/datum/physiology/physiology = zombie.physiology
	physiology.brute_mod *= brute_mod
	physiology.burn_mod *= burn_mod
	physiology.stamina_mod *= stamina_mod
	physiology.punch_damage_high_mod *= damage_mod
	physiology.punch_damage_low_mod *= damage_mod
	var/datum/action/cooldown/spell/zombie_claws/zombie_claws = new
	zombie_claws.damage_mod = damage_mod
	zombie.mind.AddSpell(zombie_claws)
	zombie.add_movespeed_modifier(movespeed_modifier)
	zombie.mind.AddSpell(new special_skill)

/datum/zombie_class/proc/remove(mob/living/carbon/human/zombie)
	var/datum/physiology/physiology = zombie.physiology
	physiology.brute_mod /= brute_mod
	physiology.burn_mod /= burn_mod
	physiology.stamina_mod /= stamina_mod
	physiology.punch_damage_high_mod /= damage_mod
	physiology.punch_damage_low_mod /= damage_mod
	zombie.mind.RemoveSpell(/datum/action/cooldown/spell/zombie_claws)
	zombie.remove_movespeed_modifier(movespeed_modifier)
	zombie.mind.RemoveSpell(special_skill)

/datum/zombie_class/hunter
	name = "Охотник"
	desc = "Быстрый и юркий зомби. Наносит мало урона и сам быстро погибает, зато способен совершать рывки на большие расстояния."
	brute_mod = 3
	burn_mod = 3
	stamina_mod = 3
	damage_mod = 0.5
	healing_factor_mod = 1.1
	movespeed_modifier = /datum/movespeed_modifier/zombie/fast
	special_skill = /datum/action/cooldown/spell/pointed/zombie_leap

/datum/zombie_class/tank
	name = "Танк"
	desc = "Очень медленный, но невероятно живучий зомби. Наносит огромный урон и выдерживает множество попаданий. Умеет топать, создавая ударную волну."
	healing_factor_mod = 1.2
	brute_mod = 0.4
	burn_mod = 0.4
	stamina_mod = 0.4
	damage_mod = 1.7
	movespeed_modifier = /datum/movespeed_modifier/zombie/slow
	special_skill = /datum/action/cooldown/spell/stomp/zombie

/datum/zombie_class/smoker
	name = "Тень"
	desc = "Медленный зомби со средним уроном и неплохой живучестью. Выпускает крайне вонючий дым, а его полупрозрачная кожа делает его трудноразличимым в темноте."
	healing_factor_mod = 2
	burn_mod = 4
	brute_mod = 0.9
	burn_mod = 0.9
	stamina_mod = 0.9
	special_skill = /datum/action/cooldown/spell/smoke/zombie

/datum/zombie_class/smoker/apply(mob/living/carbon/human/zombie)
	. = ..()
	zombie.AddElement(/datum/element/dark_invisibility, 100, 50, ALPHA_SOURCE_ZOMBIE)

/datum/zombie_class/smoker/remove(mob/living/carbon/human/zombie)
	zombie.RemoveElement(/datum/element/dark_invisibility, 100, 50, ALPHA_SOURCE_ZOMBIE)
	return ..()

/datum/zombie_class/spitter
	name = "Плевун"
	desc = "Медленный зомби со средним уроном и неплохой живучестью. Держится на расстоянии и плюётся кислотой."
	healing_factor_mod = 2
	burn_mod = 0.9
	brute_mod = 0.9
	burn_mod = 0.9
	stamina_mod = 0.9
	special_skill = /datum/action/cooldown/spell/pointed/projectile/acid_spit

