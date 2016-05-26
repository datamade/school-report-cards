import csv
import sys

if len(sys.argv[1:]) == 5 :
    (name_pos, start_pos, length_pos, 
     first_note_pos, second_note_pos) = [int(pos) for pos in sys.argv[1:]]
elif len(sys.argv[1:]) == 4 :
    (name_pos, start_pos, length_pos, 
     first_note_pos) = [int(pos) for pos in sys.argv[1:]]
    second_note_pos = None
else :
    name_pos, start_pos, length_pos, first_note_pos, second_note_pos  = 5, 3, 4, 2, 1

blacklist=("Blank", "semicolon filler")

reader = csv.reader(sys.stdin)
writer = csv.writer(sys.stdout)
writer.writerow(('column', 'start', 'length'))

for row in reader :
    try :
        if not row[name_pos].strip() or row[name_pos].strip() in blacklist :
            continue
    except IndexError :
        continue
    if second_note_pos is not None and row[second_note_pos].strip() :
        col_name = '; '.join(name.strip() for name in (row[name_pos], 
                                                       row[first_note_pos], 
                                                       row[second_note_pos]))
    elif row[first_note_pos].strip() :
        col_name = '; '.join(name.strip() for name in (row[name_pos], 
                                                       row[first_note_pos]))
    else :
        col_name = row[name_pos].strip()
    col_start = int(row[start_pos].split('-')[0].strip())
    col_length = int(float(row[length_pos])) - 1
    writer.writerow((col_name, col_start, col_length))


