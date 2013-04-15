<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<fb:header>Edit Widget</fb:header>
 
<fb:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<fb:tab-item href='edit.php?widget_id=%s' title='Widget Properties' selected='true' />", $_REQUEST['widget_id']);
   
$fbml4 = <<<EndHereDoc4
</fb:tabs>

<style>
	.label { position:relative; display:block; left:16px; top:-16px; }
</style>
EndHereDoc4;

echo $fbml4;

$result = query("select cube_id, title, hidden from widgets where widget_id = " . $_REQUEST['widget_id'] . " and cube_id = " . $currentcube);
if ($row = mysql_fetch_assoc($result)) {
	$cube_id = $row['cube_id'];
	if($cube_id != $currentcube) {
		$facebook->redirect('index.php');
		exit;
	}
	
	$title = $row['title'];
	
	echo sprintf("<fb:editor action='action.php?edit=%s'>", $_REQUEST['widget_id']);
	echo sprintf("<fb:editor-text label='Name' name='title' value='%s' maxlength='64' />", $title);

$fbml2 = <<<EndHereDoc2
<fb:editor-custom label="Don't list in profile">
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
</fb:editor-custom>

<fb:editor-buttonset>
	<fb:editor-button value='Save Changes' />
	<fb:editor-cancel href='index.php' />
</fb:editor-buttonset>
</fb:editor>
EndHereDoc3;

	echo $fbml3;
}
else {
$fbml2 = <<<EndHereDoc2
<fb:error>
     <fb:message>Error</fb:message>
     Sorry, this widget is no longer available.
</fb:error>
EndHereDoc2;

	echo $fbml2;
}

?>
