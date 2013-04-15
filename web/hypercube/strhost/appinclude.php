<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

$appapikey = '78de1b5e49857b8c72df58d514f4665d';
$appsecret = '1d69aa71655947c0a91eb93e036983d3';

$user = $_REQUEST['user_id'];
$session = $_REQUEST['session_key'];

function microtime_float()
{
	list($usec, $sec) = explode(" ", microtime());
	return ((float) $usec + (float) $sec);
}

function updateprofile($content)
{
	global $appapikey;
	global $appsecret;
	global $session;
		
	$url = '/v1/widget';
	$nonce = microtime_float();
	
	$sig = sprintf("%sapi_key=%scontent=%snonce=%ssession_key=%s%s",
		$url, $appapikey, $content, $nonce, $session, $appsecret);
						
	$remote_url = 'http://api.friendster.com' . $url;
	$remote_server = 'api.friendster.com';

	$header = "POST $url HTTP/1.0\r\n";
	$header .= "Host: $remote_server\r\n";
	$header .= "MIME-version: 1.0\r\n";
	$header .= "Content-Type: multipart/form-data; boundary=xxx\r\n";

	$data ="--xxx\r\n";
	$data .= "Content-Disposition: form-data; name=\"" . "api_key" . "\"\r\n";
	$data .= "\r\n" . $appapikey . "\r\n";

	$data .="--xxx\r\n";
	$data .= "Content-Disposition: form-data; name=\"" . "content" . "\"\r\n";
	$data .= "\r\n" . $content . "\r\n";

	$data .="--xxx\r\n";
	$data .= "Content-Disposition: form-data; name=\"" . "nonce" . "\"\r\n";
	$data .= "\r\n" . $nonce . "\r\n";

	$data .="--xxx\r\n";
	$data .= "Content-Disposition: form-data; name=\"" . "session_key" . "\"\r\n";
	$data .= "\r\n" . $session . "\r\n";

	$data .="--xxx\r\n";
	$data .= "Content-Disposition: form-data; name=\"" . "sig" . "\"\r\n";
	$data .= "\r\n" . md5($sig) . "\r\n";

	$data .="--xxx--\r\n\r\n";
	
	$length = strlen($data);
	$header .= "Content-Length: $length\r\n";
	$header .= "Connection: Close\r\n\r\n";

	$fp = fsockopen($remote_server, 80);
	fwrite($fp, $header.$data);
	
	$response = '';
	while (!feof($fp)) {
		$response .= fgets($fp, 100);
	}
	
	//echo $response;
									
	fclose($fp);
}

?>
