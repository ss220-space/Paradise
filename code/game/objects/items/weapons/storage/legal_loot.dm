/obj/item/storage/box/legal_loot
	name = "box of odds and ends"
	desc = "Коробка с легальными вещами или фальшивками. В любом случае, здесь ничего опасного и режущего! Безопасно для детей!"
	icon_state = "box_thief"
	var/loot_amount = 1
	var/static/list/possible_type_loot = list(
		/obj/item/toy/balloon,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/soap/ducttape,
		/obj/item/soap/nanotrasen,
		/obj/item/soap/homemade,
		/obj/item/soap/syndie,
		/obj/item/pickaxe/silver,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/bikehorn,
		/obj/item/beach_ball,
		/obj/item/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/katana,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/twohanded/dualsaber/toy,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/accessory/horrible,
		/obj/item/deck/cards,
		/obj/item/deck/cards/tiny,
		/obj/item/deck/unum,
		/obj/item/toy/minimeteor,
		/obj/item/toy/redbutton,
		/obj/item/toy/owl,
		/obj/item/toy/griffin,
		/obj/item/clothing/head/blob,
		/obj/item/id_decal/gold,
		/obj/item/id_decal/silver,
		/obj/item/id_decal/prisoner,
		/obj/item/id_decal/centcom,
		/obj/item/id_decal/emag,
		/obj/item/spellbook/oneuse/fake_gib,
		/obj/item/toy/foamblade,
		/obj/item/toy/flash,
		/obj/item/toy/minigibber,
		/obj/item/toy/nuke,
		/obj/item/toy/AI,
		/obj/item/clothing/under/syndicate/tacticool,
		/obj/item/storage/box/fakesyndiesuit,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
		/obj/item/stack/tile/fakespace/loaded,
		/obj/item/stack/sheet/brass_fake/fifty,
		/obj/item/sord,
		/obj/item/toy/prizeball/figure,
		/obj/item/toy/prizeball/therapy,

		/obj/item/gun/projectile/automatic/toy,
		/obj/item/gun/projectile/automatic/toy/pistol,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/ammo_box/foambox,
		/obj/item/toy/foamblade,
		/obj/item/toy/syndicateballoon,
		/obj/item/clothing/suit/syndicatefake,
		/obj/item/clothing/head/syndicatefake,
		/obj/item/gun/projectile/shotgun/toy/crossbow,
		/obj/item/gun/projectile/automatic/smg/c20r/toy/riot,
		/obj/item/gun/projectile/automatic/l6_saw/toy/riot,
		/obj/item/gun/projectile/automatic/sniper_rifle/toy,
		/obj/item/ammo_box/foambox/riot,
		/obj/item/deck/cards/syndicate
	)

/obj/item/storage/box/legal_loot/populate_contents()
	if(!possible_type_loot)
		possible_type_loot = list(
			/obj/item/toy/balloon,
			/obj/item/storage/wallet,
			/obj/item/storage/photo_album,
			/obj/item/storage/box/snappops,
			/obj/item/storage/fancy/crayons,
			/obj/item/storage/belt/champion,
			/obj/item/soap/deluxe,
			/obj/item/soap/ducttape,
			/obj/item/soap/nanotrasen,
			/obj/item/soap/homemade,
			/obj/item/soap/syndie,
			/obj/item/pickaxe/silver,
			/obj/item/pen/invisible,
			/obj/item/lipstick/random,
			/obj/item/grenade/smokebomb,
			/obj/item/grown/corncob,
			/obj/item/poster/random_contraband,
			/obj/item/bikehorn,
			/obj/item/beach_ball,
			/obj/item/beach_ball/holoball,
			/obj/item/banhammer,
			/obj/item/toy/balloon,
			/obj/item/toy/blink,
			/obj/item/toy/katana,
			/obj/item/toy/spinningtoy,
			/obj/item/toy/sword,
			/obj/item/twohanded/dualsaber/toy,
			/obj/item/paicard,
			/obj/item/instrument/violin,
			/obj/item/instrument/guitar,
			/obj/item/storage/belt/utility/full,
			/obj/item/clothing/accessory/horrible,
			/obj/item/deck/cards,
			/obj/item/deck/cards/tiny,
			/obj/item/deck/unum,
			/obj/item/toy/minimeteor,
			/obj/item/toy/redbutton,
			/obj/item/toy/owl,
			/obj/item/toy/griffin,
			/obj/item/clothing/head/blob,
			/obj/item/id_decal/gold,
			/obj/item/id_decal/silver,
			/obj/item/id_decal/prisoner,
			/obj/item/id_decal/centcom,
			/obj/item/id_decal/emag,
			/obj/item/spellbook/oneuse/fake_gib,
			/obj/item/toy/foamblade,
			/obj/item/toy/flash,
			/obj/item/toy/minigibber,
			/obj/item/toy/nuke,
			/obj/item/toy/AI,
			/obj/item/clothing/under/syndicate/tacticool,
			/obj/item/storage/box/fakesyndiesuit,
			/obj/item/gun/projectile/shotgun/toy/tommygun,
			/obj/item/stack/tile/fakespace/loaded,
			/obj/item/stack/sheet/brass_fake/fifty,
			/obj/item/sord,
			/obj/item/toy/prizeball/figure,
			/obj/item/toy/prizeball/therapy,

			/obj/item/gun/projectile/automatic/toy,
			/obj/item/gun/projectile/automatic/toy/pistol,
			/obj/item/gun/projectile/shotgun/toy,
			/obj/item/ammo_box/foambox,
			/obj/item/toy/foamblade,
			/obj/item/toy/syndicateballoon,
			/obj/item/clothing/suit/syndicatefake,
			/obj/item/clothing/head/syndicatefake,
			/obj/item/gun/projectile/shotgun/toy/crossbow,
			/obj/item/gun/projectile/automatic/smg/c20r/toy/riot,
			/obj/item/gun/projectile/automatic/l6_saw/toy/riot,
			/obj/item/gun/projectile/automatic/sniper_rifle/toy,
			/obj/item/ammo_box/foambox/riot,
			/obj/item/deck/cards/syndicate
		)
		possible_type_loot |= subtypesof(/obj/item/toy) + subtypesof(/obj/item/clothing/head/collectable) + subtypesof(/obj/item/poster) + subtypesof(/obj/item/storage/fancy/cigarettes) + subtypesof(/obj/item/lighter/zippo) + subtypesof(/obj/item/id_decal)
		possible_type_loot -= list(/obj/item/toy/plushie, /obj/item/toy/character, /obj/item/toy/desk, /obj/item/toy/plushie/fluff, /obj/item/toy/random)

	for(var/i in 1 to loot_amount)
		var/loot_type = pick(possible_type_loot)
		new loot_type(src)

/obj/item/storage/box/legal_loot/amount_2
	loot_amount = 2

/obj/item/storage/box/legal_loot/amount_5
	loot_amount = 5

/obj/item/storage/box/legal_loot/amount_10
	loot_amount = 10

/obj/item/storage/box/legal_loot/amount_15
	loot_amount = 15

/obj/item/storage/box/legal_loot/amount_20
	loot_amount = 20

/obj/item/storage/box/legal_loot/amount_30
	loot_amount = 30

/obj/item/storage/box/legal_loot/amount_40
	loot_amount = 40

/obj/item/storage/box/legal_loot/amount_50
	loot_amount = 50
