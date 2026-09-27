
/datum/heretic_knowledge_tree_column/main/rhytm

	route = PATH_RHYTM
	ui_bgr = "node_rhytm"
	path_description = list(
		"Путь Ритма держится на одном ресурсе: чем дольше вы в движении и в драке, тем быстрее вы \
		двигаетесь, бьёте и затягиваете раны.",
		"Берите этот путь, если готовы не выходить из боя — стоит остановиться, и такт рассыпается.",
	)
	path_pros = list(
		"Ритм растёт от любого урона: и полученного, и нанесённого.",
		"Постоянное исцеление, которое чинит переломы и кровотечения.",
		"Скорость движения, ударов и действий растёт вместе с ритмом.",
		"На высоком ритме вы уходите и от ударов, и с линии выстрела.",
	)
	path_cons = list(
		"Без драки ритм спадает, а вместе с ним и все ваши преимущества.",
		"На высоком ритме собственное сердце начинает бить по вам.",
		"Пока вы не изучите Ритуал Оружейника, любой стан работает как обычно.",
		"Пульсирующий клинок бьёт слабее любого другого — всю разницу вы добираете тактом.",
	)
	path_tips = list(
		"Ритм спадает по одной единице каждые три секунды без нового прироста. \
		Считайте не удары, а паузы между ними.",
		"\"Хватка Обители\" ставит метку, а удар клинком по помеченному отдаёт вам пять ритма \
		и забирает у жертвы столько выносливости, сколько ритма вы держите.",
		"\"Неусыпный тимпан\" бьётся из кармана и подсвечивает всё живое вокруг сквозь стены — \
		это ваш способ поднять такт до драки, а не во время неё.",
		"На десяти ритма каждый обычный удар клинка идёт по дуге, на пятнадцати — бьёт сильнее, \
		но каждый полученный удар тогда стоит вам ещё и выносливости.",
		"В танцевальном костюме урон уходит в выносливость, поэтому следите за ней, а не за здоровьем: \
		на нуле выносливости сердце останавливается.",
		"\"Резонанс Сердец\" превращает исцеление в удар по всему живому вокруг. Чем выше ритм, \
		тем шире расходится волна.",
	)
	passive_name = "Неостановимое Сердце"
	passive_descriptions = list(
		"Кровотечения вам не страшны, а ритм постоянно залечивает раны. В бою исцеление слабеет.",
		"Иммунитет ко сну и сбиванию с ног, предел ритма поднят до 50, исцеление приходит чаще.",
		"Предел ритма поднят до 100, высокий ритм больше не бьёт по вам, а бой не мешает исцелению.",
	)
	start = /datum/heretic_knowledge/limited_amount/starting/base_rhytm
	knowledge_tier1 = /datum/heretic_knowledge/spell/accelerated_dance
	knowledge_tier2 = /datum/heretic_knowledge/limited_amount/unwaking_timpan
	robes = /datum/heretic_knowledge/armor/rhytm
	knowledge_tier3 = /datum/heretic_knowledge/spell/relentless_festival
	blade = /datum/heretic_knowledge/blade_upgrade/rhytm
	knowledge_tier4 = /datum/heretic_knowledge/spell/heart_resonance
	ascension = /datum/heretic_knowledge/ultimate/rhytm_final
	guaranteed_side_tier1 = /datum/heretic_knowledge/eldritch_coin
	guaranteed_side_tier2 = /datum/heretic_knowledge/spell/opening_blast
	guaranteed_side_tier3 = /datum/heretic_knowledge/essence


/datum/heretic_knowledge/limited_amount/starting/base_rhytm
	name = "Секрет Ритма"
	desc = "Открывает вам Путь Ритма. \
			Позволяет преобразовать нож и сердце в пульсирующий клинок. \
			Вы можете создать только два клинка одновременно. \
			Ваше собственное сердце начинает вести счёт, а \"Хватка Обители\" помечает жертв."
	gain_text = "Обитель не говорила со мной словами. Она отбивала такт, и мое сердце подхватило его \
				раньше, чем я успел испугаться."
	required_atoms = list(
		/obj/item/kitchen/knife = 1,
		/obj/item/organ/internal/heart = 1,
	)
	result_atoms = list(/obj/item/melee/sickly_blade/rhytm)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "rhytm_blade"
	mark_type = /datum/status_effect/eldritch/rhytm
	passive_type = /datum/status_effect/heretic_passive/rhytm


/datum/heretic_knowledge/limited_amount/starting/base_rhytm/create_mark(mob/living/source, mob/living/target)
	if(target.stat == DEAD)
		return
	return target.apply_status_effect(mark_type, source)


/datum/heretic_knowledge/spell/accelerated_dance
	name = "Ускоренный Танец"
	desc = "Даёт вам \"Ускоренный Танец\": ритм подскакивает на десять, вы десять секунд двигаетесь \
			заметно быстрее, вдвое хуже чувствуете усталость и вас нельзя сбить с ног. \
			Когда танец кончится, тело разом вспомнит про усталость."
	gain_text = "Я не выбирал этот шаг. Такт выбрал его за меня, и ноги пошли сами."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "accelerated_dance"
	spell_to_add = /datum/action/cooldown/spell/accelerated_dance
	cost = 2


