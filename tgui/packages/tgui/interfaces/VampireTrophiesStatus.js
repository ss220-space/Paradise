import { useBackend } from '../backend';
import { Button, Box, Table, Section, Stack } from '../components';
import { Window } from '../layouts';

const roundTenths = function (input) {
  return (Math.round(input * 10) / 10).toFixed(1);
};

export const VampireTrophiesStatus = (props, context) => {
  return (
    <Window theme="nologo" width={700} height={800}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Trophies />
          <Passives />
          <InfectedTrophy />
          <Lunge />
          <MarkPrey />
          <MetamorphosisBats />
          <ResonantShriek />
          <Anabiosis />
          <SummonBats />
          <MetamorphosisHound />
          <LungeFinale />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Trophies = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    icon_hearts,
    icon_lungs,
    icon_livers,
    icon_kidneys,
    icon_eyes,
    icon_ears,
  } = data;
  return (
    <Stack.Item>
      <Section
        title="Trophies"
        color="red"
        textAlign="center"
        verticalAlign="middle"
      >
        <Stack fill>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_hearts}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-32px',
                'margin-right': '-48px',
                'margin-top': '-32px',
                'margin-bottom': '-48px',
                'height': '128px',
                'width': '128px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
              fontSize="20px"
            >
              {hearts}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Heart trophies are critical organs, that have increased the vitality and toughness of our kin for centuries. Maximum trophy amount of this type is 6."
              content="HEARTS"
              color="transparent"
            />
          </Box>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_lungs}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-8px',
                'margin-right': '-16px',
                'margin-top': '-12px',
                'margin-bottom': '-12px',
                'height': '72px',
                'width': '72px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
              fontSize="20px"
            >
              {lungs}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Lungs trophies are critical organs, they have always been used in rituals to increase agility and endurance of our kin. Maximum trophy amount of this type is 6."
              content="LUNGS"
              color="transparent"
            />
          </Box>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_livers}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-24px',
                'margin-right': '-24px',
                'margin-top': '-28px',
                'margin-bottom': '-20px',
                'height': '96px',
                'width': '96px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {livers}
            </Box>
            <Button
              tooltipPosition="right"
              tooltip="Liver trophies have always been used in traditional vampire's rites to increase blood control, which reduces spells cost. Maximum trophy amount of this type is 10."
              content="LIVERS"
              color="transparent"
            />
          </Box>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_kidneys}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-22px',
                'margin-right': '-26px',
                'margin-top': '-28px',
                'margin-bottom': '-20px',
                'height': '96px',
                'width': '96px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {kidneys}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Kidneys trophies are used by vampires as a catalysts to enhance various spell effects. Maximum trophy amount of this type is 10."
              content="KIDNEYS"
              color="transparent"
            />
          </Box>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_eyes}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-26px',
                'margin-right': '-22px',
                'margin-top': '-22px',
                'margin-bottom': '-26px',
                'height': '96px',
                'width': '96px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {eyes}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Eyes trophies are one of the most important ingredients to bypass any vision imperfections mortal bodies have. Maximum trophy amount of this type is 10."
              content="EYES"
              color="transparent"
            />
          </Box>
          <Box inline width="16.6%">
            <img
              src={`data:image/jpeg;base64,${icon_ears}`}
              verticalAlign="middle"
              style={{
                'margin-left': '-8px',
                'margin-right': '-8px',
                'margin-top': '-8px',
                'margin-bottom': '-8px',
                'height': '64px',
                'width': '64px',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <Box
              bold
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
              fontSize="20px"
            >
              {ears}
            </Box>
            <Button
              tooltipPosition="left"
              tooltip="Ears trophies have always helped our kin to improve control over emotions and therefore increased scope of the spells. Maximum trophy amount of this type is 10."
              content="EARS"
              color="transparent"
            />
          </Box>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const Passives = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    suck_rate,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    trophies_max_gen,
    trophies_max_crit,
    trophies_brute,
    trophies_burn,
    trophies_oxy,
    trophies_tox,
    trophies_brain,
    trophies_clone,
    trophies_stamina,
    trophies_flash,
    trophies_welding,
    trophies_xray,
    trophies_bang,
    trophies_blood,
  } = data;
  return (
    <Section
      title="Vampire Passives"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Obtained by dissecting hearts"
              content="Brute Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts < trophies_max_crit
                ? Math.ceil(hearts * (trophies_brute / trophies_max_crit))
                : trophies_brute}
              %{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Obtained by dissecting hearts"
              content="Burn Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts < trophies_max_crit
                ? Math.ceil(hearts * (trophies_burn / trophies_max_crit))
                : trophies_burn}
              %{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Obtained by dissecting lungs"
              content="Oxy Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs < trophies_max_crit
                ? Math.ceil(lungs * (trophies_oxy / trophies_max_crit))
                : trophies_oxy}
              %{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Obtained by dissecting livers"
              content="Toxin Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {livers < trophies_max_gen
                ? livers * (trophies_tox / trophies_max_gen)
                : trophies_tox}
              %{livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Obtained by dissecting kidneys"
              content="Brain Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys < trophies_max_gen
                ? kidneys * (trophies_brain / trophies_max_gen)
                : trophies_brain}
              %{kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Obtained by dissecting kidneys"
              content="Clone Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys < trophies_max_gen
                ? kidneys * (trophies_clone / trophies_max_gen)
                : trophies_clone}
              %{kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Obtained by dissecting lungs"
              content="Stamina Protection:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs < trophies_max_crit
                ? Math.ceil(lungs * (trophies_stamina / trophies_max_crit))
                : trophies_stamina}
              %{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Increased by dissecting livers"
              content="Blood Cost Reduce:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {livers < trophies_max_gen
                ? livers * (trophies_blood / trophies_max_gen)
                : trophies_blood}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Time spent on each sucking cycle, lower is better. Decreased by dissecting kidneys"
              content="Suck Rate:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {suck_rate}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Obtained by dissecting eyes"
              content="Flash Protection:"
              color="transparent"
            />
            <Box inline textColor={eyes < trophies_flash ? 'bad' : 'good'}>
              {eyes < trophies_flash ? 'LOCKED' : 'UNLOCKED'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Obtained by dissecting eyes"
              content="Welding Protection:"
              color="transparent"
            />
            <Box inline textColor={eyes < trophies_welding ? 'bad' : 'good'}>
              {eyes < trophies_welding ? 'LOCKED' : 'UNLOCKED'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Obtained by dissecting eyes"
              content="X-Ray Vision:"
              color="transparent"
            />
            <Box inline textColor={eyes < trophies_xray ? 'bad' : 'good'}>
              {eyes < trophies_xray ? 'LOCKED' : 'UNLOCKED'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Obtained by dissecting ears"
              content="Ears Bang Protection:"
              color="transparent"
            />
            <Box inline textColor={ears < trophies_bang ? 'bad' : 'good'}>
              {ears < trophies_bang ? 'LOCKED' : 'UNLOCKED'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const InfectedTrophy = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Infected Trophy"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum range before fired skull will disappear. Increased by dissecting eyes"
              content="Flight Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {5 + eyes}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Range of the area of effect, centered at the end position of the lunge. All living mobs will be affected inside. Increased by dissecting ears"
              content="AOE Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(ears / 4)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Amount of brute damage that every living victim in the AOE will receive. Increased by dissecting hearts"
              content="Damage:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 5}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of time that every living victim in the AOE will be stunned. Increased by dissecting hearts"
              content="Stun Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(hearts / 2)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Chance for every living humanoid victim in the AOE to contact Grave Fever disease. Increased by dissecting livers"
              content="Grave Fever Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {10 + livers * 3}%{livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Lunge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Lunge"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum distance at which lunge will stop automatically. Increased by dissecting lungs"
              content="Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + lungs}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Radius of the area of effect, centered at the end position of the lunge. All living mobs will be affected inside. Increased by dissecting ears"
              content="AOE Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {1 + Math.floor(ears / 5)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Amount of time that every living victim in the AOE will be weakened. Increased by dissecting hearts"
              content="Weaken Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(1 + hearts / 2)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of time that every living victim in the AOE will be confused. Increased by dissecting kidneys"
              content="Confusion Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys * 2)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Amount of blood that every living humanoid victim in the AOE will loose. Increased by dissecting kidneys"
              content="Bleeding Amount:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys * 10}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Amount of usable blood vampire will gain from every living sentient humanoid victim. Increased by dissecting kidneys."
              content="Blood Gain:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MarkPrey = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Mark the Prey"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum distance the spell can be cast. Increased by dissecting eyes"
              content="Cast Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {3 + Math.floor(eyes / 2)}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Amount of time that the mark will last. Increased by dissecting kidneys"
              content="Duration:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(5 + kidneys)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Amount of burn damage that the victim will receive every second if the chance worked. Increased by dissecting hearts"
              content="Burns / 1s.:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Chance for the burn damage to trigger. Increased by dissecting hearts"
              content="Burns Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 10}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Сhance that the victim will spontaneously attack nearby targets or even theirselves. Increased by dissecting eyes"
              content="Madness Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {30 + eyes * 7}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MetamorphosisBats = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Metamorphosis - Bats"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of that the bats can have. Increased by dissecting hearts"
              content="Health:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {130 + hearts * 20}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Threshold below which no damage to the bats can be dealt. Works only for melee attacks. Increased by dissecting hearts"
              content="Damage Threshold:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {3 + hearts * 2}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Movement speed of the bats, lower is better. Decreased by dissecting lungs"
              content="Speed:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Lowest amount of damage that the bats can inflict. Increased by dissecting hearts"
              content="Damage Low:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Highest amount of damage that the bats can inflict. Increased by dissecting hearts"
              content="Damage High:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Amount of health that bats will transform into their own after every succesfull attack. Increased by dissecting kidneys"
              content="Life Leech:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of usable blood that bats will gain from the living sentient humanoid victim after every succesfull attack. Increased by dissecting livers"
              content="Blood Gain:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Chance for the bats to stun their victim for 1 second after every succesfull attack. Increased by dissecting eyes"
              content="Fear Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const ResonantShriek = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Resonant Shriek"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Radius of the area of effect, centered at the position of the vampire. All living mobs will be affected inside. Increased by dissecting ears"
              content="AOE Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {2 + Math.floor(ears / 3)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Amount of time that every living victim in the AOE will be weakened. Increased by dissecting hearts"
              content="Weaken Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(hearts / 3)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Amount of time that every living victim in the AOE will be confused. Increased by dissecting kidneys"
              content="Confusion Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of brain damage that every living victim in the AOE will receive. Increased by dissecting eyes"
              content="Brain Damage:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}
              {eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const Anabiosis = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
    full_power,
  } = data;
  return (
    <Section
      title="Anabiosis"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of brute damage that vampire will heal during the anabiosis. Increased by dissecting hearts"
              content="Brute Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Maximum amount of burn damage that vampire will heal during the anabiosis. Increased by dissecting hearts"
              content="Burn Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (hearts + 4)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Maximum amount of toxin damage that vampire will heal during the anabiosis. Increased by dissecting livers"
              content="Tox Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (livers + 4)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of suffocation damage that vampire will heal during the anabiosis. Increased by dissecting lungs"
              content="Oxy Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {15 * (lungs * 2 + 8)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Maximum amount of genetic (clone) damage that vampire will heal during the anabiosis. Increased by dissecting kidneys"
              content="Clone Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * Math.round(kidneys / 2 + 2)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Maximum amount of blood that will be restored in the vampire's body during the anabiosis. Increased by dissecting kidneys"
              content="Blood Restored:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (kidneys * 2 + 12)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of damage that vampire's internal organs will heal during the anabiosis. Increased by dissecting kidneys"
              content="Organ Heal:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * Math.round(kidneys / 5 + 1)}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Maximum amount of reagents that will be removed from the vampire's body during the anabiosis. Increased by dissecting livers"
              content="Remove Reagents:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 * (livers + 5)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Chance to mend fracture per one anabiosis cycle (15 cycles total). Increased by dissecting hearts"
              content="Mend Fracture:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 4}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Chance to eliminate internal bleeding per one anabiosis cycle (15 cycles total). Increased by dissecting hearts"
              content="Heal Internal Bleeding:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {hearts * 4}%{hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Chance to regrow limb per one anabiosis cycle (15 cycles total). Increased by dissecting lungs"
              content="Regrow Limb:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {lungs * 2}%{lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="One-time action which removes all status effects, restores all dead organs and limbs, cures all harmfull viruses and expells all parasites."
              content="Fullpower Heal:"
              color="transparent"
            />
            <Box inline textColor={full_power ? 'good' : 'bad'}>
              {full_power ? 'UNLOCKED' : 'LOCKED'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const SummonBats = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  let maxBats =
    1 +
    (allTrophies < 40 ? Math.round(allTrophies / 2) : allTrophies < 52 ? 2 : 3);
  return (
    <Section
      title="Summon Bats"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of that the bats can have. Increased by dissecting hearts"
              content="Health:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {80 + hearts * 10}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Threshold below which no damage to the bats can be dealt. Works only for melee attacks. Increased by dissecting hearts"
              content="Damage Threshold:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {3 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Movement speed of the bats, lower is better. Decreased by dissecting lungs"
              content="Speed:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(1 - lungs * 0.1).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Lowest amount of damage that the bats can inflict. Increased by dissecting hearts"
              content="Damage Low:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + Math.floor(hearts / 2)}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Highest amount of damage that the bats can inflict. Increased by dissecting hearts"
              content="Damage High:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Amount of health that bats will transform into their own after every succesfull attack. Increased by dissecting kidneys"
              content="Life Leech:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of usable blood that bats will gain from the living sentient humanoid victim after every succesfull attack. All this blood will be transfered to the vampire. Increased by dissecting livers"
              content="Blood Gain:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(livers / 2)}
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Chance for the bats to stun their victim for 0.5 seconds after every succesfull attack. Increased by dissecting eyes"
              content="Fear Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(eyes * 1.5)}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Amount of bat packs spawned at once. Increased by collecting any type of the trophies"
              content="Bats Amount:"
              color="transparent"
            />
            <Box inline textColor={allTrophies < 52 ? 'average' : 'good'}>
              {maxBats}
              {allTrophies < 52 ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const MetamorphosisHound = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  return (
    <Section
      title="Metamorphosis - Hound"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Maximum amount of health that the hound can have. Increased by dissecting hearts"
              content="Health:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {200 + hearts * 30}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Threshold below which no damage to the hound can be dealt. Works only for melee attacks. Increased by dissecting hearts"
              content="Damage Threshold:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {10 + hearts * 3}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Movement speed of the hound, lower is better. Decreased by dissecting lungs"
              content="Speed:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {(-lungs * 0.05).toFixed(2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Lowest amount of damage that the hound can inflict. Increased by dissecting hearts"
              content="Damage Low:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {15 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Highest amount of damage that the hound can inflict. Increased by dissecting hearts"
              content="Damage High:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {20 + hearts}
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Chance for the hound to stun their victim for 1 second after every succesfull attack. Increased by dissecting eyes"
              content="Fear Chance:"
              color="transparent"
            />
            <Box
              inline
              textColor={eyes < trophies_max_gen ? 'average' : 'good'}
            >
              {eyes * 3}%{eyes < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of usable blood vampire will spend to stay transformed. Decreased by dissecting livers"
              content="Blood Cost:"
              color="transparent"
            />
            <Box
              inline
              textColor={livers < trophies_max_gen ? 'average' : 'good'}
            >
              {15 - livers} blood / 6s.
              {livers < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};

const LungeFinale = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    trophies_max_gen,
    trophies_max_crit,
    hearts,
    lungs,
    livers,
    kidneys,
    eyes,
    ears,
  } = data;
  let allTrophies = hearts + lungs + livers + kidneys + eyes + ears;
  let maxBats =
    1 +
    (allTrophies < 40 ? Math.round(allTrophies / 2) : allTrophies < 52 ? 2 : 3);
  return (
    <Section
      title="Lunge Finale"
      color="red"
      textAlign="center"
      verticalAlign="middle"
    >
      <Table italic="true" ml="2rem">
        <Table.Row>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="right"
              tooltip="Radius around the vampire in which targets will be searched. Increased by dissecting lungs"
              content="Search Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={lungs < trophies_max_crit ? 'average' : 'good'}
            >
              {5 + Math.round(lungs / 2)}
              {lungs < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="top"
              tooltip="Radius of the area of effect, centered at the end position of the lunge. All living mobs will be affected inside. Increased by dissecting ears"
              content="AOE Range:"
              color="transparent"
            />
            <Box
              inline
              textColor={ears < trophies_max_gen ? 'average' : 'good'}
            >
              {Math.floor(ears / 5)}
              {ears < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell width="33.3%">
            <Button
              tooltipPosition="left"
              tooltip="Amount of time that every living victim in the AOE will be weakened. Increased by dissecting hearts"
              content="Weaken Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={hearts < trophies_max_crit ? 'average' : 'good'}
            >
              {roundTenths(1 + hearts / 2)}s.
              {hearts < trophies_max_crit ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of time that every living victim in the AOE will be confused. Increased by dissecting kidneys"
              content="Confusion Time:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {roundTenths(kidneys * 2)}s.
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="Amount of blood that every living humanoid victim in the AOE will loose. Increased by dissecting kidneys"
              content="Bleeding Amount:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys * 5}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="left"
              tooltip="Amount of usable blood vampire will gain from every living sentient humanoid victim. Increased by dissecting kidneys."
              content="Blood Gained:"
              color="transparent"
            />
            <Box
              inline
              textColor={kidneys < trophies_max_gen ? 'average' : 'good'}
            >
              {kidneys}
              {kidneys < trophies_max_gen ? '' : ' (max)'}
            </Box>
          </Table.Cell>
        </Table.Row>
        <Table.Row>
          <Table.Cell>
            <Button
              tooltipPosition="right"
              tooltip="Amount of lunges that the hound will perform. Increased by collecting any type of the trophies"
              content="Lunges Amount:"
              color="transparent"
            />
            <Box inline textColor={allTrophies < 50 ? 'average' : 'good'}>
              {1 + Math.floor(allTrophies / 10)}
              {allTrophies < 50 ? '' : ' (max)'}
            </Box>
          </Table.Cell>
          <Table.Cell>
            <Button
              tooltipPosition="top"
              tooltip="After the ability is activated, the hound will perform defined amount of lunges at any living sentinent targets within the search range, prioritizing new targets"
              content="Additional Info"
              color="transparent"
            />
          </Table.Cell>
        </Table.Row>
      </Table>
    </Section>
  );
};
