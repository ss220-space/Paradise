import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList, Grid } from '../components';
import { Window } from '../layouts';

type PixelShiftData = {
  pixel_x: number;
  pixel_y: number;
  max_shift_x: number;
  max_shift_y: number;
  random_drop_on: boolean;
};

export const ItemPixelShift = (props: unknown) => {
  const { act, data } = useBackend<PixelShiftData>();
  const { pixel_x, pixel_y, max_shift_x, max_shift_y, random_drop_on } = data;

  return (
    <Window width={250} height={160}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="X-coordinates">
              <Button
                icon="arrow-left"
                tooltip="Shifts item leftwards."
                disabled={pixel_x === -max_shift_x}
                onClick={() => act('shift_left')}
              />
              <NumberInput
                animated
                lineHeight={1.7}
                width="75px"
                unit="pixels"
                stepPixelSize={6}
                step={1}
                value={pixel_x}
                minValue={-max_shift_x}
                maxValue={max_shift_x}
                onChange={(value) =>
                  act('custom_x', {
                    pixel_x: value,
                  })
                }
              />
              <Button
                icon="arrow-right"
                tooltip="Shifts item rightwards."
                disabled={pixel_x === max_shift_x}
                onClick={() => act('shift_right')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Y-coordinates">
              <Button
                icon="arrow-up"
                tooltip="Shifts item upwards."
                disabled={pixel_y === max_shift_y}
                onClick={() => act('shift_up')}
              />
              <NumberInput
                animated
                lineHeight={1.7}
                width="75px"
                unit="pixels"
                stepPixelSize={6}
                step={1}
                value={pixel_y}
                minValue={-max_shift_y}
                maxValue={max_shift_y}
                onChange={(value) =>
                  act('custom_y', {
                    pixel_y: value,
                  })
                }
              />
              <Button
                icon="arrow-down"
                tooltip="Shifts item downwards."
                disabled={pixel_y === -max_shift_y}
                onClick={() => act('shift_down')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section>
          <Grid>
            <Grid.Column>
              <Button
                fluid
                color="brown"
                icon="arrow-up"
                tooltip="Tries to place an item on top of the others."
                onClick={() => act('move_to_top')}
              >
                Move to Top
              </Button>
            </Grid.Column>
            <Grid.Column>
              <Button
                fluid
                color={random_drop_on ? 'good' : 'bad'}
                icon="power-off"
                tooltip="Enables/Disables item pixel randomization on any drops."
                onClick={() => act('toggle')}
              >
                {random_drop_on ? 'Shift Enabled' : 'Shift Disabled'}
              </Button>
            </Grid.Column>
          </Grid>
        </Section>
      </Window.Content>
    </Window>
  );
};
