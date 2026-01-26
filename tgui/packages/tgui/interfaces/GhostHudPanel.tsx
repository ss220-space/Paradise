import { useBackend } from '../backend';
import { Button, Section, Flex, Divider } from '../components';
import { Window } from '../layouts';

type GhostHudPanelData = {
  security: boolean;
  medical: boolean;
  diagnostic: boolean;
  ahud: boolean;
};

export const GhostHudPanel = (props: unknown) => {
  const { data } = useBackend<GhostHudPanelData>();
  const { security, medical, diagnostic, ahud } = data;
  return (
    <Window width={250} height={207} theme="nologo">
      <Window.Content>
        <Section>
          <HudEntry label="Medical" type="medical" is_active={medical} />
          <HudEntry label="Security" type="security" is_active={security} />
          <HudEntry
            label="Diagnostic"
            type="diagnostic"
            is_active={diagnostic}
          />
          <Divider />
          <HudEntry
            label="Antag HUD"
            is_active={ahud}
            act_on={'ahud_on'}
            act_off={'ahud_off'}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

type HudEntryProps = {
  label: string;
  type?: string;
  is_active: boolean;
  act_on?: string;
  act_off?: string;
};

const HudEntry = (props: HudEntryProps) => {
  const { act } = useBackend();
  const {
    label,
    type = null,
    is_active,
    act_on = 'hud_on',
    act_off = 'hud_off',
  } = props;
  return (
    <Flex pt={0.3} color="label">
      <Flex.Item pl={0.5} align="center" width="80%">
        {label}
      </Flex.Item>
      <Flex.Item>
        <Button
          mr={0.6}
          icon={is_active ? 'toggle-on' : 'toggle-off'}
          selected={is_active}
          onClick={() => act(is_active ? act_off : act_on, { hud_type: type })}
        >
          {is_active ? 'On' : 'Off'}
        </Button>
      </Flex.Item>
    </Flex>
  );
};
