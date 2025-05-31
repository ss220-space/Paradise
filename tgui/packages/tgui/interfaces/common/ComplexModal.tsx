import { ReactNode, KeyboardEvent } from 'react';
import { useBackend } from '../../backend';
import {
  Box,
  Button,
  Dropdown,
  Stack,
  Input,
  Modal,
  Image,
} from '../../components';

import { type ModalProps } from '../../components/Modal';

let bodyOverrides = {};

/**
 * Sends a call to BYOND to open a modal
 * @param {string} id The identifier of the modal
 * @param {object=} args The arguments to pass to the modal
 */
export const modalOpen = (id: string, args?: object) => {
  const { act, data } = useBackend<ModalData>();
  const newArgs = Object.assign(data.modal ? data.modal.args : {}, args || {});

  act('modal_open', {
    id: id,
    arguments: JSON.stringify(newArgs),
  });
};

/**
 * Registers an override for any modal with the given id
 * @param {string} id The identifier of the modal
 * @param {function} bodyOverride The override function that returns the
 *    modal contents
 */
export const modalRegisterBodyOverride = (
  id: string,
  bodyOverride: (modal: ModalType<any>) => ReactNode
) => {
  bodyOverrides[id] = bodyOverride;
};

export const modalAnswer = (
  id: string,
  answer: string | number,
  args?: object
) => {
  const { act, data } = useBackend<ModalData>();
  if (!data.modal) {
    return;
  }

  const newArgs = Object.assign(data.modal.args || {}, args || {});
  act('modal_answer', {
    id: id,
    answer: answer,
    arguments: JSON.stringify(newArgs),
  });
};

export const modalClose = (id?: string) => {
  const { act } = useBackend();
  act('modal_close', {
    id: id,
  });
};

type ModalData = {
  modal: ModalType<any>;
};

export type ModalType<T> = {
  id: string;
  text: string;
  args: T;
  type: string;
  value: string | number;
  choices?: object | [];
  no_text?: string;
  yes_text?: string;
};
/**
 * Displays a modal and its actions. Passed data must have a valid modal field
 *
 * **A valid modal field contains:**
 *
 * `id` — The identifier of the modal.
 * Used for server-client communication and overriding
 *
 * `text` — The text of the modal
 *
 * `type` — The type of the modal:
 * `message`, `input`, `choice`, `bento` and `boolean`.
 * Overriden by a body override registered to the identifier if applicable.
 * Defaults to `message` if not found
 * @param {ModalProps} props
 */
export const ComplexModal = (props: ModalProps) => {
  const { data } = useBackend<ModalData>();
  if (!data.modal) {
    return;
  }

  const { id, text, type } = data.modal;

  let modalOnEnter: (e: KeyboardEvent<HTMLInputElement>) => void;
  let modalHeader = (
    <Button
      className="Button--modal"
      icon="arrow-left"
      onClick={() => modalClose(id)}
    >
      Закрыть
    </Button>
  );
  let modalBody: ReactNode;
  let modalFooter: ReactNode;
  let overflowY = 'auto';

  // Different contents depending on the type
  if (bodyOverrides[id]) {
    modalBody = bodyOverrides[id](data.modal);
  } else if (type === 'input') {
    let curValue = data.modal.value;
    modalOnEnter = (e) => modalAnswer(id, curValue);
    modalBody = (
      <Input
        value={data.modal.value}
        placeholder="ENTER для подтверждения"
        width="100%"
        my="0.5rem"
        autoFocus
        onChange={(_e, val) => {
          curValue = val;
        }}
      />
    );
    modalFooter = (
      <Box mt="0.5rem">
        <Button icon="arrow-left" color="grey" onClick={() => modalClose(id)}>
          Закрыть
        </Button>
        <Button
          icon="check"
          color="good"
          style={{ float: 'right' }}
          m="0"
          onClick={() => modalAnswer(id, curValue)}
        >
          Подтвердить
        </Button>
        <Box style={{ clear: 'both' }} />
      </Box>
    );
  } else if (type === 'choice') {
    const realChoices =
      typeof data.modal.choices === 'object'
        ? Object.values(data.modal.choices)
        : data.modal.choices;
    modalBody = (
      <Dropdown
        options={realChoices}
        selected={data.modal.value as string}
        width="100%"
        my="0.5rem"
        onSelected={(val) => modalAnswer(id, val)}
      />
    );
    overflowY = 'initial';
  } else if (type === 'bento') {
    modalBody = (
      <Stack wrap="wrap" my="0.5rem" maxHeight="1%">
        {(data.modal.choices as []).map((c, i) => (
          <Stack.Item key={i} style={{ flex: '1 1 auto' }}>
            <Button
              selected={i + 1 === parseInt(data.modal.value as string, 10)}
              onClick={() => modalAnswer(id, i + 1)}
            >
              <Image src={c} />
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    );
  } else if (type === 'boolean') {
    modalFooter = (
      <Box mt="0.5rem">
        <Button
          icon="times"
          color="bad"
          style={{ float: 'left' }}
          mb="0"
          onClick={() => modalAnswer(id, 0)}
        >
          {data.modal.no_text}
        </Button>
        <Button
          icon="check"
          color="good"
          style={{ float: 'right' }}
          m="0"
          onClick={() => modalAnswer(id, 1)}
        >
          {data.modal.yes_text}
        </Button>
        <Box style={{ clear: 'both' }} />
      </Box>
    );
  }

  return (
    <Modal
      maxWidth={props.maxWidth || window.innerWidth / 2 + 'px'}
      maxHeight={props.maxHeight || window.innerHeight / 2 + 'px'}
      onEnter={modalOnEnter}
      mx="auto"
      overflowY={overflowY}
      padding-bottom="5px"
    >
      {text && <Box inline>{text}</Box>}
      {bodyOverrides[id] && modalHeader}
      {modalBody}
      {modalFooter}
    </Modal>
  );
};
