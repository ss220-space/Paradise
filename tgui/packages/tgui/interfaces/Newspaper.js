import { useBackend, useLocalState } from '../backend';
import { Box, Section, Image, Icon, Button, Flex } from '../components';
import { Window } from '../layouts';

export const Newspaper = (props, context) => {
  const { act, data } = useBackend(context);

  const {
    wanted,
    stories = [],
    current_page,
    total_pages,
    advertisements,
    scribble = [],
  } = data;

  const startIndex = (current_page - 1) * 8;
  const endIndex = startIndex + 8;
  const currentStories = stories.slice(startIndex, endIndex);

  const currentScribble = scribble.find((note) => note.id === current_page);

  const days = [
    'Воскресенье',
    'Понедельник',
    'Вторник',
    'Среда',
    'Четверг',
    'Пятница',
    'Суббота',
  ];
  const monthNames = [
    'января',
    'февраля',
    'марта',
    'апреля',
    'мая',
    'июня',
    'июля',
    'августа',
    'сентября',
    'октября',
    'ноября',
    'декабря',
  ];
  let date = new Date();

  return (
    <Window width={800} height={600} theme="paper" title="Газета Грифон">
      <Window.Content scrollable>
        <Flex mb={2}>
          <Flex.Item width="100%" textAlign="center" fontSize="12px" bold>
            {days[date.getDay()] +
              ', ' +
              date.getDate() +
              ' ' +
              monthNames[date.getMonth()] +
              ', ' +
              (date.getFullYear() + 544) +
              ' год'}
          </Flex.Item>
        </Flex>

        <Box
          textAlign="center"
          fontSize="48px"
          bold
          mb={1}
          fontFamily="Times New Roman"
        >
          ГРИФОН
        </Box>
        <Box textAlign="center" fontSize="12px" color="#666" m={2} mt={0}>
          Печатная газета, созданная специально для космических объектов
          НаноТрейзен. Служит основным источником новостей, объявлений и
          полезной информации для всех членов экипажа.
        </Box>

        <Box height="2px" backgroundColor="#000" mb={2} />

        {wanted && current_page === 1 && (
          <WantedBlock
            id={wanted[0].uid}
            title={wanted[0].title}
            body={wanted[0].body}
            photo={wanted[0].photo}
          />
        )}

        {currentStories.length > 0 ? (
          <Flex>
            <Flex.Item width="50%" mr={1}>
              {currentStories
                .filter((_, index) => index % 2 === 0)
                .map((article, index) => (
                  <Box key={index} mb={2}>
                    <Section
                      title={article.title}
                      style={{ 'box-shadow': '0px 4px rgba(17, 17, 17, 0.35)' }}
                    >
                      {article.photo ? (
                        <Flex wrap="wrap" justify="space-between">
                          <Flex.Item width="40%">
                            <PhotoThumbnail
                              name={'story_photo_' + article.uid + '.png'}
                              float="left"
                              width="100%"
                            />
                          </Flex.Item>
                          <Flex.Item width="58%">{article.body}</Flex.Item>
                        </Flex>
                      ) : (
                        <Flex.Item width="100%">{article.body}</Flex.Item>
                      )}
                      {article.author && (
                        <Box mt={1} color="#666" italic>
                          Автор: {article.author}
                        </Box>
                      )}
                    </Section>
                  </Box>
                ))}
            </Flex.Item>

            <Flex.Item width="50%" ml={1}>
              {currentStories
                .filter((_, index) => index % 2 !== 0)
                .map((article, index) => (
                  <Box key={index} mb={2}>
                    <Section
                      title={article.title}
                      style={{ 'box-shadow': '0px 4px rgba(17, 17, 17, 0.35)' }}
                    >
                      {article.photo ? (
                        <Flex wrap="wrap" justify="space-between">
                          <Flex.Item width="40%">
                            <PhotoThumbnail
                              name={'story_photo_' + article.uid + '.png'}
                              float="left"
                              width="100%"
                            />
                          </Flex.Item>
                          <Flex.Item width="58%">{article.body}</Flex.Item>
                        </Flex>
                      ) : (
                        <Flex.Item width="100%">{article.body}</Flex.Item>
                      )}
                      {article.author && (
                        <Box mt={1} color="#666" italic>
                          Автор: {article.author}
                        </Box>
                      )}
                    </Section>
                  </Box>
                ))}
            </Flex.Item>
          </Flex>
        ) : (
          <Box textAlign="center" textfontSize="18px" color="#666" mb={2}>
            Кажется еще никто не успел опубликовать свежие новости...
          </Box>
        )}

        {current_page === 1 && (
          <Box>
            <Box height="2px" backgroundColor="#000" my={2} />
            <Box textAlign="center" fontSize="20px" bold mb={1}>
              Реклама
            </Box>
            <Section style={{ 'box-shadow': '0px 4px rgba(17, 17, 17, 0.35)' }}>
              <Flex>
                <Flex.Item
                  key="1"
                  width="100%"
                  fontSize="16px"
                  m={2}
                  mt={0}
                  textAlign="center"
                  p={2}
                >
                  {advertisements}
                </Flex.Item>
              </Flex>
            </Section>
            <Box textAlign="left" fontSize="8px" bold m={2}>
              &quot;Грифон&quot; не несёт ответственности за содержание рекламы,
              точность указанной информации, а также за возможные последствия,
              связанные с использованием рекламируемых товаров или услуг.
              &quot;Грифон&quot; не гарантирует качество, безопасность или
              соответствие рекламируемых продуктов заявленным характеристикам.
            </Box>
          </Box>
        )}

        {currentScribble && (
          <Box fontSize="12px" mb={1} mt={1}>
            <Box height="2px" backgroundColor="#000" my={2} />
            <i>
              В конце страницы есть небольшая пометка... <br />
              Там написано:
            </i>
            <br />
            <Box fontSize="12px" bold>
              {currentScribble.text}
            </Box>
          </Box>
        )}

        <Box height="2px" backgroundColor="#000" my={2} />

        <Box textAlign="center" mt={2}>
          <Button
            icon="arrow-left"
            mr={1}
            disabled={current_page === 1}
            onClick={() => act('prev_page')}
          />
          <Button
            icon="arrow-right"
            disabled={current_page === total_pages || total_pages === 0}
            onClick={() => act('next_page')}
          />
        </Box>

        <Box textAlign="center" mt={2} color="#666" fontSize="14px">
          Страница {current_page}
        </Box>
      </Window.Content>
    </Window>
  );
};

const PhotoThumbnail = (properties, context) => {
  const { name, ...rest } = properties;
  const [viewingPhoto, setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  return (
    <Box
      as="img"
      className="Newscaster__photo"
      src={name}
      onClick={() => setViewingPhoto(name)}
      {...rest}
    />
  );
};

const WantedBlock = (properties, contex) => {
  const { id, title, body, photo } = properties;

  return (
    <Section
      title="Внимание! Розыск!"
      mb={2}
      style={{
        'background-color': 'rgba(197, 22, 22, 0.71)',
        'box-shadow': '0px 4px rgba(197, 22, 22, 0.9)',
      }}
    >
      <Flex>
        {photo && (
          <Flex.Item width="30%">
            <PhotoThumbnail
              name={'story_photo_' + id + '.png'}
              float="left"
              mr="0.5rem"
              width="100%"
            />
          </Flex.Item>
        )}
        <Flex.Item width="70%" ml={2}>
          <Box fontSize="20px" bold>
            {title}
          </Box>
          <Box mt={1}>{body}</Box>
        </Flex.Item>
      </Flex>
    </Section>
  );
};
