# ================================================
# 
# GET DATA FROM THE INTERNET AND CONVERT TO CSV
#
# ================================================
#
# The ISBE report card data is stashed in a bunch of different
# places and a bunch of different formats. These rules get
# data from the right URLs and convert it to CSV.
# ------------------------------------------------

97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

# Canned sequence for unzipping files.
# Translation: "Unzip the first dependency and 
# redirect its data to the target."
define unzip-rename
unzip -p $< > $@
endef

# General rule for getting .zip files from ISBE.
%.zip :
	wget http://www.isbe.net/research/zip/$@

# Special rule for getting report cards 11-14.
.INTERMEDIATE : rc11.zip rc12.zip rc13.zip rc14.zip
rc11.zip rc12.zip rc13.zip rc14.zip :
	wget http://www.isbe.net/assessment/zip/$@

# Special rule for getting report card 02.
.INTERMEDIATE : rc02All.zip
rc02All.zip :
	wget http://www.isbe.net/research/Report_Card_02/$@


.INTERMEDIATE: RC06_layout.xls RC98_layout.xls rc98bu.zip	\
               RC99_layout.xls rc99lay.zip RC00_layout.xls	\
               Rc00lay.zip RC01_layout.xls RC01_layout.zip	\
               RC02_layout.xls RC03_layout.zip RC03_layout.xls	\
               RC06_layout.xls RC10_layout.xls RC11_layout.xls	\
               RC12_layout.xls RC97_layout.xls rc97.zip

# Specific dependencies for report card layouts 97-01.
RC97_layout.xls : rc97.zip
RC98_layout.xls : rc98u.zip
RC99_layout.xls : rc99lay.zip
RC00_layout.xls : Rc00lay.zip
RC01_layout.xls : RC01_layout.zip

# Special rules for getting report card layouts 97-01.
RC97_layout.xls RC98_layout.xls RC99_layout.xls RC00_layout.xls RC01_layout.xls:
	$(unzip-rename)	

# Special rules for getting report card layout 02.
RC02_layout.xls :
	wget -O $@ http://www.isbe.net/research/Report_Card_02/ReportCard02_layout.xls

# Special rules for getting report card layout 02 and 10.
RC03_layout.xls RC10_layout.xls :
	wget http://www.isbe.net/research/xls/$@

# General rules for getting report card layouts.
RC%_layout.xls RC%_layout.xlsx :
	wget ftp://ftp.isbe.net/SchoolReportCard/20$*%20School%20Report%20Card/$@

# Special rule for getting report card layout 06.
RC06_layout.xls :
	wget "ftp://ftp.isbe.net/SchoolReportCard/2006%20School%20Report%20Card(updated%20033007)/$@"

# Special rule for getting report card layout 11.
RC11_layout.xls :
	wget http://www.isbe.net/assessment/xls/$@

# Special rule for getting report card layout 12.
RC12_layout.xls :
	wget -O $@ http://www.isbe.net/assessment/xls/RC12-layout.xls

# Special rule for getting report card layout 15.
RC15_layout.xlsx :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/2015%20School%20Report%20Card/RC15_layout_complete.xlsx

# Generate any CSV from its associated Excel file 
# using a dedicated Python script.
%.csv : %.xls
	python xls2csv.py $< > $@

# Special rules for generating CSVs from layouts that are .xlsx.
.INTERMEDIATE: RC13_layout.csv RC14_layout.csv RC15_layout.csv		\
               RC13_layout.xlsx RC14_layout.xlsx RC15_layout.xlsx
RC13_layout.csv RC14_layout.csv RC15_layout.csv : %.csv : %.xlsx
	xlsx2csv $< > $@

# Schema with the correct column names.
schema_19%.csv schema_20%.csv: RC%_layout.csv
	iconv -f WINDOWS-1252 -t UTF8 $< | python schema.py $($*_col) | python normalize_schema.py > $@

.INTERMEDIATE : rc1998u.txt rc98u.zip rc2000u.txt Rc00u.zip		\
                rc2002u.txt rc2004u.txt rc04u_updated092005.zip		\
                rc2006u.txt rc06.zip rc2007u.txt rc07.zip rc2009u.txt	\
                rc09.zip rc2015u.txt rc2010u.txt rc2011u.txt rc2012u.txt \
                rc2013u.txt rc2014u.txt

# General rule for unzipping report cards.
rc19%u.txt rc20%u.txt : rc%u.zip
	$(unzip-rename)

# Special rule for unzipping report cards 06, 07, and 09.
rc2006u.txt rc2007u.txt rc2009u.txt : rc20%u.txt : rc%.zip
	$(unzip-rename)

# Special rule for unzipping report cards 10-14.
rc2010u.txt rc2011u.txt rc2012u.txt rc2013u.txt rc2014u.txt : rc201%u.txt : rc1%.zip
	$(unzip-rename)

# Unzip report cards 98, 00, 02, 04.
rc1998u.txt : rc98bu.zip
rc2000u.txt : Rc00u.zip
rc2002u.txt : rc02All.zip
rc2004u.txt : rc04u_updated092005.zip

rc1998u.txt rc2000u.txt rc2002u.txt rc2004u.txt :
	$(unzip-rename)

# Get report card 15, which is already a plaintext file.
rc2015u.txt :
	wget -O $@ ftp://ftp.isbe.net/SchoolReportCard/2015%20School%20Report%20Card/rc15.txt

# Convert all report cards to CSV.
rc_%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@
