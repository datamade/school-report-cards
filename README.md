School Report Cards
===================
[![Linux build](https://img.shields.io/travis/datamade/school-report-cards.svg?style=flat-square&label=Linux build)](https://travis-ci.org/datamade/school-report-cards)[![Mac OS X build](https://img.shields.io/travis/datamade/school-report-cards.svg?style=flat-square&label=Mac OS X build)](https://travis-ci.org/datamade/school-report-cards)

Tools for parsing annual school report card data from the state of Illinois

## Requirements
* [GNU Make](https://www.gnu.org/software/make/)
* [GNU Wget](https://www.gnu.org/software/wget/)
* [Python 3](https://www.python.org/downloads/)
* [csvkit](https://csvkit.readthedocs.io/en/latest/tutorial/1_getting_started.html#installing-csvkit)
* [xlsx2csv](https://github.com/dilshod/xlsx2csv)
* [PostgreSQL](http://www.postgresql.org/)
* [unzip](http://www.info-zip.org/)

### Ubuntu
Most of these dependencies are installed by default
```
sudo apt-get install postgresql
pip install csvkit
pip install xlsx2csv
```

### Mac OS X
Most of these dependencies are installed by default
```
brew install postgresql
pip install csvkit
pip install xlsx2csv
```

## `make database`

You will need to run `createdb schools` to initialize the postgres database.

Running `make database` will import the data into
normalized tables in a postgresql database.

Right now, the database scripts only fully process the school-level
data that appears in all 22 years of data. These include:

* ACT Scores
* Demography and enrollment
* Time spent on subject
* Class sizes, by grade
* School level characteristics like parent involvement, truancy, and graduation rate.

## `make csv`

If you just wish to download the data without importing it into a database, run `make csv`. It will:

1. Download ISBE report card data from 1997-2015
2. Convert the fixed width files to csv format, with year-over-year normalized column names
