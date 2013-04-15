<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

$appapikey = '78de1b5e49857b8c72df58d514f4665d';
$appsecret = '1d69aa71655947c0a91eb93e036983d3';

$user = $_REQUEST['user_id'];

function microtime_float()
{
	list($usec, $sec) = explode(" ", microtime());
	return ((float) $usec + (float) $sec);
}

?>
