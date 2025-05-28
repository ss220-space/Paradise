/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { useState } from 'react';
import { Button, ByondUi, Section, TextArea } from '../components';
import { logger } from 'common/logging';

export const meta = {
  title: 'ByondUi',
  render: () => <Story />,
};

const Story = (props: unknown) => {
  const [code, setCode] = useState<string>(
    `Byond.winset('${Byond.windowId}', {\n 'is-visible': true,\n})`
  );
  return (
    <>
      <Section title="Button">
        <ByondUi
          params={{
            type: 'button',
            text: 'Button',
          }}
        />
      </Section>
      <Section
        title="Make BYOND calls"
        buttons={
          <Button
            icon="chevron-right"
            onClick={() =>
              setTimeout(() => {
                try {
                  const result = new Function('return (' + code + ')')();
                  if (result && result.then) {
                    logger.log('Promise');
                    result.then(logger.log);
                  } else {
                    logger.log(result);
                  }
                } catch (err) {
                  logger.log(err);
                }
              })
            }
          >
            Evaluate
          </Button>
        }
      >
        <TextArea
          width="100%"
          height="10em"
          value={code}
          onChange={(e, value) => setCode(value)}
        />
      </Section>
    </>
  );
};
