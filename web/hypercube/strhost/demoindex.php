<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'demoinclude.php';

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
<a href='#'>Widgets on your desktop</a> |
<a href='#'>License</a> |
<a href='#'>Help</a>
</div>
EndHereDoc;

echo $html;

echo "<div id='add'>";
echo "<a href='#'><span>Add a Widget</span></a>";
echo "</div>";

$widgetcount = 0;

$ishidden = false;
$currenthash = 0;

$result = query("select title, widget_id, hash from widgets where cube_id is null order by title");
while ($row = mysql_fetch_assoc($result)) {
	$widgetcount++;
	
	if ($widgetcount == 1) {
		echo "<div id='tabs1'><ul>";
	}
	else if(($widgetcount % 6) == 0) {
		//echo '</ul></div><div id='tabs1'><ul>';
	}
	
	$title = mysql_real_escape_string($row['title']);

	if ($widgetcount == 1) {
		$currentwidget = $row['widget_id'];
		
		echo sprintf("<li id='current'><a href='#'><span>%s</span></a></li>", $title);
	}
	else
		echo sprintf("<li><a href='#'><span>%s</span></a></li>", $title);		
}

if ($widgetcount > 0) {
	echo '</ul></div>';
}

$html2 = <<<EndHereDoc2
<div id='message'>
<h1>Install Hypercube Today!</h1>
     Amnesty&trade; Hypercube is a Friendster application that allows you to collect and share <i>web widgets</i> with your friends.  What's a web widget?  A web
     widget is a mini-application that is supposed to be embedded inside a blog or home page.  Examples include photo slideshows, streaming audio players,
     flash games and embeddable video.
</div>
EndHereDoc2;

echo $html2;

if (isset($currentwidget)) {
	echo "<div id='widgetframe'>";

	echo sprintf("<iframe src='widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' width='100%%' height='800' scrolling=no />",
		$currentwidget, $currenthash);

	echo "</div>";
}

echo "</body></html>";

?>

