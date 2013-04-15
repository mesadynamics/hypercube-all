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
<h2>Añadir Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;

echo sprintf("<li><a href='new.php?%s'><span>Crear Widget a partir de Código</span></a></li>", $template);
echo "<li id='current'><a href='#'><span>Galería de Proveedores</span></a></li>";
echo sprintf("<li><a href='featured.php?%s'><span>Widget Principales</span></a></li>", $template);

echo "</ul></div>";
echo "<div id='widget'><ul>";

echo "Diretórios de Widgets | ";
echo sprintf("<a href='providers1.php?%s'>Juegos y Diversión</a> | ", $template);
echo sprintf("<a href='providers2.php?%s'>Video incrustable</a> | ", $template);
echo sprintf("<a href='providers3.php?%s'>Pase de diapositivas de fotos</a> | ", $template);
echo sprintf("<a href='providers4.php?%s'>Reproductores de Música</a> | ", $template);
echo sprintf("<a href='providers5.php?%s'>Otros Widgets</a>", $template);

$html2 = <<<EndHereDoc2
</ul>

<table border='0' align ='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FancyGens.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FancyGens.png' /><p>FancyGens</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoogleGadgets.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoogleGadgets.png' /><p>Google Gadgets</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/LabPixies.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/LabPixies.png' /><p>LabPixies</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Pageflakes.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Pageflakes.png' /><p>Pageflakes</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/RockYou.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/RockYou.png' /><p>RockYou!</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/SpringWidgets.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/SpringWidgets.png' /><p>SpringWidgets</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Widgetbox.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Widgetbox.png' /><p>Widgetbox</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/yourminis.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/yourminis.png' /><p>yourminis</p></a>
	</td>
</tr>
</table>

</div>
</body>
</html>
EndHereDoc2;

echo $html2;

?>
