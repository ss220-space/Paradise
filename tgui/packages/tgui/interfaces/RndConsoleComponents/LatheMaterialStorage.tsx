import { useBackend } from '../../backend';
import { Button, Section, Table } from '../../components';

type LatheMaterialStorageData = {
  loaded_materials: Material[];
} & RndData;

export const LatheMaterialStorage = (properties) => {
  const { data, act } = useBackend<LatheMaterialStorageData>();
  const { loaded_materials } = data;
  return (
    <Section
      className="RndConsole__LatheMaterialStorage"
      title="Material Storage"
    >
      <Table>
        {loaded_materials.map(({ id, amount, name }) => {
          const eject = (amount: number | string) => {
            const action =
              data.menu === 4 ? 'lathe_ejectsheet' : 'imprinter_ejectsheet';
            act(action, { id, amount });
          };
          // 1 sheet = 2000 units
          const sheets = Math.floor(amount / 2000);
          const empty = amount < 1;
          const plural = sheets === 1 ? '' : 's';
          return (
            <Table.Row
              key={id}
              className={empty ? 'color-grey' : 'color-yellow'}
            >
              <Table.Cell minWidth="210px">
                * {amount} of {name}
              </Table.Cell>
              <Table.Cell minWidth="110px">
                ({sheets} sheet{plural})
              </Table.Cell>
              <Table.Cell>
                {amount >= 2000 ? (
                  <>
                    <Button icon="eject" onClick={() => eject(1)}>
                      1x
                    </Button>
                    <Button icon="eject" onClick={() => eject('custom')}>
                      C
                    </Button>
                    {amount >= 2000 * 5 ? (
                      <Button icon="eject" onClick={() => eject(5)}>
                        5x
                      </Button>
                    ) : null}
                    <Button icon="eject" onClick={() => eject(50)}>
                      All
                    </Button>
                  </>
                ) : null}
              </Table.Cell>
            </Table.Row>
          );
        })}
      </Table>
    </Section>
  );
};
