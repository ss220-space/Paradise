/datum/outfit/deathmatch_loadout //remember that fun > balance
	name = ""
	shoes = /obj/item/clothing/shoes/color/black // im not doing this on all of them
	/// Name shown in the UI
	var/display_name = ""
	/// Description shown in the UI
	var/desc = ":KILL:"
	/// If defined, using this outfit sets the targets species to it
	var/datum/species/species_override
	/// This outfit will grant these spells if applied
	var/list/spells_to_add = list()
	// Apply mutations in post_equip procs!
	/// Used for making a list for specific loadout groups
	var/loadout_type

/datum/outfit/deathmatch_loadout/pre_equip(mob/living/carbon/human/user, visuals_only = FALSE)
	. = ..()

	if(isdummy(user))
		return

	if(!isnull(species_override))
		user.set_species(species_override)
	else
		user.set_species(/datum/species/human)
	// TODO: rewrite it for datum/action/cooldown when it's ported
	for(var/obj/effect/proc_holder/spell/aspell as anything in spells_to_add)
		var/obj/effect/proc_holder/spell/our_spell = new aspell(user)
		our_spell.clothes_req = FALSE
		user.AddSpell(our_spell)

/datum/outfit/deathmatch_loadout/post_equip(mob/living/carbon/human/our_human, visualsOnly)
	..()
	if(!ismodcontrol(our_human.back))
		return
	var/obj/item/mod/control/mod_control = our_human.back
	mod_control.quick_activation()
	our_human.mind?.offstation_role = TRUE

/datum/outfit/deathmatch_loadout/naked
	name = "Deathmatch: Naked"
	display_name = "Без одежды"
	desc = "Голые космонавтики жаждут устроить кровавую баню."
	shoes = null

/datum/outfit/deathmatch_loadout/assistant
	name = "Deathmatch: Assistant"
	display_name = "Ассистент"
	desc = "Классический ассистент — серый комбинезон и туллбокс в руках."

	loadout_type = LOADOUT_ASSISTANT

	l_hand = /obj/item/storage/toolbox/mechanical
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	belt = /obj/item/flashlight

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
	)

/datum/outfit/deathmatch_loadout/assistant/weaponless
	name = "Deathmatch: Assistant (Weaponless)"
	display_name = "Ассистент (без оружия)"
	desc = "Что есть ассистент без своего туллбокса? Правильно, ничто."

	l_hand = null

/datum/outfit/deathmatch_loadout/operative
	name = "Deathmatch: Operative"
	display_name = "Оперативник (без оружия)"
	desc = "Оперативник синдиката без оружия."

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

	loadout_type = LOADOUT_SYNDICATE

/datum/outfit/deathmatch_loadout/operative/ranged
	name = "Deathmatch: Ranged Operative"
	display_name = "Оперативник (Дальний бой)"
	desc = "Оперативник синдиката с ножом и пистолетом."

	l_hand = /obj/item/gun/projectile/automatic/pistol
	l_pocket = /obj/item/kitchen/knife/combat
	backpack_contents = list(/obj/item/ammo_box/magazine/m10mm = 5)

/datum/outfit/deathmatch_loadout/operative/melee
	name = "Deathmatch: Melee Operative"
	display_name = "Оперативник (Ближний бой)"
	desc = "Оперативник синдиката с несколькими ножами."

	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet
	backpack_contents = list(/obj/item/kitchen/knife/combat/throwing = 6)
	l_hand = /obj/item/kitchen/knife/combat
	l_pocket = /obj/item/kitchen/knife/combat/throwing

