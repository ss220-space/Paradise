/datum/keybinding/emote
	category = KB_CATEGORY_EMOTE_GENERIC
	var/linked_emote

/datum/keybinding/emote/can_use(client/C, mob/M)
	return ..() //We don't need custom logic here as emotes handle their own useability

/datum/keybinding/emote/down(client/user)
	. = ..()
	usr.user_triggered_emote(linked_emote)

/datum/keybinding/emote/flip
	linked_emote = "flip"
	name = "Кувырок"

/datum/keybinding/emote/blush
	linked_emote = "blush"
	name = "Краснеть"

/datum/keybinding/emote/bow
	linked_emote ="bow"
	name = "Поклониться"

/datum/keybinding/emote/burp
	linked_emote ="burp"
	name = "Рыгнуть"

/datum/keybinding/emote/choke
	linked_emote ="choke"
	name = "Подавиться"

/datum/keybinding/emote/collapse
	linked_emote ="collapse"
	name = "Рухнуть"

/datum/keybinding/emote/dance
	linked_emote ="dance"
	name = "Танцевать"

/datum/keybinding/emote/jump
	linked_emote ="jump"
	name = "Прыгать"

/*/datum/keybinding/emote/deathgasp
	linked_emote ="deathgasp"
	name = "Deathgasp"
*/
/datum/keybinding/emote/drool
	linked_emote ="drool"
	name = "Нести чепуху"

/datum/keybinding/emote/quiver
	linked_emote ="quiver"
	name = "Трепетать"

/datum/keybinding/emote/frown
	linked_emote ="frown"
	name = "Хмуриться"

/datum/keybinding/emote/glare
	linked_emote ="glare"
	name = "Недовольно смотреть"

/datum/keybinding/emote/grin
	linked_emote ="grin"
	name = "Оскалиться в улыбке"

/datum/keybinding/emote/groan
	linked_emote ="groan"
	name = "Болезненно вздохнуть"

/datum/keybinding/emote/look
	linked_emote ="look"
	name = "Смотреть"

/datum/keybinding/emote/bshake
	linked_emote ="bshake"
	name = "Трястись"

/datum/keybinding/emote/shudder
	linked_emote ="shudder"
	name = "Содрогаться"

/datum/keybinding/emote/point
	linked_emote ="point"
	name = "Указать пальцем"

/datum/keybinding/emote/scream
	linked_emote ="scream"
	name = "Кричать"

/datum/keybinding/emote/shake
	linked_emote ="shake"
	name = "Трясти головой"

/datum/keybinding/emote/shiver
	linked_emote ="shiver"
	name = "Дрожать"

/datum/keybinding/emote/sigh
	linked_emote ="sigh"
	name = "Вздыхать"

/datum/keybinding/emote/smile
	linked_emote ="smile"
	name = "Улыбнуться"

/datum/keybinding/emote/sniff
	linked_emote ="sniff"
	name = "Нюхать"

/datum/keybinding/emote/snore
	linked_emote ="snore"
	name = "Храпеть"

/datum/keybinding/emote/stare
	linked_emote ="stare"
	name = "Пялиться"

/datum/keybinding/emote/tremble
	linked_emote ="tremble"
	name = "Дрожать в ужасе"

/datum/keybinding/emote/twitch
	linked_emote ="twitch"
	name = "Дёргаться (сильно)"

/datum/keybinding/emote/twitch_s
	linked_emote ="twitch_s"
	name = "Дёргаться"

/datum/keybinding/emote/whimper
	linked_emote ="whimper"
	name = "Подмигнуть"

/datum/keybinding/emote/carbon
	category = KB_CATEGORY_EMOTE_CARBON

/datum/keybinding/emote/carbon/can_use(client/C, mob/M)
	return iscarbon(M) && ..()

/datum/keybinding/emote/carbon/blink
	linked_emote ="blink"
	name = "Моргать"

/datum/keybinding/emote/carbon/blink_r
	linked_emote ="blink_r"
	name = "Моргать (быстро)"

/datum/keybinding/emote/carbon/clap
	linked_emote ="clap"
	name = "Хлопать"

/datum/keybinding/emote/carbon/chuckle
	linked_emote ="chuckle"
	name = "Усмехнуться"

/datum/keybinding/emote/carbon/cough
	linked_emote ="cough"
	name = "Кашлять"

/datum/keybinding/emote/carbon/moan
	linked_emote ="moan"
	name = "Стонать"

/datum/keybinding/emote/carbon/giggle
	linked_emote ="giggle"
	name = "Хихикать"

