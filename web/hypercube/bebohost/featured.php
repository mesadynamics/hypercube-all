<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:header>Add Widget</sn:header>
 
<sn:tabs>
   <sn:tab-item href='new.php' title='Create Widget from Code' />
   <sn:tab-item href='providers.php' title='Provider Gallery' />
   <sn:tab-item href='featured.php' title='Featured Widget' selected='true' />
</sn:tabs>
EndHereDoc;

echo $fbml;

echo sprintf("<sn:iframe style='width:780px;height:585px;' src='http://www.amnestywidgets.com/hypercube/bebohost/fidget.php' frameborder='0' scrolling='no' smartsize='yes' />");
		
?>
