import { type ReactNode, useState } from 'react';
import {
	Box,
	Button,
	Icon,
	Image,
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
	owner_id?: string;
	member_count: number;
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

type InCrewData =
	| { can_login: false }
	| {
			can_login: true;
			owner_messenger_account: Profile;
			chats: Chat[];
			contacts: Contact[];
			active_chat?: ChatDetails;
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

	return <InCrew key={data.owner_messenger_account.id} data={data} />;
};

function InCrewCard({ icon, children }: { icon: string; children: ReactNode }) {
	return (
		<Section className="card--hero">
			<Stack vertical align="center" p={2}>
				<Icon name={icon} className="text-gold" size={2.5} />
				<Box bold fontSize={1.8} className="text-gold">
					InCrew
				</Box>
				<Box
					fontSize="12px"
					className="text-white"
					textAlign="center"
					style={{ letterSpacing: '1.5px' }}
				>
					BlackRainGroup
				</Box>
				<Box className="divider" style={{ width: '60%', margin: 0 }} />
				{children}
			</Stack>
		</Section>
	);
}

function InCrew({ data }: { data: Extract<InCrewData, { can_login: true }> }) {
	const { act } = useBackend();
	const [showContacts, setShowContacts] = useState(false);
	const [creatingGroup, setCreatingGroup] = useState(false);
	const { active_chat, chats, contacts, owner_messenger_account } = data;
	const chat = chats.find((item) => item.chat_id === active_chat?.chat_id);

	if (chat && active_chat) {
		return (
			<Conversation
				key={chat.chat_id}
				chat={chat}
				details={active_chat}
				profile={owner_messenger_account}
				contacts={contacts}
			/>
		);
	}

	if (creatingGroup) {
		return (
			<CreateGroup
				contacts={contacts}
				onClose={() => setCreatingGroup(false)}
			/>
		);
	}

	return (
		<Stack vertical fill>
			<InCrewCard icon="comments">
				<Box bold>
					<Icon name="user-circle" className="text-gold" mr={0.5} />
					{owner_messenger_account.name}
				</Box>
			</InCrewCard>
			<Stack>
				<Stack.Item grow basis={0}>
					<Button
						className={
							showContacts
								? 'btn-bank btn-bank--primary'
								: 'btn-bank'
						}
						fluid
						p={1.5}
						onClick={() => setShowContacts(!showContacts)}
					>
						<Stack vertical align="center">
							<Icon
								name="comment"
								className="text-gold"
								size={2}
							/>
							<Box>Новый диалог</Box>
						</Stack>
					</Button>
				</Stack.Item>
				<Stack.Item grow basis={0}>
					<Button
						className="btn-bank"
						fluid
						p={1.5}
						onClick={() => setCreatingGroup(true)}
					>
						<Stack vertical align="center">
							<Icon name="users" className="text-gold" size={2} />
							<Box>Создать группу</Box>
						</Stack>
					</Button>
				</Stack.Item>
			</Stack>
			{showContacts && (
				<Section title="Собеседник">
					<ContactPicker
						contacts={contacts.filter(
							(contact) => !contact.has_private_chat,
						)}
						onSelect={(contact) => {
							act('create_private_chat', {
								target: contact.value,
							});
							setShowContacts(false);
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
								name={item.is_group ? 'users' : 'comment'}
								className="text-gold"
							/>
							<Stack.Item grow style={{ whiteSpace: 'normal' }}>
								{item.name_chat}
							</Stack.Item>
							{item.is_group && (
								<Box className="text-muted">
									{item.member_count} уч.
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
}: {
	chat: Chat;
	details: ChatDetails;
	profile: Profile;
	contacts: Contact[];
}) {
	const { act } = useBackend();
	const [draft, setDraft] = useState('');
	const [showMembers, setShowMembers] = useState(false);
	const isOwner = chat.owner_id === profile.id;
	const canDelete = !chat.is_group || isOwner;
	const chatId = chat.chat_id;
	const members = new Map(
		details.chat_members.map((member) => [member.id, member]),
	);

	const sendMessage = () => {
		if (draft.trim()) {
			act('send_message', { chatId, message: draft });
			setDraft('');
		}
	};

	return (
		<Stack vertical fill>
			<Section
				title={
					<Box className="text-gold">
						<Icon
							name={chat.is_group ? 'users' : 'comment'}
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
							icon="users"
							selected={showMembers}
							tooltip="Участники"
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
					<Box className="text-muted">{chat.description_chat}</Box>
				)}
			</Section>
			{showMembers ? (
				<Section title="Участники" fill scrollable>
					{details.chat_members.map((member) => (
						<Box key={member.id} className="card" p={1} mb={0.5}>
							<Stack align="center">
								{member.photo ? (
									<Image
										src={member.photo}
										width={2}
										height={2}
									/>
								) : (
									<Icon
										name="user-circle"
										className="text-gold"
									/>
								)}
								<Stack.Item grow>
									{member.name}
									{member.id === chat.owner_id && (
										<Box className="text-muted">
											Владелец
										</Box>
									)}
								</Stack.Item>
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
					{isOwner && details.chat_members.length < 50 && (
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
					<Section fill scrollable>
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
									<Stack align="center" mb={0.25}>
										{!!photo && (
											<Image
												src={photo}
												width={2}
												height={2}
											/>
										)}
										<Box bold className="text-gold">
											{message.sender_name}
										</Box>
										<Box
											className="text-muted"
											fontSize="12px"
										>
											{message.timestamp}
										</Box>
									</Stack>
									{message.text_message}
								</Box>
							);
						})}
					</Section>
					<Stack align="center">
						<Stack.Item grow>
							<Input
								className="input-field"
								fluid
								maxLength={1024}
								placeholder="Введите сообщение…"
								value={draft}
								onChange={setDraft}
								onEnter={sendMessage}
							/>
						</Stack.Item>
						<Button
							className="btn-bank"
							icon="paper-plane"
							tooltip="Отправить"
							disabled={!draft.trim()}
							onClick={sendMessage}
						/>
					</Stack>
				</>
			)}
		</Stack>
	);
}

function CreateGroup({
	contacts,
	onClose,
}: {
	contacts: Contact[];
	onClose: () => void;
}) {
	const { act } = useBackend();
	const [name, setName] = useState('');
	const [description, setDescription] = useState('');
	const [members, setMembers] = useState<Contact[]>([]);

	return (
		<Section
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
					{members.length < 49 && (
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
