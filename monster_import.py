from sqlalchemy import Table, Column, create_engine, MetaData, Integer, String
from sqlalchemy.orm import sessionmaker
import csv

if __name__ == '__main__':
    meta = MetaData()
    field_ids = [r[:-1] for r in open('fields.txt', 'rb')]
    with open('table_layout.csv', 'rb') as f:
        headers = list(csv.reader(f))
    cols = [
        Column('importID', Integer(5), primary_key=True),
        Column('schoolID', String(20)),
        Column('elemRank', Integer(5)),
        Column('middleRank', Integer(5)),
        Column('hsRank', Integer(5)),
    ]
    for header in headers:
        if header[0] in field_ids:
            cols.append(Column('field%s' % header[0], String(int(header[4]))))
    engine = create_engine('mysql://root:@33.33.33.10/report_card')
    table = Table('reportCards', meta, *cols, mysql_engine='MyISAM')
    meta.drop_all(engine)
    meta.create_all(engine)
    conn = engine.connect()
    fieldnames = [c.name for c in table.columns]
    with open('rc13.txt', 'rb') as f:
        reader = csv.reader(f, delimiter=';')
        for row in reader:
            data = {'schoolID': row[0]}
            for field in fieldnames:
                if field.startswith('field'):
                    index = field.replace('field', '')
                    data[field] = row[int(index)]
            ins = table.insert().values(**data)
            conn.execute(ins)
