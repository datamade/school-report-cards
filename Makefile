rc%u.zip :
	wget http://www.isbe.net/research/zip/rc$*u.zip

rc%u.txt : rc%u.zip
	unzip $<
	touch $@

rc%.csv : rc%u.txt schemas/reportcard20%.csv
	in2csv -s $(word 2, $^) $< > $@


