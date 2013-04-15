<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

$host = $_REQUEST['host'];
$userid = $_REQUEST['userid'];
$userkey = $_REQUEST['userkey'];
$user = null;

if (isset($host) && isset($userid) && isset($userkey)) {
	$key = sprintf("hypercube%s%s", $userid, $host);

	if (strcmp(md5($key), $userkey) == 0) {
		$user = $userid;
	}	
}

function microtime_float()
{
	list($usec, $sec) = explode(" ", microtime());
	return ((float) $usec + (float) $sec);
}

?>
