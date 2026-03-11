/**
 * # Abandoned Crate Loot Spawner
 *
 * Base spawner for generating loot contents in abandoned crates
 */
/obj/effect/spawner/abandoned_crate
	name = "abandoned crate loot spawner"
	desc = "I feel lucky!"
	/// Associative list with actual loot: item_type = quantity
	var/list/loot

/obj/effect/spawner/abandoned_crate/Initialize(mapload)
	. = ..()

	if(!length(loot))
		return

	for(var/atom in loot)
		for(var/i in 1 to loot[atom])
			new atom(loc)

// MARK: Thematic spawners
/obj/effect/spawner/abandoned_crate/booze
	name = "alcohol loot spawner"
	loot = list(
		/obj/item/reagent_containers/food/drinks/bottle/rum = 1,
		/obj/item/reagent_containers/food/drinks/bottle/whiskey = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
	)

/obj/effect/spawner/abandoned_crate/drugs
	name = "drugs loot spawner"
	loot = list(
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus = 1,
	)

/obj/effect/spawner/abandoned_crate/tools
	name = "tools loot spawner"
	loot = list(
		/obj/item/wirecutters = 1,
		/obj/item/screwdriver = 1,
		/obj/item/weldingtool = 1,
		/obj/item/hatchet = 1,
		/obj/item/crowbar = 1,
		/obj/item/kitchen/knife = 1,
		/obj/item/lighter = 1,
	)

/obj/effect/spawner/abandoned_crate/science_equipment
	name = "science equipment loot spawner"
	loot = list(
		/obj/item/reagent_containers/glass/beaker/bluespace = 1,
		/obj/item/reagent_containers/glass/beaker/noreact = 3,
	)

/obj/effect/spawner/abandoned_crate/diamonds
	name = "diamonds loot spawner"
	loot = list(
		/obj/item/stack/ore/diamond = 10,
	)

/obj/effect/spawner/abandoned_crate/bluespace_crystal
	name = "bluespace crystal loot spawner"
	loot = list(
		/obj/item/stack/ore/bluespace_crystal = 5,
	)

/obj/effect/spawner/abandoned_crate/posters
	name = "posters loot spawner"
	loot = list(
		/obj/item/poster/random_contraband = 5,
	)

/obj/effect/spawner/abandoned_crate/bedsheets
	name = "bedding loot spawner"
	loot = list(
		/obj/item/bedsheet = 1,
	)

/obj/effect/spawner/abandoned_crate/casual_clothes
	name = "casual clothes loot spawner"
	loot = list(
		/obj/item/clothing/under/shorts/red = 1,
		/obj/item/clothing/under/shorts/blue = 1,
	)

/obj/effect/spawner/abandoned_crate/funny_clothes
	name = "funny clothes loot spawner"
	loot = list(
		/obj/item/clothing/under/chameleon = 1,
		/obj/item/clothing/accessory/horrible = 7,
		/obj/item/clothing/head/kitty = 5,
		/obj/item/clothing/accessory/petcollar = 5,
	)

/obj/effect/spawner/abandoned_crate/snappops
	name = "snap pops loot spawner"
	loot = list(
		/obj/item/storage/box/snappops = 1,
	)

/obj/effect/spawner/abandoned_crate/toy_weapons
	name = "toy weapons loot spawner"
	loot = list(
		/obj/item/toy/syndicateballoon = 1,
		/obj/item/toy/katana = 1,
		/obj/item/gun/projectile/shotgun/toy/crossbow = 1,
	)

/obj/effect/spawner/abandoned_crate/toy_pistols
	name = "toy pistols loot spawner"
	loot = list(
		/obj/item/gun/projectile/automatic/toy/pistol/enforcer = 1,
		/obj/item/ammo_box/magazine/toy/enforcer = 1,
		/obj/item/gun/projectile/automatic/toy/pistol = 1,
		/obj/item/ammo_box/magazine/toy/pistol = 1,
	)

/obj/effect/spawner/abandoned_crate/toy_balloon
	name = "toy balloon loot spawner"
	loot = list(
		/obj/item/toy/balloon = 1,
	)

/obj/effect/spawner/abandoned_crate/roman_armor
	name = "roman armor loot spawner"
	loot = list(
		/obj/item/clothing/head/helmet/roman/legionaire/fake = 1,
		/obj/item/clothing/under/roman = 1,
		/obj/item/clothing/shoes/roman = 1,
		/obj/item/shield/riot/roman/fake = 1,
	)

/obj/effect/spawner/abandoned_crate/pet_costumes
	name = "pet costumes loot spawner"
	loot = list(
		/obj/item/clothing/suit/ianshirt = 1,
		/obj/item/clothing/suit/corgisuit = 1,
		/obj/item/clothing/head/corgi = 1,
	)

