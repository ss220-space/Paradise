// MARK: Base
/obj/item/clothing/accessory/head_strip
	abstract_type = /obj/item/clothing/accessory/head_strip
	icon_state = null
	item_state = null
	gender = FEMALE
	actions_types = list(/datum/action/item_action/show_head_strip)
	/// Name in Russian of the accessory without quotes, just the keyword
	var/strip_ru_name = null
	/// Cooldown for displaying accessory
	COOLDOWN_DECLARE(fluff_cooldown)

/obj/item/clothing/accessory/head_strip/Initialize(mapload)
	. = ..()
	var/bubble = get_bubble_override()
	if(bubble)
		AddComponent(/datum/component/bubble_icon_override, bubble, BUBBLE_ICON_PRIORITY_ACCESSORY)

/// Returns the speech bubble icon for this patch. Overridden in subtypes.
/obj/item/clothing/accessory/head_strip/proc/get_bubble_override()
	return

/obj/item/clothing/accessory/head_strip/attack_self(mob/user)
	. = ..()
	if(.)
		return
	fluff_attack_self_action(user)

/obj/item/clothing/accessory/head_strip/proc/fluff_attack_self_action(mob/user)
	SHOULD_CALL_PARENT(TRUE)

	if(!COOLDOWN_FINISHED(src, fluff_cooldown))
		return

	user.balloon_alert_to_viewers("показыва[PLUR_ET_YUT(user)] [declent_ru(ACCUSATIVE)]", "[declent_ru(NOMINATIVE)]")
	COOLDOWN_START(src, fluff_cooldown, 1 SECONDS)

/obj/item/clothing/accessory/head_strip/uniform_check(mob/living/carbon/human/target, mob/living/user, obj/item/clothing/under/uniform)
	. = ..()
	if(. && locate(/obj/item/clothing/accessory/head_strip, uniform.contents))
		return FALSE

/obj/item/clothing/accessory/head_strip/get_ru_names()
	if(!strip_ru_name)
		CRASH("head strip does not have a 'strip_ru_name'")
	var/name_in_quotes = "\"[strip_ru_name]\""
	return list(
		NOMINATIVE = "нашивка [name_in_quotes]",
		GENITIVE = "нашивки [name_in_quotes]",
		DATIVE = "нашивке [name_in_quotes]",
		ACCUSATIVE = "нашивку [name_in_quotes]",
		INSTRUMENTAL = "нашивкой [name_in_quotes]",
		PREPOSITIONAL = "нашивке [name_in_quotes]",
	)

// MARK: Subtypes
/obj/item/clothing/accessory/head_strip/captain
	name = "Captain's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с позолотой, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый золотыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся управление станцией."
	icon_state = "capstrip"
	item_state = "capstrip"
	strip_ru_name = JOB_TITLE_RU_CAPTAIN

/obj/item/clothing/accessory/head_strip/captain/get_bubble_override()
	return "CAP"

/obj/item/clothing/accessory/head_strip/rd
	name = "Research Director's strip"
	desc = "Плотно сшитая круглая нашивка из фиолетового бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый розоватыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи в области исследований."
	icon_state = "rdstrip"
	item_state = "rdstrip"
	strip_ru_name = JOB_TITLE_RU_RD

/obj/item/clothing/accessory/head_strip/rd/get_bubble_override()
	return "RD"

/obj/item/clothing/accessory/head_strip/ce
	name = "Chief Engineer's strip"
	desc = "Плотно сшитая круглая нашивка из серо-желтого бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый голубыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи в области инженерии."
	icon_state = "cestrip"
	item_state = "cestrip"
	strip_ru_name = JOB_TITLE_RU_CHIEF_ENGINEER

/obj/item/clothing/accessory/head_strip/ce/get_bubble_override()
	return "CE"

/obj/item/clothing/accessory/head_strip/t4ce
	name = "Grand Chief Engineer's strip"
	desc = "Плотно сшитая круглая нашивка из серого бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый желтыми металлическими нитями. Если присмотреться, можно заметить проходящее по нитям электричество и небольшие искорки."
	icon_state = "t4cestrip"
	item_state = "t4cestrip"
	strip_ru_name = "Супер" + JOB_TITLE_RU_CHIEF_ENGINEER

/obj/item/clothing/accessory/head_strip/t4ce/get_bubble_override()
	return "T4CE"

/obj/item/clothing/accessory/head_strip/cmo
	name = "Chief Medical Officer's strip"
	desc = "Плотно сшитая круглая нашивка из голубого бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый белыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи в области медицины."
	icon_state = "cmostrip"
	item_state = "cmostrip"
	strip_ru_name = JOB_TITLE_RU_CMO

/obj/item/clothing/accessory/head_strip/cmo/get_bubble_override()
	return "CMO"

/obj/item/clothing/accessory/head_strip/hop
	name = "Head of Personnel's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с красной окантовкой, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый белыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся управление персоналом."
	icon_state = "hopstrip"
	item_state = "hopstrip"
	strip_ru_name = JOB_TITLE_RU_HOP

/obj/item/clothing/accessory/head_strip/hop/get_bubble_override()
	return "HOP"

