import { existsSync } from 'fs';
import { useBackend } from '../backend';
import { Box, Section, Button, LabeledList, Flex, Stack } from '../components';
import { Window } from '../layouts';

type AutopsyData = {
  exists: boolean;
  target_name: string;
  death_time: string;
  scan_time: string;
  weapons: AutopsyWeaponData[];
};

type AutopsyWeaponData = {
  number: number;
  severity: string;
  count: number;
  time: string;
  bodyparts: string;
  name: string;
};

export const Autopsy = (props: unknown) => {
  const { act, data } = useBackend<AutopsyData>();

  let buttons = []
  if(data.exists) {
    buttons.push(
      <Button icon="trash" onClick={() => act('clear')}>
        Очистить данные
      </Button>
    )
    buttons.push(
      <Button icon="print" onClick={() => act('print_data')}>
        Напечатать данные
      </Button>
    )
  }
  buttons.push(
    <Button icon="pencil" onClick={() => act('print_report')}>
      Заполнить форму отчета
    </Button>
  )
  let dataEntries = []
  for (let i = 0; i < data.weapons.length; i++) {
    let weapon = data.weapons[i];
    dataEntries.push(
      (<Section title={weapon.number} mb="15px">
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
      </Section>)
    )
  }
  let mainContent = (
    <Section
      title="Данные"
      mb="15px"
      buttons={
          buttons
      }
    >
      <LabeledList>
        <LabeledList.Item label="Цель">
          {data.target_name}
        </LabeledList.Item>
        <LabeledList.Item label="Время смерти">
          {data.death_time}
        </LabeledList.Item>
        <LabeledList.Item label="Время сканирования">
          {data.scan_time}
        </LabeledList.Item>
      </LabeledList>
      {dataEntries}
    </Section>
  )
  return (
    <Window width={600} height={500} title="Сканнер аутопсии">
      <Window.Content scrollable>
        {mainContent}
      </Window.Content>
    </Window>
  );
};
