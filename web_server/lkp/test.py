#coding=utf-8

import os
import sys
import csv
from optparse import OptionParser
from json import *

from collections import namedtuple

with open('csv/netpipe.csv') as f:
	f_csv = csv.reader(f)
	headings = next(f_csv)
	Row = namedtuple('Row', headings)
	for r in f_csv:
		row = Row(*r)
		print row

