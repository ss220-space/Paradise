/////////////////////////////////////
////////////////////////////////////
//	FUNCTIONAL VERSION ZONES	 //
///////////////////////////////////
//////////////////////////////////
/area/ruin/space/USSP_gorky17
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE

/area/ruin/space/USSP_gorky17/solmaintnorth
	name = "Gorky17 North sol maintenance"
	icon_state = "away1"

/area/ruin/space/USSP_gorky17/solmaintsouth
	name = "Gorky17 South sol maintenance"
	icon_state = "away2"

/area/ruin/space/USSP_gorky17/medbay
	name = "Gorky17 Medbay zone"
	icon_state = "away3"

/area/ruin/space/USSP_gorky17/gate
	name = "Gorky17 Gate zone"
	icon_state = "away4"

/area/ruin/space/USSP_gorky17/angar
	name = "Gorky17 Space pods zone"
	icon_state = "away5"

/area/ruin/space/USSP_gorky17/utility
	name = "Gorky17 Utility room"
	icon_state = "away6"

/area/ruin/space/USSP_gorky17/kitchen
	name = "Gorky17 Kitchen"
	icon_state = "away7"

/area/ruin/space/USSP_gorky17/dinning
	name = "Gorky17 Dinning room"
	icon_state = "away8"

/area/ruin/space/USSP_gorky17/engineering
	name = "Gorky17 Engineering room"
	icon_state = "away9"

/area/ruin/space/USSP_gorky17/arrival
	name = "Gorky17 Arrivals zone"
	icon_state = "away10"

/area/ruin/space/USSP_gorky17/check1
	name = "Gorky17 Arrivals check point room"
	icon_state = "away11"

/area/ruin/space/USSP_gorky17/check2
	name = "Gorky17 Gate check point room"
	icon_state = "away12"

/area/ruin/space/USSP_gorky17/dorms
	name = "Gorky17 Dormitories zone"
	icon_state = "away13"

/area/ruin/space/USSP_gorky17/common
	name = "Gorky17 Common hall zone"
	icon_state = "away14"

/area/ruin/space/USSP_gorky17/bridge
	name = "Gorky17 Bridge zone"
	icon_state = "away15"

/area/ruin/space/USSP_gorky17/vault
	name = "Gorky17 vault room"
	icon_state = "away16"

/area/ruin/space/USSP_gorky17/rnd
	name = "Gorky17 Gorky17 RnD zone"
	icon_state = "away17"

/area/ruin/space/USSP_gorky17/mining
	name = "Gorky17 Ore melting zone"
	icon_state = "away18"
	has_gravity = FALSE

/area/ruin/space/USSP_gorky17/asteroids
	name = "Gorky17 Asteroids"
	icon_state = "away19"
	requires_power = FALSE
	has_gravity = FALSE
	outdoors = TRUE
	ambientsounds = list('sound/ambience/apathy.ogg')
	sound_environment = SOUND_AREA_SPACE

/area/ruin/space/USSP_gorky17/solars
	name = "Gorky17 Sol panels"
	icon_state = "away"
	requires_power = FALSE
	outdoors = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	has_gravity = FALSE

/////////////////////////////////////
////////////////////////////////////
//	  COLLAPSED VERSION ZONES	 //
///////////////////////////////////
//////////////////////////////////

/area/ruin/space/USSP_gorky17/collapsed
	poweralm = FALSE
	report_alerts = FALSE
	requires_power = TRUE
	fire = TRUE

/area/ruin/space/USSP_gorky17/collapsed/solmaintnorth
	name = "Gorky17 North sol maintenance"
	icon_state = "away1"

/area/ruin/space/USSP_gorky17/collapsed/solmaintsouth
	name = "Gorky17 South sol maintenance"
	icon_state = "away2"

/area/ruin/space/USSP_gorky17/collapsed/medbay
	name = "Gorky17 Medbay zone"
	icon_state = "away3"

/area/ruin/space/USSP_gorky17/collapsed/gate
	name = "Gorky17 Gate zone"
	icon_state = "away4"

/area/ruin/space/USSP_gorky17/collapsed/angar
	name = "Gorky17 Space pods zone"
	icon_state = "away5"

/area/ruin/space/USSP_gorky17/collapsed/utility
	name = "Gorky17 Utility room"
	icon_state = "away6"

/area/ruin/space/USSP_gorky17/collapsed/kitchen
	name = "Gorky17 Kitchen"
	icon_state = "away7"

/area/ruin/space/USSP_gorky17/collapsed/dinning
	name = "Gorky17 Dinning room"
	icon_state = "away8"

/area/ruin/space/USSP_gorky17/collapsed/engineering
	name = "Gorky17 Engineering room"
	icon_state = "away9"

