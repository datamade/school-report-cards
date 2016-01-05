include config.mk

HASH = \#

97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

years = 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008	\
        2009 2010 2011 2012 2013 2014 2015

rcs = $(patsubst %,rc_%.csv,$(years))

raw_school_defs = type TEXT, name TEXT, district TEXT, city TEXT
raw_school_cols = 2,3,4,5

raw_act_defs = composite FLOAT, english FLOAT, math FLOAT, reading FLOAT, \
               science FLOAT
raw_act_cols = "ACT COMP SCHOOL","ACT ENGL SCHOOL SCORE","ACT MATH SCHOOL SCORE","ACT READ SCHOOL SCORE","ACT SCIE SCHOOL SCORE"

raw_demography_defs = white_percent FLOAT, black_percent FLOAT, \
                      hispanic_percent FLOAT, asian_percent FLOAT, \
                      native_american_percent FLOAT, total TEXT, \
                      limited_english_proficiency_percent FLOAT, \
                      low_income_percent FLOAT 

raw_demography_cols = "SCHOOL - WHITE %","SCHOOL - BLACK %","SCHOOL - HISPANIC %","SCHOOL - ASIAN %","SCHOOL - NATIVE AMERICAN %","SCHOOL TOTAL ENROLLMENT","L.E.P. SCHOOL %","LOW - INCOME SCHOOL %"

raw_characteristics_defs = parental_involvement_percent FLOAT, \
                           mobility_rate FLOAT, \
                           dropout_rate FLOAT, \
                           chronic_truants TEXT, \
                           chronic_truants_rate FLOAT
raw_characteristics_cols =  "PARENTAL INVOLVEMENT SCHOOL %","MOBILITY RATE SCHOOL %","DROPOUT RATE SCHOOL %","CHRONIC TRUANTS $(HASH) - SCHOOL","CHRONIC TRUANTS RATE SCHOOL %"

raw_instructional_defs = average_class_size_kg FLOAT, \
                         average_class_size_g1 FLOAT, \
                         average_class_size_g3 FLOAT, \
                         average_class_size_g6 FLOAT, \
                         average_class_size_g8 FLOAT, \
                         average_class_size_hs FLOAT, \
                         minutes_per_day_math_g3 INT, \
                         minutes_per_day_math_g6 INT, \
                         minutes_per_day_math_g8 INT, \
                         minutes_per_day_science_g3 INT, \
                         minutes_per_day_science_g6 INT, \
                         minutes_per_day_science_g8 INT, \
                         minutes_per_day_english_g3 INT, \
                         minutes_per_day_english_g6 INT, \
                         minutes_per_day_english_g8 INT, \
                         minutes_per_day_social_science_g3 INT, \
                         minutes_per_day_social_science_g6 INT, \
                         minutes_per_day_social_science_g8 INT
raw_instructional_cols = "AVG CLASS SIZE - SCHOOL (KG)","AVG CLASS SIZE - SCHOOL (GR1)","AVG CLASS SIZE - SCHOOL (GR3)","AVG CLASS SIZE - SCHOOL (GR6)","AVG CLASS SIZE - SCHOOL (GR8)","AVG CLASS SIZE - SCHOOL (H.S.)","MIN PER DAY MATH (GR3) SCHOOL","MIN PER DAY MATH (GR6) SCHOOL","MIN PER DAY MATH (GR8) SCHOOL","MIN PER DAY SCIE (GR3) SCHOOL","MIN PER DAY SCIE (GR6) SCHOOL","MIN PER DAY SCIE (GR8) SCHOOL","MIN PER DAY ENGL (GR3) SCHOOL","MIN PER DAY ENGL (GR6) SCHOOL","MIN PER DAY ENGL (GR8) SCHOOL","MIN PER DAY SOSC (GR3) SCHOOL","MIN PER DAY SOSC (GR6) SCHOOL","MIN PER DAY SOSC (GR8) SCHOOL"

raw_grades_defs = grades TEXT
raw_grades_cols = "GRADES IN SCHOOL"

define unzip-rename
unzip -p $< > $@
endef

define create_relation
 psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
 psql -d $(PG_DB) -c 
endef

