<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'appinclude.php';

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

$query = sprintf("select cube_id from opensocial where id = '%s' and host = '%s'", $_REQUEST['friend'], $host); 
$result = query($query);
if ($row = mysql_fetch_assoc($result)) {
	$currentcube = $row['cube_id'];
}
else {
	$user = null;
}

?>
