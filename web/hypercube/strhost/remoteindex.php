<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'remoteinclude.php';

if (!isset($user)) {
	exit;
}

if ($newuser == 'true') {
	redirect("teaser.html");
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
<a href='desktop.html'>Widgets on your desktop</a> |
<a href='eula.html'>License</a> |
<a href='help.html'>Help</a>
</div>
EndHereDoc;

echo $html;

$widgetcount = 0;

$ishidden = false;

$result = query("select title, widget_id, hidden from widgets where cube_id = " . $currentcube . " and hidden = 0 order by title");
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
		echo sprintf("<li id='current'><a href='action_remoteswitch.php?widget_id=%s&%s'><span>%s</span></a></li>", $row['widget_id'], $template, $title);

		if ($row['hidden'] != 0)
			$ishidden = true;
	}
	else
		echo sprintf("<li><a href='action_remoteswitch.php?widget_id=%s&%s'><span>%s</span></a></li>", $row['widget_id'], $template, $title);		
}

if ($widgetcount > 0) {
	echo '</ul></div>';
}

if (isset($currentwidget)) {
	echo "<div id='widgetframe'>";

	query("update cubes set serve_count = serve_count + 1 where cube_id = " . $currentcube);
	
	echo sprintf("<iframe src='widget.php?widget_id=%s&cube_id=%s' frameborder='0' width='100%%' height='800' scrolling=no />",
		$currentwidget, $currentcube);

	echo "</div>";
}

echo "</body></html>";

?>

