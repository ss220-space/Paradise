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

const writes = [];
await processAutoChangelog({
  github: {
    rest: {
      repos: {
        createOrUpdateFileContents: async (params) => writes.push(params),
      },
    },
  },
  context: {
    repo: { owner: "KINGDICE666", repo: "DarkParadise" },
    payload: {
      pull_request: {
        number: 93,
        user: { login: "KINGDICE666" },
        body: ":cl:\nadd: Adds new stuff\n/:cl:",
      },
    },
  },
});
assert.equal(writes.length, 1);
assert.equal(writes[0].path, "html/changelogs/AutoChangeLog-pr-93.yml");
assert.equal(writes[0].branch, undefined);
assert.match(writes[0].message, /\[ci skip\]$/);
assert.match(Buffer.from(writes[0].content, "base64").toString(), /PR #93/);
