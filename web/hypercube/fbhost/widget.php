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
	$result = query("select code from widgets where widget_id = " . $_REQUEST['widget_id'] . " and cube_id = " . $_REQUEST['cube_id']);
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
