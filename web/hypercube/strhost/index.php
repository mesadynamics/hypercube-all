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
<a href='desktop.html'>Widgets on your desktop</a> |
<a href='eula.html'>License</a> |
<a href='help.html'>Help</a>
</div>
EndHereDoc;

echo $html;

echo "<div id='add'>";
echo sprintf("<a href='new.php?%s'><span>Add a Widget</span></a>", $template);
echo "</div>";

$widgetcount = 0;
$listcount = 0;
$list = '';

$ishidden = false;

$result = query("select title, widget_id, hash, hidden from widgets where cube_id = " . $currentcube . " order by title");
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

	if ($row['hidden'] == 0) {
		$listcount++;
		
		$hash = $row['hash'];
		if(!isset($hash))
			$hash = '0';

		if ($currentwidget == $row['widget_id'])	
			$currenthash = $hash;
		
		if ($listcount == 1)	
			$list .= sprintf("<a href='http://widgets.friendster.com/hypercube/preview.php?widget_id=%s&hash=%s'>%s</a>", $row['widget_id'], $hash, $title);
		else
			$list .= sprintf(", <a href='http://widgets.friendster.com/hypercube/preview.php?widget_id=%s&hash=%s'>%s</a>", $row['widget_id'], $hash, $title);
	}
	else if ($currentwidget == $row['widget_id'])
		$ishidden = true;
}

if ($widgetcount > 0) {
	echo '</ul></div>';
}

if (isset($_REQUEST['update'])) {
	if ($listcount == 0)
		$profile = '0 widgets added. :-(';
	else if ($listcount == 1) {
		$profile = sprintf("1 widget added: %s.", $list);
	}
	else {
		$profile = sprintf("%s widgets added: %s.", $listcount, $list);
	}
	
	updateprofile($profile);

	query("update friendster set time = null where id = " . $user);
}

if ($newuser == 'true') {
$html2 = <<<EndHereDoc2
<div id='message'>
	<h1>Welcome to Amnesty&trade; Hypercube!</h1>
	We've gone ahead and added a couple of sample widgets for you to get started.&nbsp; 
	You can find more widgets browsing the sites in our Provider Gallery or from any site that publishes widgets, flash games or video
	that can be embedded in a web page.
</div>
EndHereDoc2;

echo $html2;
}

echo sprintf("<a href='http://www.amnestywidgets.com/hypercube/deskhost/link.php?destination=friendster.com&user=%s&cube=%s&source=Hypercube'></a>", $user, $currentcube);


if (isset($currentwidget)) {
	echo "<div id='widgetframe'>";

	query("update cubes set serve_count = serve_count + 1 where cube_id = " . $currentcube);

	if($ishidden)
		echo sprintf("<img id='lock' title='Widget not listed in profile' src='images/lock_16.gif' />"); 

	echo sprintf("<div id='icons'>"); 
	//echo sprintf("<a title='Share widget' href='#'><img src='images/group_16.gif' /></a>");
	
	echo sprintf("<a title='Edit widget' href='edit.php?widget_id=%s&%s'>", $currentwidget, $template); 
	echo "<img src='images/edit_16.gif' /></a> ";

	echo sprintf("<a title='Remove widget' href='action.php?remove=%s&%s' ", $currentwidget, $template);
	
$html3 = <<<EndHereDoc3
		onclick="return confirm('This action cannot be undone.  Do you really want to remove this widget?')"><img src='images/trash_16.gif' /></a>
</div>
EndHereDoc3;

	echo $html3;
	

	echo sprintf("<iframe src='widget.php?widget_id=%s&cube_id=%s' frameborder='0' width='100%%' height='800' scrolling='no' />",
		$currentwidget, $currentcube);

	echo "</div>";
}

echo "</body></html>";

?>

