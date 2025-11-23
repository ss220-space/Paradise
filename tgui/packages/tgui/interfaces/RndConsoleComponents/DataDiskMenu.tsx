import { useBackend } from '../../backend';
import { Button, LabeledList, Section, Box } from '../../components';
import { RndNavButton, RndRoute } from './index';
import { SUBMENU } from '../RndConsole';

const DISK_TYPE_DESIGN = 'design';
const DISK_TYPE_TECH = 'tech';

type DiskData = {
  lathe_types: string[];
  materials: Material[];
} & ResearchLevel;

type RndDiskData = {
  disk_data: DiskData;
  to_copy: CopyTo;
} & RndData;

type CopyTo = {
  name: string;
  id: string;
} & Record<string, string>[];

const TechSummary = (properties) => {
  const { data, act } = useBackend<RndDiskData>();
  const { disk_data } = data;

  if (!disk_data) {
    return null;
  }

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Name">{disk_data.name}</LabeledList.Item>
        <LabeledList.Item label="Level">{disk_data.level}</LabeledList.Item>
        <LabeledList.Item label="Description">
          {disk_data.desc}
        </LabeledList.Item>
      </LabeledList>
      <Box mt="10px">
        <Button icon="arrow-up" onClick={() => act('updt_tech')}>
          Загрузить в базу данных
        </Button>
        <Button icon="trash" onClick={() => act('clear_tech')}>
          Очистить дискету
        </Button>
        <EjectDisk />
      </Box>
    </Box>
  );
};

// summarize a design disk contents from d_disk
const LatheSummary = (properties) => {
  const { data, act } = useBackend<RndDiskData>();
  const { disk_data } = data;
  if (!disk_data) {
    return null;
  }

  const { name, lathe_types, materials } = disk_data;

  const lathe_types_str = lathe_types.join(', ');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Название">{name}</LabeledList.Item>

        {lathe_types_str ? (
          <LabeledList.Item label="Совместимое оборудование">
            {lathe_types_str}
          </LabeledList.Item>
        ) : null}

        <LabeledList.Item label="Требуется материалов" />
      </LabeledList>

      {materials.map((mat) => (
        <Box key={mat.name}>
          {'- '}
          <span style={{ textTransform: 'capitalize' }}>{mat.name}</span>
          {' x '}
          {mat.amount}
        </Box>
      ))}

      <Box mt="10px">
        <Button icon="arrow-up" onClick={() => act('updt_design')}>
          Загрузить в базу данных
        </Button>
        <Button icon="trash" onClick={() => act('clear_design')}>
          Очистить дискету
        </Button>
        <EjectDisk />
      </Box>
    </Box>
  );
};

const EmptyDisk = (properties) => {
  const { data } = useBackend<RndDiskData>();
  const { disk_type } = data;
  return (
    <Box>
      <Box>Дискета пуста.</Box>
      <Box mt="10px">
        <RndNavButton
          submenu={SUBMENU.DISK_COPY}
          icon="arrow-down"
          content={
            disk_type === DISK_TYPE_TECH
              ? 'Загрузить тех. данные на дискету'
              : 'Загрузить шаблон печати на дискету'
          }
        />
        <EjectDisk />
      </Box>
    </Box>
  );
};

const EjectDisk = (properties) => {
  const { data, act } = useBackend<RndDiskData>();
  const { disk_type } = data;

  if (!disk_type) {
    return null;
  }

  return (
    <Button
      icon="eject"
      onClick={() => {
        const action =
          disk_type === DISK_TYPE_TECH ? 'eject_tech' : 'eject_design';
        act(action);
      }}
    >
      Извлечь дискету
    </Button>
  );
};

const ContentsSubmenu = (properties) => {
  const {
    data: { disk_data, disk_type },
  } = useBackend<RndDiskData>();

  const body = () => {
    if (!disk_data) {
      return <EmptyDisk />;
    }
    switch (disk_type) {
      case DISK_TYPE_DESIGN:
        return <LatheSummary />;
      case DISK_TYPE_TECH:
        return <TechSummary />;
      default:
        return null;
    }
  };

  return <Section title="Содержимое дискеты">{body()}</Section>;
};

const CopySubmenu = (properties) => {
  const { data, act } = useBackend<RndDiskData>();
  const { disk_type, to_copy } = data;

  return (
    <Section>
      <Box overflowY="auto" overflowX="hidden" maxHeight="450px">
        <LabeledList>
          {to_copy
            .sort((a, b) => a.name.localeCompare(b.name))
            .map(({ name, id }) => (
              <LabeledList.Item label={name} key={id}>
                <Button
                  icon="arrow-down"
                  onClick={() => {
                    if (disk_type === DISK_TYPE_TECH) {
                      act('copy_tech', { id });
                    } else {
                      act('copy_design', { id });
                    }
                  }}
                >
                  Копировать на дискету
                </Button>
              </LabeledList.Item>
            ))}
        </LabeledList>
      </Box>
    </Section>
  );
};

export const DataDiskMenu = (properties) => {
  const { data } = useBackend<RndDiskData>();
  const { disk_type } = data;

  if (!disk_type) {
    return null; // can't access menu without a disk
  }

  return (
    <>
      <RndRoute submenu={SUBMENU.MAIN} render={() => <ContentsSubmenu />} />
      <RndRoute submenu={SUBMENU.DISK_COPY} render={() => <CopySubmenu />} />
    </>
  );
};
