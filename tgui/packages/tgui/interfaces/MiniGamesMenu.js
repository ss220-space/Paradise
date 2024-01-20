import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section } from '../components';
import { Window } from '../layouts';

export const MiniGamesMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const spawners = data.spawners || [];
  const thunderdome_eligible = data.thunderdome_eligible;
  const notifications_enabled = data.notifications_enabled;
  return (
    <Window
      resizable>
      <Window.Content scrollable>
        <Button
          fluid
          textAlign="center"
          icon="power-off"
          tooltip={thunderdome_eligible ? "Выключить участие в боевых мини-играх" : "Включить участие в боевых мини-играх"}
          tooltipPosition="bottom"
          content={thunderdome_eligible ? "Выключить участие в боевых мини-играх" : "Включить участие в боевых мини-играх"}
          color={thunderdome_eligible ? "good" : "bad"}
          onClick={() => act('toggle_minigames')}
        />
        <Button
          fluid
          textAlign="center"
          icon="power-off"
          tooltip={notifications_enabled ? "Отключить уведомления о боевых мини-играх" : "Включить уведомления о боевых мини-играх"}
          tooltipPosition="bottom"
          content={notifications_enabled ? "Отключить уведомления о боевых мини-играх" : "Включить уведомления о боевых мини-играх"}
          color={notifications_enabled ? "good" : "bad"}
          onClick={() => act('toggle_notifications')}
        />
        <Section>
          {spawners.map(spawner => (
            <Section
              mb={0.5}
              key={spawner.name}
              title={spawner.name}
              level={2}
              buttons={(
                <Fragment>
                  <Button
                    icon="chevron-circle-right"
                    content="Jump"
                    onClick={() => act('jump', {
                      ID: spawner.uids,
                    })} />
                  <Button
                    icon="chevron-circle-right"
                    content="Start"
                    onClick={() => act('spawn', {
                      ID: spawner.uids,
                    })} />
                </Fragment>
              )}>
              <Box
                style={{ "white-space": "pre-wrap" }} // preserve newline
                mb={1}
                fontSize="16px">
                {spawner.desc}
              </Box>
              {!!spawner.fluff && (
                <Box // lighter grey than default grey for better contrast.
                  style={{ "white-space": "pre-wrap" }}
                  textColor="#878787"
                  fontSize="14px">
                  {spawner.fluff}
                </Box>
              )}
              {!!spawner.important_info && (
                <Box
                  style={{ "white-space": "pre-wrap" }}
                  mt={1}
                  bold
                  color="red"
                  fontSize="18px">
                  {spawner.important_info}
                </Box>
              )}
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
