import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  Section,
  Stack,
  Input,
  Slider,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';
import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { createSearch } from 'common/string';

const trimLongStr = (str: string, length: number) => {
  return str.length > length ? str.substring(0, length) + '...' : str;
};

const selectForms = (forms: Form[], searchText = ''): Form[] => {
  const testSearch = createSearch(searchText, (form: Form) => form.altername);
  return flow([
    (forms: Form[]) => filter(forms, (form) => !!form?.altername),
    (forms: Form[]) => (searchText ? filter(forms, testSearch) : forms),
    (forms: Form[]) => sortBy(forms, (form) => form.id),
  ])(forms);
};

type Form = {
  id: string;
  altername: string;
  category: string;
  path: string;
};

type PhotocopierData = {
  copies: number;
  category: string;
  maxcopies: number;
  ui_theme: string;
  toner: number;
  forms: Form[];
  form_id: string;
  copyitem: string;
  mob: string;
  folder: string;
  form: Form;
  isAI: boolean;
};

export const Photocopier = (_props: unknown) => {
  const { act, data } = useBackend<PhotocopierData>();

  const { copies, maxcopies } = data;

  const [searchText, setSearchText] = useState('');

  const forms = selectForms(
    sortBy(data.forms || [], (form) => form.category),
    searchText
  );
  const categories = [];
  for (let form of forms) {
    if (!categories.includes(form.category)) {
      categories.push(form.category);
    }
  }
  let category: Form[];
  if (data.category === '') {
    category = forms;
  } else {
    category = forms.filter((form: Form) => form.category === data.category);
  }

  return (
    <Window width={550} height={575} theme={data.ui_theme}>
      <Window.Content>
        <Stack fill>
          <Stack.Item basis="40%">
            <Stack fill vertical>
              <Section title="Статус">
                <Stack>
                  <Stack.Item width="50%" mt={0.3} color="grey">
                    Заряд тонера:
                  </Stack.Item>
                  <Stack.Item width="50%">
                    <ProgressBar
                      minValue={0}
                      maxValue={30}
                      value={data.toner}
                    />
                  </Stack.Item>
                </Stack>
                <Stack mt={1}>
                  <Stack.Item width="50%" mb={0.3} color="grey">
                    Форма:
                  </Stack.Item>
                  <Stack.Item width="50%" textAlign="center" bold>
                    {data.form_id === '' ? 'Не выбрана' : data.form_id}
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item width="100%" mt={1}>
                    <Button
                      fluid
                      textAlign="center"
                      disabled={!data.copyitem && !data.mob}
                      icon={data.copyitem || data.mob ? 'eject' : 'times'}
                      onClick={() => act('removedocument')}
                    >
                      {data.copyitem
                        ? data.copyitem
                        : data.mob
                          ? 'Жопа ' + data.mob + '!'
                          : 'Слот для документа'}
                    </Button>
                  </Stack.Item>
                </Stack>
                <Stack>
                  <Stack.Item width="100%" mt="3px">
                    <Button
                      fluid
                      textAlign="center"
                      disabled={!data.folder}
                      icon={data.folder ? 'eject' : 'times'}
                      onClick={() => act('removefolder')}
                    >
                      {data.folder ? data.folder : 'Слот для папки'}
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
              <Section title="Управление">
                <Stack>
                  <Stack.Item grow width="100%">
                    <Button
                      fluid
                      textAlign="center"
                      icon="print"
                      disabled={data.toner === 0 || data.form === null}
                      onClick={() => act('print_form')}
                    >
                      Печать
                    </Button>
                  </Stack.Item>
                  {!!data.isAI && (
                    <Stack.Item grow width="100%" ml="5px">
                      <Button
                        fluid
                        textAlign="center"
                        icon="image"
                        disabled={data.toner < 5}
                        tooltip="Распечатать фото с Базы Данных"
                        onClick={() => act('ai_pic')}
                      >
                        Фото
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
                <Stack>
                  <Stack.Item grow width="100%" mt="3px">
                    <Button
                      fluid
                      textAlign="center"
                      icon="copy"
                      disabled={
                        data.toner === 0 || (!data.copyitem && !data.mob)
                      }
                      onClick={() => act('copy')}
                    >
                      Копия
                    </Button>
                  </Stack.Item>
                  {!!data.isAI && (
                    <Stack.Item grow width="100%" ml="5px" mt="3px">
                      <Button
                        fluid
                        textAlign="center"
                        icon="i-cursor"
                        tooltip="Распечатать свой текст"
                        disabled={data.toner === 0}
                        onClick={() => act('ai_text')}
                      >
                        Текст
                      </Button>
                    </Stack.Item>
                  )}
                </Stack>
                <Stack>
                  <Stack.Item mr={1.5} mt={1.2} width="50%" color="grey">
                    Количество:
                  </Stack.Item>
                  <Slider
                    mt={0.75}
                    width="50%"
                    animated
                    minValue={1}
                    maxValue={maxcopies}
                    value={copies}
                    stepPixelSize={10}
                    onChange={(e, value) =>
                      act('copies', {
                        new: value,
                      })
                    }
                  />
                </Stack>
              </Section>
              <Stack.Item grow mt={0}>
                <Section fill scrollable title="Бюрократия">
                  <Stack fill vertical>
                    <Stack.Item>
                      <Button
                        fluid
                        mb={-0.5}
                        icon="chevron-right"
                        color="transparent"
                        selected={!data.category}
                        onClick={() =>
                          act('choose_category', {
                            category: '',
                          })
                        }
                      >
                        Все формы
                      </Button>
                    </Stack.Item>
                    {categories.map((category) => (
                      <Stack.Item key={category}>
                        <Button
                          fluid
                          key={category}
                          icon="chevron-right"
                          mb={-0.5}
                          color="transparent"
                          selected={data.category === category}
                          onClick={() =>
                            act('choose_category', {
                              category: category,
                            })
                          }
                        >
                          {category}
                        </Button>
                      </Stack.Item>
                    ))}
                  </Stack>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item basis="60%">
            <Section
              fill
              scrollable
              title={data.category || 'Все формы'}
              buttons={
                <Input
                  mr={18.5}
                  width="100%"
                  placeholder="Поиск формы"
                  expensive
                  onChange={setSearchText}
                />
              }
            >
              {category.map((form) => (
                <Stack.Item key={form.path}>
                  <Button
                    fluid
                    mb={0.5}
                    color="transparent"
                    tooltip={form.altername}
                    selected={data.form_id === form.id}
                    onClick={() =>
                      act('choose_form', {
                        path: form.path,
                        id: form.id,
                      })
                    }
                  >
                    {trimLongStr(form.altername, 37)}
                  </Button>
                </Stack.Item>
              ))}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
