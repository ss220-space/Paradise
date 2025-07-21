import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type MainPageProps = {
  data: MainPageData;
} & ActProps;

const MainPage = ({ act, data }: MainPageProps) => {
  const { name, currentSection, prefixes, titles, names, suffixes } = data;
  return (
    <Section>
      <div className="CodexGigas__final-name-container">
        {currentSection !== 1 ? (
          <p className="CodexGigas__final-name">{name}</p>
        ) : (
          <p className="CodexGigas__italic-text">
            Изучая эту книгу, вы познаёте слабости дьявола, если конечно вам
            известно его настоящее имя... но будьте осторожены, длительное
            чтение может иметь серьезные последствия.
          </p>
        )}
      </div>
      <LabeledList>
        <LabeledList.Item label="Префикс">
          {prefixes.map((prefix) => (
            <Button
              key={prefix.toLowerCase()}
              disabled={currentSection !== 1}
              onClick={() => act(prefix)}
              className="CodexGigas__button"
            >
              {prefix}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Заголовок">
          {titles.map((title) => (
            <Button
              key={title.toLowerCase()}
              disabled={currentSection > 2}
              onClick={() => act(title)}
              className="CodexGigas__button"
            >
              {title}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Имя">
          {names.map((name) => (
            <Button
              key={name.toLowerCase()}
              disabled={currentSection > 4}
              onClick={() => act(name)}
              className="CodexGigas__button"
            >
              {name}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Суффикс">
          {suffixes.map((suffix) => (
            <Button
              key={suffix.toLowerCase()}
              disabled={currentSection !== 4}
              onClick={() => act(suffix)}
              className="CodexGigas__button"
            >
              {suffix}
            </Button>
          ))}
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            disabled={currentSection < 4}
            onClick={() => act('search')}
            className="CodexGigas__search-button"
          >
            Поиск
          </Button>
          <Button
            disabled={currentSection === 1}
            onClick={() => act('clear')}
            className="CodexGigas__search-button"
          >
            Очистить
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

type DetailsPageProps = {
  data: DevilData;
} & ActProps;

type ActProps = {
  act: (s: string, o?: object) => void;
};

const DetailsPage = ({ act, data }: DetailsPageProps) => {
  const { devilName, ban, bane, obligation, banish } = data;

  return (
    <Section
      title={
        <span className="CodexGigas__title">Информация о {devilName}</span>
      }
    >
      <>
        <p className="CodexGigas__info-text">Запрет: {ban}</p>
        <p className="CodexGigas__info-text">Слабость: {bane}</p>
        <p className="CodexGigas__info-text">Обязательство: {obligation}</p>
        <p className="CodexGigas__info-text">Ритуал изгнания: {banish}</p>
        <div className="CodexGigas__centered">
          <Button onClick={() => act('reset')} className="CodexGigas__button">
            Искать заново
          </Button>
        </div>
      </>
    </Section>
  );
};

type CodexGigasData = {
  hasDevilInfo: boolean;
} & DevilData &
  MainPageData;

type DevilData = {
  devilName: string;
  ban: string;
  bane: string;
  obligation: string;
  banish: string;
};

type MainPageData = {
  name: string;
  currentSection: number;
  prefixes: string[];
  titles: string[];
  names: string[];
  suffixes: string[];
};

export const CodexGigas = (_props: unknown) => {
  const { act, data } = useBackend<CodexGigasData>();
  return (
    <Window theme="infernal">
      <Window.Content className="CodexGigas__background">
        {data.hasDevilInfo ? (
          <DetailsPage act={act} data={data} />
        ) : (
          <MainPage act={act} data={data} />
        )}
      </Window.Content>
    </Window>
  );
};
