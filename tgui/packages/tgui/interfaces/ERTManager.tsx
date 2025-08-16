import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Tabs,
  TextArea,
} from '../components';
import { Window } from '../layouts';
import { decodeHtmlEntities } from 'common/string';

const TabList = {
  0: () => <SendERT />,
  1: () => <ReadERTRequests />,
  2: () => <DenyERT />,
  default: () =>
    'ЧТО-ТО ПОШЛО СОВСЕМ НЕ ТАК, НАПИШИТЕ В АХЕЛП, СТОП, ВЫ АДМИН, ОХ БЛЯ! сообщите кодерам или типо того. (Send Gimmick Team может быть временным решением)',
};

const PickTab = (index) => {
  return TabList[index];
};

export const ERTManager = (props: unknown) => {
  const [tabIndex, setTabIndex] = useState(0);

  return (
    <Window title="Менеджер ОБР" width={400} height={540}>
      <Window.Content>
        <ERTOverview />
        <Tabs>
          <Tabs.Tab
            key="SendERT"
            selected={tabIndex === 0}
            onClick={() => {
              setTabIndex(0);
            }}
            icon="ambulance"
          >
            Отправить ОБР
          </Tabs.Tab>
          <Tabs.Tab
            key="ReadERTRequests"
            selected={tabIndex === 1}
            onClick={() => {
              setTabIndex(1);
            }}
            icon="book"
          >
            Запросы ОБР
          </Tabs.Tab>
          <Tabs.Tab
            key="DenyERT"
            selected={tabIndex === 2}
            onClick={() => {
              setTabIndex(2);
            }}
            icon="times"
          >
            Отклонить ОБР
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)()}
      </Window.Content>
    </Window>
  );
};

type ERTData = {
  security_level_color: string;
  str_security_level: string;
  ert_request_answered: boolean;
  ert_request_messages: ErtRequest[];
  ert_type: string;
  com: boolean;
  jan: number;
  med: number;
  sec: number;
  eng: number;
  par: number;
  cyb: number;
  total: number;
  spawnpoints: number;
};

type ErtRequest = {
  time: string;
  sender_uid: string;
  sender_real_name: string;
  message: string;
};

export const ERTOverview = (props: unknown) => {
  const { act, data } = useBackend<ERTData>();
  const { security_level_color, str_security_level, ert_request_answered } =
    data;

  return (
    <Section title="Обзор">
      <LabeledList>
        <LabeledList.Item
          label="Текущий уровень угрозы"
          color={security_level_color}
        >
          {str_security_level}
        </LabeledList.Item>
        <LabeledList.Item label="Запрос ОБР">
          <Button.Checkbox
            checked={ert_request_answered}
            textColor={ert_request_answered ? null : 'bad'}
            onClick={() => act('toggle_ert_request_answered')}
            tooltip={
              'Установка этого флага отключит следующее уведомление-напоминание о том, что запрос ОБР проигнорирован.'
            }
            selected={null}
          >
            {ert_request_answered ? 'Отвечено' : 'Неотвечено'}
          </Button.Checkbox>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const SendERT = (props: unknown) => {
  const { act, data } = useBackend<ERTData>();
  let slotOptions = [0, 1, 2, 3, 4, 5];

  const [silentERT, setSilentERT] = useState(false);

  return (
    <Section
      title="Отправить ОБР"
      buttons={
        <>
          <Button
            color={data.ert_type === 'Amber' ? 'orange' : ''}
            onClick={() => act('ert_type', { ert_type: 'Amber' })}
          >
            Эмбер
          </Button>
          <Button
            color={data.ert_type === 'Red' ? 'red' : ''}
            onClick={() => act('ert_type', { ert_type: 'Red' })}
          >
            Ред
          </Button>
          <Button
            color={data.ert_type === 'Gamma' ? 'purple' : ''}
            onClick={() => act('ert_type', { ert_type: 'Gamma' })}
          >
            Гамма
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Командир">
          <Button
            icon={data.com ? 'toggle-on' : 'toggle-off'}
            selected={data.com}
            onClick={() => act('toggle_com')}
          >
            {data.com ? 'Да' : 'Нет'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Боец">
          {slotOptions.map((a, i) => (
            <Button
              key={'sec' + a}
              selected={data.sec === a}
              onClick={() =>
                act('set_sec', {
                  set_sec: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Медик">
          {slotOptions.map((a, i) => (
            <Button
              key={'med' + a}
              selected={data.med === a}
              onClick={() =>
                act('set_med', {
                  set_med: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Инженер">
          {slotOptions.map((a, i) => (
            <Button
              key={'eng' + a}
              selected={data.eng === a}
              onClick={() =>
                act('set_eng', {
                  set_eng: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Паранормал">
          {slotOptions.map((a, i) => (
            <Button
              key={'par' + a}
              selected={data.par === a}
              onClick={() =>
                act('set_par', {
                  set_par: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Уборщик">
          {slotOptions.map((a, i) => (
            <Button
              key={'jan' + a}
              selected={data.jan === a}
              onClick={() =>
                act('set_jan', {
                  set_jan: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Борг">
          {slotOptions.map((a, i) => (
            <Button
              key={'cyb' + a}
              selected={data.cyb === a}
              onClick={() =>
                act('set_cyb', {
                  set_cyb: a,
                })
              }
            >
              {a}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Скрытный ОБР">
          <Button
            icon={silentERT ? 'microphone-slash' : 'microphone'}
            selected={silentERT}
            onClick={() => setSilentERT(!silentERT)}
            tooltip={
              silentERT
                ? 'Об этом ОБР не будет объявлено на станции.'
                : 'Об этом ОБР будет объявлено на станции при отправке.'
            }
          >
            {silentERT ? 'Да' : 'Нет'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Текущие слоты">
          <Box color={data.total > data.spawnpoints ? 'red' : 'green'}>
            {data.total} выбрано, против {data.spawnpoints} точек спавна
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Отправить">
          <Button
            icon="ambulance"
            onClick={() => act('dispatch_ert', { silent: silentERT })}
          >
            Отправить ОБР
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ReadERTRequests = (props: unknown) => {
  const { act, data } = useBackend<ERTData>();

  const { ert_request_messages } = data;

  return (
    <Section>
      {ert_request_messages && ert_request_messages.length ? (
        ert_request_messages.map((request) => (
          <Section
            key={decodeHtmlEntities(request.time)}
            title={request.time}
            buttons={
              <Button
                onClick={() =>
                  act('view_player_panel', { uid: request.sender_uid })
                }
                tooltip="Посмотреть Player panel"
              >
                {request.sender_real_name}
              </Button>
            }
          >
            {request.message}
          </Section>
        ))
      ) : (
        <Box italic textAlign="center">
          Нет запросов ОБР
        </Box>
      )}
    </Section>
  );
};

const DenyERT = (props: unknown) => {
  const { act } = useBackend();

  const [text, setText] = useState('');

  return (
    <Section fill>
      <TextArea
        placeholder="Введите здесь причину отклонения ОБР. Многострочный ввод доступен."
        fluid
        height={'50%'}
        value={text}
        onChange={setText}
      />
      <Button.Confirm
        fluid
        icon="times"
        align="center"
        mt="5px"
        textAlign="center"
        onClick={() => act('deny_ert', { reason: text })}
      >
        Отклонить запрос ОБР
      </Button.Confirm>
    </Section>
  );
};
