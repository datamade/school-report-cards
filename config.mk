# ================================================
# 
# GENERAL MACROS
#
# ================================================
#
# These variables help configure the makefile and set up the database.
# ------------------------------------------------

# DataMade's standard Makefile macros.
MAKEFLAGS += --warn-undefined-variables
SHELL := bash
.DEFAULT_GOAL := all
.DELETE_ON_ERROR:
.SUFFIXES:

# Macros for uniformly querying Postgres DB.
PG_HOST="localhost"
PG_USER="fgregg"
PG_DB="schools"
PG_PORT="5432"
PG_PASS="buddah"
