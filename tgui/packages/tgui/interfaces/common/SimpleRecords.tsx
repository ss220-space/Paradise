import { useBackend } from '../../backend';
import { ReactNode, useState } from 'react';
import { createSearch } from 'common/string';
import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { Box, Input, Button, Section, LabeledList } from '../../components';

export type RecordsProps = {
  records: Records;
  recordType: string;
  recordsList: Record[];
};

type Records = {
  general: GeneralRecord;
  medical: MedicalRecord;
  security: SecurityRecord;
};

type Record = {
  Name: string;
  uid: string;
};

export type GeneralRecord = {
  name: string;
  sex: string;
  species: string;
  age: string;
  rank: string;
  fingerprint: string;
  p_stat: string;
  m_stat: string;
};

export type SecurityRecord = {
  criminal: string;
  mi_crim: string;
  mi_crim_d: string;
  ma_crim: string;
  ma_crim_d: string;
  notes: string;
};

export type MedicalRecord = {
  blood_type: string;
  mi_dis: string;
  mi_dis_d: string;
  ma_dis: string;
  ma_dis_d: string;
  alg: string;
  alg_d: string;
  cdi: string;
  cdi_d: string;
  notes: string;
};

type SimpleRecordsProps = {
  records: Records;
  recordType: string;
  recordsList: Record[];
};

export const SimpleRecords = (props: SimpleRecordsProps) => {
  const { records } = props;

  return (
    <Box>
      {!records ? (
        <SelectionView {...props} />
      ) : (
        <RecordView recordType={props.recordType} {...props} />
      )}
    </Box>
  );
};

type SelectionViewProps = {
  recordsList: Record[];
};

const SelectionView = (props: SelectionViewProps) => {
  const { act } = useBackend();
  const { recordsList } = props;

  const [searchText, setSearchText] = useState('');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch<Record>(
      searchText,
      (member) => member.Name
    );
    return flow([
      (recordsList: Record[]) =>
        // Null member filter
        filter(recordsList, (member) => !!member?.Name),
      // Optional search term
      (recordsList: Record[]) =>
        searchText ? filter(recordsList, MemberSearch) : recordsList,
      // Slightly expensive, but way better than sorting in BYOND
      (recordsList: Record[]) => sortBy(recordsList, (member) => member.Name),
    ])(recordsList);
  };

  const formattedRecords = SelectMembers(recordsList, searchText);

  return (
    <Box>
      <Input
        fluid
        mb={1}
        placeholder="Search records..."
        expensive
        onChange={setSearchText}
      />
      {formattedRecords.map((r) => (
        <Box key={r}>
          <Button
            mb={0.5}
            icon="user"
            onClick={() => act('Records', { target: r.uid })}
          >
            {r.Name}
          </Button>
        </Box>
      ))}
    </Box>
  );
};

type RecordViewProps = {
  recordType: string;
  records: Records;
};

const RecordView = (props: RecordViewProps) => {
  const { records } = props;

  const { general, medical, security } = records;

  let secondaryRecord: ReactNode;
  switch (props.recordType) {
    case 'MED':
      secondaryRecord = (
        <Section title="Medical Data">
          {medical ? (
            <LabeledList>
              <LabeledList.Item label="Blood Type">
                {medical.blood_type}
              </LabeledList.Item>
              <LabeledList.Item label="Minor Disabilities">
                {medical.mi_dis}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {medical.mi_dis_d}
              </LabeledList.Item>
              <LabeledList.Item label="Major Disabilities">
                {medical.ma_dis}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {medical.ma_dis_d}
              </LabeledList.Item>
              <LabeledList.Item label="Allergies">
                {medical.alg}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {medical.alg_d}
              </LabeledList.Item>
              <LabeledList.Item label="Current Diseases">
                {medical.cdi}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {medical.cdi_d}
              </LabeledList.Item>
              <LabeledList.Item label="Important Notes">
                {medical.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Medical record lost!'}
            </Box>
          )}
        </Section>
      );
      break;
    case 'SEC':
      secondaryRecord = (
        <Section title="Security Data">
          {security ? (
            <LabeledList>
              <LabeledList.Item label="Criminal Status">
                {security.criminal}
              </LabeledList.Item>
              <LabeledList.Item label="Minor Crimes">
                {security.mi_crim}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {security.mi_crim_d}
              </LabeledList.Item>
              <LabeledList.Item label="Major Crimes">
                {security.ma_crim}
              </LabeledList.Item>
              <LabeledList.Item label="Details">
                {security.ma_crim_d}
              </LabeledList.Item>
              <LabeledList.Item label="Important Notes">
                {security.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Security record lost!'}
            </Box>
          )}
        </Section>
      );
      break;
  }

  return (
    <Box>
      <Section title="General Data">
        {general ? (
          <LabeledList>
            <LabeledList.Item label="Name">{general.name}</LabeledList.Item>
            <LabeledList.Item label="Sex">{general.sex}</LabeledList.Item>
            <LabeledList.Item label="Species">
              {general.species}
            </LabeledList.Item>
            <LabeledList.Item label="Age">{general.age}</LabeledList.Item>
            <LabeledList.Item label="Rank">{general.rank}</LabeledList.Item>
            <LabeledList.Item label="Fingerprint">
              {general.fingerprint}
            </LabeledList.Item>
            <LabeledList.Item label="Physical Status">
              {general.p_stat}
            </LabeledList.Item>
            <LabeledList.Item label="Mental Status">
              {general.m_stat}
            </LabeledList.Item>
          </LabeledList>
        ) : (
          <Box color="red" bold>
            General record lost!
          </Box>
        )}
      </Section>
      {secondaryRecord}
    </Box>
  );
};
