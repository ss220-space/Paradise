import { useBackend } from '../backend';
import { Box, Button, Grid, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';

export const DNAModifyer = (props, context) => {
  const { act } = useBackend(context);
  return (
    <Window>
      <Window.Content>
        <Section title="Personal Gene Therapy">
          <Button
            onClick={() => act("gene", { modification: "Toxin Adaptation" })}>
            Toxin Adaptation
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Lung Enhancement" })}>
            Lung Enhancement
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Thermal Regulation" })}>
            Thermal Regulation
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Neural Repathing" })}>
            Neural Repathing
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Hardened Skin" })}>
            Hardened Skin
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Leg Muscle Stimulus" })}>
            Leg Muscle Stimulus
          </Button>
          <Button
            onClick={() => act("gene", { modification: "Arm Muscle Stimulus" })}>
            Arm Muscle Stimulus
          </Button>
        </Section>
      </Window.Content>
    </Window>
  );
};
