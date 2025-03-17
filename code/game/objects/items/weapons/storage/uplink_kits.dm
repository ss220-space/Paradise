/obj/item/storage/box/syndicate/Initialize(mapload, list/bundle)
	. = ..()
	if(bundle)
		for(var/index in bundle)
			switch(index)
				if("Name")
					name = bundle[index]
				if("Desc")
					desc = bundle[index]
				else
					var/number = bundle[index]
					for(var/i in 1 to number)
						new index(src)

/obj/item/storage/box/syndie_kit
	name = "Box"
	desc = "Это обычная коробка."
	ru_names = list(
		NOMINATIVE = "коробка",
		GENITIVE = "коробки",
		DATIVE = "коробке",
		ACCUSATIVE = "коробку",
		INSTRUMENTAL = "коробкой",
		PREPOSITIONAL = "коробке"
	)
	gender = MALE
	icon_state = "box_of_doom"

/obj/item/storage/box/syndie_kit/mantisblade
	name = "mantis blade kit"
	desc = "Коробка, содержащая 2 клинка богомола."
	ru_names = list(
		NOMINATIVE = "набор клинков богомола",
		GENITIVE = "набора клинков богомола",
		DATIVE = "набору клинков богомола",
		ACCUSATIVE = "набор клинков богомола",
		INSTRUMENTAL = "набором клинков богомола",
		PREPOSITIONAL = "наборе клинков богомола"
	)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/mantisblade/populate_contents()
	new /obj/item/autoimplanter/oneuse/mantisblade(src)
	new /obj/item/autoimplanter/oneuse/mantisblade/l(src)

/obj/item/storage/box/syndie_kit/space
	name = "Boxed Space Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/syndicate/black/red,
					/obj/item/clothing/head/helmet/space/syndicate/black/red,
					/obj/item/tank/internals/emergency_oxygen/engi/syndi,
					/obj/item/clothing/mask/gas/syndicate,
					/obj/item/tank/jetpack/oxygen/harness)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/space/populate_contents()
	new /obj/item/clothing/suit/space/syndicate/black/red(src)
	new /obj/item/clothing/head/helmet/space/syndicate/black/red(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)
	new /obj/item/tank/jetpack/oxygen/harness(src)

