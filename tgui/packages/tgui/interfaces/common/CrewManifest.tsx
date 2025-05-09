import { useBackend } from '../../backend';
import { Box, Section, Table } from '../../components';
import { decodeHtmlEntities } from 'common/string';
import { COLORS } from '../../constants';

const deptCols = COLORS.department;

const HeadRoles = [
  'Captain',
  'Head of Security',
  'Chief Engineer',
  'Chief Medical Officer',
  'Research Director',
  'Head of Personnel',
  'Quartermaster',
];

// Head colour check. Abbreviated to save on 80 char
const HCC = (role: string) => {
  // Return green if they are the head
  if (HeadRoles.indexOf(role) !== -1) {
    return 'green';
  }

  // Return orange if its a regular person
  return 'orange';
};

// Head bold check. Abbreviated to save on 80 char
const HBC = (role: string) => {
  // Return true if they are a head
  if (HeadRoles.indexOf(role) !== -1) {
    return true;
  }
};

type Person = {
  name: string;
  rank: string;
  real_rank: string;
  active: string;
};

const ManifestTable = (group: Person[]) => {
  return (
    group.length > 0 && (
      <Table>
        <Table.Row header color="white">
          <Table.Cell width="50%">Name</Table.Cell>
          <Table.Cell width="35%">Rank</Table.Cell>
          <Table.Cell width="15%">Active</Table.Cell>
        </Table.Row>

        {group.map((person: Person) => (
          <Table.Row
            color={HCC(person.real_rank)}
            key={person.name + person.rank}
            bold={HBC(person.real_rank)}
          >
            <Table.Cell>{decodeHtmlEntities(person.name)}</Table.Cell>
            <Table.Cell>{decodeHtmlEntities(person.rank)}</Table.Cell>
            <Table.Cell>{person.active}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    )
  );
};

type Manifest = {
  heads: Person[];
  pro: Person[];
  sec: Person[];
  eng: Person[];
  med: Person[];
  sci: Person[];
  ser: Person[];
  sup: Person[];
  misc: Person[];
};

export type ManifestData = {
  manifest?: Manifest;
};

type ManifestProps = {
  manifest?: Manifest;
};

export const CrewManifest = (props: ManifestProps) => {
  // HOW TO USE THIS THING
  /*
  	GLOB.data_core.get_manifest_json()
	  data["manifest"] = GLOB.PDA_Manifest
  */
  // And thats it

  const manifest = props?.manifest
    ? props.manifest
    : useBackend<ManifestData>().data.manifest;

  const { heads, pro, sec, eng, med, sci, ser, sup, misc } = manifest;

  return (
    <Box>
      <Section
        title={
          <Box backgroundColor={deptCols.command} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Command
            </Box>
          </Box>
        }
      >
        {ManifestTable(heads)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.procedure} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Procedure
            </Box>
          </Box>
        }
      >
        {ManifestTable(pro)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.security} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Security
            </Box>
          </Box>
        }
      >
        {ManifestTable(sec)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.engineering} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Engineering
            </Box>
          </Box>
        }
      >
        {ManifestTable(eng)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.medical} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Medical
            </Box>
          </Box>
        }
      >
        {ManifestTable(med)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.science} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Science
            </Box>
          </Box>
        }
      >
        {ManifestTable(sci)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.service} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Service
            </Box>
          </Box>
        }
      >
        {ManifestTable(ser)}
      </Section>

      <Section
        title={
          <Box backgroundColor={deptCols.supply} m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Supply
            </Box>
          </Box>
        }
      >
        {ManifestTable(sup)}
      </Section>

      <Section
        title={
          <Box m={-1} pt={1} pb={1}>
            <Box ml={1} textAlign="center" fontSize={1.4}>
              Misc
            </Box>
          </Box>
        }
      >
        {ManifestTable(misc)}
      </Section>
    </Box>
  );
};
