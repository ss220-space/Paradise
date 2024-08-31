import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Section,
  Tooltip,
  Button,
  Flex,
  LabeledList,
  Divider,
  Grid,
} from '../components';
import { Window } from '../layouts';
import { FlexItem } from '../components/Flex';

export const AutoDoc = (props, context) => {
  const { act, data } = useBackend(context);
  const { HasTray, TguiIcons, occupant, isHealing, fixtimer, healtimer } = data;
  const [ChoosenPart, ChoosePart] = useLocalState(
    context,
    'ChoosePart',
    'chest'
  );
  return (
    <Window theme="ntOS95" resizable>
      <Window.Content>
        <Flex width="100%">
          <FlexItem basis="30%">
            <img
              height="256px"
              width="256px"
              src={`data:image/jpeg;base64,${TguiIcons['human']}`}
              style={{
                position: 'absolute',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <img
              height="256px"
              width="256px"
              src={`data:image/jpeg;base64,${TguiIcons[ChoosenPart]}`}
              style={{
                position: 'absolute',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
          </FlexItem>
          <FlexItem basis="70%">
            <Section
              title="Info"
              buttons={
                <Fragment>
                  {Object.keys(TguiIcons).map(
                    (part) =>
                      !(part === 'human') && (
                        <Button
                          key={part}
                          content={part}
                          selected={part === ChoosenPart}
                          onClick={() => ChoosePart(part)}
                          z
                        />
                      )
                  )}

                  <Button
                    style={{
                      'margin-left': '30px',
                    }}
                    content={HasTray ? 'Eject Tray' : 'Reject Tray'}
                    locked={isHealing}
                    onClick={() => act('ChangeTrayState')}
                  />
                </Fragment>
              }
            >
              <Box>
                {!!(occupant[ChoosenPart] && occupant[ChoosenPart].extOrgan) &&
                  occupant[ChoosenPart].extOrgan.map((organ) => (
                    <Fragment key={organ.name}>
                      <b>{organ.name}</b>
                      <br />
                      {organ.open ? 'opened' : ''}
                      {organ.broken ? 'broken' : ''}
                      {!!organ.broken && (
                        <Fragment>
                          <Button
                            content="Fix"
                            style={{
                              'margin-left': '30px',
                            }}
                            locked={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'fracture',
                              })
                            }
                          />
                          <br />
                        </Fragment>
                      )}
                      {organ.internalBleeding ? 'bleeding' : ''}
                      {!!organ.internalBleeding && (
                        <Fragment>
                          <Button
                            content="Fix"
                            style={{
                              'margin-left': '30px',
                            }}
                            locked={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'bleeding',
                              })
                            }
                          />
                          <br />
                        </Fragment>
                      )}
                      Internals:
                      <Button
                        content="Complete"
                        style={{
                          'margin-left': '10px',
                        }}
                        locked={isHealing}
                        onClick={() =>
                          act('FixOrgan', {
                            organ: organ.name,
                            type: 'completeInternal',
                          })
                        }
                      />
                      <br />
                      {organ.dead ? 'dead' : ''}
                      {!!organ.dead && <br />}
                      {organ.germ_level
                        ? 'Germ level is ' + organ.germ_level
                        : ''}
                      {!!organ.germ_level && <br />}
                      {organ.totalLoss
                        ? 'Total damage is ' + organ.totalLoss
                        : ''}
                      <br />
                    </Fragment>
                  ))}
                {!!(occupant[ChoosenPart] && occupant[ChoosenPart].intOrgan) &&
                  occupant[ChoosenPart].intOrgan.map((organ) => (
                    <Fragment key={organ.name}>
                      <b>{organ.name}</b>
                      <Button
                        content="Remove"
                        style={{
                          'margin-left': '1.5rem',
                        }}
                        locked={isHealing}
                        onClick={() =>
                          act('FixOrgan', { organ: organ.name, type: 'remove' })
                        }
                      />
                      <br />
                      {organ.dead ? 'dead' : ''}
                      {!!organ.dead && <br />}
                      {organ.germ_level
                        ? 'Germ level is ' + organ.germ_level
                        : ''}
                      {!!organ.germ_level && <br />}
                      {organ.totalLoss ? 'Total damage is ' + organ.damage : ''}
                      {!!organ.totalLoss && (
                        <Fragment>
                          <Button
                            content="Heal"
                            style={{
                              'margin-left': '30px',
                            }}
                            locked={isHealing}
                            onClick={() =>
                              act('FixOrgan', {
                                organ: organ.name,
                                type: 'damage',
                              })
                            }
                          />
                          <br />
                        </Fragment>
                      )}
                    </Fragment>
                  ))}
                {!!occupant.TotalBruteBurn && (
                  <Fragment>
                    Total external damage is {occupant.TotalBruteBurn}
                    <Button
                      style={{
                        'margin-left': '30px',
                      }}
                      content="Start Healing"
                      onClick={() => act('HealBruteBurn')}
                    />
                    <Button
                      style={{
                        'margin-left': '30px',
                      }}
                      content="Reattach externals"
                      onClick={() => act('CompleteExternal')}
                    />
                  </Fragment>
                )}
                <br />
                {!!fixtimer && <b>Fixing organ: {fixtimer}</b>}
                {!!healtimer && <b>Healing external damage: {healtimer}</b>}
              </Box>
            </Section>
          </FlexItem>
        </Flex>
      </Window.Content>
    </Window>
  );
};
