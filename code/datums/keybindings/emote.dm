/datum/keybinding/emote
	category = KB_CATEGORY_EMOTE_GENERIC
	var/datum/emote/linked_emote


/datum/keybinding/emote/down(client/user)
	. = ..()
	if(.)
		return .
	return user.mob.emote(initial(linked_emote.key), intentional = TRUE)


/**
 * Generic
 */
/datum/keybinding/emote/flip
	linked_emote = /datum/emote/flip
	name = "Кувырок"

/datum/keybinding/emote/spin
	linked_emote = /datum/emote/spin
	name = "Крутиться"

/datum/keybinding/emote/blush
	linked_emote = /datum/emote/living/blush
	name = "Краснеть"

/datum/keybinding/emote/bow
	linked_emote = /datum/emote/living/bow
	name = "Поклониться"

/datum/keybinding/emote/burp
	linked_emote = /datum/emote/living/burp
	name = "Рыгнуть"

/datum/keybinding/emote/choke
	linked_emote = /datum/emote/living/choke
	name = "Подавиться"

/datum/keybinding/emote/collapse
	linked_emote = /datum/emote/living/collapse
	name = "Рухнуть"

/datum/keybinding/emote/dance
	linked_emote = /datum/emote/living/dance
	name = "Танцевать"

/datum/keybinding/emote/jump
	linked_emote = /datum/emote/living/jump
	name = "Прыгать"

/datum/keybinding/emote/deathgasp //commented in emote_verbs.dm
	linked_emote = /datum/emote/living/deathgasp
	name = "Предсмертный вздох"

/datum/keybinding/emote/gag
	linked_emote = /datum/emote/living/gag
	name = "Выворачивать наизнанку"

/datum/keybinding/emote/drool
	linked_emote = /datum/emote/living/drool
	name = "Нести чепуху"

/datum/keybinding/emote/quiver
	linked_emote = /datum/emote/living/quiver
	name = "Трепетать"

/datum/keybinding/emote/frown
	linked_emote = /datum/emote/living/frown
	name = "Хмуриться"

/datum/keybinding/emote/look
	linked_emote = /datum/emote/living/look
	name = "Смотреть"

/datum/keybinding/emote/glare
	linked_emote = /datum/emote/living/glare
	name = "Свирепо смотреть"

/datum/keybinding/emote/bshake
	linked_emote = /datum/emote/living/bshake
	name = "Трястись"

/datum/keybinding/emote/grimace
	linked_emote = /datum/emote/living/grimace
	name = "Гримасничать"

/datum/keybinding/emote/shudder
	linked_emote = /datum/emote/living/shudder
	name = "Содрогнуться"

/datum/keybinding/emote/pout
	linked_emote = /datum/emote/living/pout
	name = "Надуть губы"

/datum/keybinding/emote/point
	linked_emote = /datum/emote/living/point
	name = "Указать пальцем"

/datum/keybinding/emote/scream
	linked_emote = /datum/emote/living/scream
	name = "Кричать"

/datum/keybinding/emote/shake
	linked_emote = /datum/emote/living/shake
	name = "Трясти головой"

/datum/keybinding/emote/shiver
	linked_emote = /datum/emote/living/shiver
	name = "Дрожать"

/datum/keybinding/emote/sigh
	linked_emote = /datum/emote/living/sigh
	name = "Вздохнуть"

/datum/keybinding/emote/sigh/happy
	linked_emote = /datum/emote/living/sigh/happy
	name = "Удовлетворённо вздохнуть"

/datum/keybinding/emote/smile
	linked_emote = /datum/emote/living/smile
	name = "Улыбнуться"

/datum/keybinding/emote/wsmile
	linked_emote = /datum/emote/living/wsmile
	name = "Слабо улыбнуться"

/datum/keybinding/emote/smug
	linked_emote = /datum/emote/living/smug
	name = "Ухмыльнуться"

/datum/keybinding/emote/grin
	linked_emote = /datum/emote/living/grin
	name = "Оскалиться в улыбке"

/datum/keybinding/emote/sniff
	linked_emote = /datum/emote/living/sniff
	name = "Нюхать"

