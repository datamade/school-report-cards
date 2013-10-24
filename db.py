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

    def __repr__(self):
        return '<District %r>' % (self.name)

class Demographic(Base):
    __tablename__ = 'demographic'
    id = Column(Integer, primary_key=True)
    name = Column(String(15))
    percentage = Column(Float)
    grouping = Column(String(10))
    school_id = Column(Integer, ForeignKey('school.id'), index=True)

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

    def __repr__(self):
        return '<Characteristic %r (%r%%)>' % (self.name, self.percentage)

class ACTDatum(Base):
    __tablename__ = 'act_datum'
    id = Column(Integer, primary_key=True)
    composite = Column(Float)
    english = Column(Float)
    math = Column(Float)
    reading = Column(Float)
    science = Column(Float)
    grouping = Column(String(10))
    school_id = Column(Integer, ForeignKey('school.id'), index=True)

    def __repr__(self):
        return '<ACTData %r (%r)>' % (self.school.name, self.school.city)

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
            s = School(**school_data)
            session.add(s)
            session.commit()
            # School demographics
            for grouping in ['school', 'district', 'subregion']:
                for data in make_demos(row[13:20], grouping):
                    if data:
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
                data = {'school': s}
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
            for idx, head in enumerate(headers[256:279]):
                index = idx + 256
                if not row[index]:
                    continue
                else:
                    data = {'school': s}
                    