/area/ruin/space/USSP_gorky17/collapsed/arrival
	name = "Gorky17 Arrivals zone"
	icon_state = "away10"

/area/ruin/space/USSP_gorky17/collapsed/check1
	name = "Gorky17 Arrivals check point room"
	icon_state = "away11"

/area/ruin/space/USSP_gorky17/collapsed/check2
	name = "Gorky17 Gate check point room"
	icon_state = "away12"

/area/ruin/space/USSP_gorky17/collapsed/dorms
	name = "Gorky17 Dormitories zone"
	icon_state = "away13"

/area/ruin/space/USSP_gorky17/collapsed/common
	name = "Gorky17 Common hall zone"
	icon_state = "away14"

/area/ruin/space/USSP_gorky17/collapsed/bridge
	name = "Gorky17 Bridge zone"
	icon_state = "away15"

/area/ruin/space/USSP_gorky17/collapsed/vault
	name = "Gorky17 vault room"
	icon_state = "away16"

/area/ruin/space/USSP_gorky17/collapsed/rnd
	name = "Gorky17 Gorky17 RnD zone"
	icon_state = "away17"

/area/ruin/space/USSP_gorky17/collapsed/mining
	name = "Gorky17 Ore melting zone"
	icon_state = "away18"
	requires_power = TRUE
	has_gravity = FALSE
	fire = FALSE

/area/ruin/space/USSP_gorky17/collapsed/asteroids
	name = "Gorky17 Asteroids"
	icon_state = "away19"
	requires_power = FALSE
	has_gravity = FALSE
	fire = FALSE
	outdoors = TRUE
	ambientsounds = list('sound/ambience/apathy.ogg')
	sound_environment = SOUND_AREA_SPACE

/area/ruin/space/USSP_gorky17/collapsed/solars
	name = "Gorky17 Sol panels"
	icon_state = "away"
	requires_power = FALSE
	fire = FALSE
	outdoors = TRUE
	dynamic_lighting = DYNAMIC_LIGHTING_IFSTARLIGHT
	ambientsounds = ENGINEERING_SOUNDS
	sound_environment = SOUND_AREA_SPACE
	has_gravity = FALSE



/////////////// Safe with secret documets

/obj/effect/spawner/lootdrop/randomsafe
	name = "Secret or data documents safe spawner"
	icon_state = "floorsafe-open"
	lootdoubles = 0
	loot = list(
				/obj/structure/safe/floor/random_documents,
				/obj/structure/safe/floor/random_researchnotes_MatBioProg
				)

/obj/item/paper/researchnotes/mat_bio_prog

/obj/item/paper/researchnotes/mat_bio_prog/Initialize()
	..()
	var/list/possible_techs = list("materials", "biotech", "programming")
	var/mytech = pick(possible_techs)
	var/mylevel = rand(6, 8)
	origin_tech = "[mytech]=[mylevel]"
	name = "research notes - [mytech] [mylevel]"

/obj/structure/safe/random_researchnotes_MatBioProg/Initialize()
	var/tech_spawn = pick(list(/obj/item/paper/researchnotes/mat_bio_prog))
	new tech_spawn(loc)
	return ..()

/obj/structure/safe/floor/random_researchnotes_MatBioProg/Initialize()
	var/tech_spawn = pick(list(/obj/item/paper/researchnotes/mat_bio_prog))
	new tech_spawn(loc)
	return ..()

/obj/structure/safe/random_documents/Initialize()
	var/doc_spawn = pick(list(/obj/item/documents, /obj/item/documents/nanotrasen, /obj/item/documents/syndicate, /obj/item/documents/syndicate/yellow/trapped))
	new doc_spawn(loc)
	return ..()

///////////////// USSP access update

/obj/machinery/computer/id_upgrader/ussp
	name = "ID Upgrade Machine"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "auth_off"
	icon_screen = null
	access_to_give = list(ACCESS_USSP_TOURIST)
	var/ranktogive = "Soviet Tourist"
	var/cardholdername
	var/cardrank
	var/possiblerank = list("Советский турист", "Товарищ") // addition before name

/obj/machinery/computer/id_upgrader/ussp/attackby(obj/item/I, mob/user, params)
	if(I.GetID())
		var/obj/item/card/id/D = I.GetID()
		if(!access_to_give.len)
			to_chat(user, "<span class='notice'>This machine appears to be configured incorrectly.</span>")
			return
		var/did_upgrade = 0
		var/list/id_access = D.GetAccess()
		for(var/this_access in access_to_give)
			if(!(this_access in id_access))
				// don't have it - add it
				D.access |= this_access
				did_upgrade = 1
		if(did_upgrade)
			giverank(D)
			to_chat(user, "<span class='notice'>New rank has been assigned to comrade.</span>")
			playsound(src, 'sound/machines/chime.ogg', 30, 0)
		else
			to_chat(user, "<span class='notice'>This ID card already has all the access this machine can give.</span>")
		return
	return ..()

