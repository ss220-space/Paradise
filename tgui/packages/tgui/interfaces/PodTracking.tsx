import { useBackend } from '../backend';
import { LabeledList, Section } from '../components';
import { Window } from '../layouts';

type PodTrackingData = {
  pods: Pod[];
};
type Pod = {
  name: string;
  podx: number;
  pody: number;
  podz: number;
  pilot: string;
  passengers: string[];
};

export const PodTracking = (_props: unknown) => {
  const { data } = useBackend<PodTrackingData>();
  const { pods } = data;
  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        {pods.map((p) => (
          <Section title={p.name} key={p.name}>
            <LabeledList>
              <LabeledList.Item label="Position">
                {p.podx}, {p.pody}, {p.podz}
              </LabeledList.Item>
              <LabeledList.Item label="Pilot">{p.pilot}</LabeledList.Item>
              <LabeledList.Item label="Passengers">
                {p.passengers}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