/datum/keybinding/emote/sulk
	linked_emote = /datum/emote/living/sulk
	name = "Дуться"

/datum/keybinding/emote/stare
	linked_emote = /datum/emote/living/stare
	name = "Пялиться"

/datum/keybinding/emote/tremble
	linked_emote = /datum/emote/living/tremble
	name = "Дрожать в ужасе"

/datum/keybinding/emote/twitch
	linked_emote = /datum/emote/living/twitch
	name = "Дёргаться (сильно)"

/datum/keybinding/emote/twitch_s
	linked_emote = /datum/emote/living/twitch_s
	name = "Дёргаться"

/datum/keybinding/emote/strech
	linked_emote = /datum/emote/living/strech
	name = "Размять конечности"

/datum/keybinding/emote/sway
	linked_emote = /datum/emote/living/sway
	name = "Кружиться"

/datum/keybinding/emote/whimper
	linked_emote = /datum/emote/living/whimper
	name = "Хныкать"

/datum/keybinding/emote/tilt
	linked_emote = /datum/emote/living/tilt
	name = "Наклонить голову на бок"

/datum/keybinding/emote/swear
	linked_emote = /datum/emote/living/swear
	name = "Ругаться"

/datum/keybinding/emote/snore
	linked_emote = /datum/emote/living/snore
	name = "Храпеть"

/**
 * Carbon
 */
/datum/keybinding/emote/carbon
	category = KB_CATEGORY_EMOTE_CARBON

/datum/keybinding/emote/carbon/can_use(client/user)
	return iscarbon(user.mob)

/datum/keybinding/emote/carbon/cross
	linked_emote = /datum/emote/living/carbon/cross
	name = "Скрестить руки"

/datum/keybinding/emote/carbon/blink
	linked_emote = /datum/emote/living/carbon/blink
	name = "Моргать"

/datum/keybinding/emote/carbon/blink_r
	linked_emote = /datum/emote/living/carbon/blink_r
	name = "Моргать (быстро)"

/datum/keybinding/emote/carbon/scowl
	linked_emote = /datum/emote/living/carbon/scowl
	name = "Мрачно смотреть"

/datum/keybinding/emote/carbon/chuckle
	linked_emote = /datum/emote/living/carbon/chuckle
	name = "Усмехнуться"

/datum/keybinding/emote/carbon/gurgle
	linked_emote = /datum/emote/living/carbon/gurgle
	name = "Булькать"

/datum/keybinding/emote/carbon/inhale
	linked_emote = /datum/emote/living/carbon/inhale
	name = "Вдохнуть"

/datum/keybinding/emote/carbon/inhale/deep
	linked_emote = /datum/emote/living/carbon/inhale/deep
	name = "Глубоко вдохнуть"

/datum/keybinding/emote/carbon/exhale
	linked_emote = /datum/emote/living/carbon/exhale
	name = "Выдохнуть"

/datum/keybinding/emote/carbon/groan
	linked_emote = /datum/emote/living/carbon/groan
	name = "Болезненно вздохнуть"

/datum/keybinding/emote/carbon/kiss
	linked_emote = /datum/emote/living/carbon/kiss
	name = "Отправить воздушный поцелуй"

/datum/keybinding/emote/carbon/cough
	linked_emote = /datum/emote/living/carbon/cough
	name = "Кашлять"

/datum/keybinding/emote/carbon/moan
	linked_emote = /datum/emote/living/carbon/moan
	name = "Стонать"

/datum/keybinding/emote/carbon/wave
	linked_emote = /datum/emote/living/carbon/wave
	name = "Махать"

/datum/keybinding/emote/carbon/yawn
	linked_emote = /datum/emote/living/carbon/yawn
	name = "Зевать"

/datum/keybinding/emote/carbon/laugh
	linked_emote = /datum/emote/living/carbon/laugh
	name = "Смеяться"

/datum/keybinding/emote/carbon/giggle
	linked_emote = /datum/emote/living/carbon/giggle
	name = "Хихикать"

