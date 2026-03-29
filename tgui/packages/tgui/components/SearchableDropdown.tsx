import { useEffect, useRef, useState } from 'react';
import { Box, TextArea } from '../components';

export const SearchableDropdown = ({
  options,
  value,
  onChange,
  placeholder = 'Поиск...',
  maxItems = 20,
}: {
  options: string[];
  value: string | null;
  onChange: (value: string) => void;
  placeholder?: string;
  maxItems?: number;
}) => {
  const [query, setQuery] = useState('');
  const [isOpen, setIsOpen] = useState(false);
  const [highlightIndex, setHighlightIndex] = useState(0);

  const containerRef = useRef<HTMLDivElement>(null);

  const filtered = options
    .filter((o) => o.toLowerCase().includes(query.toLowerCase()))
    .slice(0, maxItems);

  useEffect(() => {
    if (value) setQuery(value);
  }, [value]);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (!containerRef.current?.contains(e.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleKeyDown = (e: React.KeyboardEvent<HTMLDivElement>) => {
    if (!isOpen) return;

    if (e.key === 'ArrowDown') {
      setHighlightIndex((prev) => Math.min(prev + 1, filtered.length - 1));
    }

    if (e.key === 'ArrowUp') {
      setHighlightIndex((prev) => Math.max(prev - 1, 0));
    }

    if (e.key === 'Enter') {
      const selected = filtered[highlightIndex];
      if (selected) {
        onChange(selected);
        setQuery(selected);
        setIsOpen(false);
      }
    }
  };

  const highlightMatch = (text: string) => {
    if (!query) return text;

    const index = text.toLowerCase().indexOf(query.toLowerCase());
    if (index === -1) return text;

    return (
      <>
        {text.slice(0, index)}
        <Box as="span" className="text-gold">
          {text.slice(index, index + query.length)}
        </Box>
        {text.slice(index + query.length)}
      </>
    );
  };

  return (
    <div
      ref={containerRef}
      style={{ position: 'relative' }}
      onKeyDown={handleKeyDown}
      onClick={() => {
        setIsOpen(true);
        setHighlightIndex(0);
      }}
    >
      <TextArea
        height="48px"
        value={query}
        placeholder={placeholder}
        onChange={(t) => {
          setQuery(t);
          setIsOpen(true);
          setHighlightIndex(0);
        }}
        className="input-field input-field--large"
      />

      {isOpen && (
        <Box className="searchable-dropdown-menu">
          {filtered.length === 0 ? (
            <Box className="searchable-dropdown-empty">Ничего не найдено</Box>
          ) : (
            filtered.map((option, index) => (
              <Box
                key={option}
                onClick={() => {
                  onChange(option);
                  setQuery(option);
                  setIsOpen(false);
                }}
                className={`searchable-dropdown-item ${
                  index === highlightIndex
                    ? 'searchable-dropdown-item--active'
                    : ''
                }`}
              >
                {highlightMatch(option)}
              </Box>
            ))
          )}
        </Box>
      )}
    </div>
  );
};
