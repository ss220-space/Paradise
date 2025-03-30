import { useBackend, useLocalState } from '../backend';
import { Box, Section, Button, LabeledList, Table } from '../components';
import { Window } from '../layouts';
export const Healthanalyzer = (props, context) => {
  const { act, data } = useBackend(context);

  const { scan_data } = data;

  let damageLang = new Map([
    ['upper body', 'Грудь'],
    ['lower body', 'Живот'],
    ['head', 'Голова'],
    ['left arm', 'Левая рука'],
    ['right arm', 'Правая рука'],
    ['left leg', 'Левая нога'],
    ['right leg', 'Правая нога'],
    ['left foot', 'Левая ступня'],
    ['right foot', 'Правая ступня'],
    ['left hand', 'Левая кисть'],
    ['right hand', 'Правая кисть'],
    ['monkey tail', 'Хвост обезьяны'],
    ['wolpin tail', 'Хвост вульпина'],
    ['unathi tail', 'Хвост унатха'],
    ['tajaran tail', 'Хвост таярана'],
    ['vulpkanin tail', 'Хвост вульпканина'],
    ['vox tail', 'Хвост вокса'],
    ['wryn tail', 'Хвост врина'],
    ['luam wings', 'Крылья луам'],
  ]);

  let fractureLang = new Map([
    ['upper body', 'груди'],
    ['lower body', 'животе'],
    ['head', 'голове'],
    ['left arm', 'левой руке'],
    ['right arm', 'правой руке'],
    ['left leg', 'левой ногн'],
    ['right leg', 'правой ноге'],
    ['left foot', 'левой ступне'],
    ['right foot', 'правой ступне'],
    ['left hand', 'левой кисти'],
    ['right hand', 'правой кисти'],
    ['monkey tail', 'хвосте'],
    ['wolpin tail', 'хвосте'],
    ['unathi tail', 'хвосте'],
    ['tajaran tail', 'хвосте'],
    ['vulpkanin tail', 'хвосте'],
    ['vox tail', 'хвосте'],
    ['wryn tail', 'хвосте'],
    ['luam wings', 'крыльях'],
  ]);

  return (
    <Window
      width={500}
      height={450}
      theme={data.theme ? data.theme : ''}
      title={data.scan_title ? data.scan_title : 'Анализатор здоровья'}
      resizable={false}
    >
      <Window.Content scrollable>
        {(() => {
          if (!scan_data) {
            return (
              <Box textAlign="center" bold>
                Память анализатора здоровья успешно очищена
              </Box>
            );
          }
          if (scan_data.status === 'ERROR' || scan_data.status === 'FLOOR') {
            return (
              <Box>
                <Section title="Повреждения">
                  <LabeledList>
                    <LabeledList.Item label="Тип повреждений">
                      <Box>
                        <span style={{ color: '#0080ff' }}>Удушье</span> /{' '}
                        <span style={{ color: 'green' }}>Отравление</span> /{' '}
                        <span style={{ color: '#FF8000' }}>Терм.</span> /{' '}
                        <span style={{ color: 'red' }}>Мех.</span>
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Степень повреждений">
                      <Box>
                        <span style={{ color: '#0080ff' }}>?</span> -{' '}
                        <span style={{ color: 'green' }}>?</span> -{' '}
                        <span style={{ color: '#FF8000' }}>?</span> -{' '}
                        <span style={{ color: 'red' }}>?</span>
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
                <Section title="Общее состояние">
                  <LabeledList>
                    <LabeledList.Item label="Оценка здоровья">
                      <Box color="#c51e1e" bold>
                        ОШИБКА
                      </Box>
                    </LabeledList.Item>

                    <LabeledList.Item label="Температура тела">
                      --- °C --- °F
                    </LabeledList.Item>

                    <LabeledList.Item label="Уровень крови">
                      --- %, --- u, тип: ---, кровь расы: ---
                    </LabeledList.Item>

                    <LabeledList.Item label="Пульс">
                      --- уд/мин
                    </LabeledList.Item>

                    <LabeledList.Item label="Гены">
                      Генная структура не обнаружена
                    </LabeledList.Item>
                  </LabeledList>
                </Section>
              </Box>
            );
          } else {
            return (
              <Box>
                <TopButtons />

                <Section title="Повреждения">
                  <LabeledList>
                    <LabeledList.Item label="Тип повреждений">
                      <Box>
                        <span style={{ color: '#0080ff' }}>Удушье</span> /{' '}
                        <span style={{ color: 'green' }}>Отравление</span> /{' '}
                        <span style={{ color: '#FF8000' }}>Терм.</span> /{' '}
                        <span style={{ color: 'red' }}>Мех.</span>
                      </Box>
                    </LabeledList.Item>
                    <LabeledList.Item label="Степень повреждений">
                      <Box>
                        {scan_data.damageLevels.oxy > 0 ? (
                          <span
                            style={{ color: '#0080ff', 'font-weight': 'bold' }}
                          >
                            {scan_data.damageLevels.oxy}
                          </span>
                        ) : (
                          <span style={{ color: '#0080ff' }}>
                            {scan_data.damageLevels.oxy}
                          </span>
                        )}{' '}
                        -{' '}
                        {scan_data.damageLevels.tox > 0 ? (
                          <span
                            style={{ color: 'green', 'font-weight': 'bold' }}
                          >
                            {scan_data.damageLevels.tox}
                          </span>
                        ) : (
                          <span style={{ color: 'green' }}>
                            {scan_data.damageLevels.tox}
                          </span>
                        )}{' '}
                        -{' '}
                        {scan_data.damageLevels.burn > 0 ? (
                          <span
                            style={{ color: '#FF8000', 'font-weight': 'bold' }}
                          >
                            {scan_data.damageLevels.burn}
                          </span>
                        ) : (
                          <span style={{ color: '#FF8000' }}>
                            {scan_data.damageLevels.burn}
                          </span>
                        )}{' '}
                        -{' '}
                        {scan_data.damageLevels.brute > 0 ? (
                          <span style={{ color: 'red', 'font-weight': 'bold' }}>
                            {scan_data.damageLevels.brute}
                          </span>
                        ) : (
                          <span style={{ color: 'red' }}>
                            {scan_data.damageLevels.brute}
                          </span>
                        )}
                      </Box>
                    </LabeledList.Item>
                  </LabeledList>
                </Section>

                <Section title="Состояние">
                  <LabeledList>
                    <LabeledList.Item label="Статус">
                      {scan_data.status === 2 ? (
                        <Box color="red" bold>
                          Смерть {!!scan_data.DRN && <span bold>[НР]</span>}
                        </Box>
                      ) : scan_data.health > 0 ? (
                        <Box>{scan_data.health}% </Box>
                      ) : (
                        <Box color="red" bold>
                          {scan_data.health}%{' '}
                        </Box>
                      )}
                    </LabeledList.Item>

                    {scan_data.status === 2 && (
                      <LabeledList.Item label="Время смерти">
                        {scan_data.timeofdeath}
                      </LabeledList.Item>
                    )}

                    <LabeledList.Item label="Температура тела">
                      {scan_data.bodyTemperatureC} °C (
                      {scan_data.bodyTemperatureF} °F)
                    </LabeledList.Item>

                    {scan_data.bloodData && (
                      <LabeledList.Item label="Уровень крови">
                        {scan_data.bloodData.blood_volume <= 501 &&
                          scan_data.bloodData.blood_volume > 346 && (
                            <span
                              style={{ color: 'red', 'font-weight': 'bold' }}
                            >
                              НИЗКИЙ{' '}
                            </span>
                          )}
                        {scan_data.bloodData.blood_volume < 346 && (
                          <span style={{ color: 'red', 'font-weight': 'bold' }}>
                            КРИТИЧЕСКИЙ{' '}
                          </span>
                        )}
                        {scan_data.bloodData.blood_percent} %,{' '}
                        {scan_data.bloodData.blood_volume} u, тип:{' '}
                        {scan_data.bloodData.blood_type}, кровь расы:{' '}
                        {scan_data.bloodData.blood_species}.
                      </LabeledList.Item>
                    )}

                    <LabeledList.Item label="Пульс">
                      <span style={scan_data.pulse === 0 && { color: 'red' }}>
                        {scan_data.pulse} уд/мин
                      </span>
                    </LabeledList.Item>

                    <LabeledList.Item label="Гены">
                      {scan_data.genes < 40 ? (
                        <Box color="red" bold>
                          Критическая генная нестабильность.
                        </Box>
                      ) : scan_data.genes < 70 ? (
                        <Box color="red" bold>
                          Тяжёлая генная нестабильность.
                        </Box>
                      ) : scan_data.genes < 85 ? (
                        <Box color="red">
                          Незначительная генная нестабильность.
                        </Box>
                      ) : (
                        scan_data.genes > 40 && (
                          <Box>Генная структура стабильна.</Box>
                        )
                      )}
                    </LabeledList.Item>
                  </LabeledList>

                  <StatusInfo />
                </Section>

                {scan_data.status === 2 && (
                  <Section>
                    <Box>
                      <Box textAlign="center" bold color="red">
                        Субъект умер {scan_data.timetodefib} назад
                      </Box>
                      <Box textAlign="center" bold color="red">
                        {scan_data.timetodefibText}
                      </Box>
                    </Box>
                  </Section>
                )}

                {scan_data.heartCondition === 'CRIT' && (
                  <Section
                    title="Внимание: Критическое состояние!"
                    mt={2}
                    mb={2}
                    color="red"
                  >
                    <LabeledList>
                      <LabeledList.Item label="Название">
                        <Box bold>Остановка сердца</Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Тип">
                        <Box bold>Сердце пациента остановилось</Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Стадия">
                        <Box bold>1/1</Box>
                      </LabeledList.Item>
                      <LabeledList.Item label="Лечение">
                        <Box bold>Электрический шок</Box>
                      </LabeledList.Item>
                    </LabeledList>
                  </Section>
                )}

                {!!data['localize'] &&
                (!!scan_data.damageLocalization ||
                  !!scan_data.fractureList[0] ||
                  scan_data.infectedList[0] ||
                  !!scan_data.extraFacture) ? (
                  <Section title="Локализация повреждений">
                    {!!scan_data.damageLocalization && (
                      <Box>
                        <LabeledList>
                          {scan_data.damageLocalization.map((local, index) => (
                            <LabeledList.Item
                              key={index}
                              label={damageLang.get(local.name)}
                            >
                              <Box>
                                <span style={{ color: '#FF8000' }}>
                                  {local.burn}
                                </span>{' '}
                                -{' '}
                                <span style={{ color: 'red' }}>
                                  {local.brute}
                                </span>
                              </Box>
                            </LabeledList.Item>
                          ))}
                        </LabeledList>
                      </Box>
                    )}
                    {!!scan_data.fractureList[0] && (
                      <Box>
                        {scan_data.fractureList.map((local, index) => (
                          <Box key={index} color="#c51e1e" mt={1}>
                            Обнаружен перелом в {local}.
                          </Box>
                        ))}
                      </Box>
                    )}
                    {!!scan_data.infectedList[0] && (
                      <Box>
                        {scan_data.infectedList.map((local, index) => (
                          <Box key={index} color="#c51e1e" mt={1}>
                            Обнаружено заражение в {local}.
                          </Box>
                        ))}
                      </Box>
                    )}
                    {!!scan_data.extraFacture && (
                      <Box color="#c51e1e" mt={1}>
                        Обнаружены переломы. Локализация невозможна.
                      </Box>
                    )}
                    {!!scan_data.extraBleeding && (
                      <Box color="#c51e1e" mt={1}>
                        Обнаружено внутреннее кровотечение. Локализация
                        невозможна.
                      </Box>
                    )}
                  </Section>
                ) : (
                  !data['localize'] &&
                  (!!scan_data.fractureList[0] ||
                    scan_data.infectedList[0] ||
                    !!scan_data.extraFacture ||
                    !!scan_data.extraBleeding) && (
                    <Section title="Дополнительная информация">
                      {!!scan_data.fractureList[0] && (
                        <Box>
                          {scan_data.fractureList.map((local, index) => (
                            <Box key={index} color="#c51e1e" mt={1}>
                              Обнаружен перелом в {local}.
                            </Box>
                          ))}
                        </Box>
                      )}
                      {!!scan_data.infectedList[0] && (
                        <Box>
                          {scan_data.infectedList.map((local, index) => (
                            <Box key={index} color="#c51e1e" mt={1}>
                              Обнаружено заражение в {local}.
                            </Box>
                          ))}
                        </Box>
                      )}
                      {!!scan_data.extraFacture && (
                        <Box color="#c51e1e" mt={1}>
                          Обнаружены переломы. Требуется подробное сканирование.
                        </Box>
                      )}
                      {!!scan_data.extraBleeding && (
                        <Box color="#c51e1e" mt={1}>
                          Обнаружено внутреннее кровотечение. Локализация
                          невозможна.
                        </Box>
                      )}
                    </Section>
                  )
                )}

                {!!scan_data.reagentList && <ReagentList />}

                {!!scan_data.diseases[0] && <DiseasesList />}

                {!!scan_data.addictionList && <AddictionList />}

                {!!scan_data.implantDetect && <ImplantList />}

                <Section title="Страховка">
                  <LabeledList>
                    <LabeledList.Item label="Тип страховки ">
                      {scan_data.insuranceType}
                    </LabeledList.Item>
                    <LabeledList.Item label="Требуемое количество очков страховки">
                      {scan_data.reqInsurance}
                    </LabeledList.Item>
                    {!!scan_data.insurance && (
                      <LabeledList.Item label="Текущее количество очков страховки">
                        {scan_data.insurance}
                      </LabeledList.Item>
                    )}
                  </LabeledList>
                </Section>
              </Box>
            );
          }
        })()}
      </Window.Content>
    </Window>
  );
};

