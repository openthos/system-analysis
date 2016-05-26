<!DOCTYPE html>

<html lang="en"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<meta charset="UTF-8">
	<title>Highcharts</title>
	<meta http-equiv="X-UA-Compatible" content="IE=edge">
	<link rel="stylesheet" type="text/css" href="./highcharts_files/bootstrap.min.css">
	<link rel="stylesheet" type="text/css" href="./highcharts_files/style.css">
<script src="./highcharts_files/hm.js"></script><script src="./highcharts_files/share.js"></script><link rel="stylesheet" href="./highcharts_files/share_style0_24.css"></head>

<body>

	<div id="demo" >
		<div id="demo_content">

			<div class="page-header">
				<h1>LKP result charts</h1>
				<div class="subtitle">
				<p class="single"><a href="https://01.org/zh/lkp" target="_blank">Linux Kernel Performance</a> test case result</p>
				</div>
				<div class="clear"></div>

				</div>

				<div align="left">

			<?php

			$xaxis=$_GET["xaxis"];
			$benchmarks=$_GET["benchmarks"];
			$head_count=$_GET["count"];

			$all_head_count=explode(",",$head_count);

			//echo var_dump($xaxis).'<br>';
			//echo var_dump($benchmarks).'<br>';
			echo '<h3>'.$benchmarks.'</h3>';

			$csv_path = "csv/".$benchmarks.".csv";
			$handle = fopen($csv_path, "r");
			$buffer = fgets($handle);
			fclose($handle);

			$head_data=explode(",",$buffer);
			foreach ($all_head_count as $k=>$v ){
				if($k == 0){
				$metric=$head_data[$v];
				}else{
				$metric .= ",".$head_data[$v];
				}
			}
			//$t_exec = 'python genhtml.py -i '.$csv_path.' -o cache/out.html -m '.$head_data[$head_count].' -b '.$benchmarks.' -c gcc-4.9 -x '.$xaxis ;
			$t_exec = 'python genhtml.py -i '.$csv_path.' -o cache/out.html -m '.$metric.' -b '.$benchmarks.' -c gcc-4.9 -x '.$xaxis ;
			echo $t_exec;
			$shell_result = shell_exec("$t_exec");
			echo $shell_result;

			//echo var_dump($head_data).'<br>';

			?>

				<iframe src="cache/out.html"
				width="100%" height="500"
				frameborder="no">
				<a href="cache/out.html">CHART</a>
				</iframe>
				<div class="clearfix"></div>

			</div>
			<div class="clear"></div>


			</div>
		<div class="clear"></div>


	</div>



<script type="text/javascript" src="./highcharts_files/jquery.min.js"></script>
<script type="text/javascript" src="./highcharts_files/bootstrap.min.js"></script>
<script type="text/javascript" src="./highcharts_files/jquery.scrollUp.min.js"></script>
<script type="text/javascript" src="./highcharts_files/common.js"></script>	<script type="text/javascript" src="./highcharts_files/highcharts.js"></script>
	<script type="text/javascript" src="./highcharts_files/exporting.js"></script>
				<script type="text/javascript" src="./highcharts_files/line-basic.js"></script>

</body></html>
