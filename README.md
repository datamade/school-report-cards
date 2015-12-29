school-report-cards
===================

Tools for parsing annual school report card data from the state of Illinois

If you run `make` the program will
1. Download ISBE report card data from 1997-2015
2. Convert the fixed with files to csv format, with normalized column names
3. Import the data into normalized tables in a postgresql database

1 and 2 are finished. I'll start with 3 with data that is present
across the entire time period.

## Requirements
* [GNU Make](https://www.gnu.org/software/make/)
* [GNU Wget](https://www.gnu.org/software/wget/)
* [Python](https://www.python.org/downloads/)
* [unoconv](http://dag.wiee.rs/home-made/unoconv/)
* [csvkit](https://csvkit.readthedocs.org/en/0.9.1/install.html)
* [SQLAlchemy](http://www.sqlalchemy.org/)
* [PostgreSQL](http://www.postgresql.org/)
* [unzip](http://www.info-zip.org/)

