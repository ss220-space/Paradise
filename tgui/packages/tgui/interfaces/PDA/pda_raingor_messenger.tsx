import {
	type ReactNode,
	useCallback,
	useEffect,
	useRef,
	useState,
} from 'react';
import {
	Box,
	Button,
	Icon,
	Input,
	Section,
	Stack,
	TextArea,
} from 'tgui-core/components';
import { useBackend } from '../../backend';

type Contact = { label: string; value: string; has_private_chat: boolean };
type Profile = { id: string; name: string; photo?: string };
type Chat = {
	chat_id: string;
	name_chat: string;
	description_chat?: string;
	is_group: boolean;
	is_public: boolean;
	owner_id?: string;
	member_count: number;
	unread_count: number;
};
type Message = {
	id: number;
	text_message: string;
	timestamp: string;
	sender_id?: string;
	sender_name: string;
};
type ChatDetails = {
	chat_id: string;
	chat_members: Profile[];
	messages: Message[];
};

type CrewCall = {
	id: string;
	state: 'incoming' | 'ringing' | 'connected';
	chat_name: string;
	caller_name: string;
	is_group: boolean;
	connected_count: number;
	frequency: string | null;
	mic_on: boolean;
	quiet: boolean;
};

type InCrewData =
	| { can_login: false }
	| {
			can_login: true;
			owner_messenger_account: Profile;
			chats: Chat[];
			contacts: Contact[];
			blocked_contacts: Pick<Profile, 'id' | 'name'>[];
			max_group_members: number;
			public_groups: Chat[] | null;
			active_chat?: ChatDetails;
			call: CrewCall | null;
			call_busy: boolean;
	  };

export const pda_raingor_messenger = () => {
	const { data } = useBackend<InCrewData>();

	if (!data.can_login) {
		return (
			<InCrewCard icon="id-card">
				<Box textAlign="center">
					Вставьте ID-карту, привязанную к вашему личному счёту.
				</Box>
			</InCrewCard>
		);
	}

	return (
		<Stack key={data.owner_messenger_account.id} vertical fill>
			{data.call && <CallPanel call={data.call} />}
			<Stack.Item grow minHeight={0} overflowY="auto">
				<InCrew data={data} />
			</Stack.Item>
		</Stack>
	);
};

function CallPanel({ call }: { call: CrewCall }) {
	const { act } = useBackend();
	const incoming = call.state === 'incoming';
	const connected = call.state === 'connected';
	const quiet = !!call.quiet;
	const params = { callId: call.id };

	return (
		<Section className="card--hero">
			<Stack vertical>
				<Box bold className="text-gold increw-wrap">
					<Icon
						name={connected ? 'broadcast-tower' : 'phone'}
						mr={0.5}
					/>
					{connected
						? 'В эфире'
						: incoming
							? quiet
								? 'Вызов без звука'
								: 'Входящий вызов'
							: 'Вызов…'}
					{' · '}
					{incoming && !call.is_group
						? call.caller_name
						: call.chat_name}
				</Box>
				{incoming && !!call.is_group && (
					<Box>Вызывает {call.caller_name}</Box>
				)}
				{connected && (
					<Box>
						Частота {call.frequency} · В эфире{' '}
						{call.connected_count}
					</Box>
				)}
				{connected && !!call.mic_on && (
					<Box className="text-muted">
						Обычная речь передаётся в радиоэфир.
					</Box>
				)}
				<Stack wrap>
					{incoming && (
						<Button
							icon="phone"
							color="good"
							onClick={() => act('accept_call', params)}
						>
							Принять
						</Button>
					)}
					{connected && (
						<Button
							className="btn-bank"
							icon={
								call.mic_on ? 'microphone' : 'microphone-slash'
							}
							onClick={() => act('toggle_call_mic', params)}
						>
							{call.mic_on
								? 'Выключить микрофон'
								: 'Включить микрофон'}
						</Button>
					)}
					{(!incoming || !quiet) && (
						<Button
							icon="phone-slash"
							color="bad"
							onClick={() =>
								act(
									incoming ? 'decline_call' : 'leave_call',
									params,
								)
							}
						>
							{incoming
								? 'Отклонить'
								: connected
									? 'Положить трубку'
									: 'Отменить вызов'}
						</Button>
					)}
				</Stack>
			</Stack>
		</Section>
	);
}

