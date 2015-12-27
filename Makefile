p1 = 173

rc05%.txt :
	wget ftp://ftp.isbe.net/SchoolReportCard/2005%20School%20Report%20Card/2005%20report%20card%20separated%20file/$@

RC05_layout.xls : 
	wget ftp://ftp.isbe.net/SchoolReportCard/2005%20School%20Report%20Card/RC05_layout.xls

%.csv : %.xls
	xls2csv $< > $@

p1_layout.csv : RC05_layout.csv
	head -173 $< | csvcut -H -c 6,8,5 | \
        sed -r '1{s/.*/column,start,length/g}' | \
        sed '/^,,$$/d'> $@

p1.csv : rc05p1.txt p1_layout.csv
	in2csv -s $(word 2, $^) $< | sed 's/ *;//g' > $@
