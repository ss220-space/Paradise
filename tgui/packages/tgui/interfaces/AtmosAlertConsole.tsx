import { useBackend } from '../backend';
import { Button, Section } from '../components';
import { Window } from '../layouts';

type AtmosAlertData = {
  priority: string[];
  minor: string[];
};

export const AtmosAlertConsole = (props: unknown) => {
  const { act, data } = useBackend<AtmosAlertData>();
  const priorityAlerts = data.priority || [];
  const minorAlerts = data.minor || [];
  return (
    <Window width={350} height={300}>
      <Window.Content scrollable>
        <Section title="Alarms">
          <ul>
            {priorityAlerts.length === 0 && (
              <li className="color-good">No Priority Alerts</li>
            )}
            {priorityAlerts.map((alert) => (
              <li key={alert}>
                <Button
                  m="1px"
                  icon="times"
                  color="bad"
                  onClick={() => act('clear', { zone: alert })}
                >
                  {alert}
                </Button>
              </li>
            ))}
            {minorAlerts.length === 0 && (
              <li className="color-good">No Minor Alerts</li>
            )}
            {minorAlerts.map((alert) => (
              <li key={alert}>
                <Button
                  m="1px"
                  icon="times"
                  color="average"
                  onClick={() => act('clear', { zone: alert })}
                >
                  {alert}
                </Button>
              </li>
            ))}
          </ul>
        </Section>
      </Window.Content>
    </Window>
  );
};
