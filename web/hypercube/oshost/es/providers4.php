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

echo sprintf("<a href='providers.php?%s'>Diretórios de Widgets</a> | ", $template);
echo sprintf("<a href='providers1.php?%s'>Juegos y Diversión</a> | ", $template);
echo sprintf("<a href='providers2.php?%s'>Video incrustable</a> | ", $template);
echo sprintf("<a href='providers3.php?%s'>Pase de diapositivas de fotos</a> | ", $template);
echo "Reproductores de Música | ";
echo sprintf("<a href='providers5.php?%s'>Otros Widgets</a>", $template);

$html2 = <<<EndHereDoc2
</ul>

<table border='0' align='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/blogmusik.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/blogmusik.png' /><p>blogmusik</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Fairtilizer.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Fairtilizer.png' /><p>Fairtilizer</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FineTune.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FineTune.png' /><p>FineTune</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoodStorm.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoodStorm.png' /><p>GoodStorm</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Goombah.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Goombah.png' /><p>Goombah</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/iSOUND.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/iSOUND.png' /><p>iSOUND</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Lastfm.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Lastfm.png' /><p>Last.fm</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/MOG.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/MOG.png' /><p>MOG</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Odeo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Odeo.png' /><p>Odeo</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/payplay.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/payplay.png' /><p>payplay.fm</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/PodShow.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/PodShow.png' /><p>PodShow</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ProjectOpus.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ProjectOpus.png' /><p>Project Opus</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ProjectPlaylist.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ProjectPlaylist.png' /><p>Project Playlist</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/SeeqPod.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/SeeqPod.png' /><p>SeeqPod</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/stage.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/stage.png' /><p>stage.fm</p></a>
	</td>
</tr>
<tr>
</tr>
</table>

</div>
</body>
</html>
EndHereDoc2;

echo $html2;

?>
