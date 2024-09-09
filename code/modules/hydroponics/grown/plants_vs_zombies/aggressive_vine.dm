/obj/item/seeds/terraformers_plan/aggressive_vine
	name = "pack of aggressive vine"
	desc = "Эти семяна выростут в агрессивную лозу."
	icon_state = "seed-kudzu"
	species = "kudzu"
	plantname = "Аggressive vine"
	product = /obj/item/aggressive_vine
	lifespan = 20
	endurance = 10
	yield = 4
	growthstages = 4

/obj/item/aggressive_vine
	name = "aggressive vine"
	desc = "Лоза хватающая не терраформаторов."
	var/plant_time = 3 SECONDS

/obj/item/aggressive_vine/attack_self(mob/user)
	if (do_after(user, plant_time))
