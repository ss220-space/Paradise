/datum/disease/virus/transformation
	name = "Трансформация"
	stage_prob = 10
	max_stages = 5
	spread_flags = NON_CONTAGIOUS
	severity = DANGEROUS
	can_immunity = FALSE
	infectable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	var/list/stage1
	var/list/stage2
	var/list/stage3
	var/list/stage4
	var/list/stage5
	var/list/transform_message
	var/new_form
	var/is_new_mind = FALSE
	var/transformed = FALSE
	var/cure_after_transform = TRUE

/datum/disease/virus/transformation/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(1)
			if(prob(stage_prob) && stage1)
				to_chat(affected_mob, pick(stage1))
		if(2)
			if(prob(stage_prob) && stage2)
				to_chat(affected_mob, pick(stage2))
		if(3)
			if(prob(stage_prob*2) && stage3)
				to_chat(affected_mob, pick(stage3))
		if(4)
			if(prob(stage_prob*2) && stage4)
				to_chat(affected_mob, pick(stage4))
		if(5)
			if(prob(stage_prob*2) && stage5)
				to_chat(affected_mob, pick(stage5))
			if(!transformed)
				if(transform_message)
					to_chat(affected_mob, pick(transform_message))
				do_disease_transformation()
				if(cure_after_transform)
					cure()
	return TRUE

/datum/disease/virus/transformation/proc/do_disease_transformation()
	if(istype(affected_mob) && new_form)
		if(jobban_isbanned(affected_mob, new_form))
			affected_mob.death(1)
			return

		if(HAS_TRAIT(affected_mob, TRAIT_NO_TRANSFORM))
			return

		ADD_TRAIT(affected_mob, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
		affected_mob.icon = null
		affected_mob.cut_overlays()
		affected_mob.invisibility = INVISIBILITY_ABSTRACT

		for(var/obj/item/item as anything in affected_mob.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
			affected_mob.drop_item_ground(item)

		if(isobj(affected_mob.loc))
			var/obj/O = affected_mob.loc
			O.force_eject_occupant(affected_mob)

		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			new_mob.a_intent = "harm"
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
				if(is_new_mind)
					new_mob.mind.wipe_memory()
			else
				new_mob.key = affected_mob.key

		qdel(affected_mob)
		transformed = TRUE
		return new_mob

/datum/disease/virus/transformation/jungle_fever
	name = "Тропическая лихорадка"
	agent = "Вибрион Конги М-909"
	desc = "Обезьяны с этой болезнью кусают людей, вызывая их мутацию в обезьяну."
	stage_prob = 2
	cure_prob = 5
	cures = list("banana")
	spread_flags = BITES
	infectable_mobtypes = list(/mob/living/carbon/human)
	severity = BIOHAZARD
	cure_after_transform = FALSE
	stage1	= null
	stage2	= null
	stage3	= null
	stage4 = list(span_warning("Ваша спина болит."), span_warning("Вы дышите через рот."), span_warning("У вас возникает тяга к бананам."), span_warning("Ваш разум затуманен."))
	stage5 = list(span_warning("Вам хочется вести себя как обезьяна."))
	new_form = /mob/living/carbon/human/lesser/monkey

/datum/disease/virus/transformation/jungle_fever/do_disease_transformation()
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	if(!is_monkeybasic(H))
		if(istype(H.dna.species.primitive_form))
			H.monkeyize()
			transformed = TRUE
		else
			var/mob/living/new_mob = ..()
			var/datum/disease/virus/transformation/jungle_fever/D = Contract(new_mob)
			D?.stage = 5
			D.transformed = TRUE
	else
		transformed = TRUE

/datum/disease/virus/transformation/jungle_fever/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, span_notice("Ваш [pick("спина", "рука", "нога", "локоть", "голова")] чешется."))
		if(3)
			if(prob(4))
				to_chat(affected_mob, span_danger("Вы чувствуете острую боль в голове."))
				affected_mob.AdjustConfused(20 SECONDS)
		if(4, 5)
			if(prob(4))
				affected_mob.say(pick("Иииик, уку уку!", "Иии-ииик!", "Ииии!", "Ун, ун."))

/datum/disease/virus/transformation/robot
	name = "Роботрансформация"
	agent = "R2D2 Наномашины"
	desc = "Эта болезнь, на самом деле острая инфекция наномашин, превращает жертву в киборга."
	cures = list("copper")
	cure_prob = 5
	is_new_mind = TRUE
	stage1 = null
	stage2 = list(span_notice("Ваши суставы кажутся скованными."), span_danger("Бип... буп..."))
	stage3 = list(span_danger("Ваши суставы кажутся очень скованными."), span_notice("Ваша кожа кажется дряблой."), span_danger("Вы чувствуете, как что-то движется... внутри."))
	stage4 = list(span_danger("Ваша кожа кажется очень дряблой."), span_danger("Вы чувствуете... что-то... внутри вас."))
	transform_message = list(span_danger("Ваша кожа будто вот-вот лопнет!"))
	new_form = /mob/living/silicon/robot

/datum/disease/virus/transformation/robot/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("Бип, буп.", "Бип, бип!", "Бууп...буп."))
			if(prob(4))
				to_chat(affected_mob, span_danger("Вы чувствуете острую головную боль."))
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("Бип-буп!", "Биип-буп-бип-буп-бип!", "Уб-бе-ейте мен-н-н-я!", "Я хо-ч-чу ум-м-ме-р-р-ее-е-еть..."))