function InCrewCard({ icon, children }: { icon: string; children: ReactNode }) {
	return (
		<Section className="card--hero">
			<Stack vertical align="center" p={2}>
				<Icon name={icon} className="text-gold" size={2.5} />
				<Box bold fontSize={1.8} className="text-gold">
					InCrew
				</Box>
				<Box
					fontSize="0.85em"
					className="text-white"
					textAlign="center"
					style={{ letterSpacing: '0.12em' }}
				>
					Black Rain Group
				</Box>
				<Box className="divider" style={{ width: '60%', margin: 0 }} />
				{children}
			</Stack>
		</Section>
	);
}

function Avatar({ photo }: { photo?: string }) {
	return photo ? (
		<span className="increw-avatar">
			<img src={photo} alt="" />
		</span>
	) : (
		<Icon name="user-circle" className="text-gold" />
	);
}

function InCrew({ data }: { data: Extract<InCrewData, { can_login: true }> }) {
	const { act } = useBackend();
	const [page, setPage] = useState<
		'home' | 'contacts' | 'create' | 'about' | 'blocked'
	>('home');
	const {
		active_chat,
		blocked_contacts,
		call_busy,
		chats,
		contacts,
		max_group_members,
		owner_messenger_account,
		public_groups,
	} = data;
	const chat = chats.find((item) => item.chat_id === active_chat?.chat_id);

	if (chat && active_chat) {
		return (
			<Conversation
				key={chat.chat_id}
				chat={chat}
				details={active_chat}
				profile={owner_messenger_account}
				contacts={contacts}
				maxMembers={max_group_members}
				callBusy={call_busy}
			/>
		);
	}

	if (public_groups) {
		return (
			<PublicGroups
				groups={public_groups}
				chats={chats}
				maxMembers={max_group_members}
			/>
		);
	}

	if (page === 'create') {
		return (
			<CreateGroup
				contacts={contacts}
				maxMembers={max_group_members}
				onClose={() => setPage('home')}
			/>
		);
	}

	if (page === 'about') {
		return <AboutInCrew onClose={() => setPage('home')} />;
	}

	if (page === 'blocked') {
		return (
			<BlockedContacts
				blocked={blocked_contacts}
				contacts={contacts}
				onClose={() => setPage('home')}
			/>
		);
	}

	return (
		<Stack vertical fill>
			<InCrewCard icon="comments">
				<Stack align="center" justify="center" wrap="wrap">
					<Avatar photo={owner_messenger_account.photo} />
					<Box bold>{owner_messenger_account.name}</Box>
					<Button
						className="btn-bank"
						icon="info-circle"
						onClick={() => setPage('about')}
					>
						О InCrew
					</Button>
					<Button
						className="btn-bank"
						icon="ban"
						onClick={() => setPage('blocked')}
					>
						Чёрный список
					</Button>
				</Stack>
			</InCrewCard>
			<Box className="increw-actions">
				<QuickAction
					icon="comment"
					label="Новый диалог"
					selected={page === 'contacts'}
					onClick={() =>
						setPage(page === 'contacts' ? 'home' : 'contacts')
					}
				/>
				<QuickAction
					icon="users"
					label="Создать группу"
					onClick={() => setPage('create')}
				/>
				<QuickAction
					icon="globe"
					label="Открытые группы"
					onClick={() => {
						setPage('home');
						act('show_public_groups');
					}}
				/>
			</Box>
			{page === 'contacts' && (
				<Section title="Собеседник">
					<ContactPicker
						contacts={contacts.filter(
							(contact) => !contact.has_private_chat,
						)}
						onSelect={(contact) => {
							act('create_private_chat', {
								target: contact.value,
							});
							setPage('home');
						}}
					/>
				</Section>
			)}
			<Section
				title={
					<Box className="text-gold">
						<Icon name="inbox" mr={0.5} />
						Чаты
					</Box>
				}
				fill
				scrollable
			>
				{!chats.length && (
					<Box italic className="text-muted" textAlign="center" p={2}>
						Нет активных диалогов
					</Box>
				)}
				{chats.map((item) => (
					<Button
						key={item.chat_id}
						className="btn-bank"
						fluid
						mb={0.5}
						p={1}
						onClick={() =>
							act('open_chat', { chatId: item.chat_id })
						}
					>
						<Stack align="center">
							<Icon
								name={
									item.is_public
										? 'globe'
										: item.is_group
											? 'users'
											: 'comment'
								}
								className="text-gold"
							/>
							<Stack.Item grow style={{ whiteSpace: 'normal' }}>
								{item.name_chat}
							</Stack.Item>
							{!!item.is_group && (
								<Box className="text-muted">
									{item.member_count} уч.
								</Box>
							)}
							{item.unread_count > 0 && (
								<Box
									className="increw-unread"
									aria-label={`Непрочитанных сообщений: ${item.unread_count}`}
								>
									{item.unread_count}
								</Box>
							)}
							<Icon name="chevron-right" className="text-gold" />
						</Stack>
					</Button>
				))}
			</Section>
		</Stack>
	);
}

