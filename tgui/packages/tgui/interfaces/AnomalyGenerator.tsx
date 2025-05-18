import { classes } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  AnimatedNumber,
  Icon,
  LabeledList,
  ProgressBar,
  ImageButton,
} from '../components';
import { Window } from '../layouts';

type AnomalyGeneratorData = {
  type;
  tier;
  creating;
  req_energy;
  req_item;
  anomaly_type;
  charge;
  generating;
  use_acps;
  use_smeses;
  use_powernet;
  has_powernet;
  last_charge;
};

export const AnomalyGenerator = (props) => {
  const { act, data } = useBackend<AnomalyGeneratorData>();
  const {
    type,
    tier,
    creating,
    req_energy,
    req_item,
    anomaly_type,
    charge,
    generating,
    use_acps,
    use_smeses,
    use_powernet,
    has_powernet,
    last_charge,
  } = data;

  if (generating) {
    return (
      <Window width={710} height={250} title="Генератор аномалий">
        <Window.Content>
          <LabeledList>
            <LabeledList.Item label="Источники энергии">
              <Button
                content="ЛКП"
                selected={use_acps}
                onClick={() => act('toggle_apcs', {})}
              />
              <Button
                content="СКАНы рядом"
                selected={use_smeses}
                onClick={() => act('toggle_smeses', {})}
              />
              <Button
                content="Узел энергосети"
                selected={use_powernet}
                disabled={!has_powernet}
                onClick={() => act('toggle_powernet', {})}
              />
            </LabeledList.Item>
          </LabeledList>
          <Box>Создается {anomaly_type} аномалия.</Box>
          <Box>
            Накоплено энергии: {charge}/{req_energy}
          </Box>
          <Box>Накопление энергии в секунду: {last_charge}</Box>
          <Button
            content="Прекратить создание"
            onClick={() => act('stop', {})}
          />
        </Window.Content>
      </Window>
    );
  } else {
    return (
      <Window width={710} height={500} title="Генератор аномалий">
        <Window.Content>
          <LabeledList>
            <LabeledList.Item label="Источники энергии">
              <Button
                content="ЛКП"
                selected={use_acps}
                onClick={() => act('toggle_apcs', {})}
              />
              <Button
                content="СКАНы рядом"
                selected={use_smeses}
                onClick={() => act('toggle_smeses', {})}
              />
              <Button
                content="Узел энергосети"
                selected={use_powernet}
                disabled={!has_powernet}
                onClick={() => act('toggle_powernet', {})}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Тип аномалии">
              <Button
                content="Случайный"
                selected={type === 'random'}
                onClick={() => act('choose_type', { type: 'random' })}
              />
              <Button
                content="Атмосферная"
                selected={type === 'pyroclastic'}
                onClick={() => act('choose_type', { type: 'pyroclastic' })}
              />
              <Button
                content="Блюспейс"
                selected={type === 'bluespace'}
                onClick={() => act('choose_type', { type: 'bluespace' })}
              />
              <Button
                content="Вихревая"
                selected={type === 'vortex'}
                onClick={() => act('choose_type', { type: 'vortex' })}
              />
              <Button
                content="Гравитационная"
                selected={type === 'gravitational'}
                onClick={() => act('choose_type', { type: 'gravitational' })}
              />
              <Button
                content="Энергетическая"
                selected={type === 'energetic'}
                onClick={() => act('choose_type', { type: 'energetic' })}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Уровень аномалии">
              <Button
                content="Малая"
                selected={tier === '1'}
                onClick={() => act('choose_tier', { tier: '1' })}
              />
              <Button
                content="Средняя"
                selected={tier === '2'}
                onClick={() => act('choose_tier', { tier: '2' })}
              />
              <Button
                content="Большая"
                selected={tier === '3'}
                onClick={() => act('choose_tier', { tier: '3' })}
              />
            </LabeledList.Item>
          </LabeledList>
          <Box>Требуется: {req_item}</Box>
          <Box>Расходуемый заряд: {req_energy}</Box>
          <Button
            content="Создать аномалию"
            selected={creating === true}
            mt="0.5rem"
            onClick={() => act('generate')}
          />
          <Button
            content="Извлечь содержимое"
            mt="0.5rem"
            onClick={() => act('eject_all')}
          />
          <Button
            content="Выбрать маячок"
            mt="0.5rem"
            onClick={() => act('beakon')}
          />
        </Window.Content>
      </Window>
    );
  }
};