const TopButtons = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Section textAlign="center">
      <Box nowrap>
        <Button icon="trash" content="Очистить" onClick={() => act('clear')} />
        <Button
          icon="map-marker-alt"
          content="Локализация"
          onClick={() => act('localize')}
          color={data.localize ? '' : 'red'}
        />
        {!!data.advanced && (
          <Button
            icon="print"
            content="Печать отчёта"
            onClick={() => act('print')}
          />
        )}
        {!!data.advanced && (
          <Button
            icon="file-invoice-dollar"
            content="Списать страховку"
            onClick={() => act('insurance')}
          />
        )}
      </Box>
    </Section>
  );
};

const StatusInfo = (props, context) => {
  const { data } = useBackend(context);

  const {
    heartCondition,
    brainDamage,
    bleed,
    staminaStatus,
    cloneStatus,
    brainWorms,
  } = data.scan_data;

  return (
    <Box>
      {heartCondition === 'LESS' ? (
        <Box color="#d82020" mt={1} bold>
          Сердце не обнаружено.
        </Box>
      ) : (
        heartCondition === 'NECROSIS' && (
          <Box color="#d82020" mt={1} bold>
            Обнаружен некроз сердца.
          </Box>
        )
      )}

      {brainDamage > 100 ? (
        <Box color="#c51e1e" mt={1} bold>
          Мозг мёртв
        </Box>
      ) : brainDamage > 60 ? (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружено серьёзное повреждение мозга.
        </Box>
      ) : brainDamage > 10 ? (
        <Box color="#c51e1e" mt={1}>
          Обнаружено значительное повреждение мозга.
        </Box>
      ) : (
        brainDamage === 'LESS' && (
          <Box color="#c51e1e" mt={1} bold>
            Мозг не обнаружен.
          </Box>
        )
      )}
      {!!bleed && (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружено кровотечение!
        </Box>
      )}

      {!!staminaStatus && (
        <Box color="#0080ff" mt={1} bold>
          Обнаружено истощение.
        </Box>
      )}

      {cloneStatus > 30 ? (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружено серьёзное клеточное повреждение!
        </Box>
      ) : (
        cloneStatus > 0 && (
          <Box color="#c51e1e" mt={1}>
            Обнаружено незначительное клеточное повреждение.
          </Box>
        )
      )}

      {!!brainWorms && (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружены отклонения в работе мозга.
        </Box>
      )}
    </Box>
  );
};

