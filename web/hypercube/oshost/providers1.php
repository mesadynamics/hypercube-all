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
echo "<li id='current'><a href='#'><span>Provider Gallery</span></a></li>";
echo sprintf("<li><a href='featured.php?%s'><span>Featured Widget</span></a></li>", $template);

echo "</ul></div>";
echo "<div id='widget'><ul>";

echo sprintf("<a href='providers.php?%s'>Widget Directories</a> | ", $template);
echo "Fun &amp; Games | ";
echo sprintf("<a href='providers2.php?%s'>Embeddable Video</a> | ", $template);
echo sprintf("<a href='providers3.php?%s'>Photo Slideshows</a> | ", $template);
echo sprintf("<a href='providers4.php?%s'>Music Players</a> | ", $template);
echo sprintf("<a href='providers5.php?%s'>Other Widgets</a>", $template);

$html2 = <<<EndHereDoc2
</ul>

<table border='0' align='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/AlbinoBlacksheep.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/AlbinoBlacksheep.png' /><p>Albino Blacksheep</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ArcadeCabin.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ArcadeCabin.png' /><p>ArcadeCabin</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/bLaugh.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/bLaugh.png' /><p>bLaugh</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Blufr.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Blufr.png' /><p>Blufr</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/BunnyheroLabs.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/BunnyheroLabs.png' /><p>Bunnyhero Labs</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Funny4MySpace.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Funny4MySpace.png' /><p>Funny4MySpace</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/LargeAnimalGames.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/LargeAnimalGames.png' /><p>Large Animal Games</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Mashcodes.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Mashcodes.png' /><p>Mashcodes</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Mashface.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Mashface.png' /><p>Mashface</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Miniclip.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Miniclip.png' /><p>Miniclip</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/PicGames.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/PicGames.png' /><p>PicGames</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/POQbum.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/POQbum.png' /><p>POQbum</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Pyzam.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Pyzam.png' /><p>Pyzam</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/SmackArcade.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/SmackArcade.png' /><p>SmackArcade</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Webfetti.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Webfetti.png' /><p>Webfetti</p></a>
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
