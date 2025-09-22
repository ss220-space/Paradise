## Вступление

Это пошаговый гайд для создания новых модсьютов (тема, скин и модули)

## Тема

Тут всё довольно просто, вы идете [сюда](./mod_theme.dm) и добавляете ваш новый вариант в код. Попробуем создать в качестве примера модсьют психолога. \
Важное замечание - значение "name" у темы модсьюта будет использовано во всех его частях в виде "Шлем модели \"name\" " Так что для примера будет использоваться "Психолог". \
В графе "описание" следует добавить флаф-описание компании производителя и краткое описание свойств и особенностей модсьюта. \
Допустим, наш модсьют будет энергоёмким и с урезанным количеством доступных модулей. Допустим так:

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
```

Для любителей зачитывать описания в общий канал связи следует добавить отдельное расширенное описание для расширенного лора. Помимо этого следует добавить строку, отвечающую за внешний вид модсьюта, которая будет использоваться в dmi-файлах.

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
	extended_desc = "Прототип компании \"Тау Технолоджис\", созданный в сотрудничестве с корпорацией \"Вей-мед\". \
		Костюм был сильно модифицирован на полную экономию энергии, в результате чего общая мощность костюма была \
		значительно снижена, и он практически не способен вместить в себя хоть сколько бы то ни было модулей.
	default_skin = "psychological"
```

Теперь время добавить или изменить для модсьюта параметры, перечисленные и задокументированные в основном .dm файле с темами. Давайте добавим три новых параметра, исходя из нашего лора.

Важные замечания:

- Не забудьте создать новый датум брони следующего вида

```dm
/obj/item/mod/armor/mod_theme_psychological
	armor = list(MELEE = 20, BULLET = 5, LASER = 5, ENERGY = 5, BOMB = 30, BIO = 100, RAD = 100, FIRE = 100, ACID = 100)
```

- Параметр "комплексность" отвечает за количество вставляемых в модсьют модулей. Желательно не менять этот параметр в большую сторону для станционных модсьютов, иначе есть риск получить одежду на все случаи жизни. Модсьюты это в первую очередь компромиссы между модулями и стилями игры.

- Параметр "трата энергии" отвечает за то, как часто пользователю придется сидеть в зарядниках для киборгов. Технически, с учетом батареек из ботаники и бесконечных батареек из ксено, об этом параметре можно в принципе не задумываться в вопросе балансировки.

Итого у нас получилось следующее:

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
	extended_desc = "Прототип компании \"Тау Технолоджис\", созданный в сотрудничестве с корпорацией \"Вей-мед\". \
		Костюм был сильно модифицирован на полную экономию энергии, в результате чего общая мощность костюма была \
		значительно снижена, и он практически не способен вместить в себя хоть сколько бы то ни было модулей.
	default_skin = "psychological"
	armor_type = /datum/armor/mod_theme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
```

Теперь у нас есть базовая тема, однако у нас нет двух важных вещей - скина для модсьюта и самого /obj. Скины и их создание будут обговорены ниже, а объект мы создадим прямо сейчас

```dm
/obj/item/mod/control/pre_equipped/psychological
	theme = /datum/mod_theme/psychological
	initial_modules = list(
		/obj/item/mod/module/storage,
		/obj/item/mod/module/flashlight,
	)
```

В данном случае любой новый модсьют, созданный в РНД, заспавненный через панель или лежащий на карте, будет по умолчанию иметь в себе модуль вместимости и модуль фонарика. Однако сам по себе наш модсьют еще нельзя создать без дополнительного предмета, который мы сейчас добавим. \
Проследуем [сюда](./mod_construction.dm) и добавим следующее:

```dm
/obj/item/mod/construction/armor/psychological
	theme = /datum/mod_theme/psychological
```

Это - одна из деталей, требуемая в процессе создания модсьюта. Она отвечает за то, какую именно тему получит модсьют при строительстве. Вы можете поместить ее в РНД, добавить как лут в технические туннели или торговцам или просто оставить в щитспавне. Это делается в соотвествующих .dm файлах. Теперь, когда наш костюм почти завершён, осталось разобраться со скином.

## Скин модсьюта

У нас есть готовый модсьют и тема для него, теперь осталось разобраться, как добавить новый скин. Начнем по порядку.

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
	extended_desc = "Прототип компании \"Тау Технолоджис\", созданный в сотрудничестве с корпорацией \"Вей-мед\". \
		Костюм был сильно модифицирован на полную экономию энергии, в результате чего общая мощность костюма была \
		значительно снижена, и он практически не способен вместить в себя хоть сколько бы то ни было модулей.
	default_skin = "psychological"
	armor_type = /datum/armor/mod_theme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	skins = list(
		"psychological" = list(
			HELMET_LAYER = null,
			HELMET_FLAGS = list(
			),
			CHESTPLATE_FLAGS = list(
			),
			GAUNTLETS_FLAGS = list(
			),
			BOOTS_FLAGS = list(
			),
		),
	)
```

