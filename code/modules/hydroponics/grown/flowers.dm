// Poppy
/obj/item/seeds/poppy
	name = "pack of poppy seeds"
	desc = "These seeds grow into poppies."
	icon_state = "seed-poppy"
	species = "poppy"
	plantname = "Poppy Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/poppy
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "poppy-grow"
	icon_dead = "poppy-dead"
	reagents_add = list("bicaridine" = 0.2, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/poppy
	seed = /obj/item/seeds/poppy
	name = "poppy"
	desc = "Long-used as a symbol of rest, peace, and death."
	icon_state = "poppy"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("poppy" = 1)
	distill_reagent = "vermouth"

// Lily
/obj/item/seeds/lily
	name = "pack of lily seeds"
	desc = "These seeds grow into lilies."
	icon_state = "seed-lily"
	species = "lily"
	plantname = "Lily Plants"
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "lily-grow"
	icon_dead = "lily-dead"
	icon_harvest = "lily-harvest"
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	product = /obj/item/reagent_containers/food/snacks/grown/lily
	mutatelist = list()

/obj/item/reagent_containers/food/snacks/grown/lily
	seed = /obj/item/seeds/lily
	name = "lily"
	desc = "A beautiful white flower with rich symbolism. The lily is said to represent love and affection as well as purity and innocence in some cultures."
	icon_state = "lily"
	slot_flags = ITEM_SLOT_HEAD
	tastes = list("lily" = 1)
	filling_color = "#FFA500"

// Geranium
/obj/item/seeds/geranium
	name = "pack of geranium seeds"
	desc = "These seeds grow into geranium."
	icon_state = "seed-geranium"
	species = "geranium"
	plantname = "Geranium Plants"
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "geranium-grow"
	icon_dead = "geranium-dead"
	icon_harvest = "geranium-harvest"
	growthstages = 3
	endurance = 30
	maturation = 5
	yield = 4
	potency = 25
	product = /obj/item/reagent_containers/food/snacks/grown/geranium
	mutatelist = list(/obj/item/seeds/geranium/forgetmenot)
	reagents_add = list("bicaridine" = 0.2, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/geranium
	seed = /obj/item/seeds/geranium
	name = "geranium"
	desc = "A cluster of small purple geranium flowers. They symbolize happiness, good health, wishes and friendship and are generally associated with positive emotions."
	icon_state = "geranium"
	slot_flags = ITEM_SLOT_HEAD
	tastes = list("geranium" = 1)
	filling_color = "#008B8B"

// Forget-me-not
/obj/item/seeds/geranium/forgetmenot
	name = "pack of forget-me-not seeds"
	desc = "These seeds grow into forget-me-not"
	icon_state = "seed-forget_me_not"
	species = "forget_me_not"
	plantname = "Forget-me-not Plants"
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "forget_me_not-grow"
	icon_dead = "forget_me_not-dead"
	icon_harvest = "forget_me_not-harvest"
	product = /obj/item/reagent_containers/food/snacks/grown/geranium/forgetmenot
	reagents_add = list("kelotane" = 0.2, "plantmatter" = 0.05)

/obj/item/reagent_containers/food/snacks/grown/geranium/forgetmenot
	name = "forget-me-not"
	desc = "A clump of small blue flowers, they are primarily associated with rememberance, respect and loyalty."
	icon_state = "forget_me_not"
	tastes = list("forget-me-not" = 1)
	filling_color = "#4466ff"

// Moonlight
/obj/item/seeds/moonlight
	name = "pack of moonlight seeds"
	desc = "These seeds grow into moonlight."
	icon_state = "seed-moonlight"
	species = "moonlight"
	plantname = "Moonlight Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/moonlight
	lifespan = 45
	endurance = 40
	maturation = 8
	production = 5
	yield = 3
	growthstages = 6
	genes = list(/datum/plant_gene/trait/glow)
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	icon_grow = "moonlight-grow"
	icon_dead = "moonlight-dead"
	reagents_add = list("plantmatter" = 0.02, "vitamin" = 0.03, "moonlin" = 0.1)

/obj/item/reagent_containers/food/snacks/grown/moonlight
	seed = /obj/item/seeds/moonlight
	name = "moonlight"
	desc = "A beautiful sparkling flower."
	origin_tech = "biotech=4"
	icon_state = "moonlight"
	tastes = list("moonlin" = 1)
	filling_color = "#46fdfd"
	slot_flags = ITEM_SLOT_HEAD

// Harebell
/obj/item/seeds/harebell
	name = "pack of harebell seeds"
	desc = "These seeds grow into pretty little flowers."
	icon_state = "seed-harebell"
	species = "harebell"
	plantname = "Harebells"
	product = /obj/item/reagent_containers/food/snacks/grown/harebell
	lifespan = 100
	endurance = 20
	maturation = 7
	production = 1
	yield = 2
	potency = 30
	growthstages = 4
	genes = list(/datum/plant_gene/trait/plant_type/weed_hardy)
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	reagents_add = list("plantmatter" = 0.04)

/obj/item/reagent_containers/food/snacks/grown/harebell
	seed = /obj/item/seeds/harebell
	name = "harebell"
	desc = "\"I'll sweeten thy sad grave: thou shalt not lack the flower that's like thy face, pale primrose, nor the azured hare-bell, like thy veins; no, nor the leaf of eglantine, whom not to slander, out-sweeten'd not thy breath.\""
	icon_state = "harebell"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	tastes = list("harebell" = 1)
	bitesize_mod = 3
	distill_reagent = "vermouth"


// Sunflower
/obj/item/seeds/sunflower
	name = "pack of sunflower seeds"
	desc = "These seeds grow into sunflowers."
	icon_state = "seed-sunflower"
	species = "sunflower"
	plantname = "Sunflowers"
	product = /obj/item/grown/sunflower
	endurance = 20
	production = 2
	yield = 2
	growthstages = 3
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_grow = "sunflower-grow"
	icon_dead = "sunflower-dead"
	mutatelist = list(/obj/item/seeds/sunflower/moonflower, /obj/item/seeds/sunflower/novaflower)
	reagents_add = list("cornoil" = 0.08, "plantmatter" = 0.04)

/obj/item/grown/sunflower // FLOWER POWER!
	seed = /obj/item/seeds/sunflower
	name = "sunflower"
	desc = "It's beautiful! A certain person might beat you to death if you trample these."
	icon_state = "sunflower"
	damtype = "fire"
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3


/obj/item/grown/sunflower/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	to_chat(target, "<font color='green'><b> [user] smacks you with a sunflower!</font><font color='yellow'><b>FLOWER POWER<b></font>")
	to_chat(user, "<font color='green'>Your sunflower's </font><font color='yellow'><b>FLOWER POWER</b></font><font color='green'>strikes [target]</font>")
	return ATTACK_CHAIN_PROCEED_SUCCESS


// Moonflower
/obj/item/seeds/sunflower/moonflower
	name = "pack of moonflower seeds"
	desc = "These seeds grow into moonflowers."
	icon_state = "seed-moonflower"
	species = "moonflower"
	plantname = "Moonflowers"
	icon_grow = "moonflower-grow"
	icon_dead = "sunflower-dead"
	product = /obj/item/reagent_containers/food/snacks/grown/moonflower
	mutatelist = list()
	reagents_add = list("moonshine" = 0.2, "vitamin" = 0.02, "plantmatter" = 0.02)
	rarity = 15

/obj/item/reagent_containers/food/snacks/grown/moonflower
	seed = /obj/item/seeds/sunflower/moonflower
	name = "moonflower"
	desc = "Store in a location at least 50 yards away from werewolves."
	icon_state = "moonflower"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#E6E6FA"
	bitesize_mod = 2
	tastes = list("moonflower" = 1)
	distill_reagent = "absinthe"  //It's made from flowers.

// Novaflower
/obj/item/seeds/sunflower/novaflower
	name = "pack of novaflower seeds"
	desc = "These seeds grow into novaflowers."
	icon_state = "seed-novaflower"
	species = "novaflower"
	plantname = "Novaflowers"
	icon_grow = "novaflower-grow"
	icon_dead = "sunflower-dead"
	product = /obj/item/grown/novaflower
	mutatelist = list()
	reagents_add = list("condensedcapsaicin" = 0.25, "capsaicin" = 0.3, "plantmatter" = 0)
	rarity = 20

/obj/item/grown/novaflower
	seed = /obj/item/seeds/sunflower/novaflower
	name = "novaflower"
	desc = "These beautiful flowers have a crisp smokey scent, like a summer bonfire."
	icon_state = "novaflower"
	damtype = "fire"
	force = 0
	slot_flags = ITEM_SLOT_HEAD
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb = list("roasted", "scorched", "burned")

/obj/item/grown/novaflower/add_juice()
	..()
	force = round((5 + seed.potency / 5), 1)


/obj/item/grown/novaflower/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.))
		return .

	to_chat(target, span_danger("You are lit on fire from the intense heat of the [name]!"))
	target.adjust_fire_stacks(seed.potency / 20)
	if(target.IgniteMob())
		add_attack_logs(user, target, "set on fire", ATKLOG_FEW)


