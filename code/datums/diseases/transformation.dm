/datum/disease/transformation
	name = "Превращение"
	max_stages = 5
	spread_text = "Острый"
	spread_flags = SPECIAL
	cure_text = "Любовь кодера (теоретически)."
	agent = "Шалости"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/alien)
	severity = HARMFUL
	stage_prob = 10
	visibility_flags = HIDDEN_SCANNER|HIDDEN_PANDEMIC
	disease_flags = CURABLE
	var/list/stage1 = list("Вам невзрачно.")
	var/list/stage2 = list("Вам скучно.")
	var/list/stage3 = list("Вам всё опостылело.")
	var/list/stage4 = list("Вам белый хлеб.")
	var/list/stage5 = list("О, человечество!")
	var/new_form = /mob/living/carbon/human

/datum/disease/transformation/stage_act()
	..()
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
			do_disease_transformation(affected_mob)

/datum/disease/transformation/proc/do_disease_transformation(mob/living/affected_mob)
	if(istype(affected_mob, /mob/living/carbon) && affected_mob.stat != DEAD)
		if(stage5)
			to_chat(affected_mob, pick(stage5))
		if(jobban_isbanned(affected_mob, new_form))
			affected_mob.death(1)
			return
		if(affected_mob.notransform)
			return
		affected_mob.notransform = 1
		affected_mob.canmove = 0
		affected_mob.icon = null
		affected_mob.overlays.Cut()
		affected_mob.invisibility = 101
		for(var/obj/item/W in affected_mob)
			if(istype(W, /obj/item/implant))
				qdel(W)
				continue
			if(affected_mob.unEquip(W)) //Если вещь снимается - снимаем
				affected_mob.unEquip(W)
			W.layer = initial(W.layer)
			W.plane = initial(W.plane)
			W.loc = affected_mob.loc
			W.dropped(affected_mob)
		if(isobj(affected_mob.loc))
			var/obj/O = affected_mob.loc
			O.force_eject_occupant(affected_mob)
		var/mob/living/new_mob = new new_form(affected_mob.loc)
		if(istype(new_mob))
			new_mob.a_intent = "harm"
			if(affected_mob.mind)
				affected_mob.mind.transfer_to(new_mob)
			else
				new_mob.key = affected_mob.key
		qdel(affected_mob)



/datum/disease/transformation/jungle_fever
	name = "Тропическая лихорадка"
	cure_text = "Бананы"
	cures = list("banana")
	spread_text = "Укусы обезьян"
	spread_flags = SPECIAL
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	cure_chance = 1
	disease_flags = CAN_CARRY|CAN_RESIST
	desc = "Болеющие этой болезнью обезьяны будут кусать людей, из-за чего те будут мутировать в обезьян."
	severity = BIOHAZARD
	stage_prob = 4
	visibility_flags = 0
	agent = "Вибрион Конги М-909"
	new_form = /mob/living/carbon/human/monkey

	stage1	= null
	stage2	= null
	stage3	= null
	stage4	= list("<span class='warning'>У вас болит зад.</span>", "<span class='warning'>Вы начинаете дышать ртом.</span>",
					"<span class='warning'>Вы очень хотите бананов.</span>", "<span class='warning'>Ваш разум затуманивается.</span>")
	stage5	= list("<span class='warning'>Вы хотите обезьянничать.</span>")

/datum/disease/transformation/jungle_fever/do_disease_transformation(mob/living/carbon/human/affected_mob)
	if(!issmall(affected_mob))
		affected_mob.monkeyize()

/datum/disease/transformation/jungle_fever/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Ваша [pick("спина", "рука", "нога", "грудь", "голова")] чешется.</span>")
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>У вас раскалывается голова.</span>")
				affected_mob.AdjustConfused(10)
		if(4)
			if(prob(3))
				affected_mob.say(pick("Ииик, ук ук!", "Иии-ииик!", "Иииии!", "Уга, уга."))


/datum/disease/transformation/robot
	name = "Роботрансформация"
	cure_text = "Инъекция меди."
	cures = list("copper")
	cure_chance = 5
	agent = "Наномашины R2D2"
	desc = "Эта болезнь, будучи на самом деле острым заражением наномашинами, превращает жертву в киборга."
	severity = DANGEROUS
	visibility_flags = 0
	stage1	= null
	stage2	= list("Ваши суставы теряют гибкость.", "<span class='danger'>Биg… буп…</span>")
	stage3	= list("<span class='danger'>Ваши суставы перестают гнуться.</span>", "Ваша кожа начинает обвисать.", "<span class='danger'>Вы чувствуете, как что-то двигается внутри…</span>")
	stage4	= list("<span class='danger'>Ваша кожа сильно обвисает.</span>", "<span class='danger'>Вы чувствуете… что-то… внутри себя.</span>")
	stage5	= list("<span class='danger'>Ваша кожа начинает отваливаться!</span>")
	new_form = /mob/living/silicon/robot


