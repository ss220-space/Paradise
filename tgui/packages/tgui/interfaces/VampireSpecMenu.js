import { useBackend, useLocalState } from '../backend';
import { Button, Flex, Section, Divider, Tabs, Box } from '../components';
import { Window } from '../layouts';

export const VampireSpecMenu = (props, context) => {
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const decideTab = index => {
    switch (index) {
      case 0:
        return <HemoMenu />;
      case 1:
        return <UmbrMenu />;
      case 2:
        return <GarMenu />;
      case 3:
        return <DantMenu />;
      case 4:
        return <BestMenu />;
      default:
        return <HemoMenu />;
    }
  };

  return (
    <Window resizable theme="ntos_spooky">
      <Window.Content>
        <Box fillPositionedParent>
          <Tabs>
            <Tabs.Tab
              key="Hemomancer"
              content="Гемомансер"
              selected={0 === tabIndex}
              onClick={() => setTabIndex(0)}>
            </Tabs.Tab>
            <Tabs.Tab
              key="Umbrae"
              content="Умбра"
              selected={1 === tabIndex}
              onClick={() => setTabIndex(1)}>
            </Tabs.Tab>
            <Tabs.Tab
              key="Gargantua"
              content="Гаргантюа"
              selected={2 === tabIndex}
              onClick={() => setTabIndex(2)}>
            </Tabs.Tab>
            <Tabs.Tab
              key="Dantalion"
              content="Данталион"
              selected={3 === tabIndex}
              onClick={() => setTabIndex(3)}>
            </Tabs.Tab>
            <Tabs.Tab
              key="Bestia"
              content="Бестия"
              selected={4 === tabIndex}
              onClick={() => setTabIndex(4)}>
            </Tabs.Tab>
          </Tabs>
          {decideTab(tabIndex)}
        </Box>
      </Window.Content>
    </Window>
  );
};

export const HemoMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { hemomancer } = data;
  return (
      <Section title="Гемомансер">
        <Box textAlign="center">
          <img
            height="256px"
            width="256px"
            src={`data:image/jpeg;base64,${hemomancer}`}
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
            }} />
        </Box>
        <h3>
          {/* Focuses on blood magic and the manipulation of blood around you. */}
          Спецализируется на кровавой магии и манипуляциях с окружающей кровью.
        </h3>
        <p>
          {/* <b>Vampiric claws</b>: Unlocked at 150 blood, allows you to summon a
          robust pair of claws that attack rapidly, drain a targets blood, and heal you. */}
          <b>Вампирские когти</b>: Открывается от 150 <i><font color='red'>крови</font></i>, позволяет призвать пару острых когтей,
          позволяющих быстро атаковать цель, поглощая ее кровь и регенерируя.
        </p>
        <p>
          {/* <b>Blood Barrier</b>: Unlocked at 250 blood, allows you to select two
          turfs and create a wall between them. */}
          <b>Кровавый барьер</b>: Открывается от 250 <i><font color='red'>крови</font></i>, позволяет вам выбрать две позиции
          для создания между ними стены.
        </p>
        <p>
          {/* <b>Blood tendrils</b>: Unlocked at 250 blood, allows you to slow
          everyone in a targeted 3x3 area after a short delay. */}
          <b>Щупальца из крови</b>: Открывается от 250 <i><font color='red'>крови</font></i>, после небольшой задержки позволяет
          вам замедлить всех внутри выбранной территории 3x3.
        </p>
        <p>
          {/* <b>Sanguine pool</b>: Unlocked at 400 blood, allows you to travel at
          high speeds for a short duration. Doing this leaves behind blood
          splatters. You can move through anything but walls and space when
          doing this. */}
          <b>Кровавый бассейн</b>: Открывается от 400 <i><font color='red'>крови</font></i>, позволяет с большой скоростью преодолеть
          короткое расстояние, игнорируя все препятствия кроме стен и космоса, а также оставляя за собой кровавый след.
        </p>
        <p>
          {/* <b>Predator senses</b>: Unlocked at 600 blood, allows you to sniff out
          anyone within the same sector as you. */}
          <b>Чутьё охотника</b>: Открывается от 600 <i><font color='red'>крови</font></i>, позволяет вам почуствовать кого-угодно
          в пределах вашего сектора.
        </p>
        <p>
          {/* <b>Blood eruption</b>: Unlocked at 800 blood, allows you to manipulate
          all nearby blood splatters, in 4 tiles around you, into spikes that
          impale anyone stood ontop of them. */}
          <b>Извержение крови</b>: Открывается от 800 <i><font color='red'>крови</font></i>, позволяет вам манипулировать
          окружающими вас лужами крови в радиусе четырех метров, превращая их в шипы, протыкающие любого наступившего
          на них.
        </p>
        <p>
          <b>Полная сила</b>
          <Divider />
          {/* <b>The blood bringers rite</b>: When toggled you will rapidly drain
          the blood of everyone who is nearby and use it to heal yourself
          slightly and remove any incapacitating effects rapidly. */}
          <b>Обряд крови</b>: Будучи включенным, позволяет вам поглощать кровь
          окружающих вас существ, благодаря чему вы будете медленно лечиться и восстанавливаться от
          каких-либо оглушающих эффектов.
        </p>
        <Button content="Гемомансер" onClick={() => act('hemomancer')} />
      </Section>
  );
};