/datum/keybinding/emote/carbon/faint
	linked_emote = /datum/emote/living/carbon/faint
	name = "Потерять сознание"

/datum/keybinding/emote/carbon/sign
	linked_emote = /datum/emote/living/carbon/sign
	name = "Показать число руками"

/datum/keybinding/emote/carbon/twirl
	linked_emote = /datum/emote/living/carbon/twirl
	name = "Вертеть в руках"


/**
 * Alien
 */
/datum/keybinding/emote/carbon/alien
	category = KB_CATEGORY_EMOTE_ALIEN

/datum/keybinding/emote/carbon/alien/can_use(client/user)
	return isalien(user.mob)

/datum/keybinding/emote/carbon/alien/humanoid/hiss
	linked_emote = /datum/emote/living/carbon/alien/humanoid/hiss
	name = "Шипеть"

/datum/keybinding/emote/carbon/alien/humanoid/gnarl
	linked_emote = /datum/emote/living/carbon/alien/humanoid/gnarl
	name = "Рычать"


/**
 * MMI-brain
 */
/datum/keybinding/emote/carbon/brain
	category = KB_CATEGORY_EMOTE_BRAIN

/datum/keybinding/emote/carbon/brain/can_use(client/user)
	return isbrain(user.mob)

/datum/keybinding/emote/carbon/brain/alarm
	linked_emote = /datum/emote/living/carbon/brain/alarm
	name = "Издать аварийный сигнал"

/datum/keybinding/emote/carbon/brain/alert
	linked_emote = /datum/emote/living/carbon/brain/alert
	name = "Издать тревожный шум"

/datum/keybinding/emote/carbon/brain/notice
	linked_emote = /datum/emote/living/carbon/brain/notice
	name = "Играть громкий мотив"

/datum/keybinding/emote/carbon/brain/flash
	linked_emote = /datum/emote/living/carbon/brain/flash
	name = "Моргать лампочками"

/datum/keybinding/emote/carbon/brain/whistle
	linked_emote = /datum/emote/living/carbon/brain/whistle
	name = "Свистеть"

/datum/keybinding/emote/carbon/brain/beep
	linked_emote = /datum/emote/living/carbon/brain/beep
	name = "Бипать"

/datum/keybinding/emote/carbon/brain/boop
	linked_emote = /datum/emote/living/carbon/brain/boop
	name = "Бупать"


/**
 * Human
 */
/datum/keybinding/emote/carbon/human
	category = KB_CATEGORY_EMOTE_HUMAN

/datum/keybinding/emote/carbon/human/can_use(client/user)
	return ishuman(user.mob)

/datum/keybinding/emote/carbon/human/johnny
	linked_emote = /datum/emote/living/carbon/human/johnny
	name = "Выпустить Джонни"

/datum/keybinding/emote/carbon/human/airguitar
	linked_emote = /datum/emote/living/carbon/human/airguitar
	name = "Запил на гитаре"

/datum/keybinding/emote/carbon/human/cry
	linked_emote = /datum/emote/living/carbon/human/cry
	name = "Плакать"

/datum/keybinding/emote/carbon/human/clap
	linked_emote = /datum/emote/living/carbon/human/clap
	name = "Хлопать"

/datum/keybinding/emote/carbon/human/whistle
	linked_emote = /datum/emote/living/carbon/human/whistle
	name = "Свистеть"

/datum/keybinding/emote/carbon/human/eyebrow
	linked_emote = /datum/emote/living/carbon/human/eyebrow
	name = "Приподнять бровь"

/datum/keybinding/emote/carbon/human/grumble
	linked_emote = /datum/emote/living/carbon/human/grumble
	name = "Ворчать"

/datum/keybinding/emote/carbon/human/hug
	linked_emote = /datum/emote/living/carbon/human/hug
	name = "Обнимать"

/datum/keybinding/emote/carbon/human/mumble
	linked_emote = /datum/emote/living/carbon/human/mumble
	name = "Бормотать"

/datum/keybinding/emote/carbon/human/nod
	linked_emote = /datum/emote/living/carbon/human/nod
	name = "Кивнуть"

