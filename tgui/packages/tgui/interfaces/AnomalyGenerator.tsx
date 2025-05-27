import { useBackend } from '../backend';
import { Box, Button, LabeledList } from '../components';
import { Window } from '../layouts';

type AnomalyGeneratorData = {
  type: string;
  tier: string;
  creating: boolean;
  req_energy: boolean;
  req_item: boolean;
  anomaly_type: string;
  charge: number;
  generating: boolean;
  use_acps: boolean;
  use_smeses: boolean;
  use_powernet: boolean;
  has_powernet: boolean;
  last_charge: string;
};

export const AnomalyGenerator = (_props) => {
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
                selected={use_acps}
                onClick={() => act('toggle_apcs', {})}
              >
                ЛКП
              </Button>
              <Button
                selected={use_smeses}
                onClick={() => act('toggle_smeses', {})}
              >
                СКАНы рядом
              </Button>
              <Button
                selected={use_powernet}
                disabled={!has_powernet}
                onClick={() => act('toggle_powernet', {})}
              >
                Узел энергосети
              </Button>
            </LabeledList.Item>
          </LabeledList>
          <Box>Создается {anomaly_type} аномалия.</Box>
          <Box>
            Накоплено энергии: {charge}/{req_energy}
          </Box>
          <Box>Накопление энергии в секунду: {last_charge}</Box>
          <Button onClick={() => act('stop', {})}>Прекратить создание</Button>
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
                selected={use_acps}
                onClick={() => act('toggle_apcs', {})}
              >
                ЛКП
              </Button>
              <Button
                selected={use_smeses}
                onClick={() => act('toggle_smeses', {})}
              >
                СКАНы рядом
              </Button>
              <Button
                selected={use_powernet}
                disabled={!has_powernet}
                onClick={() => act('toggle_powernet', {})}
              >
                Узел энергосети
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Тип аномалии">
              <Button
                selected={type === 'random'}
                onClick={() => act('choose_type', { type: 'random' })}
              >
                Случайный
              </Button>
              <Button
                selected={type === 'pyroclastic'}
                onClick={() => act('choose_type', { type: 'pyroclastic' })}
              >
                Атмосферная
              </Button>
              <Button
                selected={type === 'bluespace'}
                onClick={() => act('choose_type', { type: 'bluespace' })}
              >
                Блюспейс
              </Button>
              <Button
                selected={type === 'vortex'}
                onClick={() => act('choose_type', { type: 'vortex' })}
              >
                Вихревая
              </Button>
              <Button
                selected={type === 'gravitational'}
                onClick={() => act('choose_type', { type: 'gravitational' })}
              >
                Гравитационная
              </Button>
              <Button
                selected={type === 'energetic'}
                onClick={() => act('choose_type', { type: 'energetic' })}
              >
                Энергетическая
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Уровень аномалии">
              <Button
                selected={tier === '1'}
                onClick={() => act('choose_tier', { tier: '1' })}
              >
                Малая
              </Button>
              <Button
                selected={tier === '2'}
                onClick={() => act('choose_tier', { tier: '2' })}
              >
                Средняя
              </Button>
              <Button
                selected={tier === '3'}
                onClick={() => act('choose_tier', { tier: '3' })}
              >
                Большая
              </Button>
            </LabeledList.Item>
          </LabeledList>
          <Box>Требуется: {req_item}</Box>
          <Box>Расходуемый заряд: {req_energy}</Box>
          <Button
            selected={creating === true}
            mt="0.5rem"
            onClick={() => act('generate')}
          >
            Создать аномалию
          </Button>
          <Button mt="0.5rem" onClick={() => act('eject_all')}>
            Извлечь содержимое
          </Button>
          <Button mt="0.5rem" onClick={() => act('beakon')}>
            Выбрать маячок
          </Button>
        </Window.Content>
      </Window>
    );
  }
};