export const UmbrMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { umbrae } = data;
  return (
      <Section title="Умбра">
        <Box textAlign="center">
          <img
            height="256px"
            width="256px"
            src={`data:image/jpeg;base64,${umbrae}`}
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
            }} />
        </Box>
        {/* <h3>Focuses on darkness, stealth ambushing and mobility.</h3> */}
        <h3>Спецализируется на темноте, засадах и скрытном перемещении.</h3>
        <p>
          {/* <b>Cloak of darkness</b>: Unlocked at 150 blood, when toggled, allows
          you to become nearly invisible and move rapidly when in dark regions.
          While active, burn damage is more effective against you. */}
          <b>Плащ тьмы</b>: Открывается от 150 <i><font color='red'>крови</font></i>,
          будучи включенным, позволяет вам быть почти невидимым и быстро передвигаться в темных участках
          станции. Также, будучи активным, увеличивает любой урон от ожогов по вам.
        </p>
        <p>
          {/* <b>Shadow anchor</b>: Unlocked at 250 blood, casting it will create
          an anchor at the cast location after a short delay.
          If you then cast the ability again, you are teleported back to the anchor.
          If you do not cast again within 2 minutes, you are forced back to the anchor.
          It will not teleport you between Z levels. */}
          <b>Маяк души</b>: Открывается от 250 <i><font color='red'>крови</font></i>, активация создает на месте
          применения маяк после небольшой задерки.
          Повторное использование телепортирует вас обратно к маяку.
          Если спустя две минуты после первого использования способность не была активирована снова, то вы
          будете автоматически возвращены к маяку.
          Маяк не способен телепортировать вас между секторами.
        </p>
        <p>
          {/* <b>Shadow snare</b>: Unlocked at 250 blood, allows you to summon a
          trap that when crossed blinds and ensares the victim. This trap is
          hard to see, but withers in the light. */}
          <b>Теневая ловушка</b>: Открывается от 250 <i><font color='red'>крови</font></i>, позволяет вам
          создавать ловушки, травмирующие и ослепляющие любого наступившего в них.
          Ловушку тяжело заметить, но она исчезает под воздействием источников яркого света.
        </p>
        <p>
          {/* <b>Dark passage</b>: Unlocked at 400 blood, allows you to target a
          turf on screen, you will then teleport to that turf. */}
          <b>Теневой проход</b>: Открывается от 400 <i><font color='red'>крови</font></i>, позволяет вам
          телепортироваться в любое место в пределах видимости.
        </p>
        <p>
          {/* <b>Extinguish</b>: Unlocked at 600 blood, allows you to snuff out
          nearby electronic light sources and glowshrooms. */}
          <b>Потушить</b>: Открывается от 600 <i><font color='red'>крови</font></i>, позволяет вам выводить из строя
          любые электрические источники света, а также глоушрумы.
        </p>
          {/* <b>Shadow boxing</b>: Unlocked at 800 blood, sends out shadow
          clones towards a target, damaging them while you remain in range. */}
          <b>Бой с тенью</b>: Открывается от 800 <i><font color='red'>крови</font></i>, создает
          теневых клонов, которые будут атаковать цель, пока вы находитесь рядом.
        <p>
          <b>Полная сила</b>
          <Divider/>
          {/* <b>Eternal darkness</b>: When toggled, you consume yourself in unholy
          darkness, only the strongest of lights will be able to see through it.
          It will also cause nearby creatures to freeze. */}
          <b>Вечная темнота</b>: после включения вы расстворяетесь в нечестивой темноте,
          в которой будет виден лишь сильнейший источник света. Холод, окружающей
          вас тьмы будет замораживать всех живых существ поблизости.
        </p>
        <p>Вы также получаете X-ray зрение</p>
        <Button content="Умбра" onClick={() => act('umbrae')} />
      </Section>
  );
};

