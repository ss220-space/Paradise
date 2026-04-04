import { useBackend } from '../../backend';
import { Box, Icon, Section, Table, Tooltip } from '../../components';
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
  'Magistrate',
];

// Head colour check. Abbreviated to save on 80 char
const HCC = (role: string) => {
  // Return yellow if they are the head
  if (HeadRoles.indexOf(role) !== -1) {
    return 'green';
  }

  // Return white if its a regular person
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

const getStatusIconClass = (status: string) => {
  const normalized = status
    .toLowerCase()
    .replace(/\*/g, '')
    .replace(/\s/g, '-')
    .replace(/:.*?$/, '');
  return `manifest-indicator-${normalized}`;
};

const ManifestTable = (group: Person[]) => {
  return (
    group.length > 0 && (
      <Table p="0">
        {group.map((person: Person, index) => (
          <Table.Row
            color={HCC(person.real_rank)}
            key={person.name + person.rank}
            bold={HBC(person.real_rank)}
            className={index % 2 === 0 ? 'row-even' : 'row-odd'}
          >
            <Table.Cell
              width="50%"
              textAlign="left"
              pt="5px"
              pb="5px"
              pl="10px"
            >
              {decodeHtmlEntities(person.name)}
            </Table.Cell>
            <Table.Cell width="45%" textAlign="right" pr="2%" pt="5px" pb="5px">
              {decodeHtmlEntities(person.rank)}
            </Table.Cell>
            <Table.Cell
              width="5%"
              textAlign="right"
              pr="5px"
              pt="5px"
              pb="5px"
              pl="10px"
            >
              <Tooltip content={person.active}>
                <Icon
                  name="circle"
                  className={getStatusIconClass(person.active)}
                />
              </Tooltip>
            </Table.Cell>
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

type DepartmentSectionProps = {
  title: string;
  color: string;
  deptClass: string;
  children: React.ReactNode;
};

const DepartmentSection = ({
  title,
  color,
  deptClass,
  children,
}: DepartmentSectionProps) => {
  return (
    <Section
      className={`CrewManifest__dept CrewManifest__dept-${deptClass}`}
      title={
        <Box color={color} fontSize={1.4} fontWeight="bold">
          {title}
        </Box>
      }
      textAlign="center"
    >
      {children}
    </Section>
  );
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
    <Box className="CrewManifest">
      <DepartmentSection
        title="Командование"
        color={deptCols.command}
        deptClass="command"
      >
        {ManifestTable(heads)}
      </DepartmentSection>

      <DepartmentSection
        title="Юриспруденция"
        color={deptCols.procedure}
        deptClass="procedure"
      >
        {ManifestTable(pro)}
      </DepartmentSection>

      <DepartmentSection
        title="Безопасность"
        color={deptCols.security}
        deptClass="security"
      >
        {ManifestTable(sec)}
      </DepartmentSection>

      <DepartmentSection
        title="Инженерия"
        color={deptCols.engineering}
        deptClass="engineering"
      >
        {ManifestTable(eng)}
      </DepartmentSection>

      <DepartmentSection
        title="Медицина"
        color={deptCols.medical}
        deptClass="medical"
      >
        {ManifestTable(med)}
      </DepartmentSection>

      <DepartmentSection
        title="Наука"
        color={deptCols.science}
        deptClass="science"
      >
        {ManifestTable(sci)}
      </DepartmentSection>

      <DepartmentSection
        title="Обслуживание"
        color={deptCols.service}
        deptClass="service"
      >
        {ManifestTable(ser)}
      </DepartmentSection>

      <DepartmentSection
        title="Снабжение"
        color={deptCols.supply}
        deptClass="supply"
      >
        {ManifestTable(sup)}
      </DepartmentSection>

      <DepartmentSection title="Без отдела" color="white" deptClass="misc">
        {ManifestTable(misc)}
      </DepartmentSection>
    </Box>
  );
};
