#!/usr/bin/python

#############################################################################
# Program: 	txt2csv.py
# Author: 	Kevin Xu
# Date: 	11/12/13
# 
# 	txt2csv converts all .txt files from a specified source directory into
# 	CSV files and placed into the current working directory. The CSV files are 
# 	quote bounded and all original .txt files are unaltered. 
# 
# 	Usage: 
# 	- Use 'cd' and 'dir' to navigate into the directory that contains 
# 		txt2csv. 
# 	- Run by entering the command: 
# 		> python txt2csv.py
# 	- Enter the FULL source directory where the .txt files are stored
#
#############################################################################

import csv
import sys
import shutil
import os
import glob

# Raise field limit in case CVS file has very large fields
csv.field_size_limit(sys.maxsize)		

def main(): 

	# OPTION: 
	# The src_path can either be hard-coded by modifying the file or 
	# entered by the user through prompt.  
	# src_path = raw_input("Enter full path of source directory: ")
	
	src_path = 'K:\Coboat-XMLharvester\KARMA-COBOAT-UseToRetreiveData-KARMA\service\sourcedata\TMS'
	dest_path = os.getcwd()				# Set dest_path as current working directory 

	# Copy all *.txt files from the source directory into current directory
	for infile in glob.glob( os.path.join(src_path, '*.txt')): 
		shutil.copy(infile, dest_path)
		print "copying: " + os.path.basename(infile)

	# Process all the files in current directory
	listing = os.listdir(dest_path)
	for file in listing: 
		
		# Set name of files to be processed
		txt_file = os.path.splitext(file)[0] + ".txt"
		csv_file = os.path.splitext(file)[0] + ".csv"
		
		# Ignore the program file (txt2csv) when processing.
		if txt_file == "txt2csv.txt": 
			continue
			
		# Open the files to be processed
		txt_open = open(txt_file, 'rb')
		csv_open = open(csv_file, 'wb')
		
		# Write to the csv file
		in_txt = csv.reader(txt_open, delimiter='\t')
		out_csv = csv.writer(csv_open, quoting=csv.QUOTE_ALL)
		out_csv.writerows(in_txt)
		
		# Close the files and remove
		txt_open.close()
		csv_open.close()
		os.remove(txt_file)
		
		print "processing: " + os.path.basename(csv_file)
	
	print "finished!"

	
if __name__ == "__main__": 	
	main()
