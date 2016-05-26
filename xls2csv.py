import xlrd
import csv
import sys

with xlrd.open_workbook(sys.argv[1]) as wb:
    sh = wb.sheet_by_index(0)  
    c = csv.writer(sys.stdout)
    for r in range(sh.nrows):
        c.writerow(sh.row_values(r))
