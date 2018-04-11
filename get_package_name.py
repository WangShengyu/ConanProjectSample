import subprocess
import re

project_name = "commonutils"
user_name = "cybertroneye"

def get_output(cmd):
  cmd_arr = cmd.split(" ")
  return subprocess.check_output(cmd_arr).rstrip()
  
def extract_version(raw_version):
  m = re.search('VERSION_([0-9]*)_([0-9]*).*', raw_version)
  if m:
    return m.group(1) + "." + m.group(2)
  else:
    print "Generate version fail. Can't find a tag like VERSION_X_X"
    return None

raw_version = get_output("git describe --match VERSION_[0-9]*_[0-9]*")
version = extract_version(raw_version)
if version == None:
  exit(1)
subversion = get_output("git rev-list --count HEAD")
commit = get_output("git log --format=%h -n 1")

branch = get_output("git branch")
if branch.startswith("* "):
  branch = branch[2:]

total_version = version + "." + subversion + "." + commit
print project_name + "/" + total_version + "@" + user_name + "/" + branch
