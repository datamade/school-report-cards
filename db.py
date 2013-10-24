from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, Integer, String, ForeignKey, Float
from sqlalchemy.orm import sessionmaker, relationship, backref
import csv

Base = declarative_base()

class School(Base):
    __tablename__ = 'school'
    id = Column(String(16), primary_key=True)
    type_code = Column(String(2))
    name = Column(String(34))
    city = Column(String(18))
    county = Column(String(12))
    school_type_name = Column(String(12))
    grades_in_school = Column(String(32))
    enrollment = Column(Integer)
    district_id = Column(Integer, ForeignKey('district.id'), index=True)
    demographics = relationship('Demographic', backref=backref('school'), lazy='dynamic')
    characteristics = relationship('Characteristic', backref=backref('school'), lazy='dynamic')
    act_data = relationship('ACTDatum', backref=backref('school'), lazy='dynamic')
    settings = relationship('InstructionalSetting', backref=backref('school'), lazy='dynamic')

    def __repr__(self):
        return '<School %r (%r)>' % (self.name, self.city)

class District(Base):
    __tablename__ = 'district'
    id = Column(Integer, primary_key=True)
    name = Column(String(34))
    type_code = Column(Integer)
    size_code = Column(Integer)
    type_name = Column(String(12))
    size_name = Column(String(7))
    enrollment = Column(Integer)
    schools = relationship('School', backref=backref('district'), lazy='dynamic')
    demographics = relationship('Demographic', backref=backref('district'), lazy='dynamic')
    characteristics = relationship('Characteristic', backref=backref('district'), lazy='dynamic')
    act_data = relationship('ACTDatum', backref=backref('district'), lazy='dynamic')
    settings = relationship('InstructionalSetting', backref=backref('district'), lazy='dynamic')

    def __repr__(self):
        return '<District %r>' % (self.name)

class Demographic(Base):
    __tablename__ = 'demographic'
    id = Column(Integer, primary_key=True)
    name = Column(String(15))
    percentage = Column(Float)
    grouping = Column(String(10))
    school_id = Column(Integer, ForeignKey('school.id'), index=True)
    district_id = Column(Integer, ForeignKey('district.id'), index=True)

    def __repr__(self):
        return '<Demographic %r (%r%%)>' % (self.name, self.percentage)

class Characteristic(Base):
    __tablename__ = 'characteristic'
    id = Column(Integer, primary_key=True)
    name = Column(String(6))
    percentage = Column(Float)
    demographic = Column(String(27))
    grouping = Column(String(10))
    school_id = Column(Integer, ForeignKey('school.id'), index=True)
    district_id = Column(Integer, ForeignKey('district.id'), index=True)

    def __repr__(self):
        return '<Characteristic %r (%r%%)>' % (self.name, self.percentage)

class ACTDatum(Base):
    __tablename__ = 'act_datum'
    id = Column(Integer, primary_key=True)
    area = Column(String(4))
    score = Column(Float)
    grouping = Column(String(10))
    school_id = Column(Integer, ForeignKey('school.id'), index=True)
    district_id = Column(Integer, ForeignKey('district.id'), index=True)

    def __repr__(self):
        return '<ACTData %r (%r)>' % (self.area, self.grouping)

class InstructionalSetting(Base):
    __tablename__ = 'instructional_setting'
    id = Column(Integer, primary_key=True)
    grade = Column(String(5))
    measure = Column(String(30))
    grouping = Column(String(10))
    count = Column(Float)
    school_id = Column(Integer, ForeignKey('school.id'), index=True)
    district_id = Column(Integer, ForeignKey('district.id'), index=True)

    def __repr__(self):
        return '<Instructional Setting %r (%r)>' % (self.grade, self.measure)

def make_demos(values, grouping):
    demos = [
        'White %', 
        'Black %', 
        'Hispanic %', 
        'Asian %', 
        'Native Hawaiian or other Pacific Islander %',
        'Native American %',
        'Two or More Races %',
    ]
    for name, percent in zip(demos, values):
        percent = percent.strip()
        if not percent:
            yield None
        else:
            data = {
                'name': name, 
                'percentage': percent, 
                'grouping': grouping,
            }
            yield data

