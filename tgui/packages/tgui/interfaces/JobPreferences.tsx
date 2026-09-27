import type { CSSProperties, ReactNode } from 'react';
import {
  Box,
  Button,
  Dropdown,
  NoticeBox,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

enum JobPriority {
  High = 1,
  Medium = 2,
  Low = 3,
  Never = 4,
}

enum AlternateOption {
  RandomJob = 0,
  Civilian = 1,
  ReturnToLobby = 2,
}

type Job = {
  title: string;
  name: string;
  department: string | null;
  color: string;
  head: boolean;
  exclusive: boolean;
  priority: JobPriority;
  restriction: string | null;
  alt_titles: boolean;
  muted: boolean;
};

type Data = {
  jobs: Job[];
  alternate_option: AlternateOption;
  wiki: boolean;
};

const COLUMNS = [
  ['Command', 'Engineering', 'Science'],
  ['Medical', 'Security'],
  ['Supply', 'Service'],
  ['Legal', 'Civilian', 'Silicon'],
];

const PRIORITY_BUTTON_SIZE = '18px';

type PriorityButtonProps = {
  name: string;
  color: string;
  modifier?: string;
  enabled: boolean;
  onClick: () => void;
};

function PriorityButton(props: PriorityButtonProps) {
  const className = 'JobPreferences__priority';

  return (
    <Stack.Item height={PRIORITY_BUTTON_SIZE}>
      <Button
        className={classes([
          className,
          props.modifier && `${className}--${props.modifier}`,
        ])}
        color={props.enabled ? props.color : 'white'}
        circular
        onClick={props.onClick}
        tooltip={props.name}
        tooltipPosition="bottom"
        height={PRIORITY_BUTTON_SIZE}
        width={PRIORITY_BUTTON_SIZE}
      />
    </Stack.Item>
  );
}

function PriorityHeaders() {
  const className = 'JobPreferences__PriorityHeader';

  return (
    <Stack className="JobPreferences__PriorityHeaders">
      <Stack.Item grow />
      {['Никогда', 'Низкий', 'Средний', 'Высокий'].map((label) => (
        <Stack.Item key={label} className={className}>
          <span>{label}</span>
        </Stack.Item>
      ))}
    </Stack>
  );
}

type PriorityButtonsProps = {
  job: Job;
};

function PriorityButtons(props: PriorityButtonsProps) {
  const { act } = useBackend<Data>();
  const { job } = props;

  const setPriority = (level: JobPriority) => () =>
    act('set_job_preference', { job: job.title, level });

  const isOff = job.priority === JobPriority.Never;

  return (
    <Stack
      className="JobPreferences__buttons"
      align="center"
      justify="flex-end"
    >
      <PriorityButton
        name="Никогда"
        modifier="off"
        color="light-grey"
        enabled={isOff}
        onClick={setPriority(JobPriority.Never)}
      />
      {job.exclusive ? (
        <PriorityButton
          name="Да"
          color="green"
          enabled={!isOff}
          onClick={setPriority(JobPriority.Low)}
        />
      ) : (
        <>
          <PriorityButton
            name="Низкий"
            color="red"
            enabled={job.priority === JobPriority.Low}
            onClick={setPriority(JobPriority.Low)}
          />
          <PriorityButton
            name="Средний"
            color="yellow"
            enabled={job.priority === JobPriority.Medium}
            onClick={setPriority(JobPriority.Medium)}
          />
          <PriorityButton
            name="Высокий"
            color="green"
            enabled={job.priority === JobPriority.High}
            onClick={setPriority(JobPriority.High)}
          />
        </>
      )}
    </Stack>
  );
}

type JobRowProps = {
  job: Job;
};

function JobRow(props: JobRowProps) {
  const { act } = useBackend<Data>();
  const { job } = props;

  let name: ReactNode = job.name;
  if (job.alt_titles) {
    name = (
      <Tooltip
        content="Нажмите, чтобы выбрать альтернативное название"
        position="bottom-start"
      >
        <Box
          inline
          className="JobPreferences__altTitle"
          onClick={() => act('alt_title', { job: job.title })}
        >
          {job.name}
        </Box>
      </Tooltip>
    );
  }

  return (
    <Box
      className={classes([
        'JobPreferences__job',
        job.head && 'JobPreferences__job--head',
        job.muted && 'JobPreferences__job--muted',
        job.restriction && 'JobPreferences__job--restricted',
      ])}
      style={{ '--job-color': job.color } as CSSProperties}
    >
      <Box className="JobPreferences__name">{name}</Box>
      <Box className="JobPreferences__options">
        {job.restriction ? (
          <Box className="JobPreferences__restriction">{job.restriction}</Box>
        ) : (
          <PriorityButtons job={job} />
        )}
      </Box>
    </Box>
  );
}

type DepartmentProps = {
  department: string;
  jobs: Job[];
};

function Department(props: DepartmentProps) {
  const { department, jobs } = props;

  return (
    <Box
      className={classes([
        'JobPreferences__department',
        `JobPreferences__department--${department}`,
      ])}
    >
      {jobs.map((job) => (
        <JobRow key={job.title} job={job} />
      ))}
    </Box>
  );
}

function AlternateOptionDropdown() {
  const { act, data } = useBackend<Data>();

  const options = [
    {
      displayText: 'Стать гражданским, если должность недоступна',
      value: AlternateOption.Civilian,
    },
    {
      displayText: 'Случайная должность, если должность недоступна',
      value: AlternateOption.RandomJob,
    },
    {
      displayText: 'Вернуться в лобби, если должность недоступна',
      value: AlternateOption.ReturnToLobby,
    },
  ];

  const selection = options.find(
    (option) => option.value === data.alternate_option,
  )?.displayText;

  return (
    <Dropdown
      width="100%"
      selected={selection}
      options={options}
      onSelected={(option) => act('set_alternate_option', { option })}
    />
  );
}

function groupByDepartment(jobs: Job[]) {
  const departments: Record<string, Job[]> = {};
  for (const job of jobs) {
    const department = job.department || 'other';
    departments[department] ||= [];
    departments[department].push(job);
  }
  return departments;
}

export function JobPreferences() {
  const { act, data } = useBackend<Data>();
  const departments = groupByDepartment(data.jobs);

  const knownDepartments = COLUMNS.flat();
  const columns = COLUMNS.map((column) => [...column]);
  for (const department of Object.keys(departments)) {
    if (!knownDepartments.includes(department)) {
      columns[columns.length - 1].push(department);
    }
  }

  return (
    <Window width={1400} height={520}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Stack align="center">
              <Stack.Item>
                <Button icon="save" onClick={() => act('save')}>
                  Сохранить
                </Button>
              </Stack.Item>
              <Stack.Item>
                <Button.Confirm
                  icon="undo"
                  confirmContent="Сбросить все?"
                  onClick={() => act('reset')}
                >
                  Сброс
                </Button.Confirm>
              </Stack.Item>
              {!!data.wiki && (
                <Stack.Item>
                  <Button icon="question" onClick={() => act('wiki')}>
                    Узнать о выборе должности
                  </Button>
                </Stack.Item>
              )}
              <Stack.Item grow />
              <Stack.Item width="30%">
                <AlternateOptionDropdown />
              </Stack.Item>
            </Stack>
          </Stack.Item>
          {data.jobs.length === 0 && (
            <Stack.Item>
              <NoticeBox>
                Подсистема должностей ещё не успела создать должности,
                пожалуйста, повторите попытку позже.
              </NoticeBox>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Stack fill className="JobPreferences">
              {columns.map((column) => (
                <Stack.Item key={column[0]} className="JobPreferences__column">
                  <PriorityHeaders />
                  {column
                    .filter((department) => departments[department])
                    .map((department) => (
                      <Department
                        key={department}
                        department={department}
                        jobs={departments[department]}
                      />
                    ))}
                </Stack.Item>
              ))}
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
}
