import { Fragment } from 'inferno';
import { useBackend } from "../backend";
import { Box, Button, Flex, LabeledList, ProgressBar, Section } from "../components";
import { BeakerContents } from "./common/BeakerContents";
import { Window } from "../layouts";

const dispenseAmounts = [1, 5, 10, 20, 30, 50];
const removeAmounts = [1, 5, 10];

export const ChemDispenserHandheld = (props, context) => {
  return (
    <Window resizable>
      <Window.Content className="Layout__content--flexColumn">
        <ChemDispenserHandheldSettings />
        <ChemDispenserHandheldChemicals />
        <ChemDispenserHandheldBeaker />
      </Window.Content>
    </Window>
  );
};

const ChemDispenserHandheldSettings = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    amount,
    energy,
    maxEnergy,
    mode,
  } = data;
  return (
    <Section title="Settings" flex="content">
      <LabeledList>
        <LabeledList.Item label="Energy">
          <ProgressBar
            value={energy}
            minValue={0}
            maxValue={maxEnergy}
            ranges={{
              good: [maxEnergy * 0.5, Infinity],
              average: [maxEnergy * 0.25, maxEnergy * 0.5],
              bad: [-Infinity, maxEnergy * 0.25],
            }}>
            {energy} / {maxEnergy} Units
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Amount" verticalAlign="middle">
          <Flex direction="row" spacing="1">
            {dispenseAmounts.map((a, i) => (
              <Flex.Item key={i} grow="1" width="14%" display="inline-block">
                <Button
                  icon="cog"
                  selected={amount === a}
                  content={a}
                  m="0"
                  width="100%"
                  onClick={() => act('amount', {
                    amount: a,
                  })}
                />
              </Flex.Item>
            ))}
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ChemDispenserHandheldChemicals = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    chemicals = [],
    current_reagent,
  } = data;
  const flexFillers = [];
  for (let i = 0; i < (chemicals.length + 1) % 3; i++) {
    flexFillers.push(true);
  }
  return (
    <Section
      title={data.glass ? 'Drink Selector' : 'Chemical Selector'}
      flexGrow="1">
      <Flex
        direction="row"
        wrap="wrap"
        height="100%"
        spacingPrecise="2"
        align="flex-start"
        alignContent="flex-start">
        {chemicals.map((c, i) => (
          <Flex.Item
            key={i}
            grow="1"
            basis="25%"
            height="20px"
            width="30%"
            display="inline-block">
            <Button
              icon="arrow-circle-down"
              overflow="hidden"
              textOverflow="ellipsis"
              selected={current_reagent === c.id}
              width="100%"
              height="100%"
              align="flex-start"
              content={c.title}
              onClick={() => act('dispense', {
                reagent: c.id,
              })}
            />
          </Flex.Item>
        ))}
        {flexFillers.map((_, i) => (
          <Flex.Item key={i} grow="1" basis="25%" height="20px" />
        ))}
      </Flex>
    </Section>
  );
};

const ChemDispenserHandheldBeaker = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    isContainerLoaded,
    containerCurrentVolume,
    containerMaxVolume,
    containerContents = [],
  } = data;
  return (
    <Section
      title={data.containerName}
      flex="content"
      minHeight="25%"
      buttons={(
        <Box>
          {!!isContainerLoaded && (
            <Box inline color="label" mr={2}>
              {containerCurrentVolume} / {containerMaxVolume} units
            </Box>
          )}
        </Box>
      )}>
      <BeakerContents
        beakerLoaded={isContainerLoaded}
        beakerContents={containerContents}
        buttons={chemical => (
          <Fragment>
            <Button
              content="Isolate"
              icon="compress-arrows-alt"
              onClick={() => act('remove', {
                reagent: chemical.id,
                amount: -1,
              })}
            />
            {removeAmounts.map((a, i) => (
              <Button
                key={i}
                content={a}
                onClick={() => act('remove', {
                  reagent: chemical.id,
                  amount: a,
                })}
              />
            ))}
            <Button
              content="ALL"
              onClick={() => act('remove', {
                reagent: chemical.id,
                amount: chemical.volume,
              })}
            />
            <Button
              content={"Floor"}
              tooltip={'Set to ' + Math.trunc(chemical.volume)}
              tooltipPosition="bottom-left"
              icon="arrow-circle-down"
              onClick={() => act('remove', {
                reagent: chemical.id,
                amount: -2,
              })}
            />
          </Fragment>
        )}
      />
    </Section>
  );
};
