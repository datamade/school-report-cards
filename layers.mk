postgis:
	- psql -d $(PG_DB) -c "CREATE EXTENSION postgis"
	touch $@

tl_2016_17_unsd.zip :
	wget -O $@ 'ftp://ftp2.census.gov/geo/tiger/TIGER2016/UNSD/tl_2016_17_unsd.zip'

# unzip shapefiles
tl_2016_17_unsd.shp : tl_2016_17_unsd.zip
	unzip $^
	touch $@

# import district shapefile to the school report card DB
district_boundaries : tl_2016_17_unsd.shp postgis
	shp2pgsql -s 4326 $< $@ | psql -d $(PG_DB)
	touch $@
