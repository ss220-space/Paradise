/mob/living/simple_animal/demon/slaughter
	name = "slaughter demon"
	ru_names = list(
		NOMINATIVE = "демон резни",
		GENITIVE = "демона резни",
		DATIVE = "демону резни",
		ACCUSATIVE = "демона резни",
		INSTRUMENTAL = "демоном резни",
		PREPOSITIONAL = "демоне резни"
	)
	real_name = "slaughter demon"
	desc = "Огромное угрожающее существо, покрытое бронированной чёрной чешуёй. Вам стоит бежать!"
	speak = list("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri", "orkan", "allaq")
	icon = 'icons/mob/mob.dmi'
	icon_state = "daemon"
	icon_living = "daemon"
	deathmessage = "издаёт последний рёв ярости, превращаясь в месиво из плоти!"
	loot = list(/obj/effect/decal/cleanable/blood/innards, /obj/effect/decal/cleanable/blood, /obj/effect/gibspawner/generic, /obj/effect/gibspawner/generic, /obj/item/organ/internal/heart/demon/slaughter)
	var/feast_sound = 'sound/misc/demon_consume.ogg'
	var/devoured = 0

	var/list/consumed_mobs = list()
	var/list/nearby_mortals = list()

	var/cooldown = 0
	var/gorecooldown = 0

	playstyle_string = "<b><span class='userdanger'>Вы – Демон Резни!</span></b><br> \
						<b>Вы - ужасное существо из иного измерения. У вас одна цель: убивать.</b><br> \
						<b>Вы можете использовать способность \"Кровавый путь\" на лужах крови, чтобы перемещаться через них, появляясь и исчезая на станции по своему желанию.</b><br> \
						<b>Если вы тащите мёртвое или находящееся в критическом состоянии существо, когда входите в лужу крови, он последует за вами, что позволит вам поглотить его.</b><br> \
						<b>Вы двигаетесь быстро, покидая лужу крови, но материальный мир скоро лишит вас сил и сделает медлительным.</b>"


