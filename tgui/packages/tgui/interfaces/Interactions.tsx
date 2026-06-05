import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

interface Data {
  partner: string;
  interactions: Interaction[]
}

interface Interaction {
  category: string
  action: string;
  label: string;
  danger?: boolean;
}

export const Interactions = (props) => {
  const { act, data } = useBackend<Data>();
  const { partner, interactions } = data;
  return (
    <Window
    width={320}
    height={540}
    title={`Взаимодействие с ${partner}`}>
      <Window.Content>
        <Section title="">
          {interactions
          .filter((i) => i.category === "")
          .map((interaction) => (
          <Button
              key={interaction.action}
              color={interaction.danger ? "red" : "blue"}
              onClick={() => act(interaction.action)}
            >
              {interaction.label}
            </Button>
          ))}
        </Section>
        <Section title="Руки">
            {interactions
          .filter((i) => i.category === "hands")
          .map((interaction) => (
          <Button
              key={interaction.action}
              color={interaction.danger ? "red" : "blue"}
              onClick={() => act(interaction.action)}
            >
              {interaction.label}
            </Button>
          ))}
        </Section>
        <Section title="Губы">
            {interactions
          .filter((i) => i.category === "mouth")
          .map((interaction) => (
          <Button
              key={interaction.action}
              color={interaction.danger ? "red" : "blue"}
              onClick={() => act(interaction.action)}
            >
              {interaction.label}
            </Button>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
