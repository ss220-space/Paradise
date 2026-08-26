import { useState } from 'react';
import {
	Button,
	ImageButton,
	ProgressBar,
	Section,
	Stack,
} from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type SwarmerCoreData = {
	classes: Class[];
	organic_resources: number;
	organic_goal: number;
	cheaper_swap: boolean;
	current_class_path: string;
};

type Class = {
	name: string;
	desc: string;
	path: string;
	icon: string;
	icon_state: string;
	additional_info: string;
	cost: number;
};

const SwarmerGoalProgressBar = (props: unknown) => {
	const { data } = useBackend<SwarmerCoreData>();
	const { organic_goal = 0, organic_resources = 0 } = data;

	return (
		<Stack.Item>
			<Section title="Выполнение цели (Органические ресурсы)">
				<Stack fill>
					<Stack.Item grow>
						<ProgressBar
							fontSize="small"
							color={
								organic_resources >= organic_goal
									? 'good'
									: 'average'
							}
							value={organic_resources}
							minValue={0}
							maxValue={organic_goal}
						>
							{organic_resources} / {organic_goal}
						</ProgressBar>
					</Stack.Item>
				</Stack>
			</Section>
		</Stack.Item>
	);
};

export const SwarmerCore = (_props: unknown) => {
	const { act, data } = useBackend<SwarmerCoreData>();
	const { classes, cheaper_swap, current_class_path } = data;
	const [selectedInfo, setSelectedInfo] = useState<string>('');
	const [selectedClass, setSelectedClass] = useState<Class | null>(null);

	const handleClassSelect = (classInfo: Class) => {
		setSelectedInfo(classInfo.additional_info);
		setSelectedClass(classInfo);
	};

	const handleConfirm = () => {
		if (selectedClass) {
			act('select_class', {
				class: selectedClass.path,
			});
		}
	};

	return (
		<Window width={800} height={600}>
			<Window.Content>
				<Stack fill vertical>
					<SwarmerGoalProgressBar />
					<Stack.Item grow>
						<Stack fill>
							<Stack.Item width={20}>
								<Section
									textAlign="center"
									title="Классы"
									fill
									scrollable
								>
									<Stack vertical fill>
										{classes.map((classInfo) =>
											current_class_path ===
											classInfo.path ? null : (
												<Stack.Item
													textAlign="center"
													key={classInfo.path}
												>
													<ImageButton
														color={'blue'}
														dmIcon={classInfo.icon}
														dmIconState={
															classInfo.icon_state
														}
														dmFallback={
															classInfo.name
														}
														imageSize={90}
														tooltip={
															<>
																<b>
																	{
																		classInfo.name
																	}
																</b>
																<br />
																{classInfo.desc}
															</>
														}
														onClick={() =>
															handleClassSelect(
																classInfo,
															)
														}
														fluid
														selected={
															selectedClass ===
															classInfo
														}
														title={classInfo.name}
													/>
												</Stack.Item>
											),
										)}
									</Stack>
								</Section>
							</Stack.Item>
							<Stack.Item grow>
								<Stack fill vertical>
									<Stack.Item grow>
										<Section
											title="Дополнительная информация"
											fill
											scrollable
											px={2}
										>
											<pre
												style={{
													fontFamily: 'inherit',
													margin: 5,
													fontSize: '15px',
													whiteSpace: 'pre-wrap',
													wordWrap: 'break-word',
												}}
											>
												{selectedInfo ||
													'Выберите класс для просмотра информации'}
											</pre>
										</Section>
									</Stack.Item>
									<Stack.Item>
										<Section>
											<Button
												fluid
												textAlign="center"
												lineHeight="35px"
												fontSize="1.2em"
												height="40px"
												disabled={!selectedClass}
												onClick={handleConfirm}
												color={
													selectedClass
														? 'green'
														: 'grey'
												}
											>
												{selectedClass
													? `Стоимость: ${cheaper_swap ? Math.round(selectedClass.cost / 2) : selectedClass.cost} металла. Подтвердить выбор: ${selectedClass.name}`
													: 'Выберите класс'}
											</Button>
										</Section>
									</Stack.Item>
								</Stack>
							</Stack.Item>
						</Stack>
					</Stack.Item>
				</Stack>
			</Window.Content>
		</Window>
	);
};
