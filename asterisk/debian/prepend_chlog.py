#!/usr/bin/python

"""'prepend_chlog.py path_to/ChangeLog':
This script is called during the build of Asterisk.
It automatically injects patch comments into the main Asterisk ChangeLog so
changes are correctly traceable for everybody.
More precisely:
It read the list of patch files in application order from <stdin>, extracts
documentation at top of them, format it so that it does not look completely
terrible in a ChangeLog file, and finally replaces the ChangeLog file passed as
a command line argument by a new updated one with the patch documentations of
last applied ones coming first.
"""

# $Revision$
# $Date$
# TODO make mail address a parameter

import sys, re, os, time, posix, os.path
from itertools import takewhile, chain, imap, islice

END_OF_HEADER = tuple(re.compile(pattern, re.I) for pattern in 
                      ('---', '@DPATCH@', 'Index:', 'diff'))
def not_eoh(l):
	"Returns True is not the end of a patch header, else False"
	return [1 for x in END_OF_HEADER if x.match(l)] == []

TAB_SZ = 8
def tab_to_space(line, offset):
	"""Converts tabs to spaces in 'line'. Offset if the column number of
	the first character in 'line'."""
	elems = line.split('\t')
	spcs = []
	for e in elems:
		offset += len(e)
		pad = TAB_SZ - (offset%TAB_SZ)
		spcs.append(' ' * pad)
		offset += pad
	if spcs:
		spcs[-1] = ''
	return ''.join(chain(*zip(elems, spcs)))

spcs_match = re.compile('[ ]*').match
def ini_spcs_count(s):
	"Returns the number of spaces at the beginning of 's'."
	return len(spcs_match(s).group())

MAX = 2147483647
def align_chunk(chunk):
	"""Left align the lines of 'chunk' (which is a list of strings) so that
	non empty ones start with at least 8 spaces, except for the first
	one (because it will be the ChangeLog entry header line)."""
	if not chunk:
		return
	min_spc = min(chain((MAX,),
	              (ini_spcs_count(l)
	               for l in islice(chunk, 1, MAX)
		       if l.strip())))
	if min_spc < TAB_SZ:
		compl = TAB_SZ - min_spc
		for i,l in enumerate(chunk):
			if i > 0 and l.strip():
				chunk[i] = (' ' * compl) + l

# Regex to detect Debian Patches. Matching will be tested against the first
# line of the patch file.
FIRST_LINE_DPATCH = re.compile('#.*sh')

MODE_STD = 0
MODE_DPATCH = 1
def append_by_mode(lst, mode, line):
	"""Append a new line in 'lst'. Mode can be either MODE_STD or
	MODE_DPATCH. If mode is MODE_STD full lines are considered as part of
	the ChangeLog entry. If mode is MODE_DPATCH, only lines beginning with
	'## DP:' will be selected and this marker will be stripped out."""
	if mode == MODE_DPATCH:
		if not line.startswith('## DP:'):
			return
		lst.append(tab_to_space(line[6:], 6))
	else:
		lst.append(tab_to_space(line, 0))

# Regex to detect changelog entry header line. If the first selected line
# matches it will be used untouched in the generated ChangeLog, else an
# arbitrary changelog entry header line will be automatically generated.
head_chglog_entry = re.compile('\d{4}-\d{2}-\d{2}\s.*<.*@.*>').match


### MAIN ###

if len(sys.argv) < 2:
	raise RuntimeError, "Syntax: prepend_chlog.py path/ChangeLog"

patches = [line.strip() for line in sys.stdin if line.strip()]
patches.reverse()

changelog = sys.argv[1]
changelogTmp = changelog + ".tmp." + str(posix.getpid())
fchlog_pre = open(changelogTmp, 'w')
try:
    for patch in patches:
	fp = open(patch)
	
	# Select mode using the first line: Standard Patch or Debian Patch
	# Debian Patches contains documentation on lines starting with "## DP:"
	# and other lines before the patch itself constitute a shell script
	mode = MODE_STD
	firstl = fp.readline()
	if not firstl:
		continue
	if FIRST_LINE_DPATCH.match(firstl):
		mode = MODE_DPATCH
	
	# Read the patch documentation
	# Note that the first line is reinjected by itertools.chain
	# in the for iteration
	chunk = []
	for l in takewhile(not_eoh, chain((firstl,), fp)):
		append_by_mode(chunk, mode, l)
	
	# Remove blank lines at the beginning of the extracted chunk
	while chunk and not chunk[0].strip():
		chunk.pop(0)
	# Remove blank lines at the end of the extracted chunk
	while chunk and not chunk[-1].strip():
		chunk.pop()
	# Add just one empty line at the end of the resulting chunk
	chunk.append('\n')

	# Automatically generate a ChangeLog entry header if there is none.
	if not head_chglog_entry(chunk[0]):
		chunk.insert(0, "%s  '%s' automatically applied <technique@proformatique.com>\n"
		                % (time.strftime("%Y-%m-%d"), os.path.basename(patch)))
		if len(chunk) != 2:
			chunk.insert(1, "\n")

	# Left align the ChangeLog entry
	align_chunk(chunk)

	# Write the result
	fchlog_pre.writelines(chunk)

    # Duplicate the original ChangeLog at the end of the generated one.
    fchlog = open(changelog)
    while 1:
	block = fchlog.read(65536)
	if not block:
		break
	fchlog_pre.write(block)
    fchlog.close()
except:
    fchlog_pre.close()
    os.unlink(changelogTmp)
    raise

# The generated ChangeLog is done.
fchlog_pre.close()

# Replaces the original ChangeLog with the generated one.
os.rename(changelogTmp, changelog)