/obj/item/grown/novaflower/afterattack(atom/A, mob/user, proximity, params)
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1)
	else
		to_chat(usr, "<span class='warning'>All the petals have fallen off the [name] from violent whacking!</span>")
		usr.temporarily_remove_item_from_inventory(src)
		qdel(src)

/obj/item/grown/novaflower/pickup(mob/living/carbon/human/user)
	. = ..()
	if(!user.gloves)
		to_chat(user, "<span class='danger'>The [name] burns your bare hand!</span>")
		user.adjustFireLoss(rand(1, 5))
//Shavel
/obj/item/seeds/shavel
	name = "pack of shavel seeds"
	desc = "These seeds grow into shavel."
	icon_state = "seed-shavel"
	species = "shavel"
	plantname = "Shavel Plants"
	product = /obj/item/reagent_containers/food/snacks/grown/shavel
	lifespan = 60
	endurance = 65
	potency = 15
	maturation = 6
	production = 2
	yield = 7
	growthstages = 3
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	growing_icon = 'icons/obj/hydroponics/growing.dmi'
	icon_grow = "shavel-grow"
	icon_dead = "shavel-dead"
	icon_harvest = "shavel-harvest"
	reagents_add = list("plantmatter" = 0.04, "vitamin" = 0.15)
/obj/item/reagent_containers/food/snacks/grown/shavel
	seed = /obj/item/seeds/shavel
	name = "shavel"
	desc = "A shavel leaf."
	origin_tech = "biotech=2"
	icon_state = "shavel"
	tastes = list("sour weed" = 1)
	filling_color = "#177025"

