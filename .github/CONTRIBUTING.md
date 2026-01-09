# ВКЛАД В ПРОЕКТ

## Вступление

Перед вами руководство по внесению вклада в билд **Paradise** проекта **SS1984**. Здесь вы найдёте как советы по работе с Github, так и стандарты разработки/написания кода.

## Комментарии

Если вы оставляете комментарий под чьим-то Pull Request'ом (далее **"PR"**), убедитесь, что он ёмко и лаконично выражает вашу мысль. Не следует писать на отвлечённые темы или выражать агрессию/токсичность по отношению к автору — будьте **дружелюбны** и пишите **по теме** PR'а.

## Pull Request'ы

Вклад в разработку проекта и создание PR'ов игроками приветствуется и поощряется. Учтите, что ваш PR может не получить одобрение от **Ведущего Разработчика**, либо вас попросят его доработать. Это особенно актуально для PR'ов большого размера или тех, которые затрагивают баланс. Совещайтесь с другими разработчиками и задавайте вопросы. Вы же не хотите потратить своё время и силы на работу, которую в итоге забракуют.

#### Правила:

- PR'ы должны быть **атомизированы**. Разбивайте значимые изменения на отдельные commit'ы. Благодаря такому подходу, в случае необходимости модификации/удаления определённого изменения вы можете работать только с соответствующим commit'ом. Хотя следование этому правилу не всегда является возможным из-за ограничений движка, старайтесь не пренебрегать им по возможности.

- Тщательно **документируйте** и **объясняйте** свои PR's. Это особенно актуально, если вы портируете PR с другой кодбазы (**TG station**, например), структура кода которой может разительно отличаться от нашей. Чем лучше вы подходите к документированию своих работ, тем легче членам ревью-команды проверять ваши PR'ы и понимать ваш ход принятия решений. Иногда даже небольшая ремарка может значительно ускорить **процесс одобрения** ваших изменений.

- PR'ы не должны иметь каких-либо **merge-конфликтов**. Используйте `git rebase` или `git reset`, чтобы обновлять свои ветки, не `git pull`.

- Всегда объясняйте, почему ваш PR должен быть **одобрен** и какую **ценность** для проекта несут данные изменения. Этим правилом можно пренебречь, если вы считаете, что польза PR'а очевидна и не требует каких-либо дополнительных пояснений. Тем не менее, дополнительная информация никогда не будет лишней.

#### Использование Changelog

Перед заголовком вашего PR'а требуется поставить корректный **тег**, что необходимо для корректного отображения оного в Changelog-меню игры, а также для сортировки PR'ов на Github. Названия PR'а рекомендуется писать на русском, хотя это не является обязательным (особенно для чисто технических изменений).

Учтите, что вы можете использовать **мульти-теги**, прописывая теги PR'а через `/`.

**Пример**:

```
bugfix: пропажа спрайта одежды при смене её внешнего вида
add/local: новый босс для Лазиса + локализация старых боссов
```

**Список тегов для PRa**:

- **add:** Вы добавляете новый контент в игру.
- **admin:** Вы меняете что-то, связанное с администрацией (кнопки, управление, панели, щитспавн и т.д.)
- **balance:** Вы производите балансировку в игре.
- **bugfix:** Вы исправляете некий баг.
- **code_imp:** Вы имплементируете новое для билда, не меняя при этом ничего в самой игре.
- **config:** Вы меняете конфиг или работу SQL.
- **del:** Вы удаляете контент из игры.
- **experiment:** Ваш PR создан с целью какого-то эксперимента.
- **map** Вы меняете только карту.
- **local** Вы делаете добавляете новый текст на русском или переводите на русский.
- **imageadd:**  Вы добавили новый спрайт.
- **imagedel:**  Вы удалили старый спрайт.
- **soundadd:** Вы добавили новый звук.
- **sounddel:** Вы удалили старый звук.
- **spellcheck:** Вы исправили опечатку.
- **tweak:** Вы внесли незначительную правку.
- **refactor:** Вы полностью переписали старый код, улучшив его, НО не изменив функционал.
- **server:** Вы меняете что-то связанное с серверной частью или Github.
- **wip:** Ваш PR в драфте и планируется длительная разработка.

