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
     <h1>¡Web Widgets en OpenSocial!</h1>
    Si instala Hypercube, desde su perfil podrá acceder a este y a otros widgets de web con un solo click.
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
     <h1>Widget ya no está disponible</h1>
     El usuario que publicó originalmente este enlace eliminó este Widget hace 30 días.
</div>
EndHereDoc2;

	echo $fbml2;
}

echo "</div></body></html>";

?>
