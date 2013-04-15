<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

if (!isset($user) || !isset($host)) {
	exit;
}

$query = sprintf("update opensocial set time = '%s' where id = '%s' and host = '%s'",
	microtime_float(), $user, $host);
	
query($query);

?>

