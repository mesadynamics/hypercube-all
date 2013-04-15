<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (isset($_REQUEST['widget_id'])) {
	$currentwidget = $_REQUEST['widget_id'];
	query("update bebo set widget_id = " . $currentwidget . " where fb_sig_user = " . $user);
}

redirect('index.php');

?>
