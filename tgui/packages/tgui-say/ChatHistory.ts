import { Channel } from './ChannelIterator';
import { RADIO_PREFIXES } from './constants';

export type HistoryRecord = Partial<{
  prefix: keyof typeof RADIO_PREFIXES | null;
  value: string;
  channel: Channel;
}>;

/**
 * ### ChatHistory
 * A class to manage a chat history,
 * maintaining a maximum of five messages and supporting navigation,
 * temporary message storage, and query operations.
 */
export class ChatHistory {
  private messages: HistoryRecord[] = [];
  private index: number = -1; // Initialize index at -1
  private temp: HistoryRecord | null = null;

  public add(message: HistoryRecord): void {
    this.messages.unshift(message);
    this.index = -1; // Reset index
    if (this.messages.length > 5) {
      this.messages.pop();
    }
  }

  public getIndex(): number {
    return this.index + 1;
  }

  public getOlderMessage(): HistoryRecord | null {
    if (this.messages.length === 0 || this.index >= this.messages.length - 1) {
      return null;
    }
    this.index++;
    return this.messages[this.index];
  }

  public getNewerMessage(): HistoryRecord | null {
    if (this.index <= 0) {
      this.index = -1;
      return null;
    }
    this.index--;
    return this.messages[this.index];
  }

  public isAtLatest(): boolean {
    return this.index === -1;
  }

  public saveTemp(message: HistoryRecord): void {
    this.temp = message;
  }

  public getTemp(): HistoryRecord | null {
    const temp = this.temp;
    this.temp = null;
    return temp;
  }

  public reset(): void {
    this.index = -1;
    this.temp = null;
  }
}
