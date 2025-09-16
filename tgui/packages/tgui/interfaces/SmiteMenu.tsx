import { useBackend } from '../backend';
import { Button, Table, Section, Input, Box } from '../components';
import { Window } from '../layouts';

type SmiteMenuData = {
  all_smites: string[];
  all_descs: string[];
  choosen: string;
  reason: string;
};

export const SmiteMenu = (_props: unknown) => {
  const { act, data } = useBackend<SmiteMenuData>();
  const { all_smites, all_descs, choosen, reason } = data;
  return (
    <Window width={460} height={320}>
      <Window.Content>
        <Section>
          <Input
            value={reason}
            onChange={(value) => act('change_reason', { 'new_reason': value })}
          />
          <Button onClick={() => act('activate')}>Применить кару</Button>
          <Box mt="5px">
            <Table>
              {all_smites &&
                all_smites.map &&
                all_smites.map((smite, i) => (
                  <Button
                    key={smite}
                    selected={smite === choosen}
                    tooltip={all_descs[i]}
                    onClick={() =>
                      act('change_choosen', {
                        'new_choosen': smite,
                      })
                    }
                  >
                    {smite}
                  </Button>
                ))}
            </Table>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
