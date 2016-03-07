<?php
/*
if ((($_FILES["file"]["type"] == "image/gif")
|| ($_FILES["file"]["type"] == "image/jpeg")
|| ($_FILES["file"]["type"] == "image/pjpeg"))
&& ($_FILES["file"]["size"] < 20000))
*/

#if (($_FILES["myfile"]["name"] != "")&&($_FILES["myfile"]["size"] < 50000000))
if ($_FILES["myfile"]["name"] != "")
{
	if ($_FILES["myfile"]["error"] > 0)
	{
		echo "Return Code: " . $_FILES["myfile"]["error"] . "<br />";
/*

		switch ($_FILES["myfile"]["error"])
		{
			case 1:
				echo "文件大小超过了PHP.ini中的文件限制！";
				break;
			case 2:
				echo "文件大小超过了浏览器限制！";
				break;
			case 3:
				echo "文件部分被上传！";
				break;
			case 4:
				echo "没有找到要上传的文件！";
				break;
			case 5:
				echo "服务器临时文件夹丢失，请重新上传！";
				break;
			case 6:
				echo "文件写入到临时文件夹出错！";
				break;
		}
*/
	}
	else
	{
		/*
		echo "Upload: " . $_FILES["myfile"]["name"] . "<br />";
		echo "Type: " . $_FILES["myfile"]["type"] . "<br />";
		echo "Size: " . ($_FILES["myfile"]["size"] / (1024*1024)) . " MB<br />";
		echo "Temp file: " . $_FILES["myfile"]["tmp_name"] . "<br />";
		*/

		if (file_exists("./upload/" . $_FILES["myfile"]["name"]))
		{

		echo "<script language='javascript'>";
		echo "alert('".$_FILES["myfile"]["name"]." already exists! ');";
		echo "window.location='upload.html';";
		echo "</script>";
		}
		else
		{

		echo "Upload: " . $_FILES["myfile"]["name"] . "<br />";
		echo "Type: " . $_FILES["myfile"]["type"] . "<br />";
		echo "Size: " . ($_FILES["myfile"]["size"] / (1024*1024)) . " MB<br />";

			move_uploaded_file($_FILES["myfile"]["tmp_name"],
					"./upload/" . $_FILES["myfile"]["name"]);
			echo "Stored in: " . "upload/" . $_FILES["myfile"]["name"];
		}
	}
}
else
{
		echo "<script language='javascript'>";
		echo "alert('Invalid file! ');";
		echo "window.location='upload.html';";
		echo "</script>";
}
?>
