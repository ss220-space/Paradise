import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Button,
  LabeledList,
  Flex,
  Box,
  Section,
  Table,
  DmIcon,
} from '../components';

type PDAPainterData = {
  statusLabel: string;
  pdaTypes: string[];
  hasPDA: boolean;
  pdaIcon: string;
  pdaIconState: string;
  pdaOwnerName: string;
  pdaJobName: string;
};

export const PDAPainter = (props: unknown) => {
  const { act, data } = useBackend<PDAPainterData>();

  const {
    statusLabel,
    pdaTypes,
    hasPDA,
    pdaIcon,
    pdaIconState,
    pdaOwnerName,
    pdaJobName,
  } = data;

  return (
    <Window width={545} height={350}>
      <Window.Content>
        <Flex spacing={1} direction="row" height="100%" flex="1">
          <Flex.Item width={24} shrink={0}>
            <Section
              title="Общее"
              buttons={
                <Button
                  fluid
                  icon={hasPDA ? 'eject' : 'exclamation-triangle'}
                  selected={hasPDA}
                  tooltip={hasPDA ? 'Извлечь PDA' : 'Вставить PDA'}
                  tooltipPosition="left"
                  onClick={() => act(hasPDA ? 'eject_pda' : 'insert_pda')}
                >
                  {hasPDA ? 'Извлечь' : '-----'}
                </Button>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Имя">
                  {pdaOwnerName ? pdaOwnerName : 'Н/Д'}
                </LabeledList.Item>
                <LabeledList.Item label="Должность">
                  {pdaJobName ? pdaJobName : 'Н/Д'}
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section>
              <Flex height="100%" direction="column" flex="1">
                <Flex.Item>
                  <Box textAlign="center">
                    <DmIcon
                      height="160px" // Set image size here.
                      icon={pdaIcon}
                      icon_state={pdaIconState}
                      align="middle"
                    />
                  </Box>
                  <LabeledList>
                    <LabeledList.Item label="Статус">
                      {statusLabel}
                    </LabeledList.Item>
                  </LabeledList>

                  <Button.Confirm
                    m="5px"
                    fluid
                    disabled={!hasPDA}
                    confirmContent="Подтвердить?"
                    textAlign="left"
                    color="red"
                    tooltip={'Cбросить телефон на заводские настройки'}
                    tooltipPosition="top"
                    onClick={() => act('erase_pda')}
                  >
                    Стереть PDA
                  </Button.Confirm>
                </Flex.Item>
              </Flex>
            </Section>
          </Flex.Item>
          <Flex.Item width={27}>
            <Flex direction="column" height="100%" flex="1">
              <Section title="Цвет PDA" flexGrow scrollable fill>
                <Table>
                  {Object.keys(pdaTypes).map((key) => (
                    <PDAColorRow key={key} selectedPda={key} />
                  ))}

                  {/* Logic explanation for dummies.
                    PDApainter.dm:
                      data["pdaTypes"] = colorlist << all pda colors here
                      colorlist is a list(list()):
                        example: colorlist[initial(P.icon_state)] = list(iconImage, initial(P.desc))

                        to get data:
                          colorlist[pda-clown] - yields a list that has image and description.
                          colorlist[pda-clown][1] - to get image
                          colorlist[pda-clown][2] - to get description

                    [!] in DM an array starts from 1

                      then it goes as:
                        var/data = list()
                        data["pdaTypes"] = colorlist

                    in PDAPainter.js
                      pdaTypes[key]
                      pdaTypes[pda-clown] - yields a list that has image and description.
                      pdaTypes[pda-clown][0] - to get image
                      pdaTypes[pda-clown][1] - to get description

                      [!] in JS an array start from 0
                  */}
                </Table>
              </Section>
            </Flex>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

type PDAColorRowProps = {
  selectedPda: string;
};

export const PDAColorRow = (props: PDAColorRowProps) => {
  const { act, data } = useBackend<PDAPainterData>();

  const { hasPDA, pdaIcon } = data;

  const { selectedPda } = props;

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <DmIcon
          icon={pdaIcon}
          icon_state={selectedPda}
          style={{
            verticalAlign: 'middle',
            width: '32px',
            margin: '0px',
            marginLeft: '0px',
          }}
        />
      </Table.Cell>
      <Table.Cell bold>
        <Button.Confirm
          fluid
          disabled={!hasPDA}
          icon={selectedPda}
          confirmContent="Покрасить?"
          textAlign="left"
          onClick={() =>
            act('choose_pda', {
              selectedPda: selectedPda,
            })
          }
        >
          {selectedPda}
        </Button.Confirm>
      </Table.Cell>
    </Table.Row>
  );
};
