<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

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

?>
