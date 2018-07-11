import subprocess
import re
import os

project_name = "posefilter"
user_name = "cybertroneye"

def get_output(cmd):
  cmd_arr = cmd.split(" ")
  return subprocess.check_output(cmd_arr).rstrip()
  
def extract_version(raw_version):
  m = re.search('VERSION_([0-9]*)_([0-9]*).*', raw_version)
  if m:
    return m.group(1), m.group(2)
  else:
    print "Generate version fail. Can't find a tag like VERSION_X_X"
    return None

raw_version = get_output("git describe --match VERSION_[0-9]*_[0-9]*")
version0, version1 = extract_version(raw_version)
if version0 == None:
  exit(1)
version = version0 + "." + version1
version_tag_commit = get_output("git rev-list -n 1 VERSION_" + version0 + "_" + version1)
subversion = get_output("git rev-list --count " + version_tag_commit)
commit = get_output("git log --format=%h -n 1")

branch_list = get_output("git branch").split("\n")
cur_branch = ""
for branch in branch_list:
  if branch.startswith("* "):
    cur_branch = branch[2:]

total_version = version + "." + subversion + "." + commit
print project_name + "/" + total_version + "@" + user_name + "/" + cur_branch
