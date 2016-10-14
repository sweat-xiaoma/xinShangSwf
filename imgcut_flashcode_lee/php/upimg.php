<?php

define('MY_ROOT', substr(dirname(__FILE__), 0, -8));

$do=isset($_GET['do'])?$_GET['do']:0;
$savePicName = time();  //Í¼Æ¬´æ´¢Ãû³Æ
if($do=='upload') echo avatarUpload($savePicName);

function avatarUpload($uid){
		@header("Expires: 0");
		@header("Cache-Control: private, post-check=0, pre-check=0, max-age=0", FALSE);
		@header("Pragma: no-cache");
		$filepath='upfile/'.$uid.'.jpg';
		$len = file_put_contents($filepath,file_get_contents("php://input"));
		if($len>0){
			return 'php/'.$filepath.'上传成功！';		//保存成功了
		}

}


?>
