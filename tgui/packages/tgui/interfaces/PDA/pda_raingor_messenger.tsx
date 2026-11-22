import { useState } from 'react';
import {
	Box,
	Button,
	Image,
	Input,
	LabeledList,
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
			<Section title="Вход в InCrew">
				Вставьте ID-карту, привязанную к вашему личному счёту.
			</Section>
		);
	}

	return <InCrew key={data.owner_messenger_account.id} data={data} />;
};

function InCrew({ data }: { data: Extract<InCrewData, { can_login: true }> }) {
	const { act } = useBackend();
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
			<Section
				title={owner_messenger_account.name}
				buttons={
					<Button icon="users" onClick={() => setCreatingGroup(true)}>
						Создать группу
					</Button>
				}
			/>
			<Section title="Начать диалог">
				<ContactPicker
					contacts={contacts.filter(
						(contact) => !contact.has_private_chat,
					)}
					onSelect={(contact) =>
						act('create_private_chat', { target: contact.value })
					}
				/>
			</Section>
			<Section title="Чаты" fill scrollable>
				{!chats.length && (
					<Box color="label">Нет активных диалогов</Box>
				)}
				{chats.map((item) => (
					<Button
						key={item.chat_id}
						fluid
						icon={item.is_group ? 'users' : 'comment'}
						onClick={() =>
							act('open_chat', { chatId: item.chat_id })
						}
					>
						{item.name_chat}
						{item.is_group && ` · ${item.member_count} уч.`}
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
					<Box color="label">Никого не найдено</Box>
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
				title={chat.name_chat}
				buttons={
					<>
						<Button
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
				{chat.description_chat}
			</Section>
			{showMembers ? (
				<Section title="Участники" fill scrollable>
					{details.chat_members.map((member) => (
						<Stack key={member.id} align="center">
							<Stack.Item grow>
								{member.name}
								{member.id === chat.owner_id && ' · Владелец'}
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
					))}
					{isOwner && details.chat_members.length < 50 && (
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
					)}
				</Section>
			) : (
				<>
					<Section fill scrollable>
						{!details.messages.length && (
							<Box color="label">Нет сообщений</Box>
						)}
						{details.messages.map((message) => {
							const photo =
								message.sender_id &&
								members.get(message.sender_id)?.photo;
							const outgoing = message.sender_id === profile.id;
							return (
								<Box
									key={message.id}
									backgroundColor={
										outgoing
											? 'rgba(40, 115, 175, 0.25)'
											: 'rgba(128, 128, 128, 0.1)'
									}
									mb={0.5}
									p={0.5}
									style={{ overflowWrap: 'anywhere' }}
								>
									<Stack align="center">
										{!!photo && (
											<Image
												src={photo}
												width={2}
												height={2}
											/>
										)}
										<Box bold>{message.sender_name}</Box>
										<Box color="label">
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
								fluid
								maxLength={1024}
								placeholder="Введите сообщение…"
								value={draft}
								onChange={setDraft}
								onEnter={sendMessage}
							/>
						</Stack.Item>
						<Button
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
			title="Создание группы"
			buttons={
				<Button icon="arrow-left" tooltip="Назад" onClick={onClose} />
			}
		>
			<LabeledList>
				<LabeledList.Item label="Название">
					<Input
						fluid
						maxLength={80}
						value={name}
						onChange={setName}
					/>
				</LabeledList.Item>
				<LabeledList.Item label="Описание">
					<TextArea
						fluid
						maxLength={300}
						value={description}
						onChange={setDescription}
					/>
				</LabeledList.Item>
				<LabeledList.Item label="Участники">
					{members.map((member) => (
						<Button
							key={member.value}
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
				</LabeledList.Item>
			</LabeledList>
			<Button
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
