import {
	type ReactNode,
	useCallback,
	useEffect,
	useId,
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

type Contact = { label: string; value: string };
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
	photo?: string;
	preview?: string;
	preview_time?: string;
	activity: number;
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
	older_before: number | null;
	showing_latest: boolean;
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
	| { can_login: false; can_sign_in: boolean }
	| {
			can_login: true;
			owner_messenger_account: Profile;
			chats: Chat[];
			contact_search: {
				query: string;
				picker: string;
				matches: Contact[];
			} | null;
			blocked_contacts: Pick<Profile, 'id' | 'name'>[];
			max_group_members: number;
			public_groups: Chat[] | null;
			active_chat?: ChatDetails;
			call: CrewCall | null;
			call_busy: boolean;
			plus: {
				active: boolean;
				available: boolean;
				cost: number;
				minutes: number;
			};
	  };

export const pda_raingor_messenger = () => {
	const { act, data } = useBackend<InCrewData>();

	if (!data.can_login) {
		return (
			<div className="increw-app">
				<InCrewCard icon="id-card">
					{data.can_sign_in ? (
						<Button
							className="increw-primary"
							icon="sign-in-alt"
							onClick={() => act('sign_in')}
						>
							Войти в аккаунт
						</Button>
					) : (
						<Box textAlign="center">
							Вставьте ID-карту, привязанную к вашему личному
							счёту.
						</Box>
					)}
				</InCrewCard>
			</div>
		);
	}

	return (
		<Stack
			key={data.owner_messenger_account.id}
			className="increw-app"
			vertical
			fill
		>
			<div className="increw-brand">
				<Icon name="broadcast-tower" />
				<strong>InCrew</strong>
				<span>Black Rain Group</span>
			</div>
			{data.call && <CallPanel call={data.call} />}
			<Stack.Item
				grow
				minHeight={0}
				overflowY="auto"
				className="increw-body"
			>
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
		<span className="increw-avatar increw-avatar--fallback">
			<Icon name="user" />
		</span>
	);
}

const tabs = [
	{ id: 'chats', label: 'Чаты', icon: 'comments' },
	{ id: 'groups', label: 'Группы', icon: 'users' },
	{ id: 'calls', label: 'Звонки', icon: 'phone' },
] as const;

function InCrew({ data }: { data: Extract<InCrewData, { can_login: true }> }) {
	const { act } = useBackend();
	const [page, setPage] = useState<
		'home' | 'contacts' | 'create' | 'about' | 'blocked'
	>('home');
	const [tab, setTab] = useState<(typeof tabs)[number]['id']>('chats');
	const {
		active_chat,
		blocked_contacts,
		call_busy,
		chats,
		max_group_members,
		owner_messenger_account,
		plus,
		public_groups,
	} = data;
	const chat = chats.find((item) => item.chat_id === active_chat?.chat_id);
	const catalogOpen =
		!!plus.active && tab === 'groups' && page === 'home' && !active_chat;
	const catalogLoaded = public_groups !== null;

	useEffect(() => {
		if (catalogOpen !== catalogLoaded) {
			act(catalogOpen ? 'show_public_groups' : 'hide_public_groups');
		}
	}, [act, catalogOpen, catalogLoaded]);

	if (chat && active_chat) {
		return (
			<Conversation
				key={chat.chat_id}
				chat={chat}
				details={active_chat}
				profile={owner_messenger_account}
				maxMembers={max_group_members}
				callBusy={call_busy}
				canCall={!!plus.active}
			/>
		);
	}

	if (page === 'create' && plus.active) {
		return (
			<CreateGroup
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
				onClose={() => setPage('home')}
			/>
		);
	}

	return (
		<div className="increw-screen">
			<div className="increw-toolbar">
				<Avatar photo={owner_messenger_account.photo} />
				<span
					className="increw-ellipsis"
					title={owner_messenger_account.name}
				>
					{owner_messenger_account.name}
				</span>
				<Button
					icon="info-circle"
					tooltip="О InCrew"
					onClick={() => setPage('about')}
				/>
				<Button
					icon="ban"
					tooltip="Чёрный список"
					onClick={() => setPage('blocked')}
				/>
				<Button
					icon="sign-out-alt"
					tooltip="Выйти из аккаунта"
					onClick={() => act('sign_out')}
				>
					Выйти
				</Button>
			</div>
			{tab !== 'chats' && !plus.active ? (
				<div className="increw-list">
					<Section title="Оплатите подписку">
						<Box mb={1}>
							InCrew Plus открывает групповые чаты и исходящие
							звонки. {plus.cost} кредитов каждые {plus.minutes}{' '}
							мин.
						</Box>
						<Box mb={0.5}>
							Первый платёж и доступ сразу. Продление по
							банковскому расписанию.
						</Box>
						<Button
							className="increw-primary"
							icon="credit-card"
							disabled={!plus.available}
							onClick={() => act('subscribe_plus')}
						>
							Оплатить {plus.cost} кредитов
						</Button>
					</Section>
				</div>
			) : tab === 'groups' ? (
				<GroupDirectory
					groups={public_groups}
					chats={chats}
					maxMembers={max_group_members}
					onCreate={() => setPage('create')}
				/>
			) : (
				<ChatList
					key={tab}
					chats={chats}
					calls={tab === 'calls'}
					callBusy={call_busy}
					showContacts={page === 'contacts'}
					onNewChat={() =>
						setPage(page === 'contacts' ? 'home' : 'contacts')
					}
					onContactSelected={() => setPage('home')}
				/>
			)}
			<nav className="increw-tabs" aria-label="Разделы InCrew">
				{tabs.map(({ id, label, icon }) => (
					<Button
						key={id}
						selected={tab === id}
						aria-pressed={tab === id}
						onClick={() => {
							setPage('home');
							setTab(id);
						}}
					>
						<Icon name={icon} />
						{label}
					</Button>
				))}
			</nav>
		</div>
	);
}

function ChatList({
	chats,
	calls,
	callBusy,
	showContacts,
	onNewChat,
	onContactSelected,
}: {
	chats: Chat[];
	calls: boolean;
	callBusy: boolean;
	showContacts: boolean;
	onNewChat: () => void;
	onContactSelected: () => void;
}) {
	const { act } = useBackend();
	const [query, setQuery] = useState('');
	const search = query.trim().toLowerCase();
	const matches = chats
		.filter((chat) => chat.name_chat.toLowerCase().includes(search))
		.sort((a, b) => b.activity - a.activity);

	return (
		<>
			<div className="increw-search">
				<Input
					fluid
					aria-label="Поиск по чатам"
					placeholder="Поиск по чатам…"
					value={query}
					onChange={setQuery}
				/>
				{!calls && (
					<Button
						icon="plus"
						tooltip="Новый диалог"
						selected={showContacts}
						onClick={onNewChat}
					/>
				)}
			</div>
			<div className="increw-list">
				{showContacts && (
					<Section title="Новый диалог">
						<ContactPicker
							privateOnly
							onSelect={(contact) => {
								act('create_private_chat', {
									target: contact.value,
								});
								onContactSelected();
							}}
						/>
					</Section>
				)}
				{!matches.length && (
					<div className="increw-empty">
						{search
							? 'Ничего не найдено'
							: calls
								? 'Начните диалог, чтобы позвонить'
								: 'Нет активных диалогов'}
					</div>
				)}
				{matches.map((item) => (
					<div className="increw-list-entry" key={item.chat_id}>
						<Button
							className="increw-chat-row"
							onClick={() =>
								act('open_chat', { chatId: item.chat_id })
							}
						>
							{item.is_group ? (
								<Icon
									name="users"
									className="increw-group-avatar"
								/>
							) : (
								<Avatar photo={item.photo} />
							)}
							<span className="increw-row-copy">
								<strong className="increw-ellipsis">
									{item.name_chat}
								</strong>
								{!calls && item.preview && (
									<span className="increw-ellipsis">
										{item.preview}
									</span>
								)}
							</span>
							{!calls && (
								<span className="increw-row-meta">
									{item.preview_time?.slice(0, 5)}
									{item.unread_count > 0 && (
										<span
											className="increw-unread"
											aria-label={`Непрочитанных сообщений: ${item.unread_count}`}
										>
											{item.unread_count}
										</span>
									)}
								</span>
							)}
						</Button>
						{calls && (
							<Button
								icon="phone"
								tooltip={
									item.is_group
										? 'Начать конференцию'
										: 'Позвонить'
								}
								disabled={callBusy}
								onClick={() =>
									act('start_call', { chatId: item.chat_id })
								}
							/>
						)}
					</div>
				))}
			</div>
		</>
	);
}

function InCrewPage({
	icon,
	title,
	onClose,
	children,
}: {
	icon: string;
	title: string;
	onClose: () => void;
	children: ReactNode;
}) {
	return (
		<Section
			className="increw-section"
			title={
				<Box className="text-gold">
					<Icon name={icon} mr={0.5} />
					{title}
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
			{children}
		</Section>
	);
}

function BlockedContacts({
	blocked,
	onClose,
}: {
	blocked: Pick<Profile, 'id' | 'name'>[];
	onClose: () => void;
}) {
	const { act } = useBackend();

	return (
		<InCrewPage icon="ban" title="Чёрный список" onClose={onClose}>
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
				onSelect={(contact) =>
					act('block_contact', { target: contact.value })
				}
			/>
		</InCrewPage>
	);
}

function GroupDirectory({
	groups,
	chats,
	maxMembers,
	onCreate,
}: {
	groups: Chat[] | null;
	chats: Chat[];
	maxMembers: number;
	onCreate: () => void;
}) {
	const { act } = useBackend();
	const [query, setQuery] = useState('');
	const [onlyJoined, setOnlyJoined] = useState(false);
	const search = query.trim().toLowerCase();
	const joined = new Set(chats.map((chat) => chat.chat_id));
	const directory = [
		...(groups || []).filter((group) => !joined.has(group.chat_id)),
		...chats.filter((chat) => chat.is_group),
	].filter(
		(group) =>
			(!onlyJoined || joined.has(group.chat_id)) &&
			group.name_chat.toLowerCase().includes(search),
	);

	return (
		<>
			<div className="increw-search">
				<Input
					fluid
					aria-label="Поиск групп"
					placeholder="Поиск по группам…"
					value={query}
					onChange={setQuery}
				/>
				<Button icon="plus" tooltip="Создать группу" onClick={onCreate}>
					Создать
				</Button>
			</div>
			<div className="increw-group-filters">
				<Button
					selected={!onlyJoined}
					aria-pressed={!onlyJoined}
					onClick={() => setOnlyJoined(false)}
				>
					Все группы
				</Button>
				<Button
					selected={onlyJoined}
					aria-pressed={onlyJoined}
					onClick={() => setOnlyJoined(true)}
				>
					Мои группы
				</Button>
			</div>
			<div className="increw-list">
				{[
					{ open: true, title: 'Открытые', icon: 'globe' },
					{ open: false, title: 'Закрытые', icon: 'lock' },
				].map(({ open, title, icon }) => {
					const entries = directory.filter(
						(group) => !!group.is_public === open,
					);
					return (
						<details
							className="increw-group-section"
							key={title}
							open
						>
							<summary>
								<Icon name={icon} /> {title}{' '}
								<span>{entries.length}</span>
							</summary>
							{!entries.length && (
								<div className="increw-empty">
									{open && !onlyJoined && groups === null
										? 'Загрузка…'
										: 'Нет групп'}
								</div>
							)}
							{entries.map((group) => {
								const isMember = joined.has(group.chat_id);
								const isFull = group.member_count >= maxMembers;
								return (
									<div
										className="increw-list-entry"
										key={group.chat_id}
									>
										<Button
											className="increw-channel-row"
											tooltip={
												group.description_chat ||
												group.name_chat
											}
											disabled={!isMember && isFull}
											onClick={() =>
												act(
													isMember
														? 'open_chat'
														: 'join_public_group',
													{
														chatId: group.chat_id,
													},
												)
											}
										>
											<Icon
												name={open ? 'hashtag' : 'lock'}
											/>
											<strong className="increw-ellipsis">
												{group.name_chat}
											</strong>
											<span className="increw-row-meta">
												{isMember
													? `${group.member_count} уч.`
													: isFull
														? 'Мест нет'
														: 'Вступить'}
											</span>
										</Button>
									</div>
								);
							})}
						</details>
					);
				})}
			</div>
		</>
	);
}

function ContactPicker({
	onSelect,
	privateOnly = false,
	excluded = '',
}: {
	onSelect: (contact: Contact) => void;
	privateOnly?: boolean;
	excluded?: string;
}) {
	const { act, data } = useBackend<InCrewData>();
	const picker = useId();
	const [query, setQuery] = useState('');
	const search = query.trim();
	const response = data.can_login ? data.contact_search : null;
	const matches =
		response?.picker === picker && response.query === search
			? response.matches
			: null;

	useEffect(() => {
		if (!search) return;
		const timeout = window.setTimeout(() => {
			act('search_contacts', {
				query: search,
				picker,
				privateOnly,
				excluded: excluded ? excluded.split(',') : [],
			});
		}, 180);
		return () => window.clearTimeout(timeout);
	}, [act, excluded, picker, privateOnly, search]);

	return (
		<Stack vertical>
			<Input
				className="input-field"
				fluid
				maxLength={80}
				placeholder="Поиск сотрудника…"
				value={query}
				onChange={setQuery}
			/>
			{!!search &&
				matches &&
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
	maxMembers,
	callBusy,
	canCall,
}: {
	chat: Chat;
	details: ChatDetails;
	profile: Profile;
	maxMembers: number;
	callBusy: boolean;
	canCall: boolean;
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
			details.showing_latest &&
			chat.unread_count > 0 &&
			latestMessageId &&
			latestMessageId !== lastReadSent.current
		) {
			lastReadSent.current = latestMessageId;
			act('read_chat', { chatId, messageId: latestMessageId });
		}
	}, [
		act,
		chat.unread_count,
		chatId,
		details.showing_latest,
		latestMessageId,
	]);

	useEffect(() => {
		if (
			!showMembers &&
			details.showing_latest &&
			history.current &&
			atBottom.current
		) {
			history.current.scrollTop = history.current.scrollHeight;
			readLatest();
		}
	}, [details.showing_latest, readLatest, showMembers]);

	const sendMessage = () => {
		if (draft.trim()) {
			act('send_message', { chatId, message: draft });
			setDraft('');
		}
	};

	return (
		<Stack className="increw-conversation" vertical fill>
			<Section
				className="increw-section"
				title={
					<Stack align="center">
						<Button
							icon="arrow-left"
							tooltip="Назад"
							onClick={() => act('close_chat')}
						/>
						{chat.is_group ? (
							<Icon name="hashtag" />
						) : (
							<Avatar photo={chat.photo} />
						)}
						<Box className="increw-wrap">{chat.name_chat}</Box>
					</Stack>
				}
				buttons={
					<>
						{canCall && (
							<Button
								className="increw-primary"
								icon="phone"
								disabled={callBusy}
								tooltip={
									chat.is_group
										? 'Начать конференцию'
										: 'Позвонить'
								}
								onClick={() => act('start_call', { chatId })}
							/>
						)}
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
				{!!chat.is_group && !!chat.description_chat && (
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
								excluded={details.chat_members
									.map((member) => member.id)
									.join(',')}
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
					{(!!details.older_before || !details.showing_latest) && (
						<Stack justify="space-between">
							{!!details.older_before && (
								<Button
									className="btn-bank"
									icon="arrow-up"
									onClick={() => {
										atBottom.current = false;
										if (history.current)
											history.current.scrollTop = 0;
										act('older_messages', {
											chatId,
											before: details.older_before,
										});
									}}
								>
									Раньше
								</Button>
							)}
							{!details.showing_latest && (
								<Button
									className="btn-bank"
									icon="arrow-down"
									onClick={() => {
										atBottom.current = true;
										act('latest_messages', { chatId });
									}}
								>
									К новым
								</Button>
							)}
						</Stack>
					)}
					<div
						ref={history}
						className="increw-history"
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
							const variant = !message.sender_id
								? 'system'
								: chat.is_group
									? 'channel'
									: message.sender_id === profile.id
										? 'outgoing'
										: 'incoming';
							return (
								<Box
									key={message.id}
									className={`increw-message increw-message--${variant}`}
									mb={0.5}
									p={0.75}
								>
									<Stack align="center" wrap="wrap" mb={0.25}>
										{variant === 'incoming' && (
											<Avatar photo={photo} />
										)}
										{variant === 'channel' && (
											<Box bold>
												{message.sender_name}
											</Box>
										)}
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
					</div>
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
							className="increw-primary increw-send"
							icon="paper-plane"
							tooltip="Отправить"
							aria-label="Отправить"
							disabled={!draft.trim()}
							onClick={sendMessage}
						/>
					</Box>
				</>
			)}
		</Stack>
	);
}

function CreateGroup({
	maxMembers,
	onClose,
}: {
	maxMembers: number;
	onClose: () => void;
}) {
	const { act } = useBackend();
	const [name, setName] = useState('');
	const [description, setDescription] = useState('');
	const [isPublic, setIsPublic] = useState(false);
	const [members, setMembers] = useState<Contact[]>([]);

	return (
		<InCrewPage icon="users" title="Создание группы" onClose={onClose}>
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
							excluded={members
								.map((member) => member.value)
								.join(',')}
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
		</InCrewPage>
	);
}

function AboutInCrew({ onClose }: { onClose: () => void }) {
	return (
		<InCrewPage icon="info-circle" title="О InCrew" onClose={onClose}>
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
		</InCrewPage>
	);
}
