<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007-2008 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'libraryinclude.php';

if (!isset($currentcube)) {
	exit;
}

if (isset($_REQUEST['create'])) {	
	$title = mysql_real_escape_string($_REQUEST['title']);
	
	if(strpos($_REQUEST['code'], 'gmodules.com') && strpos($_REQUEST['code'], 'synd=open')) {
		$newcode = str_replace('synd=open', 'synd=amnesty', $_REQUEST['code']);
		$code = mysql_real_escape_string($newcode);
	}
	else
		$code = mysql_real_escape_string($_REQUEST['code']);
	
	if (isset($code) && isset($title) && $code != '' && $title != '') {
		$query = sprintf("insert into widgets (code, title, cube_id, hash) values ('%s', '%s', %s, '%s')",
			$code, $title, $currentcube, md5($code));
		query($query);
		
		$result = query("select widget_id from widgets where widget_id = last_insert_id()");
		$row = mysql_fetch_assoc($result);
		$widget_id = $row['widget_id'];
		
		echo $widget_id;
	}
	else {
		echo '0';
	}
}
else if (isset($_REQUEST['remove'])) {
	query("update " . $dest . " set widget_id = NULL where " . $user_id . " = " . $user . " and widget_id = " . $_REQUEST['remove']);
	query("update widgets set cube_id = 0 where widget_id = " . $_REQUEST['remove'] . " and cube_id = " . $currentcube);
}

?>