/obj/item/clothing/accessory/head_strip/hos
	name = "Head of Security's strip"
	desc = "Плотно сшитая круглая нашивка из черно-красного бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый бело-красными металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи при службе на корпорацию."
	icon_state = "hosstrip"
	item_state = "hosstrip"
	strip_ru_name = JOB_TITLE_RU_HOS

/obj/item/clothing/accessory/head_strip/hos/get_bubble_override()
	return "HOS"

/obj/item/clothing/accessory/head_strip/qm
	name = "Quatermaster's strip"
	desc = "Плотно сшитая круглая нашивка из коричневого бархата, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый белыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи в области логистики и погрузки."
	icon_state = "qmstrip"
	item_state = "qmstrip"
	strip_ru_name = JOB_TITLE_RU_QUARTERMASTER

/obj/item/clothing/accessory/head_strip/qm/get_bubble_override()
	return "QM"

/obj/item/clothing/accessory/head_strip/bs
	name = "Blueshield's strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с темно-синей окантовкой, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый белыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся успехи при службе на корпорацию."
	icon_state = "bsstrip"
	item_state = "bsstrip"
	strip_ru_name = JOB_TITLE_RU_BLUESHIELD

/obj/item/clothing/accessory/head_strip/bs/get_bubble_override()
	return "BS"

/obj/item/clothing/accessory/head_strip/ntr
	name = "Nanotrasen Representative's strip"
	desc = "Плотно сшитая круглая нашивка из чёрного бархата с золотистой окантовкой, по центру красуется логотип корпорации \"Нанотрейзен\" прошитый белыми металлическими нитями. Награда выданная Центральным командованием за выдающиеся заслуги при службе на корпорацию."
	icon_state = "ntrstrip"
	item_state = "ntrstrip"
	strip_ru_name = JOB_TITLE_RU_REPRESENTATIVE

/obj/item/clothing/accessory/head_strip/ntr/get_bubble_override()
	return "NTR"

/obj/item/clothing/accessory/head_strip/syndicate
	name = "Syndicate strip"
	desc = "Круглый металлический значок тёмно-красного цвета с расположенной в центре ярко-зелёной буквой \"S\" с бордовым штырём."
	icon_state = "syndistrip"
	item_state = "syndistrip"
	strip_ru_name = "Синдикат"

/obj/item/clothing/accessory/head_strip/syndicate/get_bubble_override()
	return "Syndie"

/obj/item/clothing/accessory/head_strip/comrad
	name = "Comrade patch"
	desc = "Грубый прямоугольный шеврон цвета хаки с бело-золотыми вставками по бокам и вышитой красными нитями аббревиатурой \"СССП\" в центре: стандартная нашивка, выдаваемая добровольцам."
	icon_state = "patch_sssp"
	item_state = "patch_sssp"
	strip_ru_name = "Товарищ"

/obj/item/clothing/accessory/head_strip/comrad/get_bubble_override()
	return "comrad"

/obj/item/clothing/accessory/head_strip/federal
	name = "Federal strip"
	desc = "Плотно сшитая круглая нашивка из синего бархата с белой окантовкой и золотыми вставками. По центру красуется логотип ТСФ, прошитый бело-золотыми металлическими нитями: стандартный знак отличия для граждан ТСФ."
	icon_state = "stripe_federal"
	item_state = "stripe_federal"
	strip_ru_name = "Федерал"

/obj/item/clothing/accessory/head_strip/federal/get_bubble_override()
	return "federal"

/obj/item/clothing/accessory/head_strip/greytide
	name = "GreyTide strip"
	desc = "Плотно сшитая круглая нашивка серого цвета с расположенным в центре противогазом."
	icon_state = "greytstrip"
	item_state = "greytstrip"
	strip_ru_name = "GreyTide"

/obj/item/clothing/accessory/head_strip/greytide/get_bubble_override()
	return "greyt"

/obj/item/clothing/accessory/head_strip/lawyers_badge
	name = "attorney's badge"
	desc = "Наполняет вас убежденностью в СПРАВЕДЛИВОСТЬ. Юристы стремятся демонстрировать её всем, кого встречают."
	icon_state = "lawyerbadge"
	item_state = "lawyerbadge"
	gender = MALE
	strip_ru_name = JOB_TITLE_RU_LAWYER

/obj/item/clothing/accessory/head_strip/lawyers_badge/get_bubble_override()
	return "lawyer"

/obj/item/clothing/accessory/head_strip/lawyers_badge/fluff_attack_self_action(mob/user)
	. = ..()
	if(prob(1))
		user.say("Показания противоречат доказательствам!")
	user.point_at(src)

/obj/item/clothing/accessory/head_strip/cheese_badge
	name = "great fellow's badge"
	desc = "Плотно сшитая круглая нашивка из желто-оранжевого бархата, по центру красуется то ли корона, то ли головка сыра. Слегка отдает запахом Монтерей Джека."
	icon_state = "cheesebadge"
	item_state = "cheesebadge"
	gender = MALE
	strip_ru_name = "Сыр"