/datum/disease/transformation/robot/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("Бип, буп", "бип, бип!", "Буп… боп"))
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>У вас раскалывается голова.</span>")
				affected_mob.Paralyse(2)
		if(4)
			if(prob(20))
				affected_mob.say(pick("бип, бип!", "Буп боп буп бип.", "у-бе-е-е-ей-те-е-е-е ме-е-е-е-е-ня-я-я-я", "Да-а-а-а-ай-те мне-е-е-е-е уме-е-е-е-ре-е-е-е-еть"))


/datum/disease/transformation/xeno
	name = "Ксенотрансформация"
	cure_text = "Spaceacillin & Glycerol"
	cures = list("spaceacillin", "glycerol")
	cure_chance = 5
	agent = "Чужеродные микробы рип-ЛИ"
	desc = "Эта болезнь превращает жертву в ксеноморфа."
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= null
	stage2	= list("У вас чешется горло.", "<span class='danger'>Убить…</span>")
	stage3	= list("<span class='danger'>У вас очень сильно чешется горло.</span>", "Ваша кожа твердеет.", "<span class='danger'>Вы чувствуете, как что-то двигается внутри….</span>")
	stage4	= list("<span class='danger'>Ваша кожа значительно твердеет.</span>", "<span class='danger'>Ваша кровь начинает кипеть!</span>", "<span class='danger'>Вы чувствуете… что-то… внутри себя.</span>")
	stage5	= list("<span class='danger'>Ваша кожа начинает отваливаться!</span>")
	new_form = /mob/living/carbon/alien/humanoid/hunter

/datum/disease/transformation/xeno/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>У вас раскалывается голова.</span>")
				affected_mob.Paralyse(2)
		if(4)
			if(prob(20))
				affected_mob.say(pick("Ты выглядишь вкусно.", "Я… тебя… сожру…", "Х-с-с-с-ш-ш-ш-ш-ш!"))


/datum/disease/transformation/slime
	name = "Улучшенная мутационная трансформация"
	cure_text = "frost oil"
	cures = list("frostoil")
	cure_chance = 80
	agent = "Advanced Mutation Toxin"
	desc = "Этот высококонцентрированный экстракт превращает всё в него самого."
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Вам не очень хорошо.")
	stage2	= list("Ваша кожа становится липкой.")
	stage3	= list("<span class='danger'>Ваши черты лица оплавляются.</span>", "<span class='danger'>Ваши конечности начинают терять форму.</span>")
	stage4	= list("<span class='danger'>Вы становитесь слаймом…</span>")
	stage5	= list("<span class='danger'>Вы стали слаймом.</span>")
	new_form = /mob/living/simple_animal/slime/random

/datum/disease/transformation/slime/stage_act()
	..()
	switch(stage)
		if(1)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/H = affected_mob
				if(isslimeperson(H))
					stage = 5
		if(3)
			if(ishuman(affected_mob))
				var/mob/living/carbon/human/human = affected_mob
				if(!isslimeperson(human))
					human.set_species(/datum/species/slime)

/datum/disease/transformation/corgi
	name = "Лайство"
	cure_text = "Смерть"
	cures = list("adminordrazine")
	agent = "Ощутий магий собакен"
	desc = "Болезнь, превращающая субъекта в корги."
	visibility_flags = 0
	stage1	= list("ГАВ!")
	stage2	= list("Вы ощущаете желание носить дурацкие шляпы.")
	stage3	= list("<span class='danger'>Надо… сожрать… шоколадку…</span>", "<span class='danger'>ЯП!</span>")
	stage4	= list("<span class='danger'>Образы стиральных машин завораживают вас!</span>")
	stage5	= list("<span class='danger'>А-У-У-У-У-У-У!!!</span>")
	new_form = /mob/living/simple_animal/pet/dog/corgi

/datum/disease/transformation/corgi/stage_act()
	..()
	switch(stage)
		if(3)
			if(prob(8))
				affected_mob.say(pick("ЯП", "Вуф!"))
		if(4)
			if(prob(20))
				affected_mob.say(pick("ГАВ!", "А-У-У-У-У-У-У!"))

/datum/disease/transformation/morph
	name = "Благословение чревоугодия"
	cure_text = "Ничего"
	cures = list("adminordrazine")
	agent = "Благословение чревоугодия"
	desc = "«Дар» чего-то ужасного."
	stage_prob = 20
	severity = BIOHAZARD
	visibility_flags = 0
	stage1	= list("Ваш желудок урчит.")
	stage2	= list("Ваша кожа будто обвисает.")
	stage3	= list("<span class='danger'>Ваши черты лица оплавляются.</span>", "<span class='danger'>Ваши конечности начинают терять форму.</span>")
	stage4	= list("<span class='danger'>Вы изголодались.</span>")
	stage5	= list("<span class='danger'>Вы стали морфом.</span>")
	new_form = /mob/living/simple_animal/hostile/morph
