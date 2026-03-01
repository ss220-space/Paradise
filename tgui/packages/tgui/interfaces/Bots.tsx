import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Access, AccessList } from './common/AccessList';

export type BotsData = {
  accesses: number[];
  regions: Access[];
};

export const Bots = () => {
  const { act, data } = useBackend<BotsData>();
  const { accesses, regions } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <AccessList
          accesses={regions}
          selectedList={accesses}
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