## Спецификации

Ниже перечислены стандарты написания кода и разработки в общем. Вы обязаны им следовать, чтобы в билд попадал только качественно написанный код, удобный для дальнейшней разработки. Чем лучше ваш PR соответствует этим правилам, тем больше своего и чужого времени вы сэкономите и тем быстрее ваши изменения попадут в билд. **Большое спасибо за ознакомления с этим разделом**!

### Объектно-ориентированный код

Dream Maker, язык движка BYOND, (далее **"DM"**) — **объекто-ориентированный язык**, поэтому написанный вами код должен соответстовать стандартам ООП по воможности. Если "ООП" вам ни о чём не говорит, крайне рекомендуем вам поискать материалы по данной теме, чтобы иметь хотя бы базовое понимание.

### Все пути должны быть полноценными

Иными словами, пути должны быть **абсолютными**.

DM позволит вам поместить почти что любое ключевое слово в блок, например:

```DM
datum
  datum1
    var
      varname1 = 1
      varname2
      static
        varname3
        varname4
    proc
      proc1()
        code
      proc2()
        code

    datum2
      varname1 = 0
      proc
        proc3()
          code
      proc2()
        ..()
        code
```

Тем не менее, использование такого подхода **запрещено**.

**Исключение** из данного правила: большая часть объектов в файле имеет *относительные* пути, что делает нахождение определений через текст по полному пути практически невозможным.

Вот исправленная версия кода выше с использованием абсолютных путей:

```DM
/datum/datum1
  var/varname1
  var/varname2
  var/static/varname3
  var/static/varname4

/datum/datum1/proc/proc1()
  code
/datum/datum1/proc/proc2()
  code
/datum/datum1/datum2
  varname1 = 0
/datum/datum1/datum2/proc/proc3()
  code
/datum/datum1/datum2/proc2()
  ..()
  code
```

### Пользовательские интерфейсы (UI)

Все новые пользовательские интерфейсы (они же **"UI"**), добавляемые в игру, должны быть созданы с помощью **TGUI фреймворка**. Соответствующая документация может быть найдена в папке `tgui/docs`. Это необходимо для того, чтобы все игровые UI были работоспособными и удобными для использования.
**Исключение**: если конкретный UI предназначен только для OOC поля (админ. функционал, к примеру), то требованием к TGUI можно пренебречь. Тем не менее, если вы сделаете TGUI, то хуже не будет.

### Не переопределяйте проверки типов

Использовать `:` оператор, чтобы переопределить проверку на тип объекта **запрещено**. Вы должны приводить переменную к корректному типу.

### Пути объектов должны начинаться с `/`

То есть: `/datum/thing`, но не `datum/thing`.

### Пути `datum` объектов должны начинаться с "datum"

Хоть это и опционально в DM, но использование именно такого стиля облегчает обнаружение и поик определений объектов в коде. Для понимания, путь `/arbitrary` функционально идентичен пути `/datum/arbitrary`. И всё же, определяйте пути по примеру второго объекта.

### Не используйте строковое определение путей

Пример:

```DM
// Хорошо
var/path_type = /obj/item/baseball_bat

// Плохо
var/path_type = "/obj/item/baseball_bat"
```

В редких случаях это разрешается, т.к. в таком случае компилятор не выдаст ошибку, если такой путь более не существует.

### Используйте `[A.UID()]` вместо `\ref[A]`

В BYOND существует система передачи «мягких ссылок» на объекты (datums) с использованием формата `"\ref[datum]"`. Это позволяет находить объект только по текстовой строке, что особенно удобно при взаимодействии кода BYOND с HTML/JS в пользовательских интерфейсах. При возврате в BYOND ссылка преобразуется обратно в объект с помощью `locate("\ref[datum]")`. Проблема заключается в том, что если исходный объект был удалён, `locate()` может вернуть совершенно другой объект — BYOND повторно использует ссылки после удаления.

