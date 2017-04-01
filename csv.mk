97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

define unzip-rename
unzip -p $< > $@
endef

%.zip :
	wget https://www.isbe.net/_layouts/Download.aspx?SourceUrl=/Documents/$@ -O $@

.INTERMEDIATE: RC06_layout.xls RC98_layout.xls rc98bu.zip	\
               RC99_layout.xls rc99lay.zip RC00_layout.xls	\
               Rc00lay.zip RC01_layout.xls RC01_layout.zip	\
               RC02_layout.xls RC03_layout.zip RC03_layout.xls	\
               RC06_layout.xls RC10_layout.xls RC11_layout.xls	\
               RC12_layout.xls RC97_layout.xls rc97.zip

RC97_layout.xls : rc97.zip
RC98_layout.xls : rc98u.zip
RC99_layout.xls : rc99lay.zip
RC00_layout.xls : Rc00lay.zip
RC01_layout.xls : RC01_layout.zip

RC97_layout.xls RC98_layout.xls RC99_layout.xls RC00_layout.xls RC01_layout.xls:
	$(unzip-rename)	

RC02_layout.xls :
	wget https://www.isbe.net/_layouts/Download.aspx?SourceUrl=/Documents/ReportCard02_layout.xls -O $@

RC%_layout.xls RC%_layout.xlsx :
	wget https://www.isbe.net/_layouts/Download.aspx?SourceUrl=/Documents/$@ -O $@

RC12_layout.xls:
	wget https://www.isbe.net/_layouts/Download.aspx?SourceUrl=/Documents/RC12-Layout.xls -O $@

RC15_layout.xlsx:
	wget https://www.isbe.net/_layouts/Download.aspx?SourceUrl=/Documents/RC15-layout.xlsx -O $@


%.csv : %.xls
	python xls2csv.py $< > $@

.INTERMEDIATE: RC13_layout.csv RC14_layout.csv RC15_layout.csv		\
               RC13_layout.xlsx RC14_layout.xlsx RC15_layout.xlsx
RC13_layout.csv RC14_layout.csv RC15_layout.csv : %.csv : %.xlsx
	xlsx2csv $< > $@

schema_19%.csv schema_20%.csv: RC%_layout.csv
	iconv -f WINDOWS-1252 -t UTF8 $< | python schema.py $($*_col) | python normalize_schema.py > $@

.INTERMEDIATE : rc1998u.txt rc98u.zip rc2000u.txt Rc00u.zip		\
                rc2002u.txt rc2004u.txt rc04u_updated092005.zip		\
                rc2006u.txt rc06.zip rc2007u.txt rc07.zip rc2009u.txt	\
                rc09.zip rc2015u.txt rc2010u.txt rc2011u.txt rc2012u.txt \
                rc2013u.txt rc2014u.txt

rc19%u.txt rc20%u.txt : rc%u.zip
	$(unzip-rename)

rc2006u.txt rc2007u.txt rc2009u.txt : rc20%u.txt : rc%.zip
	$(unzip-rename)

rc2010u.txt rc2011u.txt rc2012u.txt rc2013u.txt rc2014u.txt rc2015u.txt: rc201%u.txt : rc1%.zip
	$(unzip-rename)

rc1998u.txt : rc98bu.zip
rc2000u.txt : Rc00u.zip
rc2002u.txt : rc02All.zip
rc2004u.txt : rc04u_updated092005.zip

rc1998u.txt rc2000u.txt rc2002u.txt rc2004u.txt :
	$(unzip-rename)

rc_%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@
