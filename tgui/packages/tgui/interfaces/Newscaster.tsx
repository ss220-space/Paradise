import { BooleanLike, classes } from 'common/react';
import { useBackend } from '../backend';
import React, { CSSProperties, ReactNode, useState } from 'react';
import {
  Box,
  Button,
  Divider,
  Dropdown,
  Icon,
  Input,
  Image,
  LabeledList,
  Modal,
  Section,
  Stack,
  TextArea,
} from '../components';
import { timeAgo } from '../constants';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalAnswer,
  modalClose,
  modalOpen,
  modalRegisterBodyOverride,
  ModalType,
} from './common/ComplexModal';
import { TemporaryNotice } from './common/TemporaryNotice';
import { BoxProps } from '../components/Box';

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

type NewscasterData = {
  is_security: boolean;
  is_admin: boolean;
  is_silent: boolean;
  is_printing: boolean;
  screen: number;
  channels: Chanel[];
  channel_idx?: number;
  channel_can_manage: boolean;
  world_time: number;
  wanted: StoryData;
  stories: StoryData[];
  photo: Photo;
  jobs: Record<string, number[]>;
};

type Chanel = {
  unread: number;
  icon: string;
  name: string;
  uid: string;
  admin: boolean;
  description: string;
  author: string;
  public: boolean;
  censored: boolean;
  frozen: boolean;
};

type Photo = {
  name: string;
  uid: string;
};

type CensorModeProps = Partial<{
  censorMode: boolean;
  setCensorMode: React.Dispatch<React.SetStateAction<boolean>>;
}>;

type FullStoriesProps = Partial<{
  fullStories: string[];
  setFullStories: React.Dispatch<React.SetStateAction<string[]>>;
}>;