/mob/living/simple_animal/demon/slaughter/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	ADD_TRAIT(src, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
	var/obj/effect/proc_holder/spell/bloodcrawl/bloodspell = new
	AddSpell(bloodspell)
	if(istype(loc, /obj/effect/dummy/slaughter))
		bloodspell.phased = TRUE


/mob/living/simple_animal/demon/slaughter/Destroy()
	// Only execute the below if we successfully died
	for(var/mob/living/M in consumed_mobs)
		release_consumed(M)
	. = ..()


/mob/living/simple_animal/demon/slaughter/attempt_objectives()
	if(!..())
		return

	var/list/messages = list()
	messages.Add(playstyle_string)
	messages.Add(span_notice("<b>Сейчас вы находитесь в ином измерении, отличном от станции. Используйте способность \"Кровавый путь\" на луже крови, чтобы проявиться.</b>"))
	src << 'sound/misc/demon_dies.ogg'
	if(vialspawned)
		return

	var/datum/objective/slaughter/objective = new
	var/datum/objective/demonFluff/fluffObjective = new
	objective.owner = mind
	fluffObjective.owner = mind
	//Paradise Port:I added the objective for one spawned like this
	mind.objectives += objective
	mind.objectives += fluffObjective
	messages.Add(mind.prepare_announce_objectives(FALSE))
	messages.Add(span_motd("С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Slaughter_Demon\">Демон резни</a>"))
	to_chat(src, chat_box_red(messages.Join("<br>")))



/obj/effect/decal/cleanable/blood/innards
	icon = 'icons/obj/surgery.dmi'
	icon_state = "innards"
	name = "pile of viscera"
	desc = "Омерзительная масса из разорванной плоти и органов."
	ru_names = list(
		NOMINATIVE = "кровавое месиво",
		GENITIVE = "кровавого месива",
		DATIVE = "кровавому месиву",
		ACCUSATIVE = "кровавое месиво",
		INSTRUMENTAL = "кровавым месивом",
		PREPOSITIONAL = "кровавом месиве"
	)


/mob/living/simple_animal/demon/slaughter/proc/release_consumed(mob/living/M)
	M.forceMove(get_turf(src))


// Cult slaughter demon
/mob/living/simple_animal/demon/slaughter/cult //Summoned as part of the cult objective "Bring the Slaughter"
	name = "harbinger of the slaughter"
	real_name = "harbinger of the Slaughter"
	desc = "Ужасное существо, обитающее за гранью здравого смысла."
	ru_names = list(
		NOMINATIVE = "вестник резни",
		GENITIVE = "вестника резни",
		DATIVE = "вестнику резни",
		ACCUSATIVE = "вестника резни",
		INSTRUMENTAL = "вестником резни",
		PREPOSITIONAL = "вестнике резни"
	)
	maxHealth = 500
	health = 500
	melee_damage_upper = 60
	melee_damage_lower = 60
	environment_smash = ENVIRONMENT_SMASH_RWALLS //Smashes through EVERYTHING - r-walls included
	faction = list("cult")
	playstyle_string = "<b><span class='userdanger'>Вы — Вестник Резни. Призванный слугами Нар'Си, у вас одна цель: уничтожить еретиков, которые не поклоняются вашему господину!</span></b><br> \
							<b>Вы можете использовать способность \"Кровавый путь\" рядом с лужей крови, чтобы войти в неё и стать неосязаемым. \
							Использование способности снова рядом с лужей крови позволит вам выйти из неё. Вы быстры, сильны и почти неуязвимы. Если вы тащите мёртвое или без сознания тело \
							в лужу крови, вы поглотите его через некоторое время и полностью восстановите здоровье. Вы можете использовать способность \"Чувствовать Жертв\" на вкладке Культиста, \
							чтобы найти случайного живого еретика.</b>"

/mob/living/simple_animal/demon/slaughter/cult/attempt_objectives()
	return


/obj/effect/proc_holder/spell/sense_victims
	name = "Охота за душами"
	desc = "Определите местоположение еретиков."
	base_cooldown = 0
	clothes_req = FALSE
	human_req = FALSE
	cooldown_min = 0
	overlay = null
	action_icon_state = "bloodcrawl"
	action_background_icon_state = "bg_cult"


/obj/effect/proc_holder/spell/sense_victims/create_new_targeting()
	return new /datum/spell_targeting/alive_mob_list


/obj/effect/proc_holder/spell/sense_victims/valid_target(mob/living/target, user)
	return target.stat == CONSCIOUS && target.key && !iscultist(target) // Only conscious, non cultist players


/obj/effect/proc_holder/spell/sense_victims/cast(list/targets, mob/user)
	var/mob/living/victim = targets[1]
	to_chat(victim, span_userdanger("Вы чувствуете ужасное ощущение, что за вами наблюдают..."))
	victim.Stun(6 SECONDS) //HUE
	var/area/A = get_area(victim)
	if(!A)
		to_chat(user, span_warning("Вы не смогли найти разумных еретиков для Резни."))
		return
	to_chat(user, span_danger("Вы чувствуете испуганную душу в [A.declent_ru(PREPOSITIONAL)]. <b>Покажите [genderize_ru(victim.gender,"ему","ей","ему","им")] ошибку [genderize_ru(victim.gender,"его","её","его","их")] пути.</b>"))


/mob/living/simple_animal/demon/slaughter/cult/Initialize(mapload)
	. = ..()
	spawn(0.5 SECONDS)
		var/list/demon_candidates = SSghost_spawns.poll_candidates("Хотите сыграть за демона резни?", ROLE_DEMON, TRUE, 10 SECONDS, source = /mob/living/simple_animal/demon/slaughter/cult)
		if(!demon_candidates.len)
			log_game("[src] has failed to spawn, because no one enrolled.")
			visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] исчезает во вспышке красного света!"))
			qdel(src)
			return
		var/mob/M = pick(demon_candidates)
		var/mob/living/simple_animal/demon/slaughter/cult/S = src
		if(!M || !M.client)
			log_game("[src] has failed to spawn, because enrolled player is missing.")
			visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] исчезает во вспышке красного света!"))
			qdel(src)
			return
		var/client/C = M.client

		S.key = C.key
		S.mind.assigned_role = "Harbinger of the Slaughter"
		S.mind.special_role = "Harbinger of the Slaughter"
		to_chat(S, playstyle_string)
		SSticker.mode.add_cultist(S.mind)
		var/obj/effect/proc_holder/spell/sense_victims/SV = new
		AddSpell(SV)
		var/datum/objective/new_objective = new /datum/objective
		new_objective.owner = S.mind
		new_objective.explanation_text = "Устройте Резню неверующим!"
		S.mind.objectives += new_objective
		var/list/messages = list(S.mind.prepare_announce_objectives(FALSE))
		to_chat(S, chat_box_red(messages.Join("<br>")))
		log_game("[S.key] has become Slaughter demon.")