/datum/outfit/deathmatch_loadout/securing_sec
	name = "Deathmatch: Security Officer"
	display_name = "Офицер СБ"
	desc = "Офицер службы безопасности НТ."

	uniform = /datum/outfit/job/officer::uniform
	suit = /datum/outfit/job/officer::suit
	suit_store = /datum/outfit/job/officer::suit_store
	belt = /datum/outfit/job/officer::belt
	gloves = /datum/outfit/job/officer::gloves
	head = /datum/outfit/job/officer::head
	shoes = /datum/outfit/job/officer::shoes
	l_pocket = /obj/item/flashlight/seclite
	r_pocket = /obj/item/kitchen/knife/combat/survival
	back = /datum/outfit/job/officer::backpack

	loadout_type = LOADOUT_NT

/datum/outfit/deathmatch_loadout/unfunny
	name = "DM: Instagib"
	display_name = "Инстагиб-пушка (!!)"
	desc = "Ассистент с инстагиб пушкой."

	loadout_type = LOADOUT_UNFUNNY

	l_hand = /obj/item/gun/energy/laser/instakill
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	belt = /obj/item/flashlight

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
	)

/datum/outfit/deathmatch_loadout/unfunny/pulse
	name = "DM: Pulse Rifle"
	display_name = "Пульс-карабин (!!)"
	desc = "Ассистент с пульсовкой отряда смерти."

	l_hand =  /obj/item/gun/energy/pulse

/datum/outfit/deathmatch_loadout/unfunny/annihilator
	name = "DM: Pulse annihilator"
	display_name = "Пульс-аннигилятор (!!)"
	desc = "Достаточно веская причина выгнать вас из лобби."

	l_hand = /obj/item/gun/energy/pulse/destroyer/annihilator

/datum/outfit/deathmatch_loadout/operative/sniper
	name = "Deathmatch: Sniper"
	display_name = "Снайпер"
	desc = "Снайперская винтовка и несколько магазинов к ней."
	backpack_contents = list(
		/obj/item/ammo_box/magazine/sniper_rounds = 3,
	)
	glasses = /obj/item/clothing/glasses/thermal
	uniform = /obj/item/clothing/under/syndicate/sniper

	l_pocket = /obj/item/kitchen/knife/combat
	l_hand = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate


/datum/outfit/deathmatch_loadout/head_of_security
	name = "Deathmatch: Head of Security"
	display_name = "ГСБ"
	desc = "Офицер с уникой. Что же может пойти не так?"

	head = /datum/outfit/job/hos::head
	uniform = /obj/item/clothing/under/rank/head_of_security/alt
	shoes = /datum/outfit/job/hos::shoes
	glasses = /datum/outfit/job/hos::glasses
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /datum/outfit/job/hos::gloves
	r_hand = /obj/item/gun/projectile/revolver/mateba
	l_hand = /obj/item/shield/riot/tele
	l_pocket = /obj/item/ammo_box/speedloader/a357
	r_pocket = /obj/item/ammo_box/speedloader/a357

	loadout_type = LOADOUT_NT

/datum/outfit/deathmatch_loadout/captain
	name = "Deathmatch: Captain"
	display_name = "Капитан"
	desc = "Обнажите вашу рапиру и покажите отродью, на что вы способны."

	head = /obj/item/clothing/head/caphat/parade
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	suit_store = /obj/item/gun/energy/laser
	shoes = /obj/item/clothing/shoes/laceup
	neck = /obj/item/bedsheet/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/captain
	belt = /obj/item/storage/belt/rapier
	l_hand = /obj/item/gun/energy/laser/captain
	l_pocket = /obj/item/melee/baton/telescopic

	loadout_type = LOADOUT_NT

/datum/outfit/deathmatch_loadout/nukie
	name = "Deathmatch: Nuclear Operative"
	display_name = "Ядерный оперативник (Бульдог)"
	desc = "Снаряжение, выдаваемое ядерному оперативнику. Ваша задача проста."

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/mod/control/pre_equipped/traitor_elite
	r_hand = /obj/item/gun/projectile/automatic/shotgun/bulldog
	belt = /obj/item/gun/projectile/automatic/pistol
	l_pocket = /obj/item/grenade/syndieminibomb

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m10mm = 2,
		/obj/item/ammo_box/magazine/m12g/slug = 5,
	)

	loadout_type = LOADOUT_SYNDICATE|LOADOUT_NUKEOPS

