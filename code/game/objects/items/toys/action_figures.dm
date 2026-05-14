/* Action figures toys
 *	Contains:
 *		Mech prizes
 *		Owl and griffin
 *		DND Character minis
 *		Action figures
 */

/*
 * Mech prizes
 */
/obj/item/toy/prize
	icon_state = "ripleytoy"
	var/cooldown = 0

//all credit to skasi for toy mech fun ideas
/obj/item/toy/prize/attack_self(mob/user as mob)
	if(cooldown < world.time - 8)
		to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
		playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)
		cooldown = world.time

/obj/item/toy/prize/attack_hand(mob/user as mob)
	if(loc == user)
		if(cooldown < world.time - 8)
			to_chat(user, span_notice("Вы играете с [declent_ru(INSTRUMENTAL)]."))
			playsound(user, 'sound/mecha/mechturn.ogg', 20, TRUE)
			cooldown = world.time
			return
	..()

/obj/random/mech
	name = "Random Mech Prize"
	desc = "This is a random prize"
	icon_state = "ripleytoy"

/obj/random/mech/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/prize)) //exclude the base type.

/obj/item/toy/prize/ripley
	name = "toy ripley"
	desc = "Mini-Mecha action figure! Collect them all! 1/11. This one is a ripley, a mining and engineering mecha."

/obj/item/toy/prize/fireripley
	name = "toy firefighting ripley"
	desc = "Mini-Mecha action figure! Collect them all! 2/11. This one is a firefighter ripley, a fireproof mining and engineering mecha."
	icon_state = "fireripleytoy"

/obj/item/toy/prize/deathripley
	name = "toy deathsquad ripley"
	desc = "Mini-Mecha action figure! Collect them all! 3/11. This one is the black ripley used by the hero of DeathSquad, that TV drama about loose-cannon ERT officers!"
	icon_state = "deathripleytoy"

/obj/item/toy/prize/gygax
	name = "toy gygax"
	desc = "Mini-Mecha action figure! Collect them all! 4/11. This one is the speedy gygax combat mecha. Zoom zoom, pew pew!"
	icon_state = "gygaxtoy"

/obj/item/toy/prize/durand
	name = "toy durand"
	desc = "Mini-Mecha action figure! Collect them all! 5/11. This one is the heavy durand combat mecha. Stomp stomp!"
	icon_state = "durandprize"

/obj/item/toy/prize/honk
	name = "toy H.O.N.K."
	desc = "Mini-Mecha action figure! Collect them all! 6/11. This one is the infamous H.O.N.K mech!"
	icon_state = "honkprize"

/obj/item/toy/prize/marauder
	name = "toy marauder"
	desc = "Mini-Mecha action figure! Collect them all! 7/11. This one is the powerful marauder combat mecha! Run for cover!"
	icon_state = "marauderprize"

/obj/item/toy/prize/seraph
	name = "toy seraph"
	desc = "Mini-Mecha action figure! Collect them all! 8/11. This one is the powerful seraph combat mecha! Someone's in trouble!"
	icon_state = "seraphprize"

/obj/item/toy/prize/mauler
	name = "toy mauler"
	desc = "Mini-Mecha action figure! Collect them all! 9/11. This one is the deadly mauler combat mecha! Look out!"
	icon_state = "maulerprize"

/obj/item/toy/prize/odysseus
	name = "toy odysseus"
	desc = "Mini-Mecha action figure! Collect them all! 10/11. This one is the spindly, syringe-firing odysseus medical mecha."
	icon_state = "odysseusprize"

/obj/item/toy/prize/phazon
	name = "toy phazon"
	desc = "Mini-Mecha action figure! Collect them all! 11/11. This one is the mysterious Phazon combat mecha! Nobody's safe!"
	icon_state = "phazonprize"

