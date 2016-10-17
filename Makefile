# ================================================
# 
# MASTER MAKEFILE
#
# ================================================
#
# `make` starts building with this file, generating
# either `csv` or `database` depending on the user's command.
# ------------------------------------------------

# Read the other makefiles before starting.
include config.mk csv.mk normalize_isbe.mk

# List of all relevant CPS years (for iteration and filenames).
years = 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008	\
        2009 2010 2011 2012 2013 2014 2015

# Generate the report card filenames from the list of years.
rcs = $(patsubst %,rc_%.csv,$(years))

# The master command for `make`ing CSVs for each report card by year.
csv : $(rcs)
	# No commands, because the rules for generating CSVs are specified
	# in `csv.mk.`

# The master command for `make`ing a Postgres DB out of the data.
# (Also automatically `make`s CSVs.)
database : csv act school district demography characteristics average_class_size \
           minutes_per_subject grades cps_crosswalk
    # No commands, because the rules for generating the dependencies are
    # specified primarily in `normalize_isbe.mk` (and also below).

# Get 2013-2014 data from the Internet in order to generate a
# crosswalk in the next rule.
.INTERMEDIATE : CPS_Schools_2013-2014_Academic_Year.csv
CPS_Schools_2013-2014_Academic_Year.csv :
	wget -O $@ https://data.cityofchicago.org/api/views/c7jj-qjvh/rows.csv?accessType=DOWNLOAD

# Create a crosswalk table (for matching columns across tables)
# using relevant columns in the 2013-2014 data.
raw_cps_crosswalk : CPS_Schools_2013-2014_Academic_Year.csv
	$(create_relation_and) "CREATE TABLE $@ \
                               (cps_id TEXT, cps_unit TEXT, rcdts TEXT, \
                                oracle_id TEXT)" \
        && csvcut -c "SchoolID","CPS Unit","ISBE ID","OracleID" $< | \
           psql -d $(PG_DB) -c 'COPY $@ FROM STDIN WITH CSV HEADER')

# Refine the crosswalk by joining it with the report card crosswalk
# generated in `normalize_isbe.mk`.
cps_crosswalk : raw_cps_crosswalk rcdts_crosswalk
	$(create_relation) "CREATE TABLE $@ \
                            AS SELECT school_id, cps_id, cps_unit, oracle_id \
                            FROM $< INNER JOIN $(word 2,$^) \
                            using(rcdts)"
