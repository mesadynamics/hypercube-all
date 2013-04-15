<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:dashboard>
	<sn:action href='desktop.php'>Widgets on your desktop</sn:action>
	<sn:action href='eula.php'>License</sn:action>
	<sn:action href='help.php'>Help</sn:action>
	<sn:create-button href='new.php'>Add a Widget</sn:create-button>
</sn:dashboard>
EndHereDoc;

echo $fbml;

$widgetcount = 0;
$listcount = 0;
$list = '';

$ishidden = false;
$currenthash = 0;

$result = query("select title, widget_id, hash, hidden from widgets where cube_id = " . $currentcube . " order by title");
while ($row = mysql_fetch_assoc($result)) {
	$widgetcount++;
	
	if ($widgetcount == 1) {
		echo '<sn:tabs>';
	
		if (!isset($currentwidget))
			$currentwidget = $row['widget_id'];
	}
	else if(($widgetcount % 6) == 0) {
		//echo '</sn:tabs><sn:tabs>';
	}
	
	$title = mysql_real_escape_string($row['title']);

	if ($currentwidget == $row['widget_id'])	
		echo sprintf("<sn:tab-item href='action_switch.php?widget_id=%s' title='%s' selected='true' />", $row['widget_id'], $title);
	else
		echo sprintf("<sn:tab-item href='action_switch.php?widget_id=%s' title='%s' />", $row['widget_id'], $title);
		
	if ($row['hidden'] == 0) {
		$listcount++;
		
		$hash = $row['hash'];
		if(!isset($hash))
			$hash = '0';

		if ($currentwidget == $row['widget_id'])	
			$currenthash = $hash;
		
		if ($listcount == 1)	
			$list .= sprintf("<a href='http://apps.bebo.com/hypercube/peek.php?widget_id=%s&hash=%s'>%s</a>", $row['widget_id'], $hash, $title);
		else
			$list .= sprintf(", <a href='http://apps.bebo.com/hypercube/peek.php?widget_id=%s&hash=%s'>%s</a>", $row['widget_id'], $hash, $title);
	}
	else if ($currentwidget == $row['widget_id'])
		$ishidden = true;
}

if ($widgetcount > 0) {
	echo '</sn:tabs>';
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
	
	if ($listcount == 0)
		$mobile = '';
	else
		$mobile = str_replace("/preview.php", "/mobile.php", $list);
		
	$bebo->api_client->profile_setFBML($profile);

	query("update bebo set fb_sig_time = null where fb_sig_user = " . $user);
}

if ($newuser == 'true') {
$fbml2 = <<<EndHereDoc2
<sn:explanation>
     <sn:message>Welcome to Amnesty&trade; Hypercube!</sn:message>
     We've gone ahead and added a couple of sample widgets for you to get started.&nbsp; 
     You can find more widgets browsing the sites in our Provider Gallery or from any site that publishes widgets, flash games or video
     that can be embedded in a web page.
</sn:explanation>
EndHereDoc2;

	echo $fbml2;
}

echo sprintf("<a href='http://www.amnestywidgets.com/hypercube/deskhost/link.php?destination=bebo.com&user=%s&cube=%s&source=Hypercube'></a>", $user, $currentcube);

if (isset($currentwidget)) {
	query("update cubes set serve_count = serve_count + 1 where cube_id = " . $currentcube);

$fbml3 = <<<EndHereDoc3
<style>
	.fb { float:right; padding-top: 6px; padding-left: 4px; padding-right: 4px; margin-right:6px; }
	.icons { float:right; padding-top: 4px; padding-right: 4px; }
	.lock { float:left; padding-top: 4px; padding-left: 4px; }
</style>
EndHereDoc3;

	echo $fbml3;

	if($ishidden)
		echo sprintf("<img class='lock' title='Widget not listed in profile' src='http://www.amnestywidgets.com/hypercube/bebohost/images/lock_16.gif' />"); 
	
	echo sprintf("<div class='icons'><a title='Edit widget' href='edit.php?widget_id=%s'>", $currentwidget); 	

$fbml5 = <<<EndHereDoc5
	<img src='http://www.amnestywidgets.com/hypercube/bebohost/images/edit_16.gif' /></a>
	<a title='Remove widget' href='#' clicktoshow='removeconfirm'>
	<img src='http://www.amnestywidgets.com/hypercube/bebohost/images/trash_16.gif' /></a>
</div>
<div id='removeconfirm' style='display:none;'>
EndHereDoc5;

	echo $fbml5;
		
	echo sprintf("<sn:editor action='action.php?remove=%s'>", $currentwidget);
	
$fbml6 = <<<EndHereDoc6
	This action cannot be undone.  Do you really want to remove this widget?
   <sn:editor-buttonset>
		<sn:editor-button value='Yes' />
		<sn:editor-button value='No' clicktohide='removeconfirm' />
   </sn:editor-buttonset>
</sn:editor>
</div>
EndHereDoc6;

	echo $fbml6;
	
	echo sprintf("<div class='fb'><sn:share-button class='url' href='http://apps.bebo.com/hypercube/preview.php?widget_id=%s&hash=%s' /></div>", $currentwidget, $currenthash);
	
	echo sprintf("<sn:iframe style='width:780px;height:585px;' src='http://www.amnestywidgets.com/hypercube/bebohost/widget.php?widget_id=%s&cube_id=%s' frameborder='0' scrolling='no' smartsize='yes' />",
		$currentwidget, $currentcube);
}

?>
