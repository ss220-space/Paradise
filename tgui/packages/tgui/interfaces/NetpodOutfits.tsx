import { createSearch } from 'tgui-core/string';
import { useBackend, useLocalState } from '../backend';
import { Button, Input, NoticeBox, Section, Stack, Tabs } from 'tgui-core/components';
import { Window } from '../layouts';

type Data = {
  netsuit: string;
  collections: Collection[];
};

type Collection = {
  name: string;
  outfits: Outfit[];
};

type Outfit = {
  path: string;
  name: string;
};

export const NetpodOutfits = (_props) => {
  const { act, data } = useBackend<Data>();
  const { netsuit, collections = [] } = data;
  const [tab, setTab] = useLocalState('tab', 0);
  const [searchText, setSearchText] = useLocalState('searchText', '');

  const selectedCollection = collections[tab] ?? collections[0];
  const testSearch = createSearch(searchText, (outfit: Outfit) => outfit.name);
  const outfits = (selectedCollection?.outfits ?? [])
    .filter(testSearch)
    .sort((first, second) => (first.name > second.name ? 1 : -1));

  const selected = collections
    .flatMap((collection) => collection.outfits)
    .find((outfit) => outfit.path === netsuit);

  return (
    <Window width={420} height={440}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs fluid>
              {collections.map((collection, index) => (
                <Tabs.Tab
                  key={collection.name}
                  onClick={() => setTab(index)}
                  selected={tab === index}
                >
                  {collection.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Облик аватара"
              buttons={
                <Input
                  placeholder="Поиск"
                  value={searchText}
                  onChange={setSearchText}
                />
              }
            >
              {outfits.map((outfit) => (
                <Stack.Item key={outfit.path}>
                  <Button
                    fluid
                    color="transparent"
                    selected={outfit.path === netsuit}
                    onClick={() =>
                      act('select_outfit', { outfit: outfit.path })
                    }
                  >
                    {outfit.name}
                  </Button>
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
          <Stack.Item>
            <NoticeBox info mb={0}>
              Выбрано: {selected?.name ?? 'ничего'}
            </NoticeBox>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
