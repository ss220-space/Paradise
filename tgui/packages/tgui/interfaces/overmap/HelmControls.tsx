import { Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../../backend';
import type { OvermapHelmData } from '../OvermapHelm';
import type { HelmSelection } from './HelmNavigation';
import { overmapKindIcon, overmapKindLabel } from './OvermapChrome';

export const HelmWeapons = () => {
  const { data, act } = useBackend<OvermapHelmData>();
  const weapons = data.weapons || [];
  return (
    <section
      className="HelmWeapons"
      aria-label="Корабельное оружие"
      title="Стрельба"
    >
      <div className="HelmCaption">
        Орудия · {weapons.filter((weapon) => weapon.selected).length} /{' '}
        {weapons.length}
      </div>
      <div
        className="HelmWeapons__list"
        tabIndex={0}
        aria-label="Список оружия"
      >
        {weapons.map((weapon) => (
          <div className="HelmWeapons__row" key={weapon.id}>
            <button
              type="button"
              className={classes([
                'HelmContacts__row',
                'HelmWeapons__select',
                weapon.selected && 'HelmContacts__row--selected',
              ])}
              aria-pressed={!!weapon.selected}
              title={weapon.name}
              onClick={() => act('select_weapon', { id: weapon.id })}
            >
              <Icon name={weapon.selected ? 'square-check' : 'crosshairs'} />
              <span>
                {weapon.name}
                <small>
                  {weapon.arc}° ·{' '}
                  {weapon.cooldown > 0
                    ? `${weapon.cooldown.toFixed(1)} с`
                    : 'готово'}
                </small>
              </span>
            </button>
            {!!weapon.turret && (
              <button
                type="button"
                className={classes([
                  'HelmWeapons__auto',
                  weapon.auto && 'HelmWeapons__auto--on',
                ])}
                aria-pressed={!!weapon.auto}
                aria-label={`Авторежим: ${weapon.name}`}
                title="Автоматическая стрельба турели"
                onClick={() => act('weapon_auto', { id: weapon.id })}
              >
                АВТО
              </button>
            )}
          </div>
        ))}
        {!weapons.length && (
          <div className="OvermapHelmHint">
            Корабельные орудия не обнаружены.
          </div>
        )}
      </div>
    </section>
  );
};

export const HelmContacts = (props: {
  selection: HelmSelection | null;
  onSelect: (selection: HelmSelection) => void;
}) => {
  const { data } = useBackend<OvermapHelmData>();
  const distance = (object: { x: number; y: number; size?: number }) => {
    const offset = Math.max(object.size || 1, 1) / 2 - 0.5;
    return data.self_pos
      ? Math.hypot(
          object.x + offset - data.self_pos[0],
          object.y + offset - data.self_pos[1],
        )
      : 0;
  };
  const contacts = (data.objects || [])
    .filter((object) => !object.is_self)
    .sort((a, b) => distance(a) - distance(b));
  const selected = (object: { id?: string; x: number; y: number }) =>
    props.selection?.kind === 'object' && props.selection.id === object.id;
  return (
    <div className="HelmContacts">
      <div className="HelmCaption">Контакты · {contacts.length}</div>
      <div
        className="HelmContacts__list"
        tabIndex={0}
        aria-label="Список контактов"
      >
        {contacts.map((object) => (
          <button
            key={object.id || `${object.name}-${object.x}-${object.y}`}
            type="button"
            className={classes([
              'HelmContacts__row',
              selected(object) && 'HelmContacts__row--selected',
            ])}
            disabled={!object.id}
            onClick={() =>
              object.id &&
              props.onSelect({
                kind: 'object',
                id: object.id,
                name: object.name,
              })
            }
          >
            <Icon
              name={
                object.distress
                  ? 'triangle-exclamation'
                  : overmapKindIcon(object.kind)
              }
              style={{ color: object.color || undefined }}
            />
            <span title={object.name}>
              {object.destroyed ? <s>{object.name}</s> : object.name}
              <small>
                {object.destroyed
                  ? 'УНИЧТОЖЕН'
                  : selected(object)
                    ? 'ВЫБРАННАЯ ЦЕЛЬ'
                    : object.distress
                      ? 'СИГНАЛ БЕДСТВИЯ'
                      : overmapKindLabel(object.kind)}
              </small>
            </span>
            <em>{distance(object).toFixed(1).replace('.', ',')}</em>
          </button>
        ))}
        {!contacts.length && (
          <div className="OvermapHelmHint">Сенсоры ничего не видят.</div>
        )}
      </div>
    </div>
  );
};
