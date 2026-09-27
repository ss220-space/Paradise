import { useBackend } from '../backend';
import { Box, Icon, Section, Stack } from 'tgui-core/components';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = 'Данных нет. Спросите совета, если он нужен.';

const HELP_TOPICS = [
  {
    color: 'purple',
    icon: 'search-location',
    title: 'Разведка',
    text: 'Осмотритесь и поймите, что нужно сделать, чтобы добыть ящик. Читайте описание домена и обращайте внимание на детали вокруг.',
  },
  {
    color: 'green',
    icon: 'boxes',
    title: 'Доставка',
    text: 'Ящик нужно принести на площадку выдачи в убежище. Она выбивается из окружения — осмотрите убежище, и вы её найдёте.',
  },
  {
    color: 'blue',
    icon: 'plug',
    title: 'Отключение',
    text: 'Голографическая лестница — самый безопасный способ отключиться до того, как ящик добыт. Если связь оборвётся сама, нетпод сможет вас откачать, но далеко не всегда.',
  },
  {
    color: 'yellow',
    icon: 'id-badge',
    title: 'Безопасность',
    text: 'Пока вы подключены, окружение домена вредит вам не в полную силу — но вредит. Следите за оповещениями.',
  },
  {
    color: 'gold',
    icon: 'coins',
    title: 'Попытки',
    text: 'Каждый аватар стоит серверу огромной пропускной способности. Не разбрасывайтесь ими.',
  },
  {
    color: 'red',
    icon: 'skull-crossbones',
    title: 'Настоящая опасность',
    text: 'Помните: вы физически связаны с этим телом. Вы чужеродный код во враждебной среде, и она будет выдавливать вас силой.',
  },
] as const;

export const AvatarHelp = (_props) => {
  const { data } = useBackend<Data>();
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Добро пожаловать в виртуальный домен"
            >
              {help_text}
            </Section>
          </Stack.Item>
          <Stack.Item grow={4}>
            <Stack fill vertical>
              {[0, 2, 4].map((row) => (
                <Stack.Item grow key={row}>
                  <Stack fill>
                    {[row, row + 1].map((index) => (
                      <HelpTopic index={index} key={index} />
                    ))}
                  </Stack>
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const HelpTopic = (props: { index: number }) => {
  const topic = HELP_TOPICS[props.index];

  return (
    <Stack.Item grow>
      <Section
        color="label"
        fill
        minHeight={10}
        title={
          <Stack align="center">
            <Icon color={topic.color} mr={1} name={topic.icon} />
            <Box>{topic.title}</Box>
          </Stack>
        }
      >
        {topic.text}
      </Section>
    </Stack.Item>
  );
};
