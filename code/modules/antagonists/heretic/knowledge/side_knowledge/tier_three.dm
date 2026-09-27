/datum/heretic_knowledge/limited_amount/summon/ashy
	drafting_tier = 3
	name = "Ритуал Пепла"
	desc = "Позволяет преобразовать костёр, кучку пепла и книгу в Духа Пепла. \
			Духи Пепла обладают коротким рывком и способностью вызывать кровотечение \
			у врагов на расстоянии. Они также могут на некоторое время создавать вокруг себя \
			огненное кольцо. У них мало здоровья, но со временем они постепенно восстанавливаются."
	gain_text = "Я соединил свой принцип голода с жаждой разрушения. \
				Маршал знал моё имя, а Ночной Страж наблюдал за мной."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/book = 1,
		/obj/structure/bonfire = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/ash_spirit
	cost = 2


/datum/heretic_knowledge/limited_amount/summon/fire_shark
	drafting_tier = 3
	name = "Опаляющая Акула"
	desc = "Позволяет преобразовать горстку пепла, печень и лист плазмы в Огненную Акулу. \
			Огненные Акулы быстры и сильны в группах, но быстро погибают. Они также очень устойчивы к огню. \
			Огненные Акулы впрыскивают в своих жертв флогистон и выделяют плазму после смерти."
	gain_text = "Колыбель туманности была холодной, но не мёртвой. Свет и тепло проникают даже сквозь самую глубокую тьму, но даже за ними охотятся хищники."

	required_atoms = list(
		/obj/effect/decal/cleanable/ash = 1,
		/obj/item/organ/internal/liver = 1,
		/obj/item/stack/sheet/mineral/plasma = 1,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/fire_shark
	limit = 5
	cost = 2
	research_tree_icon_dir = EAST


/datum/heretic_knowledge/limited_amount/summon/rusty
	drafting_tier = 3
	name = "Ржавый Ритуал"
	desc = "Позволяет превратить лужу рвоты, 15 кусочков кабеля и 10 листов железа в Ржавого Странника. \
			Ржавые Странники отлично разносят ржавчину и довольно сильны в бою."
	gain_text = "Я совместил свои навыки творца с жаждой разложения. \
				Маршал знал моё имя, и Ржавые Холмы отзывались эхом."

	required_atoms = list(
		/obj/effect/decal/cleanable/vomit = 1,
		/obj/item/stack/sheet/metal = 10,
		/obj/item/stack/cable_coil = 15,
	)
	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/rust_walker
	cost = 2


/datum/heretic_knowledge/limited_amount/summon/maid_in_mirror
	drafting_tier = 3
	name = "Дева-из-Зеркала"
	desc = "Позволяет трансмутировать пять листов стекла, любой костюм и пару лёгких, \
			чтобы создать Деву-из-Зеркала. Девы-из-Зеркала — достойные бойцы, способные \
			становиться бестелесными, появляясь в зеркальном мире и выходя из него, служа мощными \
			разведчиками и засадниками. Их атаки также накладывают заряд холода пустоты."
	gain_text = "В каждом отражении — врата в невообразимый мир полный цветов, которых никогда никто не видел. \
				Пол — стекло, а стены — ножи. Каждый шаг ранит, если у вас нет проводника."

	required_atoms = list(
		/obj/item/stack/sheet/glass = 5,
		/obj/item/clothing/suit = 1,
		/obj/item/organ/internal/lungs = 1,
	)
	cost = 2

	mob_to_summon = /mob/living/simple_animal/hostile/heretic_summon/maid_in_the_mirror


/// The max health given to Shattered Risen
#define RISEN_MAX_HEALTH 125

/datum/heretic_knowledge/limited_amount/risen_corpse
	drafting_tier = 3
	name = "Разрушенный Ритуал"
	desc = "Позволяет трансмутировать труп с душой, пару латексных или нитриловых перчаток и любой костюм, \
			чтобы создать Разбитого Восставшего. \
			Разбитые Восставшие — сильные гули со 125 единицами здоровья, но неспособные держать предметы. \
			Вместо рук у них два грозных оружия. Вы можете создать только одного Разбитого Восставшего за раз."
	gain_text = "Я видел, как холодная, раздирающая сила вернула этот труп к жизни. \
				Когда он движется, раздаётся хруст, словно внутри него пересыпаются осколки стекла. \
				Его руки больше не похожи на человеческие. \
				Вместо каждого из кулаков — грозное месиво острых костяных осколков."

	required_atoms = list(
		/obj/item/clothing/suit = 1,
		/obj/item/clothing/gloves/color/latex = 1,
	)
	cost = 2

	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "ghoul_shattered"


/datum/heretic_knowledge/limited_amount/risen_corpse/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	if(!.)
		return FALSE

	for(var/mob/living/carbon/human/body in atoms)
		if(body.stat != DEAD)
			continue

		if(!IS_VALID_GHOUL_MOB(body) || HAS_TRAIT(body, TRAIT_HUSK))
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] в слишком плохом состоянии, чтобы превратиться в гуля."))
			continue

		if(!body.mind)
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[PLUR_ET_YUT(body)] разума, а значит не мо[PLUR_JET_GUT(body)] стать гулём."))
			continue

		if(!body.client && !body.mind.get_ghost())
			to_chat(user, span_hierophant_warning("[body.declent_ru(NOMINATIVE)] не име[PLUR_ET_YUT(body)] души, а значит не мо[PLUR_JET_GUT(body)] стать гулём."))
			continue

		selected_atoms += body
		return TRUE

	loc.balloon_alert(user, "нет подходящего тела!")
	return FALSE