**Идентификаторы UID** ("уникальные идентификаторы") действительно уникальны: они генерируются с помощью глобального счётчика и **никогда** не переиспользуются. Каждому объекту UID присваивается при создании и доступен через [datum.UID()]. Вы можете использовать UID как прямую замену `\ref`, заменив все вызовы `locate(ref)` в вашем коде на `locateUID(ref)`. Использование этой системы **обязательно** для всех вызовов `/Topic(`, иначе DM будет выдавать ошибку. Используйте `<a href='byond://?src=[UID()];'>`, а не `<a href='byond://?src=\ref[src];'`.

### Используйте формат `var/name` при объявлении переменных

Хотя DM допускает и другие способы объявления переменных, для единообразия следует использовать **именно этот**.

### Используйте табуляцию, а не пробелы

Вы **обязаны** использовать табуляцию для отступов в коде, **НЕ ПРОБЕЛЫ**.

Пробелы разрешается использовать для **выравнивания**, но сначала сделайте отступ до уровня блока с помощью табуляции, а затем добавьте нужное количество пробелов.

### Не пишите "костыльный" код

"Костыльный" код — например, добавление специфических проверок вроде `istype(src, /obj/whatever)`, крайне не рекомендуется и допускается только тогда, когда другого варианта **действительно нет**.
Подсказка: фраза "Я не смог сразу придумать нормального решения, значит другого варианта нет" здесь **не сработает**! Если вы не знаете, как решить задачу правильно — прямо скажите об этом и попросите помощи. Именно для этого и **существуют мейнтейнеры**.

**Избегайте** костылей, применяя **объектно-ориентированные подходы**: переопределяйте процедуры (procs) или выносите код в отдельные функции, которые можно переопределять при необходимости.

То же самое касается **исправления багов**: если в процедуру передаётся некорректное значение откуда-то, где его быть не должно, не исправляйте проблему внутри самой процедуры — устраните её в источнике, если это возможно.

### Не дублируйте код

Копирование кода из одного места в другое допустимо в небольших краткосрочных проектах, но наш билд — **долгосрочный** проект, и дублирование здесь **крайне** не рекомендуется.

Вместо этого используйте ООП или просто выносите повторяющийся код в **отдельные функции**.

### Компромиссы при старте и во время выполнения: списки и "скрытая" процедура `init`

