import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import {
  Box,
  Button,
  Input,
  LabeledList,
  Section,
  Stack,
  Dropdown,
  DmIcon,
} from '../components';
import { Window } from '../layouts';
import { createSearch, toTitleCase } from 'common/string';

const canBeMade = (
  recipe: Recipe,
  mavail: number,
  gavail: number,
  multi: number
) => {
  if (recipe.requirements === null) {
    return true;
  }
  if (recipe.requirements['metal'] * multi > mavail) {
    return false;
  }
  if (recipe.requirements['glass'] * multi > gavail) {
    return false;
  }
  return true;
};

type Recipe = {
  requirements: Record<string, number>;
  name: string;
  category: string[];
  hacked: boolean;
  icon: string;
  icon_state: string;
  uid: string;
  ref: string;
  max_multiplier: number;
};

type AutolatheData = {
  total_amount: number;
  metal_amount: number;
  glass_amount: number;
  busyname: string;
  buildQueue: string[];
  buildQueueLen: number;
  recipes: Recipe[];
  categories: string[];
  showhacked: boolean;
  busyamt: number;
  fill_percent: number;
};

export const Autolathe = (props: unknown) => {
  const { act, data } = useBackend<AutolatheData>();
  const {
    total_amount,
    metal_amount,
    glass_amount,
    busyname,
    buildQueue,
    buildQueueLen,
    recipes,
    categories,
  } = data;

  let [category, setCategory] = useSharedState('category', '');

  if (category === '') {
    category = 'Tools';
  }
  let metalReadable = metal_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,'); // add thousands seperator
  let glassReadable = glass_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
  let totalReadable = total_amount
    .toString()
    .replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const testSearch = createSearch(searchText, (recipe: Recipe) => recipe.name);

  let buildQueueItems: React.JSX.Element[] = [];
  if (buildQueueLen > 0) {
    buildQueueItems = buildQueue.map((a, i) => {
      return (
        <Box key={i}>
          <Button
            fluid
            key={a}
            icon="times"
            color="transparent"
            onClick={() =>
              act('remove_from_queue', {
                remove_from_queue: buildQueue.indexOf(a) + 1,
              })
            }
          >
            {buildQueue[i][0]}
          </Button>
        </Box>
      );
    });
  }

  const recipesToShow: Recipe[] = flow([
    (recipes: Recipe[]) =>
      filter<Recipe>(
        recipes,
        (recipe) =>
          (recipe.category.indexOf(category) > -1 || searchText) &&
          (data.showhacked || !recipe.hacked)
      ),
    (recipes: Recipe[]) =>
      searchText ? filter<Recipe>(recipes, testSearch) : recipes,
    (recipes: Recipe[]) =>
      sortBy(recipes, (recipe) => recipe.name.toLowerCase()),
  ])(recipes);

  let rText = 'Build';
  if (searchText) {
    rText = "Results for: '" + searchText + "':";
  } else if (category) {
    rText = 'Build (' + category + ')';
  }
  return (
    <Window width={750} height={525}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="70%">
            <Section
              fill
              scrollable
              title={rText}
              buttons={
                <Dropdown
                  width="150px"
                  options={categories}
                  selected={category.toString()}
                  onSelected={(val) => setCategory(val)}
                />
              }
            >
              <Input
                fluid
                placeholder="Search for..."
                expensive
                onChange={setSearchText}
                mb={1}
              />
              {recipesToShow.map((recipe) => (
                <Stack.Item grow key={recipe.ref}>
                  <DmIcon
                    icon={recipe.icon}
                    icon_state={recipe.icon_state}
                    style={{
                      verticalAlign: 'middle',
                      width: '32px',
                      margin: '0px',
                      marginLeft: '0px',
                    }}
                  />
                  <Button
                    mr={1}
                    icon="hammer"
                    selected={
                      data.busyname === recipe.name && data.busyamt === 1
                    }
                    disabled={
                      !canBeMade(
                        recipe,
                        data.metal_amount,
                        data.glass_amount,
                        1
                      )
                    }
                    onClick={() =>
                      act('make', {
                        make: recipe.uid,
                        multiplier: 1,
                      })
                    }
                  >
                    {toTitleCase(recipe.name)}
                  </Button>
                  {recipe.max_multiplier >= 10 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={
                        data.busyname === recipe.name && data.busyamt === 10
                      }
                      disabled={
                        !canBeMade(
                          recipe,
                          data.metal_amount,
                          data.glass_amount,
                          10
                        )
                      }
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: 10,
                        })
                      }
                    >
                      10x
                    </Button>
                  )}
                  {recipe.max_multiplier >= 25 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={
                        data.busyname === recipe.name && data.busyamt === 25
                      }
                      disabled={
                        !canBeMade(
                          recipe,
                          data.metal_amount,
                          data.glass_amount,
                          25
                        )
                      }
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: 25,
                        })
                      }
                    >
                      25x
                    </Button>
                  )}
                  {recipe.max_multiplier > 25 && (
                    <Button
                      mr={1}
                      icon="hammer"
                      selected={
                        data.busyname === recipe.name &&
                        data.busyamt === recipe.max_multiplier
                      }
                      disabled={
                        !canBeMade(
                          recipe,
                          data.metal_amount,
                          data.glass_amount,
                          recipe.max_multiplier
                        )
                      }
                      onClick={() =>
                        act('make', {
                          make: recipe.uid,
                          multiplier: recipe.max_multiplier,
                        })
                      }
                    >
                      {recipe.max_multiplier}x
                    </Button>
                  )}
                  {(recipe.requirements &&
                    Object.keys(recipe.requirements)
                      .map(
                        (mat) =>
                          toTitleCase(mat) + ': ' + recipe.requirements[mat]
                      )
                      .join(', ')) || <Box>No resources required.</Box>}
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item width="30%">
            <Section title="Materials">
              <LabeledList>
                <LabeledList.Item label="Metal">
                  {metalReadable}
                </LabeledList.Item>
                <LabeledList.Item label="Glass">
                  {glassReadable}
                </LabeledList.Item>
                <LabeledList.Item label="Total">
                  {totalReadable}
                </LabeledList.Item>
                <LabeledList.Item label="Storage">
                  {data.fill_percent}% Full
                </LabeledList.Item>
              </LabeledList>
            </Section>
            <Section title="Building">
              <Box color={busyname ? 'green' : ''}>
                {busyname ? busyname : 'Nothing'}
              </Box>
            </Section>
            <Section title="Build Queue" height={23.7}>
              {buildQueueItems}
              <Button
                mt={0.5}
                fluid
                icon="times"
                color="red"
                disabled={!data.buildQueueLen}
                onClick={() => act('clear_queue')}
              >
                Clear All
              </Button>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