/datum/keybinding/emote/carbon/human/gasp
	linked_emote = /datum/emote/living/carbon/human/gasp
	name = "Задыхаться"

/datum/keybinding/emote/carbon/human/shake
	linked_emote = /datum/emote/living/carbon/human/shake
	name = "Трясти головой"

/datum/keybinding/emote/carbon/human/pale
	linked_emote = /datum/emote/living/carbon/human/pale
	name = "Бледнеть"

/datum/keybinding/emote/carbon/human/raise
	linked_emote = /datum/emote/living/carbon/human/raise
	name = "Поднять руку"

/datum/keybinding/emote/carbon/human/salute
	linked_emote = /datum/emote/living/carbon/human/salute
	name = "Салютовать"

/datum/keybinding/emote/carbon/human/shrug
	linked_emote = /datum/emote/living/carbon/human/shrug
	name = "Пожать плечами"

/datum/keybinding/emote/carbon/human/snuffle
	linked_emote = /datum/emote/living/carbon/human/snuffle
	name = "Шмыгать носом"

/datum/keybinding/emote/carbon/human/sneeze
	linked_emote = /datum/emote/living/carbon/human/sneeze
	name = "Чихнуть"

/datum/keybinding/emote/carbon/human/slap
	linked_emote = /datum/emote/living/carbon/human/slap
	name = "Шлёпнуть"

/datum/keybinding/emote/carbon/human/wince
	linked_emote = /datum/emote/living/carbon/human/wince
	name = "Морщиться"

/datum/keybinding/emote/carbon/human/wink
	linked_emote = /datum/emote/living/carbon/human/wink
	name = "Подмигнуть"

/datum/keybinding/emote/carbon/human/squint
	linked_emote = /datum/emote/living/carbon/human/squint
	name = "Прищуриться"

/datum/keybinding/emote/carbon/human/facepalm
	linked_emote = /datum/emote/living/carbon/human/facepalm
	name = "Фэйспалм"

/datum/keybinding/emote/carbon/human/highfive
	linked_emote = /datum/emote/living/carbon/human/highfive
	name = "Дать пять"

/datum/keybinding/emote/carbon/human/handshake
	linked_emote = /datum/emote/living/carbon/human/highfive/handshake
	name = "Пожать руку"

/datum/keybinding/emote/carbon/human/dap
	linked_emote = /datum/emote/living/carbon/human/highfive/dap
	name = "Брататься"

/datum/keybinding/emote/carbon/human/snap
	linked_emote = /datum/emote/living/carbon/human/snap
	name = "Щёлкнуть пальцами"

/datum/keybinding/emote/carbon/human/hem
	linked_emote = /datum/emote/living/carbon/human/hem
	name = "Хмыкнуть"

/datum/keybinding/emote/carbon/human/fart
	linked_emote = /datum/emote/living/carbon/human/fart
	name = "Пёрнуть"

/datum/keybinding/emote/carbon/human/scratch
	linked_emote = /datum/emote/living/carbon/human/scratch
	name = "Почесаться"

/datum/keybinding/emote/carbon/human/signal
	linked_emote = /datum/emote/living/carbon/sign/signal
	name = "Показать число пальцами"


/**
 * Species specific
 */
/datum/keybinding/emote/carbon/human/wag_start
	linked_emote = /datum/emote/living/carbon/human/rattle
	name = "Греметь костями (плазмамен/скелет)"

/datum/keybinding/emote/carbon/human/wag_start
	linked_emote = /datum/emote/living/carbon/human/wag
	name = "Начать махать хвостом"

/datum/keybinding/emote/carbon/human/wag_stop
	linked_emote = /datum/emote/living/carbon/human/wag/stop
	name = "Перестать махать хвостом"


/**
 * Monke
 */
/datum/keybinding/emote/carbon/human/monkey/screech
	linked_emote = /datum/emote/living/carbon/human/scream/screech
	name = "Визг (мартышки)"

/datum/keybinding/emote/carbon/human/monkey/roar
	linked_emote = /datum/emote/living/carbon/human/scream/screech/roar
	name = "Рычать и показывать зубы (мартышки)"