/*
 * Owl and griffin
 */
 /obj/item/toy/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/owl/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("На этот раз тебе не уйти, Гриффин!", "Стой, преступник!", "Ух! Ух!", "Я — ночь!")
		to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/creatures/hoot.ogg', 25, TRUE)
		user.visible_message(span_danger("[get_examine_icon(viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/obj/item/toy/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon_state = "griffinprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/griffin/attack_self(mob/user)
	if(!cooldown) //for the sanity of everyone
		var/message = pick("Ты не остановишь меня, Сова!", "Мой план безупречен! Хранилище моё!", "Карррр!", "Меня никогда не поймаешь!")
		to_chat(user, span_notice("Вы дёргаете верёвочку на [declent_ru(PREPOSITIONAL)]."))
		playsound(user, 'sound/creatures/caw.ogg', 25, TRUE)
		user.visible_message(span_danger("[get_examine_icon(viewers(user))] [message]"))
		cooldown = 1
		spawn(30) cooldown = 0
		return
	..()

/*
 * DND Character minis
 * Use the naming convention (type)character for the icon states.
 */
/obj/item/toy/character
	w_class = WEIGHT_CLASS_SMALL
	pixel_z = 5

/obj/item/toy/character/alien
	name = "Xenomorph Miniature"
	desc = "A miniature xenomorph. Scary!"
	icon_state = "aliencharacter"
/obj/item/toy/character/cleric
	name = "Cleric Miniature"
	desc = "A wee little cleric, with his wee little staff."
	icon_state = "clericcharacter"
/obj/item/toy/character/warrior
	name = "Warrior Miniature"
	desc = "That sword would make a decent toothpick."
	icon_state = "warriorcharacter"
/obj/item/toy/character/thief
	name = "Thief Miniature"
	desc = "Hey, where did my wallet go!?"
	icon_state = "thiefcharacter"
/obj/item/toy/character/wizard
	name = "Wizard Miniature"
	desc = "MAGIC!"
	icon_state = "wizardcharacter"
/obj/item/toy/character/cthulhu
	name = "Cthulhu Miniature"
	desc = "The dark lord has risen!"
	icon_state = "darkmastercharacter"
/obj/item/toy/character/lich
	name = "Lich Miniature"
	desc = "Murderboner extraordinaire."
	icon_state = "lichcharacter"
/obj/item/storage/box/characters
	name = "Box of Miniatures"
	desc = "The nerd's best friends."

/obj/item/storage/box/characters/populate_contents()
	new /obj/item/toy/character/alien(src)
	new /obj/item/toy/character/cleric(src)
	new /obj/item/toy/character/warrior(src)
	new /obj/item/toy/character/thief(src)
	new /obj/item/toy/character/wizard(src)
	new /obj/item/toy/character/cthulhu(src)
	new /obj/item/toy/character/lich(src)

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	bubble_icon = "alien"
	var/cooldown = 0
	var/animating = FALSE

/obj/item/toy/toy_xeno/update_icon_state()
	icon_state = animating ? "[initial(icon_state)]_used" : initial(icon_state)

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message(span_notice("[user] дергает[PLUR_ET_YUT(user)] верёвку на [declent_ru(PREPOSITIONAL)]."))
		INVOKE_ASYNC(src, PROC_REF(async_animation))
	else
		to_chat(user, span_warning("Верёвка [declent_ru(GENITIVE)] еще не замоталась!"))

/obj/item/toy/toy_xeno/proc/async_animation()
	animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(0.5 SECONDS)
	atom_say("Hiss!")
	var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
	playsound(get_turf(src), pick(possible_sounds), 50, TRUE)
	sleep(4.5 SECONDS)
	animating = FALSE
	update_icon(UPDATE_ICON_STATE)

/*
 * Action figures
 */
/obj/random/figure
	name = "Random Action Figure"
	desc = "This is a random toy action figure"
	icon_state = "nuketoy"

/obj/random/figure/item_to_spawn()
	return pick(subtypesof(/obj/item/toy/figure))

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	desc = "A \"Space Life\" brand... wait, what the hell is this thing?"
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	var/toysay = "Чё за хуйню вы натворили?"

/obj/item/toy/figure/Initialize(mapload)
	. = ..()
	desc = "A \"Space Life\" brand [name]"

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown < world.time)
		cooldown = (world.time + 30) //3 second cooldown
		user.visible_message(span_notice("[get_examine_icon(viewers(user))] [DECLENT_RU_CAP(src, NOMINATIVE)] говорит \"[toysay]\"."))
		playsound(user, 'sound/machines/click.ogg', 20, TRUE)

/obj/item/toy/figure/cmo
	name = "Chief Medical Officer action figure"
	desc = "The ever-suffering CMO, from Space Life's SS12 figurine collection."
	icon_state = "cmo"
	toysay = "Переключи датчики!"

/obj/item/toy/figure/assistant
	name = "Assistant action figure"
	desc = "The faceless, hairless scourge of the station, from Space Life's SS12 figurine collection."
	icon_state = "assistant"
	toysay = "Грейтайд един!"

/obj/item/toy/figure/atmos
	name = "Atmospheric Technician action figure"
	desc = "The faithful atmospheric technician, from Space Life's SS12 figurine collection."
	icon_state = "atmos"
	toysay = "Слава Атмосии!"

/obj/item/toy/figure/bartender
	name = "Bartender action figure"
	desc = "The suave bartender, from Space Life's SS12 figurine collection."
	icon_state = "bartender"
	toysay = "Где моя обезьяна?"

/obj/item/toy/figure/borg
	name = "Cyborg action figure"
	desc = "The iron-willed cyborg, from Space Life's SS12 figurine collection."
	icon_state = "borg"
	toysay = "Я. СНОВА. ЖИВОЙ."

/obj/item/toy/figure/botanist
	name = "Botanist action figure"
	desc = "The drug-addicted botanist, from Space Life's SS12 figurine collection."
	icon_state = "botanist"
	toysay = "Чувак, я вижу цвета..."

/obj/item/toy/figure/captain
	name = "Captain action figure"
	desc = "The inept captain, from Space Life's SS12 figurine collection."
	icon_state = "captain"
	toysay = "Экипаж, ядерный диск в безопасности, в меня в жопе."

/obj/item/toy/figure/cargotech
	name = "Cargo Technician action figure"
	desc = "The hard-working cargo tech, from Space Life's SS12 figurine collection."
	icon_state = "cargotech"
	toysay = "За Каргонию!"

/obj/item/toy/figure/ce
	name = "Chief Engineer action figure"
	desc = "The expert Chief Engineer, from Space Life's SS12 figurine collection."
	icon_state = "ce"
	toysay = "Подключите соляры!"

/obj/item/toy/figure/chaplain
	name = "Chaplain action figure"
	desc = "The obsessed Chaplain, from Space Life's SS12 figurine collection."
	icon_state = "chaplain"
	toysay = "Боги, сделайте меня машиной для убийств!"

/obj/item/toy/figure/chef
	name = "Chef action figure"
	desc = "The cannibalistic chef, from Space Life's SS12 figurine collection."
	icon_state = "chef"
	toysay = "Клянусь, это не человечина."

/obj/item/toy/figure/chemist
	name = "Chemist action figure"
	desc = "The legally dubious Chemist, from Space Life's SS12 figurine collection."
	icon_state = "chemist"
	toysay = "Забери свои таблетки!"

/obj/item/toy/figure/clown
	name = "Clown action figure"
	desc = "The mischevious Clown, from Space Life's SS12 figurine collection."
	icon_state = "clown"
	toysay = "Хонк!"

/obj/item/toy/figure/ian
	name = "Ian action figure"
	desc = "The adorable corgi, from Space Life's SS12 figurine collection."
	icon_state = "ian"
	toysay = "Гав!"

/obj/item/toy/figure/detective
	name = "Detective action figure"
	desc = "The clever detective, from Space Life's SS12 figurine collection."
	icon_state = "detective"
	toysay = "На этом шлюзе есть следы серого комбинезона и изоляционных перчаток."

/obj/item/toy/figure/dsquad
	name = "Death Squad Officer action figure"
	desc = "It's a member of the DeathSquad, a TV drama where loose-cannon ERT officers face up against the threats of the galaxy! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "dsquad"
	toysay = "Уничтожить все угрозы!"

/obj/item/toy/figure/engineer
	name = "Engineer action figure"
	desc = "The frantic engineer, from Space Life's SS12 figurine collection."
	icon_state = "engineer"
	toysay = "О боже, сингулярность сбежала!"

/obj/item/toy/figure/geneticist
	name = "Geneticist action figure"
	desc = "The balding geneticist, from Space Life's SS12 figurine collection."
	icon_state = "geneticist"
	toysay = "Я не квалифицирован для этой работы."

/obj/item/toy/figure/hop
	name = "Head of Personnel action figure"
	desc = "The officious Head of Personnel, from Space Life's SS12 figurine collection."
	icon_state = "hop"
	toysay = "Бумаги, пожалуйста!"

/obj/item/toy/figure/hos
	name = "Head of Security action figure"
	desc = "The bloodlust-filled Head of Security, from Space Life's SS12 figurine collection."
	icon_state = "hos"
	toysay = "Космозакон? Чего?"

/obj/item/toy/figure/qm
	name = "Quartermaster action figure"
	desc = "The nationalistic Quartermaster, from Space Life's SS12 figurine collection."
	icon_state = "qm"
	toysay = "Хайль Каргония!"

/obj/item/toy/figure/janitor
	name = "Janitor action figure"
	desc = "The water-using Janitor, from Space Life's SS12 figurine collection."
	icon_state = "janitor"
	toysay = "Читай знаки, идиот."

/obj/item/toy/figure/lawyer
	name = "Lawyer action figure"
	desc = "The unappreciated Lawyer, from Space Life's SS12 figurine collection."
	icon_state = "lawyer"
	toysay = "СРП говорит, что они виновны! Взлом — доказательство того, что они Враги Корпорации!"

/obj/item/toy/figure/librarian
	name = "Librarian action figure"
	desc = "The quiet Librarian, from Space Life's SS12 figurine collection."
	icon_state = "librarian"
	toysay = "Однажды, в..."

/obj/item/toy/figure/md
	name = "Medical Doctor action figure"
	desc = "The stressed-out doctor, from Space Life's SS12 figurine collection."
	icon_state = "md"
	toysay = "Пациент уже мёртв!"

/obj/item/toy/figure/mime
	name = "Mime action figure"
	desc = "... from Space Life's SS12 figurine collection."
	icon_state = "mime"
	toysay = "..."

/obj/item/toy/figure/miner
	name = "Shaft Miner action figure"
	desc = "The gun-toting Shaft Miner, from Space Life's SS12 figurine collection."
	icon_state = "miner"
	toysay = "О боже, оно жрёт мои кишки!"

/obj/item/toy/figure/ninja
	name = "Ninja action figure"
	desc = "It's the mysterious ninja! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "ninja"
	toysay = "О боже! Хватит стрелять, я косплеер!"

/obj/item/toy/figure/wizard
	name = "Wizard action figure"
	desc = "It's the deadly, spell-slinging wizard! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "wizard"
	toysay = "Ei Nath!"

/obj/item/toy/figure/rd
	name = "Research Director action figure"
	desc = "The ambitious RD, from Space Life's SS12 figurine collection."
	icon_state = "rd"
	toysay = "Уничтожить всех боргов!"

/obj/item/toy/figure/roboticist
	name = "Roboticist action figure"
	desc = "The skillful Roboticist, from Space Life's SS12 figurine collection."
	icon_state = "roboticist"
	toysay = "Он сам просил боргизацию!"

/obj/item/toy/figure/scientist
	name = "Scientist action figure"
	desc = "The mad Scientist, from Space Life's SS12 figurine collection."
	icon_state = "scientist"
	toysay = "Кто-то другой сделал эти бомбы!"

/obj/item/toy/figure/syndie
	name = "Nuclear Operative action figure"
	desc = "It's the red-suited Nuclear Operative! It's from Space Life's special edition SS12 figurine collection."
	icon_state = "syndie"
	toysay = "Заберите этот ёбанный диск!"

/obj/item/toy/figure/secofficer
	name = "Security Officer action figure"
	desc = "The power-tripping Security Officer, from Space Life's SS12 figurine collection."
	icon_state = "secofficer"
	toysay = "Я есть закон!"

/obj/item/toy/figure/virologist
	name = "Virologist action figure"
	desc = "The pandemic-starting Virologist, from Space Life's SS12 figurine collection."
	icon_state = "virologist"
	toysay = "Это не мой вирус!"

/obj/item/toy/figure/warden
	name = "Warden action figure"
	desc = "The amnesiac Warden, from Space Life's SS12 figurine collection."
	icon_state = "warden"
	toysay = "Казнить за взлом!"

/obj/item/toy/figure/magistrate
	name = "Magistrate action figure"
	desc = "The relevant magistrate, from Space Life's SS12 figurine collection."
	icon_state = "magistrate"
	toysay = "Казнить или не казнить — вот в чём вопрос."