export const GarMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { gargantua } = data;
  return (
      <Section title="Гаргантюа">
        <Box textAlign="center">
          <img
            height="256px"
            width="256px"
            src={`data:image/jpeg;base64,${gargantua}`}
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
            }} />
        </Box>
        {/* <h3>Focuses on tenacity and melee damage.</h3> */}
        <h3>Спецализируется на стойкости и ближнем бое.</h3>
        <p>
          {/* <b>Rejuvenate</b>: Will heal you at an increased rate based on how
          much damage you have taken. */}
          <b>Восстановление</b>: Будет восстанавливать ваше здоровье тем сильнее, чем больше урона вы получили.
        </p>
        <p>
          {/* <b>Blood swell</b>: Unlocked at 150 blood, increases your resistance
          to physical damage, stuns and stamina for 30 seconds. While it is
          active you cannot fire guns. */}
          <b>Нарастание крови</b>: Открывается от 150 <i><font color='red'>крови</font></i>, увеличивает
          ваше сопротивление оглушению, физическому и стамина урону. Вы не можете стрелять пока активна способность.
        </p>
        <p>
          {/* <b>Seismic stomp</b>: Unlocked at 250 blood, allows you to stomp the ground
          to send out a shockwave, knocking people back. */}
          <b>Сейсмический топот</b>: Открывается от 250 <i><font color='red'>крови</font></i>, позволяет вам
          сотрясать землю под ногами, чтобы огушить и оттолкнуть окружающих врагов.
        </p>
        <p>
          {/* <b>Blood rush</b>: Unlocked at 250 blood, gives you a short speed
          boost when cast. */}
          <b>Прилив крови</b>: Открывается от 250 <i><font color='red'>крови</font></i>, дает вам прибавку к скорости
          на короткое время.
        </p>
        <p>
          {/* <b>Blood swell II</b>: Unlocked at 400 blood, increases all melee
          damage by 10. */}
          <b>Нарастание крови+</b>: Открывается от 400 <i><font color='red'>крови</font></i>, увеличивает весь урон
          в ближнем бою на 10.
        </p>
        <p>
          {/* <b>Overwhelming force</b>: Unlocked at 600 blood, when toggled, if you
          bump into a door that you dont have access to, it will force it open.
          In addition, you cannot be pushed or pulled while it is active. */}
          <b>Ошеломляющая сила</b>: Открывается от 600 <i><font color='red'>крови</font></i>,
          будучи включенным, позволяет открывать двери при столкновени, даже не имея доступа.
          Вас также не могут толкнуть или тащить, пока способность активна.
        </p>
        <p>
          {/* <b>Demonic grasp</b>: Unlocked at 800 blood, allows you to send out a
          demonic hand to snare someone. If you are on disarm/grab intent you will
          push/pull the target, respectively. */}
          <b>Демоническая хватка</b>: Открывается от 800 <i><font color='red'>крови</font></i>,
          позволяет вам отправить к цели демоническую руку. Взависимости от интента, disarm/grab, вы оттолкнете/притяните
          цель.
        </p>
        <p>
          <b>Полная сила</b>
          <Divider />
          {/* <b>Charge</b>: You gain the ability to charge at a target. Destroying
          and knocking back pretty much anything you collide with. */}
          <b>Рывок</b>: Вы получаете способность делать в рывок в вашу цель, разрушая и отталкивая все, во что врежетесь.
        </p>
        <Button content="Гаргантюа" onClick={() => act('gargantua')} />
      </Section>
  );
};

