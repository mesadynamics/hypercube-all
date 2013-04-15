<html>
<!--
  Amnesty(TM) Hypercube
  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
-->

<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<style type="text/css">
<!--
body {
	margin: 0px;
	width: 646px;
}
#widget {
	margin: 10px;
}
-->
	</style>
</head>
<body>
	<div id="widget">
<?php
require_once 'widgetinclude.php';

if (isset($_REQUEST['widget_id'])) {
	if (!isset($_REQUEST['hash']) || strcmp($_REQUEST['hash'], '0') == 0)
		$query = sprintf("select code from widgets where widget_id = %s and hash is null", $_REQUEST['widget_id']);
	else
		$query = sprintf("select code from widgets where widget_id = %s and hash = '%s'", $_REQUEST['widget_id'], $_REQUEST['hash']);
	
	$result = query($query);
	
	if ($row = mysql_fetch_assoc($result)) {
		echo stripslashes($row['code']);
	}
	else {
		echo 'Sorry, this widget is no longer available.';
	}
}

?>		
	</div>
</body>
</html>
