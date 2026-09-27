import { Button, LabeledList } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type StyleEntry = {
  style: string;
  icon: string;
};

type Species = {
  specimen: string;
};

type AppearanceData = {
  icon_prefix: string;
  change_race: string;
  species: Species[];
  specimen: string;
  change_gender: string;
  gender: string;
  has_gender: string;
  change_eye_color: string;
  change_skin_tone: string;
  change_skin_color: string;
  change_head_accessory_color: string;
  change_hair_color: string;
  change_secondary_hair_color: string;
  change_facial_hair_color: string;
  change_secondary_facial_hair_color: string;
  change_head_marking_color: string;
  change_body_marking_color: string;
  change_tail_marking_color: string;
  change_head_accessory: string;
  head_accessory_styles: StyleEntry[];
  head_accessory_style: string;
  change_hair: string;
  hair_styles: StyleEntry[];
  hair_style: string;
  change_hair_gradient: string;
  change_facial_hair: string;
  facial_hair_styles: StyleEntry[];
  facial_hair_style: string;
  change_head_markings: string;
  head_marking_styles: StyleEntry[];
  head_marking_style: string;
  change_body_markings: string;
  body_marking_styles: StyleEntry[];
  body_marking_style: string;
  change_tail_markings: string;
  tail_marking_styles: StyleEntry[];
  tail_marking_style: string;
  change_body_accessory: string;
  body_accessory_styles: StyleEntry[];
  body_accessory_style: string;
  change_alt_head: string;
  alt_head_styles: StyleEntry[];
  alt_head_style: string;
};

