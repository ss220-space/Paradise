import { number } from 'prop-types';
import { useMemo } from 'react';

const MECHA_REPLACEMENTS: Record<string, string> = {
  'включен': 'Вхонк',
  'выключен': 'Выхонк',
  'вкл': 'Вхонк',
  'выкл': 'Выхонк',
  'энергия': 'Хонкия',
  'состояние': 'Хонктояние',
  'свет': 'Хонк',
  'воздух': 'Хонкдух',
  'баллон': 'Бахонк',
  'атмосфера': 'Хонкмосфера',
  'блок': 'хонк',
  'отсутствует': 'Отсухонк',
  'установлен': 'Ухонковлен',
  'статус': 'Хонктус',
  'модули': 'Хонкули',
  'настройки': 'Хонкойки',
  'груз': 'Хонк',
  'перезарядка': 'Перехонк',
  'боеприпасы': 'Хонкприпасы',
  'выбрать': 'Хонкать',
};

export const useHonk = (honkChance: number = 0.4) => {
  const honk = useMemo(() => {
    return (text: string) => {
      if (!honkChance) return text;

      let result = text;
      for (const [word, replacement] of Object.entries(MECHA_REPLACEMENTS)) {
        const regex = new RegExp(`${word}`, 'gi');
        result = result.replace(regex, replacement);
      }

      if (result !== text) return result;

      const words = result.split(/\s+/);

      for (let i = 0; i < words.length; i++) {
        if (Math.random() >= honkChance || words[i].length <= 3) continue;

        const cleanWord = words[i].replace(
          new RegExp(`^[^a-zA-Zа-яёА-Я]+|[^a-zA-Zа-яёА-Я]+$`, 'g'),
          ''
        );

        if (cleanWord.length <= 3) continue;

        const replaceLength = Math.min(Math.floor(cleanWord.length / 2), 3);
        const replaceStart = Math.random() > 0.5;

        words[i] = replaceStart
          ? 'хонк' + cleanWord.substring(replaceLength)
          : cleanWord.substring(0, cleanWord.length - replaceLength) + 'хонк';
      }

      return words.join(' ');
    };
  }, [honkChance]);

  return honk;
};
