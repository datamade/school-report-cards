import csv
import sys

def whitelist(field) :
    field = field.strip()
    if field :
        if field.replace('-', '').isdigit() :
            return False
        elif field == 'IMAGE' :
            return False
        else :
            return True
    else :
        return False

reader = csv.reader(sys.stdin)
writer = csv.writer(sys.stdout)
writer.writerow(('column', 'start', 'length'))

for row in reader :
    if not row[5].strip() :
        continue
    if whitelist(row[1]) :
        col_name = '; '.join(name.strip() for name in (row[5], row[2], row[1]))
    elif whitelist(row[2]) :
        col_name = '; '.join(name.strip() for name in (row[5], row[2]))
    else :
        col_name = row[5].strip()
    col_start = row[7]
    col_length = int(row[4]) - 1
    writer.writerow((col_name, col_start, col_length))


