<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<fb:header>Add Widget</fb:header>
EndHereDoc;

echo $fbml;

echo sprintf("<fb:error><fb:message>%s</fb:message>%s</fb:error>",
	$_REQUEST['errtitle'], $_REQUEST['errmsg']);

?>