/datum/keybinding/emote/carbon/human/monkey/roll
	linked_emote = /datum/emote/living/carbon/human/monkey/roll
	name = "Крутиться (мартышки)"


/**
 * Moth
 */
/datum/keybinding/emote/carbon/human/moth/flap
	linked_emote = /datum/emote/living/carbon/human/moth/flap
	name = "Махать крыльями (нианы)"

/datum/keybinding/emote/carbon/human/moth/flap/angry
	linked_emote = /datum/emote/living/carbon/human/moth/flap/angry
	name = "Агрессивно махать крыльями (нианы)"

/datum/keybinding/emote/carbon/human/moth/flutter
	linked_emote = /datum/emote/living/carbon/human/moth/flutter
	name = "Расправить крылья (нианы)"


/**
 * Vox
 */
/datum/keybinding/emote/carbon/human/vox/quill
	linked_emote = /datum/emote/living/carbon/human/vox/quill
	name = "Шуршать перьями (воксы)"


/**
 * Skrell
 */
/datum/keybinding/emote/carbon/human/skrell/warble
	linked_emote = /datum/emote/living/carbon/human/skrell/warble
	name = "Трель (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/warble_sad
	linked_emote = /datum/emote/living/carbon/human/skrell/warble/sad
	name = "Трель грустная (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/warble_joyfull
	linked_emote = /datum/emote/living/carbon/human/skrell/warble/joyfull
	name = "Трель радостная (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/croak
	linked_emote = /datum/emote/living/carbon/human/skrell/croak
	name = "Кваканье (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/discontent
	linked_emote = /datum/emote/living/carbon/human/skrell/discontent
	name = "Недовольство (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/relax
	linked_emote = /datum/emote/living/carbon/human/skrell/relax
	name = "Расслабиться (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/excitement
	linked_emote = /datum/emote/living/carbon/human/skrell/excitement
	name = "Возбуждение (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/confusion
	linked_emote = /datum/emote/living/carbon/human/skrell/confusion
	name = "Замешательство (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/understand
	linked_emote = /datum/emote/living/carbon/human/skrell/understand
	name = "Понимание (скреллы)"

/datum/keybinding/emote/carbon/human/skrell/smile
	linked_emote = /datum/emote/living/carbon/human/skrell/smile
	name = "Улыбка (скреллы)"


/**
 * Kidan
 */
/datum/keybinding/emote/carbon/human/kidan/clack
	linked_emote = /datum/emote/living/carbon/human/kidan/clack
	name = "Щёлкать мандибулами (киданы)"

/datum/keybinding/emote/carbon/human/kidan/click
	linked_emote = /datum/emote/living/carbon/human/kidan/clack/click
	name = "Клацать мандибулами (киданы)"

/datum/keybinding/emote/carbon/human/kidan/wiggle
	linked_emote = /datum/emote/living/carbon/human/kidan/wiggle
	name = "Шевелить усиками (киданы)"

/datum/keybinding/emote/carbon/human/kidan/wave_k
	linked_emote = /datum/emote/living/carbon/human/kidan/waves_k
	name = "Взмахнуть усиками (киданы)"


/**
 * Drask
 */
/datum/keybinding/emote/carbon/human/drask/drone
	linked_emote = /datum/emote/living/carbon/human/drask/drask_talk/drone
	name = "Гудеть (драски)"

/datum/keybinding/emote/carbon/human/drask/hum
	linked_emote = /datum/emote/living/carbon/human/drask/drask_talk/hum
	name = "Грохотать (драски)"

/datum/keybinding/emote/carbon/human/drask/rumble
	linked_emote = /datum/emote/living/carbon/human/drask/drask_talk/rumble
	name = "Урчать (драски)"


/**
 * Unathi
 */
/datum/keybinding/emote/carbon/human/unathi/hiss
	linked_emote = /datum/emote/living/carbon/human/unathi/hiss
	name = "Шипеть (унати)"

/datum/keybinding/emote/carbon/human/unathi/threat
	linked_emote = /datum/emote/living/carbon/human/unathi/threat
	name = "Угрожать (унати)"

