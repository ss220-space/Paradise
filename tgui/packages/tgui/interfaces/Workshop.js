import { createSearch, toTitleCase } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Collapsible,
  Dropdown,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Countdown } from '../components/Countdown';
import { Window } from '../layouts';

const canBeMade = (design, brsail, pwrail) => {
  if (design.requirements === null) {
    return true;
  }
  if (design.requirements['brass'] > brsail) {
    return false;
  }
  if (design.requirements['power'] > pwrail) {
    return false;
  }
  return true;
};

export const Workshop = (_properties, context) => {
  const { act, data } = useBackend(context);
  const {
    brass_amount,
    power_amount,
    building,
    buildStart,
    buildEnd,
    worldTime,
  } = data;

  const brassReadable = brass_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,'); // add thousands seperator
  const powerReadable = power_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

  const styleLeftDiv = {
    float: 'left',
    width: '60%',
  };
  const styleRightDiv = {
    float: 'right',
    width: '39%',
  };

  return (
    <Window width={400} height={500} theme="clockwork">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <WorkshopSearch />
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
                    format={(v, f) => f.substr(3)}
                  />
                  )
                </ProgressBar.Countdown>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill scrollable>
              <WorkshopItems />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const WorkshopSearch = (_properties, context) => {
  const [_searchText, setSearchText] = useLocalState(context, 'search', '');
  const [_sortOrder, setSortOrder] = useLocalState(context, 'sort', '');
  const [descending, setDescending] = useLocalState(
    context,
    'descending',
    false
  );
  return (
    <Box mb="0.5rem">
      <Stack width="100%">
        <Stack.Item grow="1" mr="0.5rem">
          <Input
            placeholder="Search by item name.."
            width="100%"
            onInput={(_e, value) => setSearchText(value)}
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

const WorkshopItems = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { items } = data;

  // Search thingies
  const [searchText, _setSearchText] = useLocalState(context, 'search', '');
  const [sortOrder, _setSortOrder] = useLocalState(
    context,
    'sort',
    'Alphabetical'
  );
  const [descending, _setDescending] = useLocalState(
    context,
    'descending',
    false
  );
  const searcher = createSearch(searchText, (item) => {
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
    <Stack.Item grow="1">
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

const WorkshopItemsCategory = (properties, context) => {
  const { act, data } = useBackend(context);
  const { title, items, ...rest } = properties;
  return (
    <Collapsible open title={title} {...rest}>
      {items.map((item) => (
        <Box key={item.name}>
          <img
            src={`data:image/jpeg;base64,${item.image}`}
            style={{
              'vertical-align': 'middle',
              width: '32px',
              margin: '0px',
              'margin-left': '0px',
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
            display="inline-block"
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
