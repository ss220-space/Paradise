import { useBackend } from "../backend";
import { Button, Box, Table, Section } from "../components";
import { Window } from "../layouts";

const roundTenths = function (input) {
  return (Math.round(input * 10) / 10).toFixed(1);
};

export const VampireTrophiesStatus = (props, context) => {
  return (
    <Window theme="ntos_spooky">
      <Window.Content scrollable>
        <Trophies />
        <Passives />
        <InfectedTrophy />
        <Lunge />
        <MarkPrey />
        <MetamorphosisBats />
        <ResonantShriek />
        <Anabiosis />
        <SummonBats />
        <MetamorphosisHound />
        <LungeFinale />
      </Window.Content>
    </Window>
  );
};

const Trophies = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    icon_hearts,
    icon_lungs,
    icon_livers,
    icon_kidneys,
    icon_eyes,
    icon_ears,
  } = data;
  return (
    <Section
      title="Трофеи"
      color="red"
      textAlign="center"
      verticalAlign="middle">

      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_hearts}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-32px",
            "margin-right": "-48px",
            "margin-top": "-32px",
            "margin-bottom": "-48px",
            "height": "128px",
            "width": "128px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={hearts < trophies_max_crit ? "average" : "good"} fontSize="20px">
          {hearts}
        </Box>
        <Button
          tooltipPosition="right"
          tooltip="Cердце - трофей, который веками повышал жизненную силу и крепость тела наших сородичей. Критичный орган. Максимальное количество трофеев этого типа - 6."
          content="СЕРДЦЕ"
          color="transparent"
        />
      </Box>
      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_lungs}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-8px",
            "margin-right": "-16px",
            "margin-top": "-12px",
            "margin-bottom": "-12px",
            "height": "72px",
            "width": "72px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={lungs < trophies_max_crit ? "average" : "good"} fontSize="20px">
          {lungs}
        </Box>
        <Button
          tooltipPosition="right"
          tooltip="Легкие - трофей, который всегда использовался в ритуалах для повышения ловкости и выносливости наших сородичей. Критичный орган. Максимальное количество трофеев этого типа - 6."
          content="ЛЕГКИЕ"
          color="transparent"
        />
      </Box>
      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_livers}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-24px",
            "margin-right": "-24px",
            "margin-top": "-28px",
            "margin-bottom": "-20px",
            "height": "96px",
            "width": "96px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={livers < trophies_max_gen ? "average" : "good"} fontSize="20px">
          {livers}
        </Box>
        <Button
          tooltipPosition="right"
          tooltip="Печень - всегда использовалась в традиционных вампирских обрядах для усиления контроля крови, что снижает затраты крови для использования способностей. Максимальное количество трофеев этого типа - 10."
          content="ПЕЧЕНЬ"
          color="transparent"
        />
      </Box>
      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_kidneys}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-22px",
            "margin-right": "-26px",
            "margin-top": "-28px",
            "margin-bottom": "-20px",
            "height": "96px",
            "width": "96px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={kidneys < trophies_max_gen ? "average" : "good"} fontSize="20px">
          {kidneys}
        </Box>
        <Button
          tooltipPosition="left"
          tooltip="Почки - используются вампирами в качестве катализатора для усиления эффектов от способностей. Максимальное количество трофеев этого типа - 10."
          content="ПОЧКИ"
          color="transparent"
        />
      </Box>
      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_eyes}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-26px",
            "margin-right": "-22px",
            "margin-top": "-22px",
            "margin-bottom": "-26px",
            "height": "96px",
            "width": "96px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={eyes < trophies_max_gen ? "average" : "good"} fontSize="20px">
          {eyes}
        </Box>
        <Button
          tooltipPosition="left"
          tooltip="Глаза - один из самых важных ингредиентов, позволяющий обойти любые недостатки зрения, присущие смертному телу. Максимальное количество трофеев этого типа - 10."
          content="ГЛАЗА"
          color="transparent"
        />
      </Box>
      <Box display="inline-block" width="16.6%">
        <Box
          as="img"
          src={`data:image/jpeg;base64,${icon_ears}`}
          verticalAlign="middle"
          style={{
            "margin-left": "-8px",
            "margin-right": "-8px",
            "margin-top": "-8px",
            "margin-bottom": "-8px",
            "height": "64px",
            "width": "64px",
            "-ms-interpolation-mode": "nearest-neighbor",
          }} />
        <Box bold textColor={ears < trophies_max_gen ? "average" : "good"} fontSize="20px">
          {ears}
        </Box>
        <Button
          tooltipPosition="left"
          tooltip="Уши - всегда помогали нашим сородичам улучшить контроль над эмоциями, что предавло нашим способностям больший радиус действия. Максимальное количество трофеев этого типа - 10."
          content="УШИ"
          color="transparent"
        />
      </Box>
    </Section>
  );
};


