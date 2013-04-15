<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

if (isset($user)) {
	$url =  sprintf("preview.php?widget_id=%s&hash=%s", $_REQUEST['widget_id'], $_REQUEST['hash']);
	redirect($url);
	exit;
} 

$fbml = <<<EndHereDoc
<sn:dashboard>
	<sn:create-button href='http://www.bebo.com/addhypercube'>Install Hypercube</sn:create-button>
</sn:dashboard>
<sn:explanation>
     <sn:message>Web widgets on Bebo!</sn:message>
     If you install Hypercube you can access this and other web widgets with one click from your profile.
</sn:explanation>
EndHereDoc;

echo $fbml;


$result = query("select title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$title = $row['title'];
	
	echo sprintf("<sn:tabs><sn:tab-item href='peek.php?widget_id=%s&hash=%s' title='%s' selected='true' /></sn:tabs>", $_REQUEST['widget_id'], $_REQUEST['hash'], $title);
   
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
