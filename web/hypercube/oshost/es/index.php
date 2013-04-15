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
<div id='header'>
<a href='desktop.html'>widgets en su escritorio</a> |
<a href='eula.html'>licencia</a> |
<a href='help.html'>ayuda</a>
</div>
EndHereDoc;

echo $html;

echo "<div id='add'>";
echo sprintf("<a href='new.php?%s'><span>añadir widget</span></a>", $template);
echo "</div>";

$widgetcount = 0;

$ishidden = false;

$result = query("select title, widget_id, hidden from widgets where cube_id = " . $currentcube . " order by title");
while ($row = mysql_fetch_assoc($result)) {
	$widgetcount++;
	
	if ($widgetcount == 1) {
		echo "<div id='tabs1'><ul>";
	
		if (!isset($currentwidget))
			$currentwidget = $row['widget_id'];
	}
	else if(($widgetcount % 6) == 0) {
		//echo '</ul></div><div id='tabs1'><ul>';
	}
	
	$title = mysql_real_escape_string($row['title']);

	if ($currentwidget == $row['widget_id']) {
		echo sprintf("<li id='current'><a href='action_switch.php?widget_id=%s&%s'><span>%s</span></a></li>", $row['widget_id'], $template, $title);

		if ($row['hidden'] != 0)
			$ishidden = true;
	}
	else
		echo sprintf("<li><a href='action_switch.php?widget_id=%s&%s'><span>%s</span></a></li>", $row['widget_id'], $template, $title);		
}

if ($widgetcount > 0) {
	echo '</ul></div>';
}

if ($newuser == 'true') {
$html2 = <<<EndHereDoc2
<div id='message'>
	<h1>¡Bienvenido a Amnesty Hypercube!</h1>
	Nos hemos adelantado y hemos añadido un par de widgets de muestra para que pueda comenzar.&nbsp; Podrá encontrar más widgets visualizando los sitios en nuestra Galería de Proveedores o a partir de cualquier sitio que publique widgets, juegos flash o video que pueda ser incrustado en una página web.
</div>
EndHereDoc2;

echo $html2;
}

echo sprintf("<a href='http://www.amnestywidgets.com/hypercube/deskhost/link.php?destination=%s&user=%s&cube=%s&source=Hypercube'></a>", $host, $user, $currentcube);

if (isset($currentwidget)) {
	echo "<div id='widgetframe'>";

	query("update cubes set serve_count = serve_count + 1 where cube_id = " . $currentcube);

	if($ishidden)
		echo sprintf("<img id='lock' title='Este Widget no está listado en el perfil' src='images/lock_16.gif' />"); 

	echo sprintf("<div id='icons'>"); 
	//echo sprintf("<a title='Compartir widget' href='#'><img src='images/group_16.gif' /></a>");
	
	echo sprintf("<a title='Editar widget' href='edit.php?widget_id=%s&%s'>", $currentwidget, $template); 
	echo "<img src='images/edit_16.gif' /></a> ";

	echo sprintf("<a title='Eliminar widget' href='action.php?remove=%s&%s' ", $currentwidget, $template);
	
$html3 = <<<EndHereDoc3
		onclick="return confirm('Esta acción no puede deshacerse. ¿De veras desea eliminar este widget?')"><img src='images/trash_16.gif' /></a>
</div>
EndHereDoc3;

	echo $html3;
	
	echo sprintf("<iframe src='widget.php?widget_id=%s&cube_id=%s' frameborder='0' width='100%%' height='520' scrolling=no />",
		$currentwidget, $currentcube);

	echo "</div>";
}

echo "</body></html>";

?>

