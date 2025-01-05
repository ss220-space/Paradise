//kills unconscious targets and turns them into blob zombies, produces fragile spores when killed.  Spore produced by factories are sentient.
/datum/blobstrain/reagent/distributed_neurons
	name = "Распределенные нейроны"
	description = "наносит средне-низкий урон токсинами и превращает бессознательные цели в зомби блоба."
	effectdesc = "при разрушении также производит хрупкие споры.  Споры, производимые фабриками, разумны."
	shortdesc = "наносит средне-низкий урон токсинами и убьет все цели, находящиеся без сознания, при атаке. Споры, производимые фабриками, разумны."
	analyzerdescdamage = "Наносит средне-низкий урон токсинами и зомбирует людей, находящихся без сознания."
	analyzerdesceffect = "При разрушении производит хрупкие споры. Споры, производимые фабриками, разумны."
	color = "#E88D5D"
	complementary_color = "#823ABB"
	message_living = "и ты чувствуешь усталость"
	reagent = /datum/reagent/blob/distributed_neurons

/datum/blobstrain/reagent/distributed_neurons/damage_reaction(obj/structure/blob/blob_tile, damage, damage_type, damage_flag)
	if((damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) && blob_tile.get_integrity() - damage <= 0 && prob(15)) //if the cause isn't fire or a bomb, the damage is less than 21, we're going to die from that damage, 15% chance of a shitty spore.
		blob_tile.visible_message(span_boldwarning("Спора вылетает из блоба!"))
		blob_tile.overmind.create_spore(blob_tile.loc, /mob/living/simple_animal/hostile/blob_minion/spore/minion/weak)
	return ..()

/datum/reagent/blob/distributed_neurons
	name = "Распределенные нейроны"
	id = "blob_distributed_neurons"
	color = "#E88D5D"
	taste_description = "шипящий"

/datum/reagent/blob/distributed_neurons/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.apply_damage(0.6*reac_volume, TOX)
	if(overmind && ishuman(exposed_mob))
		if(exposed_mob.stat == UNCONSCIOUS)
			exposed_mob.investigate_log("has been killed by distributed neurons (blob).", INVESTIGATE_DEATHS)
			exposed_mob.death() //sleeping in a fight? bad plan.
		if(exposed_mob.stat == DEAD && overmind.can_buy(BLOB_ZOMBIFICATION_COST))
			var/mob/living/simple_animal/hostile/blob_minion/spore/minion/spore = overmind.create_spore(get_turf(exposed_mob))
			spore.zombify(exposed_mob)
			overmind.add_points(-5)
			to_chat(overmind, span_notice("Потрачено [BLOB_ZOMBIFICATION_COST] ресурса на зомбификацию [exposed_mob]."))