//Red flower
/obj/item/seeds/redflower
	name = "pack of red flower seeds"
	desc = "These seeds grow into red flowers"
	icon_state = "seed-redflower"
	species = "redflower"
	plantname = "Red flowers"
	product = /obj/item/reagent_containers/food/snacks/grown/redflower
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "redflower-dead"
	icon_harvest = "redflower-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "redflower-grow"

/obj/item/reagent_containers/food/snacks/grown/redflower
	seed = /obj/item/seeds/redflower
	name = "red flower"
	desc = "Beautiful red flower."
	icon_state = "redflower"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Flowerlamp
/obj/item/seeds/flowerlamp
	name = "pack of flowerlamp seeds"
	desc = "These seeds grow into flowerlamp"
	icon_state = "seed-flowerlamp"
	species = "flowerlamp"
	plantname = "Flowerlamp"
	product = /obj/item/reagent_containers/food/snacks/grown/flowerlamp
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "flowerlamp-dead"
	icon_harvest = "flowerlamp-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "flowerlamp-grow"

/obj/item/reagent_containers/food/snacks/grown/flowerlamp
	seed = /obj/item/seeds/flowerlamp
	name = "flowerlamp"
	desc = "Beautiful flowerlamp."
	icon_state = "flowerlamp"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//White Carnation
/obj/item/seeds/carnation
	name = "pack of white carnation seeds"
	desc = "These seeds grow into white carnation"
	icon_state = "seed-whitecarnation"
	species = "whitecarnation"
	plantname = "white carnation"
	product = /obj/item/reagent_containers/food/snacks/grown/whitecarnation
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "whitecarnation-dead"
	icon_harvest = "whitecarnation-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "whitecarnation-grow"
	mutatelist = list(/obj/item/seeds/carnation/red)

/obj/item/reagent_containers/food/snacks/grown/whitecarnation
	seed = /obj/item/seeds/carnation
	name = "white carnation"
	desc = "Beautiful white carnation."
	icon_state = "whitecarnation"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Red carnation
/obj/item/seeds/carnation/red
	name = "pack of red carnation seeds"
	desc = "These seeds grow into red carnation"
	icon_state = "seed-redcarnation"
	species = "redcarnation"
	plantname = "red carnation"
	product = /obj/item/reagent_containers/food/snacks/grown/redcarnation
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "redcarnation-dead"
	icon_harvest = "redcarnation-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "redcarnation-grow"

/obj/item/reagent_containers/food/snacks/grown/redcarnation
	seed = /obj/item/seeds/carnation/red
	name = "red carnation"
	desc = "Beautiful red carnation."
	icon_state = "redcarnation"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//White tulp
/obj/item/seeds/tulp
	name = "pack of white tulp seeds"
	desc = "These seeds grow into white tulp"
	icon_state = "seed-whitetulp"
	species = "whitetulp"
	plantname = "white tulp"
	product = /obj/item/reagent_containers/food/snacks/grown/whitetulp
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "whitetulp-dead"
	icon_harvest = "whitetulp-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "whitetulp-grow"
	mutatelist = list(/obj/item/seeds/tulp/yellow, /obj/item/seeds/tulp/pink)

