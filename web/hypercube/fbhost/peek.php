<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappincludenone.php';

if (isset($user)) {
	$url =  sprintf("preview.php?widget_id=%s&hash=%s", $_REQUEST['widget_id'], $_REQUEST['hash']);
	$facebook->redirect($url);
	exit;
} 

$fbml = <<<EndHereDoc
<fb:dashboard>
	<fb:create-button href='http://www.facebook.com/apps/application.php?id=6019942314'>Install Hypercube</fb:create-button>
</fb:dashboard>
<fb:explanation>
     <fb:message>Web widgets on Facebook!</fb:message>
     If you install Hypercube you can access this and other web widgets with one click from your profile.
</fb:explanation>
EndHereDoc;

echo $fbml;


$result = query("select title from widgets where widget_id = " . $_REQUEST['widget_id']);
if ($row = mysql_fetch_assoc($result)) {
	$title = $row['title'];
	
	echo sprintf("<fb:tabs><fb:tab-item href='peek.php?widget_id=%s&hash=%s' title='%s' selected='true' /></fb:tabs>", $_REQUEST['widget_id'], $_REQUEST['hash'], $title);
   
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
