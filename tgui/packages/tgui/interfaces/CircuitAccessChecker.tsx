import { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Button, LabeledList } from '../components';
import { Window } from '../layouts';
import { Access, AccessList } from './common/AccessList';

type Data = {
  oneAccess: BooleanLike;
  regions: Access[];
  accesses: number[];
};

export const CircuitAccessChecker = (props) => {
  const { act, data } = useBackend<Data>();
  const { oneAccess, regions, accesses } = data;

  return (
    <Window width={420} height={360}>
      <Window.Content>
        <LabeledList>
          <LabeledList.Item label="Требования к доступу">
            <Button
              icon={oneAccess ? 'unlock' : 'lock'}
              onClick={() => act('one_access')}
            >
              {oneAccess ? 'Один' : 'Все'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
        <AccessList
          accesses={regions || []}
          selectedList={accesses || []}
          accessMod={(ref) =>
            act('set', {
              access: ref,
            })
          }
          grantAll={() => act('grant_all')}
          denyAll={() => act('clear_all')}
          grantDep={(ref) =>
            act('grant_region', {
              region: ref,
            })
          }
          denyDep={(ref) =>
            act('deny_region', {
              region: ref,
            })
          }
        />
      </Window.Content>
    </Window>
  );
};
