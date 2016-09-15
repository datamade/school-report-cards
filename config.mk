MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

PG_HOST="localhost"
PG_USER="fgregg"
PG_DB="schools"
PG_PORT="5432"
PG_PASS="buddah"
