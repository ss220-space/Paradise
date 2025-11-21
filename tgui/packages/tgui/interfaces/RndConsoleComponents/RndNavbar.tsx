import { RndRoute, RndNavButton } from './index';
import { Box } from '../../components';
import { MENU, SUBMENU } from '../RndConsole';

export const RndNavbar = () => (
  <Box className="RndConsole__RndNavbar">
    <RndRoute
      menu={(n) => n !== MENU.MAIN}
      render={() => (
        <RndNavButton menu={MENU.MAIN} submenu={SUBMENU.MAIN} icon="reply">
          Main Menu
        </RndNavButton>
      )}
    />

    {/* Links to return to submenu 0 for each menu other than main menu */}
    <RndRoute
      submenu={(n) => n !== SUBMENU.MAIN}
      render={() => (
        <Box>
          <RndRoute
            menu={MENU.DISK}
            render={() => (
              <RndNavButton submenu={SUBMENU.MAIN} icon="reply">
                Disk Operations Menu
              </RndNavButton>
            )}
          />

          <RndRoute
            menu={MENU.LATHE}
            render={() => (
              <RndNavButton submenu={SUBMENU.MAIN} icon="reply">
                Protolathe Menu
              </RndNavButton>
            )}
          />

          <RndRoute
            menu={MENU.IMPRINTER}
            render={() => (
              <RndNavButton submenu={SUBMENU.MAIN} icon="reply">
                Circuit Imprinter Menu
              </RndNavButton>
            )}
          />

          <RndRoute
            menu={MENU.SETTINGS}
            render={() => (
              <RndNavButton submenu={SUBMENU.MAIN} icon="reply">
                Settings Menu
              </RndNavButton>
            )}
          />
        </Box>
      )}
    />

    <RndRoute
      menu={(n) => n === MENU.LATHE || n === MENU.IMPRINTER}
      submenu={SUBMENU.MAIN}
      render={() => (
        <Box>
          <RndNavButton submenu={SUBMENU.LATHE_MAT_STORAGE} icon="arrow-up">
            Material Storage
          </RndNavButton>
          <RndNavButton submenu={SUBMENU.LATHE_CHEM_STORAGE} icon="arrow-up">
            Chemical Storage
          </RndNavButton>
        </Box>
      )}
    />
  </Box>
);