/**
 * The loot from killing a slaughter demon - can be consumed to allow the user to blood crawl.
 */
/obj/item/organ/internal/heart/demon/slaughter/attack_self(mob/living/user)
	..()

	// Eating the heart for the first time. Gives basic bloodcrawling. This is the only time we need to insert the heart.
	if(!HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		user.visible_message(span_warning("Глаза [user] вспыхивают багровым светом!"), span_userdanger("Вы чувствуете, как странная сила проникает в ваше тело... Вы преобрели способность демона перемещаться через кровь!"))
		ADD_TRAIT(user, TRAIT_BLOODCRAWL, "bloodcrawl")
		user.drop_from_active_hand()
		insert(user) //Consuming the heart literally replaces your heart with a demon heart. H A R D C O R E.
		return TRUE

	// Eating a 2nd heart. Gives the ability to drag people into blood and eat them.
	if(HAS_TRAIT(user, TRAIT_BLOODCRAWL))
		to_chat(user, "Вы чувствуете себя иначе... [span_warning("ПОГЛОТИ ИХ!")]")
		ADD_TRAIT(user, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
		qdel(src) // Replacing their demon heart with another demon heart is pointless, just delete this one and return.
		return TRUE

	// Eating any more than 2 demon hearts does nothing.
	to_chat(user, span_warning("...и вы не чувствуете никаких изменений."))
	qdel(src)


/obj/item/organ/internal/heart/demon/slaughter/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M?.mind?.AddSpell(new /obj/effect/proc_holder/spell/bloodcrawl(null))


/obj/item/organ/internal/heart/demon/slaughter/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(M.mind)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL, TRAIT_BLOODCRAWL)
		REMOVE_TRAIT(M, TRAIT_BLOODCRAWL_EAT, TRAIT_BLOODCRAWL_EAT)
		M.mind.RemoveSpell(/obj/effect/proc_holder/spell/bloodcrawl)
	. = ..()


/**
 * LAUGHTER DEMON
 */
/mob/living/simple_animal/demon/slaughter/laughter
	// The laughter demon! It's everyone's best friend! It just wants to hug
	// them so much, it wants to hug everyone at once!
	name = "laughter demon"
	ru_names = list(
		NOMINATIVE = "демон смеха",
		GENITIVE = "демона смеха",
		DATIVE = "демону смеха",
		ACCUSATIVE = "демона смеха",
		INSTRUMENTAL = "демоном смеха",
		PREPOSITIONAL = "демоне смеха"
	)
	real_name = "laughter demon"
	desc = "Огромное милое существо, покрытое броней с розовыми бантиками."
	speak_emote = list("хихикает", "смеётся", "посмеивается")
	emote_hear = list("громко хохочет", "смеётся")
	response_help  = "обнимает"
	attacktext = "неистово щекочет"
	maxHealth = 175
	health = 175
	melee_damage_lower = 25
	melee_damage_upper = 25

	attack_sound = 'sound/items/bikehorn.ogg'
	feast_sound = 'sound/spookoween/scary_horn2.ogg'
	death_sound = 'sound/misc/sadtrombone.ogg'

	icon_state = "bowmon"
	icon_living = "bowmon"
	deathmessage = "исчезает, выпуская всех своих друзей из тюрьмы объятий."
	loot = list(/mob/living/simple_animal/pet/cat/kitten{name = "Laughter"})

	playstyle_string = "<font color='#FF69B4'><b><span class='userdanger'>Вы — Демон Смеха!</span></b></font><br> \
						<font color='#FF69B4'><b>Вы — очаровательное, и слегка пугающее, существо, которое обожает объятия и смех. Ваша цель — распространять радость, веселье и... немного хаоса!</b></font><br> \
						<font color='#FF69B4'><b>Вы можете использовать способность \"Кровавый путь\", чтобы перемещаться через милые лужи крови, появляясь и исчезая по своему желанию.</b></font><br> \
						<font color='#FF69B4'><b>Если вы тащите кого-то в лужу крови – они получат порцию вашего веселья и обнимашек. Вы быстро двигаетесь и восстанавливаетесь в лужах крови, но будьте осторожны: слишком много серьёзности может ослабить вас!</b></font><br> \
						<font color='#FF69B4'><b>Помните: смех — это ваше оружие, а объятия — ваш стиль. ДЕЛАЙТЕ МИР ЯРЧЕ И СМЕШНЕЕ!</b></font>"

/mob/living/simple_animal/demon/slaughter/laughter/release_consumed(mob/living/M)
	if(M.revive())
		M.grab_ghost(force = TRUE)
		playsound(get_turf(src), feast_sound, 50, 1, -1)
		to_chat(M, span_clown("Вы покидаете тёплые объятия [declent_ru(GENITIVE)] и чувствуете себя готовым покорить мир."))
	..(M)


//Objectives and helpers.

//Objective info, Based on Reverent mini Atang
/datum/objective/slaughter
	needs_target = FALSE
	antag_menu_name = "Поглотить смертных"
	var/targetKill = 10


/datum/objective/slaughter/New()
	targetKill = rand(10,20)
	explanation_text = "Поглотить [targetKill] смертн[declension_ru(targetKill, "ого", "ых", "ых")]."
	..()


/datum/objective/slaughter/check_completion()
	var/kill_count = 0
	for(var/datum/mind/player in get_owners())
		if(!isslaughterdemon(player.current) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/demon/slaughter/demon = player.current
		kill_count += demon.devoured

	if(kill_count >= targetKill)
		return TRUE

	return FALSE


/datum/objective/demonFluff
	needs_target = FALSE


/datum/objective/demonFluff/New()
	find_target()
	var/targetname = "someone"
	if(target?.current)
		targetname = target.current.real_name
	var/list/explanation_texts = list("Залейте кровью весь мостик.", \
									 "Залейте кровью весь бриг.", \
									 "Залейте кровью всю церковь.", \
									 "Убейте или уничтожьте всех чистоботов или медботов.", \
									 "Нанесите удар жертве и скройтесь... Заставьте их обагрить всё своей кровью.", \
									 "Охотьтесь на тех, кто попытается охотиться на вас.", \
									 "Охотьтесь на тех, кто в страхе убегает от вас.", \
									 "Покажите [targetname] силу крови.", \
									 "Сведите [targetname] с ума демоническим шепотом."
									 )

	// As this is a fluff objective, we don't need a target, so we want to null it out.
	// We don't want the demon getting a "Time for Plan B" message if the target cryos.
	target = null
	explanation_text = pick(explanation_texts)
	..()


/datum/objective/demonFluff/check_completion()
	return TRUE
