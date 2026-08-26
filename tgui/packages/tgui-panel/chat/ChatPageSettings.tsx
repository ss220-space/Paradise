/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'tgui/backend';
import {
  Button,
  Collapsible,
  Divider,
  Input,
  Section,
  Stack,
} from 'tgui/components';

import {
  moveChatPageLeft,
  moveChatPageRight,
  removeChatPage,
  toggleAcceptedType,
  updateChatPage,
} from './actions';
import { MESSAGE_TYPES } from './constants';
import { selectCurrentChatPage } from './selectors';

export const ChatPageSettings = (props: unknown) => {
  const page = useSelector(selectCurrentChatPage);
  const dispatch = useDispatch();
  return (
    <Section>
      <Stack align="center">
        {!page.isMain && (
          <Stack.Item>
            <Button
              color="blue"
              icon="angles-left"
              tooltip="Переместить вкладку влево"
              onClick={() =>
                dispatch(
                  moveChatPageLeft({
                    pageId: page.id,
                  })
                )
              }
            />
          </Stack.Item>
        )}
        <Stack.Item grow ml={0.5}>
          <Input
            width="100%"
            value={page.name}
            onChange={(value) =>
              dispatch(
                updateChatPage({
                  pageId: page.id,
                  name: value,
                })
              )
            }
          />
        </Stack.Item>
        {!page.isMain && (
          <Stack.Item ml={0.5}>
            <Button
              color="blue"
              icon="angles-right"
              tooltip="Переместить вкладку вправо"
              onClick={() =>
                dispatch(
                  moveChatPageRight({
                    pageId: page.id,
                  })
                )
              }
            />
          </Stack.Item>
        )}
        <Stack.Item>
          <Button.Checkbox
            checked={page.hideUnreadCount}
            icon={page.hideUnreadCount ? 'bell-slash' : 'bell'}
            tooltip="Отключить счетчик непрочитанных сообщений"
            onClick={() =>
              dispatch(
                updateChatPage({
                  pageId: page.id,
                  hideUnreadCount: !page.hideUnreadCount,
                })
              )
            }
          >
            Заглушить
          </Button.Checkbox>
        </Stack.Item>
        {!page.isMain && (
          <Stack.Item>
            <Button
              color="red"
              icon="times"
              onClick={() =>
                dispatch(
                  removeChatPage({
                    pageId: page.id,
                  })
                )
              }
            >
              Удалить
            </Button>
          </Stack.Item>
        )}
      </Stack>
      <Divider />
      <Section title="Сообщения для отображения">
        {MESSAGE_TYPES.filter(
          (typeDef) => !typeDef.important && !typeDef.admin
        ).map((typeDef) => (
          <Button.Checkbox
            key={typeDef.type}
            tooltip={typeDef.description}
            checked={page.acceptedTypes[typeDef.type]}
            onClick={() =>
              dispatch(
                toggleAcceptedType({
                  pageId: page.id,
                  type: typeDef.type,
                })
              )
            }
          >
            {typeDef.name}
          </Button.Checkbox>
        ))}
        <Collapsible mt={1} color="transparent" title="Админ. вкладки">
          {MESSAGE_TYPES.filter(
            (typeDef) => !typeDef.important && typeDef.admin
          ).map((typeDef) => (
            <Button.Checkbox
              key={typeDef.type}
              tooltip={typeDef.description}
              checked={page.acceptedTypes[typeDef.type]}
              onClick={() =>
                dispatch(
                  toggleAcceptedType({
                    pageId: page.id,
                    type: typeDef.type,
                  })
                )
              }
            >
              {typeDef.name}
            </Button.Checkbox>
          ))}
        </Collapsible>
      </Section>
    </Section>
  );
};
