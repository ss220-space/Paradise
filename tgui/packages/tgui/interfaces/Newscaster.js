import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
} from '../components';
import { timeAgo } from '../constants';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalAnswer,
  modalClose,
  modalOpen,
  modalRegisterBodyOverride,
} from './common/ComplexModal';
import { TemporaryNotice } from './common/TemporaryNotice';

const HEADLINE_MAX_LENGTH = 128;

const jobOpeningCategoriesOrder = [
  'security',
  'engineering',
  'medical',
  'science',
  'service',
  'supply',
];
const jobOpeningCategories = {
  security: {
    title: 'Security',
    fluff_text: 'Помогайте обеспечивать безопасность экипажа',
  },
  engineering: {
    title: 'Engineering',
    fluff_text: 'Следите за бесперебойной работой станции',
  },
  medical: {
    title: 'Medical',
    fluff_text: 'Занимайтесь медициной и спасайте жизни',
  },
  science: {
    title: 'Science',
    fluff_text: 'Разрабатывайте новые технологии',
  },
  service: {
    title: 'Service',
    fluff_text: 'Обеспечивайте экипаж удобствами',
  },
  supply: {
    title: 'Supply',
    fluff_text: 'Поддерживайте снабжение станции',
  },
};

export const Newscaster = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    is_security,
    is_admin,
    is_silent,
    is_printing,
    screen,
    channels,
    channel_idx = -1,
  } = data;
  const [menuOpen, setMenuOpen] = useLocalState(context, 'menuOpen', false);
  const [viewingPhoto, _setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  const [censorMode, setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  let body;
  if (screen === 0 || screen === 2) {
    body = <NewscasterFeed />;
  } else if (screen === 1) {
    body = <NewscasterJobs />;
  }
  const totalUnread = channels.reduce((a, c) => a + c.unread, 0);
  return (
    <Window theme={is_security && 'security'} width={800} height={600}>
      {viewingPhoto ? (
        <PhotoZoom />
      ) : (
        <ComplexModal
          maxWidth={window.innerWidth / 1.5 + 'px'}
          maxHeight={window.innerHeight / 1.5 + 'px'}
        />
      )}
      <Window.Content>
        <Stack fill>
          <Section
            fill
            className={classes([
              'Newscaster__menu',
              menuOpen && 'Newscaster__menu--open',
            ])}
          >
            <Stack fill vertical>
              <Stack.Item>
                <MenuButton
                  icon="bars"
                  title="Меню"
                  onClick={() => setMenuOpen(!menuOpen)}
                />
                <MenuButton
                  icon="newspaper"
                  title="Статьи"
                  selected={screen === 0}
                  onClick={() => act('headlines')}
                >
                  {totalUnread > 0 && (
                    <Box className="Newscaster__menuButton--unread">
                      {totalUnread >= 10 ? '9+' : totalUnread}
                    </Box>
                  )}
                </MenuButton>
                <MenuButton
                  icon="briefcase"
                  title="Вакансии"
                  selected={screen === 1}
                  onClick={() => act('jobs')}
                />
                <Divider />
              </Stack.Item>
              <Stack.Item grow>
                {channels.map((channel) => (
                  <MenuButton
                    key={channel}
                    icon={channel.icon}
                    title={channel.name}
                    selected={
                      screen === 2 && channels[channel_idx - 1] === channel
                    }
                    onClick={() => act('channel', { uid: channel.uid })}
                  >
                    {channel.unread > 0 && (
                      <Box className="Newscaster__menuButton--unread">
                        {channel.unread >= 10 ? '9+' : channel.unread}
                      </Box>
                    )}
                  </MenuButton>
                ))}
              </Stack.Item>
              <Stack.Item>
                <Divider />
                {(!!is_security || !!is_admin) && (
                  <>
                    <MenuButton
                      security
                      icon="exclamation-circle"
                      title="Редактировать розыск"
                      mb="0.5rem"
                      onClick={() => modalOpen(context, 'wanted_notice')}
                    />
                    <MenuButton
                      security
                      icon={censorMode ? 'minus-square' : 'minus-square-o'}
                      title={'Режим Цензуры: ' + (censorMode ? 'Вкл' : 'Выкл')}
                      mb="0.5rem"
                      onClick={() => setCensorMode(!censorMode)}
                    />
                    <Divider />
                  </>
                )}
                <MenuButton
                  icon="pen-alt"
                  title="Новая статья"
                  mb="0.5rem"
                  onClick={() => modalOpen(context, 'create_story')}
                />
                <MenuButton
                  icon="plus-circle"
                  title="Новый канал"
                  onClick={() => modalOpen(context, 'create_channel')}
                />
                <Divider />
                <MenuButton
                  icon={is_printing ? 'spinner' : 'print'}
                  iconSpin={is_printing}
                  title={is_printing ? 'Печать...' : 'Распечатать газету'}
                  onClick={() => act('print_newspaper')}
                />
                <MenuButton
                  icon={is_silent ? 'volume-mute' : 'volume-up'}
                  title={'Заглушить: ' + (is_silent ? 'Вкл' : 'Выкл')}
                  onClick={() => act('toggle_mute')}
                />
              </Stack.Item>
            </Stack>
          </Section>
          <Stack fill vertical width="100%">
            <TemporaryNotice />
            {body}
          </Stack>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MenuButton = (properties, context) => {
  const { act } = useBackend(context);
  const {
    icon = '',
    iconSpin,
    selected = false,
    security = false,
    onClick,
    title,
    children,
    ...rest
  } = properties;
  return (
    <Box
      className={classes([
        'Newscaster__menuButton',
        selected && 'Newscaster__menuButton--selected',
        security && 'Newscaster__menuButton--security',
      ])}
      onClick={onClick}
      {...rest}
    >
      {selected && <Box className="Newscaster__menuButton--selectedBar" />}
      <Icon name={icon} spin={iconSpin} size="2" />
      <Box className="Newscaster__menuButton--title">{title}</Box>
      {children}
    </Box>
  );
};

const NewscasterFeed = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    screen,
    is_admin,
    channel_idx,
    channel_can_manage,
    channels,
    stories,
    wanted,
  } = data;
  const [fullStories, _setFullStories] = useLocalState(
    context,
    'fullStories',
    []
  );
  const [censorMode, _setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  const channel =
    screen === 2 && channel_idx > -1 ? channels[channel_idx - 1] : null;
  return (
    <Stack fill vertical>
      {!!wanted && <Story story={wanted} wanted />}
      <Section
        fill
        scrollable
        title={
          <>
            <Icon name={channel ? channel.icon : 'newspaper'} mr="0.5rem" />
            {channel ? channel.name : 'Статьи'}
          </>
        }
      >
        {stories.length > 0 ? (
          stories
            .slice()
            .reverse()
            .map((story) =>
              !fullStories.includes(story.uid) &&
              story.body.length + 3 > HEADLINE_MAX_LENGTH
                ? {
                    ...story,
                    body_short:
                      story.body.substr(0, HEADLINE_MAX_LENGTH - 4) + '...',
                  }
                : story
            )
            .map((story, index) => <Story key={index} story={story} />)
        ) : (
          <Box className="Newscaster__emptyNotice">
            <Icon name="times" size="3" />
            <br />В настоящее время нет никаких статей.
          </Box>
        )}
      </Section>
      {!!channel && (
        <Section
          fill
          scrollable
          height="40%"
          title={
            <>
              <Icon name="info-circle" mr="0.5rem" />О канале
            </>
          }
          buttons={
            <>
              {censorMode && (
                <Button
                  disabled={!!channel.admin && !is_admin}
                  selected={channel.censored}
                  icon={channel.censored ? 'comment-slash' : 'comment'}
                  content={
                    channel.censored
                      ? 'Заблокировать канал'
                      : 'Разблокировать канал'
                  }
                  mr="0.5rem"
                  onClick={() => act('censor_channel', { uid: channel.uid })}
                />
              )}
              <Button
                disabled={!channel_can_manage}
                icon="cog"
                content="Управление"
                onClick={() =>
                  modalOpen(context, 'manage_channel', {
                    uid: channel.uid,
                  })
                }
              />
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Описание">
              {channel.description || 'Н/Д'}
            </LabeledList.Item>
            <LabeledList.Item label="Владелец">
              {channel.author || 'Н/Д'}
            </LabeledList.Item>
            <LabeledList.Item label="Публичный">
              {channel.public ? 'Да' : 'Нет'}
            </LabeledList.Item>
            <LabeledList.Item label="Всего просмотров">
              <Icon name="eye" mr="0.5rem" />
              {stories.reduce((a, c) => a + c.view_count, 0).toLocaleString()}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Stack>
  );
};

const NewscasterJobs = (properties, context) => {
  const { act, data } = useBackend(context);
  const { jobs, wanted } = data;
  const numOpenings = Object.entries(jobs).reduce(
    (a, [k, v]) => a + v.length,
    0
  );
  return (
    <Stack fill vertical>
      {!!wanted && <Story story={wanted} wanted />}
      <Section
        fill
        scrollable
        title={
          <>
            <Icon name="briefcase" mr="0.5rem" />
            Открытые вакансии
          </>
        }
        buttons={
          <Box mt="0.25rem" color="label">
            Работайте ради лучшего будущего в Nanotrasen
          </Box>
        }
      >
        {numOpenings > 0 ? (
          jobOpeningCategoriesOrder
            .map((catId) =>
              Object.assign({}, jobOpeningCategories[catId], {
                id: catId,
                jobs: jobs[catId],
              })
            )
            .filter((cat) => !!cat && cat.jobs.length > 0)
            .map((cat) => (
              <Section
                key={cat.id}
                className={classes([
                  'Newscaster__jobCategory',
                  'Newscaster__jobCategory--' + cat.id,
                ])}
                title={cat.title}
                buttons={
                  <Box mt="0.25rem" color="label">
                    {cat.fluff_text}
                  </Box>
                }
              >
                {cat.jobs.map((job) => (
                  <Box
                    key={job.title}
                    class={classes([
                      'Newscaster__jobOpening',
                      !!job.is_command && 'Newscaster__jobOpening--command',
                    ])}
                  >
                    • {job.title}
                  </Box>
                ))}
              </Section>
            ))
        ) : (
          <Box className="Newscaster__emptyNotice">
            <Icon name="times" size="3" />
            <br />В настоящее время свободных вакансий.
          </Box>
        )}
      </Section>
      <Section height="17%">
        Интересует работа в НаноТрейзен?
        <br />
        Запишитесь на любую из вышеуказанных должностей прямо сейчас в{' '}
        <b>Офисе Главы Персонала!</b>
        <br />
        <Box as="small" color="label">
          Подписываясь на работу в НаноТрейзен, вы соглашаетесь передать свою
          душу в отдел лояльности вездесущего и полезного наблюдателя за
          человечеством.
        </Box>
      </Section>
    </Stack>
  );
};

const Story = (properties, context) => {
  const { act, data } = useBackend(context);
  const { story, wanted = false } = properties;
  const [fullStories, setFullStories] = useLocalState(
    context,
    'fullStories',
    []
  );
  const [censorMode, _setCensorMode] = useLocalState(
    context,
    'censorMode',
    false
  );
  return (
    <Section
      className={classes([
        'Newscaster__story',
        wanted && 'Newscaster__story--wanted',
      ])}
      title={
        <>
          {wanted && <Icon name="exclamation-circle" mr="0.5rem" />}
          {(story.censor_flags & 2 && '[ОТРЕДАКТИРОВАНО]') ||
            story.title ||
            'News from ' + story.author}
        </>
      }
      buttons={
        <Box mt="0.25rem">
          <Box color="label">
            {!wanted && censorMode && (
              <Box inline>
                <Button
                  enabled={story.censor_flags & 2}
                  icon={story.censor_flags & 2 ? 'comment-slash' : 'comment'}
                  content={
                    story.censor_flags & 2 ? 'Разблокировать' : 'Заблокировать'
                  }
                  mr="0.5rem"
                  mt="-0.25rem"
                  onClick={() => act('censor_story', { uid: story.uid })}
                />
              </Box>
            )}
            <Box inline>
              <Icon name="user" /> {story.author} |&nbsp;
              {!wanted && (
                <>
                  <Icon name="eye" /> {story.view_count.toLocaleString()}{' '}
                  |&nbsp;
                </>
              )}
              <Icon name="clock" />{' '}
              {timeAgo(story.publish_time, data.world_time)}
            </Box>
          </Box>
        </Box>
      }
    >
      <Box>
        {story.censor_flags & 2 ? (
          '[ОТРЕДАКТИРОВАНО]'
        ) : (
          <>
            {!!story.has_photo && (
              <PhotoThumbnail
                name={'story_photo_' + story.uid + '.png'}
                float="right"
                ml="0.5rem"
              />
            )}
            {(story.body_short || story.body).split('\n').map((p, index) => (
              <Box key={index}>{p || <br />}</Box>
            ))}
            {story.body_short && (
              <Button
                content="Читать далее.."
                mt="0.5rem"
                onClick={() => setFullStories([...fullStories, story.uid])}
              />
            )}
            <Box clear="right" />
          </>
        )}
      </Box>
    </Section>
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

const PhotoZoom = (properties, context) => {
  const [viewingPhoto, setViewingPhoto] = useLocalState(
    context,
    'viewingPhoto',
    ''
  );
  return (
    <Modal className="Newscaster__photoZoom">
      <Box as="img" src={viewingPhoto} />
      <Button
        icon="times"
        content="Закрыть"
        color="grey"
        mt="1rem"
        onClick={() => setViewingPhoto('')}
      />
    </Modal>
  );
};

// This handles both creation and editing
const manageChannelModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  // Additional data
  const channel =
    !!modal.args.uid &&
    data.channels.filter((c) => c.uid === modal.args.uid).pop();
  if (modal.id === 'manage_channel' && !channel) {
    modalClose(context); // ?
    return;
  }
  const isEditing = modal.id === 'manage_channel';
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    channel?.author || scannedUser || 'Неавторизованный'
  );
  const [name, setName] = useLocalState(context, 'name', channel?.name || '');
  const [description, setDescription] = useLocalState(
    context,
    'description',
    channel?.description || ''
  );
  const [icon, setIcon] = useLocalState(
    context,
    'icon',
    channel?.icon || 'newspaper'
  );
  const [isPublic, setIsPublic] = useLocalState(
    context,
    'isPublic',
    isEditing ? !!channel?.public : false
  );
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    channel?.admin === 1 || false
  );
  return (
    <Section
      m="-1rem"
      pb="1.5rem"
      title={isEditing ? 'Управление: ' + channel.name : 'Создать новый канал'}
    >
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Владелец">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Название">
            <Input
              width="100%"
              placeholder="Макс. 50 символов"
              maxLength="50"
              value={name}
              onInput={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Описание (опционально)" verticalAlign="top">
            <Input
              multiline
              width="100%"
              placeholder="Макс. 128 символов."
              maxLength="128"
              value={description}
              onInput={(_e, v) => setDescription(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Иконка">
            <Input
              disabled={!isAdmin}
              value={icon}
              width="35%"
              mr="0.5rem"
              onInput={(_e, v) => setIcon(v)}
            />
            <Icon name={icon} size="2" verticalAlign="middle" mr="0.5rem" />
          </LabeledList.Item>
          <LabeledList.Item label="Сделать канал публичным?">
            <Button
              selected={isPublic}
              icon={isPublic ? 'toggle-on' : 'toggle-off'}
              content={isPublic ? 'Да' : 'Нет'}
              onClick={() => setIsPublic(!isPublic)}
            />
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'Вкл' : 'Выкл'}
                tooltip="Блокировка этого канала сделает его доступным для редактирования только для сотрудников CentComm."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={author.trim().length === 0 || name.trim().length === 0}
        icon="check"
        color="good"
        content="ОК"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, modal.id, '', {
            author: author,
            name: name.substr(0, 49),
            description: description.substr(0, 128),
            icon: icon,
            public: isPublic ? 1 : 0,
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

const createStoryModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const { photo, channels, channel_idx = -1 } = data;
  // Additional data
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  let availableChannels = channels
    .slice()
    .sort((a, b) => {
      if (channel_idx < 0) {
        return 0;
      }
      const selected = channels[channel_idx - 1];
      if (selected.uid === a.uid) {
        return -1;
      } else if (selected.uid === b.uid) {
        return 1;
      }
    })
    .filter(
      (c) => isAdmin || (!c.frozen && (c.author === scannedUser || !!c.public))
    );
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    scannedUser || 'Unknown'
  );
  const [channel, setChannel] = useLocalState(
    context,
    'channel',
    availableChannels.length > 0 ? availableChannels[0].name : ''
  );
  const [title, setTitle] = useLocalState(context, 'title', '');
  const [body, setBody] = useLocalState(context, 'body', '');
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    false
  );
  return (
    <Section m="-1rem" pb="1.5rem" title="Написать новую статью">
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Автор">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Канал" verticalAlign="top">
            <Dropdown
              selected={channel}
              options={availableChannels.map((c) => c.name)}
              mb="0"
              width="100%"
              onSelected={(c) => setChannel(c)}
            />
          </LabeledList.Item>
          <LabeledList.Divider />
          <LabeledList.Item label="Заголовок">
            <Input
              width="100%"
              placeholder="Макс. 128 символов"
              maxLength="128"
              value={title}
              onInput={(_e, v) => setTitle(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Текст статьи" verticalAlign="top">
            <Input
              fluid
              multiline
              placeholder="Макс. 1024 символов"
              maxLength="1024"
              rows="8"
              width="100%"
              value={body}
              onInput={(_e, v) => setBody(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Фото (опционально)" verticalAlign="top">
            <Button
              icon="image"
              selected={photo}
              content={photo ? 'Достать: ' + photo.name : 'Вставить фото'}
              tooltip={
                !photo && 'Приложите фото к этой статье, держа ее в руке.'
              }
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Превью" verticalAlign="top">
            <Section
              noTopPadding
              title={title}
              maxHeight="13.5rem"
              overflow="auto"
            >
              <Box mt="0.5rem">
                {!!photo && (
                  <PhotoThumbnail
                    name={'inserted_photo_' + photo.uid + '.png'}
                    float="right"
                  />
                )}
                {body.split('\n').map((p, index) => (
                  <Box key={index}>{p || <br />}</Box>
                ))}
                <Box clear="right" />
              </Box>
            </Section>
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'Вкл' : 'Выкл'}
                tooltip="Публикация этой статьи сделает ее недоступной для цензуры никем, кроме сотрудников CentComm."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={
          author.trim().length === 0 ||
          channel.trim().length === 0 ||
          title.trim().length === 0 ||
          body.trim().length === 0
        }
        icon="check"
        color="good"
        content="ОК"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, 'create_story', '', {
            author: author,
            channel: channel,
            title: title.substr(0, 127),
            body: body.substr(0, 1023),
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

const wantedNoticeModalBodyOverride = (modal, context) => {
  const { act, data } = useBackend(context);
  const { photo, wanted } = data;
  // Additional data
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useLocalState(
    context,
    'author',
    wanted?.author || scannedUser || 'Неавторизованный'
  );
  const [name, setName] = useLocalState(
    context,
    'name',
    wanted?.title.substr(8) || ''
  );
  const [description, setDescription] = useLocalState(
    context,
    'description',
    wanted?.body || ''
  );
  const [adminLocked, setAdminLocked] = useLocalState(
    context,
    'adminLocked',
    wanted?.admin_locked === 1 || false
  );
  return (
    <Section m="-1rem" pb="1.5rem" title="Уведомлением о розыске">
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Authority">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onInput={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Имя">
            <Input
              width="100%"
              value={name}
              maxLength="128"
              onInput={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Описание" verticalAlign="top">
            <Input
              multiline
              width="100%"
              value={description}
              maxLength="512"
              rows="4"
              onInput={(_e, v) => setDescription(v)}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Фото (опционально)" verticalAlign="top">
            <Button
              icon="image"
              selected={photo}
              content={photo ? 'Достать: ' + photo.name : 'Вставить фото'}
              tooltip={
                !photo && 'Приложите фото к этой статье, держа ее в руке.'
              }
              tooltipPosition="top"
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            />
            {!!photo && (
              <PhotoThumbnail
                name={'inserted_photo_' + photo.uid + '.png'}
                float="right"
              />
            )}
          </LabeledList.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                content={adminLocked ? 'Вкл' : 'Выкл'}
                tooltip="Заблокировав это уведомление о розыске, никто, кроме сотрудников CentComm, не сможет его редактировать."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Box>
      <Button.Confirm
        disabled={!wanted}
        icon="eraser"
        color="danger"
        content="Очистить"
        position="absolute"
        right="7.25rem"
        bottom="-0.75rem"
        onClick={() => {
          act('clear_wanted_notice');
          modalClose(context);
        }}
      />
      <Button.Confirm
        disabled={
          author.trim().length === 0 ||
          name.trim().length === 0 ||
          description.trim().length === 0
        }
        icon="check"
        color="good"
        content="ОК"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => {
          modalAnswer(context, modal.id, '', {
            author: author,
            name: name.substr(0, 127),
            description: description.substr(0, 511),
            admin_locked: adminLocked ? 1 : 0,
          });
        }}
      />
    </Section>
  );
};

modalRegisterBodyOverride('create_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('manage_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('create_story', createStoryModalBodyOverride);
modalRegisterBodyOverride('wanted_notice', wantedNoticeModalBodyOverride);