/datum/keybinding/emote/carbon/human/unathi/rumble
	linked_emote = /datum/emote/living/carbon/human/unathi/rumble
	name = "Урчать (унати)"

/datum/keybinding/emote/carbon/human/unathi/roar
	linked_emote = /datum/emote/living/carbon/human/unathi/roar
	name = "Рычать (унати)"

/datum/keybinding/emote/carbon/human/unathi/whip
	linked_emote = /datum/emote/living/carbon/human/unathi/whip
	name = "Ударить хвостом (унати)"

/datum/keybinding/emote/carbon/human/unathi/whips
	linked_emote = /datum/emote/living/carbon/human/unathi/whip/whip_l
	name = "Хлестать хвостом (унати)"


/**
 * Diona
 */
/datum/keybinding/emote/carbon/human/diona/creak
	linked_emote = /datum/emote/living/carbon/human/diona/creak
	name = "Скрипеть (дионы)"


/**
 * Slimepeople
 */
/datum/keybinding/emote/carbon/human/slime/squish
	linked_emote = /datum/emote/living/carbon/human/slime/squish
	name = "Хлюпать (слаймолюди)"

/datum/keybinding/emote/carbon/human/slime/bubble
	linked_emote = /datum/emote/living/carbon/human/slime/bubble
	name = "Пузыриться (слаймолюди)"

/datum/keybinding/emote/carbon/human/slime/pop
	linked_emote = /datum/emote/living/carbon/human/slime/pop
	name = "Издавать хлопки (слаймолюди)"


/**
 * Vulpkanin
 */
/datum/keybinding/emote/carbon/human/vulpkanin/howl
	linked_emote = /datum/emote/living/carbon/human/vulpkanin/howl
	name = "Выть (вульпы)"

/datum/keybinding/emote/carbon/human/vulpkanin/growl
	linked_emote = /datum/emote/living/carbon/human/vulpkanin/growl
	name = "Рычать (вульпы)"


/**
 * Tajaran
 */
/datum/keybinding/emote/carbon/human/tajaran/hiss
	linked_emote = /datum/emote/living/carbon/human/tajaran/hiss
	name = "Шипеть (таяры)"

/datum/keybinding/emote/carbon/human/tajaran/purr
	linked_emote = /datum/emote/living/carbon/human/tajaran/purr
	name = "Мурчать (таяры)"

/datum/keybinding/emote/carbon/human/tajaran/purrl
	linked_emote = /datum/emote/living/carbon/human/tajaran/purr/purrl
	name = "Мурчать дольше (таяры)"


/**
 * Silicon
 */
/datum/keybinding/emote/silicon
	category = KB_CATEGORY_EMOTE_SILICON

/datum/keybinding/emote/silicon/can_use(client/user)
	return issilicon(user.mob) || isbot(user.mob) || ismachineperson(user.mob)

/datum/keybinding/emote/silicon/scream
	linked_emote = /datum/emote/living/silicon/scream
	name = "Кричать"

/datum/keybinding/emote/silicon/ping
	linked_emote = /datum/emote/living/silicon/ping
	name = "Звенеть"

/datum/keybinding/emote/silicon/buzz
	linked_emote = /datum/emote/living/silicon/buzz
	name = "Жужжать"

/datum/keybinding/emote/silicon/buzz2
	linked_emote = /datum/emote/living/silicon/buzz2
	name = "Жужжать раздражённо"

/datum/keybinding/emote/silicon/beep
	linked_emote = /datum/emote/living/silicon/beep
	name = "Бипать"

/datum/keybinding/emote/silicon/boop
	linked_emote = /datum/emote/living/silicon/boop
	name = "Бупать"

/datum/keybinding/emote/silicon/yes
	linked_emote = /datum/emote/living/silicon/yes
	name = "Утвердительно"

/datum/keybinding/emote/silicon/no
	linked_emote = /datum/emote/living/silicon/no
	name = "Отрицательно"

/datum/keybinding/emote/silicon/law
	linked_emote = /datum/emote/living/silicon/law
	name = "Указать кто здесь закон"

