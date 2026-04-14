import { useBackend } from '../backend';
import { Button, Section, Stack, Divider } from '../components';
import { Window } from '../layouts';

interface InteractionData {
  target_name: string;
  is_adjacent: boolean;
  has_usable_hands: boolean;
  target_has_usable_hands: boolean;
  can_use_mouth: boolean;
  target_mouth_free: boolean;
  target_species: string;
  can_pet_target: boolean;
  can_bite: boolean;
}

export const InteractionMenu = (props) => {
  const { data, act } = useBackend<InteractionData>();
  const {
    target_name,
    is_adjacent,
    has_usable_hands,
    target_has_usable_hands,
    can_use_mouth,
    target_mouth_free,
    target_species,
    can_pet_target,
    can_bite,
  } = data;

  return (
    <Window width={340} height={520} title="Взаимодействие">
      <Window.Content scrollable>
        <Section title={target_name || 'Персонаж'}>
          <Stack vertical>
            <Button fluid icon="user-friends" onClick={() => act('bow')}>
              Отвесить поклон
            </Button>

            {!!has_usable_hands && (
              <>
                <Divider />
                <div className="bold">Руки:</div>
                <Stack vertical>
                  <Button fluid onClick={() => act('wave')}>
                    Приветливо помахать
                  </Button>
                  <Button fluid onClick={() => act('bow_affably')}>
                    Приветливо кивнуть
                  </Button>
                  <Button color="danger" fluid onClick={() => act('fuckyou')}>
                    Показать средний палец
                  </Button>
                  <Button color="danger" fluid onClick={() => act('threaten')}>
                    Погрозить кулаком
                  </Button>

                  {!!is_adjacent && (
                    <>
                      <Button fluid onClick={() => act('handshake')}>
                        Пожать руку
                      </Button>
                      <Button fluid onClick={() => act('hug')}>
                        Обнимашки!
                      </Button>
                      <Button fluid onClick={() => act('cheer')}>
                        Похлопать по плечу
                      </Button>
                      <Button fluid onClick={() => act('five')}>
                        Дать пять
                      </Button>
                      {!!target_has_usable_hands && (
                        <Button fluid onClick={() => act('give')}>
                          Передать предмет
                        </Button>
                      )}
                      <Button color="danger" fluid onClick={() => act('slap')}>
                        Дать пощечину!
                      </Button>

                      {target_species === 'Moth' && (
                        <Button
                          color="danger"
                          fluid
                          onClick={() => act('pullwing')}
                        >
                          Дёрнуть за крылья!
                        </Button>
                      )}
                      {['Tajaran', 'Vox', 'Vulpkanin', 'Unathi'].includes(
                        target_species
                      ) && (
                        <>
                          <Button
                            color="danger"
                            fluid
                            onClick={() => act('pull')}
                          >
                            Дёрнуть за хвост!
                          </Button>
                          {!!can_pet_target && (
                            <>
                              <Button fluid onClick={() => act('pet')}>
                                Погладить
                              </Button>
                              <Button fluid onClick={() => act('scratch')}>
                                Почесать
                              </Button>
                            </>
                          )}
                        </>
                      )}
                      <Button color="danger" fluid onClick={() => act('knock')}>
                        Дать подзатыльник
                      </Button>
                    </>
                  )}
                </Stack>
              </>
            )}

            {!!can_use_mouth && (
              <>
                <Divider />
                <div className="bold">Лицо:</div>
                <Stack vertical>
                  <Button fluid onClick={() => act('kiss')}>
                    Поцеловать
                  </Button>
                  <Button color="danger" fluid onClick={() => act('tongue')}>
                    Показать язык
                  </Button>

                  {!!is_adjacent && (
                    <>
                      {!!can_bite && (
                        <Button
                          color="danger"
                          fluid
                          icon="tooth"
                          onClick={() => act('bite')}
                        >
                          Укусить
                        </Button>
                      )}
                      {!!target_mouth_free && (
                        <Button fluid onClick={() => act('lick')}>
                          Лизнуть в щеку
                        </Button>
                      )}
                      <Button color="danger" fluid onClick={() => act('spit')}>
                        Плюнуть
                      </Button>
                    </>
                  )}
                </Stack>
              </>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
