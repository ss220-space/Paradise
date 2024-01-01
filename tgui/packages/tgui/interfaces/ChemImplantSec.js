import { useBackend } from "../backend";
import { LabeledList, Box, Button, ProgressBar } from "../components";
import { Window } from "../layouts";

export const ChemImplantSec = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    dead,
    health,
    current_chemicals,
    available_chemicals,
  } = data;
  return (
    <Window resizable>
      <Window.Content  className="Layout__content--flexColumn">
        <Box>
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
            <LabeledList.Item label="Current Chemicals">
              {current_chemicals}
            </LabeledList.Item>
            <LabeledList.Item label="Available Chemicals">
              {available_chemicals.map(s => (
                <Button key={s.key} content={s.name + " (" + s.amount + ")"} tooltip={s.desc} disabled={current_chemicals === 0} onClick={
                  () => act('secreteChemicals', { key: s.key })
                } />
              ))}
              {available_chemicals.length === 0 && (
                "No chemicals available!"
              )}
            </LabeledList.Item>
          </LabeledList>
        </Box>
      </Window.Content>
    </Window>
  );
};
