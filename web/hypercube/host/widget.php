<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8">
	<style type="text/css">
<!--
body {
	margin: 0px;
	background-color: #FEFFFE;
}
#widget {
	background-color: none;
}
-->
	</style>
	<script type="text/javascript">
<!--
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
-->
	</script>
</head>
<body>
	<div id="widget">
<?php
	system(sprintf('./verifyWidget %s %s',
		escapeshellarg($_GET['id']),
		escapeshellarg($_GET['version'])), $verify);
	if($verify==0)
		echo $_GET['code'];
?>
	</div>
	<script type="text/javascript">
		HCDisableSelection();
	</script>
</body>
</html>
