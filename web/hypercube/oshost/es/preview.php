<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
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
<h2>Añadir Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $fbml;

echo sprintf("<li id='current'><a href='preview.php?widget_id=%s&hash=%s'><span>Desde tu Amigo</span></a></li>", $_REQUEST['widget_id'], $_REQUEST['hash']);
   
$fbml3 = <<<EndHereDoc3
</ul></div>

<form name='form1' action='action.php?' method='post'>
<script language="JavaScript">
function submitform()
{
	document.form1.submit();
}
</script>

EndHereDoc3;

echo $fbml3;

$result = query("select cube_id, title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id == $currentcube) {
		$currentwidget = $_REQUEST['widget_id'];
		$query = sprintf("update opensocial set widget_id = %s where id = '%s'", $currentwidget, $user);
		query($query);
		
		$url = sprintf("index.php?%s", $template);
		redirect($url);
		exit;
	}
	
	$title = $row['title'];

	echo sprintf("<input type='hidden' name='copy' value='%s' />", $_REQUEST['widget_id']);
	echo sprintf("<input type='hidden' name='host' value='%s' />", $host);
	echo sprintf("<input type='hidden' name='userid' value='%s' />", $user);
	echo sprintf("<input type='hidden' name='userkey' value='%s' />", $userkey);
		
$fbml2 = <<<EndHereDoc2
<div id='inputform'>
<table>
<tr>
<td id='tabler'>Nombre:</td>
<td>
<input type='text' maxlength='64' size='45' name='title' value='$title' />
</td>
</tr>
</table>
</div>

<div id='copy'><a href='javascript: submitform()'>copiar widget</a>
</div>
EndHereDoc2;

	echo $fbml2;

	echo sprintf("<div id='copycancel'>o <a href='index.php?%s'><span>cancelar</span></a></div>", $template);

	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';
		
	echo "<div id='previewframe'>";

	echo sprintf("<iframe src='widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' width='100%%' height='420' scrolling=no />",
		$_REQUEST['widget_id'], $hash);
		
	echo "</div>";
}
else {
$fbml2 = <<<EndHereDoc2
<div id='widgetframe'>
<div id="error">
     <h1>Widget ya no está disponible</h1>
     El usuario que publicó originalmente este enlace eliminó este Widget hace 30 días.
</div>
</div>
EndHereDoc2;

	echo $fbml2;
}

echo "</body></html>";

?>