/datum/keybinding/emote/silicon/halt
	linked_emote = /datum/emote/living/silicon/halt
	name = "Приказать немедленно остановиться"


/**
 * Simple Mobs
 */
/datum/keybinding/emote/simple_animal
	category = KB_CATEGORY_EMOTE_ANIMAL

/datum/keybinding/emote/simple_animal/can_use(client/user)
	return isanimal(user.mob)

/datum/keybinding/emote/simple_animal/pet/dog/can_use(client/user)
	return isdog(user.mob)

/datum/keybinding/emote/simple_animal/pet/dog/bark
	linked_emote = /datum/emote/living/simple_animal/pet/dog/bark
	name = "Лаять (пёс)"

/datum/keybinding/emote/simple_animal/pet/dog/yelp
	linked_emote = /datum/emote/living/simple_animal/pet/dog/yelp
	name = "Тявкать (пёс)"

/datum/keybinding/emote/simple_animal/pet/dog/growl
	linked_emote = /datum/emote/living/simple_animal/pet/dog/growl
	name = "Рычать (пёс)"


/datum/keybinding/emote/simple_animal/mouse/can_use(client/user)
	return ismouse(user.mob)

/datum/keybinding/emote/simple_animal/mouse/squeak
	linked_emote = /datum/emote/living/simple_animal/mouse/squeak
	name = "Писк (мышь)"


/datum/keybinding/emote/simple_animal/pet/cat/can_use(client/user)
	return iscat(user.mob)

/datum/keybinding/emote/simple_animal/pet/cat/meow
	linked_emote = /datum/emote/living/simple_animal/pet/cat/meow
	name = "Мяукать (кот)"

/datum/keybinding/emote/simple_animal/pet/cat/hiss
	linked_emote = /datum/emote/living/simple_animal/pet/cat/hiss
	name = "Шипеть (кот)"

/datum/keybinding/emote/simple_animal/pet/cat/purr
	linked_emote = /datum/emote/living/simple_animal/pet/cat/purr
	name = "Мурлыкать (кот)"

/datum/keybinding/emote/simple_animal/pet/cat/sit
	linked_emote = /datum/emote/living/sit/cat
	name = "Сесть/Встать (кот)"


/**
 * Custom
 */
/datum/keybinding/custom
	category = KB_CATEGORY_EMOTE_CUSTOM
	var/default_emote_text = "Введите текст вашей эмоции"
	var/donor_exclusive = FALSE


/datum/keybinding/custom/down(client/user)
	. = ..()
	if(.)
		return .
	if(!user.prefs?.custom_emotes) //Checks the current character save for any custom emotes
		return TRUE

	var/desired_emote = user.prefs.custom_emotes[name] //check the custom emotes list for this keybind name

	if(!desired_emote)
		return TRUE

	user.mob.me_verb(html_decode(desired_emote)) //do the thing!
	return TRUE


/datum/keybinding/custom/can_use(client/user)
	if(donor_exclusive && !((user.donator_level >= 2) || user.holder || user.prefs?.unlock_content)) //is this keybind restricted to donors/byond members/admins, and are you one or not?
		return FALSE
	return isliving(user.mob)


/datum/keybinding/custom/one
	name = "Custom Emote 1"

/datum/keybinding/custom/two
	name = "Custom Emote 2"

/datum/keybinding/custom/three
	name = "Custom Emote 3"

/datum/keybinding/custom/four
	name = "Custom Emote 4"
	donor_exclusive = TRUE

/datum/keybinding/custom/five
	name = "Custom Emote 5"
	donor_exclusive = TRUE

/datum/keybinding/custom/six
	name = "Custom Emote 6"
	donor_exclusive = TRUE

/datum/keybinding/custom/seven
	name = "Custom Emote 7"
	donor_exclusive = TRUE

/datum/keybinding/custom/eight
	name = "Custom Emote 8"
	donor_exclusive = TRUE

/datum/keybinding/custom/nine
	name = "Custom Emote 9"
	donor_exclusive = TRUE

/datum/keybinding/custom/ten
	name = "Custom Emote 10"
	donor_exclusive = TRUE