/datum/disease/virus/transformation/xeno
	name = "Ксенотрансформация"
	agent = "Чужеродные микробы рип-ЛИ"
	desc = "Эта болезнь превращает жертву в ксеноморфа."
	cures = list("spaceacillin", "glycerol")
	cure_prob = 5
	stage1 = null
	stage2 = list("Ваше горло першит.", span_danger("Убить..."))
	stage3 = list(span_danger("Ваше горло сильно першит."), "Ваша кожа кажется тугой.", span_danger("Вы чувствуете, как что-то движется... внутри."))
	stage4 = list(span_danger("Ваша кожа кажется очень тугой."), span_danger("Ваша кровь кипит!"), span_danger("Вы чувствуете... что-то... внутри вас."))
	transform_message = list(span_danger(span_fontsize5("<b>Теперь вы ксеноморф.</b>") + "\n\
		<b>Вы чувствуете боль от превращения! Вы желаете укусить того, кто с вами это сделал, благо, память вас не покинула и вы всё помните.</b>"))
	new_form = null

/datum/disease/virus/transformation/xeno/New()
	..()
	new_form = pick(/mob/living/carbon/alien/humanoid/hunter, /mob/living/carbon/alien/humanoid/drone/no_queen, /mob/living/carbon/alien/humanoid/sentinel)

/datum/disease/virus/transformation/xeno/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(4))
				to_chat(affected_mob, span_danger("Вы чувствуете острую головную боль."))
				affected_mob.Paralyse(4 SECONDS)
		if(4)
			if(prob(20))
				affected_mob.say(pick("Ты выглядишь вкусно.", "Собираюсь... сожрать тебя...", "Хииисссс!"))

/datum/disease/virus/transformation/xeno/phantom
	name = "dangerous xenomorph transformation"
	transform_message = list(span_danger(span_fontsize5("<b>Теперь вы ксеноморф.</b>") + "\n\
	<b>Вы чувствуете боль от превращения! Вы утратили всю память и первобытная жажда убийства охватила вас!</b>"))

/datum/disease/virus/transformation/xeno/phantom/New()
	..()
	new_form = pick(/mob/living/carbon/alien/humanoid/hunter, /mob/living/carbon/alien/humanoid/drone/no_queen, /mob/living/carbon/alien/humanoid/sentinel)

/datum/disease/virus/transformation/xeno/phantom/do_disease_transformation()
	. = ..()
	var/mob/living/prom = .
	if(!prom.mind)
		return
	prom.mind.wipe_memory()
	prom.mind.objectives += new /datum/objective/xeno_genocide
	var/list/messages = prom.mind.prepare_announce_objectives()
	to_chat(prom, chat_box_red(messages.Join("<br>")))

/datum/disease/virus/transformation/slime
	name = "Продвинутая Мутационная Трансформация"
	agent = "Токсин Продвинутой Мутации"
	desc = "Этот высококонцентрированный экстракт превращает всё в большее количество себя."
	cures = list("frostoil")
	cure_prob = 80
	stage1 = list(span_notice("Вы чувствуете себя не очень хорошо."))
	stage2 = list(span_notice("Ваша кожа кажется немного скользкой."))
	stage3 = list(span_danger("Ваши конечности тают."), span_danger("Ваши конечности начинают терять форму."))
	stage4 = list(span_danger("Вы превращаетесь в слайма."))
	transform_message = list(span_danger("Вы превратились в слайма."))
	new_form = /mob/living/simple_animal/slime/random

/datum/disease/virus/transformation/slime/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(1)
			if(isslimeperson(affected_mob))
				stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(!isslimeperson(human))
					human.set_species(/datum/species/slime)

/datum/disease/virus/transformation/corgi
	name = "Лаяние"
	agent = "Шерсть магической собаки"
	desc = "Эта болезнь превращает жертву в корги."
	cure_text = "Смерть"
	cures = list("adminordrazine")
	stage1 = list(span_notice("ГАВ."))
	stage2 = list(span_notice("Вам хочется надеть глупую шляпу."))
	stage3 = list(span_danger("Нужно... съесть... шоколад...."), span_danger("ТЯФ"))
	stage4 = list(span_danger("Видения стиральных машин атакуют ваш разум!"))
	transform_message = list(span_danger("АУУУУУУ!!!"))
	new_form = /mob/living/simple_animal/pet/dog/corgi
	is_new_mind = TRUE

/datum/disease/virus/transformation/corgi/stage_act()
	if(!..() || !affected_mob)
		return FALSE

	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("ТЯФ", "Вууф!"))
		if(4)
			if(prob(20))
				affected_mob.say(pick("ГАВ!", "АВУУУУ!"))

/datum/disease/virus/transformation/morph
	name = "Благословение Обжорства"
	desc = "\"Дар\" из какого-то ужасного места."
	cure_text = "Ничего"
	cures = list("adminordrazine")
	stage_prob = 20
	stage1 = list(span_notice("Ваш желудок урчит."))
	stage2 = list(span_notice("Ваша кожа кажется обвисшей."))
	stage3 = list(span_danger("Ваши конечности тают."), span_danger("Ваши конечности начинают терять форму."))
	stage4 = list(span_danger("Вы ненасытны!"))
	transform_message = list(span_danger(span_fontsize5("<b>ТЕПЕРЬ ВЫ МОРФ!</b>") + "\n\
	Хоть Вы и трансформировались в отвратительную зелёную жижу, но это не повлияло на Ваше сознание \
	и память. Вы не являетесь антагонистом."))
	new_form = /mob/living/simple_animal/hostile/morph