const Passives = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    suck_rate,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    trophies_brute,
    trophies_burn,
    trophies_oxy,
    trophies_tox,
    trophies_brain,
    trophies_clone,
    trophies_stamina,
    trophies_flash,
    trophies_welding,
    trophies_xray,
    trophies_bang,
    trophies_blood,
  } = data;
  return (
    <Section
      title="Пассивная защита"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении сердец"
              content="Травмы:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts < trophies_max_crit ? Math.ceil(hearts * (trophies_brute / trophies_max_crit)) : trophies_brute}%
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении сердец"
              content="Ожоги:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts < trophies_max_crit ? Math.ceil(hearts * (trophies_burn / trophies_max_crit)) : trophies_burn}%
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Улучшается при извлечении легких"
              content="Гипоксия:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {lungs < trophies_max_crit ? Math.ceil(lungs * (trophies_oxy / trophies_max_crit)) : trophies_oxy}%
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении печени"
              content="Токсины:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {livers < trophies_max_gen ? livers * (trophies_tox / trophies_max_gen) : trophies_tox}%
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении почек"
              content="Повреждения мозга:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys < trophies_max_gen ? kidneys * (trophies_brain / trophies_max_gen) : trophies_brain}%
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Улучшается при извлечении почек"
              content="Повреждения клеток:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys < trophies_max_gen ? kidneys * (trophies_clone / trophies_max_gen) : trophies_clone}%
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Улучшается при извлечении легких"
              content="Выносливость:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {lungs < trophies_max_crit ? Math.ceil(lungs * (trophies_stamina / trophies_max_crit)) : trophies_stamina}%
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Улучшается при извлечении печени"
              content="Снижения затрат крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {livers < trophies_max_gen ? livers * (trophies_blood / trophies_max_gen) : trophies_blood}
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Время, затрачиваемое на каждый цикл поглощения крови, чем меньше, тем лучше. Снижается при извлечении почек."
              content="Скорость поглощения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {suck_rate}с.
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Становится доступно при извлечении ушей"
              content="Защита от вспышек:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_flash ? "bad" : "good"}>
              {eyes < trophies_flash ? "НЕТ" : "ЕСТЬ"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Становится доступно при извлечении ушей"
              content="Защита от сварки:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_welding ? "bad" : "good"}>
              {eyes < trophies_welding ? "НЕТ" : "ЕСТЬ"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Становится доступно при извлечении глаз"
              content="X-Ray зрение:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_xray ? "bad" : "good"}>
              {eyes < trophies_xray ? "НЕТ" : "ЕСТЬ"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Становится доступно при извлечении ушей"
              content="Защита ушей:"
              color="transparent"
            />
            <Box display="inline-block" textColor={ears < trophies_bang ? "bad" : "good"}>
              {ears < trophies_bang ? "НЕТ" : "ЕСТЬ"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const InfectedTrophy = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Infected Trophy"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Расстояние, которое пролетит череп, перед исчезновением. Увеличивается при извлечении глаз."
              content="Дальность полета:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {5 + eyes}
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в точке попадания. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              content="Радиус поражения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={ears < trophies_max_gen ? "average" : "good"}>
              {Math.floor(ears / 4)}
              {ears < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Количество физического урона, которое получит каждый живой моб в области поражения. Увеличивается при извлечении сердец."
              content="Урон:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts * 5}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              content="Время оглушения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {roundTenths(hearts / 2)}с.
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Вероятность того, что каждый живой гуманоид в в области поражения будет заражен могильной лихорадкой. Увеличивается при извлечении печени."
              content="Шанс заражения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {10 + livers * 3}%
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Lunge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Lunge"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное расстояние, на котором рывок прервывется автоматически. Увеличивается при извлечении легких."
              content="Дистанция:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {5 + lungs}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в конечной точке рывка. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              content="Радиус поражения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={ears < trophies_max_gen ? "average" : "good"}>
              {1 + Math.floor(ears / 5)}
              {ears < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              content="Время оглушения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {roundTenths(1 + hearts / 2)}с.
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              content="Время замешательства:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {roundTenths(kidneys * 2)}с.
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Количество крови, которое потеряет каждый живой гуманоид в области поражения. Увеличивается при извлечении почек."
              content="Кровопотеря:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys * 10}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество крови, которое получит вампир от каждого живого разумного гуманоида в области поражения. Увеличивается при извлечении почек."
              content="Поглощение крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MarkPrey = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Mark the Prey"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальная дистанция, на которой можно применить способность. Увеличивается при извлечении глаз."
              content="Дальность применения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {3 + Math.floor(eyes / 2)}
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Время, в течение которого метка будет действовать. Увеличивается при извлечении почек."
              content="Продолжительность:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {roundTenths(5 + kidneys)}с.
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Количество ожогов, которое получит жертва, если сработает поджог. Увеличивается при извлечении сердец."
              content="Ожоги:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Шанс на то, что поджог сработает. Увеличивается при извлечении сердец."
              content="Шанс на поджог:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts * 10}%
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс на то, что цель спонтанно атакует ближайшую цель или же саму себя. Увеличивается при извлечении глаз."
              content="Шанс на безумие:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {30 + eyes * 7}%
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MetamorphosisBats = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Metamorphosis - Bats"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье летучих мышей. Увеличивается при извлечении сердец."
              content="Здоровье:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {130 + hearts * 20}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого летучим мышам не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              content="Порог урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {3 + hearts * 2}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения летучих мышей. Чем ниже, тем лучше. Снижается при извлечении легких."
              content="Скорость:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              content="Минимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {10 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наибольший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              content="Максимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {15 + hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество здоровья, которое летучие мыши преобразуют в свое собственное после каждой успешной атаки. Увеличивается при извлечении почек."
              content="Восстановление:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое получат летучие мыши от каждого живого гуманоида после каждой успешной атаки. Увеличивается при извлечении печени."
              content="Поглощение крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс для летучих мышей на оглушение жертвы на 1 секунду после каждой успешной атаки. Увеличивается при извлечении глаз."
              content="Шанс на испуг:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {eyes * 3}%
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section >
  );
};

const ResonantShriek = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Resonant Shriek"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Радиус зоны поражения, с центром в точке нахождения вампира. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              content="Радиус поражения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={ears < trophies_max_gen ? "average" : "good"}>
              {2 + Math.floor(ears / 3)}
              {ears < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              content="Время оглушения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {roundTenths(hearts / 3)}с.
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              content="Время замешательства:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {roundTenths(kidneys)}с.
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество урона мозгу, которое получит каждый живой моб в области поражения. Увеличивается при извлечении глаз."
              content="Урон мозгу:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {eyes * 3}
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Anabiosis = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    full_power,
  } = data;
  return (
    <Section
      title="Anabiosis"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество травм, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении сердец."
              content="Лечение травм:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество ожогов, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении сердец."
              content="Лечение ожогов:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Максимально количество токсинов, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении печени."
              content="Лечение токсинов:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {15 * (livers + 4)}
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество удушья, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении легких."
              content="Лечение гипоксии:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {15 * (lungs * 2 + 8)}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество клеточных повреждений, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении почек."
              content="Лечение клеток:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {15 * Math.round(kidneys / 2 + 2)}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Максимально количество крови, которое может восстановить тело вампира во время анабиоза. Увеличивается при извлечении почек."
              content="Восстановление крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {15 * (kidneys * 2 + 12)}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Максимально количество повреждений внутренним органам, которое может вылечить вампир во время анабиоза. Увеличивается при извлечении почек."
              content="Лечение органов:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {15 * Math.round(kidneys / 5 + 1)}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Максимально количество реагентов, которое может вывести тело вампира во время анабиоза. Увеличивается при извлечении печени."
              content="Выведение реагентов:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {15 * (livers + 5)}
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Шанс срастить сломанные кости за цикл анабиоза (15 всего циклов). Увеличивается при извлечении сердец."
              content="Сращивание перелома:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts * 4}%
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Шанс избавиться от внутреннего кровотечения за цикл анабиоза (15 всего циклов). Увеличивается при извлечении сердец."
              content="Сращивание вен:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {hearts * 4}%
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс отрастить конечность за цикл анабиоза (15 всего циклов). Увеличивается при извлечении легких."
              content="Отращивание конечности:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {lungs * 2}%
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Одноразовая способность: убирает все наложенные эффекты, восстанавливает все мертвые органы и конечности, излечивает все вредные вирусы и выводит всех паразитов."
              content="Полное исцеление:"
              color="transparent"
            />
            <Box display="inline-block" textColor={full_power ? "good" : "bad"}>
              {full_power ? "НЕТ" : "ЕСТЬ"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const SummonBats = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  let maxBats = 1 + (allTrophies < 40 ? Math.round(allTrophies / 2) : allTrophies < 52 ? 2 : 3);
  return (
    <Section
      title="Summon Bats"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье, которое могут иметь летучие мыши. Увеличивается при извлечении сердец."
              content="Здоровье:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {80 + hearts * 10}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого летучим мышам не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              content="Порог урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {3 + hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения летучих мышей. Чем ниже, тем лучше. Снижается при извлечении легких."
              content="Скорость:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {(1 - lungs * 0.1).toFixed(2)}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              content="Минимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {5 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наибольший урон, который могут нанести летучие мыши. Увеличивается при извлечении сердец."
              content="Максимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {10 + hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество здоровья, которое летучие мыши преобразуют в свое собственное после каждой успешной атаки. Увеличивается при извлечении почек."
              content="Восстановление:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое получат летучие мыши от каждого живого разумного гуманоида после каждой успешной атаки. Увеличивается при извлечении печени."
              content="Поглощение крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Шанс для летучих мышей на оглушение жертвы на 0.5 секунды после каждой успешной атаки. Увеличивается при извлечении глаз."
              content="Шанс на испуг:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {Math.floor(eyes * 1.5)}%
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество летучих мышей, призываемых за раз. Увеличивается при извлечении любого трофейного органа."
              content="Количество:"
              color="transparent"
            />
            <Box display="inline-block" textColor={allTrophies < 52 ? "average" : "good"}>
              {maxBats}
              {allTrophies < 52 ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section >
  );
};

const MetamorphosisHound = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Metamorphosis - Hound"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Максимальное здоровье гончей. Увеличивается при извлечении сердец."
              content="Здоровье:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {200 + hearts * 30}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Порог, ниже которого гончей не может быть нанесен урон. Работает только на атаки ближнего боя. Увеличивается при извлечении сердец."
              content="Порог урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {10 + hearts * 3}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Скорость передвижения гончей. Чем ниже, тем лучше. Снижается при извлечении легких."
              content="Скорость:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Наименьший урон, который может нанести гончая. Увеличивается при извлечении сердец."
              content="Минимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {15 + hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Наименьший урон, который может нанести гончая. Увеличивается при извлечении сердец."
              content="Максимум урона:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {20 + hearts}
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Шанс для гончей на оглушение жертвы на 1 секунду после каждой успешной атаки. Увеличивается при извлечении глаз."
              content="Шанс на испуг:"
              color="transparent"
            />
            <Box display="inline-block" textColor={eyes < trophies_max_gen ? "average" : "good"}>
              {eyes * 3}%
              {eyes < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество крови, которое будет тратить вампир, чтобы оставаться в форме гончей. Снижается при извлечении печени."
              content="Потребление крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={livers < trophies_max_gen ? "average" : "good"}>
              {15 - livers} крови / 6с.
              {livers < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section >
  );
};

const LungeFinale = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  let maxBats = 1 + (allTrophies < 40 ? Math.round(allTrophies / 2) : allTrophies < 52 ? 2 : 3);
  return (
    <Section
      title="Lunge Finale"
      color="red"
      textAlign="center"
      verticalAlign="middle">
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Радиус вокруг вампира, внутри которой ищется цель для рывка. Увеличивается при извлечении легких."
              content="Радиус поиска:"
              color="transparent"
            />
            <Box display="inline-block" textColor={lungs < trophies_max_crit ? "average" : "good"}>
              {5 + Math.round(lungs / 2)}
              {lungs < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Радиус зоны поражения, с центром в конечной точке рывка. Все живые мобы в области будут задеты. Увеличивается при извлечении ушей."
              content="Радиус поражения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={ears < trophies_max_gen ? "average" : "good"}>
              {Math.floor(ears / 5)}
              {ears < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Время, которое каждый живой моб в области поражения будет оглушен. Увеличивается при извлечении сердец."
              content="Время оглушения:"
              color="transparent"
            />
            <Box display="inline-block" textColor={hearts < trophies_max_crit ? "average" : "good"}>
              {roundTenths(1 + hearts / 2)}c.
              {hearts < trophies_max_crit ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Время, которое каждый живой моб в области поражения будет в замешательстве. Увеличивается при извлечении почек."
              content="Время замешательства:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {roundTenths(kidneys * 2)}c.
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Количество крови, которое потеряет каждый живой гуманоид в области поражения. Увеличивается при извлечении почек."
              content="Кровопотеря:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys * 5}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Количество крови, которое получит вампир от каждого живого разумного гуманоида в области поражения. Увеличивается при извлечении почек."
              content="Поглощение крови:"
              color="transparent"
            />
            <Box display="inline-block" textColor={kidneys < trophies_max_gen ? "average" : "good"}>
              {kidneys}
              {kidneys < trophies_max_gen ? "" : " (max)"}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Количество рывков, которое совершит гончая. Увеличивается при извлечении любого трофейного органа."
              content="Количество рывков:"
              color="transparent"
            />
            <Box display="inline-block" textColor={allTrophies < 50 ? "average" : "good"}>
              {1 + Math.floor(allTrophies / 10)}
              {allTrophies < 50 ? "" : " (max)"}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="После активации способности гончая выполнит определенное количество рывков по любым живым разумным целям в области поиска, ставя приоритет на новые цели."
              content="Дополнительная информация"
              color="transparent"
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

