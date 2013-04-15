<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (isset($_REQUEST['widget_id'])) {
	$currentwidget = $_REQUEST['widget_id'];
	$query = sprintf("update friendster set widget_id = %s where id = '%s'", $currentwidget, $user);
	query($query);
}

$url = sprintf("index.php?%s", $template);
redirect($url);

?>
