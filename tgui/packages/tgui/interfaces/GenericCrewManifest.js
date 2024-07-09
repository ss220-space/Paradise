import { Section } from '../components';
import { Window } from '../layouts';
import { CrewManifest } from './common/CrewManifest';

export const GenericCrewManifest = (props, context) => {
  return (
    <Window width={588} height={510} theme="nologo">
      <Window.Content scrollable>
        <Section noTopPadding>
          <CrewManifest />
        </Section>
      </Window.Content>
    </Window>
  );
};
