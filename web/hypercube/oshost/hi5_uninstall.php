<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

$user = $_REQUEST['uid'];

if (!isset($user)) {
	exit;
}

$query = sprintf("update opensocial set time = '%s' where id = '%s' and host = 'hi5.com'",
	microtime_float(), $user);
	
query($query);

?>