/datum/keybinding/emote/carbon/wave
	linked_emote ="wave"
	name = "Махать"

/datum/keybinding/emote/carbon/yawn
	linked_emote ="yawn"
	name = "Зевать"

/datum/keybinding/emote/carbon/laugh
	linked_emote ="laugh"
	name = "Смеяться"

/datum/keybinding/emote/carbon/faint
	linked_emote ="faint"
	name = "Потерять сознание"

/datum/keybinding/emote/carbon/alien
	category = KB_CATEGORY_EMOTE_ALIEN

/datum/keybinding/emote/carbon/alien/can_use(client/C, mob/M)
	return isalien(M) && ..()

/datum/keybinding/emote/carbon/alien/humanoid/roar
	linked_emote ="roar"
	name = "Рычать"

/datum/keybinding/emote/carbon/alien/humanoid/hiss
	linked_emote ="hiss"
	name = "Шипеть"

//For MMI's brains
/datum/keybinding/emote/carbon/brain
	category = KB_CATEGORY_EMOTE_BRAIN

/datum/keybinding/emote/carbon/brain/can_use(client/C, mob/M)
	return isbrain(M) && ..()

/datum/keybinding/emote/carbon/brain/notice
	linked_emote ="notice"
	name = "Notice"

/datum/keybinding/emote/carbon/brain/flash
	linked_emote ="flash"
	name = "Flash"

/datum/keybinding/emote/carbon/brain/whistle
	linked_emote ="whistle"
	name = "Whistle"

/datum/keybinding/emote/carbon/brain/beep
	linked_emote ="beep"
	name = "Beep"

/datum/keybinding/emote/carbon/brain/boop
	linked_emote ="boop"
	name = "Boop"

/datum/keybinding/emote/carbon/human
	category = KB_CATEGORY_EMOTE_HUMAN

/datum/keybinding/emote/carbon/human/can_use(client/C, mob/M)
	return ishuman(M) && ..()

/datum/keybinding/emote/carbon/human/airguitar
	linked_emote ="airguitar"
	name = "Запил на гитаре"

/datum/keybinding/emote/carbon/human/cry
	linked_emote ="cry"
	name = "Плакать"

/*/datum/keybinding/emote/carbon/human/dap //закоменчено и в эмоут панели
	linked_emote ="dap
	name = "Dap"
*/
/datum/keybinding/emote/carbon/human/eyebrow
	linked_emote ="eyebrow"
	name = "Приподнять бровь"

/datum/keybinding/emote/carbon/human/grumble
	linked_emote ="grumble"
	name = "Ворчать"

/datum/keybinding/emote/carbon/human/hug
	linked_emote ="hug"
	name = "Обнимать"

/datum/keybinding/emote/carbon/human/mumble
	linked_emote ="mumble"
	name = "Бормотать"

/datum/keybinding/emote/carbon/human/nod
	linked_emote ="nod"
	name = "Кивнуть"

/datum/keybinding/emote/carbon/human/scream
	linked_emote ="scream"
	name = "Кричать"

/datum/keybinding/emote/carbon/human/gasp
	linked_emote ="gasp"
	name = "Задыхаться"

/datum/keybinding/emote/carbon/human/shake
	linked_emote ="shake"
	name = "Трясти головой"

/datum/keybinding/emote/carbon/human/pale
	linked_emote ="pale"
	name = "Бледнеть"

/datum/keybinding/emote/carbon/human/raise
	linked_emote ="raise"
	name = "Поднять руку"

/datum/keybinding/emote/carbon/human/salute
	linked_emote ="salute"
	name = "Салютовать"

/datum/keybinding/emote/carbon/human/shrug
	linked_emote ="shrug"
	name = "Пожать плечами"

/datum/keybinding/emote/carbon/human/sniff
	linked_emote ="sniff"
	name = "Понюхать"

/datum/keybinding/emote/carbon/human/sneeze
	linked_emote ="sneeze"
	name = "Чихнуть"

/datum/keybinding/emote/carbon/human/slap
	linked_emote ="slap"
	name = "Шлёпнуть"

/datum/keybinding/emote/carbon/human/wink
	linked_emote ="wink"
	name = "Подмигнуть"

/datum/keybinding/emote/carbon/human/highfive
	linked_emote ="highfive"
	name = "Дать Пять"

/datum/keybinding/emote/carbon/human/handshake
	linked_emote ="handshake"
	name = "Пожать руку"

