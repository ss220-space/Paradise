import { Button, LabeledList, Section } from 'tgui-core/components';
import { useBackend } from '../../backend';

type ChemicalStorageData = {
  loaded_chemicals: Chemical[];
} & RndData;

export const LatheChemicalStorage = (_properties: unknown) => {
  const { data, act } = useBackend<ChemicalStorageData>();

  const { loaded_chemicals } = data;

  const lathe = data.menu === 4;

  return (
    <Section title="Буфер реагентов">
      <Button
        icon="trash"
        onClick={() => {
          const action = lathe ? 'disposeallP' : 'disposeallI';
          act(action);
        }}
      >
        Удалить всё
      </Button>

      <LabeledList>
        {loaded_chemicals.map(({ volume, name, id }) => (
          <LabeledList.Item label={`* ${volume} of ${name}`} key={id}>
            <Button
              icon="trash"
              onClick={() => {
                const action = lathe ? 'disposeP' : 'disposeI';
                act(action, { id });
              }}
            >
              Удалить
            </Button>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
