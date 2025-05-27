import { useBackend } from '../../backend';
import { Button, Section, Table } from '../../components';
import { LatheMaterials } from './index';

type LatheCategoryData = {
  category: string;
  matching_designs: Designs[];
} & RndData;

type Designs = {
  id: string;
  name: string;
  can_build: number;
  materials: Material[];
};
// Also handles search results
export const LatheCategory = (properties) => {
  const { data, act } = useBackend<LatheCategoryData>();

  const { category, matching_designs, menu } = data;

  const lathe = menu === 4;
  // imprinter current ignores amount, only prints 1, always can_build 1 or 0
  const action = lathe ? 'build' : 'imprint';

  return (
    <Section title={category}>
      <LatheMaterials />
      <Table className="RndConsole__LatheCategory__MatchingDesigns">
        {matching_designs.map(({ id, name, can_build, materials }) => {
          return (
            <Table.Row key={id}>
              <Table.Cell>
                <Button
                  icon="print"
                  disabled={can_build < 1}
                  onClick={() => act(action, { id, amount: 1 })}
                >
                  {name}
                </Button>
              </Table.Cell>
              <Table.Cell>
                {can_build >= 5 ? (
                  <Button onClick={() => act(action, { id, amount: 5 })}>
                    x5
                  </Button>
                ) : null}
              </Table.Cell>
              <Table.Cell>
                {can_build >= 10 ? (
                  <Button onClick={() => act(action, { id, amount: 10 })}>
                    x10
                  </Button>
                ) : null}
              </Table.Cell>
              <Table.Cell>
                {materials.map(({ name, amount, is_red }) => (
                  <>
                    {' | '}
                    <span className={is_red ? 'color-red' : null}>
                      {amount} {name}
                    </span>
                  </>
                ))}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};
