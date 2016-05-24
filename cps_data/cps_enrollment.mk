.PHONY : cps_school_data
cps_school_data :
	wget -P cps_data/ -e robots=off -r -l 1 -nd -N -A xls,xlsx -H http://cps.edu/SchoolData/Pages/SchoolData.aspx

enrollment = $(patsubst %,enrollment_%.csv,$(years))
unpadded_enrollment = $(patsubst %,unpadded_%,$(enrollment))

.INTERMEDIATE : $(unpadded_enrollment)
.INTERMEDIATE : $(enrollment)

.INTERMEDIATE : oneyr_all_schools_1999through2014.csv
$(unpadded_enrollment) : oneyr_all_schools_1999through2014.csv

unpadded_enrollment_1999.csv : 
	csvcut -c 2,85 $< > $@

unpadded_enrollment_2000.csv : 
	csvcut -c 2,86 $< > $@

unpadded_enrollment_2001.csv : 
	csvcut -c 2,87 $< > $@

unpadded_enrollment_2002.csv : 
	csvcut -c 2,88 $< > $@

unpadded_enrollment_2003.csv : 
	csvcut -c 2,89 $< > $@

unpadded_enrollment_2004.csv : 
	csvcut -c 2,90 $< > $@

unpadded_enrollment_2005.csv : 
	csvcut -c 2,91 $< > $@

enrollment_%.csv : enrollment_20th_day_%.csv
	csvcut -c "School ID",7-19 $< > $@

enrollment_%.csv : enrollment_20th_day_%_GV_20151023.csv
	in2csv $< | csvcut -c "School ID",7-19 $< > $@

.INTERMEDIATE : enrollment_20th_day_2014-15.csv
enrollment_2015.csv : enrollment_20th_day_2014-15.csv
	in2csv $< | csvcut -c "School ID",7-19 $< > $@

.INTERMEDIATE : membership_20th_day_2006.csv	\
	        membership_20th_day_2007.csv	\
	        membership_20th_day_2008.csv	\
	        membership_20th_day_2009.csv

enrollment_2006.csv enrollment_2007.csv : enrollment_%.csv: membership_20th_day_%.csv
	csvcut -c "School ID",11-23 $< > $@

enrollment_2008.csv : membership_20th_day_2008.csv
	csvcut -c "School ID",9-21 $< > $@

enrollment_2009.csv : membership_20th_day_2009.csv
	csvcut -c "School ID",5-16,Totals $< > $@

enrollment_%.csv : membership_20th_day_%.csv
	csvcut -c "School ID",8-19,Totals $< > $@

enrollment_%.csv : unpadded_enrollment_%.csv
	tail -n +3 $< | awk 'BEGIN{FS=OFS=","} {$$2=",,,,,,,,,,,,"$$2;} 1'> $@

raw_cps_enrollment : $(enrollment)
	$(create_relation_and) "CREATE TABLE $@ (cps_id FLOAT, \
                                                 \"1\" INT, \"2\" INT, \
                                                 \"3\" INT, \"4\" INT, \
                                                 \"5\" INT, \"6\" INT, \
                                                 \"7\" INT, \"8\" INT, \
                                                 \"9\" INT, \"10\" INT, \
                                                 \"11\" INT, \"12\" INT, \
                                                 total FLOAT, \
                                                 year INT)" && \
	for year in $(years); \
            do cat enrollment_$$year.csv | sed "s/$$/,$$year/" | psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER';\
        done)

cps_enrollment : raw_cps_enrollment
	$(create_relation) "CREATE TABLE $@ AS \
                            SELECT * FROM \
                             (SELECT cps_id::TEXT, \
                              year, \
                              UNNEST(ARRAY['first', \
                                           'second', \
                                           'third', \
                                           'fourth', \
                                           'fifth', \
                                           'sixth', \
                                           'seventh', \
                                           'eighth', \
                                           'ninth', \
                                           'tenth', \
                                           'eleventh', \
                                           'twelfth', \
                                           'all']) AS grade, \
                              UNNEST(ARRAY[\"1\", \
                                           \"2\", \
                                           \"3\", \
                                           \"4\", \
                                           \"5\", \
                                           \"6\", \
                                           \"7\", \
                                           \"8\", \
                                           \"9\", \
                                           \"10\", \
                                           \"11\", \
                                           \"12\", \
                                           total::INT]) AS total \
                              FROM $<) AS t \
                             WHERE total IS NOT NULL AND total > 0"