/obj/machinery/computer/id_upgrader/ussp/proc/giverank(obj/item/card/id/D)
	if(D)
		D.rank = ranktogive
		D.assignment = ranktogive
		D.registered_name = "[cardrank] [cardholdername]"
		D.UpdateName()

/obj/machinery/computer/id_upgrader/ussp/verb/set_name()
	set name = "Enter name"
	set category = "Object"
	set src in oview(1)

	cardholdername = input("Enter cardholder name:")
	cardrank = input("Select cardholder rank:") in possiblerank

/obj/machinery/computer/id_upgrader/ussp/conscript
	access_to_give = list(ACCESS_USSP_CONSCRIPT)
	ranktogive = "Soviet Conscript"
	possiblerank = list("Рядовой", "Ефрейтор", "Младший сержант", "Сержант")

/obj/machinery/computer/id_upgrader/ussp/soldier
	access_to_give = list(ACCESS_USSP_SOLDIER)
	ranktogive = "Soviet Soldier"
	possiblerank = list("Сержант", "Старший сержант", "Старшина", "Прапорщик", "Старший прапорщик", "Младший лейтенант")

/obj/machinery/computer/id_upgrader/ussp/marine
	access_to_give = list(ACCESS_USSP_MARINE)
	ranktogive = "Soviet Marine"
	possiblerank = list("Старшина", "Прапорщик", "Старший прапорщик", "Младший лейтенант", "Лейтенант")

/obj/machinery/computer/id_upgrader/ussp/officer
	access_to_give = list(ACCESS_USSP_OFFICER)
	ranktogive = "Soviet Officer"
	possiblerank = list("Старший лейтенант","Капитан", "Майор", "Подполковник")

/////////////////// Paper notes

/obj/item/paper/gorky17
	language = "Neo-Russkiya"
/obj/item/paper/gorky17/talisman
	name = "Проклятый талисман"
	info = "<p><strong>НЕ ТРОГАЙ ЭТУ ХРЕНЬ ИЗ ЯЩИКА!</strong><br /> \
	\n<strong>Я СЕРЬЁЗНО! НЕ-ТРО-ГАЙ! ИЛИ СДОХНЕШЬ, КАК ТЕ ТРОЕ БЕДОЛАГ!</strong><br />\
	\nВ общем, рассказываю: была очередная вылазка в эти сраные врата (как же я заманался с ними, одного раза хватило, чтобы все любопытство отбить),\
	сержант грезил, что вот после этой вылазки к нам отправят подкрепление и провиант.\
	 Ага, хер там плавал - из команды в 10 человек вернулось трое, все перебитые и еле живые. На себе тащили по трупу.\
	 Как оклемались в сан. части - парни рассказали, что по ту сторону сраные нацисты сидят и проводят какие то ритуалы крови (либо их накрыло после стимуляторов так, \
	 либо эта нездоровая хрень реальна - надеюсь первое). \
	Покромсали наших эти культисты, будь они прокляты своими же богами, нехило, как ты понял. \
	Единственное, что они прихватили оттуда - какой то проклятый меч, да талисман. От 'талисмана', бумажки пропитанной кровью, как я понял, и померли те 3 срочника, \
	тела которых притащили с вылазки... \
	Ну да ладно, вскрытие покажет от чего те померли.<br />\
	\nЯ тебя предупредил, не лезь в этот ящик...</p>"

/obj/item/paper/gorky17/autopsy
	name = "Результаты вскрытия"
	info = "<p>Мужики, с такой дрянью я сталкивался лишь в старинных записях... \
	Простое, но действенное боевое отравляющие вещество, надеюсь вы его заперли куда подальше в герметичный контейнер. В повседневных условиях этой дряни хватило бы самую малость: \
	намазать дверную ручку или капнуть на белье - и все, цель будет устранена. А судя по тем дозам, которые я обнаружил на коже и в крови - эта бумага насквозь пропитана, не понимаю, \
	как с нее капли то не стекают. В общем, отчет и материалы я отправил куда следует - будем ждать более подробный анализ этой дряни, а пока я бы рекомендовал всем провериться и \
	пройти процедуры обеззараживания.</p>"

/obj/item/paper/gorky17/network
	name = "Название сети для камер"
	info = "<p>Ну это не серьезно, мужики. Каждая смена, как поломается камера, придумывает свое название для сетки камер наблюдения, 'Горько17, Григорий17, Горыныч, Кам17, Камеры'...\
	Мужики, вам так сложно запомнить или на листок записать? Ладно, сделаю это за вас... Надеюсь как подтирку не используете его... Название сети <strong>USSP_gorky17</strong> \
	Если запомнить не в силах - то хоть лист не про... фукайте.</p>"

