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
EndHereDoc;

echo $html;

$result = query("select cube_id, title, hidden from widgets where widget_id = " . $_REQUEST['widget_id'] . " and cube_id = " . $currentcube);
if ($row = mysql_fetch_assoc($result)) {
$html2 = <<<EndHereDoc2
<h2>Editar widget</h2>

<div id='tabs1'><ul>
   <li id='current'><a href='#'><span>Propiedades del Widget</span></a></li>
</ul></div>

<form name='form1' action='action.php?' method='post'>
<script language="JavaScript">
function submitform()
{
	document.form1.submit();
}
</script>
EndHereDoc2;

	echo $html2;

	echo sprintf("<input type='hidden' name='edit' value='%s' />", $_REQUEST['widget_id']);
	echo sprintf("<input type='hidden' name='host' value='%s' />", $host);
	echo sprintf("<input type='hidden' name='userid' value='%s' />", $user);
	echo sprintf("<input type='hidden' name='userkey' value='%s' />", $userkey);

	$cube_id = $row['cube_id'];
	if($cube_id != $currentcube) {
		$url = sprintf("index.php?%s", $template);
		redirect($url);
		exit;
	}
	
	$title = $row['title'];
	
	echo "<div id='inputform'><table><tr><td id='tabler'>Nombre:</td><td>";
	echo sprintf("<input type='text' maxlength='64' size='45' name='title' value='%s' />", $title);
	echo "</td></tr><tr><td id='tabler'>No listar en el perfil:</td><td>";

	if($row['hidden']) {
		echo sprintf("<input type='checkbox' name='hidden' value='swap' style='width:auto' checked='1'/>");
	}
	else {
		echo sprintf("<input type='checkbox' name='hidden' value='swap' style='width:auto' />");
	}
	
	echo "</td></tr></table></div>";
	
$html3 = <<<EndHereDoc3
<div id='save2'><a href='javascript: submitform()'>grabar cambios</a>
</div>
EndHereDoc3;

	echo $html3;

	echo sprintf("<div id='cancel3'>o <a href='index.php?%s'><span>cancelar</span></a></div>", $template);
}
else {
$html2 = <<<EndHereDoc2
<div id='error'>
     <h1>Error</h1>
     Lo sentimos. Este Widget ya no está disponible.
</div>
EndHereDoc2;

	echo $html2;
}

echo "</body></html>";

?>
