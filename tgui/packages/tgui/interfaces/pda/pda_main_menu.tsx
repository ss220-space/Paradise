import { useBackend } from '../../backend';
import { Box, Section } from '../../components';

type MainMenuData = {
  owner: string;
  ownjob: string;
  idInserted: boolean;
  categories: string[];
  notifying: string[];
  apps: Record<string, App[]>;
};

type App = {
  name: string;
  uid: string;
  notify_icon: string;
  icon: string;
};

const AppIcon = ({ app, isNotifying, onClick }) => {
  const iconName = (isNotifying ? app.notify_icon : app.icon) || 'cube';

  return (
    <Box
      onClick={onClick}
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        width: '64px',
        cursor: 'pointer',
      }}
    >
      <Box
        style={{
          width: '52px',
          height: '52px',
          borderRadius: '14px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: '#1f2a3a',
        }}
      >
        <i
          className={`fa fa-${iconName}`}
          style={{
            fontSize: '20px',
            color: '#fff',
          }}
        />
      </Box>

      <Box
        style={{
          fontSize: '10px',
          color: '#ddd',
          marginTop: '6px',
          textAlign: 'center',
        }}
      >
        {app.name}
      </Box>
    </Box>
  );
};

const CategoryGrid = ({
  name,
  apps,
  notifying,
  onStart,
}: {
  name: string;
  apps: App[];
  notifying: string[];
  onStart: (uid: string) => void;
}) => {
  if (!apps?.length) return null;

  return (
    <Section title={name} mb={2}>
      <Box
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(5, 1fr)', // 🔥 максимум 5
          gap: '12px 8px',
          justifyItems: 'center',
          padding: '10px 6px',
        }}
      >
        {apps.map((app) => (
          <AppIcon
            key={app.uid}
            app={app}
            isNotifying={notifying.includes(app.uid)}
            onClick={() => onStart(app.uid)}
          />
        ))}
      </Box>
    </Section>
  );
};

export const pda_main_menu = () => {
  const { act, data } = useBackend<MainMenuData>();
  const { owner, ownjob, categories, notifying, apps } = data;

  return (
    <Box style={{ padding: '10px' }}>
      {/* USER */}
      <Box
        style={{
          marginBottom: '10px',
          padding: '10px',
          background: '#1a1f2b',
          borderRadius: '10px',
        }}
      >
        <Box bold>{owner}</Box>
        <Box style={{ fontSize: '11px', color: '#888' }}>{ownjob}</Box>
      </Box>

      {/* APPS */}
      {categories.length === 0 ? (
        <Box style={{ textAlign: 'center', color: '#666', padding: '40px' }}>
          No apps
        </Box>
      ) : (
        categories.map((cat) => (
          <CategoryGrid
            key={cat}
            name={cat}
            apps={apps[cat]}
            notifying={notifying}
            onStart={(uid) => act('StartProgram', { program: uid })}
          />
        ))
      )}
    </Box>
  );
};
