#!/bin/bash

xAxis="'NULL'"
all_commit="0"
commits="0"

out_file="cache/count.html"

cd path
for file_ in $(ls *.txt)
do

xAxis+=", '$(echo $file_ | sed "s/\.txt//g")'"

all_commit+=", $(cut -d '/' -f 8 $file_ | wc -l )"
commits+=", $(cut -d '/' -f 8 $file_ | awk '!a[$0]++' | wc -l )"

done

cd -

#echo "categories: [$xAxis]"
#echo "{name: 'all commits', data: [$all_commit]}"
#echo "{name: 'no-repeat commits', data: [$commits]}"

cat html/head.html > $out_file
echo "
{
        chart: {
            type: 'bar'
        },
        title: {
            text: 'The Commits of All Benchmarks'
        },
        xAxis: {
	    categories: [$xAxis],
            title: {
                text: null
            }
        },
        yAxis: {
            min: 0,
            title: {
                text: 'Population (millions)',
                align: 'high'
            },
            labels: {
                overflow: 'justify'
            }
        },
        tooltip: {
            valueSuffix: ' millions'
        },
        plotOptions: {
            bar: {
                dataLabels: {
                    enabled: true
                }
            }
        },
        legend: {
            layout: 'vertical',
            align: 'right',
            verticalAlign: 'top',
            x: -40,
            y: 80,
            floating: true,
            borderWidth: 1,
            backgroundColor: ((Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF'),
            shadow: true
        },
        credits: {
            enabled: false
        },

	series: [{name: 'all commits', data: [$all_commit]}, 
		{name: 'no-repeat commits', data: [$commits]}]   }" >> $out_file

cat html/tailer2.html >> $out_file

