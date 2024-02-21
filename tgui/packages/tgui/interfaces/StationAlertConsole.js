import { useBackend } from '../backend';
import { Section } from '../components';
import { Window } from '../layouts';

export const StationAlertConsole = () => {
  return (
    <Window resizable>
      <Window.Content scrollable>
        <StationAlertConsoleContent />
      </Window.Content>
    </Window>
  );
};

export const StationAlertConsoleContent = (props, context) => {
  const { data } = useBackend(context);
  const categories = data.alarms || [];

  return (
    Object.keys(categories).map(categoryName => (
      <Section key={categoryName} title={`${categoryName} Alarms`}>
        <ul>
          {categories[categoryName]?.length === 0 ? (
            <li className="color-good">
              Systems Nominal
            </li>
          ) : (
            categories[categoryName]?.map(alert => (
              <li key={alert} className="color-average">
                {alert}
              </li>
            ))
          )}
        </ul>
      </Section>
    ))
  );
};