function BlockedContacts({
	blocked,
	contacts,
	onClose,
}: {
	blocked: Pick<Profile, 'id' | 'name'>[];
	contacts: Contact[];
	onClose: () => void;
}) {
	const { act } = useBackend();

	return (
		<Section
			className="increw-section"
			title={
				<Box className="text-gold">
					<Icon name="ban" mr={0.5} />
					Чёрный список
				</Box>
			}
			buttons={
				<Button
					className="btn-bank"
					icon="arrow-left"
					onClick={onClose}
				>
					Назад
				</Button>
			}
			fill
			scrollable
		>
			{blocked.map((contact) => (
				<Box key={contact.id} className="card" p={1} mb={0.5}>
					<Stack align="center" wrap>
						<Stack.Item grow className="increw-wrap">
							{contact.name}
						</Stack.Item>
						<Button
							className="btn-bank"
							onClick={() =>
								act('unblock_contact', { target: contact.id })
							}
						>
							Разблокировать
						</Button>
					</Stack>
				</Box>
			))}
			{!blocked.length && (
				<Box className="text-muted" mb={1}>
					Список пуст
				</Box>
			)}
			<Box className="field-label" mt={1}>
				Заблокировать контакт
			</Box>
			<ContactPicker
				contacts={contacts}
				onSelect={(contact) =>
					act('block_contact', { target: contact.value })
				}
			/>
		</Section>
	);
}

function QuickAction({
	icon,
	label,
	selected = false,
	onClick,
}: {
	icon: string;
	label: string;
	selected?: boolean;
	onClick: () => void;
}) {
	return (
		<Button
			className="btn-bank increw-action"
			selected={selected}
			fluid
			onClick={onClick}
		>
			<Stack vertical align="center">
				<Icon name={icon} className="text-gold" size={1.8} />
				<Box>{label}</Box>
			</Stack>
		</Button>
	);
}

function PublicGroups({
	groups,
	chats,
	maxMembers,
}: {
	groups: Chat[];
	chats: Chat[];
	maxMembers: number;
}) {
	const { act } = useBackend();
	const joined = new Set(chats.map((chat) => chat.chat_id));

	return (
		<Section
			className="increw-section"
			title={
				<Box className="text-gold">
					<Icon name="globe" mr={0.5} />
					Открытые группы
				</Box>
			}
			buttons={
				<Button
					className="btn-bank"
					icon="arrow-left"
					onClick={() => act('hide_public_groups')}
				>
					Назад
				</Button>
			}
			fill
			scrollable
		>
			{!groups.length && (
				<Box italic className="text-muted" textAlign="center" p={2}>
					Открытых групп пока нет
				</Box>
			)}
			{groups.map((group) => {
				const isMember = joined.has(group.chat_id);
				const isFull = group.member_count >= maxMembers;
				return (
					<Box key={group.chat_id} className="card" p={1} mb={0.75}>
						<Stack align="center" wrap="wrap">
							<Stack.Item grow minWidth="0">
								<Box bold className="text-gold increw-wrap">
									{group.name_chat}
								</Box>
								<Box className="text-muted">
									{group.member_count} / {maxMembers}{' '}
									участников
								</Box>
							</Stack.Item>
							<Button
								className="btn-bank"
								icon={isMember ? 'comment' : 'sign-in-alt'}
								disabled={!isMember && isFull}
								onClick={() =>
									act(
										isMember
											? 'open_chat'
											: 'join_public_group',
										{ chatId: group.chat_id },
									)
								}
							>
								{isMember
									? 'Открыть'
									: isFull
										? 'Мест нет'
										: 'Вступить'}
							</Button>
						</Stack>
						{group.description_chat && (
							<Box mt={0.5} className="increw-wrap">
								{group.description_chat}
							</Box>
						)}
					</Box>
				);
			})}
		</Section>
	);
}

