import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  Section,
  Box,
  LabeledList,
  Input,
  Icon,
  DmIcon,
} from '../components';
import { Window } from '../layouts';

type ImplantPadData = {
  implant: Implant;
  contains_case: boolean;
  tag: string;
};

type Implant = {
  name: string;
  icon: string;
  icon_state: string;
  life: string;
  notes: string;
  function: string;
};

export const ImplantPad = (props: unknown) => {
  const { act, data } = useBackend<ImplantPadData>();
  const { implant, contains_case, tag } = data;
  const [newTag, setNewTag] = useState(tag);

  return (
    <Window width={410} height={325}>
      <Window.Content>
        <Section
          fill
          title="Bio-chip Mini-Computer"
          buttons={
            <Box>
              <Button
                icon="eject"
                disabled={!contains_case}
                onClick={() => act('eject_case')}
              >
                Eject Case
              </Button>
            </Box>
          }
        >
          {implant && contains_case ? (
            <>
              <Box bold mb={2}>
                <DmIcon
                  icon={implant.icon}
                  icon_state={implant.icon_state}
                  ml={0}
                  mr={2}
                  style={{
                    verticalAlign: 'middle',
                    width: '32px',
                  }}
                />
                {implant.name}
              </Box>
              <LabeledList>
                <LabeledList.Item label="Life">{implant.life}</LabeledList.Item>
                <LabeledList.Item label="Notes">
                  {implant.notes}
                </LabeledList.Item>
                <LabeledList.Item label="Function">
                  {implant.function}
                </LabeledList.Item>
                {!!tag && (
                  <LabeledList.Item label="Tag">
                    <Input
                      width="5.5rem"
                      value={tag}
                      onEnter={() => act('tag', { newtag: newTag })}
                      onChange={setNewTag}
                    />
                    <Button
                      disabled={tag === newTag}
                      width="20px"
                      mb="0"
                      ml="0.25rem"
                      onClick={() => act('tag', { newtag: newTag })}
                    >
                      <Icon name="pen" />
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </>
          ) : contains_case ? (
            <Box>This bio-chip case has no implant!</Box>
          ) : (
            <Box>Please insert a bio-chip casing!</Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
