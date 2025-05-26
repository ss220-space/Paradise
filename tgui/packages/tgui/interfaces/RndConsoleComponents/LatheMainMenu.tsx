import { useBackend } from '../../backend';
import { Button, Divider, Flex, Section } from '../../components';
import { LatheMaterials, LatheSearch } from './index';

type MainMenuData = { categories: string[] } & RndData;

export const LatheMainMenu = (properties) => {
  const { data, act } = useBackend<MainMenuData>();

  const { menu, categories } = data;

  const label = menu === 4 ? 'Protolathe' : 'Circuit Imprinter';

  return (
    <Section title={label + ' Menu'}>
      <LatheMaterials />
      <LatheSearch />

      <Divider />

      <Flex wrap="wrap">
        {categories.map((cat) => (
          <Flex
            key={cat}
            style={{
              flexBasis: '50%',
              marginBottom: '6px',
            }}
          >
            <Button
              icon="arrow-right"
              onClick={() => {
                act('setCategory', { category: cat });
              }}
            >
              {cat}
            </Button>
          </Flex>
        ))}
      </Flex>
    </Section>
  );
};
