#!/bin/bash
#jq

if [ $# -ne 1 ]; then
        echo -e "Usage: $0 LKP_RESULT_DIR"
        exit
fi

lkp_result="$1"
dir_html="out_html"

cd $lkp_result
file_list=$(ls)

mkdir $dir_html
if [ $? -ne 0 ]; then
echo 'mkdir ERROR!'
exit
fi

gzip -dk *.gz

for fileOrg in $file_list
do

if [ "${fileOrg##*.}"x = "gz"x ]; then
file_=$(echo $fileOrg | sed "s/\.gz//g")

else
file_=$fileOrg
fi

echo -e "
<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
<title>$fileOrg</title>
</head><body>
<h3>$fileOrg</h3>" > $dir_html/${fileOrg}.html

if [ "${file_##*.}"x = "json"x ]; then
jq '@html' $file_ | sed -e 's/"{&quot;/<table><tbody><tr><td>/g; s/}"/<\/td><\/tr><\/tbody><\/table>/g; s/,&quot;/<\/td><\/tr><tr><td>/g; s/&quot;:/<\/td><td>/g' >> $dir_html/${fileOrg}.html

else
echo '<pre><code>' >> $dir_html/${fileOrg}.html
cat $file_ >> $dir_html/${fileOrg}.html
echo '</code></pre>' >> $dir_html/${fileOrg}.html
fi

echo '</body></html>' >> $dir_html/${fileOrg}.html
done

###
echo -e "
<html><head>
<meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>
<title>$lkp_result</title>
</head><body>
<h3>$lkp_result</h3>" > $dir_html/Index.html

echo '<table><tbody>' >> $dir_html/Index.html

for list_ in $file_list
do
echo -e "<tr><td><a href=\"${list_}.html\">$list_</a></td></tr>" >> $dir_html/Index.html
done

echo '
</tbody></table>
</body></html>' >> $dir_html/Index.html


