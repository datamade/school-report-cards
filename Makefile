include config.mk

97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

years = 1997 1998 1999 2000 2001 2001 2003 2004 2005 2006 2007 2008	\
        2009 2010 2011 2012 2013 2014 2015

rcs = $(patsubst %,rc_%.csv,$(years))

define unzip-rename
unzip -p $< > $@
endef

all : $(rcs)

.INTERMEDIATE: rc11.zip rc12.zip rc13.zip rc14.zip 

%.zip :
	wget http://www.isbe.net/research/zip/$@

rc11.zip :
	wget http://www.isbe.net/assessment/zip/rc11.zip

rc12.zip :
	wget http://www.isbe.net/assessment/zip/rc12.zip

rc13.zip :
	wget http://www.isbe.net/assessment/zip/rc13.zip

rc14.zip :
	wget http://www.isbe.net/assessment/zip/rc14.zip

.INTERMEDIATE: RC06_layout.xls RC98_layout.xls rc98bu.zip	\
               RC99_layout.xls rc99lay.zip RC00_layout.xls	\
               Rc00lay.zip RC01_layout.xls RC01_layout.zip	\
               RC02_layout.xls RC03_layout.zip RC03_layout.xls	\
               RC06_layout.xls RC10_layout.xls RC11_layout.xls	\
               RC12_layout.xls

RC9%_layout.xls : rc9%.zip
	$(unzip-rename)

RC98_layout.xls : rc98u.zip
	$(unzip-rename)

RC99_layout.xls : rc99lay.zip
	$(unzip-rename)

RC0%_layout.xls :
	wget ftp://ftp.isbe.net/SchoolReportCard/200$*%20School%20Report%20Card/$@

RC00_layout.xls : Rc00lay.zip
	$(unzip-rename)

RC01_layout.xls : RC01_layout.zip
	$(unzip-rename)

RC02_layout.xls :
	wget -O $@ http://www.isbe.net/research/Report_Card_02/ReportCard02_layout.xls

RC03_layout.xls :
	wget http://www.isbe.net/research/xls/RC03_layout.xls

RC06_layout.xls :
	wget "ftp://ftp.isbe.net/SchoolReportCard/2006%20School%20Report%20Card(updated%20033007)/RC06_layout.xls"

RC10_layout.xls :
	wget http://www.isbe.net/research/xls/RC10_layout.xls

RC1%_layout.xlsx :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/201$*%20School%20Report%20Card/$@

RC11_layout.xls :
	wget http://www.isbe.net/assessment/xls/RC11_layout.xls

RC12_layout.xls :
	wget -O $@ http://www.isbe.net/assessment/xls/RC12-layout.xls


.INTERMEDIATE: RC13_layout.csv RC14_layout.csv RC13_layout.xlsx	\
               RC14_layout.xlsx RC15_layout.csv RC15_layout.xlsx

%.csv : %.xls 
	unoconv --format csv $<

RC13_layout.csv : RC13_layout.xlsx 
	unoconv --format csv $<

RC14_layout.csv : RC14_layout.xlsx 
	unoconv --format csv $<

RC15_layout.csv : RC15_layout.xlsx 
	unoconv --format csv $<

schema_19%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

schema_20%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

.INTERMEDIATE : rc1998u.txt rc98u.zip rc2000u.txt Rc00u.zip		\
                rc02All.zip rc2002u.txt rc2004u.txt			\
                rc04u_updated092005.zip rc2006u.txt rc06.zip		\
                rc2007u.txt rc07.zip rc2009u.txt rc09.zip rc2010u.txt	\
                rc10.zip rc2015u.txt

rc199%u.txt : rc9%u.zip
	$(unzip-rename)

rc1998u.txt : rc98bu.zip
	$(unzip-rename)

rc200%u.txt : rc0%u.zip
	$(unzip-rename)

rc2000u.txt : Rc00u.zip
	$(unzip-rename)

rc02All.zip :
	wget http://www.isbe.net/research/Report_Card_02/rc02All.zip
	touch $@

rc2002u.txt : rc02All.zip
	$(unzip-rename)

rc2004u.txt : rc04u_updated092005.zip
	$(unzip-rename)

rc2006u.txt : rc06.zip
	$(unzip-rename)

rc2007u.txt : rc07.zip
	$(unzip-rename)

rc2009u.txt : rc09.zip
	$(unzip-rename)

rc2010u.txt : rc10.zip
	$(unzip-rename)

rc201%u.txt : rc1%.zip
	$(unzip-rename)

rc2015u.txt :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/2015%20School%20Report%20Card/rc15.txt

rc_%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@

.PHONY : school.table
raw_school.table : $(rcs)
	-psql -d $(PG_DB) -c 'CREATE TABLE raw_school (rcdts TEXT, type TEXT, name TEXT, district TEXT, city TEXT, year INT)'
	for year in $(years); \
		do csvcut -c 1,2,3,4,5 rc_$$year.csv | sed "s/$$/,$$year/" | psql -d $(PG_DB) -c 'COPY raw_school FROM STDIN WITH CSV HEADER' ; \
	done

crosswalk.table : 
	psql -d $(PG_DB) -c "CREATE TABLE crosswalk \
                             AS \
                             SELECT DISTINCT \
                                    (substring(rcdts from 3 for 7) \
                                     || substring(rcdts from '.{4}$$')) AS id, \
                             rcdts \
                             FROM raw_school"

school.table :
	psql -d $(PG_DB) -c "create table school as select distinct id as school_id, substring(rcdts from 3 for 7) as district_id, CASE WHEN substring(id from 8 for 1)='0' THEN 'High School' WHEN substring(id from 8 for 1)='1' THEN 'Middle/Junior High School' ELSE 'Elementary School' END as type, MIN(year) OVER (PARTITION BY id), MAX(year) OVER (PARTITION BY id) from crosswalk inner join raw_school using (rcdts)"

district.table : 
	psql -d $(PG_DB) -c "create table district as select distinct on(district_id) substring(rcdts from 3 for 7) as district_id, substring(rcdts from 3 for 3) as county, CASE WHEN length(rcdts)=15 THEN substring(rcdts from 10 for 2) ELSE NULL END as type, MIN(year) OVER (PARTITION BY substring(rcdts from 3 for 7)), MAX(year) OVER (PARTITION BY SUBSTRING(rcdts from 3 for 7)) from crosswalk inner join raw_school using (rcdts) order by district_id, type"

act_columns = "ACT COMP SCHOOL","ACT ENGL SCHOOL SCORE","ACT MATH SCHOOL SCORE","ACT READ SCHOOL SCORE","ACT SCIE SCHOOL SCORE"

act.table :
	-psql -d $(PG_DB) -c 'CREATE TABLE raw_act (rcdts TEXT, act_composite FLOAT, act_english FLOAT, act_math FLOAT, act_reading FLOAT, act_science FLOAT, year INT)'
	for year in $(years); \
		do csvcut -c 1,$(act_columns) rc_$$year.csv | sed "s/$$/,$$year/" | psql -d $(PG_DB) -c 'COPY raw_act FROM STDIN WITH CSV HEADER' ; \
	done




# chicago 0162990 
# invariants
# - county
# - district
# (these don't change without the school id changing. effectively different school)
# type code