if __name__ == '__main__':
    engine = create_engine('sqlite:///report_card.db')
    Session = sessionmaker(bind=engine)
    Base.metadata.create_all(engine)
    session = Session()
    with open('rc13.txt', 'rb') as f:
        reader = csv.reader(f, delimiter=';')
        for row in reader:
            district_data = {
                'name': row[4].strip(),
                'type_code': row[7].strip(),
                'size_code': row[8].strip(),
                'type_name': row[9].strip(),
                'size_name': row[10].strip(),
                'enrollment': row[36].strip(),
            }
            district = session.query(District).filter_by(**district_data).first()
            if not district:
                district = District(**district_data)
                session.add(district)
                session.commit()
            school_data = {
                'id': row[0].strip(),
                'type_code': row[1].strip(),
                'name': row[3].strip(),
                'city': row[5].strip(),
                'county': row[6].strip(),
                'school_type_name': row[11].strip(),
                'grades_in_school': row[12].strip(),
                'district': district,
                'enrollment': row[21].strip(),
            }
            s = session.query(School).get(school_data['id'])
            if not s:
                s = School(**school_data)
                session.add(s)
                session.commit()
            # School demographics
            for grouping, indexes in {'school': (13,20), 'district': (30,36)}.items():
                l_idx, r_idx = indexes
                for data in make_demos(row[l_idx:r_idx], grouping):
                    if data:
                        data['district'] = district
                        data['school'] = s
                        demo = session.query(Demographic).filter_by(**data).first()
                        if not demo:
                            demo = Demographic(**data)
                            session.add(demo)
                            session.commit()
            with open('RC13_layout/RC13-Table 1.csv', 'rb') as head:
                reader = csv.reader(head)
                headers = list(reader)
            # School 'Characteristics'
            for idx, head in enumerate(headers[46:254]):
                index = idx + 46
                data = {'school': s, 'district': district}
                data['name'] = head[5].strip()
                percentage = row[index].strip().replace(',','')
                if not percentage:
                    continue
                else:
                    data['percentage'] = percentage
                parts = data['name'].split(' ')
                if parts[-1] == '%':
                    data['grouping'] = parts[-2].lower()
                else:
                    data['grouping'] = parts[-1].lower()
                demo = None
                if head[2].strip():
                    data['demographic'] = head[2]
                char = session.query(Characteristic).filter_by(**data).first()
                if not char:
                    char = Characteristic(**data)
                    session.add(char)
                    session.commit()
            # ACT data
            for idx, head in enumerate(headers[257:279]):
                index = idx + 254
                if not row[index].strip():
                    continue
                else:
                    act_data = {'school': s, 'district': district}
                    parts = head[5].strip().split(' ')
                    if len(parts) == 3:
                        area, grouping = parts[1:]
                    elif len(parts) == 4:
                        area, grouping = parts[1:3]
                    else:
                        area, grouping = head[5].split(' - ')
                    act_data['score'] = row[index]
                    act_data['grouping'] = grouping.lower()
                    act_data['area'] = area.lower()
                    act = session.query(ACTDatum).filter_by(**act_data)
                    if not act:
                        act = ACTDatum(**act_data)
                        session.add(act)
                        session.commit()
            # Instructional setting
            for idx, head in enumerate(headers[280:372]):
                index = idx + 280
                if row[index].strip():
                    data = {'school': s, 'district': district}
                    name = head[5]
                    if name.find('(') > 0:
                        data['grade'] = name[name.find('(')+1:name.find(')')]
                        parts = name.split('-')
                        if len(parts) == 2:
                            data['measure'] = parts[0].strip()
                            data['grouping'] = parts[1].split(' ')[0]
                        else:
                            parts = name.split('(')
                            data['measure'] = parts[0].strip()
                            data['grouping'] = parts[1][5:].lower()
                    else:
                        data['grade'] = 'all'
                        parts = name.split(' - ')
                        data['measure'] = parts[0]
                        data['grouping'] = parts[1]
                    data['count'] = row[index]
                    inst = session.query(InstructionalSetting).filter_by(**data).first()
                    if not inst:
                        inst = InstructionalSetting(**data)
                        session.add(inst)
                        session.commit()
                        print inst







