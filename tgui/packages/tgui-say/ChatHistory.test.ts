import { ChatHistory } from './ChatHistory';

describe('ChatHistory', () => {
  let chatHistory: ChatHistory;

  beforeEach(() => {
    chatHistory = new ChatHistory();
  });

  it('should add a message to the history', () => {
    chatHistory.add({ value: 'Hello' });
    expect(chatHistory.getOlderMessage().value).toEqual('Hello');
  });

  it('should retrieve older and newer messages', () => {
    chatHistory.add({ value: 'Hello' });
    chatHistory.add({ value: 'World' });
    expect(chatHistory.getOlderMessage().value).toEqual('World');
    expect(chatHistory.getOlderMessage().value).toEqual('Hello');
    expect(chatHistory.getNewerMessage().value).toEqual('World');
    expect(chatHistory.getNewerMessage()).toBeNull();
    expect(chatHistory.getOlderMessage().value).toEqual('World');
  });

  it('should limit the history to 5 messages', () => {
    for (let i = 1; i <= 6; i++) {
      chatHistory.add({ value: `Message ${i}` });
    }

    expect(chatHistory.getOlderMessage().value).toEqual('Message 6');
    for (let i = 5; i >= 2; i--) {
      expect(chatHistory.getOlderMessage().value).toEqual(`Message ${i}`);
    }
    expect(chatHistory.getOlderMessage()).toBeNull();
  });

  it('should handle temp message correctly', () => {
    chatHistory.saveTemp({ value: 'Temp message' });
    expect(chatHistory.getTemp().value).toEqual('Temp message');
    expect(chatHistory.getTemp()).toBeNull();
  });

  it('should reset correctly', () => {
    chatHistory.add({ value: 'Hello' });
    chatHistory.getOlderMessage();
    chatHistory.reset();
    expect(chatHistory.isAtLatest()).toBe(true);
    expect(chatHistory.getOlderMessage().value).toEqual('Hello');
  });
});
