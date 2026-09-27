import assert from "node:assert/strict";
import { changelogToYml, processAutoChangelog } from "./autoChangelog.js";
import { parseChangelog } from "./changelogParser.js";

assert.equal(
  changelogToYml(
    parseChangelog(`
			My cool PR!
			:cl: DenverCoder9
			add: Adds new stuff
			add: Adds more stuff
			/:cl:
		`),
    "DenverCoder9",
    93,
  ),
  `author: "DenverCoder9"
delete-after: True
changes:
  - add: "Adds new stuff (PR #93)"
  - add: "Adds more stuff (PR #93)"`,
);

const notFound = () => Object.assign(new Error("Not found"), { status: 404 });
const calls = [];
const github = {
  rest: {
    repos: {
      getContent: async ({ ref }) => {
        calls.push(`getContent:${ref}`);
        throw notFound();
      },
      createOrUpdateFileContents: async ({ branch, content }) => {
        calls.push(`write:${branch}`);
        assert.match(Buffer.from(content, "base64").toString(), /PR #93/);
      },
    },
    git: {
      getRef: async ({ ref }) => {
        calls.push(`getRef:${ref}`);
        if (ref === "heads/master220") {
          return { data: { object: { sha: "base-sha" } } };
        }
        throw notFound();
      },
      createRef: async ({ ref }) => calls.push(`createRef:${ref}`),
    },
    pulls: {
      list: async () => ({ data: [] }),
      create: async ({ base, head }) => calls.push(`createPR:${head}:${base}`),
    },
  },
};
await processAutoChangelog({
  github,
  context: {
    repo: { owner: "KINGDICE666", repo: "DarkParadise" },
    payload: {
      pull_request: {
        number: 93,
        base: { ref: "master220" },
        user: { login: "KINGDICE666" },
        body: ":cl:\nadd: Adds new stuff\n/:cl:",
      },
    },
  },
});
assert.deepEqual(calls, [
  "getContent:master220",
  "getRef:heads/automation/changelog-pr-93",
  "getRef:heads/master220",
  "createRef:refs/heads/automation/changelog-pr-93",
  "getContent:automation/changelog-pr-93",
  "write:automation/changelog-pr-93",
  "createPR:automation/changelog-pr-93:master220",
]);
