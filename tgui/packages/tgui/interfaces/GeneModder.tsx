import { useBackend } from '../backend';
import { classes } from '../../common/react';
import {
  Button,
  Section,
  Stack,
  Icon,
  Image,
  Collapsible,
  LabeledList,
} from '../components';
import { ComplexModal } from '../interfaces/common/ComplexModal';
import { Window } from '../layouts';
import { ReactNode } from 'react';

type GeneModderData = {
  has_seed: boolean;
  seed: Seed;
  has_disk: boolean;
  disk: Disk;
  core_genes: Gene[];
  reagent_genes: Gene[];
  has_reagent: boolean;
  trait_genes: Gene[];
  has_trait: boolean;
};

type Gene = {
  name: string;
  id: string;
  is_type: boolean;
};

type Disk = {
  name: string;
  can_extract: boolean;
  can_insert: boolean;
  is_core: boolean;
  is_bulk_core: boolean;
};

type Seed = {
  name: string;
  image: string;
};

export const GeneModder = (props: unknown) => {
  const { data } = useBackend<GeneModderData>();
  const { has_seed } = data;

  return (
    <Window width={500} height={650}>
      <Window.Content>
        <Stack fill vertical>
          <Storage />
          <ComplexModal maxWidth="75%" maxHeight="75%" />
          {!has_seed ? <MissingSeed /> : <Genes />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Genes = (props: unknown) => {
  const { act, data } = useBackend<GeneModderData>();
  const { disk } = data;

  return (
    <Section
      title="Genes"
      fill
      scrollable
      buttons={
        <Button
          disabled={!disk || !disk.can_insert || disk.is_core}
          icon="arrow-circle-down"
          onClick={() => act('insert')}
        >
          Insert Gene from Disk
        </Button>
      }
    >
      <CoreGenes />
      <ReagentGenes />
      <TraitGenes />
    </Section>
  );
};

const MissingSeed = (props: unknown) => {
  return (
    <Section fill height="85%">
      <Stack height="100%">
        <Stack.Item
          bold
          grow={1}
          textAlign="center"
          align="center"
          color="green"
        >
          <Icon name="leaf" size={5} mb="10px" />
          <br />
          The plant DNA manipulator is missing a seed.
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Storage = (props: unknown) => {
  const { act, data } = useBackend<GeneModderData>();
  const { has_seed, seed, has_disk, disk } = data;

  let show_seed: ReactNode;
  let show_disk: ReactNode;

  if (has_seed) {
    show_seed = (
      <Stack.Item mb="-6px" mt="-4px">
        <Image
          className={classes(['seeds32x32', seed.image])}
          style={{
            verticalAlign: 'middle',
            width: '32px',
            margin: '-1px',
            marginLeft: '-11px',
          }}
        />
        <Button onClick={() => act('eject_seed')}>{seed.name}</Button>
        <Button
          ml="3px"
          icon="pen"
          tooltip="Name Variant"
          onClick={() => act('variant_name')}
        />
      </Stack.Item>
    );
  } else {
    show_seed = (
      <Stack.Item>
        <Button ml={3.3} onClick={() => act('eject_seed')}>
          None
        </Button>
      </Stack.Item>
    );
  }

  if (has_disk) {
    show_disk = disk.name;
  } else {
    show_disk = 'None';
  }

  return (
    <Section title="Storage">
      <LabeledList>
        <LabeledList.Item label="Plant Sample">{show_seed}</LabeledList.Item>
        <LabeledList.Item label="Data Disk">
          <Stack.Item>
            <Button ml={3.3} onClick={() => act('eject_disk')}>
              {show_disk}
            </Button>
          </Stack.Item>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const CoreGenes = (props: unknown) => {
  const { act, data } = useBackend<GeneModderData>();
  const { disk, core_genes } = data;

  return (
    <Collapsible key="Core Genes" title="Core Genes" open>
      {core_genes.map((gene) => (
        <Stack key={gene.id} py="2px" className="candystripe">
          <Stack.Item width="100%" ml="2px">
            {gene.name}
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!disk?.can_extract}
              icon="save"
              onClick={() => act('extract', { id: gene.id })}
            >
              Extract
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!gene.is_type || !disk.can_insert}
              icon="arrow-circle-down"
              onClick={() => act('replace', { id: gene.id })}
            >
              Replace
            </Button>
          </Stack.Item>
        </Stack>
      ))}{' '}
      {
        <Stack>
          <Stack.Item>
            <Button
              disabled={!disk?.is_bulk_core}
              icon="arrow-circle-down"
              onClick={() => act('bulk_replace_core')}
            >
              Replace All
            </Button>
          </Stack.Item>
        </Stack>
      }
    </Collapsible>
  );
};

const ReagentGenes = (props: unknown) => {
  const { data } = useBackend<GeneModderData>();
  const { reagent_genes, has_reagent } = data;

  return (
    <OtherGenes
      title="Reagent Genes"
      gene_set={reagent_genes}
      do_we_show={has_reagent}
    />
  );
};

const TraitGenes = (props: unknown) => {
  const { data } = useBackend<GeneModderData>();
  const { trait_genes, has_trait } = data;

  return (
    <OtherGenes
      title="Trait Genes"
      gene_set={trait_genes}
      do_we_show={has_trait}
    />
  );
};

type OtherGenesProps = {
  title: string;
  gene_set: Gene[];
  do_we_show: boolean;
};

const OtherGenes = (props: OtherGenesProps) => {
  const { title, gene_set, do_we_show } = props;
  const { act, data } = useBackend<GeneModderData>();
  const { disk } = data;

  return (
    <Collapsible key={title} title={title} open>
      {do_we_show ? (
        gene_set.map((gene) => (
          <Stack key={gene.id} py="2px" className="candystripe">
            <Stack.Item width="100%" ml="2px">
              {gene.name}
            </Stack.Item>
            <Stack.Item>
              <Button
                disabled={!disk?.can_extract}
                icon="save"
                onClick={() => act('extract', { id: gene.id })}
              >
                Extract
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                onClick={() => act('remove', { id: gene.id })}
              >
                Remove
              </Button>
            </Stack.Item>
          </Stack>
        ))
      ) : (
        <Stack.Item>No Genes Detected</Stack.Item>
      )}
    </Collapsible>
  );
};
