import { parseChangelog } from "./changelogParser.js";

export const CHANGELOG_BRANCH_PREFIX = "automation/changelog-pr-";

const safeYml = (string) =>
  string.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\n/g, "\\n");

export function changelogToYml(changelog, login, prNumber) {
  const author = changelog.author || login;
  const ymlLines = [];

  ymlLines.push(`author: "${safeYml(author)}"`);
  ymlLines.push(`delete-after: True`);
  ymlLines.push(`changes:`);

  for (const change of changelog.changes) {
    let description = change.description;
    if (!description.includes(`#${prNumber}`)) {
      description += ` (PR #${prNumber})`;
    }
    ymlLines.push(
      `  - ${change.type.changelogKey}: "${safeYml(description)}"`,
    );
  }

  return ymlLines.join("\n");
}

export async function processAutoChangelog({ github, context }) {
  const pullRequest = context.payload.pull_request;
  if (pullRequest.head?.ref?.startsWith(CHANGELOG_BRANCH_PREFIX)) {
    console.log("changelog pull request, skipping");
    return;
  }

  const changelog = parseChangelog(pullRequest.body);
  if (!changelog || changelog.changes.length === 0) {
    console.log("no changelog found");
    return;
  }

  const yml = changelogToYml(
    changelog,
    pullRequest.user.login,
    pullRequest.number,
  );
  const { owner, repo } = context.repo;
  const base = pullRequest.base.ref;
  const branch = `${CHANGELOG_BRANCH_PREFIX}${pullRequest.number}`;
  const path = `html/changelogs/AutoChangeLog-pr-${pullRequest.number}.yml`;
  const params = { owner, repo, path };

  // Reruns must not recreate a changelog that has already been merged.
  try {
    await github.rest.repos.getContent({ ...params, ref: base });
    console.log(`${path} already exists on ${base}`);
    return;
  } catch (error) {
    if (error.status !== 404) throw error;
  }

  try {
    await github.rest.git.getRef({ owner, repo, ref: `heads/${branch}` });
  } catch (error) {
    if (error.status !== 404) throw error;
    const baseRef = await github.rest.git.getRef({
      owner,
      repo,
      ref: `heads/${base}`,
    });
    await github.rest.git.createRef({
      owner,
      repo,
      ref: `refs/heads/${branch}`,
      sha: baseRef.data.object.sha,
    });
  }

  let sha;
  try {
    const existing = await github.rest.repos.getContent({
      ...params,
      ref: branch,
    });
    sha = existing.data.sha;
  } catch (error) {
    if (error.status !== 404) throw error;
  }

  await github.rest.repos.createOrUpdateFileContents({
    ...params,
    branch,
    message: `Automatic changelog for PR #${pullRequest.number}`,
    content: Buffer.from(yml).toString("base64"),
    ...(sha ? { sha } : {}),
  });

  const openPullRequests = await github.rest.pulls.list({
    owner,
    repo,
    base,
    head: `${owner}:${branch}`,
    state: "open",
  });
  if (openPullRequests.data.length === 0) {
    await github.rest.pulls.create({
      owner,
      repo,
      base,
      head: branch,
      title: `Add changelog for PR #${pullRequest.number}`,
      body: `Automatically generated from #${pullRequest.number}. Review and merge this changelog entry.`,
    });
  }
}