/datum/heretic_knowledge/limited_amount/unwaking_timpan
	name = "Неусыпный Тимпан"
	desc = "Позволяет преобразовать сердце и кожу в неусыпный тимпан. \
			Каждый удар по нему поднимает ваш ритм, ненадолго разгоняет вас, \
			высвечивает всё живое вокруг сквозь стены и вытягивает силы из тех, кто рядом. \
			Если сил у вас в достатке, удар вместо этого бьёт по головам. \
			Бить в него можно прямо из кармана."
	gain_text = "Кожа помнит удары лучше, чем плоть. Натяни её — и она будет отбивать такт \
				даже тогда, когда ты спишь."
	required_atoms = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/stack/sheet/animalhide = 1,
	)
	result_atoms = list(/obj/item/unwaking_timpan)
	research_tree_icon_path = 'icons/obj/eldritch.dmi'
	research_tree_icon_state = "timpan"
	limit = 2
	cost = 2


/datum/heretic_knowledge/armor/rhytm
	desc = "Позволяет преобразовать сердце, маску и верхнюю одежду (или стол) \
			в танцевальный костюм. Пока он надет и вы держите ритм, \
			весь урон уходит в выносливость, слабые удары только подхлёстывают такт, \
			а сбить или замедлить вас нельзя. На нуле выносливости сердце остановится."
	gain_text = "Костюм сшит не для защиты. Он сшит для того, чтобы движение не прерывалось \
				ни на один такт."
	required_atoms = list(
		/obj/item/organ/internal/heart = 1,
		/obj/item/clothing/mask = 1,
		list(/obj/structure/table, /obj/item/clothing/suit) = 1,
	)
	result_atoms = list(/obj/item/clothing/suit/hooded/cultrobes/eldritch/rhytm)
	research_tree_icon_state = "rhytm_armor"
	research_tree_icon_frame = 1


/datum/heretic_knowledge/spell/relentless_festival
	name = "Безустанный Фестиваль"
	desc = "Даёт вам \"Безустанный Фестиваль\": все живые вокруг теряют власть над собственными ногами \
			и повторяют каждый ваш шаг, теряя силы с каждым движением."
	gain_text = "Я сделал шаг — и весь коридор шагнул со мной. Никто из них не хотел танцевать."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "relentless_festival"
	spell_to_add = /datum/action/cooldown/spell/aoe/relentless_festival
	cost = 2


/datum/heretic_knowledge/blade_upgrade/rhytm
	name = "Сердцебиение Клинка"
	desc = "Ваш клинок начинает бить в такт с вами. Каждый удар по живой цели выбивает столько \
			выносливости, сколько ритма вы держите, а каждый третий удар по одной и той же жертве \
			оставляет на ней метку Обители."
	gain_text = "Лезвие перестало быть железом. Оно стало ещё одним ударом сердца, только снаружи."
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_rhytm"
	var/hits_per_mark = 3
	var/list/hit_counts = list()


/datum/heretic_knowledge/blade_upgrade/rhytm/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	var/datum/status_effect/heretic_passive/rhytm/our_rhythm = get_heretic_rhytm(source)
	if(!our_rhythm)
		return

	target.adjustStaminaLoss(our_rhythm.rhythm)

	var/target_uid = target.UID()
	hit_counts[target_uid] += 1
	if(hit_counts[target_uid] < hits_per_mark)
		return

	hit_counts[target_uid] = 0
	var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(source)
	var/datum/heretic_knowledge/limited_amount/starting/base_rhytm/mark_to_apply = heretic_datum?.get_knowledge(/datum/heretic_knowledge/limited_amount/starting/base_rhytm)
	mark_to_apply?.create_mark(source, target)


/datum/heretic_knowledge/spell/heart_resonance
	name = "Резонанс Сердец"
	desc = "Даёт вам \"Резонанс Сердец\": на минуту все сердца поблизости начинают биться в вашем такте. \
			Пока связь держится, каждое ваше сердцебиение бьёт по всему живому вокруг, \
			а чужой страх поднимает ваш ритм. Радиус волны растёт вместе с ритмом."
	gain_text = "Их сердца сбились на мой такт, и я впервые услышал, как много вокруг живого."
	research_tree_icon_path = 'icons/mob/actions/actions_ecult.dmi'
	research_tree_icon_state = "heart_resonance"
	spell_to_add = /datum/action/cooldown/spell/aoe/heart_resonance
	cost = 2
	is_final_knowledge = TRUE


/datum/heretic_knowledge/ultimate/rhytm_final
	name = "Сердце, Которое Не Останавливается"
	desc = "Ритуал вознесения Пути Ритма. \
			Поднесите 4 трупа к руне трансмутации, чтобы завершить ритуал. \
			Вы снимете с себя кожу и станете аватаром Грозового Ритма: \
			сердце будет бить каждую секунду, каждый его удар будет бить по всему живому вокруг, \
			а ваш ритм больше никогда не опустится ниже тридцати."
	gain_text = "Обитель не была ни местом, ни существом. Она была тактом, который никто не смеет прервать. \
				Теперь этот такт отбиваю я."

	announcement_text = "%SPOOKY% Станция сбилась с такта. Сердце сущности %NAME% \
						бьётся за всех вас сразу. %SPOOKY%"
	announcement_sound = 'sound/magic/heretic/rhytm/timpan1.ogg'
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/ascension.dmi'
	research_tree_icon_state = "rhytmascend"
	required_atoms = list(/mob/living/carbon/human = 4)


/datum/heretic_knowledge/ultimate/rhytm_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()

	var/datum/status_effect/heretic_passive/rhytm/our_rhythm = get_heretic_rhytm(user)
	our_rhythm?.ascend()

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/ascended_heretic = user
	var/skintype = ascended_heretic.dna.species.skinned_type
	if(skintype)
		new skintype(get_turf(ascended_heretic))
	ascended_heretic.ChangeToHusk()
