<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

if (isset($user)) {
	$url =  sprintf("preview.php?widget_id=%s&hash=%s%s", $_REQUEST['widget_id'], $_REQUEST['hash'], $template);
	redirect($url);
	exit;
} 

$fbml = <<<EndHereDoc
<html>
<head>
	<meta http-equiv='content-type' content='text/html; charset=utf-8'>
	<style type='text/css'>
		@import 'main.css';
	</style>
</head>

<body>

<div id='message3'>
     <h1>Web widgets on OpenSocial!</h1>
     If you install Hypercube you can access this and other web widgets with one click from your profile.
</div>
<div id='widgetframe'>
EndHereDoc;

echo $fbml;


$result = query("select title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$title = $row['title'];
	  
	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';

	echo sprintf("<iframe src='widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' width='100%%' height='520' scrolling=no />",
		$_REQUEST['widget_id'], $hash);
}
else {
$fbml2 = <<<EndHereDoc2
<div id="error">
     <h1>Widget not available</h1>
     Sorry, this widget is no longer available.  The user who originally posted this link removed this widget over 30 days ago.
</div>
EndHereDoc2;

	echo $fbml2;
}

echo "</div></body></html>";

?>