/obj/effect/spawner/abandoned_crate/chicken_costume
	name = "chicken costume loot spawner"
	loot = list(
		/obj/item/clothing/suit/chickensuit = 1,
		/obj/item/clothing/head/chicken = 1,
	)

/obj/effect/spawner/abandoned_crate/clown_kit
	name = "clown kit loot spawner"
	loot = list(
		/obj/item/storage/backpack/clown = 1,
		/obj/item/clothing/under/rank/clown = 1,
		/obj/item/clothing/shoes/clown_shoes = 1,
		/obj/item/pda/clown = 1,
		/obj/item/clothing/mask/gas/clown_hat = 1,
		/obj/item/bikehorn = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana = 1,
	)

/obj/effect/spawner/abandoned_crate/mime_kit
	name = "mime kit loot spawner"
	loot = list(
		/obj/item/clothing/under/mime = 1,
		/obj/item/clothing/shoes/black = 1,
		/obj/item/pda/mime = 1,
		/obj/item/clothing/gloves/color/white = 1,
		/obj/item/clothing/mask/gas/mime = 1,
		/obj/item/clothing/mask/gas/mime/old = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/suit/suspenders = 1,
		/obj/item/toy/crayon/mime = 1,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 1,
	)

/obj/effect/spawner/abandoned_crate/tacticool_gear
	name = "tacticool gear loot spawner"
	loot = list(
		/obj/item/clothing/under/syndicate/tacticool = 1,
		/obj/item/clothing/gloves/combat = 1,
		/obj/item/clothing/shoes/combat = 1,
		/obj/item/clothing/accessory/holster = 1,
		/obj/item/clothing/head/beret = 1,
		/obj/item/clothing/accessory/scarf/red = 1,
		/obj/item/clothing/mask/holo_cigar = 1,
	)

/obj/effect/spawner/abandoned_crate/wrestling_gear
	name = "wrestling gear loot spawner"
	loot = list(
		/obj/item/storage/belt/champion = 1,
		/obj/item/clothing/mask/luchador = 1,
	)

/obj/effect/spawner/abandoned_crate/justice_kit
	name = "justice kit loot spawner"
	loot = list(
		/obj/item/clothing/head/helmet/justice = 1,
		/obj/item/storage/backpack/justice = 1,
	)

/obj/effect/spawner/abandoned_crate/gentleman_kit
	name = "gentleman kit loot spawner"
	loot = list(
		/obj/item/cane = 1,
		/obj/item/clothing/head/collectable/tophat = 1,
	)

/obj/effect/spawner/abandoned_crate/fursuit
	name = "fursuit loot spawner"
	loot = list(
		/obj/item/clothing/head/bearpelt = 1,
	)

/obj/effect/spawner/abandoned_crate/space_suit
	name = "space suit loot spawner"
	loot = list(
		/obj/item/clothing/suit/space = 1,
		/obj/item/clothing/head/helmet/space = 1,
	)

/obj/effect/spawner/abandoned_crate/security_gear
	name = "security gear loot spawner"
	loot = list(
		/obj/item/melee/baton/security = 1,
		/obj/item/melee/baton = 2,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/gun/projectile/automatic/pistol/enforcer = 1,
		/obj/item/ammo_box/magazine/enforcer = 1,
		/obj/item/clothing/mask/balaclava = 1,
		/obj/item/gun/projectile/automatic/pistol = 1,
		/obj/item/ammo_box/magazine/m10mm = 1,
	)

/obj/effect/spawner/abandoned_crate/shotgun_kit
	name = "shotgun kit loot spawner"
	loot = list(
		/obj/item/gun/projectile/shotgun = 1,
		/obj/item/storage/belt/bandolier/full = 1,
	)

/obj/effect/spawner/abandoned_crate/syndicate_gear
	name = "syndicate gear loot spawner"
	loot = list(
		/obj/item/clothing/suit/space/syndicate/green = 1,
		/obj/item/clothing/head/helmet/space/syndicate/green = 1,
	)

/obj/effect/spawner/abandoned_crate/energy_weapons
	name = "energy weapons loot spawner"
	loot = list(
		/obj/item/gun/energy/plasmacutter = 1,
		/obj/item/gun/energy/specter = 1,
		/obj/item/weapon_cell/specter = 1,
	)

/obj/effect/spawner/abandoned_crate/katana
	name = "katana loot spawner"
	loot = list(
		/obj/item/melee/katana = 1,
	)

/obj/effect/spawner/abandoned_crate/wizard_gear
	name = "wizard gear loot spawner"
	loot = list(
		/obj/item/gun/magic/wand = 1,
		/obj/item/spellbook/oneuse/smoke = 1,
	)

