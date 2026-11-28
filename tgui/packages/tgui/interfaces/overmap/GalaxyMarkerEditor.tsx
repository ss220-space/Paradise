import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NumberInput,
} from 'tgui-core/components';
import type { GalaxyMarkerStyle } from './galaxyTypes';

export const GalaxyMarkerEditor = ({
  value,
  onChange,
}: {
  value: GalaxyMarkerStyle;
  onChange: (marker: GalaxyMarkerStyle) => void;
}) => {
  const [error, setError] = useState('');
  const update = (change: Partial<GalaxyMarkerStyle>) =>
    onChange({ ...value, ...change });
  const numberFields: [
    keyof GalaxyMarkerStyle,
    string,
    number,
    number,
    number,
    number,
  ][] = [
    ['size', 'Размер значка', 1, 40, 0.5, 4],
    ['width', 'Толщина обводки', 0.5, 8, 0.5, 1],
    ['opacity', 'Непрозрачность', 0, 1, 0.05, 1],
    ['rotation', 'Поворот', -360, 360, 5, 0],
    ['labelSize', 'Размер подписи', 6, 32, 1, 11],
    ['labelX', 'Сдвиг подписи X', -200, 200, 1, 0],
    ['labelY', 'Сдвиг подписи Y', -200, 200, 1, 0],
  ];
  return (
    <LabeledList>
      <LabeledList.Item label="Форма">
        <Dropdown
          fluid
          selected={value.shape || 'circle'}
          displayText={
            {
              circle: 'Круг',
              ring: 'Кольцо',
              diamond: 'Ромб',
              square: 'Квадрат',
              triangle: 'Треугольник',
              star: 'Звезда',
              cross: 'Крест',
            }[value.shape || 'circle']
          }
          options={[
            ['circle', 'Круг'],
            ['ring', 'Кольцо'],
            ['diamond', 'Ромб'],
            ['square', 'Квадрат'],
            ['triangle', 'Треугольник'],
            ['star', 'Звезда'],
            ['cross', 'Крест'],
          ].map(([value, displayText]) => ({ value, displayText }))}
          onSelected={(shape) => update({ shape })}
        />
      </LabeledList.Item>
      {(
        [
          ['color', 'Цвет обводки', '#8fd0ff'],
          ['fill', 'Цвет заливки', '#8fd0ff'],
          ['labelColor', 'Цвет подписи', '#d4e7ef'],
        ] as const
      ).map(([key, label, fallback]) => (
        <LabeledList.Item key={key} label={label}>
          <input
            aria-label={label}
            type="color"
            value={value[key] || fallback}
            onChange={(event) => update({ [key]: event.target.value })}
          />
          <Input
            width="100px"
            value={value[key] || fallback}
            onChange={(color) => update({ [key]: color })}
          />
        </LabeledList.Item>
      ))}
      {numberFields.map(([key, label, min, max, step, fallback]) => (
        <LabeledList.Item key={key} label={label}>
          <NumberInput
            value={
              typeof value[key] === 'number' ? (value[key] as number) : fallback
            }
            minValue={min}
            maxValue={max}
            step={step}
            onChange={(number) => update({ [key]: number })}
          />
        </LabeledList.Item>
      ))}
      <LabeledList.Item label="Подпись">
        <Button.Checkbox
          checked={!!(value.showLabel ?? true)}
          onClick={() => update({ showLabel: !(value.showLabel ?? true) })}
        >
          Показывать название
        </Button.Checkbox>
      </LabeledList.Item>
      <LabeledList.Item label="Изображение">
        <input
          aria-label="Загрузить изображение маркера"
          type="file"
          accept="image/png,image/jpeg,image/webp"
          onChange={(event) => {
            const file = event.target.files?.[0];
            if (!file) return;
            if (
              file.size > 512 * 1024 ||
              !['image/png', 'image/jpeg', 'image/webp'].includes(file.type)
            ) {
              setError('PNG, JPEG или WebP до 512 КиБ');
              return;
            }
            const reader = new FileReader();
            reader.onload = () => {
              if (typeof reader.result === 'string') {
                update({ image: reader.result });
                setError('');
              }
            };
            reader.onerror = () => setError('Не удалось прочитать изображение');
            reader.readAsDataURL(file);
          }}
        />
        {!!value.image && (
          <>
            <Button icon="trash" onClick={() => update({ image: undefined })}>
              Убрать изображение
            </Button>
            <NumberInput
              value={value.imageSize || 32}
              minValue={8}
              maxValue={160}
              step={1}
              onChange={(imageSize) => update({ imageSize })}
            />
          </>
        )}
        {!!error && <Box color="bad">{error}</Box>}
      </LabeledList.Item>
    </LabeledList>
  );
};
