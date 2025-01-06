import { classes } from 'common/react';

import { useBackend } from '../../backend';
import { Box, Button, Section } from '../../components';
import { PodLauncherData } from './types';

export const StylePage = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const { effectName, styleChoice, podStyles } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          icon="edit"
          onClick={() => act('effectName')}
          selected={effectName}
          tooltip={`
            Edit pod's
            .id/desc.`}
          tooltipPosition="bottom-start"
        >
          Имя
        </Button>
      }
      fill
      scrollable
      title="Стиль"
    >
      {podStyles.map((page, i) => (
        <Button
          height="45px"
          key={page.id}
          onClick={() => act('setStyle', { style: page.id })}
          selected={styleChoice === page.id}
          style={{
            'vertical-align': 'middle',
            'margin-right': '5px',
            'border-radius': '20px',
          }}
          tooltipPosition={
            i >= podStyles.length - 2
              ? i % 2 === 1
                ? 'top-start'
                : 'top-end'
              : i % 2 === 1
                ? 'bottom-start'
                : 'bottom-end'
          }
          tooltip={page.title}
          width="45px"
        >
          <Box
            className={classes(['supplypods64x64', 'pod_asset' + page.id])}
            style={{
              'pointer-events': 'none',
              'transform': 'rotate(45deg) translate(-25%,-10%)',
            }}
          />
        </Button>
      ))}
    </Section>
  );
};