/obj/effect/spawner/abandoned_crate/mining_tools
	name = "mining tools loot spawner"
	loot = list(
		/obj/item/pickaxe/drill = 1,
		/obj/item/pickaxe/drill/jackhammer = 1,
		/obj/item/pickaxe/diamond = 1,
		/obj/item/pickaxe/drill/diamonddrill = 1,
		/obj/item/clothing/suit/hooded/goliath = 1,
		/obj/item/twohanded/spear/bonespear = 1,
		/obj/item/borg/upgrade/modkit/aoe/mobs = 1,
	)

/obj/effect/spawner/abandoned_crate/medical
	name = "medical equipment loot spawner"
	loot = list(
		/obj/item/defibrillator/compact = 1,
	)

/obj/effect/spawner/abandoned_crate/organs
	name = "organs loot spawner"
	loot = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/brain/xeno = 1,
		/obj/item/organ/internal/heart = 1,
	)

/obj/effect/spawner/abandoned_crate/cybernetics
	name = "cybernetics loot spawner"
	loot = list(
		/obj/item/organ/internal/cyberimp/arm/katana = 1,
	)

/obj/effect/spawner/abandoned_crate/dna_injectors
	name = "DNA injectors loot spawner"
	loot = list(
		/obj/item/dnainjector/xraymut = 1,
	)

/obj/effect/spawner/abandoned_crate/cash
	name = "cash loot spawner"
	loot = list(
		/obj/item/stack/spacecash/c5000 = 1,
	)

/obj/effect/spawner/abandoned_crate/soulstone
	name = "soulstone loot spawner"
	loot = list(
		/obj/item/soulstone/anybody = 1,
	)

/obj/effect/spawner/abandoned_crate/electronics
	name = "electronics loot spawner"
	loot = list(
		/obj/item/laser_pointer = 1,
		/obj/item/card/emag_broken = 1,
	)

/obj/effect/spawner/abandoned_crate/random_seeds
	name = "random seeds spawner"
	loot = list(
		/obj/item/seeds/random = 1,
		/obj/item/seeds/firelemon = 1,
	)

// MARK: Dynamic spawners
/obj/effect/spawner/abandoned_crate/random_toy
	name = "random toy spawner"

/obj/effect/spawner/abandoned_crate/random_toy/Initialize(mapload)
	var/prize = pick(subtypesof(/obj/item/toy))
	loot[prize] = 1
	return ..()

/obj/effect/spawner/abandoned_crate/random_coins
	name = "random coins spawner"

/obj/effect/spawner/abandoned_crate/random_coins/Initialize(mapload)
	var/coin_types = list(
		/obj/item/coin/silver = 3,
		/obj/item/coin/iron = 3,
		/obj/item/coin/gold = 1,
		/obj/item/coin/diamond = 1,
		/obj/item/coin/plasma = 1,
		/obj/item/coin/uranium = 1
	)
	var/num_coins = rand(4, 7)
	loot = list()
	for(var/i in 1 to num_coins)
		var/coin_type = pick_weight_classic(coin_types)
		loot[coin_type] = (loot[coin_type] || 0) + 1
	return ..()

/obj/effect/spawner/abandoned_crate/random_components
	name = "random components spawner"

/obj/effect/spawner/abandoned_crate/random_components/Initialize(mapload)
	var/num_parts = rand(4, 7)
	loot = list()
	for(var/i in 1 to num_parts)
		var/part_type = pick(subtypesof(/obj/item/stock_parts))
		loot[part_type] = (loot[part_type] || 0) + 1
	return ..()

/obj/effect/spawner/abandoned_crate/bombarda
	name = "bombarda spawner"
	loot = list(
		/obj/item/gun/projectile/bombarda = 1,
	)

/obj/effect/spawner/abandoned_crate/bombarda/Initialize(mapload)
	var/shell_types = list(
		/obj/item/ammo_casing/a40mm/improvised/exp_shell,
		/obj/item/ammo_casing/a40mm/improvised/flame_shell,
		/obj/item/ammo_casing/a40mm/improvised/smoke_shell
	)
	var/num_shells = rand(1, 5)
	loot = list(/obj/item/gun/projectile/bombarda = 1)
	for(var/i in 1 to num_shells)
		var/shell_type = pick(shell_types)
		loot[shell_type] = (loot[shell_type] || 0) + 1
	return ..()

/obj/effect/spawner/abandoned_crate/weed
	name = "cannabis spawner"

/obj/effect/spawner/abandoned_crate/weed/Initialize(mapload)
	var/seed_type = pick(typesof(/obj/item/seeds/cannabis))
	var/cannabis_type= pick(typesof(/obj/item/reagent_containers/food/snacks/grown/cannabis))
	var/weed_amount = rand(2, 4)
	loot = list()
	for(var/i in 1 to weed_amount)
		loot[seed_type] = (loot[seed_type] || 0) + 1
		loot[cannabis_type] = (loot[cannabis_type] || 0) + 1

	return ..()
