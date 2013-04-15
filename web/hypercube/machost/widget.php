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
	-khtml-user-select: none;
}
#widget {
	background-color: none;
}
-->
	</style>
</head>
<body>
	<div id="widget">
<?php
	system(sprintf('./verifyWidget %s %s',
		escapeshellarg($_POST['id']),
		escapeshellarg($_POST['version'])), $verify);
	if($verify==0)
		echo $_POST['code'];
?>
	</div>
</body>
</html>
