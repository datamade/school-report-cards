# ================================================
#
# CLEAN AND IMPORT DATA INTO A POSTGRES DATABASE
#
# ================================================
#
# Once the CSVs have been downloaded and converted, this makefile
# uses them to create a Postgres database on the user's machine.
# ------------------------------------------------

# Macro for properly parsing hash characters in strings.
HASH = \#

# Canned sequence for simplifying the creation of Postgres tables.
# Translation: "Check to see if a table with the name of the target
# exists, logging output and errors in /dev/null. 
# If that fails, follow the custom command specified after the
# function call to make the table."
define create_relation
 psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
 psql -d $(PG_DB) -c 
endef

# Identical to `create_relation`, except the custom command that
# gets called to create the table (if no table exists) will 
# get called in its own shell.
define create_relation_and
 psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
 (psql -d $(PG_DB) -c 
endef

# General rule for importing a raw table (lots of extraneous data and not
# normalized) into the postgres DB. 
raw_% : $(rcs)
	psql -d $(PG_DB) -c "\d $@" > /dev/null 2>&1 || \
	(psql -d $(PG_DB) -c 'CREATE TABLE $@ (rcdts TEXT, $($@_defs), year INT)' && \
	 for year in $(years); \
	    do csvcut -c 1,$($@_cols) rc_$$year.csv | \
               sed "s/$$/,$$year/" | \
               psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER' ; \
	 done)

# Create a report card crosswalk, with a unique entry for each school,
# by eliminating duplicates from `raw_school`.
rcdts_crosswalk : raw_school
	$(create_relation) "CREATE TABLE rcdts_crosswalk \
                            AS \
                            SELECT DISTINCT \
                                   (SUBSTRING(rcdts FROM 3 FOR 7) \
                                    || SUBSTRING(rcdts FROM '.{4}$$')) AS school_id, \
                            rcdts \
                            FROM raw_school"

# Final columns for `raw_school`.
raw_school_defs = type TEXT, name TEXT, district TEXT, city TEXT
# Initial columns for `raw_school` (less legible).
raw_school_cols = 2,3,4,5

# ================================================
# 
# CREATE THE TABLES
# 
# ================================================
#
# The rest of the targets on this page are the final tables that show
# up in the Postgres database. Each one is generated out of raw data and
# the crosswalk, using SQL queries in order to clean and format the table.
#
# As with `raw_schools`, each table has a set of variables mapping the initial
# column name (`raw_%_cols`) to a new column name (`raw_%_defs`).
# ------------------------------------------------
    
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

raw_act_defs = composite FLOAT, english FLOAT, math FLOAT, reading FLOAT, \
               science FLOAT
raw_act_cols = "ACT COMP SCHOOL","ACT ENGL SCHOOL SCORE","ACT MATH SCHOOL SCORE","ACT READ SCHOOL SCORE","ACT SCIE SCHOOL SCORE"

act : raw_act rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT \
                                      school_id, composite, english, \
                                      math, reading, science, year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts) \
                            WHERE composite IS NOT NULL"

raw_district_act_defs  = composite FLOAT, english FLOAT, math FLOAT, \
                         reading FLOAT, science FLOAT
raw_district_act_cols = "ACT COMP DISTRICT","ACT ENGL DISTRICT SCORE","ACT MATH DISTRICT SCORE","ACT READ DISTRICT SCORE","ACT SCIE DISTRICT SCORE"

district_act : raw_district_act
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT \
                                      SUBSTRING(rcdts FROM 3 FOR 7) AS district_id, \
                                      composite, english, math, \
                                      reading, science, year \
                            FROM $< WHERE composite IS NOT NULL"

raw_demography_defs = white_percent FLOAT, black_percent FLOAT, \
                      hispanic_percent FLOAT, asian_percent FLOAT, \
                      native_american_percent FLOAT, total TEXT, \
                      limited_english_proficiency_percent FLOAT, \
                      low_income_percent FLOAT, \
                      individualized_education_plan FLOAT \

raw_demography_cols = "SCHOOL - WHITE %","SCHOOL - BLACK %","SCHOOL - HISPANIC %","SCHOOL - ASIAN %","SCHOOL - NATIVE AMERICAN %","SCHOOL TOTAL ENROLLMENT","L.E.P. SCHOOL %","LOW - INCOME SCHOOL %","I.E.P. SCHOOL %"

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
                                      individualized_education_plan/100 AS individualed_education_plan_rate, \
                                      year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts)"


raw_characteristics_defs = parental_involvement_percent FLOAT, \
                           mobility_rate FLOAT, \
                           dropout_rate FLOAT, \
                           chronic_truants TEXT, \
                           chronic_truants_rate FLOAT, \
                           graduation_rate FLOAT
raw_characteristics_cols =  "PARENTAL INVOLVEMENT SCHOOL %","MOBILITY RATE SCHOOL %","DROPOUT RATE SCHOOL %","CHRONIC TRUANTS $(HASH) - SCHOOL","CHRONIC TRUANTS RATE SCHOOL %","HS 4 - YEAR GRAD RATE SCHOOL %; ALL"

characteristics : raw_characteristics rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                             AS SELECT DISTINCT \
                                       school_id, \
                                       parental_involvement_percent/100 AS parental_involvement_percent, \
                                       mobility_rate/100 AS mobility_rate, \
                                       dropout_rate/100 AS dropout_rate, \
                                       replace(chronic_truants, ',','')::numeric chronic_truants, \
	                               chronic_truants_rate/100 as chronic_truants_rate, \
                                       graduation_rate/100 as graduation_rate, \
                                       year \
                             FROM $< INNER JOIN $(word 2,$^) \
                             USING (rcdts)"

raw_district_characteristics_defs = parental_involvement_percent FLOAT, \
                                    mobility_rate FLOAT, \
                                    dropout_rate FLOAT, \
                                    chronic_truants TEXT, \
                                    chronic_truants_rate FLOAT, \
                                    graduation_rate FLOAT
raw_district_characteristics_cols =  "PARENTAL INVOLVEMENT DISTRICT %","MOBILITY RATE DISTRICT %","DROPOUT RATE DISTRICT %","CHRONIC TRUANTS $(HASH) - DISTRICT","CHRONIC TRUANTS RATE DISTRICT %","HS 4 - YEAR GRAD RATE DISTRICT %; ALL"

district_characteristics : raw_district_characteristics
	$(create_relation) "CREATE TABLE $@ \
                             AS SELECT DISTINCT ON (district_id, year)\
                                       SUBSTRING(rcdts FROM 3 FOR 7) AS district_id, \
                                       parental_involvement_percent/100 AS parental_involvement_percent, \
                                       mobility_rate/100 AS mobility_rate, \
                                       dropout_rate/100 AS dropout_rate, \
                                       replace(chronic_truants, ',','')::numeric chronic_truants, \
	                               chronic_truants_rate/100 as chronic_truants_rate, \
                                       graduation_rate/100 as graduation_rate, \
                                       year \
                             FROM $< ORDER BY district_id, year, dropout_rate NULLS LAST, graduation_rate NULLS LAST"

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
                                          'eighth']) as grade, \
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

raw_grades_defs = grades TEXT
raw_grades_cols = "GRADES IN SCHOOL"

grades : raw_grades rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT DISTINCT \
                                   school_id, \
                                   STRING_TO_ARRAY(grades, ' ') AS grades, \
                                   year \
                            FROM $< INNER JOIN $(word 2,$^) \
                            USING (rcdts)"
