<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:header>Add Widget</sn:header>
EndHereDoc;

echo $fbml;

echo sprintf("<sn:error><sn:message>%s</sn:message>%s</sn:error>",
	$_REQUEST['errtitle'], $_REQUEST['errmsg']);

?>