const DiseasesList = (props, context) => {
  const { data } = useBackend(context);

  const { diseases } = data.scan_data;

  return (
    <Box>
      {diseases.map((disease, index) => (
        <Section
          title={'Внимание: ' + disease.form}
          mt={2}
          mb={2}
          color="red"
          key={index}
        >
          <LabeledList>
            <LabeledList.Item label="Название">
              <Box bold>{disease.name}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Тип">
              <Box bold>{disease.additional_info}</Box>
            </LabeledList.Item>
            <LabeledList.Item label="Стадия">
              <Box bold>
                {disease.stage}/{disease.max_stages}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Лечение">
              <Box bold>{disease.cure_text}</Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </Box>
  );
};

const ReagentList = (props, context) => {
  const { data } = useBackend(context);

  const { reagentList } = data.scan_data;

  return (
    <Section title="Обнаружены вещества">
      <LabeledList>
        {reagentList.map((reagent, index) => (
          <LabeledList.Item label={reagent.name} key={index}>
            <Box>
              {reagent.volume} ед.{' '}
              {reagent.overdosed === 1 && (
                <Box as="span" color="red" bold>
                  - ПЕРЕДОЗИРОВКА!
                </Box>
              )}
            </Box>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const AddictionList = (props, context) => {
  const { data } = useBackend(context);

  const { addictionList } = data.scan_data;

  return (
    <Section title="Обнаружены зависимости">
      <LabeledList>
        {addictionList.map((addiction, index) => (
          <LabeledList.Item label={addiction.name} key={index}>
            <Box>Стадия: {addiction.addiction_stage}/5</Box>
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const ImplantList = (props, context) => {
  const { data } = useBackend(context);

  const { implantDetect } = data.scan_data;

  return (
    <Section title="Обнаружены кибернетические модификации:">
      <LabeledList>
        {implantDetect.map((implant, index) => (
          <Box key={index} ml={1} bold>
            {implant}
          </Box>
        ))}
      </LabeledList>
    </Section>
  );
};
