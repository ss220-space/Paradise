
// /datum/recipe/oven

/datum/recipe/oven/bun
	items = list(
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/bun

/datum/recipe/oven/meatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/meat

/datum/recipe/oven/syntibread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/meat

/datum/recipe/oven/xenomeatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/xeno

/datum/recipe/oven/bananabread
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/banana

/datum/recipe/oven/muffin
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/muffin

/datum/recipe/oven/carrotcake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/carrot
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/carrotcake

/datum/recipe/oven/cheesecake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/cheesecake

/datum/recipe/oven/plaincake
	reagents = list("milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/plaincake

/datum/recipe/oven/meatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie

/datum/recipe/oven/meatpie_human
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/human,
		/obj/item/organ/internal/liver,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/human

/datum/recipe/oven/meatpie_vulpkanin
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vulpkanin,
		/obj/item/organ/internal/liver/vulpkanin,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/vulpkanin

/datum/recipe/oven/meatpie_tajaran
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/tajaran,
		/obj/item/organ/internal/liver/tajaran,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/tajaran

/datum/recipe/oven/meatpie_unathi
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/unathi,
		/obj/item/organ/internal/liver/unathi,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/unathi

/datum/recipe/oven/meatpie_drask
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/drask,
		/obj/item/organ/internal/liver/drask,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/drask

/datum/recipe/oven/meatpie_grey
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/grey,
		/obj/item/organ/internal/liver/grey,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/grey

/datum/recipe/oven/meatpie_skrell
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/skrell,
		/obj/item/organ/internal/liver/skrell,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/skrell

/datum/recipe/oven/meatpie_vox
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/vox,
		/obj/item/organ/internal/liver/vox,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/vox

/datum/recipe/oven/meatpie_slime
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/slime,
		/obj/item/organ/internal/heart/slime,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/slime

/datum/recipe/oven/meatpie_wryn
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wryn,
		/obj/item/organ/internal/wryn/glands,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/wryn

/datum/recipe/oven/meatpie_kidan
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/kidan,
		/obj/item/organ/internal/liver/kidan,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/kidan

/datum/recipe/oven/meatpie_nian
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/nian,
		/obj/item/organ/internal/liver/nian,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/nian

/datum/recipe/oven/meatpie_diona
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/diona,
		/obj/item/organ/internal/liver/diona,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/diona

/datum/recipe/oven/meatpie_monkey
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/organ/internal/heart,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/monkey

/datum/recipe/oven/meatpie_farwa
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/farwa,
		/obj/item/organ/internal/heart/tajaran,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/farwa

/datum/recipe/oven/meatpie_wolpin
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/wolpin,
		/obj/item/organ/internal/heart/vulpkanin,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/wolpin

/datum/recipe/oven/meatpie_neara
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/neara,
		/obj/item/organ/internal/heart/skrell,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/neara

/datum/recipe/oven/meatpie_stok
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/stok,
		/obj/item/organ/internal/heart/unathi,
	)
	result = /obj/item/reagent_containers/food/snacks/meatpie/stok

/datum/recipe/oven/tofupie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/tofu,
	)
	result = /obj/item/reagent_containers/food/snacks/tofupie

/datum/recipe/oven/xemeatpie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/monstermeat/xenomeat
	)
	result = /obj/item/reagent_containers/food/snacks/xemeatpie

/datum/recipe/oven/pie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/pie

/datum/recipe/oven/cherrypie
	reagents = list("sugar" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/cherries
	)
	result = /obj/item/reagent_containers/food/snacks/cherrypie

/datum/recipe/oven/berryclafoutis
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/berries
	)
	result = /obj/item/reagent_containers/food/snacks/berryclafoutis

/datum/recipe/oven/tofubread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread/tofu

/datum/recipe/oven/loadedbakedpotato
	items = list(
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/potato
	)
	result = /obj/item/reagent_containers/food/snacks/loadedbakedpotato

/datum/recipe/oven/yakiimo
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/potato/sweet
	)
	result = /obj/item/reagent_containers/food/snacks/yakiimo

////cookies by Ume

/datum/recipe/oven/cookies
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies/chocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray

/datum/recipe/oven/cocochips
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies/cocochips,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/cocochips

/datum/recipe/oven/sugarcookies
	items = list(
		/obj/item/reagent_containers/food/snacks/rawcookies,
	)
	result = /obj/item/storage/bag/tray/cookies_tray/sugarcookie


////

/datum/recipe/oven/fortunecookie
	reagents = list("sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice,
		/obj/item/paper,
	)
	result = /obj/item/reagent_containers/food/snacks/fortunecookie

/datum/recipe/oven/fortunecookie/make_food(obj/container)
	var/obj/item/paper/P = locate() in container
	P.loc = null //So we don't delete the paper while cooking the cookie
	var/obj/item/reagent_containers/food/snacks/fortunecookie/being_cooked = ..()
	if(P.info) //If there's anything written on the paper, just move it into the fortune cookie
		P.forceMove(being_cooked) //Prevents the oven deleting our paper
		being_cooked.trash = P //so the paper is left behind as trash without special-snowflake(TM Nodrak) code ~carn
	else
		qdel(P)
	return being_cooked