/obj/item/storage/box/syndie_kit/hardsuit
	name = "Boxed Blood Red Suit and Helmet"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/syndi, /obj/item/tank/internals/emergency_oxygen/engi/syndi, /obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/syndi(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/chameleon_hardsuit
	name = "oxygen deprivation first aid kit"
	desc = "A first aid kit that contains four pills of salbutamol, which is able to counter injuries caused by suffocation. Also contains a health analyzer to determine the health of the patient."
	description_antag = "Высокотехнологичная коробка, содержащая набор хардсьюта-хамелеона, искусно скрытая под аптечку первой оксигенной помощи. Можно разобрать на картон, на самом деле это просто качественная краска."
	icon_state = "o2"
	item_state = "firstaid-o2"
	can_hold = list(/obj/item/clothing/suit/space/hardsuit/contractor/agent,
					/obj/item/tank/internals/emergency_oxygen/engi/syndi,
					/obj/item/clothing/mask/gas/syndicate)
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/counterfeiter_bundle
	name = "Counterfeiter Bundle"
	desc = "A box containing all the neccessary equipment to forge stamps and insignias, making the user capable of faking any NanoTrasen documents."

/obj/item/storage/box/syndie_kit/counterfeiter_bundle/populate_contents()
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/chameleon_hardsuit/populate_contents()
	new /obj/item/clothing/suit/space/hardsuit/contractor/agent(src)
	new /obj/item/clothing/mask/gas/syndicate(src)
	new /obj/item/tank/internals/emergency_oxygen/engi/syndi(src)

/obj/item/storage/box/syndie_kit/conversion
	name = "box (CK)"

/obj/item/storage/box/syndie_kit/conversion/populate_contents()
	new /obj/item/conversion_kit(src)
	new /obj/item/ammo_box/speedloader/a357(src)

/obj/item/storage/box/syndie_kit/emp
	name = "boxed EMP kit"

/obj/item/storage/box/syndie_kit/emp/populate_contents()
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/grenade/empgrenade(src)
	new /obj/item/implanter/emp/(src)

/obj/item/storage/box/syndie_kit/c4
	name = "Pack of C-4 Explosives"

/obj/item/storage/box/syndie_kit/c4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/c4(src)

/obj/item/storage/box/syndie_kit/t4
	name = "Pack of T-4 Explosives"
	desc = "Contains five T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4/populate_contents()
	for(var/I in 1 to 5)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/box/syndie_kit/t4P
	name = "Small pack of T-4 Explosives"
	desc = "Contains three T4 breaching charges."

/obj/item/storage/box/syndie_kit/t4P/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/grenade/plastic/x4/thermite(src)

/obj/item/storage/box/syndie_kit/throwing_weapons
	name = "boxed throwing kit"
	can_hold = list(/obj/item/throwing_star,
					/obj/item/restraints/legcuffs/bola/tactical)
	max_combined_w_class = 16
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/throwing_weapons/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/throwing_star(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)
	new /obj/item/restraints/legcuffs/bola/tactical(src)

/obj/item/storage/box/syndie_kit/sarin
	name = "sarin gas grenades"
	desc = "Коробка, содержащая гранаты с зарином."
	ru_names = list(
		NOMINATIVE = "набор зариновых гранат",
		GENITIVE = "набора зариновых гранат",
		DATIVE = "набору зариновых гранат",
		ACCUSATIVE = "набор зариновых гранат",
		INSTRUMENTAL = "набором зариновых гранат",
		PREPOSITIONAL = "наборе зариновых гранат"
	)

/obj/item/storage/box/syndie_kit/sarin/populate_contents()
	for(var/I in 1 to 4)
		new /obj/item/grenade/chem_grenade/saringas(src)

/obj/item/storage/box/syndie_kit/bioterror
	name = "bioterror syringe kit"
	desc = "Коробка, содержащая семь шприцов \"Биотеррор\"."
	ru_names = list(
		NOMINATIVE = "набор шприцов \"Биотеррор\"",
		GENITIVE = "набора шприцов \"Биотеррор\"",
		DATIVE = "набору шприцов \"Биотеррор\"",
		ACCUSATIVE = "набор шприцов \"Биотеррор\"",
		INSTRUMENTAL = "набором шприцов \"Биотеррор\"",
		PREPOSITIONAL = "наборе шприцов \"Биотеррор\""
	)

/obj/item/storage/box/syndie_kit/bioterror/populate_contents()
	for(var/I in 1 to 7)
		new /obj/item/reagent_containers/syringe/bioterror(src)

/obj/item/storage/box/syndie_kit/caneshotgun
	name = "cane gun kit"
	desc = "Коробка, содержащая дробовик-трость и патроны к нему."
	ru_names = list(
		NOMINATIVE = "набор дробовика-трости",
		GENITIVE = "набора дробовика-трости",
		DATIVE = "набору дробовика-трости",
		ACCUSATIVE = "набор дробовика-трости",
		INSTRUMENTAL = "набором дробовика-трости",
		PREPOSITIONAL = "наборе дробовика-трости"
	)

/obj/item/storage/box/syndie_kit/caneshotgun/populate_contents()
	for(var/I in 1 to 6)
		new /obj/item/ammo_casing/shotgun/assassination(src)
	new /obj/item/gun/projectile/revolver/doublebarrel/improvised/cane(src)

/obj/item/storage/box/syndie_kit/fake_revolver
	name = "trick revolver kit"
	desc = "Коробка с револьвером для розыгрышей."
	ru_names = list(
		NOMINATIVE = "набор револьвера для розыгрышей",
		GENITIVE = "набора револьвера для розыгрышей",
		DATIVE = "набору револьвера для розыгрышей",
		ACCUSATIVE = "набор револьвера для розыгрышей",
		INSTRUMENTAL = "набором револьвера для розыгрышей",
		PREPOSITIONAL = "наборе револьвера для розыгрышей"
	)

/obj/item/storage/box/syndie_kit/fake_revolver/populate_contents()
	new /obj/item/toy/russian_revolver/trick_revolver(src)

/obj/item/storage/box/syndie_kit/mimery
	name = "advanced mimery kit"
	desc = "Коробка, содержащая 2 книги по продвинутыми пантомимами."
	ru_names = list(
		NOMINATIVE = "набор продвинутых пантомим",
		GENITIVE = "набора продвинутых пантомим",
		DATIVE = "набору продвинутых пантомим",
		ACCUSATIVE = "набор продвинутых пантомим",
		INSTRUMENTAL = "набором продвинутых пантомим",
		PREPOSITIONAL = "наборе продвинутых пантомим"
	)

/obj/item/storage/box/syndie_kit/mimery/populate_contents()
	new /obj/item/spellbook/oneuse/mime/greaterwall(src)
	new	/obj/item/spellbook/oneuse/mime/fingergun(src)

/obj/item/storage/box/syndie_kit/atmosn2ogrenades
	name = "atmos N2O grenades kit"
	desc = "Коробка, содержащая 2 кластерные гранаты наполненные газом N2O."
	ru_names = list(
		NOMINATIVE = "набор усыпляющих газовых кластерных гранат",
		GENITIVE = "набора усыпляющих газовых кластерных гранат",
		DATIVE = "набору усыпляющих газовых кластерных гранат",
		ACCUSATIVE = "набор усыпляющих газовых кластерных гранат",
		INSTRUMENTAL = "набором усыпляющих газовых кластерных гранат",
		PREPOSITIONAL = "наборе усыпляющих газовых кластерных гранат"
	)

/obj/item/storage/box/syndie_kit/atmosn2ogrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/n2o(src)
	new /obj/item/grenade/clusterbuster/n2o(src)


/obj/item/storage/box/syndie_kit/atmosfiregrenades
	name = "plasma fire grenades kit"
	desc = "Коробка, содержащая 2 кластерные гранаты наполненные газообразной плазмой."
	ru_names = list(
		NOMINATIVE = "набор плазменных газовых кластерных гранат",
		GENITIVE = "набора плазменных газовых кластерных гранат",
		DATIVE = "набору плазменных газовых кластерных гранат",
		ACCUSATIVE = "набор плазменных газовых кластерных гранат",
		INSTRUMENTAL = "набором плазменных газовых кластерных гранат",
		PREPOSITIONAL = "наборе плазменных газовых кластерных гранат"
	)

/obj/item/storage/box/syndie_kit/atmosfiregrenades/populate_contents()
	new /obj/item/grenade/clusterbuster/plasma(src)
	new /obj/item/grenade/clusterbuster/plasma(src)

/obj/item/storage/box/syndie_kit/missionary_set
	name = "missionary starter kit"
	desc = "Коробка, содержащая Библию, комплект одежды и посох."
	ru_names = list(
		NOMINATIVE = "стартовый набор миссионера",
		GENITIVE = "стартового набора миссионера",
		DATIVE = "стартовому набору миссионера",
		ACCUSATIVE = "стартовый набор миссионера",
		INSTRUMENTAL = "стартовым набором миссионера",
		PREPOSITIONAL = "стартовом наборе миссионера"
	)

/obj/item/storage/box/syndie_kit/missionary_set/populate_contents()
	new /obj/item/nullrod/missionary_staff(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/missionary_robe(src)
	var/obj/item/storage/bible/B = new /obj/item/storage/bible(src)
	if(prob(25))	//an omen of success to come?
		B.deity_name = "Success"
		B.icon_state = "greentext"
		B.item_state = "greentext"


/obj/item/storage/box/syndie_kit/cutouts
	name = "adaptive cardboard figure kit"
	desc = "Коробка, содерржащая адаптивные картонные фигуры и баллончик с краской."
	ru_names = list(
		NOMINATIVE = "набор адаптивных картонных фигур",
		GENITIVE = "набора адаптивных картонных фигур",
		DATIVE = "набору адаптивных картонных фигур",
		ACCUSATIVE = "набор адаптивных картонных фигур",
		INSTRUMENTAL = "набором адаптивных картонных фигур",
		PREPOSITIONAL = "наборе адаптивных картонных фигур"
	)

/obj/item/storage/box/syndie_kit/cutouts/populate_contents()
	for(var/i in 1 to 3)
		new/obj/item/twohanded/cardboard_cutout/adaptive(src)
	new/obj/item/toy/crayon/spraycan(src)

/obj/item/storage/box/syndie_kit/bonerepair
	name = "emergency nanite kit"
	desc = "Коробка, содержащая инъектор с нанокальцием и руководство по применению."
	ru_names = list(
		NOMINATIVE = "набор инъектора с нанокальцием",
		GENITIVE = "набора инъектора с нанокальцием",
		DATIVE = "набору инъектора с нанокальцием",
		ACCUSATIVE = "набор инъектора с нанокальцием",
		INSTRUMENTAL = "набором инъектора с нанокальцием",
		PREPOSITIONAL = "наборе инъектора с нанокальцием"
	)

/obj/item/storage/box/syndie_kit/bonerepair/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/nanocalcium(src)
	var/obj/item/paper/P = new /obj/item/paper(src)
	P.name = "Prototype nanite repair guide" // The instructions need to be revised.
	P.desc = "For when you want to safely get off Mr Bones' Wild Ride."
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><B>Prototype Emergency Repair Nanites</B><HR></center><BR><BR>

<B>Usage:</B> <BR><BR><BR>

<font size = "1">This is a highly experimental prototype chemical designed to repair damaged bones, organs, and treat interenal bleeding of soldiers in the field, use only as a last resort. The autoinjector contains prototype nanites bearing a classifed payload. The nanites will simultaneously shut down body systems whilst aiding in repair.<BR><BR><BR>Warning: Side effects can cause temporary paralysis, loss of co-ordination and sickness. <B>Do not use with any kind of stimulant or drugs. Serious damage can occur!</B><BR><BR><BR>

To apply, hold the injector a short distance away from the outer thigh before applying firmly to the skin surface. The process of repairing should begin repair after a short time, during which you are advised to remain still. <BR><BR><BR><BR>After use you are advised to see a doctor at the next available opportunity. Mild scarring and tissue damage may occur after use. This is a prototype. We are not liable for any bone spurs, cancers, extra limbs, or creation of new viruses from use of the product.</font><BR><HR></font>
	"}

/obj/item/storage/box/syndie_kit/chameleon
	name = "chameleon kit"
	desc = "Коробка, содержащая комплект одежды, оснащённый технологией \"Хамелеон\"."
	ru_names = list(
		NOMINATIVE = "набор одежды \"Хамелеон\"",
		GENITIVE = "набора одежды \"Хамелеон\"",
		DATIVE = "набору одежды \"Хамелеон\"",
		ACCUSATIVE = "набор одежды \"Хамелеон\"",
		INSTRUMENTAL = "набором одежды \"Хамелеон\"",
		PREPOSITIONAL = "наборе одежды \"Хамелеон\""
	)

/obj/item/storage/box/syndie_kit/chameleon/populate_contents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/plasma_chameleon
	name = "plasmaman chameleon kit"
	desc = "Коробка, содержащая комплект одежды для плазмолюдов, оснащённый технологией \"Хамелеон\"."
	ru_names = list(
		NOMINATIVE = "набор одежды \"Хамелеон\" для плазмолюдов",
		GENITIVE = "набора одежды \"Хамелеон\" для плазмолюдов",
		DATIVE = "набору одежды \"Хамелеон\" для плазмолюдов",
		ACCUSATIVE = "набор одежды \"Хамелеон\" для плазмолюдов",
		INSTRUMENTAL = "набором одежды \"Хамелеон\" для плазмолюдов",
		PREPOSITIONAL = "наборе одежды \"Хамелеон\" для плазмолюдов"
	)

/obj/item/storage/box/syndie_kit/plasma_chameleon/populate_contents()
	new /obj/item/clothing/under/plasmaman/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/helmet/space/plasmaman/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/stamp/chameleon(src)
	new /obj/item/pda/chameleon(src)
	new /obj/item/pen/fakesign(src)

/obj/item/storage/box/syndie_kit/dart_gun
	name = "dart gun kit"
	desc = "Коробка, содержащая миниатюрную версию обычного шприцемёта."
	ru_names = list(
		NOMINATIVE = "набор дротикового пистолета",
		GENITIVE = "набора дротикового пистолета",
		DATIVE = "набору дротикового пистолета",
		ACCUSATIVE = "набор дротикового пистолета",
		INSTRUMENTAL = "набором дротикового пистолета",
		PREPOSITIONAL = "наборе дротикового пистолета"
	)

/obj/item/storage/box/syndie_kit/dart_gun/populate_contents()
	new /obj/item/gun/syringe/syndicate(src)
	new /obj/item/reagent_containers/syringe/capulettium_plus(src)
	new /obj/item/reagent_containers/syringe/sarin(src)
	new /obj/item/reagent_containers/syringe/pancuronium(src)

/obj/item/storage/box/syndie_kit/nuke
	name = "box"  // Stealth, because you will spawn with a box.
	desc = "Это обычная коробка."
	ru_names = list(
		NOMINATIVE = "коробка",
		GENITIVE = "коробки",
		DATIVE = "коробке",
		ACCUSATIVE = "коробку",
		INSTRUMENTAL = "коробкой",
		PREPOSITIONAL = "коробке"
	)
	icon_state = "box"

/obj/item/storage/box/syndie_kit/nuke/populate_contents()
	new /obj/item/screwdriver/nuke(src)
	new /obj/item/nuke_core_container(src)
	new /obj/item/paper/guides/antag/nuke_instructions(src)

/obj/item/storage/box/syndie_kit/supermatter
	name = "box"  // Stealth, because you will spawn with a box.
	desc = "Это обычная коробка."
	ru_names = list(
		NOMINATIVE = "коробка",
		GENITIVE = "коробки",
		DATIVE = "коробке",
		ACCUSATIVE = "коробку",
		INSTRUMENTAL = "коробкой",
		PREPOSITIONAL = "коробке"
	)
	icon_state = "box"

/obj/item/storage/box/syndie_kit/supermatter/populate_contents()
	new /obj/item/scalpel/supermatter(src)
	new /obj/item/retractor/supermatter(src)
	new /obj/item/nuke_core_container/supermatter(src)
	new /obj/item/paper/guides/antag/supermatter_sliver(src)

/obj/item/storage/box/syndie_kit/genes
	name = "genetic superiority bundle"
	desc = "Коробка, содержащая шприцы с сильными генетическими модификациями."
	ru_names = list(
		NOMINATIVE = "набор генетического превосходства",
		GENITIVE = "набора генетического превосходства",
		DATIVE = "набору генетического превосходства",
		ACCUSATIVE = "набор генетического превосходства",
		INSTRUMENTAL = "набором генетического превосходства",
		PREPOSITIONAL = "наборе генетического превосходства"
	)

/obj/item/storage/box/syndie_kit/genes/populate_contents()
	new /obj/item/dnainjector/hulkmut(src)
	new /obj/item/dnainjector/xraymut(src)
	new /obj/item/dnainjector/telemut(src)
	new /obj/item/dnainjector/runfast(src)
	new /obj/item/dnainjector/insulation(src)

/obj/item/storage/box/syndie_kit/stungloves
	name = "stungloves kit"
	desc = "Коробка, содержащая оглушающие перчатки и аккумулятор."
	ru_names = list(
		NOMINATIVE = "набор оглушающих перчаток",
		GENITIVE = "набора оглушающих перчаток",
		DATIVE = "набору оглушающих перчаток",
		ACCUSATIVE = "набор оглушающих перчаток",
		INSTRUMENTAL = "набором оглушающих перчаток",
		PREPOSITIONAL = "наборе оглушающих перчаток"
	)

/obj/item/storage/box/syndie_kit/stungloves/populate_contents()
	new /obj/item/clothing/gloves/color/yellow/stun(src)
	new /obj/item/stock_parts/cell/high/plus(src)
	new /obj/item/toy/crayon/white(src)
	new /obj/item/toy/crayon/yellow(src)
	new /obj/item/toy/crayon/rainbow(src)

/obj/item/storage/box/syndie_kit/cyborg_maint
	name = "cyborg repair kit"
	desc = "Коробка, содержащая всё необходимое для ремонта робота, а также подробную инструкцию по эксплуатации."
	ru_names = list(
		NOMINATIVE = "набор для починки роботов",
		GENITIVE = "набора для починки роботов",
		DATIVE = "набору для починки роботов",
		ACCUSATIVE = "набор для починки роботов",
		INSTRUMENTAL = "набором для починки роботов",
		PREPOSITIONAL = "наборе для починки роботов"
	)

/obj/item/storage/box/syndie_kit/cyborg_maint/populate_contents()
	new /obj/item/robot_parts/robot_component/armour(src)
	new /obj/item/robot_parts/robot_component/actuator(src)
	new /obj/item/robot_parts/robot_component/radio(src)
	new /obj/item/robot_parts/robot_component/binary_communication_device(src)
	new /obj/item/robot_parts/robot_component/camera(src)
	new /obj/item/robot_parts/robot_component/diagnosis_unit(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/stack/nanopaste(src)
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/robotanalyzer(src)
	var/obj/item/paper/P = new (src)
	P.name = "Cyborg Repair Instruction" // The instructions need to be revised.
	P.info = {"
<font face="Verdana" color=black></font><font face="Verdana" color=black><center><B>Краткая инструкция по пончинке роботов</B><HR></center><BR><BR>

<font size = "4">1. Возьмите Cyborg Analyzer, проведите им по роботу.<BR>
2. Запомните сломанные компоненты, которые вывел Cyborg Analyzer.<BR>
3. Если робот закрыт (будет визуально заметно), то попросите его открыться. Если он уничтожен - проведите ЕМАГом для открытия.<BR>
4. Монтировкой откройте крышку робота.<BR>
5. Руками вытащите батарейку у робота.<BR>
6. Монтировкой снимите сломанные компоненты из пункта 2.<BR>
7. Вставьте новые компоненты в робота.<BR>
8. Вставьте батарейку в робота.<BR>
9. Закройте крышку робота монтировкой.<BR>
10. Залейте нанопастой поврежденные части робота.<BR>
11. Готово. робот снова функционирует.<BR>
<BR><BR><BR>
	"}

/obj/item/storage/box/syndie_kit/chameleon_counter
	name = "chameleon counterfeiter kit"
	desc = "Коробка, содержащая 3 фальсификатора \"Хамелеон\"."
	ru_names = list(
		NOMINATIVE = "набор фальсификаторов \"Хамелеон\"",
		GENITIVE = "набора фальсификаторов \"Хамелеон\"",
		DATIVE = "набору фальсификаторов \"Хамелеон\"",
		ACCUSATIVE = "набор фальсификаторов \"Хамелеон\"",
		INSTRUMENTAL = "набором фальсификаторов \"Хамелеон\"",
		PREPOSITIONAL = "наборе фальсификаторов \"Хамелеон\""
	)

/obj/item/storage/box/syndie_kit/chameleon_counter/populate_contents()
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)
	new /obj/item/chameleon_counterfeiter(src)

/obj/item/storage/box/syndie_kit/pistol_ammo
	name = "10mm ammunition kit"
	desc = "Коробка, содержащая 2 магазина патронов калибра 10 мм."
	ru_names = list(
		NOMINATIVE = "набор патронов калибра 10 мм",
		GENITIVE = "набора патронов калибра 10 мм",
		DATIVE = "набору патронов калибра 10 мм",
		ACCUSATIVE = "набор патронов калибра 10 мм",
		INSTRUMENTAL = "набором патронов калибра 10 мм",
		PREPOSITIONAL = "наборе патронов калибра 10 мм"
	)

/obj/item/storage/box/syndie_kit/pistol_ammo/populate_contents()
	new /obj/item/ammo_box/magazine/m10mm(src)
	new /obj/item/ammo_box/magazine/m10mm(src)

/obj/item/storage/box/syndie_kit/revolver_ammo
	name = ".357 ammunition kit"
	desc = "Коробка, содержащая 2 сменных барабана патронов .357 калибра."
	ru_names = list(
		NOMINATIVE = "набор патронов .357 калибра",
		GENITIVE = "набора патронов .357 калибра",
		DATIVE = "набору патронов .357 калибра",
		ACCUSATIVE = "набор патронов .357 калибра",
		INSTRUMENTAL = "набором патронов .357 калибра",
		PREPOSITIONAL = "наборе патронов .357 калибра"
	)

/obj/item/storage/box/syndie_kit/revolver_ammo/populate_contents()
	new /obj/item/ammo_box/speedloader/a357(src)
	new /obj/item/ammo_box/speedloader/a357(src)

/obj/item/storage/box/syndie_kit/dangertray
	name = "danger tray pack"
	desc = "Коробка, содержащая 3 острых металлических подноса."
	ru_names = list(
		NOMINATIVE = "набор особо острых подносов",
		GENITIVE = "набора особо острых подносов",
		DATIVE = "набору особо острых подносов",
		ACCUSATIVE = "набор особо острых подносов",
		INSTRUMENTAL = "набором особо острых подносов",
		PREPOSITIONAL = "наборе особо острых подносов"
	)
	can_hold = list(/obj/item/storage/bag/dangertray)
	max_combined_w_class = 3
	max_w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/box/syndie_kit/dangertray/populate_contents()
	for(var/I in 1 to 3)
		new /obj/item/storage/bag/dangertray(src)

/obj/item/storage/box/syndie_kit/mr_chang_technique
	name = "Mr. Chang's aggressive marketing technique"
	desc = "Коробка с товарами, предназначенными для увеличения прибыли через агрессивный маркетинг. Предоставлена корпорацией Мистера Чанга."
	ru_names = list(
		NOMINATIVE = "набор агрессивной маркетинговой техники Мистера Чанга",
		GENITIVE = "набора агрессивной маркетинговой техники Мистера Чанга",
		DATIVE = "набору агрессивной маркетинговой техники Мистера Чанга",
		ACCUSATIVE = "набор агрессивной маркетинговой техники Мистера Чанга",
		INSTRUMENTAL = "набором агрессивной маркетинговой техники Мистера Чанга",
		PREPOSITIONAL = "наборе агрессивной маркетинговой техники Мистера Чанга"
	)
	icon_state = "box_mr_chang"

/obj/item/storage/box/syndie_kit/mr_chang_technique/populate_contents()
	new /obj/item/mr_chang_technique(src)
	new /obj/item/clothing/suit/mr_chang_coat(src)
	new /obj/item/clothing/shoes/mr_chang_sandals(src)
	new /obj/item/clothing/head/mr_chang_band(src)

/obj/item/storage/box/syndie_kit/bowman_conversion_kit
	name = "bowman headset conversion kit"
	desc = "В комплект входят гарнитура, которая обеспечивает защиту от громких звуков, а также ключ-шифратор Синдиката."
	ru_names = list(
		NOMINATIVE = "набор гарнитуры с ключом-шифратором Синдиката",
		GENITIVE = "набора гарнитуры с ключом-шифратором Синдиката",
		DATIVE = "набору гарнитуры с ключом-шифратором Синдиката",
		ACCUSATIVE = "набор гарнитуры с ключом-шифратором Синдиката",
		INSTRUMENTAL = "набором гарнитуры с ключом-шифратором Синдиката",
		PREPOSITIONAL = "наборе гарнитуры с ключом-шифратором Синдиката"
	)

/obj/item/storage/box/syndie_kit/bowman_conversion_kit/populate_contents()
	new /obj/item/encryptionkey/syndicate(src)
	new /obj/item/bowman_conversion_tool(src)

/obj/item/storage/box/syndie_kit/commando_kit
	name = "knife fight kit"
	desc = "Коробка, наполненная ароматами пороха, напалма и дешёвого виски, хранит в себе всё необходимое для выживания в суровых условиях."
	ru_names = list(
		NOMINATIVE = "набор для ножевого боя",
		GENITIVE = "набора для ножевого боя",
		DATIVE = "набору для ножевого боя",
		ACCUSATIVE = "набор для ножевого боя",
		INSTRUMENTAL = "набором для ножевого боя",
		PREPOSITIONAL = "наборе для ножевого боя"
	)
	icon_state = "commandos_kit"

/obj/item/storage/box/syndie_kit/commando_kit/populate_contents()
	new /obj/item/throwing_manual(src)
	new /obj/item/clothing/under/pants/camo/commando(src)
	new /obj/item/clothing/shoes/combat/commando(src)
	new /obj/item/clothing/head/commando(src)
	new /obj/item/poster/commando(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/kitchen/knife/combat(src)
	new /obj/item/clothing/accessory/holster/knives(src)
	new /obj/item/storage/box/syndie_kit/knives_kit(src)

/obj/item/storage/box/syndie_kit/knives_kit
	name = "throwing knives kit"
	desc = "Коробка, содержащая 7 метательных ножей."
	ru_names = list(
		NOMINATIVE = "набор метательных ножей",
		GENITIVE = "набора метательных ножей",
		DATIVE = "набору метательных ножей",
		ACCUSATIVE = "набор метательных ножей",
		INSTRUMENTAL = "набором метательных ножей",
		PREPOSITIONAL = "наборе метательных ножей"
	)

/obj/item/storage/box/syndie_kit/knives_kit/populate_contents()
	for(var/i in 1 to 7)
		new /obj/item/kitchen/knife/combat/throwing(src)

/obj/item/storage/box/syndie_kit/blackops_kit
	name = "black ops kit"
	desc = "Коробка, содержащая одежду, предназначенную для проведения опасных секретных операций."
	ru_names = list(
		NOMINATIVE = "набор для секретных операций",
		GENITIVE = "набора для секретных операций",
		DATIVE = "набору для секретных операций",
		ACCUSATIVE = "набор для секретных операций",
		INSTRUMENTAL = "набором для секретных операций",
		PREPOSITIONAL = "наборе для секретных операций"
	)

/obj/item/storage/box/syndie_kit/blackops_kit/populate_contents()
	new /obj/item/clothing/under/syndicate/blackops(src)
	new /obj/item/clothing/gloves/combat(src)
	new /obj/item/clothing/shoes/combat(src)
	new /obj/item/clothing/suit/armor/vest(src)
	new /obj/item/clothing/glasses/night(src)
	new /obj/item/clothing/accessory/storage/webbing(src)
	new /obj/item/storage/belt/military/assault(src)
	new /obj/item/clothing/mask/balaclava(src)

/obj/item/storage/box/syndie_kit/combat_baking
	name = "combat bakery kit"
	desc = "Коробка, содержащая оружие, изготовленное из выпечки!"
	ru_names = list(
		NOMINATIVE = "набор боевого пекаря",
		GENITIVE = "набора боевого пекаря",
		DATIVE = "набору боевого пекаря",
		ACCUSATIVE = "набор боевого пекаря",
		INSTRUMENTAL = "набором боевого пекаря",
		PREPOSITIONAL = "наборе боевого пекаря"
	)

/obj/item/storage/box/syndie_kit/combat_baking/populate_contents()
	new /obj/item/reagent_containers/food/snacks/baguette/combat(src)
	new /obj/item/reagent_containers/food/snacks/croissant/throwing(src)
	new /obj/item/reagent_containers/food/snacks/croissant/throwing(src)
	new /obj/item/book/granter/crafting_recipe/combat_baking(src)

/obj/item/storage/box/syndie_kit/ghostface_kit
	name = "Ghostface kit"
	desc = "Коробка, содержащая костюм и маску \"Гоустфейс\"."
	ru_names = list(
		NOMINATIVE = "набор \"Гоустфейс\"",
		GENITIVE = "набора \"Гоустфейс\"",
		DATIVE = "набору \"Гоустфейс\"",
		ACCUSATIVE = "набор \"Гоустфейс\"",
		INSTRUMENTAL = "набором \"Гоустфейс\"",
		PREPOSITIONAL = "наборе \"Гоустфейс\""
	)

/obj/item/storage/box/syndie_kit/ghostface_kit/populate_contents()
	new /obj/item/clothing/suit/hooded/ghostfacesuit/true(src)
	new /obj/item/clothing/mask/gas/ghostface/true(src)
	new /obj/item/melee/ghostface_knife(src)

/obj/item/storage/box/syndie_kit/devil_ghostface_kit
	name = "Devil Ghostface kit"
	desc = "Коробка, содержащая костюм и маску \"Гоустфейс\"."
	ru_names = list(
		NOMINATIVE = "набор \"Дьявольский Гоустфейс\"",
		GENITIVE = "набора \"Дьявольский Гоустфейс\"",
		DATIVE = "набору \"Дьявольский Гоустфейс\"",
		ACCUSATIVE = "набор \"Дьявольский Гоустфейс\"",
		INSTRUMENTAL = "набором \"Дьявольский Гоустфейс\"",
		PREPOSITIONAL = "наборе \"Дьявольский Гоустфейс\""
	)

/obj/item/storage/box/syndie_kit/devil_ghostface_kit/populate_contents()
	new /obj/item/clothing/suit/hooded/ghostfacesuit/devil/true(src)
	new /obj/item/clothing/mask/gas/ghostface/true/devil(src)
	new /obj/item/melee/ghostface_knife/devil(src)
