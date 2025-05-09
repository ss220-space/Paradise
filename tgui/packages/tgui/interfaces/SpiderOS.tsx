import { Component, Fragment, ReactNode } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  ProgressBar,
  Dropdown,
  NoticeBox,
  DmIcon,
  ImageButton,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { Placement } from '@popperjs/core';

const helpButtonsData = [
  {
    icon_state: 'headset_green',
    tooltipTitle: 'Ваш наушник',
    tooltipContent: `В отличии от стандартных наушников большинства корпораций, наш вариант создан специально для помощи в вашем внедрении. \
В него встроен специальный канал для общения с вашим боргом или другими членами клана.
\nК тому же он способен просканировать любые другие наушники и скопировать доступные для прослушки и/или разговора каналы их ключей.
Благодаря этому вы можете постепенно накапливать необходимые вам местные каналы связи для получения любой информации.
\nТак же ваш наушник автоматически улавливает и переводит бинарные сигналы генерируемые синтетиками при общении друг с другом. \
К тому же позволяя вам самим общаться с ними.`,
  },
  {
    icon_state: 'ninja_sleeper',
    tooltipTitle: 'Похищение экипажа',
    tooltipContent: `Порой клану нужны сведения которыми могут обладать люди работающие на обьекте вашей миссии. \
В такой ситуации вам становится доступно особое устройство для сканирования чужого разума. \
Даже если вам не удастся найти обладающего всей информацией человека, можно будет собрать информацию по крупицам продолжая похищать людей.
\nДля того, чтобы успешно похитить людей. У вас на шаттле есть скафандры, а на базе запас наручников, кислорода и баллонов. \
\nТак же напоминаем, что ваши перчатки способны направлять в людей электрический импульс, эффективно станя их на короткое время. `,
  },
  {
    icon_state: 'ai_face',
    tooltipTitle: 'Саботаж ИИ',
    tooltipContent: `Иногда у нас заказывают саботаж Искусственного интеллекта на обьектах операции. Это процесс сложный и требующий от нас основательной подготовки. \
\nПредпочитаемый кланом метод это создание уязвимости прямо в загрузочной для законов позволяющей вывести ИИ из строя. \
В результате такого метода мы можем легко перегрузить ИИ абсурдными законами, но это ограничивает нас в том плане, что для взлома в итоге подходят только консоли в самой загрузочной.
Так же взлом задача нелёгкая - системы защиты есть везде. А процесс занимает время. Не удивляйтесь если ИИ будет противодействовать вашим попыткам его сломать.`,
  },
  {
    icon_state: 'ninja_borg',
    tooltipTitle: 'Саботаж роботов',
    tooltipContent: `Иногда оценивая ваши шансы на выполнение миссии для их увеличения на обьектах, \
что используют роботов для своих целей, мы даём вам особый "Улучшающий" их прибор, встроенный в ваши перчатки. \
\nПри взломе киборга таким прибором(Взлом занимает время) вы получите лояльного клану и вам лично \
слугу способного на оказание помощи как в саботаже станции так и в вашем лечении. \
\nТак же робот будет оснащён личной катаной, устройством маскировки, пинпоинтером указывающим ему на вас и генератором электрических сюрикенов. \
Помните, что катана робота не способна обеспечить его блюспейс транслокацию!`,
  },
  {
    icon_state: 'server',
    tooltipTitle: 'Саботаж исследований',
    tooltipContent: `На научных обьектах всегда есть своя команда учёных и множество данных которые приходится где то хранить. \
В качестве такого обьекта обычно выступают сервера. А как известно корпорации вечно грызутся за знания. Что нам на руку. \
\nМы разработали специальный вирус который будет записан на ваши перчатки перед миссией такого рода. \
Вам нужно будет лишь загрузить его напрямую на их научный сервер и все их исследования будут утеряны. \
\nНо загрузка вируса требует времени, и системы защиты многих обьектов не дремлют. \
Скорее всего о вашей попытке взлома будет оповещён местный ИИ. Будьте готовы к этому.`,
  },
  {
    icon_state: 'buckler',
    tooltipTitle: 'Защита цели',
    tooltipContent: `Иногда богатые шишки платят за услуги защиты определённого человека. Если вам досталась такая цель помните следующее:
\n * Защищаемый обязан дожить до конца смены! \
\n * Скорее всего защищаемый не знает о вашей задаче. И лучше всего чтобы он и дальше не знал! \
\n * Не важно кто или что охотится на вашего подзащитного, но для обьекта где проходит миссия вы всегда нежеланное лицо. \
Не раскрывайте себя без нужды, чтобы упростить себе же работу и на вас самих не вели охоту! \
\nТак же мы напоминаем, что клан не одобряет варварские методы "Защиты" цели. Нет вы не можете посадить защищаемого в клетку и следить за ним там! \
Не портите нашу репутацию в глазах наших клиентов!`,
  },
  {
    icon_state: 'cash',
    tooltipTitle: 'Кража денег',
    tooltipContent: `Как бы это не было тривиально. Иногда клан нуждается в деньгах. Или даже возможно вы задолжали нам. \
В таком случае мы скорее всего дадим вам задачу достать для нас эти деньги на следующей вашей миссии. \
\nДля вас эта задача не трудная, но времязатратная. Помните, что вы натренированы в искусстве незаметных карманных краж. \
Вы можете это использовать для кражи чужих карт и обналичивания их счетов. Либо можете метить выше и ограбить хранилища или счета самого обьекта вашей миссии.
Самое главное. Достаньте эти деньги!`,
  },
  {
    icon_state: 'handcuff',
    tooltipTitle: 'Подставить человека',
    tooltipContent: `В некоторых ситуациях чужой позор для клиентов гораздо интереснее чем смерть. \
В таких случаях вам прийдётся проявить креативность и добиться того, чтобы вашу жертву по законным основаниям упекли за решётку \
Самое главное чтобы в криминальной истории цели остался след. \
Но в то же время просто прийти и вписать цели срок в консоли - не рабочий метод. Цель легко оправдают в суде, что не устроит клиента.
\n У вас достаточно инструментов, чтобы совершить преступление под личиной цели. \
Главное постарайтесь обойтись без слишком больших последствий. Лишняя дыра в обшивке станции или трупы - увеличивают шансы провала вашего плана.`,
  },
];

