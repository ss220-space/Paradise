import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { BAYS } from './constants';
import { PodLauncherData } from './types';

export const PodBays = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const { bayNumber } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="trash"
            onClick={() => act('clearBay')}
            tooltip={`
              Очищает всё
из выбранного ангара.`}
            tooltipPosition="top-end"
          />
          <Button
            color="transparent"
            icon="question"
            tooltip={`
              Каждый вариант соответствует
определённой зоне на ЦК.
Запущенные капсулы будут
заполнены предметами из этих зон
в соответствии с опцией
«Загрузка из ангара» в левом верхнем углу.`}
            tooltipPosition="top-end"
          />
        </>
      }
      fill
      title="Ангар"
    >
      {BAYS.map((bay, i) => (
        <Button
          key={i}
          onClick={() => act('switchBay', { bayNumber: '' + (i + 1) })}
          selected={bayNumber === '' + (i + 1)}
          tooltipPosition="bottom-end"
        >
          {bay.title}
        </Button>
      ))}
    </Section>
  );
};