define create_relation_and
 psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
 (psql -d $(PG_DB) -c 
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

raw_% : $(rcs)
	psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
	(psql -d $(PG_DB) -c 'CREATE TABLE $@ (rcdts TEXT, $($@_defs), year INT)' && \
	 for year in $(years); \
	    do csvcut -c 1,$($@_cols) rc_$$year.csv | \
               sed "s/$$/,$$year/" | \
               psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER' ; \
	 done)

rcdts_crosswalk : raw_school
	$(create_relation) "CREATE TABLE rcdts_crosswalk \
                            AS \
                            SELECT DISTINCT \
                                   (SUBSTRING(rcdts FROM 3 FOR 7) \
                                    || SUBSTRING(rcdts FROM '.{4}$$')) AS school_id, \
                            rcdts \
                            FROM raw_school"

school : rcdts_crosswalk raw_school
	$(create_relation) "CREATE TABLE school \
                            AS SELECT DISTINCT \
                                      school_id, \
                                      LAST_VALUE(name) \
                                          OVER (partition BY school_id \
                                                ORDER BY year \
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as name, \
                                      SUBSTRING(school_id FROM 1 FOR 7) AS district_id, \
                                      CASE WHEN SUBSTRING(school_id FROM 8 FOR 1)='0' \
                                           THEN 'High School' \
                                           WHEN SUBSTRING(school_id FROM 8 fOR 1)='1' \
                                           THEN 'Middle/Junior High School' \
                                           ELSE 'Elementary School' \
                                      END as type, \
                                      MIN(year) OVER (PARTITION BY school_id), \
                                      MAX(year) OVER (PARTITION BY school_id) \
                               FROM $< INNER JOIN $(word 2,$^) \
                               USING (rcdts)"


district : rcdts_crosswalk raw_school
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT ON(district_id) \
                                      SUBSTRING(rcdts FROM 3 FOR 7) AS district_id, \
                                      LAST_VALUE(district) \
                                          OVER (partition BY SUBSTRING(rcdts FROM 3 FOR 7) \
                                                ORDER BY year \
                                                ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as name, \
                                      SUBSTRING(rcdts FROM 3 FOR 3) AS county, \
                                      CASE WHEN LENGTH(rcdts)=15 \
                                           THEN SUBSTRING(rcdts FROM 10 FOR 2) \
                                           ELSE NULL \
                                      END AS type, \
                                      MIN(year) OVER (PARTITION BY SUBSTRING(rcdts FROM 3 FOR 7)), \
                                      MAX(year) OVER (PARTITION BY SUBSTRING(rcdts from 3 for 7)) \
                               FROM $< INNER JOIN $(word 2,$^) \
                               USING (rcdts) \
                               ORDER BY district_id, type"

act : raw_act rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT school_id, composite, english, \
                                      math, reading, science, year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts) \
                            WHERE composite IS NOT NULL"

demography : raw_demography rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT \
                                      school_id, \
                                      white_percent/100 as white_percent, \
                                      black_percent/100 as black_percent, \
                                      hispanic_percent/100 as hispanic_percent, \
                                      asian_percent/100 as asian_percent, \
                                      native_american_percent/100 as native_american_percent, \
                                      replace(total, ',', '')::integer AS total, \
                                      limited_english_proficiency_percent/100 as limited_english_proficiency, \
                                      low_income_percent/100 as low_income_percent, \
                                      year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts)"

characteristics : raw_characteristics rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                             AS SELECT DISTINCT \
                                       school_id, \
                                       parental_involvement_percent/100 AS parental_involvment_percent, \
                                       mobility_rate/100 AS mobility_rate, \
                                       dropout_rate/100 AS dropout_rate, \
                                       replace(chronic_truants, ',','')::numeric, \
	                               chronic_truants_rate/100 as chronic_truants_rate, \
                                       year \
                             FROM $< INNER JOIN $(word 2,$^) \
                             USING (rcdts)"


average_class_size : raw_instructional rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT * FROM \
                            (SELECT school_id, \
                                    UNNEST(ARRAY['kindergarten', \
                                                 'first', \
                                                 'third', \
                                                 'sixth', \
                                                 'eighth', \
                                                 'high school']) AS grade, \
                                    UNNEST(ARRAY[average_class_size_kg, \
                                                 average_class_size_g1, \
                                                 average_class_size_g3, \
                                                 average_class_size_g6, \
                                                 average_class_size_g8, \
                                                 average_class_size_hs]) AS average_class_size, \
                                    year \
                             FROM $< INNER JOIN $(word 2,$^) \
                             USING (rcdts)) AS t \
                            WHERE average_class_size IS NOT NULL"

minutes_per_subject : raw_instructional rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT * FROM \
                            (SELECT school_id, \
                             UNNEST(ARRAY['third', \
                                          'sixth', \
                                          'eighth']), \
                             UNNEST(ARRAY[minutes_per_day_math_g3, \
                                          minutes_per_day_math_g6, \
                                          minutes_per_day_math_g8]) AS math, \
                             UNNEST(ARRAY[minutes_per_day_english_g3, \
                                          minutes_per_day_english_g6, \
                                          minutes_per_day_english_g8]) AS english, \
                             UNNEST(ARRAY[minutes_per_day_science_g3, \
                                          minutes_per_day_science_g6, \
                                          minutes_per_day_science_g8]) AS science, \
                             UNNEST(ARRAY[minutes_per_day_social_science_g3, \
                                          minutes_per_day_social_science_g6, \
                                          minutes_per_day_social_science_g8]) AS social_science, \
                             year \
                             FROM $< INNER JOIN $(word 2,$^) \
                             USING (rcdts)) as t \
                            WHERE math IS NOT NULL \
                                  OR english IS NOT NULL \
                                  OR science IS NOT NULL \
                                  OR social_science IS NOT NULL"

grades : raw_grades rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT \
                                   school_id, \
                                   STRING_TO_ARRAY(grades, ' ') AS grades, \
                                   year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts)"

.INTERMEDIATE : CPS_Schools_2013-2014_Academic_Year.csv
CPS_Schools_2013-2014_Academic_Year.csv :
	wget -O $@ https://data.cityofchicago.org/api/views/c7jj-qjvh/rows.csv?accessType=DOWNLOAD

raw_cps_crosswalk : CPS_Schools_2013-2014_Academic_Year.csv
	$(create_relation_and) "CREATE TABLE $@ \
                               (cps_id TEXT, cps_unit TEXT, rcdts TEXT, \
                                oracle_id TEXT)" \
        && csvcut -c "SchoolID","CPS Unit","ISBE ID","OracleID" $< | \
           psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER')

cps_crosswalk : raw_cps_crosswalk rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT school_id, cps_id, cps_unit, oracle_id \
                            FROM $< INNER JOIN $(word 2,$^) \
                            using(rcdts)"


all : act school district demography characteristics average_class_size \
      minutes_per_subject grades