const abilityButtons = {
  ghost: [
    {
      style: 'smoke',
      row: '1',
      iconState: 'smoke',
      title: 'ДЫМОВАЯ ЗАВЕСА',
      content: `Вы создаёте большое облако дыма чтобы запутать своих врагов.
Эта способность отлично сочетается с вашим визором в режиме термального сканера.
А так же автоматически применяется многими другими модулями если вы того пожелаете.
Стоимость активации: 1000 ед. энергии.
Стоимость автоматической активации: 250 ед. энергии.
Перезарядка: 3 секунды.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'ninja_cloak',
      row: '2',
      iconState: 'ninja_cloak',
      title: 'НЕВИДИМОСТЬ',
      content: `Вы формируете вокруг себя маскировочное поле скрывающее вас из виду и приглушающее ваши шаги.
Поле довольно хрупкое и может разлететься от любого резкого действия или удара.
Активация поля занимает 2 секунды. Хоть поле и скрывает вас полностью, настоящий убийца должен быть хладнокровен.
Не стоит недооценивать внимательность других людей.
Активная невидимость слабо увеличивает пассивный расход энергии.
Перезарядка: 15 секунд.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'ninja_clones',
      row: '3',
      iconState: 'ninja_clones',
      title: 'ЭНЕРГЕТИЧЕСКИЕ КЛОНЫ',
      content: `Создаёт двух клонов готовых помочь в битве и дезориентировать противника.
Так же в процессе смещает вас и ваших клонов в случайном направлении в радиусе пары метров.
Пользуйтесь осторожно. Случайное смещение может запереть вас за 4-мя стенами. Будьте к этому готовы.
Клоны существуют примерно 20 секунд. Клоны имеют шанс размножится атакуя противников.
Стоимость активации: 4000 ед. энергии.
Перезарядка: 8 секунд.`,
      tooltipPosition: 'right',
    },
    {
      style: 'chameleon',
      row: '4',
      iconState: 'chameleon',
      title: 'ХАМЕЛЕОН',
      content: `Вы формируете вокруг себя голографическое поле искажающее визуальное и слуховое восприятие других существ.
Вас будут видеть и слышать как человека которого вы просканируете специальным устройством.
Это даёт вам огромный простор по внедрению и имитации любого члена экипажа.
Поле довольно хрупкое и может разлететься от любого резкого действия или удара.
Активация поля занимает 2 секунды.
Активный хамелеон слабо увеличивает пассивный расход энергии.
Перезарядка: Отсутствует.`,
      tooltipPosition: 'right',
    },
    {
      style: 'ninja_spirit_form',
      row: '5',
      iconState: 'ninja_spirit_form',
      title: 'ФОРМА ДУХА',
      content: `Вы воздействуете на стабильность собственного тела посредством этой эксперементальной технологии.
Делая ваше тело нестабильным эта способность дарует вам возможность проходить сквозь стены.
Эта эксперементальная технология не сделает вас неуязвимым для пуль и лезвий!
Но позволит вам снять с себя наручники, болы и даже вылезти из гроба или ящика, окажись вы там заперты...
Активация способности мгновенна.
Активная форма духа значительно увеличивает пассивный расход энергии! Потребление одинаково большое вне зависимости от объёма батареи.
Перезарядка: 25 секунд.`,
      tooltipPosition: 'right',
    },
  ],
  snake: [
    {
      style: 'kunai',
      row: '1',
      icon_state: 'kunai',
      title: 'ВСТРОЕННОЕ ДЖОХЬЁ',
      content: `Так же известно как Шэнбяо или просто Кинжал на цепи.
  Интегрированное в костюм устройство запуска позволит вам поймать и притянуть к себе жертву за доли секунды.
  Оружие не очень годится для долгих боёв, но отлично подходит для вытягивания одной жертвы - на расстояние удара!
  Главное не промахиваться при стрельбе.
  Стоимость выстрела: 500 ед. энергии.
  Перезарядка: 5 секунд.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'chem_injector',
      row: '2',
      icon_state: 'chem_injector',
      title: 'ИСЦЕЛЯЮЩИЙ КОКТЕЙЛЬ',
      content: `Вводит в вас эксперементальную лечебную смесь. Способную залечить даже сломанные кости и оторванные конечности.
  Препарат вызывает пространст-
  венно-временные парадоксы и очень медленно выводится из организма!
  При передозировке они становятся слишком опасны для пользователя. Не вводите больше 30 ед. препарата в ваш организм!
  Вместо траты энергии имеет 3 заряда. Их можно восстановить вручную с помощью цельных кусков блюспейс кристаллов помещённых в костюм.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'emergency_blink',
      row: '3',
      icon_state: 'emergency_blink',
      title: 'ЭКСТРЕННАЯ ТЕЛЕПОРТАЦИЯ',
      content: `При использовании мгновенно телепортирует пользователя в случайную зону в радиусе около двух десятков метров.
  Для активации используются мозговые импульсы пользователя. Поэтому опытные воины клана, могут использовать её даже во сне.
  Стоимость активации: 1500 ед. энергии.
  Перезарядка: 3 секунды.`,
      tooltipPosition: 'right',
    },
    {
      style: 'caltrop',
      row: '4',
      icon_state: 'caltrop',
      title: 'ЭЛЕКТРО-ЧЕСНОК',
      content: `Чаще их называют просто калтропы, из-за запутывающих ассоциаций с более съестным чесноком.
  При использовании раскидывает позади вас сделанные из спрессованной энергии ловушки.
  Ловушки существуют примерно 10 секунд. Так же они пропадают - если на них наступить.
  Боль от случайного шага на них настигнет даже роботизирован- ные конечности.
  Вы не защищены от них. Не наступайте на свои же ловушки!
  Стоимость активации: 1500 ед. энергии.
  Перезарядка: 1 секунда.`,
      tooltipPosition: 'right',
    },
    {
      style: 'cloning',
      row: '5',
      icon_state: 'cloning',
      title: 'ВТОРОЙ ШАНС',
      content: `В прошлом многие убийцы проваливая свои миссии совершали самоубийства или оказывались в лапах врага.
  Сейчас же есть довольно дорогая альтернатива. Мощное устройство способное достать вас практически с того света.
  Эта машина позволит вам получить второй шанс, телепортировав вас к себе и излечив любые травмы.
  Мы слышали про сомнения завязанные на идее, что это просто устройство для клонирования членов клана. Но уверяем вас, это не так.
  К сожалению из-за больших затрат на лечение и телепортацию. Устройство спасёт вас лишь один раз.
  Устройство активируется автоматически, когда вы будете при смерти.`,
      tooltipPosition: 'right',
    },
  ],
  steel: [
    {
      style: 'shuriken',
      row: '1',
      icon_state: 'shuriken',
      title: 'ЭНЕРГЕТИЧЕСКИЕ СЮРИКЕНЫ',
      content: `Активирует пусковое устройство скрытое в перчатках костюма.
  Устройство выпускает по три сюрикена, сделанных из сжатой энергии, очередью.
  Сюрикены постепенно изнуряют врагов и наносят слабый ожоговый урон.
  Так же они пролетают через стекло, как и обычные лазерные снаряды.
  Стоимость выстрела: 300 ед. энергии.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'adrenal',
      row: '2',
      icon_state: 'adrenal',
      title: 'ВСПЛЕСК АДРЕНАЛИНА',
      content: `Мгновенно вводит в вас мощную эксперементальную сыворотку ускоряющую вас в бою и помогающую быстрее оклематься от оглушающих эффектов.
  Костюм производит сыворотку с использованием урана. Что к сожалению даёт неприятный негативный эффект, в виде накопления радия в организме пользователя.
  Вместо траты энергии может быть использовано лишь один раз, пока не будет перезаряжено вручную с помощью цельных кусков урана помещённых в костюм.`,
      tooltipPosition: 'bottom-end',
    },
    {
      style: 'emp',
      row: '3',
      icon_state: 'emp',
      title: 'ЭЛЕКТРОМАГНИТНЫЙ ВЗРЫВ',
      content: `Электромагнитные волны выключают, подрывают или иначе повреждают - киборгов, дронов, КПБ, энергетическое оружие, портативные Светошумовые устройства, устройства связи и т.д.
  Этот взрыв может как помочь вам в бою, так и невероятно навредить. Внимательно осматривайте местность перед применением.
  Не забывайте о защищающем от света режиме вашего визора. Он может помочь не ослепнуть, при подрыве подобных устройств.
  Взрыв - прерывает пассивные эффекты наложенные на вас. Например невидимость.
  Стоимость активации: 5000 ед. энергии.
  Перезарядка: 4 секунды.`,
      tooltipPosition: 'right',
    },
    {
      style: 'energynet',
      row: '4',
      icon_state: 'energynet',
      title: 'ЭНЕРГЕТИЧЕСКАЯ СЕТЬ',
      content: `Мгновенно ловит выбранную вами цель в обездвиживающую ловушку.
  Из ловушки легко выбраться просто сломав её любым предметом.
  Отлично подходит для временной нейтрализации одного врага.
  К тому же в неё можно поймать агрессивных животных или надоедливых охранных ботов.
  Учитывайте, что сеть не мешает жертве отстреливаться от вас.
  Так же сеть легко покинуть другим путём, например телепортацией.
  Активация сети - прерывает пассивные эффекты наложенные на вас. Например невидимость.
  Стоимость активации: 4000 ед. энергии.`,
      tooltipPosition: 'right',
    },
    {
      style: 'spider_red',
      row: '5',
      icon_state: 'spider_red',
      title: 'БОЕВОЕ ИСКУССТВО \nПОЛЗУЧЕЙ ВДОВЫ',
      content: `Боевое искусство ниндзя сосредоточенное на накоплении концентрации для использования приёмов.
  В учение входят следующие приёмы:
  Выворачивание руки - заставляет жертву выронить своё оружие.
  Удар ладонью - откидывает жертву на несколько метров от вас, лишая равновесия.
  Перерезание шеи - мгновенно обезглавливает лежачую жертву катаной во вспомогательной руке.
  Энергетическое торнадо - раскидывает врагов вокруг вас и создаёт облако дыма при наличии активного дымового устройства и энергии.
  Так же вы обучаетесь с определённым шансом отражать сняряды врагов обратно.`,
      tooltipPosition: 'right',
    },
  ],
};

type SpiderOSData = {
  suit_tgui_state: number;
  stylesIcon: string;
  style_preview_icon_state: string;
  end_terminal: boolean;
  current_load_text: string;
  randomPercent: number;
  actionsIcon: string;
  color_choice: string;
  blocked_TGUI_rows: boolean[];
  status: string;
  player_pos: string;
  shuttle: boolean;
  docking_ports_len: number;
  docking_ports: Port[];
  admin_controlled: boolean;
  designs: string[];
  design_choice: string;
  scarf_design_choice: string;
  colors: string[];
  genders: string[];
  preferred_clothes_gender: string;
  suit_state: boolean;
  preferred_scarf_over_hood: boolean;
  show_charge_UI: boolean;
  has_martial_art: boolean;
  show_concentration_UI: boolean;
};

type Port = {
  name: string;
  id: string;
};

export const SpiderOS = (_properties) => {
  const { act, data } = useBackend<SpiderOSData>();
  let body: ReactNode;
  if (data.suit_tgui_state === 0) {
    let actionsCheck = !!data.blocked_TGUI_rows.filter((value) => !value)
      .length;
    body = (
      <Flex direction="row" spacing={1}>
        <Flex.Item width="55%">
          <Stack direction="column" fill mx={1}>
            <Stack.Item backgroundColor="rgba(0, 0, 0, 0)">
              <ActionBuyPanel actionsCheck={actionsCheck} />
            </Stack.Item>

            <Stack.Item mt={2.2} backgroundColor="rgba(0, 0, 0, 0)">
              <ShuttleConsole />
            </Stack.Item>
          </Stack>
        </Flex.Item>

        <Flex.Item
          width="45%"
          height="190px"
          grow={1}
          backgroundColor="rgba(0, 0, 0, 0)"
        >
          <Helpers />
          <StylesPreview />
          <SuitTuning />
        </Flex.Item>
      </Flex>
    );
  } else if (data.suit_tgui_state === 1) {
    body = (
      <Flex
        width="100%"
        height="100%"
        direction="column"
        shrink={1}
        spacing={1}
      >
        <Flex.Item backgroundColor="rgba(0, 0, 0, 0.8)" height="100%">
          <FakeLoadBar />
          <FakeTerminal
            allMessages={data.current_load_text}
            finishedTimeout={3000}
            end_terminal={data.end_terminal}
            onFinished={() => act('set_UI_state', { suit_tgui_state: 0 })}
          />
        </Flex.Item>
      </Flex>
    );
  }
  return (
    <Window width={800} height={730} theme="spider_clan">
      <Window.Content>
        <Flex direction="row" spacing={1}>
          {body}
        </Flex>
      </Window.Content>
    </Window>
  );
};

const StylesPreview = (_properties) => {
  const { data } = useBackend<SpiderOSData>();
  const { stylesIcon, style_preview_icon_state } = data;
  return (
    <Section
      title="Персонализация костюма"
      style={{ textAlign: 'center' }}
      m={1}
      width="97%"
      buttons={
        <Button
          tooltip={
            'Настройка внешнего вида вашего костюма!\
        Наши технологии позволяют вам подстроить костюм под себя, \
        при этом не теряя оборонительных качеств. \
        Потому что удобство при ношении костюма, жизненно важно для настоящего убийцы.'
          }
          tooltipPosition="bottom-start"
          icon={'question'}
          iconSize={0.8}
          mt={-0.5}
        />
      }
    >
      <Flex direction="column" grow={1} alignContent="center">
        <NoticeBox success align="center">
          <Section style={{ background: 'rgba(4, 74, 27, 0.75)' }} mt={0}>
            <DmIcon
              height="100px"
              width="100px"
              icon={stylesIcon}
              icon_state={style_preview_icon_state}
            />
          </Section>
        </NoticeBox>
      </Flex>
    </Section>
  );
};

const SuitTuning = (_properties) => {
  const { act, data } = useBackend<SpiderOSData>();
  const {
    designs,
    design_choice,
    scarf_design_choice,
    colors,
    color_choice,
    genders,
    preferred_clothes_gender,
    suit_state,
    preferred_scarf_over_hood,
    show_charge_UI,
    has_martial_art,
    show_concentration_UI,
  } = data;
  let dynamicButtonText: string;
  if (!suit_state) {
    dynamicButtonText = 'Активировать костюм';
  } else {
    dynamicButtonText = 'Деактивировать костюм';
  }

  let dynamicButtonText_scarf: string;
  if (!preferred_scarf_over_hood) {
    dynamicButtonText_scarf = 'Капюшон';
  } else {
    dynamicButtonText_scarf = 'Шарф';
  }

  let if_scarf: ReactNode;
  if (preferred_scarf_over_hood) {
    if_scarf = (
      <LabeledList.Item label={'Стиль шарфа'}>
        {
          <Dropdown
            options={designs}
            selected={scarf_design_choice}
            width={'60%'}
            onSelected={(val) =>
              act('set_scarf_design', { scarf_design_choice: val })
            }
          />
        }
      </LabeledList.Item>
    );
  } else {
    if_scarf = null;
  }

  let if_concentration: ReactNode;
  if (has_martial_art) {
    if_concentration = (
      <LabeledList.Item label={'Концентрация'}>
        <Box>
          <Button
            selected={show_concentration_UI}
            width="78px"
            textAlign="left"
            onClick={() => act('toggle_ui_concentration')}
          >
            {show_concentration_UI ? 'Показать' : 'Скрыть'}
          </Button>
          <Button
            textAlign="center"
            tooltip={
              'Включение или отключение интерфейса показывающего сконцентрированы ли вы для применения боевого исскуства.'
            }
            tooltipPosition="top-start"
            icon={'question'}
            iconSize={0.8}
          />
        </Box>
      </LabeledList.Item>
    );
  } else {
    if_concentration = null;
  }

  return (
    <Flex direction="row" grow={1} alignContent="center">
      <Flex.Item grow={1} width="100%" m={1} my={0}>
        <NoticeBox success align="center" fontSize={'14px'}>
          <LabeledList>
            <LabeledList.Item label="Стиль">
              <Dropdown
                options={designs}
                selected={design_choice}
                width={'60%'}
                onSelected={(val) => act('set_design', { design_choice: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет">
              <Dropdown
                options={colors}
                selected={color_choice}
                width={'60%'}
                onSelected={(val) => act('set_color', { color_choice: val })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Женский/Мужской">
              <Dropdown
                options={genders}
                selected={preferred_clothes_gender}
                width={'60%'}
                onSelected={(val) =>
                  act('set_gender', { preferred_clothes_gender: val })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Шарф/Капюшон">
              <Button
                className={!suit_state ? '' : 'Button_disabled'}
                width="90px"
                selected={preferred_scarf_over_hood}
                disabled={suit_state}
                textAlign="left"
                onClick={() => act('toggle_scarf')}
              >
                {dynamicButtonText_scarf}
              </Button>
              <Button
                textAlign="center"
                tooltip={
                  'С настройкой "Шарф" ваш капюшон больше не будет прикрывать волосы.\
                            Но это не значит, что ваша голова не защищена! \
                            Адаптивные нано-волокна костюма всё ещё реагируют на потенциальные угрозы прикрывая вашу голову! \
                            Уточнение: нановолокна так же будут прикрывать вашу голову и от других головных уборов \
                            с целью уменьшения помех в их работе.'
                }
                tooltipPosition="top-start"
                icon={'question'}
                iconSize={0.8}
              />
            </LabeledList.Item>
            {if_scarf}
            <LabeledList.Item label="Заряд костюма">
              <Button
                selected={show_charge_UI}
                width="90px"
                textAlign="left"
                onClick={() => act('toggle_ui_charge')}
              >
                {show_charge_UI ? 'Показать' : 'Скрыть'}
              </Button>
              <Button
                textAlign="center"
                tooltip={
                  'Включение или отключение интерфейса показывающего заряд вашего костюма.'
                }
                tooltipPosition="top-start"
                icon={'question'}
                iconSize={0.8}
              />
            </LabeledList.Item>
            {if_concentration}
          </LabeledList>
          <Button
            width="80%"
            mt={1}
            icon="power-off"
            textAlign="center"
            backgroundColor={color_choice}
            tooltip={
              'Позволяет вам включить костюм и получить доступ к применению всех функций в нём заложенных. \
              \nУчтите, что вы не сможете приобрести любые модули, когда костюм будет активирован. \
              \nТак же включённый костюм пассивно потребляет заряд для поддержания работы всех функций и модулей.\
              \nАктивированный костюм нельзя снять обычным способом, пока он не будет деактивирован.\
              \nВключение ровно как и выключение костюма занимает много времени. Подумайте дважды прежде, чем выключать его на территории врага!'
            }
            tooltipPosition="top-start"
            onClick={() => act('initialise_suit')}
          >
            {dynamicButtonText}
          </Button>
        </NoticeBox>
      </Flex.Item>
    </Flex>
  );
};

const Helpers = (_properties) => {
  const { data } = useBackend<SpiderOSData>();
  const { actionsIcon } = data;
  return (
    <Section
      m="0"
      title="Советы и подсказки"
      style={{ textAlign: 'center' }}
      buttons={
        <Button
          tooltip={
            'Молодым убийцам часто не легко освоится в полевых условиях, даже после интенсивных тренировок. \
        \nЭтот раздел призван помочь вам советами по определённым часто возникающим вопросам касательно возможных миссий которые вам выдадут\
        или рассказать о малоизвестной информации которую вы можете обернуть в свою пользу.'
          }
          tooltipPosition="bottom-start"
          icon={'question'}
          iconSize={0.8}
          mt={-0.5}
        />
      }
    >
      <Flex direction="column" grow={1} alignContent="center">
        <Flex.Item direction="row">
          {helpButtonsData.map(
            ({ icon_state, tooltipTitle, tooltipContent }, index) => (
              <ImageButton
                key={index}
                className="Button_green"
                height="32px"
                width="32px"
                dmIcon={actionsIcon}
                dmIconState={icon_state}
                tooltip={tooltipContent}
                tooltipPosition="bottom-start"
              >
                {tooltipTitle}
              </ImageButton>
            )
          )}
        </Flex.Item>
      </Flex>
    </Section>
  );
};

type ActionBuyPanelProps = {
  actionsCheck: boolean;
};

const ActionBuyPanel = (properties: ActionBuyPanelProps) => {
  const { act, data } = useBackend<SpiderOSData>();
  const { actionsIcon, blocked_TGUI_rows } = data;

  let rowStyles = [
    {
      blue: 'Button_blue',
      green: 'Button_green',
      red: 'Button_red',
      disabled: 'Button_disabled',
    },
  ];

  return (
    <Section
      title="Модули костюма"
      style={{ textAlign: 'center' }}
      overflowY={'scroll'}
      height="550px"
      buttons={
        <Button
          tooltip={
            'Устанавливаемые улучшения для вашего костюма!\
        Делятся на 3 разных подхода для выполнения вашей миссии.\
        Из-за больших требований по поддержанию работоспособности костюма,\
        приобретение любого модуля, блокирует приобретение модулей одного уровня из соседних столбцов'
          }
          tooltipPosition="bottom"
          icon={'question'}
          iconSize={0.8}
          mt={-0.5}
        />
      }
    >
      {properties.actionsCheck ? (
        <Flex direction="row" alignContent="center" ml={1.5}>
          <Flex.Item width="33%" shrink={1}>
            <Section
              width="100%"
              title="Призрак"
              height={'100%'}
              ml="0px"
              buttons={
                <Button
                  tooltip={
                    'Скрывайтесь среди врагов, нападайте из тени и будьте незримой угрозой, всё для того чтобы о вас и вашей миссии никто не узнал! Будьте незаметны как призрак!'
                  }
                  tooltipPosition="bottom"
                  icon={'question'}
                  iconSize={0.8}
                  mt={-0.5}
                />
              }
              style={{
                textAlign: 'center',
                background: 'rgba(53, 94, 163, 0.8)',
              }}
            >
              <NoticeBox
                className="NoticeBox_blue"
                success
                danger
                align="center"
              >
                {abilityButtons.ghost.map(
                  (
                    { style, row, iconState, title, content, tooltipPosition },
                    i
                  ) =>
                    !blocked_TGUI_rows[i] && (
                      <ImageButton
                        key={style}
                        className={
                          !blocked_TGUI_rows[i]
                            ? rowStyles[0].blue
                            : rowStyles[0].disabled
                        }
                        height="64px"
                        imageSize={90}
                        width="64px"
                        fontSize={'10px'}
                        dmIcon={actionsIcon}
                        dmIconState={iconState}
                        disabled={blocked_TGUI_rows[i]}
                        onClick={() => act('give_ability', { style, row })}
                        tooltip={content}
                        tooltipPosition={tooltipPosition as Placement}
                      >
                        {title}
                      </ImageButton>
                    )
                )}
              </NoticeBox>
            </Section>
          </Flex.Item>
          <Flex.Item width="33%" shrink={1}>
            <Section
              ml="0px"
              width="100%"
              title="Змей"
              height={'100%'}
              buttons={
                <Button
                  tooltip={
                    'Удивляйте! Трюки, ловушки, щиты. Покажите им, что такое бой с настоящим убийцей. Извивайтесь и изворачивайтесь находя выход из любой ситуации. Враги всего лишь грызуны, чьё логово навестил змей!'
                  }
                  tooltipPosition="bottom"
                  icon={'question'}
                  iconSize={0.8}
                  mt={-0.5}
                />
              }
              style={{
                textAlign: 'center',
                background: 'rgba(0, 174, 208, 0.15)',
              }}
            >
              <NoticeBox success align="center">
                {abilityButtons.snake.map(
                  (
                    { style, row, icon_state, title, content, tooltipPosition },
                    index
                  ) =>
                    !blocked_TGUI_rows[index] && (
                      <ImageButton
                        key={style}
                        className={
                          !blocked_TGUI_rows[index]
                            ? rowStyles[0].green
                            : rowStyles[0].disabled
                        }
                        height="64px"
                        imageSize={90}
                        width="64px"
                        fontSize={'10px'}
                        dmIcon={actionsIcon}
                        dmIconState={icon_state}
                        tooltip={content}
                        tooltipPosition={tooltipPosition as Placement}
                        disabled={blocked_TGUI_rows[index]}
                        onClick={() => act('give_ability', { style, row })}
                      >
                        {title}
                      </ImageButton>
                    )
                )}
              </NoticeBox>
            </Section>
          </Flex.Item>
          <Flex.Item width="33%" shrink={1}>
            <Section
              ml="0px"
              width="100%"
              title="Сталь"
              height={'100%'}
              buttons={
                <Button
                  tooltip={
                    'Ярость не доступная обычным людям. Сила, скорость и орудия выше их понимания. Разите их как хищник что разит свою добычу. Покажите им холодный вкус стали!'
                  }
                  tooltipPosition="bottom"
                  icon={'question'}
                  iconSize={0.8}
                  mt={-0.5}
                />
              }
              style={{
                textAlign: 'center',
                background: 'rgba(80, 20, 20, 1)',
              }}
            >
              <NoticeBox
                className="NoticeBox_red"
                success
                danger
                align="center"
              >
                {abilityButtons.steel.map(
                  (
                    { style, row, icon_state, title, content, tooltipPosition },
                    index
                  ) =>
                    !blocked_TGUI_rows[index] && (
                      <ImageButton
                        key={style}
                        className={
                          !blocked_TGUI_rows[index]
                            ? rowStyles[0].red
                            : rowStyles[0].disabled
                        }
                        height="64px"
                        imageSize={90}
                        width="64px"
                        fontSize={'10px'}
                        dmIcon={actionsIcon}
                        dmIconState={icon_state}
                        tooltip={content}
                        tooltipPosition={tooltipPosition as Placement}
                        disabled={blocked_TGUI_rows[index]}
                        onClick={() => act('give_ability', { style, row })}
                      >
                        {title}
                      </ImageButton>
                    )
                )}
              </NoticeBox>
            </Section>
          </Flex.Item>
        </Flex>
      ) : (
        <NoticeBox className="NoticeBox_red" success danger align="center">
          Все модули выбраны
        </NoticeBox>
      )}
    </Section>
  );
};

export const ShuttleConsole = (_properties) => {
  const { act, data } = useBackend<SpiderOSData>();
  return (
    <Section
      title="Управление шаттлом"
      mr="5px"
      style={{ textAlign: 'center' }}
      buttons={
        <Button
          tooltip={
            'Панель для удалённого управление вашим личным шаттлом. \
        Так же показывает вашу текущую позицию и позицию самого шаттла!'
          }
          tooltipPosition="right"
          icon={'question'}
          iconSize={0.8}
          mt={-0.5}
        />
      }
    >
      <Flex ml={2}>
        <LabeledList>
          <LabeledList.Item label="Позиция">
            {data.status ? (
              data.status
            ) : (
              <NoticeBox color="red">Shuttle Missing</NoticeBox>
            )}
          </LabeledList.Item>
          <LabeledList.Item label="Ваша позиция">
            {data.player_pos}
          </LabeledList.Item>
          {!!data.shuttle && // only show this stuff if there's a shuttle
            ((!!data.docking_ports_len && (
              <LabeledList.Item label={'Отправить шаттл'}>
                {data.docking_ports.map((port) => (
                  <Button
                    icon="chevron-right"
                    key={port.name}
                    onClick={() =>
                      act('move', {
                        move: port.id,
                      })
                    }
                  >
                    {port.name}
                  </Button>
                ))}
              </LabeledList.Item>
            )) || ( // ELSE, if there's no docking ports.
              <>
                <LabeledList.Item label="Status" color="red">
                  <NoticeBox color="red">Shuttle Locked</NoticeBox>
                </LabeledList.Item>
                {!!data.admin_controlled && (
                  <LabeledList.Item label="Авторизация">
                    <Button
                      icon="exclamation-circle"
                      disabled={!data.status}
                      onClick={() => act('request')}
                    >
                      Запросить авторизацию
                    </Button>
                  </LabeledList.Item>
                )}
              </>
            ))}
        </LabeledList>
      </Flex>
    </Section>
  );
};

const FakeLoadBar = (_properties) => {
  const { data } = useBackend<SpiderOSData>();
  const { randomPercent, actionsIcon, color_choice } = data;
  return (
    <Section stretchContents>
      <ProgressBar
        color={color_choice}
        value={randomPercent}
        minValue={0}
        maxValue={100}
      >
        <center>
          <NoticeBox className={'NoticeBox_' + color_choice} mt={1}>
            <DmIcon
              height="64px"
              width="64px"
              icon={actionsIcon}
              icon_state={'spider_' + color_choice}
              style={{
                marginLeft: '-6px',
              }}
            />
            <br />
            Loading {randomPercent + '%'}
          </NoticeBox>
        </center>
      </ProgressBar>
    </Section>
  );
};

type FakeTerminalProps = {
  linesPerSecond?: number;
  allMessages: string;
  end_terminal: boolean;
  onFinished: () => void;
  finishedTimeout?: number;
};

type FakeTerminalState = {
  lastText: string;
  currentDisplay: string[];
};

class FakeTerminal extends Component<FakeTerminalProps, FakeTerminalState> {
  timer: NodeJS.Timeout;
  constructor(props: FakeTerminalProps) {
    super(props);
    this.timer = null;
    this.state = {
      lastText: 'text do be there',
      currentDisplay: [],
    };
  }

  tick() {
    const { props, state } = this;
    if (props.allMessages !== state.lastText && !props.end_terminal) {
      const { currentDisplay } = state;
      currentDisplay.push(props.allMessages);
      this.setState({
        lastText: props.allMessages,
        currentDisplay: currentDisplay,
      });
    } else if (props.end_terminal) {
      clearTimeout(this.timer);
      setTimeout(props.onFinished, props.finishedTimeout);
    }
  }

  componentDidMount() {
    const { linesPerSecond = 2.5 } = this.props;
    this.timer = setInterval(() => this.tick(), 1000 / linesPerSecond);
  }

  componentWillUnmount() {
    clearTimeout(this.timer);
  }

  render() {
    return (
      <Box m={1}>
        {this.state.currentDisplay.map((value) => (
          <Fragment key={value}>
            {value}
            <br />
          </Fragment>
        ))}
      </Box>
    );
  }
}
