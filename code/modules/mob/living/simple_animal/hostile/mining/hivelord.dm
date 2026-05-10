//Tendril-spawned Legion remains, the charred skeletons of those whose bodies sank into laval or fell into chasms.
/obj/effect/mob_spawn/human/corpse/charredskeleton // Похуй потом Вынести этот кал куда-нибуть в другое место
	name = "charred skeletal remains"
	burn_damage = 1000
	mob_name = "ashen skeleton"
	mob_gender = NEUTER
	husk = FALSE
	mob_species = /datum/species/skeleton
	mob_color = "#454545"

/obj/effect/mob_spawn/human/corpse/charredskeleton/get_ru_names()
	return list(
		NOMINATIVE = "обугленные останки",
		GENITIVE = "обугленных останков",
		DATIVE = "обугленным останкам",
		ACCUSATIVE = "обугленные останки",
		INSTRUMENTAL = "обугленными останками",
		PREPOSITIONAL = "об обугленных останках",
	)

//Legion infested mobs

/obj/effect/mob_spawn/human/corpse/damaged/legioninfested/monkey/equip(mob/living/carbon/human/H, use_prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	. = ..()
	H.force_gene_block(GLOB.monkeyblock, TRUE)

/obj/effect/mob_spawn/human/corpse/damaged/legioninfested/dwarf/equip(mob/living/carbon/human/H, use_prefs = FALSE, _mob_name = FALSE, _mob_gender = FALSE, _mob_species = FALSE)
	. = ..()
	H.force_gene_block(GLOB.smallsizeblock, TRUE)

/obj/effect/mob_spawn/human/corpse/damaged/legioninfested/Initialize(mapload)
	var/type = pickweight(list("Miner" = 66, "Ashwalker" = 10, "Golem" = 10,"Clown" = 10, pick(list("Shadow", "YeOlde","Operative", "Cultist")) = 4))
	switch(type)
		if("Miner")
			mob_species = pickweight(list(/datum/species/human = 72, /datum/species/unathi = 28))
			uniform = /obj/item/clothing/under/rank/miner/lavaland
			if(prob(4))
				belt = pickweight(list(/obj/item/storage/belt/mining = 2, /obj/item/storage/belt/mining/alt = 2))
			else if(prob(10))
				belt = pickweight(list(/obj/item/pickaxe = 8, /obj/item/pickaxe/mini = 4, /obj/item/pickaxe/silver = 2, /obj/item/pickaxe/diamond = 1))
			else
				belt = /obj/item/tank/internals/emergency_oxygen/engi
			if(mob_species != /datum/species/unathi)
				shoes = /obj/item/clothing/shoes/workboots/mining
			gloves = /obj/item/clothing/gloves/color/black
			mask = /obj/item/clothing/mask/gas/explorer
			if(prob(20))
				suit = pickweight(list(/obj/item/clothing/suit/hooded/explorer = 18, /obj/item/clothing/suit/hooded/goliath = 2))
			if(prob(30))
				r_pocket = pickweight(list(/obj/item/stack/marker_beacon = 20, /obj/item/stack/spacecash/c1000 = 7, /obj/item/reagent_containers/hypospray/autoinjector/survival = 2, /obj/item/borg/upgrade/modkit/damage = 1 ))
			if(prob(10))
				l_pocket = pickweight(list(/obj/item/stack/spacecash/c1000 = 7, /obj/item/reagent_containers/hypospray/autoinjector/survival = 2, /obj/item/borg/upgrade/modkit/cooldown/haste = 1 ))
		if("Ashwalker")
			mob_species = /datum/species/unathi/ashwalker
			uniform = /obj/item/clothing/under/ash_walker
			if(prob(95))
				head = /obj/item/clothing/head/helmet/gladiator
			else
				head = /obj/item/clothing/head/helmet/skull
				suit = /obj/item/clothing/suit/armor/bone
				gloves = /obj/item/clothing/gloves/bracer
			if(prob(5))
				back = pickweight(list(/obj/item/twohanded/spear/bonespear = 3, /obj/item/twohanded/fireaxe/boneaxe = 2))
			if(prob(10))
				belt = /obj/item/storage/belt/mining/primitive
			if(prob(30))
				r_pocket = /obj/item/kitchen/knife/combat/survival/bone
			if(prob(30))
				l_pocket = /obj/item/kitchen/knife/combat/survival/bone
		if("Clown")
			name = pick(GLOB.clown_names)
			outfit = /datum/outfit/job/clown
			belt = null
			backpack_contents = list()
			if(prob(70))
				backpack_contents += list(/obj/item/stamp/clown = 1, /obj/item/reagent_containers/spray/waterflower = 1, /obj/item/reagent_containers/food/snacks/grown/banana = 1, /obj/item/megaphone = 1)
			if(prob(30))
				backpack_contents += list(/obj/item/stack/sheet/mineral/bananium = pickweight(list(1 = 3, 2 = 2, 3 = 1)))
			if(prob(10))
				l_pocket = pickweight(list(/obj/item/bikehorn/golden = 3, /obj/item/bikehorn/airhorn= 1 ))
			if(prob(10))
				r_pocket = /obj/item/implanter/sad_trombone
		if("Golem")
			mob_species = pick(list(/datum/species/golem/adamantine, /datum/species/golem/plasma, /datum/species/golem/diamond, /datum/species/golem/gold, /datum/species/golem/silver, /datum/species/golem/plasteel, /datum/species/golem/titanium, /datum/species/golem/plastitanium))
			if(prob(30))
				glasses = pickweight(list(/obj/item/clothing/glasses/meson = 2, /obj/item/clothing/glasses/hud/health = 2, /obj/item/clothing/glasses/hud/diagnostic =2, /obj/item/clothing/glasses/science = 2, /obj/item/clothing/glasses/welding = 2, /obj/item/clothing/glasses/night = 1))
			if(prob(10))
				belt = pick(list(/obj/item/storage/belt/mining/vendor, /obj/item/storage/belt/utility/full))
			if(prob(50))
				back = /obj/item/bedsheet/rd/royal_cape
			if(prob(10))
				l_pocket = pick(list(/obj/item/crowbar/power, /obj/item/wrench/power, /obj/item/weldingtool/experimental))
		if("YeOlde")
			mob_gender = FEMALE
			uniform = /obj/item/clothing/under/maid
			gloves = /obj/item/clothing/gloves/color/white
			shoes = /obj/item/clothing/shoes/laceup
			head = /obj/item/clothing/head/helmet/riot/knight
			suit = /obj/item/clothing/suit/armor/riot/knight
			back = /obj/item/shield/riot/buckler
			belt = /obj/item/nullrod/claymore
			r_pocket = /obj/item/tank/internals/emergency_oxygen
			mask = /obj/item/clothing/mask/breath
		if("Operative")
			id_job = "Operative"
			outfit = /datum/outfit/syndicatecommandocorpse
		if("Shadow")
			mob_species = /datum/species/shadow
			uniform = /obj/item/clothing/under/color/black
			shoes = /obj/item/clothing/shoes/color/black
			suit = /obj/item/clothing/suit/storage/labcoat
			glasses = /obj/item/clothing/glasses/sunglasses/blindfold/black
			back = /obj/item/tank/internals/oxygen
			mask = /obj/item/clothing/mask/breath
		if("Cultist")
			uniform = /obj/item/clothing/under/roman
			suit = /obj/item/clothing/suit/hooded/cultrobes
			suit_store = /obj/item/tome
			r_pocket = /obj/item/restraints/legcuffs/bola/cult
			l_pocket = /obj/item/melee/cultblade/dagger
			glasses =  /obj/item/clothing/glasses/hud/health/night
			backpack_contents = list(/obj/item/reagent_containers/food/drinks/bottle/unholywater = 1, /obj/item/cult_shift = 1, /obj/item/flashlight/flare = 1, /obj/item/stack/sheet/runed_metal = 15)
	. = ..()