/datum/heretic_knowledge/limited_amount/risen_corpse/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/mob/living/carbon/human/soon_to_be_ghoul = locate() in selected_atoms
	if(QDELETED(soon_to_be_ghoul)) // No body? No ritual
		stack_trace("[type] reached on_finished_recipe without a human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "нет подходящего трупа!")
		return FALSE

	soon_to_be_ghoul.grab_ghost()
	if(!soon_to_be_ghoul.mind || !soon_to_be_ghoul.client)
		stack_trace("[type] reached on_finished_recipe without a minded / cliented human in selected_atoms to make a ghoul out of.")
		loc.balloon_alert(user, "нет подходящего трупа!")
		return FALSE

	selected_atoms -= soon_to_be_ghoul
	make_risen(user, soon_to_be_ghoul)
	return TRUE


/// Make [victim] into a shattered risen ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/make_risen(mob/living/user, mob/living/carbon/human/victim)
	message_admins("[ADMIN_LOOKUPFLW(user)] created a shattered risen, [ADMIN_LOOKUPFLW(victim)].")

	victim.apply_status_effect(
		/datum/status_effect/ghoul,
		RISEN_MAX_HEALTH,
		user.mind,
		CALLBACK(src, PROC_REF(apply_to_risen)),
		CALLBACK(src, PROC_REF(remove_from_risen)),
	)


/// Callback for the ghoul status effect - what effects are applied to the ghoul.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/apply_to_risen(mob/living/risen)
	LAZYADD(created_items, WEAKREF(risen))
	risen.AddComponent(/datum/component/mutant_hands, mutant_hand_path = /obj/item/mutant_hand/shattered_risen)


/// Callback for the ghoul status effect - cleaning up effects after the ghoul status is removed.
/datum/heretic_knowledge/limited_amount/risen_corpse/proc/remove_from_risen(mob/living/risen)
	LAZYREMOVE(created_items, WEAKREF(risen))
	qdel(risen.GetComponent(/datum/component/mutant_hands))


#undef RISEN_MAX_HEALTH


/// The "hand" "weapon" used by shattered risen
/obj/item/mutant_hand/shattered_risen
	name = "shattered risen fist"
	desc = "То, что когда-то было обычным человеческим кулаком, \
			теперь является месивом из острых костяных осколков."
	color = "#001aff"
	hitsound = SFX_SHATTER
	force = 16
	sharp = TRUE


/obj/item/mutant_hand/shattered_risen/get_ru_names()
	return alist(
		NOMINATIVE = "месиво костяных осколков",
		GENITIVE = "месива костяных осколков",
		DATIVE = "месиву костяных осколков",
		ACCUSATIVE = "месиво костяных осколков",
		INSTRUMENTAL = "месивом костяных осколков",
		PREPOSITIONAL = "месиве костяных осколков",
	)


/datum/heretic_knowledge/dream_catcher
	drafting_tier = 3
	is_shop_only = TRUE
	name = "Ловец Снов"
	desc = "Позволяет создать \"Dream Catcher\".<br>\
			Надетый обруч работает в двух режимах.<br>\
			В режиме охоты он ждёт, пока вы уснёте, и переносит вас в тело любого спящего \
			на этом уровне — на две минуты его хозяин остаётся заперт за собственными глазами.<br>\
			В режиме вызова вы выбираете любого разумного поблизости: оба тела засыпают, а вы \
			встречаетесь во сне, где выживает только один."
	transmute_text = "Преобразуйте любой головной убор, две зажжённые свечи, глаза и простыню."
	gain_text = "Спящий не защищён ничем, кроме собственной уверенности, что спит один. \
				Кодекс называет это самой дешёвой из всех дверей."
	required_atoms = list(
		/obj/item/clothing/head = 1,
		/obj/item/organ/internal/eyes = 1,
		/obj/item/bedsheet = 1,
		/obj/item/candle = 2,
	)
	result_atoms = list(/obj/item/clothing/head/dream_catcher)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/hats.dmi'
	research_tree_icon_state = "dream_catcher_node"


/datum/heretic_knowledge/dream_catcher/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle


/datum/heretic_knowledge/mad_mask
	drafting_tier = 3
	name = "Маска Безумия"
	desc = "Позволяет создать \"Маску Безумия\".<br>\
			Маска вселяет страх в язычников, которые её видят, вызывая снижение выносливости, галлюцинации и безумие.<br>\
			Её также можно надеть на язычника силой, чтобы он не смог её снять..."
	transmute_text = "Преобразуйте любую маску, четыре зажжённые свечи, стандубинку и печень."
	gain_text = "Дозор носил на службе странное облачение. Оно позволяло ходить по городу, оставаясь незамеченным для толпы."
	required_atoms = list(
		/obj/item/organ/internal/liver = 1,
		/obj/item/melee/baton/security = 1,
		/obj/item/clothing/mask = 1,
		/obj/item/candle = 4,
	)
	result_atoms = list(/obj/item/clothing/mask/madness_mask)
	cost = 2
	research_tree_icon_path = 'icons/obj/clothing/masks.dmi'
	research_tree_icon_state = "mad_mask"


/datum/heretic_knowledge/mad_mask/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	. = ..()
	for(var/obj/item/candle/candle in atoms)
		if(!candle.lit)
			atoms -= candle
