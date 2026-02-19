import { useBackend } from '../backend';
import { Button, LabeledList, Box, Section, Dimmer, Icon } from '../components';
import { Window } from '../layouts';

type PersonalCraftingData = {
  busy: boolean;
  category: string;
  display_craftable_only: boolean;
  display_compact: boolean;
  prev_cat: string;
  next_cat: string;
  subcategory: boolean;
  prev_subcat: string;
  next_subcat: string;
  can_craft: CraftItem[];
  cant_craft: CraftItem[];
};

type CraftItem = {
  name: string;
  ref: string;
  catalyst_text: string;
  req_text: string;
  tool_text: string;
};

export const PersonalCrafting = (_props: unknown) => {
  const { act, data } = useBackend<PersonalCraftingData>();
  const {
    busy,
    category,
    display_craftable_only,
    display_compact,
    prev_cat,
    next_cat,
    subcategory,
    prev_subcat,
    next_subcat,
  } = data;
  return (
    <Window width={700} height={800}>
      <Window.Content scrollable>
        {!!busy && (
          <Dimmer fontSize="32px">
            <Icon name="cog" spin={1} />
            {' Crafting...'}
          </Dimmer>
        )}
        <Section
          title={category}
          buttons={
            <>
              <Button
                icon={display_craftable_only ? 'check-square-o' : 'square-o'}
                selected={display_craftable_only}
                onClick={() => act('toggle_recipes')}
              >
                Show Craftable Only
              </Button>
              <Button
                icon={display_compact ? 'check-square-o' : 'square-o'}
                selected={display_compact}
                onClick={() => act('toggle_compact')}
              >
                Compact Mode
              </Button>
            </>
          }
        >
          <Box>
            <Button icon="arrow-left" onClick={() => act('backwardCat')}>
              {prev_cat}
            </Button>
            <Button icon="arrow-right" onClick={() => act('forwardCat')}>
              {next_cat}
            </Button>
          </Box>
          {subcategory && (
            <Box>
              <Button icon="arrow-left" onClick={() => act('backwardSubCat')}>
                {prev_subcat}
              </Button>
              <Button icon="arrow-right" onClick={() => act('forwardSubCat')}>
                {next_subcat}
              </Button>
            </Box>
          )}
          {display_compact ? <CompactView /> : <ExpandedView />}
        </Section>
      </Window.Content>
    </Window>
  );
};

const CompactView = (_props: unknown) => {
  const { act, data } = useBackend<PersonalCraftingData>();
  const { display_craftable_only, can_craft, cant_craft } = data;
  return (
    <Box mt={1}>
      <LabeledList>
        {can_craft.map((r) => (
          <LabeledList.Item key={r.ref} label={r.name}>
            <Button icon="hammer" onClick={() => act('make', { make: r.ref })}>
              Craft
            </Button>
            {r.catalyst_text && (
              <Button tooltip={r.catalyst_text} color="transparent">
                Catalysts
              </Button>
            )}
            <Button tooltip={r.req_text} color="transparent">
              Requirements
            </Button>
            {r.tool_text && (
              <Button tooltip={r.tool_text} color="transparent">
                Tools
              </Button>
            )}
          </LabeledList.Item>
        ))}
        {!display_craftable_only &&
          cant_craft.map((r) => (
            <LabeledList.Item key={r.ref} label={r.name}>
              <Button icon="hammer" disabled>
                Craft
              </Button>
              {r.catalyst_text && (
                <Button tooltip={r.catalyst_text} color="transparent">
                  Catalysts
                </Button>
              )}
              <Button tooltip={r.req_text} color="transparent">
                Requirements
              </Button>
              {r.tool_text && (
                <Button tooltip={r.tool_text} color="transparent">
                  Tools
                </Button>
              )}
            </LabeledList.Item>
          ))}
      </LabeledList>
    </Box>
  );
};

const ExpandedView = (_props: unknown) => {
  const { act, data } = useBackend<PersonalCraftingData>();
  const { display_craftable_only, can_craft, cant_craft } = data;
  return (
    <Box mt={1}>
      {can_craft.map((r) => (
        <Section
          key={r.ref}
          title={r.name}
          buttons={
            <Button icon="hammer" onClick={() => act('make', { make: r.ref })}>
              Craft
            </Button>
          }
        >
          <LabeledList>
            {r.catalyst_text && (
              <LabeledList.Item label="Catalysts">
                {r.catalyst_text}
              </LabeledList.Item>
            )}
            <LabeledList.Item label="Requirements">
              {r.req_text}
            </LabeledList.Item>
            {r.tool_text && (
              <LabeledList.Item label="Tools">{r.tool_text}</LabeledList.Item>
            )}
          </LabeledList>
        </Section>
      ))}
      {!display_craftable_only &&
        cant_craft.map((r) => (
          <Section
            key={r.ref}
            title={r.name}
            buttons={
              <Button icon="hammer" disabled>
                Craft
              </Button>
            }
          >
            <LabeledList>
              {r.catalyst_text && (
                <LabeledList.Item label="Catalysts">
                  {r.catalyst_text}
                </LabeledList.Item>
              )}
              <LabeledList.Item label="Requirements">
                {r.req_text}
              </LabeledList.Item>
              {r.tool_text && (
                <LabeledList.Item label="Tools">{r.tool_text}</LabeledList.Item>
              )}
            </LabeledList>
          </Section>
        ))}
    </Box>
  );
};
