import { useBackend } from '../../backend';
import { Box, LabeledList, ProgressBar } from '../../components';

export const pai_bioscan = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    holder,
    dead,
    health,
    brute,
    oxy,
    tox,
    burn,
    reagents,
    addictions,
    fractures,
    internal_bleeding,
  } = data.app_data;

  if (!holder) {
    return <Box color="red">Error: No biological host found.</Box>;
  }
  return (
    <LabeledList>
      <LabeledList.Item label="Status">
        {dead ? (
          <Box bold color="red">
            Dead
          </Box>
        ) : (
          <Box bold color="green">
            Alive
          </Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Health">
        <ProgressBar
          min={0}
          max={1}
          value={health / 100}
          ranges={{
            good: [0.5, Infinity],
            average: [0, 0.5],
            bad: [-Infinity, 0],
          }}
        />
      </LabeledList.Item>
      <LabeledList.Item label="Oxygen Damage">
        <Box color="blue">{oxy}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Toxin Damage">
        <Box color="green">{tox}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Burn Damage">
        <Box color="orange">{burn}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Brute Damage">
        <Box color="red">{brute}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Reagents">
        {reagents
          ? reagents.map((reagent) => (
              <LabeledList.Item key={reagent.id} label={reagent.title}>
                <Box color={reagent.overdosed ? 'bad' : 'good'}>
                  {' '}
                  {reagent.volume} {reagent.overdosed ? 'OVERDOSED' : ''}{' '}
                </Box>
              </LabeledList.Item>
            ))
          : 'Reagents not found.'}
      </LabeledList.Item>
      <LabeledList.Item label="Addictions">
        {addictions ? (
          addictions.map((addiction) => (
            <LabeledList.Item
              key={addiction.id}
              label={addiction.addiction_name}
            >
              <Box color="bad"> Stage: {addiction.stage} </Box>
            </LabeledList.Item>
          ))
        ) : (
          <Box color="good">Addictions not found.</Box>
        )}
      </LabeledList.Item>
      <LabeledList.Item label="Fractures">
        <Box color={fractures ? 'bad' : 'good'}>
          Fractures {fractures ? '' : 'not'} detected.
        </Box>
      </LabeledList.Item>
      <LabeledList.Item label="Internal Bleedings">
        <Box color={internal_bleeding ? 'bad' : 'good'}>
          Internal Bleedings {internal_bleeding ? '' : 'not'} detected.
        </Box>
      </LabeledList.Item>
    </LabeledList>
  );
};