Не совсем понятно, что мы написали, верно? Давайте разберемся. За сам внешний вид костюма отвечает "psychological". Это собственно то, как он будет выглядеть на кукле. У костюмов может быть несколько внешних видов, которые меняются через специальные предметы. За примером в коде обратитесь к шахтерскому модсьюту и его скинам - стандартный и астероидный скины.

Теперь взглянем на флаги. Ботинки, ноги и туловище в большинстве случаев делаются по общему стандарту - активированные детали получают флаги HIDEJUMPSUIT и STOPSPRESSUREDAMAGE - для того, чтобы скрыть комбинезон и получить иммунитет к космосу, при этом неактивированные получают флаг THICKMATERIAL - для использования шприцов, мендеров и других типов лечения.

С головой же всё сложнее. Для начала взглянем на спрайт самого модсьюта.

Если у нас спрайт сделан так, что шлем модсьюта даже в выключенном состоянии покрывает всю голову (к примеру - модсьют РД), то мы делаем это следующим образом

```dm
			HELMET_LAYER = null,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
```

Однако, в случае если неактивированный шлем модсьюта имеет открытую голову (к примеру - модсьюты инженерии), то нам необходимо поступить вот так:

```dm
			HELMET_LAYER = NECK_LAYER,
			HELMET_FLAGS = list(
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
```

Уточнение - флаги в примере взяты с ТГ. У нас вероятно другие. Уточните действующие флаги для модсьюта в соответствующих файлах.

Есть другие варианты, которые лишь частично укрывают голову, поэтому за примерами лучше обратиться в соответствующий файл. Представим, что наш костюм в выключенном состоянии имет открытую голову и к тому же имеет альтернативный скин, в котором наоборот шлем всегда скрывает голову. Попробуем представить это в коде

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
	extended_desc = "Прототип компании \"Тау Технолоджис\", созданный в сотрудничестве с корпорацией \"Вей-мед\". \
		Костюм был сильно модифицирован на полную экономию энергии, в результате чего общая мощность костюма была \
		значительно снижена, и он практически не способен вместить в себя хоть сколько бы то ни было модулей.
	default_skin = "psychological"
	armor_type = /datum/armor/mod_theme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	skins = list(

		"psychological" = list(
			HELMET_LAYER = NECK_LAYER,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),

		"psychotherapeutic" = list(
			HELMET_LAYER = null,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		),
	)
)
```

Код полностью готов. Теперь всё, что осталось, это мы идем в файлы .dmi и добавляем необходимые спрайты для людей и для ксенорас в соответствующие папки.

Теперь, когда костюм полностью готов, время создать для него уникальный модуль.

## Модули

Поскольку это костюм для психолога, представим, что он имеет модуль, который лечит повреждения мозгу в определенном радиусе.
Поскольку это медицинский модуль, мы создадим его в [соответствующем файле](modules/modules_medical.dm). Начнем создавать новый предмет.

```dm
/obj/item/mod/module/neuron_healer
	name = "MOD neuron healer module"
	desc = "Экспериментальный модуль, созданный корпорацией \"Тау Технолоджис\". По желанию пользователя \
		модуль выпускает нейронные волны, которые пассивно лечат повреждения мозга."
	icon_state = "neuron_healer"

/obj/item/mod/module/neuron_healer/get_ru_names()
	return list(
		NOMINATIVE = "Модуль для Модсьюта \"Нейронное лечение\"",
		GENITIVE = "Модуля для Модсьюта \"Нейронное лечение\"",
		DATIVE = "Модулю для Модсьюта \"Нейронное лечение\"",
		ACCUSATIVE = "Модуль для Модсьюта \"Нейронное лечение\"",
		INSTRUMENTAL = "Модулем для Модсьюта \"Нейронное лечение\"",
		PREPOSITIONAL = "Модуле для Модсьюта \"Нейронное лечение\"",
	)

