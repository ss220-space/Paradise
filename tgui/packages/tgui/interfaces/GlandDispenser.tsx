import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

type GlandDispenserData = {
  glands: Gland[];
};

type Gland = {
  id: string;
  color: string;
  amount: number;
};

export const GlandDispenser = (props: unknown) => {
  const { act, data } = useBackend<GlandDispenserData>();
  const { glands = [] } = data;
  return (
    <Window width={300} height={338} theme="abductor">
      <Window.Content>
        <Section>
          {glands.map((gland) => (
            <Button
              key={gland.id}
              width="60px"
              height="60px"
              m={0.75}
              textAlign="center"
              fontSize="17px"
              lineHeight="55px"
              icon="eject"
              backgroundColor={gland.color}
              disabled={!gland.amount}
              onClick={() =>
                act('dispense', {
                  gland_id: gland.id,
                })
              }
            >
              {gland.amount || '0'}
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
