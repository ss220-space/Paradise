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
        placeholder="Поиск записей..."
        onInput={(e, value) => setSearchText(value)}
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
        <Section title="Медицинская информация">
          {medical ? (
            <LabeledList>
              <LabeledList.Item label="Группа крови">
                {medical.blood_type}
              </LabeledList.Item>
              <LabeledList.Item label="Незначительные отклонения">
                {medical.mi_dis}
              </LabeledList.Item>
              <LabeledList.Item label="Детали">
                {medical.mi_dis_d}
              </LabeledList.Item>
              <LabeledList.Item label="Инвалидности">
                {medical.ma_dis}
              </LabeledList.Item>
              <LabeledList.Item label="Детали">
                {medical.ma_dis_d}
              </LabeledList.Item>
              <LabeledList.Item label="Аллергии">
                {medical.alg}
              </LabeledList.Item>
              <LabeledList.Item label="Делтали">
                {medical.alg_d}
              </LabeledList.Item>
              <LabeledList.Item label="Текущие заболевания">
                {medical.cdi}
              </LabeledList.Item>
              <LabeledList.Item label="Детали">
                {medical.cdi_d}
              </LabeledList.Item>
              <LabeledList.Item label="Важные примечания">
                {medical.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Медицинская запись отсутствует!'}
            </Box>
          )}
        </Section>
      );
      break;
    case 'SEC':
      secondaryRecord = (
        <Section title="Данные Службы Безопасности">
          {security ? (
            <LabeledList>
              <LabeledList.Item label="Статус">
                {security.criminal}
              </LabeledList.Item>
              <LabeledList.Item label="Незначительные преступления">
                {security.mi_crim}
              </LabeledList.Item>
              <LabeledList.Item label="Детали">
                {security.mi_crim_d}
              </LabeledList.Item>
              <LabeledList.Item label="Тяжкие преступления">
                {security.ma_crim}
              </LabeledList.Item>
              <LabeledList.Item label="Детали">
                {security.ma_crim_d}
              </LabeledList.Item>
              <LabeledList.Item label="Важные Примечания:">
                {security.notes}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="red" bold>
              {'Запись службы безопасности отсутствует!'}
            </Box>
          )}
        </Section>
      );
      break;
  }

  return (
    <Box>
      <Section title="Общая Информация">
        {general ? (
          <LabeledList>
            <LabeledList.Item label="Имя">{general.name}</LabeledList.Item>
            <LabeledList.Item label="Пол">{general.sex}</LabeledList.Item>
            <LabeledList.Item label="Раса">{general.species}</LabeledList.Item>
            <LabeledList.Item label="Возраст">{general.age}</LabeledList.Item>
            <LabeledList.Item label="Должность">
              {general.rank}
            </LabeledList.Item>
            <LabeledList.Item label="Хэш отпечатков пальцев">
              {general.fingerprint}
            </LabeledList.Item>
            <LabeledList.Item label="Физическое состояние">
              {general.p_stat}
            </LabeledList.Item>
            <LabeledList.Item label="Психологическое состояние">
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
