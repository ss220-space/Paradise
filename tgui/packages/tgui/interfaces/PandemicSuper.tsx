import { useBackend } from '../backend';
import { Box, Section, Button, LabeledList, Flex, Stack } from '../components';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type PandemicSuperData = {
  error_message: string;
  beaker_exists: boolean;
  blood_data: PandemicSuperBloodData;
  diseases: PandemicSuperDiseaseData[];
  antibodies: PandemicSuperAntibodyData[];
};

type PandemicSuperBloodData = {
  dna: string;
  group: string;
  type: string;
};

type PandemicSuperDiseaseData = {
  index: number;
  name: string;
  agent: string;
  description: string;
  route: string;
  possibleMedicine: string;
  antibodiesPossibility: string;
  symptoms: string;
  allow_remove_sympthoms: boolean;
  allow_add_sympthoms: boolean;
};

type PandemicSuperAntibodyData = {
  index: number;
  name: string;
};

export const PandemicSuper = (props: unknown) => {
  const { act, data } = useBackend<PandemicSuperData>();
  const { error_message, beaker_exists, blood_data, diseases, antibodies } =
    data;

  let blocks = [];
  if (error_message !== null) {
    blocks.push(
      <p>
        <b style={{ fontSize: 'big' }}> {error_message}</b>
      </p>
    );
  }
  if (beaker_exists) {
    blocks.push(
      <Box>
        <Button icon="eject" onClick={() => act('extractBeaker')}>
          Извлечь ёмкость
        </Button>
        <Button
          icon="trash"
          tooltip="Очищает и извлекает ёмкость."
          onClick={() => act('clearAndExtractBeaker')}
        >
          Очистить и извлечь ёмкость
        </Button>
      </Box>
    );
  }
  if (error_message === null) {
    blocks.push(
      <Stack.Item>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Данные образца крови" mb="15px">
              <LabeledList>
                <LabeledList.Item
                  label="ДНК крови"
                  labelStyle={{ fontWeight: 'bold', flex: 0.2 }}
                >
                  {blood_data.dna}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Группа крови"
                  labelStyle={{ fontWeight: 'bold', flex: 0.2 }}
                >
                  {blood_data.group}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Тип расовой крови"
                  labelStyle={{ fontWeight: 'bold', flex: 0.2 }}
                >
                  {blood_data.type}
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Данные о заболеваниях" mb="15px">
              {diseases !== null && diseases.length > 0 ? (
                diseases.map((disease) => (
                  <LabeledList key={disease.index}>
                    <LabeledList.Item
                      label="Общепринятое название"
                      labelStyle={{ fontWeight: 'bold', maxWidth: 200 }}
                    >
                      {disease.name}
                      {disease.name === 'Неизвестно' ? (
                        <Button
                          icon="tag"
                          onClick={() =>
                            act('renameDisease', {
                              index: disease.index,
                            })
                          }
                        >
                          Задать название
                        </Button>
                      ) : (
                        <Button
                          icon="tag"
                          onClick={() =>
                            act('printForm', {
                              index: disease.index,
                            })
                          }
                        >
                          Напечатать форму выпуска
                        </Button>
                      )}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Болезнетворный агент"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.agent}{' '}
                      <Button
                        icon="plus-circle"
                        onClick={() =>
                          act('createExample', {
                            index: disease.index,
                          })
                        }
                      >
                        Создать образец
                      </Button>
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Описание"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.description}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Путь передачи"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.route}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Возможное лекарство"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.possibleMedicine}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Возможность выработки антител"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.antibodiesPossibility}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Симптомы"
                      labelStyle={{
                        fontWeight: 'bold',
                        maxWidth: 200,
                        textWrap: 'wrap',
                      }}
                    >
                      {disease.symptoms}
                    </LabeledList.Item>
                    {disease.allow_add_sympthoms ||
                    disease.allow_remove_sympthoms ? (
                      <LabeledList.Item
                        label="Управление симптомами"
                        labelStyle={{
                          fontWeight: 'bold',
                          maxWidth: 200,
                          textWrap: 'wrap',
                        }}
                      >
                        {disease.allow_add_sympthoms ? (
                          <Button
                            icon="plus-circle"
                            onClick={() =>
                              act('addSympthom', {
                                index: disease.index,
                              })
                            }
                          >
                            Добавить симптом
                          </Button>
                        ) : (
                          ''
                        )}
                        {disease.allow_remove_sympthoms ? (
                          <Button
                            icon="plus-circle"
                            onClick={() =>
                              act('removeSympthom', {
                                index: disease.index,
                              })
                            }
                          >
                            Удалить симптом
                          </Button>
                        ) : (
                          ''
                        )}
                      </LabeledList.Item>
                    ) : (
                      ''
                    )}
                    <br />
                    <br />
                  </LabeledList>
                ))
              ) : (
                <b>В образце не обнаружен вирус.</b>
              )}
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Антитела" mb="15px">
              {antibodies !== null && antibodies.length > 0 ? (
                antibodies.map((antibody) => (
                  <Box key={antibody.index}>
                    {antibody.name}
                    <Button
                      icon="medkit"
                      onClick={() =>
                        act('createVaccine', {
                          index: antibody.index,
                        })
                      }
                    >
                      Создать бутылку с вакциной
                    </Button>
                  </Box>
                ))
              ) : (
                <b>Не содержит антител</b>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    );
  }
  return (
    <Window width={500} height={500} title="Панд.Е.М.И.К 220">
      <ComplexModal />
      <Window.Content scrollable>
        <Stack fill vertical>
          {blocks}
        </Stack>
      </Window.Content>
    </Window>
  );
};
