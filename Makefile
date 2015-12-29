97_col = 5 3 4 2
98_col = 3 1 2 0
99_col = 4 2 3 1
00_col = 4 2 3 1

%.zip :
	wget http://www.isbe.net/research/zip/$@

RC%_layout.xls :
	wget ftp://ftp.isbe.net/SchoolReportCard/20$*%20School%20Report%20Card/$@

RC%_layout.xlsx :
	wget ftp://ftp.isbe.net/SchoolReportCard/20$*%20School%20Report%20Card/$@

RC06_layout.xls :
	wget "ftp://ftp.isbe.net/SchoolReportCard/2006%20School%20Report%20Card(updated%20033007)/RC06_layout.xls"

rc9%.xls : rc9%.zip
	unzip $< 

RC9%_layout.xls : rc9%.xls
	mv $< $@

RC98.xls : rc98.zip
	unzip $< 

RC98_layout.xls : RC98u.xls
	mv $< $@

RC99lay1.xls : rc99lay.zip
	unzip $<
	touch $@

RC99_layout.xls : RC99lay1.xls
	mv $< $@

RC00lay.xls : Rc00lay.zip
	unzip $<
	touch $@

RC00_layout.xls : RC00lay.xls
	mv $< $@
	touch $@

RC01_layout.xls : RC01_layout.zip
	unzip $<

RC03_layout.xls :
	wget http://www.isbe.net/research/xls/RC03_layout.xls

rc%.txt : rc%.zip
	unzip $<
	touch $@

%.csv : %.xls 
	unoconv --format csv $<

RC13_layout.csv : RC13_layout.xlsx 
	unoconv --format csv $<

RC14_layout.csv : RC14_layout.xlsx 
	unoconv --format csv $<

RC15_layout.csv : RC15_layout.xlsx 
	unoconv --format csv $<

schema_%.csv : RC%_layout.csv
	cat $< | python schema.py $($*_col) | python normalize_schema.py > $@

rc%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@

