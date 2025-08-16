import { createSearch, toTitleCase } from 'common/string';
import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  DmIcon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Countdown } from '../components/Countdown';
import { Window } from '../layouts';
import { CollapsibleProps } from '../components/Collapsible';

const canBeMade = (design: Item, brsail: number, pwrail: number) => {
  if (design.requirements === null) {
    return true;
  }
  if (design.requirements.brass > brsail) {
    return false;
  }
  if (design.requirements.power > pwrail) {
    return false;
  }
  return true;
};

type WorkshopData = {
  brass_amount: number;
  power_amount: number;
  building: number;
  buildStart: number;
  buildEnd: number;
  worldTime: number;
  items: Record<string, Record<string, Item>>;
};

type Item = {
  name: string;
  icon: string;
  icon_state: string;
  affordable: boolean;
  requirements?: Requirements;
};

type Requirements = {
  brass: number;
  power: number;
};

export const Workshop = (_properties) => {
  const { act, data } = useBackend<WorkshopData>();
  const {
    brass_amount,
    power_amount,
    building,
    buildStart,
    buildEnd,
    worldTime,
  } = data;

  const [searchText, SetSearchText] = useState('');
  const [descending, SetDescending] = useState(false);

  const brassReadable = brass_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,'); // add thousands seperator
  const powerReadable = power_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

  return (
    <Window width={400} height={500} theme="clockwork">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <WorkshopSearch
              setSearchText={SetSearchText}
              descending={descending}
              setDescending={SetDescending}
            />
            <Section title="Materials">
              <LabeledList>
                <LabeledList.Item label="Brass">
                  {brassReadable}
                  <Button
                    icon={'arrow-down'}
                    height="19px"
                    tooltip={'Dispense Brass'}
                    tooltipPosition="bottom-start"
                    ml="0.5rem"
                    onClick={() => act('dispense')}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Power">
                  {powerReadable}
                </LabeledList.Item>
              </LabeledList>
              {building && (
                <ProgressBar.Countdown
                  mt={2}
                  start={buildStart}
                  current={worldTime}
                  end={buildEnd}
                  bold
                >
                  Building {building}
                  &nbsp;(
                  <Countdown
                    current={worldTime}
                    timeLeft={buildEnd - worldTime}
                    format={(v, f) => f.substring(3)}
                  />
                  )
                </ProgressBar.Countdown>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <WorkshopItems searchText={searchText} descending={descending} />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type DescendingProps = Partial<{
  descending: boolean;
  setDescending: React.Dispatch<React.SetStateAction<boolean>>;
}>;

type WorkshopState = SearchTextProps & DescendingProps;

const WorkshopSearch = (properties: WorkshopState) => {
  const { setSearchText, descending, setDescending } = properties;
  return (
    <Box mb="0.5rem">
      <Stack width="100%">
        <Stack.Item grow={1} mr="0.5rem">
          <Input
            placeholder="Search by item name.."
            width="100%"
            expensive
            onChange={setSearchText}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            icon={descending ? 'arrow-down' : 'arrow-up'}
            height="19px"
            tooltip={descending ? 'Descending order' : 'Ascending order'}
            tooltipPosition="bottom-start"
            ml="0.5rem"
            onClick={() => setDescending(!descending)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const WorkshopItems = (properties: WorkshopState) => {
  const { data } = useBackend<WorkshopData>();
  const { items } = data;

  // Search thingies
  const { searchText, descending } = properties;
  const searcher = createSearch<[string, Item]>(searchText, (item) => {
    return item[0];
  });

  let has_contents = false;
  const contents = Object.entries(items).map((kv, _i) => {
    let items_in_cat = Object.entries(kv[1])
      .filter(searcher)
      .map((kv2) => {
        kv2[1].affordable = canBeMade(
          kv2[1],
          data.brass_amount,
          data.power_amount
        );
        return kv2[1];
      });
    if (items_in_cat.length === 0) {
      return;
    }
    if (descending) {
      items_in_cat = items_in_cat.reverse();
    }

    has_contents = true;
    return (
      <WorkshopItemsCategory key={kv[0]} title={kv[0]} items={items_in_cat} />
    );
  });
  return (
    <Stack.Item grow={1}>
      <Section>
        {has_contents ? (
          contents
        ) : (
          <Box color="label">No items matching your criteria was found!</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

type WorkshopItemsCategoryProps = {
  items: Item[];
} & CollapsibleProps;

const WorkshopItemsCategory = (properties: WorkshopItemsCategoryProps) => {
  const { act, data } = useBackend<WorkshopData>();
  const { title, items, ...rest } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map((item) => (
        <Box key={item.name}>
          <DmIcon
            icon={item.icon}
            icon_state={item.icon_state}
            style={{
              verticalAlign: 'middle',
              width: '32px',
              margin: '0px',
              marginLeft: '0px',
            }}
          />
          <Button
            icon="hammer"
            disabled={!canBeMade(item, data.brass_amount, data.power_amount)}
            onClick={() =>
              act('make', {
                cat: title,
                name: item.name,
              })
            }
          >
            {toTitleCase(toTitleCase(item.name))}
          </Button>
          <Box
            inline
            verticalAlign="middle"
            lineHeight="20px"
            style={{
              float: 'right',
            }}
          >
            {(item.requirements &&
              Object.keys(item.requirements)
                .map((mat) => toTitleCase(mat) + ': ' + item.requirements[mat])
                .join(', ')) || <Box>No resources required.</Box>}
          </Box>
          <Box
            style={{
              clear: 'both',
            }}
          />
        </Box>
      ))}
    </Collapsible>
  );
};
