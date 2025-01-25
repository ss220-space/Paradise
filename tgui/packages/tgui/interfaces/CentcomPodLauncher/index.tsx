import { Section, Stack } from '../../components';
import { Window } from '../../layouts';
import { useCompact } from './hooks';
import { PodBays } from './PodBays';
import { PodLaunch } from './PodLaunch';
import { PodSounds } from './PodSounds';
import { PodStatusPage } from './PodStatusPage';
import { PresetsPage } from './PresetsPage';
import { ReverseMenu } from './ReverseMenu';
import { StylePage } from './StylePage';
import { Timing } from './Timing';
import { ViewTabHolder } from './ViewTabHolder';

export const CentcomPodLauncher = (props, context) => {
  const [compact] = useCompact(context);

  return (
    <Window
      height={compact ? 360 : 440}
      title="Меню капсул снабжения"
      width={compact ? 460 : 750}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item shrink={0}>
            <PodStatusPage />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item grow shrink={0} basis="14.1em">
                <Stack fill vertical>
                  <Stack.Item grow>
                    <PresetsPage />
                  </Stack.Item>
                  <Stack.Item>
                    <ReverseMenu />
                  </Stack.Item>
                  <Stack.Item>
                    <Section>
                      <PodLaunch />
                    </Section>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              {!compact && (
                <Stack.Item grow={3}>
                  <ViewTabHolder />
                </Stack.Item>
              )}
              <Stack.Item basis="9em">
                <Stack fill vertical direction="column">
                  <Stack.Item>
                    <PodBays />
                  </Stack.Item>
                  <Stack.Item grow>
                    <Timing />
                  </Stack.Item>
                  {!compact && (
                    <Stack.Item>
                      <PodSounds fill />
                    </Stack.Item>
                  )}
                </Stack>
              </Stack.Item>
              <Stack.Item basis="11em">
                <StylePage />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
