school-report-cards
===================

Tools for parsing annual school report card data from the state of Illinois

If you run `make` the program will

1. Download ISBE report card data from 1997-2015
2. Convert the fixed with files to csv format, with normalized column names
3. Import the data into normalized tables in a postgresql database

Right now, these scripts only fully process the school-level data that
appears in all 22 years of data. These include

* ACT Scores
* Demography and enrollment
* Time spent on subject
* Class sizes

## Requirements
* [GNU Make](https://www.gnu.org/software/make/)
* [GNU Wget](https://www.gnu.org/software/wget/)
* [Python](https://www.python.org/downloads/)
* [unoconv](http://dag.wiee.rs/home-made/unoconv/)
* [csvkit](https://csvkit.readthedocs.org/en/0.9.1/install.html)
* [PostgreSQL](http://www.postgresql.org/)
* [unzip](http://www.info-zip.org/)

