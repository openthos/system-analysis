<?php

	$benchmarks=$_GET["benchmarks"];
	$xaxis=$_GET["xaxis"];
	$shell_result = shell_exec(" grep $xaxis path/$benchmarks.txt ");
	echo $shell_result;

?>