function ContactPicker({
	contacts,
	onSelect,
}: {
	contacts: Contact[];
	onSelect: (contact: Contact) => void;
}) {
	const [query, setQuery] = useState('');
	const search = query.trim().toLocaleLowerCase();
	const matches = contacts
		.filter((contact) => contact.label.toLocaleLowerCase().includes(search))
		.slice(0, 8);

	return (
		<Stack vertical>
			<Input
				className="input-field"
				fluid
				placeholder="Поиск сотрудника…"
				value={query}
				onChange={setQuery}
			/>
			{!!search &&
				(matches.length ? (
					matches.map((contact) => (
						<Button
							key={contact.value}
							className="btn-bank"
							icon="plus"
							fluid
							onClick={() => {
								onSelect(contact);
								setQuery('');
							}}
						>
							{contact.label}
						</Button>
					))
				) : (
					<Box className="text-muted">Никого не найдено</Box>
				))}
		</Stack>
	);
}

function Conversation({
	chat,
	details,
	profile,
	contacts,
	maxMembers,
	callBusy,
}: {
	chat: Chat;
	details: ChatDetails;
	profile: Profile;
	contacts: Contact[];
	maxMembers: number;
	callBusy: boolean;
}) {
	const { act } = useBackend();
	const [draft, setDraft] = useState('');
	const [showMembers, setShowMembers] = useState(false);
	const history = useRef<HTMLDivElement>(null);
	const atBottom = useRef(true);
	const lastReadSent = useRef<number>(0);
	const isOwner = chat.owner_id === profile.id;
	const canDelete = !chat.is_group || isOwner;
	const chatId = chat.chat_id;
	const latestMessageId = details.messages.at(-1)?.id;
	const members = new Map(
		details.chat_members.map((member) => [member.id, member]),
	);

	const readLatest = useCallback(() => {
		if (
			chat.unread_count > 0 &&
			latestMessageId &&
			latestMessageId !== lastReadSent.current
		) {
			lastReadSent.current = latestMessageId;
			act('read_chat', { chatId, messageId: latestMessageId });
		}
	}, [act, chat.unread_count, chatId, latestMessageId]);

	useEffect(() => {
		if (!showMembers && history.current && atBottom.current) {
			history.current.scrollTop = history.current.scrollHeight;
			readLatest();
		}
	}, [readLatest, showMembers]);

	const sendMessage = () => {
		if (draft.trim()) {
			act('send_message', { chatId, message: draft });
			setDraft('');
		}
	};

	return (
		<Stack vertical fill>
			<Section
				className="increw-section"
				title={
					<Box className="text-gold increw-wrap">
						<Icon
							name={
								chat.is_public
									? 'globe'
									: chat.is_group
										? 'users'
										: 'comment'
							}
							mr={0.5}
						/>
						{chat.name_chat}
					</Box>
				}
				buttons={
					<>
						<Button
							className="btn-bank"
							icon="arrow-left"
							tooltip="К списку чатов"
							onClick={() => act('close_chat')}
						/>
						<Button
							className="btn-bank"
							icon="phone"
							disabled={callBusy}
							tooltip={
								chat.is_group
									? 'Начать конференцию'
									: 'Позвонить'
							}
							onClick={() => act('start_call', { chatId })}
						/>
						<Button
							icon="users"
							selected={showMembers}
							tooltip={
								isOwner ? 'Участники и доступ' : 'Участники'
							}
							onClick={() => setShowMembers(!showMembers)}
						/>
						<Button.Confirm
							icon={canDelete ? 'trash' : 'sign-out-alt'}
							color="bad"
							tooltip={
								canDelete ? 'Удалить чат' : 'Покинуть группу'
							}
							confirmContent={
								canDelete ? 'Удалить?' : 'Покинуть?'
							}
							onClick={() =>
								act(canDelete ? 'delete_chat' : 'leave_chat', {
									chatId,
								})
							}
						/>
					</>
				}
			>
				{chat.description_chat && (
					<Box className="text-muted increw-wrap">
						{chat.description_chat}
					</Box>
				)}
			</Section>
			{showMembers ? (
				<Section title="Участники" fill scrollable>
					{!!chat.is_group && (
						<Box className="secure-notice" mb={0.75}>
							<Box className="text-gold" bold>
								<Icon
									name={chat.is_public ? 'globe' : 'lock'}
									mr={0.5}
								/>
								{chat.is_public
									? 'Открытая группа'
									: 'Закрытая группа'}
							</Box>
							<Box mt={0.25}>
								{chat.is_public
									? 'Вступить может любой сотрудник с InCrew.'
									: 'Вход по приглашению владельца.'}
							</Box>
							{isOwner && (
								<Button.Confirm
									className="btn-bank"
									icon={chat.is_public ? 'lock' : 'globe'}
									mt={0.5}
									confirmContent={
										chat.is_public
											? 'Подтвердить'
											: 'Открыть доступ к истории?'
									}
									onClick={() =>
										act('set_group_visibility', {
											chatId,
											isPublic: !chat.is_public,
										})
									}
								>
									{chat.is_public
										? 'Закрыть группу'
										: 'Сделать открытой'}
								</Button.Confirm>
							)}
						</Box>
					)}
					{details.chat_members.map((member) => (
						<Box key={member.id} className="card" p={1} mb={0.5}>
							<Stack align="center">
								<Avatar photo={member.photo} />
								<Stack.Item grow className="increw-wrap">
									{member.name}
									{member.id === chat.owner_id && (
										<Box className="text-muted">
											Владелец
										</Box>
									)}
								</Stack.Item>
								{member.id !== profile.id && (
									<Button.Confirm
										icon="ban"
										tooltip="Заблокировать контакт"
										confirmContent="В чёрный список?"
										onClick={() =>
											act('block_contact', {
												target: member.id,
											})
										}
									/>
								)}
								{isOwner && member.id !== profile.id && (
									<Button
										icon="times"
										color="bad"
										tooltip="Исключить из группы"
										onClick={() =>
											act('remove_member_from_chat', {
												chatId,
												target: member.id,
											})
										}
									/>
								)}
							</Stack>
						</Box>
					))}
					{isOwner && chat.member_count < maxMembers && (
						<Box mt={1}>
							<Box className="field-label">
								Добавить участника
							</Box>
							<ContactPicker
								contacts={contacts.filter(
									(contact) => !members.has(contact.value),
								)}
								onSelect={(contact) =>
									act('add_member_to_chat', {
										chatId,
										target: contact.value,
									})
								}
							/>
						</Box>
					)}
				</Section>
			) : (
				<>
					<Section
						ref={history}
						fill
						scrollable
						onScroll={() => {
							const panel = history.current;
							if (!panel) return;
							atBottom.current =
								panel.scrollHeight -
									panel.scrollTop -
									panel.clientHeight <=
								1;
							if (atBottom.current) readLatest();
						}}
					>
						{!details.messages.length && (
							<Box
								italic
								className="text-muted"
								textAlign="center"
								p={2}
							>
								Нет сообщений
							</Box>
						)}
						{details.messages.map((message) => {
							const photo =
								message.sender_id &&
								members.get(message.sender_id)?.photo;
							const outgoing = message.sender_id === profile.id;
							return (
								<Box
									key={message.id}
									className={
										outgoing
											? 'increw-message increw-message--outgoing'
											: 'increw-message'
									}
									mb={0.5}
									p={0.75}
								>
									<Stack align="center" wrap="wrap" mb={0.25}>
										{message.sender_id && (
											<Avatar photo={photo} />
										)}
										<Box bold className="text-gold">
											{message.sender_name}
										</Box>
										<Box
											className="text-muted"
											fontSize="0.85em"
										>
											{message.timestamp}
										</Box>
									</Stack>
									{message.text_message}
								</Box>
							);
						})}
					</Section>
					<Box className="increw-composer">
						<Input
							className="input-field"
							fluid
							maxLength={1024}
							placeholder="Введите сообщение…"
							value={draft}
							onChange={setDraft}
							onEnter={sendMessage}
						/>
						<Button
							className="btn-bank increw-send"
							icon="paper-plane"
							disabled={!draft.trim()}
							onClick={sendMessage}
						>
							Отправить
						</Button>
					</Box>
				</>
			)}
		</Stack>
	);
}