**Сначала** прочитайте комментарии в [этой теме на форуме BYOND](http://www.byond.com/forum/?post=2086980&page=2#comment19776775), начиная с указанного места.

Здесь два ключевых момента:

1. Определение списка прямо в объявлении переменной вызывает скрытую процедуру `init`. Если список нужно создавать при запуске — делайте это в `New()` (или, что лучше, в `Initialize()`), чтобы избежать накладных расходов от двойного вызова (`Init()`, а затем `New()`).

2. Такой подход также потребляет больше памяти — список резервируется сразу, даже если объект, которому он принадлежит, никогда его не использует.

Помните: хотя такой компромисс часто оправдан, он не подходит для всех случаев. Внимательно подумайте, **действительно** ли он нужен в **вашем** случае.

### Приоритет `Initialize()` вместо `New()` для атомов

Наш игровой контроллер хорошо справляется с длительными операциями и лагами, но он **не может** повлиять на то, что происходит при загрузке карты, когда вызывается `New()` для всех атомов на карте. Если вы создаёте новый атом — используйте процедуру `Initialize()` **вместо** `New()` для инициализации. Это уменьшит количество вызовов процедур при загрузке мира.

Обычно мы требуем обновлять устаревший код, если вы вносите правки рядом с ним. Однако это правило **не распространяется** на замену `New()` → `Initialize()`. Такие системы сильно зависят от иерархии наследования, и неосторожная модификация существующего кода может привести к багам, которые проявятся только через месяцы.

### Не используйте неявный `var/`

При объявлении параметров процедуры префикс `var/` подразумевается **автоматически**. Не включайте его явно.

Пример:

```DM
// Плохо
obj/item/proc1(var/input1, var/input2)

// Хорошо
obj/item/proc1(input1, input2)
```

### Не используйте "магические" числа и строки

Это означает использование переменных вроде `mode = 1` или `mode = 2` без пояснения, что они значат. **Вместо этого** создавайте `#define` с понятными именами.

Пример:

```DM
/datum/proc/do_the_thing(thing_to_do)
  switch(thing_to_do)
    if(1)
      (...)
    if(2)
      (...)
```

Непонятно, что означают `1` и `2`. Лучше сделать так:

```DM
#define DO_THE_THING_REALLY_HARD 1
#define DO_THE_THING_EFFICIENTLY 2
/datum/proc/do_the_thing(thing_to_do)
  switch(thing_to_do)
    if(DO_THE_THING_REALLY_HARD)
      (...)
    if(DO_THE_THING_EFFICIENTLY)
      (...)
```

Это делает код читабельнее. **Привыкайте** так писать!

### Управляющие конструкции

(`if`, `while`, `for` и т.д.)

- В одной строке с управляющей конструкцией не должно быть кода: `if(condition) return ...` — запрещено.
- При сравнении переменной с числом используйте форму `переменная оператор число`, а не наоборот.
	Например: `if(count <= 10)`, а не `if(10 >= count)`.
- Управляющие конструкции должны быть записаны как `if()`, без пробела между ключевым словом и скобками.

### Используйте ранний возврат

Он же "early return", он же "ранний ретёрн".
Не оборачивайте всю процедуру в `if`-блок, если можно **просто вернуться** при невыполнении условия.

Пример:

```DM
// Плохо
/datum/datum1/proc/proc1()
  if(thing1)
    if(!thing2)
      if(thing3 == 30)
        сделать чё-то

// Хорошо
/datum/datum1/proc/proc1()
  if(!thing1)
    return
  if(thing2)
    return
  if(thing3 != 30)
    return
  сделать чё-то
```

Это предотвращает чрезмерную вложенность и облегчает читаемость кода.

### Используйте `addtimer()` вместо `sleep()` или `spawn()`

Если вам нужно вызвать процедуру через определённое время — используйте `addtimer()` **вместо** `spawn()` и `sleep()` там, где это возможно.
Хотя это сложнее, это **производительнее** и, в отличие от `spawn()` или `sleep()`, может быть **отменено**.
Подробнее: https://github.com/tgstation/tgstation/pull/22933.

Пример:

```DM
// Плохо
/datum/datum1/proc/proc1()
  spawn(5)
  dothing(arg1, arg2, arg3)

// Хорошо
  addtimer(CALLBACK(procsource, PROC_REF(dothing), arg1, arg2, arg3), waittime, timertype)
```

### Операторы

#### Пробелы

- Разделяемые пробелами операторы:
  - Булевы и логические операторы: `&&`, `||`, `<`, `>`, `==` и т.д. (но не `!`)
  - Побитовое И: `&`
  - Разделители аргументов: `,` (и `;` в `for`-циклах)
  - Операторы присваивания: `=`, `+=` и т.д.
  - Математические операторы: `+`, `-`, `/`, `*`
- Неразделяемые пробелами операторы:
  - Побитовое ИЛИ: `|`
  - Операторы доступа: `.`, `:`
  - Скобки: `()`
  - Логическое НЕ: `!`

#### Использование

- Побитовое И - `&`
  - Пишите как `bitfield & bitflag`, но **НИКОГДА** не `bitflag & bitfield`,  хотя оба варианта работают, обратный порядок нестандартен и запутывает.
- В ассоциативных списках ключи-строки должны быть в кавычках:
  - ПЛОХО: `list(a = "b")`
  - ХОРОШО: `list("a" = "b")`

#### Битовые флаги

- Мы предпочитаем использовать побитовые сдвиги вместо прямого указания чисел.
  ```DM
  // Хорошо
  #define MACRO_ONE (1<<0)
  #define MACRO_TWO (1<<1)
  #define MACRO_THREE (1<<2)
  #define MACRO_ALL (~0)

  // Плохо
  #define MACRO_ONE 1
  #define MACRO_TWO 2
  #define MACRO_THREE 4
  #define MACRO_ALL 7 // или 16777215 как более аккуратное
  ```
  Это делает код читабельнее и снижает вероятность ошибок.

### Устаревший код (legacy)

В коде игры много устаревшего кода, который более не принимается. Вот примеры:

- Не используйте цветовые макросы (`\red`, `\blue` и т.д.). Вместо этого — `span`-макросы. (`span_warning("Красный текст")`, `span_notice("blue text")`).
  -
  ```DM
  // Плохо
  to_chat("\red Красный текст \black чёрный текст")
  to_chat("<span class='warning'>Красный текст</span>")

  // Хорошо
  to_chat("[span_warning("Красный текст")] чёрный текст")
  ```
- При обращении к переменной/процедуре объекта не пишите
  `src.var`/`src.proc()` — `src.` подразумевается автоматически:

  ```DM
  // Плохо
  var/user = src.interactor
  src.fillReserves(user)

  // Хорошо
  var/user = interactor
  fillReserves(user)
  ```

### Пишите безопасный код

- Входные данные от игроков всегда должны быть экранированы. Используйте `stripped_input` вместо обычного `input`. Считайте, что любой ввод от игрока — потенциально вредоносный.

- Запросы к базе данных должны использовать параметры (значения с `:`). Это предотвращает SQL-инъекции.

  ```DM
	// Плохо
  	var/datum/db_query/query_watch = SSdbcore.NewQuery("SELECT reason FROM [format_table_name("watch")] WHERE ckey='[target_ckey]'")

  	// Хорошо
  	var/datum/db_query/query_watch = SSdbcore.NewQuery("SELECT reason FROM [format_table_name("watch")] WHERE ckey=:target_ckey", list(
  		"target_ckey" = target_ckey
  	))
  ```

- Все вызовы `/Topic()` должны проверяться на корректность. Клиенты легко могут подделать вызов, поэтому убедитесь, что он допустим для текущего состояния объекта. **Не полагайтесь на UI**!

- Информация, которую игроки могут использовать для метаигры (например, определение типа антагониста или стадии раунда), должна быть доступна **только** администраторам.

- Функции, способные вызвать масштабные изменения или хаос (вкладка "Веселье"), должны быть изначально **заблокированы** за одной из стандартных админ-ролей. Выбирайте роль по уровню потенциального ущерба.

### Файлы

- Поскольку ошибки времени выполнения не показывают полный путь, старайтесь избегать файлов с одинаковыми именами в разных папках.

- Имена файлов не должны содержать заглавных букв, пробелов или символов, требующих экранирования в URI.

- Все файлы и пути, на которые есть ссылки в коде (кроме #include), должны быть **строго** в нижнем регистре, чтобы избежать проблем на чувствительных к регистру файловых системах.

### SQL

- Do not use the shorthand sql insert format (where no column names are specified) because it unnecessarily breaks all queries on minor column changes and prevents using these tables for tracking outside related info such as in a connected site/forum.

- Use parameters for queries (Mentioned above in) [###Develop Secure Code](###Develop Secure Code)

- Always check your queries for success with if(!query.warn_execute()). By using this standard format, you can ensure the correct log messages are used

- Always qdel() your queries after you are done with them, this cleans up the results and helps things run smoother

- All changes to the database's layout(schema) must be specified in the database changelog in SQL, as well as reflected in the schema files

- Any time the schema is changed the `SQL_VERSION` defines must be incremented, as well as the example config, with an appropriate conversion kit placed
  in the SQL/updates folder.

- Queries must never specify the database, be it in code, or in text files in the repo.

## Изменение кода на языке Rust //TODO: перевести блин

Некоторые части кода написаны на [Rust][] по соображениям производительности и надёжности:

- Атмосферный движок, "MILLA", находящийся в директории `rust/src/milla/`.
- Модуль `mapmanip` от "Aurora Station" используемый для автоматизации изменения `DMM`-файлов, находящийся в директории `rust/src/mapmanip`.

Все Rust-компоненты в билде компилируются в единую библиотеку, отдельную от остального кода.
Если вы используете Windows, то по умолчанию получаете уже собранную версию.
Если вы на Linux — вы уже собирали её самостоятельно, чтобы запустить сервер.

Если вы вносите изменения в Rust-библиотеку, вам нужно будет пересобрать её. Процесс почти идентичен тому, что используется в проекте [rust-g][]. Единственное отличие — команду `cargo` следует запускать из директории `rust/`, при этом указывать флаг `--all-features` не обязательно (хотя это и не повредит).

Сервер автоматически обнаружит вашу локальную сборку и будет использовать её вместо стандартной Windows-версии.

Когда будете готовы создавать PR, **НЕ ИЗМЕНЯЙТЕ** файлы `rustlibs.dll` или `tools/ci/librustlibs_ci.so`. Оставьте опцию `"Allow edits and access to secrets by maintainers"` включённой и оставьте следующий комментарий в своём PR: `!build_rust`. Бот автоматически соберёт нужные файлы и обновит вашу ветку.

[Rust]: https://www.rust-lang.org/
[rust-g]: https://github.com/ParadiseSS13/rust-g

### Mapping Standards

- Map Merge

  - You MUST run Map Merge prior to opening your PR when updating existing maps to minimize the change differences (even when using third party mapping programs such as FastDMM.)
    - Failure to run Map Merge on a map after using third party mapping programs (such as FastDMM) greatly increases the risk of the map's key dictionary
      becoming corrupted by future edits after running map merge. Resolving the corruption issue involves rebuilding the map's key dictionary;

- Variable Editing (Var-edits)
  - While var-editing an item within the editor is perfectly fine, it is preferred that when you are changing the base behavior of an item (how it functions) that you make a new subtype of that item within the code, especially if you plan to use the item in multiple locations on the same map, or across multiple maps. This makes it easier to make corrections as needed to all instances of the item at one time as opposed to having to find each instance of it and change them all individually.
    - Subtypes only intended to be used on away mission or ruin maps should be contained within an .dm file with a name corresponding to that map within `code\modules\awaymissions` or `code\modules\ruins` respectively. This is so in the event that the map is removed, that subtype will be removed at the same time as well to minimize leftover/unused data within the repo.
  - Please attempt to clean out any dirty variables that may be contained within items you alter through var-editing. For example, due to how DM functions, changing the `pixel_x` variable from 23 to 0 will leave a dirty record in the map's code of `pixel_x = 0`. Likewise this can happen when changing an item's icon to something else and then back. This can lead to some issues where an item's icon has changed within the code, but becomes broken on the map due to it still attempting to use the old entry.
  - Areas should not be var-edited on a map to change it's name or attributes. All areas of a single type and it's altered instances are considered the same area within the code, and editing their variables on a map can lead to issues with powernets and event subsystems which are difficult to debug.

### Other Notes

- Code should be modular where possible; if you are working on a new addition, then strongly consider putting it in its own file unless it makes sense to put it with similar ones (i.e. a new tool would go in the "tools.dm" file)

- Bloated code may be necessary to add a certain feature, which means there has to be a judgement over whether the feature is worth having or not. You can help make this decision easier by making sure your code is modular.

- You are expected to help maintain the code that you add, meaning that if there is a problem then you are likely to be approached in order to fix any issues, runtimes, or bugs.

- If you used regex to replace code during development of your code, post the regex in your PR for the benefit of future developers and downstream users.

- All new var/proc names should use the American English spelling of words. This is for consistency with BYOND.

### Dream Maker Quirks/Tricks

Like all languages, Dream Maker has its quirks, some of them are beneficial to us, like these

#### In-To for-loops

`for(var/i = 1, i <= some_value, i++)` is a fairly standard way to write an incremental for loop in most languages (especially those in the C family), but
DM's `for(var/i in 1 to some_value)` syntax is oddly faster than its implementation of the former syntax; where possible, it's advised to use DM's syntax. (
Note, the `to` keyword is inclusive, so it automatically defaults to replacing `<=`; if you want `<` then you should write it as `1 to
some_value-1`).

HOWEVER, if either `some_value` or `i` changes within the body of the for (underneath the `for(...)` header) or if you are looping over a list AND
changing the length of the list then you can NOT use this type of for-loop!

### for(var/A in list) VS for(var/i in 1 to list.len)

The former is faster than the latter, as shown by the following profile results:
https://file.house/zy7H.png
Code used for the test in a readable format:
https://pastebin.com/w50uERkG

#### Istypeless for loops

A name for a differing syntax for writing for-each style loops in DM. It's NOT DM's standard syntax, hence why this is considered a quirk. Take a look at this:

```DM
var/list/bag_of_items = list(sword, apple, coinpouch, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_items)
  if(!best_sword || S.damage > best_sword.damage)
    best_sword = S
```

The above is a simple proc for checking all swords in a container and returning the one with the highest damage, and it uses DM's standard syntax for a
for-loop by specifying a type in the variable of the for's header that DM interprets as a type to filter by. It performs this filter using `istype()` (or
some internal-magic similar to `istype()` - this is BYOND, after all). This is fine in its current state for `bag_of_items`, but if `bag_of_items`
contained ONLY swords, or only SUBTYPES of swords, then the above is inefficient. For example:

```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/obj/item/sword/S in bag_of_swords)
  if(!best_sword || S.damage > best_sword.damage)
    best_sword = S
```

specifies a type for DM to filter by.

With the previous example that's perfectly fine, we only want swords, but here the bag only contains swords? Is DM still going to try to filter because we gave
it a type to filter by? YES, and here comes the inefficiency. Wherever a list (or other container, such as an atom (in which case you're technically accessing
their special contents list, but that's irrelevant)) contains datums of the same datatype or subtypes of the datatype you require for your loop's body,
you can circumvent DM's filtering and automatic `istype()` checks by writing the loop as such:

```DM
var/list/bag_of_swords = list(sword, sword, sword, sword)
var/obj/item/sword/best_sword
for(var/s in bag_of_swords)
  var/obj/item/sword/S = s
  if(!best_sword || S.damage > best_sword.damage)
    best_sword = S
```

Of course, if the list contains data of a mixed type then the above optimisation is DANGEROUS, as it will blindly typecast all data in the list as the
specified type, even if it isn't really that type, causing runtime errors (AKA your shit won't work if this happens).

#### Dot variable

Like other languages in the C family, DM has a `.` or "Dot" operator, used for accessing variables/members/functions of an object instance.
eg:

```DM
var/mob/living/carbon/human/H = YOU_THE_READER
H.gib()
```

However, DM also has a dot variable, accessed just as `.` on its own, defaulting to a value of null. Now, what's special about the dot operator is that it is automatically returned (as in the `return` statement) at the end of a proc, provided the proc does not already manually return (`return count` for example.) Why is this special?

With `.` being everpresent in every proc, can we use it as a temporary variable? Of course we can! However, the `.` operator cannot replace a typecasted variable - it can hold data any other var in DM can, it just can't be accessed as one, although the `.` operator is compatible with a few operators that look weird but work perfectly fine, such as: `.++` for incrementing `.'s` value, or `.[1]` for accessing the first element of `.`, provided that it's a list.

## Globals versus static

DM has a var keyword, called global. This var keyword is for vars inside of types. For instance:

```DM
/mob
  var/global/thing = TRUE
```

This does NOT mean that you can access it everywhere like a global var. Instead, it means that that var will only exist once for all instances of its type, in this case that var will only exist once for all mobs - it's shared across everything in its type. (Much more like the keyword `static` in other languages like PHP/C++/C#/Java)

Isn't that confusing?

There is also an undocumented keyword called `static` that has the same behaviour as global but more correctly describes BYOND's behaviour. Therefore, we always use static instead of global where we need it, as it reduces suprise when reading BYOND code.

### Global Vars

All new global vars must use the defines in code/\_\_DEFINES/\_globals.dm. Basic usage is as follows:

To declare a global var:

```DM
GLOBAL_VAR(my_global_here)
```

To access it:

```
GLOB.my_global_here = X
```

There are a few other defines that do other things. `GLOBAL_REAL` shouldn't be used unless you know exactly what you're doing.
`GLOBAL_VAR_INIT` allows you to set an initial value on the var, like `GLOBAL_VAR_INIT(number_one, 1)`.
`GLOBAL_LIST_INIT` allows you to define a list global var with an initial value. Etc.

## Maintainers and Review Team

There are two official roles for GitHub: `Maintainer` and `Review Team`. First ones have ability to merge and close
pull requests by themselfs. The Review Team has ability to approve pull requests. After two approves PR will be sent
to the Merge Queue.

### Review Team instructions

- Do not `self-approve`; this refers to the practice of opening a pull request, then
  approve it yourself.
- Wait for the CI build to complete. If it fails, the pull request may only be
  merged if there is a very good reason (example: fixing the CI configuration).
- PRs with MAP label must have at least one Map Review Team approve before sending to Merge Queue