export const AppearanceChanger = (props: unknown) => {
  const { act, data } = useBackend<AppearanceData>();

  const {
    change_race,
    species,
    specimen,
    change_gender,
    gender,
    has_gender,
    change_eye_color,
    change_skin_tone,
    change_skin_color,
    change_head_accessory_color,
    change_hair_color,
    change_secondary_hair_color,
    change_facial_hair_color,
    change_secondary_facial_hair_color,
    change_head_marking_color,
    change_body_marking_color,
    change_tail_marking_color,
    change_head_accessory,
    head_accessory_styles,
    head_accessory_style,
    change_hair,
    hair_styles,
    hair_style,
    change_hair_gradient,
    change_facial_hair,
    facial_hair_styles,
    facial_hair_style,
    change_head_markings,
    head_marking_styles,
    head_marking_style,
    change_body_markings,
    body_marking_styles,
    body_marking_style,
    change_tail_markings,
    tail_marking_styles,
    tail_marking_style,
    change_body_accessory,
    body_accessory_styles,
    body_accessory_style,
    change_alt_head,
    alt_head_styles,
    alt_head_style,
  } = data;

  const has_colours =
    change_eye_color ||
    change_skin_tone ||
    change_skin_color ||
    change_head_accessory_color ||
    change_hair_color ||
    change_secondary_hair_color ||
    change_facial_hair_color ||
    change_secondary_facial_hair_color ||
    change_head_marking_color ||
    change_body_marking_color ||
    change_tail_marking_color;

  return (
    <Window width={800} height={600}>
      <Window.Content scrollable>
        <LabeledList>
          {!!change_race && (
            <LabeledList.Item label="Species">
              {species.map((s) => (
                <Button
                  key={s.specimen}
                  selected={s.specimen === specimen}
                  onClick={() => act('race', { race: s.specimen })}
                >
                  {s.specimen}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_gender && (
            <LabeledList.Item label="Gender">
              <Button
                selected={gender === 'male'}
                onClick={() => act('gender', { gender: 'male' })}
              >
                Male
              </Button>
              <Button
                selected={gender === 'female'}
                onClick={() => act('gender', { gender: 'female' })}
              >
                Female
              </Button>
              {!has_gender && (
                <Button
                  selected={gender === 'plural'}
                  onClick={() => act('gender', { gender: 'plural' })}
                >
                  Genderless
                </Button>
              )}
            </LabeledList.Item>
          )}
          {!!has_colours && <ColorContent />}
          {!!change_head_accessory && (
            <StyleContent
              label="Head accessory"
              action="head_accessory"
              styles={head_accessory_styles}
              current={head_accessory_style}
            />
          )}
          {!!change_hair && (
            <StyleContent
              label="Hair"
              action="hair"
              styles={hair_styles}
              current={hair_style}
            />
          )}
          {!!change_hair_gradient && (
            <LabeledList.Item label="Hair Gradient">
              <Button onClick={() => act('hair_gradient')}>Change Style</Button>
              <Button onClick={() => act('hair_gradient_offset')}>
                Change Offset
              </Button>
              <Button onClick={() => act('hair_gradient_colour')}>
                Change Color
              </Button>
              <Button onClick={() => act('hair_gradient_alpha')}>
                Change Alpha
              </Button>
            </LabeledList.Item>
          )}
          {!!change_facial_hair && (
            <StyleContent
              label="Facial hair"
              action="facial_hair"
              styles={facial_hair_styles}
              current={facial_hair_style}
            />
          )}
          {!!change_head_markings && (
            <StyleContent
              label="Head markings"
              action="head_marking"
              styles={head_marking_styles}
              current={head_marking_style}
            />
          )}
          {!!change_body_markings && (
            <StyleContent
              label="Body markings"
              action="body_marking"
              styles={body_marking_styles}
              current={body_marking_style}
            />
          )}
          {!!change_tail_markings && (
            <StyleContent
              label="Tail markings"
              action="tail_marking"
              styles={tail_marking_styles}
              current={tail_marking_style}
            />
          )}
          {!!change_body_accessory && (
            <StyleContent
              label="Body accessory"
              action="body_accessory"
              styles={body_accessory_styles}
              current={body_accessory_style}
            />
          )}
          {!!change_alt_head && (
            <StyleContent
              label="Alternate head"
              action="alt_head"
              styles={alt_head_styles}
              current={alt_head_style}
            />
          )}
        </LabeledList>
      </Window.Content>
    </Window>
  );
};

type StyleContentProps = {
  label: string;
  action: string;
  styles: StyleEntry[];
  current: string;
};

const StyleContent = (props: StyleContentProps) => {
  const { act, data } = useBackend<AppearanceData>();
  const { label, action, styles = [], current } = props;
  const { icon_prefix } = data;

  return (
    <LabeledList.Item label={label}>
      {styles.map((entry) => (
        <Button
          key={entry.style}
          tooltip={entry.style}
          selected={entry.style === current}
          verticalAlignContent="middle"
          onClick={() => act(action, { [action]: entry.style })}
        >
          {!!entry.icon && (
            <div
              className={`${icon_prefix} ${entry.icon}`}
              style={{ marginRight: '4px', verticalAlign: 'middle' }}
            />
          )}
          {entry.style}
        </Button>
      ))}
    </LabeledList.Item>
  );
};

const ColorContent = (props: unknown) => {
  const { act, data } = useBackend();

  const colorOptions = [
    { key: 'change_eye_color', text: 'Change eye color', action: 'eye_color' },
    { key: 'change_skin_tone', text: 'Change skin tone', action: 'skin_tone' },
    {
      key: 'change_skin_color',
      text: 'Change skin color',
      action: 'skin_color',
    },
    {
      key: 'change_head_accessory_color',
      text: 'Change head accessory color',
      action: 'head_accessory_color',
    },
    {
      key: 'change_hair_color',
      text: 'Change hair color',
      action: 'hair_color',
    },
    {
      key: 'change_secondary_hair_color',
      text: 'Change secondary hair color',
      action: 'secondary_hair_color',
    },
    {
      key: 'change_facial_hair_color',
      text: 'Change facial hair color',
      action: 'facial_hair_color',
    },
    {
      key: 'change_secondary_facial_hair_color',
      text: 'Change secondary facial hair color',
      action: 'secondary_facial_hair_color',
    },
    {
      key: 'change_head_marking_color',
      text: 'Change head marking color',
      action: 'head_marking_color',
    },
    {
      key: 'change_body_marking_color',
      text: 'Change body marking color',
      action: 'body_marking_color',
    },
    {
      key: 'change_tail_marking_color',
      text: 'Change tail marking color',
      action: 'tail_marking_color',
    },
  ];

  return (
    <LabeledList.Item label="Colors">
      {colorOptions.map(
        (c) =>
          !!data[c.key] && (
            <Button key={c.key} onClick={() => act(c.action)}>
              {c.text}
            </Button>
          ),
      )}
    </LabeledList.Item>
  );
};
