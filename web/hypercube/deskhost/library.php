<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'libraryinclude.php';

$xml = <<<EndHereDoc
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
EndHereDoc;

echo $xml;

if (isset($currentcube)) {
	$result = query("select widget_id, title, code from widgets where cube_id = " . $currentcube . " order by title");
	while ($row = mysql_fetch_assoc($result)) {
		$widget_id = $row['widget_id'];
		$title = htmlspecialchars($row['title'], ENT_QUOTES);
		$code = htmlspecialchars($row['code'], ENT_QUOTES);
		
		echo sprintf("<key>%s</key>", $widget_id);
		echo '<dict>';
		
			echo '<key>title</key>';
			echo sprintf("<string>%s</string>", $title);
			echo '<key>code</key>';
			echo sprintf("<string>%s</string>", $code);
			
		echo '</dict>';
		
	}
}

$xml2 = <<<EndHereDoc2
</dict>
</plist>
EndHereDoc2;

echo $xml2;

?>

