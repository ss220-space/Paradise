
// /datum/recipe/grill

/datum/recipe/grill/bacon
	items = list(
		/obj/item/reagent_containers/food/snacks/raw_bacon,
	)
	result = /obj/item/reagent_containers/food/snacks/bacon

/datum/recipe/grill/telebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon


/datum/recipe/grill/syntitelebacon
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/assembly/signaler
	)
	result = /obj/item/reagent_containers/food/snacks/telebacon

/datum/recipe/grill/friedegg
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/friedegg

/datum/recipe/grill/birdsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/bird
	)
	result = /obj/item/reagent_containers/food/snacks/birdsteak

/datum/recipe/grill/meatsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/salmonsteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat
	)
	result = /obj/item/reagent_containers/food/snacks/salmonsteak

/datum/recipe/grill/syntisteak
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak

/datum/recipe/grill/meatsteak_human
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/grown/eggplant
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/human

/datum/recipe/grill/meatsteak_vulpkanin
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/vulpkanin

/datum/recipe/grill/meatsteak_tajaran
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "sodawater" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran,
		/obj/item/grown/nettle/basic
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/tajaran

/datum/recipe/grill/meatsteak_unathi
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "tomatojuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/unathi,
		/obj/item/reagent_containers/food/snacks/grown/harebell
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/unathi

/datum/recipe/grill/meatsteak_drask
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "capsaicin" = 10, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/drask,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/drask

/datum/recipe/grill/meatsteak_grey
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "tomatojuice" = 10, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/grey,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/cabbage
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/grey