function CreateGroup({
	contacts,
	maxMembers,
	onClose,
}: {
	contacts: Contact[];
	maxMembers: number;
	onClose: () => void;
}) {
	const { act } = useBackend();
	const [name, setName] = useState('');
	const [description, setDescription] = useState('');
	const [isPublic, setIsPublic] = useState(false);
	const [members, setMembers] = useState<Contact[]>([]);

	return (
		<Section
			className="increw-section"
			title={
				<Box className="text-gold">
					<Icon name="users" mr={0.5} />
					Создание группы
				</Box>
			}
			buttons={
				<Button
					className="btn-bank"
					icon="arrow-left"
					tooltip="Назад"
					onClick={onClose}
				/>
			}
		>
			<Stack vertical>
				<Box>
					<Box className="field-label">Название</Box>
					<Input
						className="input-field"
						aria-label="Название"
						fluid
						maxLength={80}
						value={name}
						onChange={setName}
					/>
				</Box>
				<Box>
					<Box className="field-label">Описание</Box>
					<TextArea
						className="input-field"
						aria-label="Описание"
						fluid
						maxLength={300}
						value={description}
						onChange={setDescription}
					/>
				</Box>
				<Box>
					<Box className="field-label">Доступ</Box>
					<Stack wrap="wrap">
						<Button
							icon="lock"
							selected={!isPublic}
							onClick={() => setIsPublic(false)}
						>
							Закрытая
						</Button>
						<Button
							icon="globe"
							selected={isPublic}
							onClick={() => setIsPublic(true)}
						>
							Открытая
						</Button>
					</Stack>
					<Box className="text-muted" mt={0.5}>
						{isPublic
							? 'Группа появится в каталоге. Вступившие получат доступ к её истории.'
							: 'Участники вступают по приглашению владельца.'}
					</Box>
				</Box>
				<Box>
					<Box className="field-label">Участники</Box>
					{members.map((member) => (
						<Button
							key={member.value}
							className="btn-bank"
							icon="times"
							tooltip="Убрать из списка"
							onClick={() =>
								setMembers(
									members.filter((item) => item !== member),
								)
							}
						>
							{member.label}
						</Button>
					))}
					{members.length < maxMembers - 1 && (
						<ContactPicker
							contacts={contacts.filter(
								(contact) =>
									!members.some(
										(member) =>
											member.value === contact.value,
									),
							)}
							onSelect={(contact) =>
								setMembers([...members, contact])
							}
						/>
					)}
				</Box>
			</Stack>
			<Button
				className="btn-bank btn-bank--primary"
				fluid
				icon="plus"
				disabled={!name.trim()}
				mt={1}
				onClick={() => {
					act('create_group_chat', {
						name,
						description,
						isPublic,
						members: members.map((member) => member.value),
					});
					onClose();
				}}
			>
				Создать группу
			</Button>
		</Section>
	);
}

