#coding=utf-8
#create time : 2016-04-11
#commit time : 2016-04-11
#author : Huiyang.Han

import os
import sys
import json
import csv

FULLFILL = "x"
BINDEX = 1
KINDEX = 5
CINDEX = 6

#1. read paths
#2. collect and get rid of boolean
#3. combine(call)

def read_paths(path_file):
	#input: a pathfile, it it a path index
	#output: a list of paths
	#function: load

	#indicators
	#print "Read"

	paths = []
	for path in open(path_file):
		#print path
		paths.append(path[0:len(path)-1])
	#print "Read finished"
	return paths

def mean(dic):
	#input: a dict whose value is a list
	#output: a dict whose value is the mean value of the former value
	#function: obtain the mean value of the list
	
	special = ["benchmark", "kernel", "compiler"]	
	for key, value in dic.items():
		#print key
		if key in special:
			continue
		sum = 0.0
		notbool = False
		for num in value:
			#print num, sum
			sum += float(num)
			if num != 0.0 and num != 1.0:
				notbool = True
		if notbool:
			value = sum / len(value)
			dic[key] = value
		else:
			del dic[key]
	return dic

def collect(paths):
	#input: a list of paths of matrix.json files
	#output: a list of dict, each in the list is mapped from a matrix.json
	#function: collect

	#Indicators
	print "Collect"
	table = []
	for path in paths:
		print path
		#print os.path.exists(path)
		#print path
		if os.path.exists(path):
			#print path
			jsontext = open(path).read()
			if len(jsontext) > 2:#{}
				dic = json.loads(jsontext)
				del dic["stats_source"]
				dic = mean(dic)
				#print dic
				pathsplit = path.split("/")
				dic["benchmark"] = pathsplit[BINDEX]
				dic["kernel"] = pathsplit[KINDEX]
				dic["compiler"] = pathsplit[CINDEX]
				table.append(dic)
			else:
				continue
		else:
			#print path
			continue
	print "Collect finished"
	#print table
	return table

def replace(numbers):
	#input: a list of numbers(mixed with "x"es)
	#output: a list of numbers("x"es are replaced)
	#function: in case of read error
	newlist = []
	sum = 0.0
	cnt = 0.0
	for num in numbers:
		if cmp(FULLFILL, num):
			cnt += 1.0
			sum += num
	fullfill = sum / cnt
	
	length = len(numbers)
	for i in range(length):
		if not cmp(FULLFILL, num):
			numbers[i] = fullfill
	return numbers

def normlize(numbers):
	#input: a list of numbers
	#output: a normlized list 
	#function: normlize
	max = numbers[0]
	min = numbers[0]

	length = len(numbers)

	for num in numbers:
		if max < num:
			max = num
		if min > num:
			min = num
	print max, min
	base = max - min
	
	if base == 0:
		numbers = [0.0] * length
	else:
		for i in range(length):
			numbers[i] = float(numbers[i]) / base
	return numbers

def combine(table):
	#input: a list of dict
	#output: a dict whose keys are metrics and values are lists of numbers
	#function: combine the dicts

	#Indicators
	print "Combine"
	full = {}
	dictnum = 0

	for dic in table:
		print dic["benchmark"] + "/" + dic["kernel"] + "/" + dic["compiler"]
		dictnum += 1
		for k, v in dic.items():
			if full.has_key(k):
				full[k].append(v)
			else:
				full[k] = [v]
		for k, v in full.items():
			if len(v) < dictnum:
				v.append(FULLFILL)
				full[k] = v
	print "Combine finished"

	#normlize
	#Indicator
	print "Normlize"

	special = ["benchmark", "kernel", "compiler"]
	for k, v in full.items():
		if not k in special:
			v = replace(v)
			full[k] = normlize(v)
	print "Normlize finished"
	return full

def savetocsv(full):
	#input: a dict whose keys are metrics and values are lists of numbers
	#output: nothing
	#function: save

	#Indicator
	print "Savetocsv"

	keylist = full.keys()

	wcsvfile = file('washeddata.csv', 'wb')
	writer = csv.writer(wcsvfile)

	writer.writerow(keylist)#write the first row : metrics

	length = 0
	for k, v in full.items():
		length = len(v)
		break

	listcnt = len(full.keys())
	ll = []

	for k, v in full.items():
		ll.append(v)

	for j in range(length):
		line = []
		for i in range(listcnt):
			line.append(ll[i][j])
			print ll[0][j] + "/" + ll[1][j] + "/" + ll[2][j]
		writer.writerow(line)

	wcsvfile.close()

if __name__ == "__main__":
	#main process: read_paths->collect->combine(norm)->savetocsv
	#update: 3 more metrics to add
	paths = read_paths("paths.txt")
	#print paths
	table = collect(paths)
	full = combine(table)
	savetocsv(full)
