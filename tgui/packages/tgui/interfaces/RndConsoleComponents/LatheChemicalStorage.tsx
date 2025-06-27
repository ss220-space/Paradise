import { useBackend } from '../../backend';
import { Button, LabeledList, Section } from '../../components';

type ChemicalStorageData = {
  loaded_chemicals: Chemical[];
} & RndData;

export const LatheChemicalStorage = (properties) => {
  const { data, act } = useBackend<ChemicalStorageData>();

  const { loaded_chemicals } = data;

  const lathe = data.menu === 4;

  return (
    <Section title="Chemical Storage">
      <Button
        icon="trash"
        onClick={() => {
          const action = lathe ? 'disposeallP' : 'disposeallI';
          act(action);
        }}
      >
        Purge All
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
              Purge
            </Button>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};
