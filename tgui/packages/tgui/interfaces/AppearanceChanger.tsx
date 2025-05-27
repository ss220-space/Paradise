import { useBackend } from '../backend';
import { LabeledList, Button } from '../components';
import { Window } from '../layouts';

type AppearanceData = {
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
  head_accessory_styles: HeadAccessory[];
  head_accessory_style: string;
  change_hair: string;
  hair_styles: Hairstyle[];
  hair_style: string;
  change_hair_gradient: string;
  change_facial_hair: string;
  facial_hair_styles: Facialhairstyle[];
  facial_hair_style: string;
  change_head_markings: string;
  head_marking_styles: Headmarkingstyle[];
  head_marking_style: string;
  change_body_markings: string;
  body_marking_styles: Bodymarkingstyle[];
  body_marking_style: string;
  change_tail_markings: string;
  tail_marking_styles: Tailmarkingstyle[];
  tail_marking_style: string;
  change_body_accessory: string;
  body_accessory_styles: Bodyaccessorystyle[];
  body_accessory_style: string;
  change_alt_head: string;
  alt_head_styles: Altheadstyle[];
  alt_head_style: string;
};

type Species = {
  specimen: string;
};

type HeadAccessory = {
  headaccessorystyle: string;
};

type Hairstyle = {
  hairstyle: string;
};

type Facialhairstyle = {
  facialhairstyle: string;
};

type Headmarkingstyle = {
  headmarkingstyle: string;
};

type Bodymarkingstyle = {
  bodymarkingstyle: string;
};

type Tailmarkingstyle = {
  tailmarkingstyle: string;
};

type Bodyaccessorystyle = {
  bodyaccessorystyle: string;
};

type Altheadstyle = {
  altheadstyle: string;
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

  let has_colours = false;
  // Yes this if statement is awful, but I would rather do it here than inside the template
  if (
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
    change_tail_marking_color
  ) {
    has_colours = true;
  }

  return (
    <Window width={800} height={450}>
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
            <LabeledList.Item label="Head accessory">
              {head_accessory_styles.map((s) => (
                <Button
                  key={s.headaccessorystyle}
                  selected={s.headaccessorystyle === head_accessory_style}
                  onClick={() =>
                    act('head_accessory', {
                      head_accessory: s.headaccessorystyle,
                    })
                  }
                >
                  {s.headaccessorystyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_hair && (
            <LabeledList.Item label="Hair">
              {hair_styles.map((s) => (
                <Button
                  key={s.hairstyle}
                  selected={s.hairstyle === hair_style}
                  onClick={() => act('hair', { hair: s.hairstyle })}
                >
                  {s.hairstyle}
                </Button>
              ))}
            </LabeledList.Item>
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
            <LabeledList.Item label="Facial hair">
              {facial_hair_styles.map((s) => (
                <Button
                  key={s.facialhairstyle}
                  selected={s.facialhairstyle === facial_hair_style}
                  onClick={() =>
                    act('facial_hair', { facial_hair: s.facialhairstyle })
                  }
                >
                  {s.facialhairstyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_head_markings && (
            <LabeledList.Item label="Head markings">
              {head_marking_styles.map((s) => (
                <Button
                  key={s.headmarkingstyle}
                  selected={s.headmarkingstyle === head_marking_style}
                  onClick={() =>
                    act('head_marking', { head_marking: s.headmarkingstyle })
                  }
                >
                  {s.headmarkingstyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_markings && (
            <LabeledList.Item label="Body markings">
              {body_marking_styles.map((s) => (
                <Button
                  key={s.bodymarkingstyle}
                  selected={s.bodymarkingstyle === body_marking_style}
                  onClick={() =>
                    act('body_marking', { body_marking: s.bodymarkingstyle })
                  }
                >
                  {s.bodymarkingstyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_tail_markings && (
            <LabeledList.Item label="Tail markings">
              {tail_marking_styles.map((s) => (
                <Button
                  key={s.tailmarkingstyle}
                  selected={s.tailmarkingstyle === tail_marking_style}
                  onClick={() =>
                    act('tail_marking', { tail_marking: s.tailmarkingstyle })
                  }
                >
                  {s.tailmarkingstyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_body_accessory && (
            <LabeledList.Item label="Body accessory">
              {body_accessory_styles.map((s) => (
                <Button
                  key={s.bodyaccessorystyle}
                  selected={s.bodyaccessorystyle === body_accessory_style}
                  onClick={() =>
                    act('body_accessory', {
                      body_accessory: s.bodyaccessorystyle,
                    })
                  }
                >
                  {s.bodyaccessorystyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
          {!!change_alt_head && (
            <LabeledList.Item label="Alternate head">
              {alt_head_styles.map((s) => (
                <Button
                  key={s.altheadstyle}
                  selected={s.altheadstyle === alt_head_style}
                  onClick={() => act('alt_head', { alt_head: s.altheadstyle })}
                >
                  {s.altheadstyle}
                </Button>
              ))}
            </LabeledList.Item>
          )}
        </LabeledList>
      </Window.Content>
    </Window>
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
          )
      )}
    </LabeledList.Item>
  );
};
