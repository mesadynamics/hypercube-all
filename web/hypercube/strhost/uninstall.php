<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

if (!isset($user)) {
	exit;
}

$query = sprintf("update friendster set time = '%s' where id = %s",
	microtime_float(), $user);
	
query($query);

?>