/datum/outfit/deathmatch_loadout/nukie/desword
	name = "Deathmatch: Nuclear Operative (desword)"
	display_name = "Ядерный оперативник (двойной энергомеч)"
	r_hand = /obj/item/twohanded/dualsaber

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m10mm = 3,
	)

/datum/outfit/deathmatch_loadout/nukie/machine_gun
	name = "Deathmatch: Nuclear Operative (l6 saw)"
	display_name = "Ядерный оперативник (пулемет)"

	r_hand = /obj/item/gun/projectile/automatic/l6_saw
	belt = null

	backpack_contents = list(
		/obj/item/ammo_box/magazine/l6saw = 2,
	)

/datum/outfit/deathmatch_loadout/nukie/sniper
	name = "Deathmatch: Nuclear Operative (sniper)"
	display_name = "Ядерный оперативник (снайпер)"

	r_hand = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m10mm = 3,
		/obj/item/ammo_box/magazine/sniper_rounds/explosive = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/penetrator = 2,
		/obj/item/ammo_box/magazine/sniper_rounds/soporific = 2,
	)

/datum/outfit/deathmatch_loadout/nukie/generic_goon
	name = "Deathmatch: Nuclear Operative (carbine)"
	display_name = "Ядерный оперативник (М-90gl)"

	r_hand = /obj/item/gun/projectile/automatic/m90
	l_hand = /obj/item/shield/energy/syndie

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m10mm = 3,
		/obj/item/ammo_box/magazine/m556 = 5,
		/obj/item/ammo_casing/a40mm = 1,
	)

/datum/outfit/deathmatch_loadout/ert
	name = "Deathmatch: ERT member (ARG)"
	display_name = "Офицер ОБР (Солдат с АРГ)"
	desc = "Бравый член отряда быстрого реагирования."

	uniform = /obj/item/clothing/under/rank/security/sensor
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	shoes = /obj/item/clothing/shoes/combat
	belt = /obj/item/storage/belt/military/assault/gammaert/full
	glasses = /obj/item/clothing/glasses/hud/health/night
	gloves = /obj/item/clothing/gloves/combat/swat
	back = /obj/item/mod/control/pre_equipped/responsory/security

	l_hand = /obj/item/gun/projectile/automatic/arg
	r_hand = /obj/item/shield/riot/tele

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m556 = 3,
		/obj/item/kitchen/knife/combat = 1,
	)

	loadout_type = LOADOUT_NT|LOADOUT_NUKEOPS

/datum/outfit/deathmatch_loadout/ert/inquisitor
	name = "Deathmatch: ERT member (Inquisitor)"
	display_name = "Офицер ОБР (Инквизитор с гироджетом)"

	uniform = /obj/item/clothing/under/rank/chaplain
	back = /obj/item/mod/control/pre_equipped/responsory/inquisitory/chaplain

	l_hand = /obj/item/gun/projectile/automatic/gyropistol
	r_hand = /obj/item/shield/riot/templar

	backpack_contents = list(
		/obj/item/ammo_box/magazine/m75 = 1,
		/obj/item/kitchen/knife/combat = 1,
		/obj/item/storage/bible = 1,
	)

/datum/outfit/deathmatch_loadout/ert/inquisitor/pre_equip(mob/living/carbon/human/our_human, visualsOnly = FALSE)
	. = ..()
	if(our_human.mind)
		our_human.mind.isholy = TRUE

/datum/outfit/deathmatch_loadout/ert/medic
	name = "Deathmatch: ERT member (Medic)"
	display_name = "Офицер ОБР (медик с боевым дефибриллятором)"

	back = /obj/item/mod/control/pre_equipped/responsory/medic
	belt = /obj/item/defibrillator/compact/combat/loaded
	l_pocket = /obj/item/reagent_containers/hypospray/combat/nanites
	r_pocket = /obj/item/reagent_containers/applicator/abductor/industrial

	l_hand = null
	r_hand = null

	backpack_contents = list(
		/obj/item/gun/projectile/automatic/pistol/sp8 = 1,
		/obj/item/ammo_box/magazine/sp8 = 2,
		/obj/item/storage/firstaid/ertm = 1,
	)

