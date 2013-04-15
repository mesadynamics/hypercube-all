<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<fb:header>Add Widget</fb:header>
 
<fb:tabs>
   <fb:tab-item href='new.php' title='Create Widget from Code' />
   <fb:tab-item href='providers.php' title='Provider Gallery' />
   <fb:tab-item href='featured.php' title='Featured Widget' selected='true' />
</fb:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<fb:iframe src='http://www.amnestywidgets.com/hypercube/fbhost/fidget.php' frameborder='0' scrolling='no' smartsize='yes' />");
		
?>
