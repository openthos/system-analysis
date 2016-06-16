#!/bin/bash

if [ $# -ne 1 ]; then
        echo -e "Usage: $0 CSV_file"
        exit
fi

csv_file="$1"
out_file="${csv_file}.html"
count=0
IFS=","

echo -e "<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
<title>$csv_file</title>
<style type='text/css'>
#left {
float:left;
width: 180px;
}

#head {
float:left;
}

#nav li {
list-style-type:none;
background-color:#eee;
border: solid #888;
/*
border-width:0px 1px 1px 0px; */
border-width:1px 1px 1px 1px;
}
</style>
</head><body>
<h1>$csv_file</h1>" > $out_file

echo '<ul id="nav">' >> $out_file

while read LINE
do
	if [ "$count" -eq 0 ]
	then
	tabhead='<div id="head">'
	for name_ in $LINE
	do
	tabhead+="<li><b>$(echo $name_ |sed "s/>/\&gt\;/g"|cut -b -80 )</b></li>"
	done
	tabhead+='</div>'

	let "count+=1"
	continue
	fi
#####
	echo '<div id="left">' >> $out_file
	for single_ in $LINE
	do
	#echo "${single_}->"
	echo -e "<li>${single_}</li>" >> $out_file
	done

	echo '</div>' >> $out_file
	let "count+=1"

done < $csv_file

echo $tabhead >> $out_file
echo '</ul>' >> $out_file
echo '</body></html>' >> $out_file

