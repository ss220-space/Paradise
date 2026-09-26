import fs from "fs";
import { CHANGELOG_ENTRIES } from "./changelogConfig.js";
import { get_updated_label_set } from "./autoLabel.js";
import { CHANGELOG_BRANCH_PREFIX } from "./autoChangelog.js";

const DEFAULT_MODELS = [
  "google/gemma-4-31b-it:free",
  "nvidia/nemotron-3-super-120b-a12b:free",
  "qwen/qwen3.8-27b:free",
];
const AI_ENDPOINT = "https://openrouter.ai/api/v1/chat/completions";
const DIFF_BUDGET = 60000;
const FILE_PATCH_LIMIT = 8000;
const SECTION_WHAT = "Что этот ПР делает";
const SECTION_WHY = "Почему это хорошо для игры";
const SECTION_CHANGELOG = "Список изменений";
const TRIGGER_LABEL = "AI описание";
const GENERATED_MARK = "<sub>Описание сгенерировано нейросетью, проверьте его.</sub>";

const REGEX_COMMENT = /<!--[\s\S]*?-->/g;
const SKIPPED_PATCH_EXTENSIONS = [".dmm", ".dmi", ".png", ".ogg", ".json", ".lock"];

const PREFIXES = CHANGELOG_ENTRIES.map(([names, meta]) => ({
  name: names[0],
  aliases: names,
  hint: meta.placeholders[0],
}));

function escapeRegex(string) {
  return string.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&");
}

function sectionRegex(title) {
  return new RegExp(
    `(^##\\s*${escapeRegex(title)}[^\\n]*\\n)([\\s\\S]*?)(?=^##\\s|(?![\\s\\S]))`,
    "m",
  );
}

export function getSection(body, title) {
  const match = body.match(sectionRegex(title));
  return match ? match[2] : null;
}

export function isSectionEmpty(body, title) {
  const section = getSection(body, title);
  return section === null || !section.replace(REGEX_COMMENT, "").trim();
}

function setSection(body, title, text) {
  const regex = sectionRegex(title);
  if (!regex.test(body)) {
    return `${body.trimEnd()}\n\n## ${title}\n\n${text}\n`;
  }
  return body.replace(regex, (_, header) => `${header}\n${text}\n\n`);
}

function removeSection(body, title) {
  return body.replace(sectionRegex(title), "");
}

function buildChangelog(section, entries) {
  const author = section.match(/^:cl:[ \t]*(.*)$/m)?.[1]?.trim() ?? "";
  const lines = entries.map(({ prefix, text }) => `${prefix}: ${text}`);
  return [`:cl:${author ? ` ${author}` : ""}`, ...lines, "/:cl:"].join("\n");
}

export function fillBody(body, generated) {
  let newBody = body.replace(REGEX_COMMENT, "").replace(/\n{3,}/g, "\n\n");

  newBody = setSection(
    newBody,
    SECTION_WHAT,
    `${generated.what.trim()}\n\n${GENERATED_MARK}`,
  );
  newBody = setSection(newBody, SECTION_WHY, generated.why.trim());

  if (generated.changelog.length) {
    const section = getSection(newBody, SECTION_CHANGELOG) ?? "";
    newBody = setSection(
      newBody,
      SECTION_CHANGELOG,
      buildChangelog(section, generated.changelog),
    );
  } else {
    newBody = removeSection(newBody, SECTION_CHANGELOG);
  }

  return newBody.replace(/\n{3,}/g, "\n\n").trim() + "\n";
}

function parseJsonReply(text) {
  const start = text.indexOf("{");
  const end = text.lastIndexOf("}");
  if (start === -1 || end <= start) {
    throw new Error(`Модель ответила не JSON: ${text.slice(0, 500)}`);
  }
  return JSON.parse(text.slice(start, end + 1));
}

export function normalizeGenerated(raw) {
  const data = typeof raw === "string" ? parseJsonReply(raw) : raw;
  const changelog = [];
  for (const entry of Array.isArray(data.changelog) ? data.changelog : []) {
    const prefix = PREFIXES.find(({ aliases }) =>
      aliases.includes(String(entry?.prefix ?? "").trim().toLowerCase()),
    );
    const text = String(entry?.text ?? "").replace(/\s+/g, " ").trim();
    if (prefix && text) {
      changelog.push({ prefix: prefix.name, text });
    }
  }
  return {
    what: String(data.what ?? "").trim(),
    why: String(data.why ?? "").trim(),
    changelog,
  };
}

async function collectDiff({ github, context }) {
  const files = await github.paginate(github.rest.pulls.listFiles, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: context.payload.pull_request.number,
    per_page: 100,
  });

  const summary = files
    .map((file) => `${file.status} ${file.filename} (+${file.additions} -${file.deletions})`)
    .join("\n");

  let budget = DIFF_BUDGET - summary.length;
  const patches = [];
  for (const file of files) {
    if (budget <= 0) {
      patches.push("... остальные файлы не влезли в лимит");
      break;
    }
    if (!file.patch || SKIPPED_PATCH_EXTENSIONS.some((ext) => file.filename.endsWith(ext))) {
      continue;
    }
    let patch = file.patch;
    if (patch.length > FILE_PATCH_LIMIT) {
      patch = `${patch.slice(0, FILE_PATCH_LIMIT)}\n... патч обрезан`;
    }
    patch = patch.slice(0, budget);
    budget -= patch.length;
    patches.push(`--- ${file.filename}\n${patch}`);
  }

  return `Файлы:\n${summary}\n\nДифф:\n${patches.join("\n\n")}`;
}

