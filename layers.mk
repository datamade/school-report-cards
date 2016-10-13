postgis:
	- psql -d $(PG_DB) -c "CREATE EXTENSION postgis"
	touch $@

tl_2016_17_unsd.zip :
	wget -O $@ 'ftp://ftp2.census.gov/geo/tiger/TIGER2016/UNSD/tl_2016_17_unsd.zip'

tl_2016_17_elsd.zip :
	wget -O $@ 'ftp://ftp2.census.gov/geo/tiger/TIGER2016/ELSD/tl_2016_17_elsd.zip'

tl_2016_17_scsd.zip :
	wget -O $@ 'ftp://ftp2.census.gov/geo/tiger/TIGER2016/SCSD/tl_2016_17_scsd.zip'


# unzip shapefiles
tl_2016_17_%.shp : tl_2016_17_%.zip
	unzip $^
	touch $@

# import district shapefile to the school report card DB
%_boundaries : tl_2016_17_%.shp postgis
	shp2pgsql -s 4326 -d $< $@ | psql -d $(PG_DB)
	touch $@

district_boundaries : unsd_boundaries elsd_boundaries scsd_boundaries
	psql -d $(PG_DB) -c "CREATE TABLE $@ AS \
                             (SELECT * FROM $< \
                              UNION \
                              SELECT * FROM $(word 2,$^) \
                              UNION \
                              SELECT * FROM $(word 3,$^))"
