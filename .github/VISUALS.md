# Визуал в SS1984

(Заранее, это перевод VISUALS.md из билда TGstation. )

Добро пожаловать в гайд по визуалу(visuals, отображение на экране грубо говоря) и визуальные эффекты в нашем коде и BYOND.

Здесь описание основных систем которые мы используем, а также объяснение на стороне BYOND(Предоставляя также ссылки-рефы).

Для полного листа всех рефов BYOND, вы можете ознакомиться [здесь](https://www.byond.com/docs/ref/#/atom/var/appearance)

Для понимания как BYOND рендерит все объекты, вы можете обратиться по этому [рефу(renderer)](https://www.byond.com/docs/ref/#/{notes}/renderer)

(Большая благодарность LemonInTheDark и многим другим кодерам из TG ветки)

### Оглавление

- [Appearances](#appearances-in-byond)
- [Overlays](#overlays)
- [Visual contents](#visual-contents)
- [Images](#images)
- [Client images](#client-images)
- [View](#view)
- [Eye](#eye)
- [Client screen](#client-screen)
- [Blend mode](#client-screen)
- [Appearance flags](#appearance-flags)
- [Gliding](#gliding)
- [Sight](#sight)
- [BYOND lighting](#byond-lighting)
	- [Luminosity](#luminosity)
	- [See in dark](#see-in-dark)
	- [Infrared](#infrared)
- [Invisibility](#invisibility)
- [Layers](#layers)
- [Planes](#planes)
- [Render target/source](#render-targetsource)
- [Multiz](#multiz)
- [Mouse opacity](#mouse-opacity)
- [Filters](#filters)
- [Particles](#particles)
- [Pixel offsets](#pixel-offsets)
- [Color](#color)
- [Transform](#transform)
- [Lighting](#lighting)
- [Animate()](#animate())

## Appearances in BYOND

- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/appearance)

Все отображаемые вещи на карте имеют переменную "внешность"(appearance), которое описывает как должен рендериться тот или иной атом(объект, моб, визуальный эффект, HUD или картинка).
Оно не содержит прям ВСЁ, Плейн Мастер([plane masters](#planes)) существуют отдельно, как и другие факторы.
Оно своего рода "рецпет" всего, для влияния на рендеринг объекта.

Appearance имеет пару особенностей который могут быть полезными либо раздражающими смотря что вы пытаетесь сделать.

Первым же делом, appearance статичный. Вы не можете вот прямо изменить его "датум". Он будет выдавать рантайм.

В многих случаях их можно отредактировать, меняя переменные того объекта, которуя предоставляет appearance.

У appearance есть кузин mutable appearance, которые не статичен и его можно **менять**.

Что мы можно сделать так это создать новый mutable appearance[(Реф)](https://www.byond.com/docs/ref/info.html#/mutable_appearance), установить его appearance копием статической, изменить его, и установить сам mutable appearance как appearance желаемого объекта.

Что-то такого.

```byond
// Заметьте, что у нас нету доступа в appearance, поэтому мы часто врём
// Компилятору, заставляя его думать что мы используем mutable appearance.
// Это даёт на возможность менять переменные. Но будьте осторожны с этим
/proc/mutate_icon_state(mutable_appearance/thing)
	var/mutable_appearance/temporary_lad = new() // Создаём временный mutable appearance который мы можем менять и который мы потом вернём. Изначально у его статический appearance стоит.
	temporary_lad.appearance = thing // Здесь мы меняем на наш собственный mutable appearance.
	temporary_lad.icon_state += "haha_owned"
	return temporary_lad.appearance
```

> **Предупреждение:** BYOND может иметь проблемы с повреждёнными appearance, поэтому стоит быть осторожным реализовывая подобное.

## Overlays

- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/overlays) (также стоит посмотреть его место в [рендеринге](https://www.byond.com/docs/ref/#/{notes}/renderer))

Оверлеи(Overlays) это список статических [appearanc'ы](#appearances-in-byond) которые мы рендерим выше нашего объекта.
Их можно редактировать с помощью метода описанный выше.

Очередь редеринга определён с помощью [лееров(layer)](#layers) и [плейн(plane)](#planes), но изначально это решается очередью appearanc'ов внутри списка оверлеев.

While overlays are stored as static appearances they can be created using icon states to draw from the overlay'd thing icon, or using `/icon` objects.
Не смотря что оверлее хранятся как статические appearance, их можно создать используя icon state с иконок другого объекта со своими оверлеями или используя `\icon` объектов.

Стоит отметить что добавление оверлеев имеют свою "стоимость" поэтому мы кэшируем модификации в список.

Это не столь значительно, но оно там и стоит об этом знать.

### Наша реализация

Мы используем оверлеи как основной метод наложения визуалов на объекты.
Но так как оверлеи это КОПИИ appearance объектов, обеспечить их очистку довольно проблемотично.

Чтобы решить эту проблему, мы управляем ими с помощью `update_overlays()`.

Этот прок вызывается когда appearance объекта обновляется с помощью `update_appearance()`
(Грубо говоря, мы ре-рендерим что либо статическое в объекте, будь то icon state или name),
что сопроводит вызовом `update_icon()`.

`update_icon()` справляется с иконкой объекта, а также его оверлеем.

В `update_icon()` сперва вызывается `update_overlays()` чтобы получить новые оверлеи.
Изначально старые оверлеи содержатся не только как в переменной `overlays`, но и также в списке `managed_overlays` в сыром виде.
Это необходимо чтобы проверять что они случаем не одинаковые. Если не одинаковые то происходит следующее.

Сперва вызывается `cut_overlay()` чтобы очистить старые оверлеи, а после добавляются новый через `add_overlays()`.
Внутри прока, список объектов превращаются в статические appearanc'ы и после добавляются в `overlays`

Вы можете оверрайднуть всю систему используя `add_overlays()` и `cut_overlay()`,
Но это очень опасно потому что вы очищаете оверлеи соотвествующим образом.
Будьте осторожны в этом.

## Visual Contents

- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/vis_contents)

`vis_contents` даёт буквально сказать "Ей, зарендерь это прямо НА меня".

Само "НА" может быть по разному работать за счёт `vis_flags` переменной.
Можно взглянуть [здесь](https://www.byond.com/docs/ref/#/atom/var/vis_flags).

В наших интересах это флаги:
- `VIS_INHERIT_ID`: Даёт возможность соединить ПРЯМИКОМ в объекту на котором оно нарисовано,
то есть если мы кликнем по `vis_contents`-объект мы кликаем на изначальный объект.
- `VIS_INHERIT_PLANE`: Мы обсудим [плейны](#planes) в будущем, но мы используем их вместе чтобы менять очередь рендера и применять эффектов как группы.
Этот флаг меняет плейн у любого `vis_contents`-объекта на плейн как источник-объекта(source).
Это может быть полезно, но оно может ломать любые эффекты которые зависят от плейн.

Всё что внутри `vis_contents` будет содержать свой loc в `vis_locs` переменной.
Мы редко это используем, в основном для очистки референсов от `vis_contents`.

`vis_contents`, unlike `overlays` is a reference, not a copy. So you can update a `vis_contents`'d thing and have it mirror properly.
This is how we do multiz by the by, with uh, some more hell discussed under [multiz](#multiz).
`vis_contents`, это ссылка(референс, reference), не копия как если оверлеи. Поэтому вы можете обновлять `vis_contents` объект и правильно его отображать.
Таким методом мы и делаем [МультиЗ](#multiz).

Но в качестве платы за это, уступает в виде потребления маптика(maptick).
Так как это не копия, мы всегда должны проверять на изменения, что приводит к затрату за каждого подключенного игрока.
Будьте осторожны как вы это будете использовать.

## Images


- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/image)

Изображения технически это родители [mutable appearances](#appearances-in-byond).
Мы не используем их так часто, потому что можем выполнить многие задачи с помощью того же mutable appearance.

Изображения существует для использования в оверлеях и для отображения вещей только для клиента на карте.
Смотрите [/client/var/images](#client-images)

> Примечание: наследствие между двумя это просто удобство для движка. Не полагайтесь на это.

## Client Images

- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/client/var/images)

`/client/var/images` это список изображении объектов для показа ТОЛЬКО определённому клиенту.

Изображения объектов показываются на их loc переменных, и могут быть показаны более одному пользователю за раз.

### Наша реализация

Мы используем client images по разному. В основном используем по назначению, модифицируя видимость только у одного пользователя(видимость ИИ к примеру).

Но мы также желаем показать список изображении для ГРУППУ людей, но в ограниченном варианте.
Для этого, мы используем `/datum/atom_hud` (или HUD) систему.

Это другое в отличии от `/datum/hud`, о чём я расскажу чуть позже.

ХУДы это датумы которые предоставляют собой категорию изображении для отображение пользователям.
Во многом они глобальные, но могут быть созданы в атоме в редких случаях.

Они хранят список изображении для дисплей (отсортированы с помощью Z уровня для уменьшения лага) и список клиентов для дисплея.

Мы отображаем эту группу изображении в/из client image списка, смотря по тому что может видеть ХУДы.
Мы это используем к примеру в медхуде, антагхуд и других видов ХУД.

## View
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/client/var/view)

`/client/var/view` это очень легкая топика,
но я расскажу не только о нём, но а также про изменение размеров пикселей(pixel sizing) и как мы справляемся с этим.

view это то, что отвечает за границы отображения у клиента. Говоря по другому, это границы экрана у клиента.

Это может быть числом X на X клеток или строка(string) "XxY" для большего контроля.

### Client Rendering Modes

- [Zoom Реф BYOND](https://www.byond.com/docs/ref/#/{skin}/param/zoom) / [Zoom Mode Реф BYOND](https://www.byond.com/docs/ref/#/{skin}/param/zoom-mode)

Клиенты немного опции как буквально они хотят отображать игру себе.

Здесь обсудим пару режимов, `zoom` и `zoom-mode` оба которые параметры скинов.(переменные которые живут у клиентов)

`zoom` решает как клиент хочет видеть турфы.
У его есть две опции.
Если равен нулю то он будет растягивать тайлы отправленные клиенту чтобы исправить к размеру окна-карты.
Иначе, любое число(1, 2, 4) приведёт к масшатбзированию в несколько X раз.
Этот эффект может выдавать ровные, гладкие границы пикселей только если число полное(не 1.5 к примеру). Поэжтому мы выдаём игрокам полные числа.

`zoom-mode` контролирует как пикселы должны быть увеличены, если надо на это.
Взгляните в реф для большей детальности, но `normal` выдаёт самый острый(sharpest) результат, `distort` использует "nearest neighbor" метод что приводит
к некоторому блюру, и `blur` которые использует Билинейную интерполяцию(bilinear sampling) которое само собой выдаёт буквально мыло.

## Eye
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/client/var/eye)

`/client/var/eye` это атом или моб. Этот атом будет в центре экрана клиента. Обычно это и есть сам моб игрока(или к примеру камера ИИ).

По умолчанию `/client/var/mob` но можно модифицировать.
С помощью этого мы можем выполнять такие вещи как, глаз ИИ или ползание в вентиляции(делая `eye` на турф, нежели моб). Или другие где игрок находится в чём-то(ящики).

## Client Screen
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/{notes}/HUD)

Похожее с client images но не *совсем* одинаковое. Здесь мы можем буквально вставлять объекты в экран клиента.

Это можно за счёт использования `screen_loc` числа и вставляя в список `screen` клиента.

> Примечание: мы также используем `screen` для других вещей также, по этому будет чуть позже.

`screen` не столь интересно, но `screen_loc` имеет ПОЛНО нюансов.

Начиная с формата.
Классический `screen_loc` формат выглядит примерно так:
`x:px,y:py`

Пиксель оффсеты можно убрать ибо они опциональны, но важная часть это x и y числа. Но их можно и не использовать также.

Мы используем кардинальный ключевые слова как `NORTH` чтобы прикрепить объект в размеру экрана клиента.
Также можно использовать дирекционные слова как `TOP` чтобы прикрепить к видимому окне-карты, что предотвращает выходы за рамки(out of bounds).
Можно также использовать абсолютные оффсеты что позиционировать объекта вне размеров `view`, что заставляет окно-карту расшириться.

### Secondary Maps

Пока мы здесь, это сайд-топика но вы можете использовать более одной окне-карты на экране клиента сразу.

Это наёбывает dmf но вы можете использовать [id окон](https://www.byond.com/docs/ref/#/{skin}/param/id) чтобы сказать объекту на экране рендериться на второй окне.
Очень полезно для создания pop-up окон и подобных.

## Blend Mode
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/blend_mode)

`/atom/var/blend_mode` устанавливает как атом рендерится на карту.

Здесь полно опции но самая нужная это `BLEND_MULTIPLY`, которое умнажает вещь "на" нас.

Таким образом мы выполяем эффект света(lighting).

## Appearance Flags
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/appearance_flags)

`/atom/var/appearance_flags` это набор флагов-переключателей для приминения визуального элемента на атом.

Флаги интересов:
- `LONG_GLIDE`: без него, диагональные движения всегда автоматически брали sqrt(2) больше времени, за счёт большей дистанции. Мы делаем калькуляцию автоматически,
поэтому мы желаем чтобы оно было отключено.
- `KEEP_TOGETHER`: даёт возможность заставлять оверлеи рендериться в том же манере как и объект на который он был наложен. Самая полезная для людей чтобы делать альфа-цвет изменения для всех оверлеев.
- `PLANE_MASTER`: Я приду к этому чуть позже, но это даёт возможность использовать [плейн(plane)](#planes) переменную для рендеров на "объекты на экране", так что мы можем применять визуальные эффекты, маски и т.д.
- `TILE_BOUND`: По умолчанию если видна только одна часть на одном тайле или видна другая часть которая на другом тайле, то объект будет виден. Это может использоваться для крупных объектов, объекты которые вне своего турфа или для объектов которые прошли transform'ацию.

## Gliding
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/{notes}/gliding)

Вы могли заметить что передвижение между тайлами довольно гладко.
Движение в 0.2 или 10 тайлов в секунду всегда будет гладко. Это потому что мы контролируем скорость в котором атомы анимирует между каждым шагом.

Мы можем изменять `/atom/movable/var/glide_size` установив количество пикселей который моб должен продвинуться в каждый тик СЕРВЕРА (Тик сервера по умолчанию 20 в секунду, или 0.05 секунд в раз).
Мы изменяем его с помощью прока `/atom/movable/proc/glide_for`.

Размер глайда в каком-то контексте установлен как скорость передвижения. Или как задержка движения у моба, установленная в `/client/Move()`, или задержку в сабсистеме движения.

## Sight
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/mob/var/sight)

`/mob/var/sight` это группа битфлагов которые *чаще* всего указывают ЧТО должно рендериться на вашем экране. Будь то мобы, турфы и т.д.

- `SEE_INFRA`: Я немного подойду к этому чуть позже, но инфракрасный(infrared) это по сути копия темноты BYOND'а. Это не то что мы в основном используем.
- `SEE_BLACKNESS`: Сильно относиться к [плейнам](#planes), это буквально и есть "полная темнота(blackness)" (оно маскирует те вещи которые не можете видеть полностью)
и рендериться отдельно, вне контроля как "пользователь".
Но если флаг `SEE_BLACKNESS` включен, то он будет рендериться на плейне 0, дефолтные плейн BYOND'а.
Это позволяет захватывать его, и так сказать, блюрить, перерисовывать его в другом месте. Очень мощный флаг которую мы постоянно используем.

## BYOND Lighting

- [Оглавление](#оглавление)

Не смотря на нашу имплементацию света, используя цветовые матрицы, BYOND имеет свою систему света.

Он супер простой. Тайл либо светиться либо нет.

Если тайл не светиться, и он соотвествует некоторым условиям, то его контент и он сам будут спрятаны от пользователя,
Как если бы между ним(тайлом) была стенка. Этот использует темноту BYOND, что делает его контролируемым.

Я расскажу в здесь также другие кусочки которые также используются этой системой

### Luminosity
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/luminosity)

`/atom/var/luminosity` это переменная которая позволяет нам вливать свет прямо в систему света BYOND'а.
Он очень прост, всего лишь радиус тайлов которые должны быть освещены, беря также во внимание видимость(sight-line) и тому подобное.

> `/proc/view()` по сути и использует систему видимость у этого "света", для определения видимости.

### See in Dark
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/mob/var/see_in_dark)

`/mob/var/see_in_dark` устанавливает радиус в виде квадрата вокруг моба, который вырезает темноту BYOND.

Из-за этого когда ты стоишь в темноте то можешь видеть себя, и поэтому можете видеть вокруг объекты когда используете мезоны.
Это очень простое, но стоит описания.

### Infrared
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/mob/var/see_infrared)

Инфракрасный(Infrared) видимость можно считать как бы скрытым копием стандартной темнотой BYOND'а.
Это не то что мы можем видеть, но вы можете понять, что это довольно трудно понять без контекста.

## Invisibility
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/invisibility)

`/atom/var/invisibility` это тупой способ скрытия объектов от группу пользователей. Можно об этом думать как [плейн](#planes) или [client images](#client-images) но в более ограниченном варианте.
Мы используем это чтобы скрывать призраков, только-призрачные вещи.

Оно также используется чтобы скрыть таймеры и другие указатели которые видят только призраки. Его значение можно поставить от 0 до 101.

`/mob/var/see_invisible` эта переменная отвечает на каком уровне моб может видеть невидимые объекты равные по уровню или ниже. То есть при `see_invisible` должен быть не ниже `invisibility` объекта чтобы его видеть. Довольно просто.

## Layers
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/layer)

`/atom/var/layer` это первый элемент который решает в каком порядке вещи будут рендериться на карту.
Очередь рендера ОЧЕНЬ заивист от [формата карты(map format)](https://www.byond.com/docs/ref/#/world/var/map_format),
но о том что сказано в рефе выше я не стану рассказывать ибо это не столь важно.
Всё что вы должны знать так это наш нынешний формат,
объекты которые появляются первыми, рисуются первыми, но рендеряться ниже всех.
Думаете об этом как если вы накладываете нарезки разных кусочек бумаг друг на друга.(бутерборд: турф, потом объект, на котором оверлеи)

Лееры довольно просты идя с самых низких до самых высоких. Но есть пару нюансов.
Эти сноуфлейк лееры могут использоваться для выполнение некоторых целей которые просто любой леер с негативным числом, помимо флоут лееры(floating layers).

Флоут лееры(floating layer, от слова float) прилегают к "высшему" по звену объекту на которой нарисованы, пока не достигнут целого леера(real layer). Они потом оффсетят от этого.

Это даёт нам возможность поддерживать разницы в леерях не требуя делать все источники статическими. Очень полезно.

## Planes
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/plane)

Ну и наконец-то самое жаркое. `/atom/var/plane`.

Они исполняют две функции. Первое самое простое, это тупо копирование [лееров](#layers).
Высшие плейны будут (**обычно**) рендериться ниже других. Чётко и просто.

Как и [лееры](#layers), плейны поддерживают "floating"(флоуты) вместе с `FLOAT_PLANE`. Смотртите объяснение выше.

Но они могут также использоваться для более комплексных и... прикольных вещей!
Если клиент имеет атом с `PLANE_MASTER` [флаг appearance](#appearance-flags) в ихнем [окне](#client-screen),
Вместо того чтобы рендериться всё нормально, всё что угондо в пределах видимости клиента( в пределах view) будет рендериться на плейн мастер(plane master).

Это ОЧЕНЬ мощный инструмент, потому что это даёт нам возможность [прятать](https://www.byond.com/docs/ref/#/atom/var/alpha), менять [цвета](#color),
и [искажать](#filters) многие классы объектов, среди прочего.
Это даже невозможно описать насколько это полезно для нас. Но у его есть некоторые недостатки.

Так как плейны связаны вместе с группировкой и рендеринг очередью, есть некоторые эффекты которые требуются разделения плейнов на кусочки.
Это также приводит к некоторым эффектам к невозможностью их выполнить или вовсе к конфликтам между двумя. Особенно у вещей связанных с [форматом карт(map format)](https://www.byond.com/docs/ref/#/world/var/map_format).
Это тупо, но это всё что мы имеем братан, поэтому мы будем использовать это как бесплатный билет на Багамы.

Мы имеем систему которая позваляет управлять плейн мастерами для целей в [эффектов фильтра(filter effects)](#filters)
Он слегка устаревший из-за [рендер релеев(render relays)](#render-targetsource), но он всё ещё используется и иногда полезен.

> Кое-что вам следует знать: Плейн мастеры влияют ТОЛЬКО на карту на которой находиться их screen_loc.
По этой причине, мы должны генерировать полно копии групп из плейн мастеров с соотвествующим screen_loc чтоба сделать subview(под-взгляды) правильно.

> Предупреждение: Плейны имеют ограничения на числа. Они ТРЕБУЮТ полные числа(не флоуты) и ДОЛЖНЫ иметь абсолютное число из `10000`.
Это нужно чтобы поддерживать `FLOAT_PLANE`. которое живёт на границах 32 битного int.

## Render Target/Source
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/render_target)

Render targets are a way of rendering one thing onto another. Not like vis_contents but in a literal sense ONTO.
The target object is given a `/atom/var/render_target` value, and anything that wishes to "take" it sets its `/atom/var/render_source` var to match.

When I say render onto, I mean it literally. It is like adding a second step in the rendering process.

You can even prepend * to the render target value to disable the initial render, and JUST render via the render source.

### Our Implementation

We use render targets to create "render relays" which can be used to link [plane masters](#planes) together and accomplish more advanced effects.
See [the renderer documentation](../../code/_onclick/hud/rendering/_render_readme.md) for visualizations for this.

> Of note: this linking behavior is accomplished by adding a screen object to link onto with a plane value of the desired PM we want to relay onto.
Layer is VERY important here, and will be set based off the layer of the last plane master.
This means plane order is not always the absolute order in which different plane masters render. Be careful of this.

> To edit and display planes and plane connections in game, run the `Edit/Debug Planes` command.
It will open a ui that allows you to view relay connections, plane master descriptions, and edit their values and effects.

## Multiz
- [Оглавление](#оглавление)
- Реф: Наше убогое воплощение с TG билда

Я объясню как работает мультиз. Но перед этим, стоит объяснить как он до этого работало.

Что мы делали так это брали турф openspace сверху, вставляли турф ниже в [vis_contents](#visual-contents), и на этом всё.
Это работало потому что всё было на карте которое имело `VIS_INHERIT_PLANE` флаг и опенспейс имел плейн мастер почти под всеми остальными.

Это значило что турф "под" казался "сдвинутым" и всё выглядело хорошо.

Но не совсем по двум причинам. Один ужаснее другого

- 1: Это выглядело дерьмово. Это ломало паттерн старых плейнов всех объектов в vis_contents, что `effects/lighting/dropshadows` ломалось прям ужасно.
(Этой проблемы не было в нашем билде. Хотя были проблемы с эффектом оффсета по границам экрана клиента.)
- 2: Я раньше говорил об этом, но это полностью ломало `side_map` [формат карты](https://www.byond.com/docs/ref/#/world/var/map_format)
Это потому что `side_map` меняет как проходит очередь рендера.

Ок, старые метод не очень рабочий. Что тогда?

Здесь пару проблем. Первая что наши плейн мастеры приходит уже предготовлеными. Мы должны иметь способ получения и нижних и верхних плейн мастеров.

Это вполне... не легко, но и не совсем трудно. Мы просто делаем дубликат всех наших плейн мастеров как деерево и соединяем верхушку мастера рендера к опенспейн плейн мастеру на уровень верх. Вполне возможно.

ВТОРАЯ проблема. Как мы сделаем так чтобы всё что внизу "приземлялось" на правильный плейн?

Ответ разочаровывающий но правдивый. Мы вручную оффсетим каждый объект на карте плейна соотвествуя ихнему "z layer".
Это включает любые `overlays` или `vis_contents` с уникальными плейн числами.

Во многом мы требуем что либо что устанавливает число плейна чтобы потом это отправить источнику, что-то вроде турфа или отходящий от турфа.
Есть несколько уникальных случаев, где потребуется отработать оффсет, но они довольно редки.

Это тупо. Но это сотворимо. И это то что мы творим.

## Mouse Opacity
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/mouse_opacity)

`/atom/var/mouse_opacity` говорит клиенту как обрабатывать наведение мышки на атом.

Значение 0 означает полное игнорирование, не смотря ни на что.
Значение 1 означает что оно прозрачно основываясь на альфа-цвет иконки в определённой его части.
Значение 2 означает что будет считывает всю иконку объекта ни смотря на прозрачность. Все 32 на 32.

Мы иногда используем прозрачность мыши(mouse opacity), но чаще мы это делаем с помощью [vis_contents](#visual-contents),
или очень низкий альфа-цвет пикселей на спрайт(альфа-цвет равным 1)

> Note: Mouse opacity will only matter if the atom is being rendered on its own. [Overlays](#overlays)(and [images](#images))
will NOT work as expected with this.
> Примечание: Mouse opacity работает только с самим атомом. Это не включает в себе [оверлеи](#overlays) и [изображении](#images)
Хотя вы всё ещё можете иметь прозрачные оверлеи. Если зарендерить их на [плейн мастер](#planes) с желаемым числом mouse opacity
оно будет работать как надо. Это работает так как сперва рендерер накладывает оверлей НА плейн мастер, а потом принимает эффекты плейн мастера.

## Filters
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/{notes}/filters)

Фильтры это система для приминения ограниченных вариантов шейдеров для рендера.
Эти шейдеры рендеряться у клиента. У этого есть свои преимущества и недостатки.
Плюсы: очень дешево для сервера. Минусы: лагучий для клиента.
Будьте осторожны с этим

Это система по сути универсальный. У его ПОЛНО разных эффектов и много вещей который мы могли поделать с этим.

Есть пару вещей о которых вам стоит знать дабы вы понимали их полезность и ограничения.

По полезности. Есть фильтры на маскирование альфа-цвет(alpha masking). Он принимает источники рендера как аргумент, то есть мы можем к примеру использовать один плейн мастер
чтобы "замаскировать" другой. Этот "плюс" и есть объяснение тому как эмиссивы работают.

Также есть фильтры на искажение(distortion). Таким образом мы выполняем эффект гравитационных аномалии.(В нашем билде этого пока нету)

По ограничениям: Фильтры, как и другие вещи в BYOND, содержатся в списке в `/atom`е. Это значит что если мы хотим управлять ими,
то нам нужна своя система управления. Поэтому, не как byond, мы используем оболочку(wrapper) для фильтров чтобы ставить приоритеты и управлять добавлением и удалением.
Это система может ломать анимации и другие вещи. Будьте осторожны.

## Particles
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/{notes}/particles)

Частицы это система которая позволяет приклепять "генераторы" к атомам в мире(world) и выплёвывать маленькие визуальные эффекты.
Это сделано создавая подтип из типа `/particles` давая переменные которые вы желаете.

По умолчанию BYOND разрешает присоединить только один эмиттер частиц к атому. Мы обходим это используя атом вставленный в loc или родитель-атом который следует.
Это и есть `/obj/effect/abstract/particle_holder`. Его использование довольно прост. Просто даёте loc для отображения и тип частиц для использования.
Остальное он сделает сам.

## Pixel Offsets
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/pixel_x)

This is a real simple idea and I normally wouldn't mention it, but I have something else I wanna discuss related to it, so I'ma take this chance.

`/atom/var/pixel_x/y/w/z` are variables that allow us to offset the DISPLAY position of an atom. This doesn't effect its position on the map mind,
just where it APPEARS to be. This is useful for many little effects, and some larger ones.

Anyway, onto why I'm mentioning this.

There are two "types" of each direction offset. There's the "real" offset (x/y) and the "fake" offset (w,z).
Real offsets will change both the visual position (IE: where it renders) and also the positional position (IE: where the renderer thinks they are).
Fake offsets only effect visual position.

This doesn't really matter for our current map format, but for anything that takes position into account when layering, like `side_map` or `isometric_map`
it matters a whole ton. It's kinda a hard idea to get across, but I hope you have at least some idea.

## Color
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/color)

`/atom/var/color` is another one like [pixel offsets](#pixel-offsets) where its most common use is really uninteresting, but it has an interesting
edge case I think is fun to discuss/important to know.

So let's get the base case out of the way shall we?

At base, you can set an atom's color to some `rrggbbaa` string (see [here](https://www.byond.com/docs/ref/#/{{appendix}}/html-colors)). This will shade every pixel on that atom to said color, and override its [`/atom/var/alpha`](https://www.byond.com/docs/ref/#/atom/var/alpha) value.
See [appearance flags](#appearance-flags) for how this effect can carry into overlays and such.

That's the boring stuff, now the fun shit.

> Before we get into this. `rr` is read as "red to red". `ag` is read as "alpha to green", etc. `c` is read as constant, and always has a value of 255

You can use the color variable to not just shade, but shift the colors of the atom.
It accepts a list (functionally a matrix if you know those) in the format `list(rr,br,gr,ar, rb,bb,gb,ab, rg,bg,gg,ag, ra,ba,ga,aa, cr,cb,cg,ca)`
This allows us to essentially multiply the color of each pixel by some other other. The values inserted in each multiple are not really bounded.

You can accomplish some really fun effects with this trick, it gives you a LOT of control over the color of a sprite or say, a [plane master](#planes)
and leads to some fun vfx.

> We have a debug tool for color matrixes. Just VV an atom, go to the VV dropdown and look for the `Edit Color as Matrix` entry.
It'll help visualize this process quite well. Play around with it, it's fun.

## Transform
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/atom/var/transform)

`/atom/var/transform` allows you to shift, contort, rotate and scale atoms visually.
This is done using a matrix, similarly to color matrixes. You will likely never need to use it manually however, since there are
helper procs for pretty much everything it can do.

> Note: the transform var is COPIED whenever you read it. So if you want to modify it, you will need to reset the atom var back to your changes.

It's not totally without explanation, and I figured you might wanna know about it. Not a whole lot more to say tho. Neat tool.

## Lighting
- [Оглавление](#оглавление)
- Reference: Hell of our own creation

I wanted to take this chance to briefly explain the essentials of how our lighting system works.
Essentially, each tile has a lighting [overlay](#overlays) (technically an [underlay](https://www.byond.com/docs/ref/#/atom/var/underlays)
 which is just overlays but drawn under).
Anyway, each underlay is a color gradient, with red green and blue and alpha in each corner.
Every "corner" (we call them lighting corners) on the map impacts the 4 colors that touch it.
This is done with color matrixes. This allows us to apply color and lighting in a smooth way, while only needing 1 overlay per tile.

There's a lot of nuance here, like how color is calculated and stored, and our overlay lighting system which is a whole other beast.
But it covers the core idea, the rest should be derivable, and you're more qualified to do so then me, assuming some bastard will come along to change it
and forget to update this file.

## Animate()
- [Оглавление](#оглавление)
- [Реф BYOND](https://www.byond.com/docs/ref/#/proc/animate)

The animate proc allows us to VISUALLY transition between different values on an appearance on clients, while in actuality
setting the values instantly on the servers.

This is quite powerful, and lets us do many things, like slow fades, shakes, hell even parallax using matrixes.

It doesn't support everything, and it can be quite temperamental especially if you use things like the flag that makes it work in
parallel. It's got a lot of nuance to it, but it's real useful. Works on filters and their variables too, which is AGGRESSIVELY useful.

Lets you give radiation glow a warm pulse, that sort of thing.
