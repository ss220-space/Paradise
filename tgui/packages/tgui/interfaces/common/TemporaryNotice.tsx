import { useBackend } from '../../backend';
import { Box, Button, NoticeBox } from '../../components';

type TemporaryNoticeData = {
  temp: Temp;
};

type Temp = { style: string; text: string };

/**
 * Displays a notice box with text and style dictated by the
 * `temp` data field if it exists.
 *
 * A valid `temp` object contains:
 *
 * - `style` — The style of the NoticeBox
 * - `text` — The text to display
 *
 * Allows clearing the notice through the `cleartemp` TGUI act
 * @param {object} _properties
 */
export const TemporaryNotice = (_properties) => {
  const { act, data } = useBackend<TemporaryNoticeData>();
  const { temp } = data;
  if (!temp) {
    return;
  }
  const temporaryProperty = { [temp.style]: true };
  return (
    <NoticeBox {...temporaryProperty}>
      <Box inline verticalAlign="middle">
        {temp.text}
      </Box>
      <Button
        icon="times-circle"
        style={{ float: 'right' }}
        onClick={() => act('cleartemp')}
      />
      <Box style={{ clear: 'both' }} />
    </NoticeBox>
  );
};
