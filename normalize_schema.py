import csv
import sys
import re

cleaners = (lambda x : x.replace(' -->', ''),
            lambda x : x.replace('TIT1SCHOOLS', 'TIT1 SCHOOLS'),
            lambda x : x.replace('TEACH ER', 'TEACHER'),
            lambda x : x.replace('; Coming Soon', ''),
            lambda x : re.sub(r'  +', r' ', x),
            lambda x : re.sub(r" \(Y, N\)", '', x),
            lambda x : re.sub(r" \(0, *1\)", '', x),
            lambda x : re.sub(r" \(Yes, No\)", '', x),
            lambda x : re.sub('; ;', ';', x),
            lambda x : x.replace('MEETSS', 'MEETS'),
            lambda x : x.replace('DISABLED', 'IEP'),
            lambda x : x.replace('HISPA ', 'HISPANIC '),
            lambda x : x.replace('NAT A ', 'NATIVE AMERICAN '),
            lambda x : x.replace('NATIVE AMER ', 'NATIVE AMERICAN '),
            lambda x : re.sub(r'ATTENDANCE RATE (\w+) %$', r'ATTENDANCE RATE \1 %; ALL', x),
            lambda x : re.sub(r'RATE (\w+)$', r'RATE \1 %', x),
            lambda x : re.sub(r'^HS GRAD RATE', 'HS 4-YEAR GRAD RATE', x),
            lambda x : re.sub(r'HS 4-YEAR GRAD RATE (\w+) %$', r'HS 4-YEAR GRAD RATE \1 %; ALL', x),
            lambda x : re.sub('; CORE$', '', x),
            lambda x : re.sub('^ACS', 'AVG CLASS SIZE', x),
            lambda x : re.sub('^AVG ACS', 'AVG CLASS SIZE', x),
            lambda x : re.sub('^MPD', 'MIN PER DAY', x),
            lambda x : re.sub(r'(\w+) TEACH -', r'\1 TEACHER -', x),
            lambda x : re.sub(r'(\S)-', r'\1 -', x),
            lambda x : re.sub(r'-(\S)', r'- \1', x),
            lambda x : re.sub(r'^PT ', 'PUPIL - TEACHER ', x),
            lambda x : re.sub(r'^P - ADM ', 'PUPIL - ADMIN ', x),
            lambda x : re.sub(r'^AVG TCH ', 'AVG TEACHER ', x),
            lambda x : re.sub(r'^AVG ADM ', 'AVG ADMIN ', x),
            lambda x : re.sub(r';[ -1234567890]+$', r'', x),
            lambda x : re.sub(r'^MATH\d+', 'MATH', x),
            lambda x : re.sub(r'^READ\d+', 'READING', x),
            lambda x : re.sub(r'^WRIT\d+', 'WRITING', x),
            lambda x : re.sub(r'^SCIE\d+', 'SCIENCE', x),
            lambda x : re.sub(r'^SOS\d+', 'SOC SCIENCE', x),
            lambda x : re.sub(r'SUBREG\b', 'SUBREGION', x),
            lambda x : re.sub(r'^%TESTED', '% SCORES', x),
            lambda x : re.sub(r'%TESTED(\d)', r'% SCORES \1', x),
            lambda x : x.replace(" - '\"&MID(YEAR(TODAY()),3,2)", ''),
            lambda x : re.sub(r'^PAR - INV', 'PARENTAL INVOLVEMENT', x),
            lambda x : re.sub(r'^MEET GOALS (.*)$', r'MEETS \1; ALL; IGAP', x),
            lambda x : re.sub(r'^EXCEED GOALS (.*)$', r'EXCEEDS \1; ALL; IGAP', x),
            lambda x : re.sub(r'^DONOTMEET GOALS (.*)$', r'BELOW \1; ALL; IGAP', x),
            lambda x : re.sub(r'\bWRIT\b', 'WRITING', x),
            lambda x : re.sub(r'^DOES NOT MEET', 'BELOW', x),
            lambda x : re.sub(r'^DONOTMEET', 'BELOW', x),
            lambda x : re.sub(r'^# CHRONIC TRUANTS', 'CHRONIC TRUANTS #', x),
            lambda x : re.sub(r'(BELOW|MEETS|EXCEEDS|ACADEMIC WARNING|% TESTED (?:.*) STUDENTS) (.*?);(.*)$', r'\2 \1;\3', x), 
            lambda x : re.sub(r'\bMEET;', 'MEETS;', x),
            lambda x : re.sub(r'^GR (\d+)', r'GR\1', x),
            lambda x : re.sub(r'(.*) (BELOW|MEETS|EXCEEDS|ACADEMIC WARNING|% TESTED (?:.*) STUDENTS); ([^;]*)$',
                              r'\1 \2; \3; ISAT', x),
            lambda x : re.sub(r'ACADEMIC WARNING; ALL$',
                              r'ACADEMIC WARNING; ALL; ISAT',
                              x),



)

reader = csv.reader(sys.stdin)
writer = csv.writer(sys.stdout, lineterminator='\n')
writer.writerow(next(reader))

for row in reader :
    col_name, col_start, col_length = row
    for cleaner in cleaners :
        col_name = cleaner(col_name)
    writer.writerow([col_name, col_start, col_length])

