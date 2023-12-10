import { useBackend, useLocalState } from '../backend';
import { Button, Section, Box, Input, Icon } from '../components';
import { LabeledList, LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const ImplantPad = (props, context) => {
  const { act, data } = useBackend(context);
  const { implant, contains_case, tag } = data;
  const [newTag, setNewTag] = useLocalState(context, "newTag", tag);

  return (
    <Window resizable>
      <Window.Content>
        <Section title="Bio-chip Information">
          {implant && contains_case ? (
            <>
              <Box bold mb={2}>
                <img
                  src={`data:image/jpeg;base64,${implant.image}`}
                  ml={0}
                  mr={2}
                  style={{
                    'vertical-align': 'middle',
                    width: '32px',
                  }}
                />
                {implant.name}
              </Box>
              <LabeledList>
                <LabeledListItem label="Life">{implant.life}</LabeledListItem>
                <LabeledListItem label="Notes">{implant.notes}</LabeledListItem>
                <LabeledListItem label="Function">{implant.function}</LabeledListItem>
              </LabeledList>
            </>
          ) : contains_case ? (
            <Box>This bio-chip case has no implant!</Box>
          ) : (
            <Box>Please insert a bio-chip casing!</Box>
          )}
        </Section>
        <Section title="Options">
          {tag && contains_case ? (
            <LabeledList>
              <Input
                ml={1}
                width="8rem"
                value={tag}
                onEnter={() => act('tag', { newtag: newTag })}
                onInput={(e, value) => setNewTag(value)}
              />
              <Button
                disabled={tag === newTag}
                width="20px"
                mb="0"
                ml="0.25rem"
                onClick={() => act('tag', { newtag: newTag })}>
                <Icon name="pen" />
              </Button>
            </LabeledList>
          ) : null}
          {contains_case ? (
            <Button
              mt={1}
              content="Eject Case"
              icon="eject"
              disabled={!contains_case}
              onClick={() => act('eject_case')}
            />
          ) : null}
        </Section>
      </Window.Content>
    </Window>
  );
};