function buildMessages({ title, authorText, diff }) {
  const prefixList = PREFIXES.map(({ name, hint }) => `${name} — ${hint}`).join("\n");
  const system = `Ты заполняешь описание пул-реквеста для русскоязычного сервера Space Station 13 (кодбаза Paradise, язык DreamMaker/BYOND, интерфейсы tgui).
Пиши по-русски, коротко и по делу, только то, что видно из диффа. Ничего не выдумывай.
Ответь строго JSON-объектом:
{
  "what": "markdown: что делает PR, 2-6 пунктов списком",
  "why": "markdown: 1-3 предложения, почему это полезно для игры или разработки",
  "changelog": [{"prefix": "...", "text": "..."}]
}
changelog — только изменения, которые заметят игроки или администраторы. Если таких нет (чистый рефактор, CI, тесты), верни пустой массив.
Каждая запись changelog — одно законченное предложение в прошедшем времени, без упоминания файлов и процедур.
Допустимые префиксы:
${prefixList}`;

  const user = `Заголовок PR: ${title}
${authorText ? `\nЧто уже написал автор:\n${authorText}\n` : ""}
${diff}`;

  return [
    { role: "system", content: system },
    { role: "user", content: user },
  ];
}

async function generate(messages) {
  const response = await fetch(AI_ENDPOINT, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${process.env.AI_API_KEY}`,
      "Content-Type": "application/json",
      Accept: "application/json",
    },
    body: JSON.stringify({
      ...(process.env.AI_MODEL ? { model: process.env.AI_MODEL } : { models: DEFAULT_MODELS }),
      messages,
      temperature: 0.2,
      response_format: { type: "json_object" },
    }),
  });

  const text = await response.text();
  if (!response.ok) {
    throw new Error(`Нейросеть ответила ${response.status}: ${text.slice(0, 1000)}`);
  }

  let data;
  try {
    data = JSON.parse(text);
  } catch {
    throw new Error(`Эндпоинт вернул не JSON: ${text.slice(0, 500)}`);
  }

  const content = data.choices?.[0]?.message?.content;
  if (!content) {
    throw new Error(`Пустой ответ нейросети: ${text.slice(0, 1000)}`);
  }
  console.log(`Модель: ${data.model ?? "?"}`);
  return normalizeGenerated(content);
}

export async function fillPullRequestDescription({ github, context }) {
  const pull = context.payload.pull_request;
  const byLabel = context.payload.action === "labeled";

  if (byLabel && context.payload.label?.name !== TRIGGER_LABEL) {
    return;
  }

  if (pull.head?.ref?.startsWith(CHANGELOG_BRANCH_PREFIX)) {
    console.log("PR с changelog, пропускаю.");
    return;
  }

  if (!process.env.AI_API_KEY) {
    console.log("Секрет AI_API_KEY не задан, пропускаю.");
    return;
  }

  const currentBody =
    (
      await github.rest.pulls.get({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: pull.number,
      })
    ).data.body ||
    fs.readFileSync(".github/PULL_REQUEST_TEMPLATE.md", { encoding: "utf8" });

  if (!byLabel && !isSectionEmpty(currentBody, SECTION_WHAT)) {
    console.log("Автор уже заполнил описание, пропускаю.");
    return;
  }

  const authorText = [SECTION_WHAT, SECTION_WHY]
    .map((title) => (getSection(currentBody, title) ?? "").replace(REGEX_COMMENT, "").replace(GENERATED_MARK, "").trim())
    .filter(Boolean)
    .join("\n\n");

  const diff = await collectDiff({ github, context });
  const generated = await generate(buildMessages({ title: pull.title, authorText, diff }));

  if (!generated.what) {
    throw new Error("Модель вернула пустое описание.");
  }

  const latestBody =
    (
      await github.rest.pulls.get({
        owner: context.repo.owner,
        repo: context.repo.repo,
        pull_number: pull.number,
      })
    ).data.body || currentBody;

  const updatedPull = (
    await github.rest.pulls.update({
      owner: context.repo.owner,
      repo: context.repo.repo,
      pull_number: pull.number,
      body: fillBody(latestBody, generated),
    })
  ).data;

  await refreshLabels({ github, context, updatedPull, byLabel });
}

async function refreshLabels({ github, context, updatedPull, byLabel }) {
  const labelContext = Object.create(context);
  labelContext.payload = { ...context.payload, pull_request: updatedPull };

  try {
    const labels = await get_updated_label_set({ github, context: labelContext });
    await github.rest.issues.setLabels({
      owner: context.repo.owner,
      repo: context.repo.repo,
      issue_number: updatedPull.number,
      labels,
    });
    console.log(`Метки обновлены: ${labels}`);
  } catch (error) {
    console.error("Не удалось пересчитать метки:", error);
    if (byLabel) {
      await github.rest.issues
        .removeLabel({
          owner: context.repo.owner,
          repo: context.repo.repo,
          issue_number: updatedPull.number,
          name: TRIGGER_LABEL,
        })
        .catch(() => {});
    }
  }
}
