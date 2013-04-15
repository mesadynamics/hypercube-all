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
	background: #FEFFFE;
}
#widget {
	background-color: none;
}
-->
	</style>
	<script type="text/javascript">
<!--
	var widgetString = "";

	function HCDisableSelection() {
		target = document.getElementById("widget");
		
		if(typeof target.onselectstart != "undefined")
			target.onselectstart = function() { return false };
		else if(typeof target.style.MozUserSelect != "undefined")
			target.style.MozUserSelect = "none";
		else
			target.onmousedown = function() { return false };
			
		target.style.cursor = "default";
	}
	function HCSetBackground(color) {
		document.body.style.background = color;
	}
	function HCPause() {
		target = document.getElementById("widget");
		widgetString = target.innerHTML;
		target.innerHTML = "";
	}
	function HCResume() {
		target = document.getElementById("widget");
		target.innerHTML = widgetString;
		widgetString = "";
	}
-->
	</script>
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
	<script type="text/javascript">
		HCDisableSelection();
	</script>
</body>
</html>
