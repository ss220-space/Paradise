import { Fragment } from 'inferno';
import { useBackend, useLocalState } from '../backend';
import { Button, LabeledList, Box, Section, Tabs, Input } from '../components';
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

export const ERTManager = (props, context) => {
  const { act, data } = useBackend(context);

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);

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

export const ERTOverview = (props, context) => {
  const { act, data } = useBackend(context);
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
            content={ert_request_answered ? 'Отвечено' : 'Неотвечено'}
            onClick={() => act('toggle_ert_request_answered')}
            tooltip={
              'Установка этого флага отключит следующее уведомление-напоминание о том, что запрос ОБР проигнорирован.'
            }
            selected={null}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const SendERT = (props, context) => {
  const { act, data } = useBackend(context);
  let slotOptions = [0, 1, 2, 3, 4, 5];

  const [silentERT, setSilentERT] = useLocalState(context, 'silentERT', false);

  return (
    <Section
      title="Отправить ОБР"
      buttons={
        <Fragment>
          <Button
            content="Эмбер"
            color={data.ert_type === 'Amber' ? 'orange' : ''}
            onClick={() => act('ert_type', { ert_type: 'Amber' })}
          />
          <Button
            content="Ред"
            color={data.ert_type === 'Red' ? 'red' : ''}
            onClick={() => act('ert_type', { ert_type: 'Red' })}
          />
          <Button
            content="Гамма"
            color={data.ert_type === 'Gamma' ? 'purple' : ''}
            onClick={() => act('ert_type', { ert_type: 'Gamma' })}
          />
        </Fragment>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Командир">
          <Button
            icon={data.com ? 'toggle-on' : 'toggle-off'}
            selected={data.com}
            content={data.com ? 'Да' : 'Нет'}
            onClick={() => act('toggle_com')}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Боец">
          {slotOptions.map((a, i) => (
            <Button
              key={'sec' + a}
              selected={data.sec === a}
              content={a}
              onClick={() =>
                act('set_sec', {
                  set_sec: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Медик">
          {slotOptions.map((a, i) => (
            <Button
              key={'med' + a}
              selected={data.med === a}
              content={a}
              onClick={() =>
                act('set_med', {
                  set_med: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Инженер">
          {slotOptions.map((a, i) => (
            <Button
              key={'eng' + a}
              selected={data.eng === a}
              content={a}
              onClick={() =>
                act('set_eng', {
                  set_eng: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Паранормал">
          {slotOptions.map((a, i) => (
            <Button
              key={'par' + a}
              selected={data.par === a}
              content={a}
              onClick={() =>
                act('set_par', {
                  set_par: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Уборщик">
          {slotOptions.map((a, i) => (
            <Button
              key={'jan' + a}
              selected={data.jan === a}
              content={a}
              onClick={() =>
                act('set_jan', {
                  set_jan: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Борг">
          {slotOptions.map((a, i) => (
            <Button
              key={'cyb' + a}
              selected={data.cyb === a}
              content={a}
              onClick={() =>
                act('set_cyb', {
                  set_cyb: a,
                })
              }
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Скрытный ОБР">
          <Button
            icon={silentERT ? 'microphone-slash' : 'microphone'}
            content={silentERT ? 'Да' : 'Нет'}
            selected={silentERT}
            onClick={() => setSilentERT(!silentERT)}
            tooltip={
              silentERT
                ? 'Об этом ОБР не будет объявлено на станции.'
                : 'Об этом ОБР будет объявлено на станции при отправке.'
            }
          />
        </LabeledList.Item>
        <LabeledList.Item label="Текущие слоты">
          <Box color={data.total > data.spawnpoints ? 'red' : 'green'}>
            {data.total} выбрано, против {data.spawnpoints} точек спавна
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Отправить">
          <Button
            icon="ambulance"
            content="Отправить ОБР"
            onClick={() => act('dispatch_ert', { silent: silentERT })}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ReadERTRequests = (props, context) => {
  const { act, data } = useBackend(context);

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
                content={request.sender_real_name}
                onClick={() =>
                  act('view_player_panel', { uid: request.sender_uid })
                }
                tooltip="Посмотреть Player panel"
              />
            }
          >
            {request.message}
          </Section>
        ))
      ) : (
        <Box fluid italic textAlign="center">
          Нет запросов ОБР
        </Box>
      )}
    </Section>
  );
};

const DenyERT = (props, context) => {
  const { act, data } = useBackend(context);

  const [text, setText] = useLocalState(context, 'text', '');

  return (
    <Section>
      <Input
        placeholder="Введите здесь причину отклонения ОБР.\nМногострочный ввод доступен."
        rows={10}
        fluid
        multiline={1}
        value={text}
        onChange={(e, value) => setText(value)}
      />
      <Button.Confirm
        content="Отклонить запрос ОБР"
        fluid
        icon="times"
        center
        mt="5px"
        textAlign="center"
        onClick={() => act('deny_ert', { reason: text })}
      />
    </Section>
  );
};