function AboutInCrew({ onClose }: { onClose: () => void }) {
	return (
		<Section
			className="increw-section"
			title={
				<Box className="text-gold">
					<Icon name="info-circle" mr={0.5} />О InCrew
				</Box>
			}
			buttons={
				<Button
					className="btn-bank"
					icon="arrow-left"
					onClick={onClose}
				>
					Назад
				</Button>
			}
			fill
			scrollable
		>
			<InCrewCard icon="comments">
				<Box textAlign="center">Связь для экипажей и станций</Box>
			</InCrewCard>
			<Box className="lore-container" mt={1.5}>
				<Box className="lore-paragraph">
					<Box as="span" className="lore-highlight">
						InCrew
					</Box>{' '}
					— служба связи холдинга Black Rain Group. Первую версию
					сделали для ремонтных бригад BRG, которым нужно было
					передавать заявки и оставлять записи следующей смене.
				</Box>
				<Box className="lore-paragraph">
					Когда группа развернула сеть блюспейс-ретрансляторов для
					Raingor Interstellar Bank, на той же инфраструктуре выделили
					канал для связи экипажей. Со временем InCrew стал доступен и
					станциям, которые обслуживает холдинг.
				</Box>
				<Box className="lore-paragraph">
					Для объявлений и координации смены есть открытые группы. У
					рабочих бригад — закрытые каналы по приглашению. Личные
					разговоры остаются в отдельных диалогах.
				</Box>
				<Box className="card--quote">
					<Icon
						name="quote-left"
						className="lore-icon-decor"
						mr={0.5}
					/>
					«Смена меняется. Связь остаётся.»
				</Box>
			</Box>
		</Section>
	);
}
