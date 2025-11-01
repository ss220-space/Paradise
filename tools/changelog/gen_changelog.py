# Script to generate changelog from commit tree
# Listen up.
# In order to run this script on Windows, you need to make sure you have Python **3** installed. Tested on 3.8.2
# It won't work on 2.7 at all.

# !/usr/bin/env python3


from git import Repo
from datetime import date
import yaml

validPrefixes = [
    "add",
    "admin",
    "balance",
    "bugfix",
    "code_imp",
    "config",
    "del",
    "expansion",
    "experiment",
    "image",
    "imageadd",
    "imagedel",
    "local",
    "map",
    "qol",
    "refactor",
    "rscadd",
    "rscdel",
    "server",
    "sound",
    "soundadd",
    "sounddel",
    "spellcheck",
    "tgs",
    "tweak",
    "unknown",
    "wip",
]

today = date.today()
repo = Repo()
commitsSet = set()


def add_commits(commit):
    commit_mount = date.fromtimestamp(commit.committed_date).month
    mount_fixed = today.month
    if commit_mount > 10 and today.month < 3:
        mount_fixed += 12
    if commit_mount >= mount_fixed - 1:
        if not commit.message.startswith("Automatic changelog generation"):
            commitsSet.add(commit)
        for parent in commit.parents:
            add_commits(parent)


def commit_key(c):
    return c.committed_date


add_commits(repo.head.commit)
commitsByDate = dict()
commitsSorted = list(commitsSet)
commitsSorted.sort(key=commit_key)

for i in commitsSorted:
    commit_time = date.fromtimestamp(i.committed_date)
    commit_year_mount = commit_time.strftime("%Y-%m")
    commit_year_mount_day = commit_time.strftime("%Y-%m-%d").format()
    if commit_year_mount not in commitsByDate:
        commitsByDate[commit_year_mount] = dict()
    if commit_year_mount_day not in commitsByDate[commit_year_mount]:
        commitsByDate[commit_year_mount][commit_year_mount_day] = dict()

    if i.author.name not in commitsByDate[commit_year_mount][commit_year_mount_day]:
        commitsByDate[commit_year_mount][commit_year_mount_day][i.author.name] = list()

    message = i.message.splitlines()[0]
    split = message.split(':', 1)
    prefix = ""
    change = ""
    if len(split) > 1:
        prefix = split[0].lower()
        change = split[1]
        prefixes = prefix.split('/')
        for j in range(len(prefixes)):
            temp_prefix = prefixes[j]
            if temp_prefix.startswith("fix") or temp_prefix == "hotfix":
                prefixes[j] = "bugfix"
            elif temp_prefix == "buff":
                prefixes[j] = "tweak"
            elif temp_prefix == "feat":
                prefixes[j] = "add"
            elif temp_prefix.startswith("ref"):
                prefixes[j] = "refactor"
            elif temp_prefix.startswith("revert"):
                prefixes[j] = "del"
            elif temp_prefix not in validPrefixes:
                prefixes[j] = "unknown"

        prefix = '/'.join(prefixes)
    else:
        prefix = "server"
        change = split[0]

    commitsByDate[commit_year_mount][commit_year_mount_day][i.author.name].append({prefix: change.strip()})

for i in commitsByDate:
    with open("html/changelogs/archive/{}.yml".format(i), 'w', encoding='utf-8') as f:
        yaml.dump(commitsByDate[i], f, default_flow_style=False, allow_unicode=True)