/obj/item/clothing/accessory/head_strip/cheese_badge/get_bubble_override()
	return "cheese"

/obj/item/clothing/accessory/head_strip/cheese_badge/fluff_attack_self_action(mob/user)
	. = ..()
	if(prob(1))
		user.say("СЫЫ-Ы-Ы-Ы-Ы-РР!")

/obj/item/clothing/accessory/head_strip/clown
	name = "clown's strip"
	desc = "Плотно сшитая круглая нашивка с изображением клоуна. Идеально подойдет для совершения военных преступлений, ведь это не военное преступление, если тебе было весело!"
	icon_state = "clownstrip"
	item_state = "clownstrip"
	strip_ru_name = JOB_TITLE_RU_CLOWN

/obj/item/clothing/accessory/head_strip/clown/get_bubble_override()
	return "clown"

/obj/item/clothing/accessory/head_strip/deathsquad
	name = "deathsquad's strip"
	desc = "Плотно сшитая круглая нашивка из чёрного бархата с красными вставками. По центру красуется шлем бойца Эскадрона Смерти, которые являются \[ОТРЕДАКТИРОВАНО\]."
	icon_state = "deathsquadstrip"
	item_state = "deathsquadstrip"
	strip_ru_name = "Эскадрон Смерти"

/obj/item/clothing/accessory/head_strip/deathsquad/get_bubble_override()
	return "deathsquad"

/obj/item/clothing/accessory/head_strip/triforce
	name = "triforce strip"
	desc = "Круглая нашивка из твёрдого пластика жёлтого цвета с чёрной окантовкой, по центру расположены три светящихся треугольника голубого цвета. Треугольники явно расположены неправильно."
	icon_state = "triforcestrip"
	item_state = "triforcestrip"
	strip_ru_name = "Трифорс"

/obj/item/clothing/accessory/head_strip/triforce/get_bubble_override()
	return "triforce"

/obj/item/clothing/accessory/head_strip/black_cat
	name = "black cat strip"
	desc = "Плотно сшитая нашивка из чёрного бархата в форме головы кота, по центру прошиты глаза и мордочка, выглядит замурчательно."
	icon_state = "blackcatstrip"
	item_state = "blackcatstrip"
	strip_ru_name = "Чёрный кот"

/obj/item/clothing/accessory/head_strip/black_cat/get_bubble_override()
	return "blackcat"

/obj/item/clothing/accessory/head_strip/fox
	name = "fox strip"
	desc = "Плотно сшитая нашивка из оранжевых нитей в форме головы лисы, в центре прошиты глаза и носик, выглядит достаточно мило."
	icon_state = "foxstrip"
	item_state = "foxstrip"
	strip_ru_name = "Лиса"

/obj/item/clothing/accessory/head_strip/fox/get_bubble_override()
	return "fox"

/obj/item/clothing/accessory/head_strip/frog
	name = "frog strip"
	desc = "Плотно сшитая нашивка из зелёного бархата в форме весёлой лягушки, по центру прошит рот и белый животик. Сделано для истинных почитателей лягушек."
	icon_state = "frogstrip"
	item_state = "frogstrip"
	strip_ru_name = "Лягушка"

/obj/item/clothing/accessory/head_strip/frog/get_bubble_override()
	return "frog"

/obj/item/clothing/accessory/head_strip/whitecatstrip
	name = "white cat strip"
	desc = "Плотно сшитая нашивка из белого бархата в форме головы кота, по центру прошиты глаза и мордочка. Выглядит мило."
	icon_state = "whitecatstrip"
	item_state = "whitecatstrip"
	strip_ru_name = "Белый кот"

/obj/item/clothing/accessory/head_strip/whitecatstrip/get_bubble_override()
	return "whitecat"

/obj/item/clothing/accessory/head_strip/orangecatstrip
	name = "orange cat strip"
	desc = "Плотно сшитая нашивка из нитей трех цветов в форме головы кота, по центру прошиты глаза и мордочка. Выглядит очень мило."
	icon_state = "orangecatstrip"
	item_state = "orangecatstrip"
	strip_ru_name = "Трёхцветный кот"

/obj/item/clothing/accessory/head_strip/orangecatstrip/get_bubble_override()
	return "orangecat"

/obj/item/clothing/accessory/head_strip/ratstrip
	name = "rat strip"
	desc = "Плотно сшитая нашивка из серого бархата в форме головы крысы, по центру прошиты глаза и мордочка. Выглядит пи-пи-пи."
	icon_state = "ratstrip"
	item_state = "ratstrip"
	strip_ru_name = "Крыска"

/obj/item/clothing/accessory/head_strip/ratstrip/get_bubble_override()
	return "rat"

/obj/item/clothing/accessory/head_strip/devilstrip
	name = "devil strip"
	desc = "Плотно сшитая нашивка из красного бархата в форме головы дьявола, сверху красуются рога, а по центру два зловещих желтых глаза. От нашивки исходит инфернальное тепло."
	icon_state = "devilstrip"
	item_state = "devilstrip"
	strip_ru_name = "Дьявол"

/obj/item/clothing/accessory/head_strip/devilstrip/get_bubble_override()
	return "devil"