export const DantMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { dantalion } = data;
  return (
      <Section title="Данталион">
        <Box textAlign="center">
          <img
            height="256px"
            width="256px"
            src={`data:image/jpeg;base64,${dantalion}`}
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
            }} />
        </Box>
        {/* <h3>Focuses on thralling and illusions.</h3> */}
        <h3>Спецализируется на порабощении и иллюзиях.</h3>
        <p>
          {/* <b>Enthrall</b>: Unlocked at 150 blood, Thralls your target to your
          will, requires you to stand still. Does not work on mindshielded or
          already enthralled/mindslaved people. */}
          <b>Порабощение</b>: Открывается от 150 <i><font color='red'>крови</font></i>,
          подчиняет цель вашей воле, требует от вас не шевелиться во время
          порабощения. Не работает на носителей импланта защиты разума и на уже порабощенных существ.
        </p>
        <p>
          {/* <b>Thrall cap</b>: You can only thrall a max of 1 person at a time.
          This can be increased at 400 blood, 600 blood and at full power to a
          max of 4 thralls. */}
          <b>Увелечение количества рабов</b>: Вы можете поработить максимум одного раба за раз.
          Количество рабов будет расти при достижении 400 <i><font color='red'>крови</font></i>,
          600 <i><font color='red'>крови</font></i> и полной силы с максимум в 4 раба.
        </p>
        <p>
          {/* <b>Thrall commune</b>: Unlocked at 150 blood, Allows you to talk to
          your thralls, your thralls can talk back in the same way. */}
          <b>Общение</b>: Открывается от 150 <i><font color='red'>крови</font></i>,
          позволяет вам разговаривать с вашими рабами, ваши рабы также могут отвечать вам.
        </p>
        <p>
          {/* <b>Subspace swap</b>: Unlocked at 250 blood, allows you to swap positions
          with a target. */}
          <b>Подпространственный обмен</b>: Открывается от 150 <i><font color='red'>крови</font></i>,
          позволяет вам меняться местами с целью.
        </p>
        <p>
          {/* <b>Pacify</b>: Unlocked at 250 blood, allows you to pacify a target,
          preventing them from causing harm for 40 seconds. */}
          <b>Умиротворение</b>: Открывается от 250 <i><font color='red'>крови</font></i>,
          позволяет вам успокоить цель, отобрав у нее возможность нанести вред кому-либо в течение
          40 секунд.
        </p>
        <p>
          {/* <b>Decoy</b>: Unlocked at 400 blood, briefly turn invisible and send
          out an illusion to fool everyone nearby. */}
          <b>Приманка</b>: Открывается от 400 <i><font color='red'>крови</font></i>,
          делает вас невидимым на некоторое время, создав на месте примения вашу копию.
        </p>
        <p>
          {/* <b>Rally thralls</b>: Unlocked at 600 blood, removes all incapacitating effects from nearby thralls. */}
          <b>Сплотить рабов</b>: Открывается от 600 <i><font color='red'>крови</font></i>,
          снимает с ваших рабов любые оглушающие эффекты.
        </p>
        <p>
          {/* <b>Blood bond</b>: Unlocked at 800 blood, when cast, all nearby thralls
          become linked to you. If anyone in the network takes damage, it is shared
          equally between everyone in the network. If a thrall goes out of range,
          they will be removed from the network. */}
          <b>Кровавая связь</b>: Открывается от 800 <i><font color='red'>крови</font></i>,
          связывает вас со всеми окружающими вас рабами, если кто-либо в связке получает урон, то он делится
          между всеми остальными. Если раб уходит далеко от вас, то вы теряете связь с ним.

        </p>
        <p>
          <b>Полная сила</b>
          <Divider />
          {/* <b>Mass Hysteria</b>: Casts a powerful illusion that, blinds then make
          everyone nearby perceive others to looks like random animals. */}
          <b>Массовая истерия</b>: создает массовую галлюцинацию, ослепив всех поблизости, а затем заставив окружающих
          видеть друг в друге различных животных.
        </p>
        <Button content="Данталион" onClick={() => act('dantalion')} />
      </Section>
  );
};