/datum/outfit/deathmatch_loadout/ert/leader
	name = "Deathmatch: ERT member (Leader)"
	display_name = "Офицер ОБР (Лидер с РШ-12 и гранатами)"

	back = /obj/item/mod/control/pre_equipped/responsory/commander

	l_hand = /obj/item/gun/projectile/revolver/rsh_12

	backpack_contents = list(
		/obj/item/clothing/accessory/holster = 1,
		/obj/item/ammo_box/c12_dot_7X55 = 4,
		/obj/item/grenade/frag = 4,
	)

/datum/outfit/deathmatch_loadout/tider
	name = "Deathmatch: Tider"
	display_name = "Грейтайд"
	desc = "Глава среди ассистентов"

	loadout_type = LOADOUT_ASSISTANT

	back = /obj/item/melee/baton/security/cattleprod
	r_hand = /obj/item/twohanded/fireaxe
	uniform = /obj/item/clothing/under/color/grey
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/color/yellow/fake
	r_pocket = /obj/item/stock_parts/cell/high
	belt = /obj/item/storage/belt/utility/full

/datum/outfit/deathmatch_loadout/chef
	name = "Deathmatch: Chef"
	display_name = "Шеф-повар"
	desc = "Любитель приготовить гречку."

	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef
	belt = /obj/item/storage/belt/chef
	head = /obj/item/clothing/head/chefhat

	l_hand = /obj/item/sleeping_carp_scroll

/datum/outfit/deathmatch_loadout/wizard
	name = "Deathmatch: Wizard"
	display_name = "Волшебник (фаерболы и стенки)"
	desc = "Ого какой необычный билд."

	uniform = /obj/item/clothing/under/color/lightpurple
	head = /obj/item/clothing/head/wizard
	shoes = /obj/item/clothing/shoes/sandal
	suit = /obj/item/clothing/suit/wizrobe
	back = /obj/item/storage/backpack/satchel

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
	)

	spells_to_add = list(
		/obj/effect/proc_holder/spell/projectile/magic_missile,
		/obj/effect/proc_holder/spell/forcewall,
		/obj/effect/proc_holder/spell/fireball,
	)

	loadout_type = LOADOUT_WIZARD

/datum/outfit/deathmatch_loadout/wizard/pyro
	name = "Deathmatch: Pyro Wizard"
	display_name = "Волшебник (школа огня)"
	desc = "Фаерболы, дым и самосожжение."

	suit = /obj/item/clothing/suit/victcoat/red/suit/fire_robe
	head = /obj/item/clothing/head/wizard/red
	spells_to_add = list(
		/obj/effect/proc_holder/spell/smoke,
		/obj/effect/proc_holder/spell/fireball,
		/obj/effect/proc_holder/spell/sacred_flame,
	)

/datum/outfit/deathmatch_loadout/wizard/electro
	name = "Deathmatch: Electro Wizard"
	display_name = "Волшебник (школа электричества)"
	desc = "Как станбатоны, только лучше."

	suit = /obj/item/clothing/suit/wizrobe/magusred
	head = /obj/item/clothing/head/wizard/magus
	spells_to_add = list(
		/obj/effect/proc_holder/spell/charge_up/bounce/lightning,
		/obj/effect/proc_holder/spell/aoe/repulse,
		/obj/effect/proc_holder/spell/forcewall/greater,
	)

