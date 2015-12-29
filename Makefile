97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

define unzip-rename
unzip -p $< > $@
endef


all : rc_97.csv rc_98.csv rc_99.csv rc_00.csv rc_01.csv rc_03.csv	\
      rc_04.csv rc_05.csv rc_06.csv rc_07.csv rc_08.csv rc_09.csv	\
      rc_10.csv rc_11.csv rc_12.csv rc_13.csv rc_14.csv rc_15.csv

.INTERMEDIATE: rc11.zip rc12.zip rc13.zip

%.zip :
	wget http://www.isbe.net/research/zip/$@

rc11.zip :
	wget http://www.isbe.net/assessment/zip/rc11.zip

rc12.zip :
	wget http://www.isbe.net/assessment/zip/rc12.zip

rc13.zip :
	wget http://www.isbe.net/assessment/zip/rc13.zip

rc14.zip :
	wget http://www.isbe.net/assessment/zip/rc14.zip


.INTERMEDIATE: RC06_layout.xls RC98_layout.xls RC99_layout.xls	\
               RC00_layout.xls RC11_layout.xls RC12_layout.xls

RC9%_layout.xls : rc9%.zip
	$(unzip-rename)

RC98_layout.xls : rc98u.zip
	$(unzip-rename)

RC99_layout.xls : rc99lay.zip
	$(unzip-rename)

RC0%_layout.xls : rc0%.zip

RC00_layout.xls : Rc00lay.zip
	$(unzip-rename)

RC01_layout.xls : RC01_layout.zip
	$(unzip-rename)

RC06_layout.xls :
	wget "ftp://ftp.isbe.net/SchoolReportCard/2006%20School%20Report%20Card(updated%20033007)/RC06_layout.xls"

RC03_layout.xls :
	wget http://www.isbe.net/research/xls/RC03_layout.xls

RC10_layout.xls :
	wget http://www.isbe.net/research/xls/RC10_layout.xls

RC0%_layout.xls :
	wget ftp://ftp.isbe.net/SchoolReportCard/200$*%20School%20Report%20Card/$@

RC1%_layout.xlsx :
	wget ftp://ftp.isbe.net/SchoolReportCard/201$*%20School%20Report%20Card/$@

RC11_layout.xls :
	wget http://www.isbe.net/assessment/xls/RC11_layout.xls

RC12_layout.xls :
	wget -O $@ http://www.isbe.net/assessment/xls/RC12-layout.xls

.INTERMEDIATE: RC13_layout.csv RC14_layout.csv

%.csv : %.xls 
	unoconv --format csv $<

RC13_layout.csv : RC13_layout.xlsx 
	unoconv --format csv $<

RC14_layout.csv : RC14_layout.xlsx 
	unoconv --format csv $<

schema_%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

rc9%u.txt : rc9%u.zip
	$(unzip-rename)

.INTERMEDIATE : rc98u.txt rc98u.zip rc00.txt Rc00u.zip rc02all.zip	\
                rc02.txt rc04u.txt rc04u_updated092005.zip rc06u.txt	\
                rc06.zip rc07u.txt rc07.zip rc09u.txt rc09.zip		\
                rc10u.txt rc10.zip

rc98u.txt : rc98bu.zip
	$(unzip-rename)

rc0%u.txt : rc0%u.zip
	$(unzip-rename)

rc00u.txt : Rc00u.zip
	$(unzip-rename)

rc02all.zip :
	wget http://www.isbe.net/research/Report_Card_02/rc02All.zip
	touch $@

rc02u.txt : rc02all.zip
	$(unzip-rename)

rc04u.txt : rc04u_updated092005.zip
	$(unzip-rename)

rc06u.txt : rc06.zip
	$(unzip-rename)

rc07u.txt : rc07.zip
	$(unzip-rename)

rc09u.txt : rc09.zip
	$(unzip-rename)

rc10.zip : 
	wget http://www.isbe.net/research/zip/rc10.zip
	touch $@

rc10u.txt : rc10.zip
	$(unzip-rename)

rc1%u.txt : rc1%.zip
	$(unzip-rename)


rc_%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@

