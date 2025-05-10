import { useBackend } from '../backend';
import { Button, Section, Box } from '../components';
import { Window } from '../layouts';

type SyndicateComputerSimpleData = {
  rows: Record[];
};

type Record = {
  title: string;
  buttondisabled: boolean;
  buttontooltip: string;
  buttonact: string;
  buttontitle: string;
  status: string;
  bullets: string[];
};

export const SyndicateComputerSimple = (_props: unknown) => {
  const { act, data } = useBackend<SyndicateComputerSimpleData>();
  return (
    <Window width={400} height={400} theme="syndicate">
      <Window.Content>
        {data.rows.map((record) => (
          <Section
            key={record.title}
            title={record.title}
            buttons={
              <Button
                disabled={record.buttondisabled}
                tooltip={record.buttontooltip}
                tooltipPosition="left"
                onClick={() => act(record.buttonact)}
              >
                {record.buttontitle}
              </Button>
            }
          >
            {record.status}
            {!!record.bullets && (
              <Box>
                {record.bullets.map((bullet) => (
                  <Box key={bullet}>{bullet}</Box>
                ))}
              </Box>
            )}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