/datum/outfit/deathmatch_loadout/wizard/lizard
	name = "Deathmatch: Lizard-Wizard"
	display_name = "Волшебник (школа Лаваленда)"
	desc = "Ящер, владеющий огромным количеством заклинаний. Жаль, правда, что они почти бесполезные."

	species_override = /datum/species/unathi
	uniform = /obj/item/clothing/under/ash_walker
	gloves = /obj/item/clothing/gloves/color/black/goliath
	suit = /obj/item/clothing/suit/hooded/goliath/wizard
	l_hand = /obj/item/twohanded/spear/bonespear

	spells_to_add = list(
		/obj/effect/proc_holder/spell/aoe/conjure/legion_skulls,
		/obj/effect/proc_holder/spell/goliath_tentacles,
		/obj/effect/proc_holder/spell/goliath_dash,
		/obj/effect/proc_holder/spell/watchers_look,
		/obj/effect/proc_holder/spell/touch/healtouch/advanced,
	)

/datum/outfit/deathmatch_loadout/wizard/singulo
	name = "Deathmatch: Singulo Wizard"
	display_name = "Волшебник (школа сингулярности)"
	desc = "Молот сингулярности и магия отбрасывания. Жаль, что первый же волшебник метнет в вас фаербол в упор."

	suit = /obj/item/clothing/suit/space/hardsuit/singuloth/deathmatch

	l_hand = /obj/item/twohanded/singularityhammer

	spells_to_add = list(
		/obj/effect/proc_holder/spell/summonitem,
		/obj/effect/proc_holder/spell/aoe/repulse,
		/obj/effect/proc_holder/spell/touch/healtouch/advanced,
		/obj/effect/proc_holder/spell/forcewall,
	)

/datum/outfit/deathmatch_loadout/wizard/battlemage
	name = "Deathmatch: Battlemage"
	display_name = "Волшебник (мйёльнир)"
	desc = "Мйёльнир и возможность призывать оружие к себе. Надеюсь у других магов нет фаерболов.."

	l_hand = /obj/item/twohanded/mjollnir
	suit = /obj/item/clothing/suit/wizrobe/magusdefender
	head = /obj/item/clothing/head/wizard/magusdefender

	spells_to_add = list(
		/obj/effect/proc_holder/spell/summonitem,
	)

/datum/outfit/deathmatch_loadout/wizard/gunmancer
	name = "Deathmatch: Gunmancer"
	display_name = "Волшебник (школа стрельбы)"
	desc = "Кому нужна магия, когда есть пушки?"

	belt = /obj/item/gun/projectile/automatic/pistol/m1911
	suit = /obj/item/clothing/suit/wizrobe/necromage
	head = /obj/item/clothing/head/wizard/necromage

	spells_to_add = list(
		/obj/effect/proc_holder/spell/infinite_guns,
		/obj/effect/proc_holder/spell/summonitem,
	)

/datum/outfit/deathmatch_loadout/wizard/chaos
	name = "Deathmatch: Chaos Wizard"
	display_name = "Волшебник (школа хаоса)"
	desc = "Посох хаоса и остановка времени. Да начнется веселье!"

	l_hand = /obj/item/gun/magic/staff/chaos/lesser_chaos
	suit = /obj/item/clothing/suit/wizrobe/visionmage
	head = /obj/item/clothing/head/wizard/visionmage

	spells_to_add = list(
		/obj/effect/proc_holder/spell/aoe/conjure/timestop,
		/obj/effect/proc_holder/spell/summonitem,
	)

/datum/outfit/deathmatch_loadout/wizard/spellblade
	name = "Deathmatch: Spellblade Wizard"
	display_name = "Волшебник (спеллблейд)"
	desc = "Отрубите головы вашим противникам с помощью спеллблейда!"

	suit = /obj/item/clothing/suit/space/hostile_environment
	head = /obj/item/clothing/head/helmet/space/hostile_environment

	l_hand = /obj/item/gun/magic/staff/spellblade

	spells_to_add = list(
		/obj/effect/proc_holder/spell/summonitem,
	)

// TODO:
// ALL BATTLERS
// ALL SPECIES
// ALL CULTISTS
