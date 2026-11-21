import { useEffect, useRef, useState } from 'react';
import { AnimatedNumber, Box, Button, Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type SlotMachineData = {
  money: number | null;
  plays: number;
  working: boolean;
  result: string | null;
  resultlvl: string | null;
  reels: string[];
  winning_reels: number[];
  credits: number;
  prize: string | null;
  spin_id: number;
  multiplier: number;
  paytable: PaytableEntry[];
};

type ReelSymbol =
  | 'seven'
  | 'bar'
  | 'bell'
  | 'cherry'
  | 'lemon'
  | 'gem'
  | 'star';

type PaytableEntry = {
  id: string;
  symbol: ReelSymbol;
  match: number;
  credits: number;
  jackpot: boolean;
};

const DEFAULT_REELS: ReelSymbol[] = ['seven', 'bar', 'cherry'];

const SYMBOL_ICONS: Partial<Record<ReelSymbol, string>> = {
  bell: 'bell',
  cherry: 'apple-whole',
  lemon: 'lemon',
  gem: 'gem',
  star: 'star',
};

const SPIN_STRIP: ReelSymbol[] = [
  'seven',
  'bell',
  'cherry',
  'bar',
  'lemon',
  'gem',
  'star',
  'cherry',
  'seven',
  'bar',
  'lemon',
  'bell',
];

const REEL_STRIPS = [0, 4, 8].map((offset) => [
  ...SPIN_STRIP.slice(offset),
  ...SPIN_STRIP.slice(0, offset),
]);

const BULBS = Array.from({ length: 16 }, (_, index) => index);

const SymbolView = ({ symbol }: { symbol: ReelSymbol }) => {
  if (symbol === 'seven') {
    return <span className="SlotMachine__seven">7</span>;
  }
  if (symbol === 'bar') {
    return <span className="SlotMachine__bar">BAR</span>;
  }
  return (
    <Icon
      name={SYMBOL_ICONS[symbol] || 'question'}
      className={classes(['SlotMachine__icon', `SlotMachine__icon--${symbol}`])}
    />
  );
};

const Bulbs = ({ offset }: { offset: number }) => (
  <div className="SlotMachine__bulbs" aria-hidden>
    {BULBS.map((bulb) => (
      <span
        className="SlotMachine__bulb"
        key={bulb}
        style={{ animationDelay: `${((bulb + offset) % 8) * 0.11}s` }}
      />
    ))}
  </div>
);

const Reel = ({
  index,
  symbol,
  spinning,
  winning,
  jackpot,
}: {
  index: number;
  symbol: ReelSymbol;
  spinning: boolean;
  winning: boolean;
  jackpot: boolean;
}) => {
  const strip = REEL_STRIPS[index % REEL_STRIPS.length];

  return (
    <div
      className={classes([
        'SlotMachine__reel',
        spinning && 'SlotMachine__reel--spinning',
        winning && 'SlotMachine__reel--winning',
        winning && jackpot && 'SlotMachine__reel--jackpot',
      ])}
    >
      {spinning ? (
        <div
          className="SlotMachine__strip"
          style={{ animationDuration: `${0.22 + index * 0.035}s` }}
        >
          {[...strip, ...strip].map((stripSymbol, stripIndex) => (
            <div
              className="SlotMachine__reel-symbol"
              key={`${stripSymbol}-${stripIndex}`}
            >
              <SymbolView symbol={stripSymbol} />
            </div>
          ))}
        </div>
      ) : (
        <div className="SlotMachine__reel-symbol SlotMachine__reel-symbol--settle">
          <SymbolView symbol={symbol} />
        </div>
      )}
    </div>
  );
};

const PaytableRow = ({
  entry,
  multiplier,
}: {
  entry: PaytableEntry;
  multiplier: number;
}) => (
  <div
    className={classes([
      'SlotMachine__paytable-row',
      entry.jackpot && 'SlotMachine__paytable-row--jackpot',
    ])}
  >
    <span className="SlotMachine__paytable-symbols">
      {Array.from({ length: entry.match }, (_, index) => (
        <span
          className="SlotMachine__paytable-symbol"
          key={`${entry.symbol}-${index}`}
        >
          <SymbolView symbol={entry.symbol} />
        </span>
      ))}
      {entry.match === 2 && (
        <span className="SlotMachine__paytable-pair">×2</span>
      )}
    </span>
    <span className="SlotMachine__paytable-payout">
      {(entry.credits * multiplier).toLocaleString('ru-RU')} кр.
    </span>
  </div>
);

export const SlotMachine = (_props: unknown) => {
  const { act, data } = useBackend<SlotMachineData>();
  const [phase, setPhase] = useState<'idle' | 'spinning' | 'stopping'>(
    data.working ? 'spinning' : 'idle',
  );
  const [stoppedReels, setStoppedReels] = useState(0);
  const [showResult, setShowResult] = useState(
    () => !data.working && !!data.result,
  );
  const stopTimers = useRef<ReturnType<typeof setTimeout>[]>([]);
  const wasWorking = useRef(data.working);

  const clearStopTimers = () => {
    stopTimers.current.forEach(clearTimeout);
    stopTimers.current = [];
  };

  useEffect(() => {
    if (data.working) {
      clearStopTimers();
      setPhase('spinning');
      setStoppedReels(0);
      setShowResult(false);
    } else if (wasWorking.current) {
      setPhase('stopping');
      setStoppedReels(0);
      stopTimers.current = [
        setTimeout(() => setStoppedReels(1), 175),
        setTimeout(() => setStoppedReels(2), 375),
        setTimeout(() => setStoppedReels(3), 575),
        setTimeout(() => {
          setPhase('idle');
          setShowResult(true);
        }, 725),
      ];
    }
    wasWorking.current = data.working;
  }, [data.working, data.spin_id]);

  useEffect(() => {
    return () => clearStopTimers();
  }, []);

  const money = data.money;

  if (money === null) {
    return (
      <Window width={400} height={220}>
        <Window.Content className="SlotMachine__no-account">
          <Box bold fontSize="16px" mb={1}>
            Невозможно определить платежный аккаунт!
          </Box>
          <Box>
            Пожалуйста, наденьте или держите в руках вашу карту и попробуйте
            заново.
          </Box>
        </Window.Content>
      </Window>
    );
  }

  const reels = (
    data.reels?.length === 3 ? data.reels : DEFAULT_REELS
  ) as ReelSymbol[];
  const winningReels = data.winning_reels || [];
  const spinning = data.working || phase !== 'idle';
  const isWin = showResult && data.credits > 0;
  const isJackpot = showResult && data.prize === 'jackpot';
  const multiplier = data.multiplier || 1;
  const paytable = [...(data.paytable || [])].sort(
    (a, b) => b.credits - a.credits,
  );
  const canSpin = !spinning && money >= 50;

  const isReelSpinning = (index: number) => {
    if (phase === 'spinning') {
      return true;
    }
    if (phase === 'stopping') {
      return index >= stoppedReels;
    }
    return false;
  };

  let spinButtonText = 'КРУТИТЬ';
  if (data.working || phase === 'spinning') {
    spinButtonText = 'КРУТИМ...';
  } else if (phase === 'stopping') {
    spinButtonText = 'ОСТАНОВКА...';
  } else if (money < 50) {
    spinButtonText = 'НЕДОСТАТОЧНО КРЕДИТОВ';
  }

  return (
    <Window width={480} height={600}>
      <Window.Content fitted className="SlotMachine__window">
        <div
          className={classes([
            'SlotMachine',
            isWin && 'SlotMachine--win',
            isJackpot && 'SlotMachine--jackpot',
          ])}
        >
          <div className="SlotMachine__marquee">
            <Bulbs offset={0} />
            <div className="SlotMachine__title">Lucky</div>
            <div className="SlotMachine__subtitle">NANOTRASEN CASINO</div>
            <Bulbs offset={1} />
          </div>

          <div className="SlotMachine__cabinet">
            <div className="SlotMachine__reels">
              {reels.map((symbol, index) => (
                <Reel
                  key={index}
                  index={index}
                  symbol={symbol}
                  spinning={isReelSpinning(index)}
                  winning={showResult && winningReels.includes(index + 1)}
                  jackpot={isJackpot}
                />
              ))}
            </div>
            <div className="SlotMachine__payline" />
          </div>

          <div className="SlotMachine__paytable">
            <div className="SlotMachine__paytable-title">
              Таблица выплат
              {multiplier > 1 && (
                <span className="SlotMachine__multiplier">×{multiplier}</span>
              )}
            </div>
            <div className="SlotMachine__paytable-list">
              {paytable.map((entry) => (
                <PaytableRow
                  entry={entry}
                  multiplier={multiplier}
                  key={entry.id}
                />
              ))}
            </div>
          </div>

          <div className="SlotMachine__footer">
            <div className="SlotMachine__stats">
              <span>
                Баланс:{' '}
                <b>
                  <AnimatedNumber value={money} /> кр.
                </b>
              </span>
              <span>
                Спинов: <b>{data.plays}</b>
              </span>
            </div>

            <div
              className={classes([
                'SlotMachine__result',
                isWin && 'SlotMachine__result--win',
                isJackpot && 'SlotMachine__result--jackpot',
              ])}
            >
              {showResult ? (
                <Box
                  bold
                  className="SlotMachine__result-text"
                  color={data.resultlvl || undefined}
                >
                  {data.result}
                </Box>
              ) : (
                <span className="SlotMachine__result-idle">
                  {spinning ? 'Барабаны крутятся...' : 'Испытайте удачу!'}
                </span>
              )}
            </div>

            <Button
              className="SlotMachine__spin"
              fluid
              disabled={!canSpin}
              onClick={() => act('spin')}
            >
              <span className="SlotMachine__spin-icon" aria-hidden>
                <Icon name={spinning ? 'spinner' : 'coins'} spin={spinning} />
              </span>
              {spinButtonText}
            </Button>

            <div className="SlotMachine__bet">
              Ставка: <b>50</b> кредитов за спин
            </div>
          </div>

          {isWin && (
            <div className="SlotMachine__coin-rain" aria-hidden>
              {Array.from({ length: isJackpot ? 28 : 16 }, (_, index) => (
                <span
                  className="SlotMachine__coin"
                  key={index}
                  style={{
                    left: `${(index * 37 + 11) % 100}%`,
                    animationDelay: `${(index % 8) * 0.1}s`,
                    animationDuration: `${1.4 + (index % 6) * 0.15}s`,
                  }}
                >
                  <Icon name="coins" />
                </span>
              ))}
            </div>
          )}
        </div>
      </Window.Content>
    </Window>
  );
};
