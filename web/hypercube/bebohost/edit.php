<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:header>Edit Widget</sn:header>
 
<sn:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<sn:tab-item href='edit.php?widget_id=%s' title='Widget Properties' selected='true' />", $_REQUEST['widget_id']);
   
$fbml4 = <<<EndHereDoc4
</sn:tabs>

<style>
	.label { position:relative; display:block; left:16px; top:-16px; }
</style>
EndHereDoc4;

echo $fbml4;

$result = query("select cube_id, title, hidden from widgets where widget_id = " . $_REQUEST['widget_id'] . " and cube_id = " . $currentcube);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id != $currentcube) {
		redirect('index.php');
		exit;
	}
	
	$title = $row['title'];
	
	echo sprintf("<sn:editor action='action.php?edit=%s'>", $_REQUEST['widget_id']);
	echo sprintf("<sn:editor-text label='Name' name='title' value='%s' maxlength='64' size='64' />", $title);

$fbml2 = <<<EndHereDoc2
<sn:editor-custom label="Don't list in profile">
EndHereDoc2;

	echo $fbml2;

	if($row['hidden']) {
		echo sprintf("<label>");
		echo sprintf("<input type='checkbox' name='hidden' value='swap' style='width:auto' checked='1'/>");
	}
	else {
		echo sprintf("<label>");
		echo sprintf("<input type='checkbox' name='hidden' value='swap' style='width:auto' />");
	}
	
$fbml3 = <<<EndHereDoc3
</label>
</sn:editor-custom>

<sn:editor-buttonset>
	<sn:editor-button value='Save Changes' />
	<sn:editor-cancel href='index.php' />
</sn:editor-buttonset>
</sn:editor>
EndHereDoc3;

	echo $fbml3;
}
else {
$fbml2 = <<<EndHereDoc2
<sn:error>
     <sn:message>Error</sn:message>
     Sorry, this widget is no longer available.
</sn:error>
EndHereDoc2;

	echo $fbml2;
}

?>
