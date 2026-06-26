import { useBackend } from '../backend';
import { Section, Button, LabeledList } from '../components';
import { Window } from '../layouts';

type AutopsyData = {
  exists: boolean;
  target_name: string;
  death_time: string;
  scan_time: string;
  weapons: AutopsyWeaponData[];
};

type AutopsyWeaponData = {
  number: string;
  severity: string;
  count: number;
  time: string;
  bodyparts: string;
  name: string;
};

export const Autopsy = (props: unknown) => {
  const { act, data } = useBackend<AutopsyData>();

  return (
    <Window width={600} height={500} title="Сканнер аутопсии">
      <Window.Content scrollable>
        <Section
          title="Данные"
          mb="15px"
          buttons={
            <>
              {data.exists && (
                <>
                  <Button icon="trash" onClick={() => act('clear')}>
                    Очистить данные
                  </Button>
                  <Button icon="print" onClick={() => act('print_data')}>
                    Напечатать данные
                  </Button>
                </>
              )}
              <Button icon="pencil" onClick={() => act('print_report')}>
                Заполнить форму отчета
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Цель">{data.target_name}</LabeledList.Item>
            <LabeledList.Item label="Время смерти">
              {data.death_time}
            </LabeledList.Item>
            <LabeledList.Item label="Время сканирования">
              {data.scan_time}
            </LabeledList.Item>
          </LabeledList>
          {data.weapons.map((weapon, i) => (
            <Section title={weapon.number} mb="15px" key={weapon.number}>
              <LabeledList>
                <LabeledList.Item label="Тяжесть:">
                  {weapon.severity}
                </LabeledList.Item>
                <LabeledList.Item label="Нанесено ударов">
                  {weapon.count}
                </LabeledList.Item>
                <LabeledList.Item label="Время нанесения ранения">
                  {weapon.time}
                </LabeledList.Item>
                <LabeledList.Item label="Поражённые части тела">
                  {weapon.bodyparts}
                </LabeledList.Item>
                <LabeledList.Item label="Оружие">
                  {weapon.name}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