/datum/keybinding/emote/carbon/human/snap
	linked_emote ="snap"
	name = "Щёлкнуть пальцами"

/datum/keybinding/emote/carbon/human/fart
	linked_emote ="fart"
	name = "Пёрнуть"

/datum/keybinding/emote/carbon/human/wag
	linked_emote ="wag"
	name = "Махать хвостом"

/datum/keybinding/emote/carbon/human/wag/stop
	linked_emote ="swag"
	name = "Перестать махать хвостом"

/datum/keybinding/emote/carbon/human/scream/screech/roar
	linked_emote ="roar"
	name = "Рычать"

/datum/keybinding/emote/carbon/human/flap
	linked_emote ="flap"
	name = "Махать крыльями"

/datum/keybinding/emote/carbon/human/flap/angry
	linked_emote ="aflap"
	name = "Агрессивно махать крыльями"

/datum/keybinding/emote/carbon/human/quill
	linked_emote ="quill"
	name = "Шуршать перьями"

/datum/keybinding/emote/carbon/human/warble
	linked_emote ="warble"
	name = "Трель"

/datum/keybinding/emote/carbon/human/clack
	linked_emote ="clack"
	name = "Трещать"

/datum/keybinding/emote/carbon/human/clack/click
	linked_emote ="click"
	name = "Щёлкать"

/datum/keybinding/emote/carbon/human/drask_talk/hum
	linked_emote ="hum"
	name = "Гудеть"

/datum/keybinding/emote/carbon/human/hiss
	linked_emote ="hiss"
	name = "Шипеть"

/datum/keybinding/emote/carbon/human/creak
	linked_emote ="creak"
	name = "Скрипеть"

/datum/keybinding/emote/carbon/human/squish
	linked_emote ="squish"
	name = "Хлюпать"

/datum/keybinding/emote/carbon/human/howl
	linked_emote ="howl"
	name = "Выть"

/datum/keybinding/emote/carbon/human/growl
	linked_emote ="growl"
	name = "Рычать"

/datum/keybinding/emote/carbon/human/monkey/scratch
	linked_emote ="scratch"
	name = "Почесаться"

/datum/keybinding/emote/carbon/human/whip
	linked_emote ="whip"
	name = "Ударить хвостом"

/datum/keybinding/emote/carbon/human/whips
	linked_emote ="whips"
	name = "Хлестать хвостом"

/datum/keybinding/emote/silicon
	category = KB_CATEGORY_EMOTE_SILICON

/datum/keybinding/emote/silicon/can_use(client/C, mob/M)
	return (issilicon(M) || ismachineperson(M)) && ..()

/datum/keybinding/emote/silicon/scream
	linked_emote ="scream"
	name = "Кричать"

/datum/keybinding/emote/silicon/ping
	linked_emote ="ping"
	name = "Звенеть"

/datum/keybinding/emote/silicon/buzz
	linked_emote ="buzz"
	name = "Жужжать"

/datum/keybinding/emote/silicon/buzz2
	linked_emote ="buzz2"
	name = "Жужжать раздражённо"

/datum/keybinding/emote/silicon/beep
	linked_emote ="beep"
	name = "Пищать"

/datum/keybinding/emote/silicon/yes
	linked_emote ="yes"
	name = "Утвердительно"

/datum/keybinding/emote/silicon/no
	linked_emote ="no"
	name = "Отрицательно"

/datum/keybinding/emote/simple_animal
	category = KB_CATEGORY_EMOTE_ANIMAL

/datum/keybinding/emote/simple_animal/can_use(client/C, mob/M)
	return isanimal(M) && ..()

/datum/keybinding/emote/simple_animal/pet/dog/bark
	linked_emote ="bark"
	name = "Лаять (пёс)"

/datum/keybinding/emote/simple_animal/pet/dog/yelp
	linked_emote ="yelp"
	name = "Визг (пёс)"

/datum/keybinding/emote/simple_animal/pet/dog/growl
	linked_emote ="growl"
	name = "Рычать (пёс)"

/datum/keybinding/emote/simple_animal/mouse/squeak
	linked_emote ="squeak"
	name = "Squeak (мышь)"

/datum/keybinding/emote/simple_animal/pet/cat/meow
	linked_emote ="meow"
	name = "Мяукать (кот)"

/datum/keybinding/emote/simple_animal/pet/cat/hiss
	linked_emote ="hiss"
	name = "Шипеть (кот)"

/datum/keybinding/emote/simple_animal/pet/cat/purr
	linked_emote ="purr"
	name = "Мурчать (кот)"
