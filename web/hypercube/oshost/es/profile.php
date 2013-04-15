<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
	exit;
}

$listcount = 0;
$list = '';

$result = query("select title, widget_id, hash, hidden from widgets where cube_id = " . $currentcube . " order by title");
while ($row = mysql_fetch_assoc($result)) {	
	$title = mysql_real_escape_string($row['title']);

	if ($row['hidden'] == 0) {
		$listcount++;
		
		$hash = $row['hash'];
		if(!isset($hash))
			$hash = '0';
		
		if ($listcount == 1)	
			$list .= sprintf("<a href='#' onclick=\"widgetjump('%s');\">%s</a>", $row['widget_id'], $title);
		else
			$list .= sprintf(", <a href='#' onclick=\"widgetjump('%s');\">%s</a>", $row['widget_id'], $title);
	}
}

echo "<span style='font: normal 12px/1.5em Verdana,Arial,sans-serif'>";

if ($listcount == 0)
	$profile = '0 widgets añadidos. :-(';
else if ($listcount == 1) {
	$profile = sprintf("1 widget añadidos: %s.", $list);
}
else {
	$profile = sprintf("%s widgets añadidos: %s.", $listcount, $list);
}
	
echo $profile;
echo "</span>";

?>

