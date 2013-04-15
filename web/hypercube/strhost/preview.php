<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
	exit;
}

$result = query("select cube_id, title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id == $currentcube) {
		$currentwidget = $_REQUEST['widget_id'];
		query("update friendster set widget_id = " . $currentwidget . " where id = " . $user);

		$url = sprintf("index.php?%s", $template);
		redirect($url);
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
<li id='current'><a href='#'><span>From your Friend</span></a></li>
</ul></div>

<script language="JavaScript">
function submitform()
{
	document.form1.submit();
}
</script>
EndHereDoc;

	echo $html;
	
	$title = $row['title'];
	
	echo sprintf("<form name='form1' action='action.php?copy=%s' method='post'>", $_REQUEST['widget_id']);
	echo sprintf("<input type='hidden' name='user_id' value='%s' />", $user);
	echo sprintf("<input type='hidden' name='session_key' value='%s' />", $session);
	
$html2 = <<<EndHereDoc2
<div id='copyform'>
<table>
<tr>
<td id='tabler'>Name:</td>
<td>
<input type='text' maxlength='64' size='45' name='title' value='$title' /></form
</td>
</tr>
</table>
</div>
<div id='copy'><a href='javascript: submitform()'>Copy Widget</a>
</div>
EndHereDoc2;

	echo $html2;
	echo sprintf("<div id='cancel4'>or <a href='index.php?%s'><span>Cancel</span></a></div>", $template);

	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';
		
	echo "<div id='widgetpeek'>";
	echo sprintf("<iframe src='widgetpeek.php?widget_id=%s&hash=%s'  frameborder='0' width='100%%' height='800' scrolling='no' />",
		$_REQUEST['widget_id'], $hash);
	echo "</div>";
}
else {
$html3 = <<<EndHereDoc3
<div id='error'>
     <h1>Widget not available</h1>
     Sorry, this widget is no longer available.  The user who originally posted this link removed this widget over 30 days ago.
</div>
EndHereDoc3;

	echo $html3;
}

echo "</body></html>";

?>