export const BestMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { bestia } = data;
  return (
      <Section title="Бестия">
        <Box textAlign="center">
          <img
            height="256px"
            width="256px"
            src={`data:image/jpeg;base64,${bestia}`}
            style={{
              "-ms-interpolation-mode": "nearest-neighbor",
            }} />
        </Box>
        {/* <h3>Focuses on transformations and trophies harvesting.</h3> */}
        <h3>Спецализируется на трансформации и добыче трофеев.</h3>
        <p>
          {/* <b>Check Trophies</b>: Unlocked at 150 blood, allows you to check
          current trophies amount and all the passive effects they provide. */}
          <b>Проверить трофеи</b>: Открывается от 150 <i><font color='red'>крови</font></i>,
          позволяет вам проверить количество трофеев, а также все пассивные эффекты, что они дают.
        </p>
        <p>
          {/* <b>Dissect</b>: Unlocked at 150 blood, main source of gaining power, besides blood,
          allows you to harvest human organs, as a trophies, to passively increase your might. */}
          <b>Вскрытие</b>: Открывается от 150 <i><font color='red'>крови</font></i>, вдобавок к крови позволяет вам
          поглощать органы в качестве трофеев для расширения ваших возможностей.
        </p>
        <p>
          {/* <b>Dissect Cap</b>: You can only harvest one organ trophie at a time.
          This can be increased at 600 blood and at full power to a
          max of 3 trophies per victim. */}
          <b>Увеличение вскрытий </b>: за раз вы можете поглотить максимум один орган.
          Предел будет увеличиваться при достижении 600 <i><font color='red'>крови</font></i> и полной силы
          с максимумом в три органа.
        </p>
        <p>
          {/* <b>Infected Trophy</b>: Unlocked at 150 blood, allows you to stun enemies
          from the safe distance and infect them with the deadly Grave Fever. */}
          <b>Зараженный трофей</b>: Открывается от 150 <i><font color='red'>крови</font></i>, позволяет
          вам оглушать противников с безопасной дистанции, заражая их при этом болезнью вампиров.
        </p>
        <p>
          {/* <b>Lunge</b>: Unlocked at 250 blood, allows you to rapidly close distance
          to a victim or escape a dangerous situation. */}
          <b>Выпад</b>: Открывается от 250 <i><font color='red'>крови</font></i>,
          позволяет быстро сократить расстояние между вами и целью или сбежать из опасной ситуации.
        </p>
        <p>
          {/* <b>Mark the Prey</b>: Unlocked at 250 blood, allows you to mark a victim
          which drastically reduces their movement speed and forces them
          to take spontaneous actions. */}
          <b>Отметить добычу</b>: Открывается от 250 <i><font color='red'>крови</font></i>,
          позволяет вам отметить жертву, уменьшив ее скорость и заставив ее путаться в ногах.
        </p>
        <p>
          {/* <b>Metamorphosis - Bats</b>: Unlocked at 400 blood, allows you to shapeshift
          into the deadly and vicious space bats swarm. */}
          <b>Метаморфоз - Летучие Мыши</b>: Открывается от 400 <i><font color='red'>крови</font></i>,
          позволяет вам обратиться смертоносными космическими летучими мышами.
        </p>
        <p>
          {/* <b>Anabiosis</b>: Unlocked at 600 blood, ancient technique which
          allows you to cure almost any wounds while sleeping in a coffin. */}
          <b>Анабиоз</b>: Открывается от 600 <i><font color='red'>крови</font></i>, древняя техника,
          позволяющая вам залечить почти любые ранения за счет сна в гробу.
        </p>
        <p>
          {/* <b>Summon Bats</b>: Unlocked at 800 blood, allows you to call extraplanar
          space bats to aid you in combat. */}
          <b>Призыв летучих мышей</b>: Открывается от 600 <i><font color='red'>крови</font></i>,
          позволяет вам призвать космических летучих мышей для помощи в бою.
        </p>
        <p>
          <b>Полная сила</b>
          <Divider />
          {/* <b>Metamorphosis - Hound</b>: Allows you to shapeshift into the ultimate
          form of bluespace entity which took over your soul. */}
          <b>Метаморфоз - Гончая</b>: Позволяет вам обратиться в совершенную форму
          блюспейс сущности, завладевшей вашей душой.
        </p>
        <Button content="Бестия" onClick={() => act('bestia')} />
      </Section>
  );
};
