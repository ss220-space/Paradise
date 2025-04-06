import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

const MainPage = ({ act, data }) => {
  const { name, currentSection, prefixes, titles, names, suffixes } = data;
  return (
    <Section>
      <div className="CodexGigas__final-name-container">
        {currentSection !== 1 ? (
          <p className="CodexGigas__final-name">{name}</p>
        ) : (
          <p className="CodexGigas__italic-text">
            Изучая эту книгу, ты познаешь слабости дьявола, если конечно тебе
            известно его настоящее имя... но будь осторожен, длительное чтение
            может иметь серьезные последствия.
          </p>
        )}
      </div>
      <LabeledList>
        <LabeledList.Item label="Префикс">
          {prefixes.map((prefix) => (
            <Button
              key={prefix.toLowerCase()}
              content={prefix}
              disabled={currentSection !== 1}
              onClick={() => act(prefix)}
              className="CodexGigas__button"
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Заголовок">
          {titles.map((title) => (
            <Button
              key={title.toLowerCase()}
              content={title}
              disabled={currentSection > 2}
              onClick={() => act(title)}
              className="CodexGigas__button"
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Имя">
          {names.map((name) => (
            <Button
              key={name.toLowerCase()}
              content={name}
              disabled={currentSection > 4}
              onClick={() => act(name)}
              className="CodexGigas__button"
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item label="Суффикс">
          {suffixes.map((suffix) => (
            <Button
              key={suffix.toLowerCase()}
              content={suffix}
              disabled={currentSection !== 4}
              onClick={() => act(suffix)}
              className="CodexGigas__button"
            />
          ))}
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            content="Поиск"
            disabled={currentSection < 4}
            onClick={() => act('search')}
            className="CodexGigas__search-button"
          />
          <Button
            content="Очистить"
            disabled={currentSection === 1}
            onClick={() => act('clear')}
            className="CodexGigas__search-button"
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const DetailsPage = ({ act, data }) => {
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
          <Button
            content="Искать заново"
            onClick={() => act('reset')}
            className="CodexGigas__button"
          />
        </div>
      </>
    </Section>
  );
};

export const CodexGigas = (props, context) => {
  const { act, data } = useBackend(context);
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
