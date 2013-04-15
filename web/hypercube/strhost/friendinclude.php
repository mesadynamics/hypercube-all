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
		$user = $_REQUEST['friend'];
	}	
}

if (!isset($user)) {
	exit;
} 

$currentcube = NULL;

$conn = mysql_connect('mysql50-12.wc1.dfw1.stabletransit.com', '386731_root', 'boinkboink');
mysql_select_db('386731_hypercube', $conn);

function query($q) {
	global $conn;
	$result = mysql_query($q, $conn);
	if (!$result) {
		die("Invalid query -- $q -- " . mysql_error());
	}
	return $result;
}

function redirect($url)
{
	$location = sprintf("Location: %s", $url); 
	header($location);
}

$query = sprintf("select cube_id from friendster where id = '%s' and host = '%s'", $user, $host); 
$result = query($query);
if ($row = mysql_fetch_assoc($result)) {
	$currentcube = $row['cube_id'];
}
else {
	$user = null;
}

?>