/obj/item/paper/gorky17/orders
	name = "Деректива опер штаба СО"
	info = "<div style='text-align:center;'><img src='ussplogo.png'><h3>Директива №412</h3></div><hr><center><b>	Особые указания для ██████████████████, главнокомандующего объекта Gorky17</b></center> <br><br>\
	Разведка донесла штабу информацию и координаты расположении элизиумского отродья. По сообщениям группы █████████████ необходимые координаты для ваших врат ████████ - ████ - ████. \
	Ставка Главного Командования поручает Вам собрать боевую группу и уничтожить позицию врага, сохранив возможность последующего использования на благо СССП.\
	<br> Время отведенное на выполнение задачи <b>72 часа</b> с момента получения директивы. <br><br><i>	Оперативный штаб специальных операций</i>"

/obj/item/paper/gorky17/orders/Initialize()
	var/obj/item/stamp/ussp/stamp = new
	src.stamp(stamp)
	qdel(stamp)
	..()

////// CURSED TALISMAN
/obj/item/paper/poisonedtalisman
	info = "<font face=\"Verdana\" color=black>\
			<table cellspacing=0 cellpadding=3  align=\"right\">\
			<tr><td><img src= talisman.png></td></tr>\
			<br><HR></font>"
	desc = "Strange and stinky paper with blood rune."
	icon_state = "paper_talisman"
	var/poison_type = "amanitin"
	var/poison_dose = 20
	var/poison_total = 60

/obj/item/paper/poisonedtalisman/pickup(user)
	if(ishuman(user) && poison_total > 0)
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(poison_type, poison_dose)
			poison_total -= poison_dose
			add_attack_logs(src, user, "Picked up [src], the poisoned paper talisman")
	return ..()

///////////////// ID cards

/obj/item/card/id/gorky17
	name = "An old USSP indification badge"
	desc = "An excellent combination of simplicity and reliability. Old but not useless."
	icon_state = "retro_security"
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST)
	assignment = "Soviet Tourist"
	rank = "Soviet Tourist"

/obj/item/card/id/gorky17/conscript
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT)
	assignment = "Soviet Conscript"
	rank = "Soviet Conscript"

/obj/item/card/id/gorky17/soldier
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT, ACCESS_USSP_SOLDIER)
	assignment = "Soviet Soldier"
	rank = "Soviet Soldier"
/obj/item/card/id/gorky17/marine
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT, ACCESS_USSP_SOLDIER, ACCESS_USSP_MARINE)
	assignment = "Soviet Marine"
	rank = "Soviet Marine"

/obj/item/card/id/gorky17/officer
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT, ACCESS_USSP_SOLDIER, ACCESS_USSP_MARINE, ACCESS_USSP_OFFICER)
	assignment = "Soviet Officer"
	rank = "Soviet Officer"

/obj/item/card/id/gorky17/captain
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT, ACCESS_USSP_SOLDIER, ACCESS_USSP_OFFICER, ACCESS_USSP_MARINE, ACCESS_USSP_MARINE_CAPTAIN)
	assignment = "Soviet Marine Captain"
	rank = "Soviet Marine Captain"

/obj/item/card/id/gorky17/admiral
	access = list(ACCESS_MAINT_TUNNELS, ACCESS_USSP_TOURIST, ACCESS_USSP_CONSCRIPT, ACCESS_USSP_SOLDIER, ACCESS_USSP_OFFICER, ACCESS_USSP_MARINE, ACCESS_USSP_MARINE_CAPTAIN, ACCESS_USSP_MARINE_ADMIRAL)
	assignment = "Soviet Admiral"
	rank = "Soviet Admiral"

/////////////// CORPSE
/datum/outfit/usspconscript_corpse
	name = "USSP conscript conscript"

	gloves = null
	back = /obj/item/storage/backpack/explorer
	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/sovietsidecap
	id = /obj/item/card/id/gorky17/conscript
	shoes = /obj/item/clothing/shoes/combat
	l_ear = /obj/item/radio/headset/alt/soviet
	r_pocket = /obj/item/flashlight/seclite

	backpack_contents = list(
		/obj/item/storage/box/soviet = 1
	)

/obj/effect/mob_spawn/human/corpse/usspconscript
	mob_type = /mob/living/carbon/human
	name = "USSP conscript corpse"
	icon = 'icons/mob/uniform.dmi'
	icon_state = "soviet_s"
	mob_name = "Unknown"
	random = TRUE
	death = TRUE
	disable_sensors = TRUE
	outfit = /datum/outfit/usspconscript_corpse

/obj/effect/mob_spawn/human/corpse/usspconscript/Initialize()
	brute_damage = rand(0, 400)
	burn_damage = rand(0, 400)
	return ..()
