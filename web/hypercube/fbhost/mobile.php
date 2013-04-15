<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludelog.php';

echo "<fb:mobile>";

$result = query("select cube_id from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';

	echo "Sorry, Facebook doesn't allow embedded content in mobile canvas pages right now.";
	//echo sprintf("<fb:iframe src='http://www.amnestywidgets.com/hypercube/fbhost/widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' scrolling='no' smartsize='yes' />",
	//	$_REQUEST['widget_id'], $hash);
}

echo "</fb:mobile>";

?>