/datum/recipe/grill/meatsteak_skrell
	reagents = list("sodiumchloride" = 1, "blackpepper" = 5, "tomatojuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/skrell,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/skrell

/datum/recipe/grill/meatsteak_vox
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vox,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet,
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/vox

/datum/recipe/grill/meatsteak_slime
	reagents = list("sodiumchloride" = 10, "sugar" = 5, "herbsmix" = 5, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/slime,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/slime

/datum/recipe/grill/meatsteak_wryn
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "orangejuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wryn,
		/obj/item/reagent_containers/food/snacks/grown/potato,
		/obj/item/reagent_containers/food/snacks/grown/potato
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/wryn

/datum/recipe/grill/meatsteak_kidan
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/kidan,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/olive,
		/obj/item/reagent_containers/food/snacks/grown/olive,
		/obj/item/reagent_containers/food/snacks/grown/olive
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/kidan

/datum/recipe/grill/meatsteak_nian
	reagents = list("sodiumchloride" = 5, "sugar" = 5, "herbsmix" = 5, "lemonjuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/nian,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/nian

/datum/recipe/grill/meatsteak_diona
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/diona

/datum/recipe/grill/meatsteak_monkey
	reagents = list("sodiumchloride" = 5, "blackpepper" = 1, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/monkey

/datum/recipe/grill/meatsteak_farwa
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "grapejuice" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/farwa,
		/obj/item/reagent_containers/food/snacks/grown/poppy,
		/obj/item/reagent_containers/food/snacks/grown/poppy
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/farwa

/datum/recipe/grill/meatsteak_wolpin
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1, "potato" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wolpin,
		/obj/item/reagent_containers/food/snacks/onion_slice/red,
		/obj/item/reagent_containers/food/snacks/onion_slice/red
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/wolpin

/datum/recipe/grill/meatsteak_neara
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2, "lemonjuice" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/neara,
		/obj/item/reagent_containers/food/snacks/grown/soybeans,
		/obj/item/reagent_containers/food/snacks/grown/soybeans
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/neara

/datum/recipe/grill/meatsteak_stok
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2, "orangejuice" = 5, "herbsmix" = 5, "oliveoil" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat/humanoid/stok,
		/obj/item/reagent_containers/food/snacks/cucumberslice,
		/obj/item/reagent_containers/food/snacks/cucumberslice
	)
	result = /obj/item/reagent_containers/food/snacks/meatsteak/stok

/datum/recipe/grill/waffles
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/waffles

/datum/recipe/grill/rofflewaffles
	reagents = list("psilocybin" = 5, "sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/rofflewaffles

/datum/recipe/grill/grilledcheese
	items = list(
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/breadslice,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/grilledcheese

/datum/recipe/grill/sausage
	items = list(
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/cutlet,
	)
	result = /obj/item/reagent_containers/food/snacks/sausage

/datum/recipe/grill/fishfingers
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/carpmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/fishfingers

/datum/recipe/grill/fishfingers/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/fishfingers/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/grill/cutlet
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcutlet
	)
	result = /obj/item/reagent_containers/food/snacks/cutlet

/datum/recipe/grill/omelette
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/omelette

/datum/recipe/grill/wingfangchu
	reagents = list("soysauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/reagent_containers/food/snacks/wingfangchu

/datum/recipe/grill/human/kabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
	)
	result = /obj/item/reagent_containers/food/snacks/kabob

/datum/recipe/grill/monkeykabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/syntikabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
	)
	result = /obj/item/reagent_containers/food/snacks/monkeykabob

/datum/recipe/grill/tofukabob
	items = list(
		/obj/item/stack/rods,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofukabob

/datum/recipe/grill/sushi_Tamago
	reagents = list("sake" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tamago

/datum/recipe/grill/sushi_Unagi
	reagents = list("sake" = 5)
	items = list(
		/obj/item/fish/electric_eel,
		/obj/item/reagent_containers/food/snacks/boiledrice,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Unagi

/datum/recipe/grill/sushi_Ebi
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ebi

/datum/recipe/grill/sushi_Ikura
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/salmon,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Ikura

/datum/recipe/grill/sushi_Inari
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/fried_tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Inari

/datum/recipe/grill/sushi_Sake
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Sake

/datum/recipe/grill/sushi_SmokedSalmon
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/salmonsteak,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_SmokedSalmon

/datum/recipe/grill/sushi_Masago
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/goldfish,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Masago

/datum/recipe/grill/sushi_Tobiko
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/fish_eggs/shark,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tobiko

/datum/recipe/grill/sushi_TobikoEgg
	items = list(
		/obj/item/reagent_containers/food/snacks/sushi_Tobiko,
		/obj/item/reagent_containers/food/snacks/egg,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_TobikoEgg

/datum/recipe/grill/sushi_Tai
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/catfishmeat,
	)
	result = /obj/item/reagent_containers/food/snacks/sushi_Tai

/datum/recipe/grill/goliath
	items = list(/obj/item/reagent_containers/food/snacks/monstermeat/goliath)
	result = /obj/item/reagent_containers/food/snacks/goliath_steak

/datum/recipe/grill/shrimp_skewer
	items = list(
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/reagent_containers/food/snacks/shrimp,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/shrimp_skewer

/datum/recipe/grill/fish_skewer
	reagents = list("flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/stack/rods,
	)
	result = /obj/item/reagent_containers/food/snacks/fish_skewer

/datum/recipe/grill/pancake
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough
	)
	result = /obj/item/reagent_containers/food/snacks/pancake

/datum/recipe/grill/berry_pancake
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/grown/berries
	)
	result = /obj/item/reagent_containers/food/snacks/pancake/berry_pancake

/datum/recipe/grill/choc_chip_pancake
	items = list(
		/obj/item/reagent_containers/food/snacks/cookiedough,
		/obj/item/reagent_containers/food/snacks/choc_pile
	)
	result = /obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake

/datum/recipe/grill/unathi
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "tsauce" = 1)
	items = list(
		/obj/item/organ/external/tail/unathi
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lizard

/datum/recipe/grill/plov
	items = list(
		/obj/item/reagent_containers/food/snacks/boiledrice,
		/obj/item/reagent_containers/food/snacks/onion_slice,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/rawcutlet,
		/obj/item/reagent_containers/food/snacks/grown/garlic
	)
	result = /obj/item/reagent_containers/food/snacks/plov
