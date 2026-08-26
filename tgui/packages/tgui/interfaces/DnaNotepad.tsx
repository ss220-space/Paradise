import { useBackend } from '../backend';
import { Box, Section, Button, LabeledList, Flex, Stack } from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type DnaNotepadData = {
  dna_data: DnaDetailData[];
};

type DnaDetailData = {
  num: number;
  name: string;
  color: string;
};

export const DnaNotepad = (props: unknown) => {
  const { act, data } = useBackend<DnaNotepadData>();
  const { dna_data } = data;

  return (
    <Window width={900} height={700} title="Планшет генетика">
      <ComplexModal />
      <Window.Content scrollable>
        {(() => {
          return (
            <Section
              title="Блоки генов"
              lineHeight="10px"
              mb="15px"
              buttons={
                <>
                  <Button icon="trash" onClick={() => act('clear')}>
                    Очистить данные
                  </Button>
                  <Button icon="print" onClick={() => act('print')}>
                    Напечатать данные
                  </Button>
                </>
              }
            >
              <DnaEntriesBlock dna_data={dna_data} />
            </Section>
          );
        })()}
      </Window.Content>
    </Window>
  );
};

type DnaEntriesBlockProps = {
  dna_data: DnaDetailData[];
};

const DnaEntriesBlock = (props: DnaEntriesBlockProps) => {
  const { act } = useBackend<DnaNotepadData>();
  const { dna_data } = props;

  let dnaBlocks = [];
  for (let i = 0; i < dna_data.length; i++) {
    let dnaBlock = dna_data[i];
    let stackItem = (
      <Stack.Item mb="1rem" mr="1rem" width="30%">
        <Box inline mr="0.5rem">
          <span style={{ color: '#FFFFFF' }}>{dnaBlock.num}</span>
          {': '}
          <span style={{ color: dnaBlock.color }}>{dnaBlock.name}</span>{' '}
          <Button
            icon="pen"
            onClick={() =>
              act('edit_dna_block', {
                id: dnaBlock.num,
              })
            }
          />
        </Box>
      </Stack.Item>
    );
    dnaBlocks.push(stackItem);
  }
  return <Flex wrap="wrap">{dnaBlocks}</Flex>;
};
