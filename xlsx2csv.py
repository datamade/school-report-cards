import openpyxl
import csv
import sys

wb = openpyxl.load_workbook(sys.argv[1])
sh = wb.get_active_sheet()
c = csv.writer(sys.stdout)
for r in sh.rows:
    c.writerow([cell.value for cell in r])