/datum/recipe/oven/pizzamargherita
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita

/datum/recipe/oven/meatpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/oven/syntipizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/meat/syntiflesh,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza

/datum/recipe/oven/mushroompizza

	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza

/datum/recipe/oven/vegetablepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/eggplant,
		/obj/item/reagent_containers/food/snacks/grown/carrot,
		/obj/item/reagent_containers/food/snacks/grown/corn,
		/obj/item/reagent_containers/food/snacks/grown/tomato
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza

/datum/recipe/oven/hawaiianpizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/pineappleslice,
		/obj/item/reagent_containers/food/snacks/meat,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza

/datum/recipe/oven/macncheesepizza
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/macncheese,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/macpizza

/datum/recipe/oven/seapizza
	reagents = list("herbsmix" = 1, "gsauce" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/salmonmeat,
		/obj/item/reagent_containers/food/snacks/boiled_shrimp,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/seafood

/datum/recipe/oven/tajarpizza
	reagents = list("herbsmix" = 1, "tsauce" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/tajaroni,
		/obj/item/reagent_containers/food/snacks/grown/olive,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/tajaroni

/datum/recipe/oven/baconpizza
	reagents = list("msauce" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/grown/mushroom,
		/obj/item/reagent_containers/food/snacks/raw_bacon,
		/obj/item/reagent_containers/food/snacks/raw_bacon
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/bacon

/datum/recipe/oven/diablopizza
	reagents = list("herbsmix" = 1, "dsauce" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/meatball,
		/obj/item/reagent_containers/food/snacks/meatball
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pizza/diablo

/datum/recipe/oven/amanita_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita
	)
	result = /obj/item/reagent_containers/food/snacks/amanita_pie

/datum/recipe/oven/plump_pie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet
	)
	result = /obj/item/reagent_containers/food/snacks/plump_pie

/datum/recipe/oven/plumphelmetbiscuit
	reagents = list("water" = 5, "flour" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet)
	result = /obj/item/reagent_containers/food/snacks/plumphelmetbiscuit

/datum/recipe/oven/creamcheesebread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/creamcheesebread

/datum/recipe/oven/baguette
	reagents = list("sodiumchloride" = 1, "blackpepper" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
	)
	result = /obj/item/reagent_containers/food/snacks/baguette

/datum/recipe/oven/birthdaycake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/clothing/head/cakehat
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/birthdaycake

/datum/recipe/oven/bread
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bread

/datum/recipe/oven/bread/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sliceable/bread/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/applepie
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/applepie

/datum/recipe/oven/applecake
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/apple,
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/applecake

/datum/recipe/oven/orangecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange,
		/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/orangecake

/datum/recipe/oven/bananacake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/bananacake

/datum/recipe/oven/limecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lime
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/limecake

/datum/recipe/oven/lemoncake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon,
		/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/lemoncake

/datum/recipe/oven/chocolatecake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/chocolatecake

/datum/recipe/oven/braincake
	reagents = list("milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/organ/internal/brain
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/braincake

/datum/recipe/oven/pumpkinpie
	reagents = list("milk" = 5, "sugar" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough,
		/obj/item/reagent_containers/food/snacks/grown/pumpkin
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/pumpkinpie

/datum/recipe/oven/appletart
	reagents = list("sugar" = 5, "milk" = 5, "flour" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/grown/apple/gold
	)
	result = /obj/item/reagent_containers/food/snacks/appletart

/datum/recipe/oven/appletart/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/appletart/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/cracker
	reagents = list("sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/doughslice
	)
	result = /obj/item/reagent_containers/food/snacks/cracker

/datum/recipe/oven/sugarcookie/make_food(obj/container)
	var/obj/item/reagent_containers/food/snacks/sugarcookie/being_cooked = ..()
	being_cooked.reagents.del_reagent("egg")
	return being_cooked

/datum/recipe/oven/flatbread
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/flatdough
	)
	result = /obj/item/reagent_containers/food/snacks/flatbread

/datum/recipe/oven/toastedsandwich
	items = list(
		/obj/item/reagent_containers/food/snacks/sandwich
	)
	result = /obj/item/reagent_containers/food/snacks/toastedsandwich

/datum/recipe/oven/turkey  // Magic
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/stuffing,
		/obj/item/reagent_containers/food/snacks/stuffing
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/turkey

/datum/recipe/oven/tofurkey
	items = list(
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/tofu,
		/obj/item/reagent_containers/food/snacks/stuffing,
	)
	result = /obj/item/reagent_containers/food/snacks/tofurkey

/datum/recipe/oven/lasagna
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/cheesewedge,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/grown/tomato,
		/obj/item/reagent_containers/food/snacks/dough
	)
	result = /obj/item/reagent_containers/food/snacks/lasagna

/datum/recipe/oven/tajaroni
	reagents = list("blackpepper" = 1)
	items = list(
		/obj/item/organ/external/tail/tajaran,
		/obj/item/reagent_containers/food/snacks/grown/garlic,
		/obj/item/reagent_containers/food/snacks/grown/chili,
		/obj/item/reagent_containers/food/snacks/meat
	)
	result = /obj/item/reagent_containers/food/snacks/tajaroni

/datum/recipe/oven/vuplix
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "tsauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix

/datum/recipe/oven/vulpixchilli
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "dsauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/chili
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/chilli

/datum/recipe/oven/vulpixcheese
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "csauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/cheesewedge
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/cheese

/datum/recipe/oven/vulpixbacon
	reagents = list("blackpepper" = 1, "sodiumchloride" = 1, "herbsmix" = 1, "msauce" = 1, "cream" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/internal/liver/vulpkanin,
		/obj/item/reagent_containers/food/snacks/raw_bacon,
		/obj/item/reagent_containers/food/snacks/grown/mushroom
	)
	result = /obj/item/reagent_containers/food/snacks/vulpix/bacon

/datum/recipe/oven/slimepie
	reagents = list("custard" = 1, "milk" = 5, "sugar" = 15)
	items = list(
		/obj/item/organ/internal/heart/slime
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/slimepie

//////////////////////////////////////////
//onyx bay food
//////////////////////////////////////////

/datum/recipe/oven/bunbun
	items = list(
		/obj/item/reagent_containers/food/snacks/bun,
		/obj/item/reagent_containers/food/snacks/bun
	)
	result = /obj/item/reagent_containers/food/snacks/bunbun

/datum/recipe/oven/choccherrycake
	reagents = list("milk" = 5, "flour" = 15)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/grown/cherries
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/choccherrycake

/datum/recipe/oven/smokedsausage
	reagents = list("sodiumchloride" = 5, "blackpepper" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/sausage
	)
	result = /obj/item/reagent_containers/food/snacks/smokedsausage

/datum/recipe/oven/salami
	reagents = list("gsauce" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/smokedsausage
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/salami

/datum/recipe/oven/sundae
	reagents = list("cream" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/grown/cherries,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/doughslice
	)
	result = /obj/item/reagent_containers/food/snacks/sundae

/datum/recipe/oven/noel
	reagents = list("flour" = 15, "cream" = 10, "milk" = 5)
	items = list(
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/egg,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/chocolatebar,
		/obj/item/reagent_containers/food/snacks/grown/berries,
		/obj/item/reagent_containers/food/snacks/grown/berries
	)
	result = /obj/item/reagent_containers/food/snacks/sliceable/noel

//////////////////////////////////////////
//Reinforced cheese
//////////////////////////////////////////
/datum/recipe/oven/reinforcedcheese
	reagents = list("sodiumchloride" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesewheel
	)
	result = /obj/item/stack/sheet/cheese

/datum/recipe/oven/bakedvulp
	reagents = list("sodiumchloride" = 2, "blackpepper" = 2)
	items = list(
		/obj/item/reagent_containers/food/snacks/meat,
		/obj/item/organ/external/head/vulpkanin,
		/obj/item/reagent_containers/food/snacks/grown/apple
	)
	result = /obj/item/reagent_containers/food/snacks/bakedvulp

//////////////////////////////////////////
//Reinforced gingerbread
//////////////////////////////////////////

/datum/recipe/oven/reinforcedcheese
	reagents = list("sodiumchloride" = 10)
	items = list(
		/obj/item/reagent_containers/food/snacks/gingercookie,
		/obj/item/reagent_containers/food/snacks/gingercookie
	)
	result = /obj/item/stack/sheet/gingerbread/five

//////////////////////////////////////////
//Ginger cookies
//////////////////////////////////////////

/datum/recipe/oven/gingercokie
	reagents = list("sugar" = 1)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie

/datum/recipe/oven/gingercokie/ball
	reagents = list("sugar" = 2)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/ball

/datum/recipe/oven/gingercokie/cane
	reagents = list("sugar" = 3)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/cane

/datum/recipe/oven/gingercokie/heart
	reagents = list("sugar" = 4)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/heart

/datum/recipe/oven/gingercokie/home
	reagents = list("sugar" = 5)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/home

/datum/recipe/oven/gingercokie/mitten
	reagents = list("sugar" = 6)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/mitten

/datum/recipe/oven/gingercokie/tree
	reagents = list("sugar" = 7)
	items = list(/obj/item/reagent_containers/food/snacks/cookiedough)
	result = /obj/item/reagent_containers/food/snacks/gingercookie/tree

//////////////////////////////////////////
//Carbon dulce Feliz Navidad
//////////////////////////////////////////

/datum/recipe/oven/sugar_coal
	reagents = list("charcoal" = 5, "sugar" = 5, "egg" = 5)
	result = /obj/item/reagent_containers/food/snacks/sugar_coal

/datum/recipe/oven/croissant
	reagents = list("milk" = 5, "sugar" = 5, "sodiumchloride" = 1)
	items = list(
		/obj/item/reagent_containers/food/snacks/dough,
		/obj/item/reagent_containers/food/snacks/egg
	)
	result = /obj/item/reagent_containers/food/snacks/croissant