export const Newscaster = (properties) => {
  const { act, data } = useBackend<NewscasterData>();
  const {
    is_security,
    is_admin,
    is_silent,
    is_printing,
    screen,
    channels,
    channel_idx = -1,
  } = data;
  const [menuOpen, setMenuOpen] = useState(false);
  const [viewingPhoto, _setViewingPhoto] = useState('');
  const [censorMode, setCensorMode] = useState(false);
  const [fullStories, setFullStories] = useState([]);
  let body: ReactNode;
  if (screen === 0 || screen === 2) {
    body = (
      <NewscasterFeed
        censorMode={censorMode}
        fullStories={fullStories}
        setFullStories={setFullStories}
      />
    );
  } else if (screen === 1) {
    body = (
      <NewscasterJobs
        censorMode={censorMode}
        fullStories={fullStories}
        setFullStories={setFullStories}
      />
    );
  }
  const totalUnread = channels.reduce((a, c) => a + c.unread, 0);
  return (
    <Window theme={is_security && 'security'} width={800} height={600}>
      {viewingPhoto ? (
        <PhotoZoom />
      ) : (
        <ComplexModal maxWidth={50} maxHeight={70} />
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
                    key={channel.uid}
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
                      onClick={() => modalOpen('wanted_notice')}
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
                  onClick={() => modalOpen('create_story')}
                />
                <MenuButton
                  icon="plus-circle"
                  title="Новый канал"
                  onClick={() => modalOpen('create_channel')}
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

type MenuButtonProps = Partial<{
  icon: string;
  iconSpin: BooleanLike;
  selected: boolean;
  security: boolean;
  onClick: () => void;
  title: string;
  children: ReactNode;
}> &
  BoxProps;

const MenuButton = (properties: MenuButtonProps) => {
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
      <Icon name={icon} spin={iconSpin} size={2} />
      <Box className="Newscaster__menuButton--title">{title}</Box>
      {children}
    </Box>
  );
};

const NewscasterFeed = (properties: CensorModeProps & FullStoriesProps) => {
  const { act, data } = useBackend<NewscasterData>();
  const {
    screen,
    is_admin,
    channel_idx,
    channel_can_manage,
    channels,
    stories,
    wanted,
  } = data;
  const { censorMode, fullStories, setFullStories } = properties;

  const channel =
    screen === 2 && channel_idx > -1 ? channels[channel_idx - 1] : null;
  return (
    <Stack fill vertical>
      {!!wanted && (
        <Story
          story={wanted}
          wanted
          censorMode={censorMode}
          fullStories={fullStories}
          setFullStories={setFullStories}
        />
      )}
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
                      story.body.substring(0, HEADLINE_MAX_LENGTH - 4) + '...',
                  }
                : story
            )
            .map((story, index) => (
              <Story
                key={index}
                story={story}
                censorMode={censorMode}
                fullStories={fullStories}
                setFullStories={setFullStories}
              />
            ))
        ) : (
          <Box className="Newscaster__emptyNotice">
            <Icon name="times" size={3} />
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
                  icon={channel.censored ? 'comment' : 'ban'}
                  backgroundColor={!channel.censored && 'red'}
                  mr="0.5rem"
                  tooltip={
                    !channel.censored
                      ? 'Заблокировать канал'
                      : 'Разблокировать канал'
                  }
                  onClick={() => act('censor_channel', { uid: channel.uid })}
                />
              )}
              <Button
                disabled={!channel_can_manage}
                icon="cog"
                onClick={() =>
                  modalOpen('manage_channel', {
                    uid: channel.uid,
                  })
                }
              >
                Управление
              </Button>
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

const NewscasterJobs = (properties: FullStoriesProps & CensorModeProps) => {
  const { data } = useBackend<NewscasterData>();
  const { jobs, wanted } = data;
  const numOpenings = Object.entries(jobs).reduce(
    (a, [k, v]) => a + v.length,
    0
  );
  const { censorMode, fullStories, setFullStories } = properties;
  return (
    <Stack fill vertical>
      {!!wanted && (
        <Story
          censorMode={censorMode}
          fullStories={fullStories}
          setFullStories={setFullStories}
          story={wanted}
          wanted
        />
      )}
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
                    className={classes([
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
            <Icon name="times" size={3} />
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

export type StoryData = {
  censor_flags: number;
  title: string;
  uid: string;
  author: string;
  view_count: number;
  publish_time: number;
  has_photo: boolean;
  body: string;
  body_short: string;
  admin_locked: boolean;
  photo?: boolean;
};

type StoryProps = {
  story: StoryData;
  wanted?: boolean;
} & FullStoriesProps &
  CensorModeProps;

const Story = (properties: StoryProps) => {
  const { act, data } = useBackend<NewscasterData>();
  const { story, wanted = false } = properties;
  const { censorMode, fullStories, setFullStories } = properties;
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
                  disabled={!!story.admin_locked && !data.is_admin}
                  icon={story.censor_flags & 2 ? 'comment' : 'ban'}
                  backgroundColor={!(story.censor_flags & 2) && 'red'}
                  mr="0.5rem"
                  mt="-0.25rem"
                  tooltip={
                    story.censor_flags & 2 ? 'Разблокировать' : 'Заблокировать'
                  }
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
                style={{ float: 'right', marginLeft: '0.5rem' }}
              />
            )}
            {(story.body_short || story.body).split('\n').map((p, index) => (
              <Box key={index}>{p || <br />}</Box>
            ))}
            {story.body_short && (
              <Button
                mt="0.5rem"
                onClick={() => setFullStories([...fullStories, story.uid])}
              >
                Читать далее..
              </Button>
            )}
            <Box style={{ clear: 'right' }} />
          </>
        )}
      </Box>
    </Section>
  );
};

type PhotoThumbnailProps = {
  name: string;
  style: CSSProperties;
};

export const PhotoThumbnail = (properties: PhotoThumbnailProps) => {
  const { name, ...rest } = properties;
  const [viewingPhoto, setViewingPhoto] = useState('');
  return (
    <img
      className="Newscaster__photo"
      src={name}
      onClick={() => setViewingPhoto(name)}
      {...rest}
    />
  );
};

const PhotoZoom = (properties) => {
  const [viewingPhoto, setViewingPhoto] = useState('');
  return (
    <Modal className="Newscaster__photoZoom">
      <Image src={viewingPhoto} />
      <Button
        icon="times"
        color="grey"
        mt="1rem"
        onClick={() => setViewingPhoto('')}
      >
        Закрыть
      </Button>
    </Modal>
  );
};

type ManageChannelModalArgs = {
  uid: string;
  is_admin: boolean;
  scanned_user: string;
};
// This handles both creation and editing
const manageChannelModalBodyOverride = (
  modal: ModalType<ManageChannelModalArgs>
) => {
  const { data } = useBackend<NewscasterData>();
  // Additional data
  const channel =
    !!modal.args.uid &&
    data.channels.filter((c) => c.uid === modal.args.uid).pop();
  if (modal.id === 'manage_channel' && !channel) {
    modalClose(); // ?
    return;
  }
  const isEditing = modal.id === 'manage_channel';
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useState(
    channel?.author || scannedUser || 'Неавторизованный'
  );
  const [name, setName] = useState(channel?.name || '');
  const [description, setDescription] = useState(channel?.description || '');
  const [icon, setIcon] = useState(channel?.icon || 'newspaper');
  const [isPublic, setIsPublic] = useState(
    isEditing ? !!channel?.public : false
  );
  const [adminLocked, setAdminLocked] = useState(channel?.admin || false);
  return (
    <Section
      m="-1rem"
      pb="1.5rem"
      title={isEditing ? 'Управление: ' + channel.name : 'Создать новый канал'}
    >
      <Stack vertical mx="0.5rem">
        <Stack.Item>
          <LabeledList.Item label="Владелец">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onChange={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Название">
            <Input
              width="100%"
              placeholder="Макс. 50 символов"
              maxLength={50}
              value={name}
              onChange={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <Stack.Item>
            <LabeledList.Item label="Описание (опционально)" />
          </Stack.Item>
          <Stack.Item>
            <TextArea
              width="100%"
              placeholder="Макс. 128 символов."
              maxLength={128}
              height={10}
              value={description}
              onChange={(_e, v) => setDescription(v)}
            />
          </Stack.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Иконка">
            <Input
              overflowX="visible"
              disabled={!isAdmin}
              value={icon}
              mr="0.5rem"
              onChange={(_e, v) => setIcon(v)}
            />
            <Icon name={icon} size={2} verticalAlign="middle" mr="0.5rem" />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Сделать канал публичным?">
            <Button
              selected={isPublic}
              width={4}
              icon={isPublic ? 'toggle-on' : 'toggle-off'}
              onClick={() => setIsPublic(!isPublic)}
            >
              {isPublic ? 'Да' : 'Нет'}
            </Button>
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                tooltip="Блокировка этого канала сделает его доступным для редактирования только для сотрудников CentComm."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              >
                {adminLocked ? 'Вкл' : 'Выкл'}
              </Button>
            </LabeledList.Item>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            disabled={author.trim().length === 0 || name.trim().length === 0}
            icon="check"
            color="good"
            position="absolute"
            right={1}
            bottom="-0.75rem"
            onClick={() => {
              modalAnswer(modal.id, '', {
                author: author,
                name: name.substr(0, 49),
                description: description.substr(0, 128),
                icon: icon,
                public: isPublic ? 1 : 0,
                admin_locked: adminLocked ? 1 : 0,
              });
            }}
          >
            Создать
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const createStoryModalBodyOverride = (
  modal: ModalType<ManageChannelModalArgs>
) => {
  const { act, data } = useBackend<NewscasterData>();
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
  const [author, setAuthor] = useState(scannedUser || 'Unknown');
  const [channel, setChannel] = useState(
    availableChannels.length > 0 ? availableChannels[0].name : ''
  );
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [adminLocked, setAdminLocked] = useState(false);
  return (
    <Section m="-1rem" pb="1.5rem" title="Написать новую статью">
      <Stack vertical mx="0.5rem">
        <Stack.Item>
          <LabeledList.Item label="Автор">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onChange={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Канал" verticalAlign="top">
            <Dropdown
              selected={channel}
              options={availableChannels.map((c) => c.name)}
              mb="0"
              width="100%"
              onSelected={(c) => setChannel(c)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Divider />
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Заголовок">
            <Input
              width="100%"
              placeholder="Макс. 128 символов"
              maxLength={128}
              value={title}
              onChange={(_e, v) => setTitle(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <Stack.Item>
            <LabeledList.Item label="Текст статьи" verticalAlign="top" />
          </Stack.Item>
          <Stack.Item>
            <TextArea
              fluid
              placeholder="Макс. 1024 символов"
              maxLength={1024}
              width="100%"
              height={10}
              value={body}
              onChange={(_e, v) => setBody(v)}
            />
          </Stack.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Фото (опционально)" verticalAlign="top">
            <Button
              icon="image"
              selected={!!photo}
              tooltip={
                !photo && 'Приложите фото к этой статье, держа ее в руке.'
              }
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            >
              {photo ? 'Достать: ' + photo.name : 'Вставить фото'}
            </Button>
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item mt={3}>
          <Stack vertical>
            <Stack.Item>
              <Section
                noTopPadding
                title={title}
                maxHeight="13.5rem"
                overflow="auto"
                style={{
                  border: '1px solid #3a3a3a',
                  boxShadow: '0 0 8px #3a3a3a',
                  borderRadius: '4px',
                }}
              >
                <Box mt="0.5rem">
                  {!!photo && (
                    <PhotoThumbnail
                      name={'inserted_photo_' + photo.uid + '.png'}
                      style={{ float: 'right' }}
                    />
                  )}
                  {body.split('\n').map((p, index) => (
                    <Box key={index}>{p || <br />}</Box>
                  ))}
                  <Box style={{ clear: 'right' }} />
                </Box>
              </Section>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock' : 'lock-open'}
                tooltip="Публикация этой статьи сделает ее недоступной для цензуры никем, кроме сотрудников CentComm."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              >
                {adminLocked ? 'Вкл' : 'Выкл'}
              </Button>
            </LabeledList.Item>
          )}
        </Stack.Item>
        <Stack.Item>
          <Button.Confirm
            disabled={
              author.trim().length === 0 ||
              channel.trim().length === 0 ||
              title.trim().length === 0 ||
              body.trim().length === 0
            }
            icon="check"
            color="good"
            position="absolute"
            right="1rem"
            bottom="-0.75rem"
            onClick={() => {
              modalAnswer('create_story', '', {
                author: author,
                channel: channel,
                title: title.substr(0, 127),
                body: body.substr(0, 1023),
                admin_locked: adminLocked ? 1 : 0,
              });
            }}
          >
            Создать
          </Button.Confirm>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const wantedNoticeModalBodyOverride = (
  modal: ModalType<ManageChannelModalArgs>
) => {
  const { act, data } = useBackend<NewscasterData>();
  const { photo, wanted } = data;
  // Additional data
  const isAdmin = !!modal.args.is_admin;
  const scannedUser = modal.args.scanned_user;
  // Temp data
  const [author, setAuthor] = useState(
    wanted?.author || scannedUser || 'Неавторизованный'
  );
  const [name, setName] = useState(wanted?.title.substring(8) || '');
  const [description, setDescription] = useState(wanted?.body || '');
  const [adminLocked, setAdminLocked] = useState(wanted?.admin_locked || false);
  return (
    <Section m="-1rem" pb="1.5rem" title="Уведомлением о розыске">
      <Stack vertical mx="0.5rem">
        <Stack.Item>
          <LabeledList.Item label="Authority">
            <Input
              disabled={!isAdmin}
              width="100%"
              value={author}
              onChange={(_e, v) => setAuthor(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Имя">
            <Input
              width="100%"
              value={name}
              maxLength={128}
              onChange={(_e, v) => setName(v)}
            />
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Описание" verticalAlign="top" />
          <TextArea
            width="100%"
            value={description}
            height={10}
            maxLength={512}
            onChange={(_e, v) => setDescription(v)}
          />
        </Stack.Item>
        <Stack.Item>
          <LabeledList.Item label="Фото (опционально)" verticalAlign="top">
            <Button
              icon="image"
              selected={!!photo}
              tooltip={
                !photo && 'Приложите фото к этой статье, держа ее в руке.'
              }
              tooltipPosition="top"
              onClick={() => act(photo ? 'eject_photo' : 'attach_photo')}
            >
              {photo ? 'Достать: ' + photo.name : 'Вставить фото'}
            </Button>
          </LabeledList.Item>
        </Stack.Item>
        <Stack.Item>
          {!!photo && (
            <PhotoThumbnail
              name={'inserted_photo_' + photo.uid + '.png'}
              style={{ float: 'right' }}
            />
          )}
        </Stack.Item>
        <Stack.Item>
          {isAdmin && (
            <LabeledList.Item label="CentComm Lock" verticalAlign="top">
              <Button
                selected={adminLocked}
                icon={adminLocked ? 'lock-open' : 'lock'}
                backgroundColor={!adminLocked && 'red'}
                tooltip="Заблокировав это уведомление о розыске, никто, кроме сотрудников CentComm, не сможет его редактировать."
                tooltipPosition="top"
                onClick={() => setAdminLocked(!adminLocked)}
              >
                {adminLocked ? 'Вкл' : 'Выкл'}
              </Button>
            </LabeledList.Item>
          )}
        </Stack.Item>
        <Stack.Item>
          <Stack>
            <Stack.Item>
              <Button.Confirm
                disabled={!wanted}
                icon="eraser"
                color="danger"
                position="absolute"
                bottom="-0.75rem"
                onClick={() => {
                  act('clear_wanted_notice');
                  modalClose();
                }}
              >
                Очистить
              </Button.Confirm>
            </Stack.Item>
            <Stack.Item>
              <Button.Confirm
                disabled={
                  author.trim().length === 0 ||
                  name.trim().length === 0 ||
                  description.trim().length === 0
                }
                icon="check"
                color="good"
                position="absolute"
                right="1rem"
                bottom="-0.75rem"
                onClick={() => {
                  modalAnswer(modal.id, '', {
                    author: author,
                    name: name.substring(0, 127),
                    description: description.substr(0, 511),
                    admin_locked: adminLocked ? 1 : 0,
                  });
                }}
              >
                ОК
              </Button.Confirm>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

modalRegisterBodyOverride('create_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('manage_channel', manageChannelModalBodyOverride);
modalRegisterBodyOverride('create_story', createStoryModalBodyOverride);
modalRegisterBodyOverride('wanted_notice', wantedNoticeModalBodyOverride);