```

В других примерах кода прок на добавление ру-неймов более не будет дублироваться.

Поскольку мы хотим, чтобы модуль лечил людей по требованию, мы сделаем этот модуль активируемым по кнопке. В текущей итерации поддерживается 4 типа модулей:

- Пассивные (добавляют пассивный эффект пользователю. К примеру визоры и ИЛС)
- Переключаемые (По кнопке действия переключают своё действие. К примеру модули магбутсов)
- Используемые (По кнопке осуществляют мгновенное действие. К примеру модуль сонара или гудка)
- Активные (Используется лишь один подобный модуль за раз, давая уникальное действие или предмет. К примеру модуль файерволла или модуль телекинеза)

Поскольку у нас используемый модуль, то мы должны это указать и добавить время кулдауна. Так же не забудьте установить ему комплексность и энергозатраты на каждое использование кнопки действия. Так же добавим новый вариабл на то, как много урона мозгу лечится за каждое использование. Не забудьте так же указать несовместимые модули. Каждый модуль обязан быть несовместим с самим собой, чтобы не дублировать способности и кнопки.

Обновим наш объект.

```dm
/obj/item/mod/module/neuron_healer
	name = "MOD neuron healer module"
	ru_name = "Модуль нейронного исцеления"
	desc = "Экспериментальный модуль, созданный корпорацией \"Тау Технолоджис\". По желанию пользователя \
		модуль выпускает нейронные волны, которые пассивно лечат повреждения мозга."
	icon_state = "neuron_healer"
	module_type = MODULE_USABLE
	complexity = 3
	use_energy_cost = DEFAULT_CHARGE_DRAIN
	incompatible_modules = list(/obj/item/mod/module/neuron_healer)
	cooldown_time = 15 SECONDS
	/// Damage, that we heal in each ability use
	var/brain_damage_healed = 25

```

поскольку это используемый модуль, следует написать оверрайд прока "on_use". В нашем случае все стандартные проверки нам подходят и мы должны их передать наследнику. Про иные проки и вариаблы вы можете прочитать в [этом](modules/_module.dm) файле.

```dm
/obj/item/mod/module/neuron_healer/on_use()
	. = ..()
	if(!.)
		return
```

Данный кусок кода проверяет кулдаун таймера, проверки возможность совершать действия, доступную энергию для костюма и проч.

Теперь мы добавим наш код, который лечит мозг всем существам в небольшом радиусе и создает луч от носителя модсьюта к существам

```dm
/obj/item/mod/module/neuron_healer/on_use()
	. = ..()
	if(!.)
		return
	for(var/mob/living/carbon/carbon_mob in range(5, src))
		if(carbon_mob == mod.wearer)
			continue
		carbon_mob.adjustOrganLoss(ORGAN_SLOT_BRAIN, -brain_damage_healed)
		mod.wearer.Beam(carbon_mob, icon_state = "plasmabeam", time = 1.5 SECONDS)
	playsound(src, 'sound/effects/magic.ogg', 100, TRUE)
	drain_power(use_energy_cost)
```

Этот код - код с ТГ. У нас могут использоваться другие аргументы и проки.

Теперь, когда мы закончили создавать модуль, вы можете добавить его в список для печати в РНД, в списки лута или оставить в щитспавне. Давайте теперь создадим уникальный подвид модуля, который не будет обладать какой бы то ни было комплексностью, будет работать сильнее, чем базовая версия и будет несъемным.

```dm
/obj/item/mod/module/neuron_healer/advanced
	name = "MOD advanced neuron healer module"
	ru_name = "Продвинутый модуль нейронного исцеления"
	complexity = 0
	brain_damage_healed = 50
```

Описание и рунеймы не обязательны, ведь этот предмет невозможно получить стандартными методами и он будет находиться лишь в определенном модсьюте/заспавнен админами.

Теперь мы добавим наш продвинутый, более сильный модуль в тему нашего модсьюта психиатра, после чего он будет добавлен во все модсьюты этого типа.

У вас может появиться вопрос, в чем разница между добавлением модуля в тему и добавлением модуля через "initial_modules" в самом модсьюте. Изначальные модули модсьюта можно вытащить и они обладают комплексностью. Встроенные в тему модули полностью уникальны и их невозможно удалить.

```dm
/datum/mod_theme/psychological
	name = "Психолог"
	desc = "Энергоёмкий костюм производства компании \"Тау Технолоджис\", имеющий крайне ограниченную вместимость модулей."
	extended_desc = "Прототип компании \"Тау Технолоджис\", созданный в сотрудничестве с корпорацией \"Вей-мед\". \
		Костюм был сильно модифицирован на полную экономию энергии, в результате чего общая мощность костюма была \
		значительно снижена, и он практически не способен вместить в себя хоть сколько бы то ни было модулей.
	default_skin = "psychological"
	armor_type = /datum/armor/mod_theme_psychological
	complexity_max = DEFAULT_MAX_COMPLEXITY - 7
	charge_drain = DEFAULT_CHARGE_DRAIN * 0.5
	inbuilt_modules = list(/obj/item/mod/module/neuron_healer/advanced)
	skins = list(

		"psychological" = list(
			HELMET_LAYER = NECK_LAYER,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),

		"psychotherapeutic" = list(
			HELMET_LAYER = null,
			HELMET_FLAGS = list(
				UNSEALED_CLOTHING = SNUG_FIT|THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR|HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				UNSEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
			),
			CHESTPLATE_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
			),
			GAUNTLETS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
			BOOTS_FLAGS = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
			),
		),
	)
)
```

## Конец

Гайд на модсюьты подошёл к концу. Благодаря этому гайду, у вас не должно быть никаких проблем с добавлением новых модсьютов, тем для модсьюта и новых модулей в игру.