/obj/item/reagent_containers/food/snacks/grown/whitetulp
	seed = /obj/item/seeds/tulp
	name = "white tulp"
	desc = "Beautiful white tulp."
	icon_state = "whitetulp"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Yellow tulp
/obj/item/seeds/tulp/yellow
	name = "pack of yellow tulp seeds"
	desc = "These seeds grow into yellow tulp"
	icon_state = "seed-yellowtulp"
	species = "yellowtulp"
	plantname = "yellow tulp"
	product = /obj/item/reagent_containers/food/snacks/grown/yellowtulp
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "yellowtulp-dead"
	icon_harvest = "yellowtulp-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "yellowtulp-grow"

/obj/item/reagent_containers/food/snacks/grown/yellowtulp
	seed = /obj/item/seeds/tulp/yellow
	name = "yellow tulp"
	desc = "Beautiful yellow tulp."
	icon_state = "yellowtulp"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Pink tulp
/obj/item/seeds/tulp/pink
	name = "pack of pink tulp seeds"
	desc = "These seeds grow into pink tulp"
	icon_state = "seed-pinktulp"
	species = "pinktulp"
	plantname = "pink tulp"
	product = /obj/item/reagent_containers/food/snacks/grown/pinktulp
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "pinktulp-dead"
	icon_harvest = "pinktulp-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "pinktulp-grow"

/obj/item/reagent_containers/food/snacks/grown/pinktulp
	seed = /obj/item/seeds/tulp/pink
	name = "pink tulp"
	desc = "Beautiful pink tulp."
	icon_state = "pinktulp"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Chamomile
/obj/item/seeds/chamomile
	name = "pack of chamomile seeds"
	desc = "These seeds grow into chamomile"
	icon_state = "seed-chamomile"
	species = "chamomile"
	plantname = "chamomile"
	product = /obj/item/reagent_containers/food/snacks/grown/chamomile
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "chamomile-dead"
	icon_harvest = "chamomile-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "chamomile-grow"
	mutatelist = list(/obj/item/seeds/chamomile/red)

/obj/item/reagent_containers/food/snacks/grown/chamomile
	seed = /obj/item/seeds/chamomile
	name = "chamomile"
	desc = "Beautiful chamomile."
	icon_state = "chamomile"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Red chamomile
/obj/item/seeds/chamomile/red
	name = "pack of red chamomile seeds"
	desc = "These seeds grow into red chamomile"
	icon_state = "seed-redchamomile"
	species = "redchamomile"
	plantname = "red chamomile"
	product = /obj/item/reagent_containers/food/snacks/grown/redchamomile
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "redchamomile-dead"
	icon_harvest = "redchamomile-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "redchamomile-grow"

/obj/item/reagent_containers/food/snacks/grown/redchamomile
	seed = /obj/item/seeds/chamomile/red
	name = "red chamomile"
	desc = "Beautiful red chamomile."
	icon_state = "redchamomile"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//White rose
/obj/item/seeds/rose
	name = "pack of white rose seeds"
	desc = "These seeds grow into white rose"
	icon_state = "seed-whiterose"
	species = "whiterose"
	plantname = "white rose"
	product = /obj/item/reagent_containers/food/snacks/grown/whiterose
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "whiterose-dead"
	icon_harvest = "whiterose-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "whiterose-grow"
	mutatelist = (/obj/item/seeds/rose/red)
	genes = list(/datum/plant_gene/trait/stinging)

/obj/item/reagent_containers/food/snacks/grown/whiterose
	seed = /obj/item/seeds/rose
	name = "white rose"
	desc = "Beautiful white rose."
	icon_state = "whiterose"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)

//Red rose
/obj/item/seeds/rose/red
	name = "pack of red rose seeds"
	desc = "These seeds grow into red rose"
	icon_state = "seed-redrose"
	species = "redrose"
	plantname = "red rose"
	product = /obj/item/reagent_containers/food/snacks/grown/redrose
	growing_icon = 'icons/obj/hydroponics/growing_flowers.dmi'
	icon_dead = "redrose-dead"
	icon_harvest = "redrose-harvest"
	reagents_add = list("plantmatter" = 0.05)
	endurance = 10
	maturation = 8
	yield = 6
	potency = 20
	growthstages = 3
	icon_grow = "redrose-grow"
	genes = list(/datum/plant_gene/trait/stinging)

/obj/item/reagent_containers/food/snacks/grown/redrose
	seed = /obj/item/seeds/rose/red
	name = "red rose"
	desc = "Beautiful red rose."
	icon_state = "redrose"
	filling_color = "#FF6347"
	bitesize_mod = 3
	tastes = list("flower" = 1)
