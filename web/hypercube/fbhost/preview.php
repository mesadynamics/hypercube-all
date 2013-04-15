<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludelog.php';

$fbml = <<<EndHereDoc
<fb:header>Add Widget</fb:header>
 
<fb:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<fb:tab-item href='preview.php?widget_id=%s&hash=%s' title='From your Friend' selected='true' />", $_REQUEST['widget_id'], $_REQUEST['hash']);
   
$fbml3 = <<<EndHereDoc3
</fb:tabs>
EndHereDoc3;

echo $fbml3;

$result = query("select cube_id, title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id == $currentcube) {
		$currentwidget = $_REQUEST['widget_id'];
		query("update facebook set widget_id = " . $currentwidget . " where fb_sig_user = " . $user);
		$facebook->redirect('index.php');
		exit;
	}
	
	$title = $row['title'];
	
	echo sprintf("<fb:editor action='action.php?copy=%s'>", $_REQUEST['widget_id']);
	echo sprintf("<fb:editor-text label='Name' name='title' value='%s' maxlength='64' />", $title);
	
$fbml2 = <<<EndHereDoc2
<fb:editor-buttonset>
	<fb:editor-button value='Copy Widget' />
	<fb:editor-cancel href='index.php' />
</fb:editor-buttonset>
</fb:editor>
EndHereDoc2;

	echo $fbml2;

	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';

	echo sprintf("<fb:iframe src='http://www.amnestywidgets.com/hypercube/fbhost/widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' scrolling='no' smartsize='yes' />",
		$_REQUEST['widget_id'], $hash);
}
else {
$fbml2 = <<<EndHereDoc2
<fb:error>
     <fb:message>Widget not available</fb:message>
     Sorry, this widget is no longer available.  The user who originally posted this link removed this widget over 30 days ago.
</fb:error>
EndHereDoc2;

	echo $fbml2;
}

?>
