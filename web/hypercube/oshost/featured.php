<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
	exit;
}

$html = <<<EndHereDoc
<html>
<head>
	<meta http-equiv='content-type' content='text/html; charset=utf-8'>
	<style type='text/css'>
		@import 'main.css';
	</style>
</head>

<body>
<h2>Add Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;

echo sprintf("<li><a href='new.php?%s'><span>Create Widget from Code</span></a></li>", $template);
echo sprintf("<li><a href='providers.php?%s'><span>Provider Gallery</span></a></li>", $template);
echo "<li id='current'><a href='#'><span>Featured Widget</span></a></li>";

echo "</ul></div>";

echo "<div id='widget'>";
echo "<iframe src='fidget.php' frameborder='0' width='100%%' height='100%%' scrolling=no />";
echo "</div></body></html>";
		
?>
