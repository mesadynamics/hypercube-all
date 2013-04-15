<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludelog.php';

$fbml = <<<EndHereDoc
<sn:header>Add Widget</sn:header>
 
<sn:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<sn:tab-item href='preview.php?widget_id=%s&hash=%s' title='From your Friend or Network' selected='true' />", $_REQUEST['widget_id'], $_REQUEST['hash']);
   
$fbml3 = <<<EndHereDoc3
</sn:tabs>
EndHereDoc3;

echo $fbml3;

$result = query("select cube_id, title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id == $currentcube) {
		$currentwidget = $_REQUEST['widget_id'];
		query("update bebo set widget_id = " . $currentwidget . " where fb_sig_user = " . $user);
		redirect('index.php');
		exit;
	}
	
	$title = $row['title'];
	
	echo sprintf("<sn:editor action='action.php?copy=%s'>", $_REQUEST['widget_id']);
	echo sprintf("<sn:editor-text label='Name' name='title' value='%s' maxlength='64' />", $title);
	
$fbml2 = <<<EndHereDoc2
<sn:editor-buttonset>
	<sn:editor-button value='Copy Widget' />
	<sn:editor-cancel href='index.php' />
</sn:editor-buttonset>
</sn:editor>
EndHereDoc2;

	echo $fbml2;

	if (isset($_REQUEST['hash']))
		$hash = $_REQUEST['hash'];
	else
		$hash = '0';

	echo sprintf("<sn:iframe style='width:780px;height:585px;' src='http://www.amnestywidgets.com/hypercube/bebohost/widgetpeek.php?widget_id=%s&hash=%s' frameborder='0' scrolling='no' smartsize='yes' />",
		$_REQUEST['widget_id'], $hash);
}
else {
$fbml2 = <<<EndHereDoc2
<sn:error>
     <sn:message>Widget not available</sn:message>
     Sorry, this widget is no longer available.  The user who originally posted this link removed this widget over 30 days ago.
</sn:error>
EndHereDoc2;

	echo $fbml2;
}

?>
