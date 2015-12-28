rc%.zip :
	wget http://www.isbe.net/research/zip/rc$*.zip

RC%_layout.xls :
	wget ftp://ftp.isbe.net/SchoolReportCard/20$*%20School%20Report%20Card/RC$*_layout.xls

RC02_layout.xls :
	wget -O $@ http://www.isbe.net/research/Report_Card_02/ReportCard02_layout.xls

RC03_layout.xls :
	wget http://www.isbe.net/research/xls/RC03_layout.xls

rc%.txt : rc%.zip
	unzip $<
	touch $@

schema_%.csv : RC%_layout.xls
	xls2csv $< | tr -d '\014' | python schema.py > $@

rc%.csv : rc%u.txt schema_%.csv
	in2csv -s $(word 2, $^) $< > $@

