<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'appinclude.php';

if (!isset($dest) || !isset($user) || !isset($cube) || !isset($key)) {
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

$user_id = 'id';
if ($dest == 'facebook' || $dest == 'bebo')
	$user_id = 'fb_sig_user';
	
if ($dest == 'opensocial')
	$query = sprintf("select cube_id from %s where %s = '%s' and cube_id = %s and host = '%s'", $dest, $user_id, $user, $cube, $_REQUEST['host']);
else
	$query = sprintf("select cube_id from %s where %s = '%s' and cube_id = %s", $dest, $user_id, $user, $cube);

$result = query($query);
if ($row = mysql_fetch_assoc($result)) {
	$currentcube = $row['cube_id'];
}

?>
