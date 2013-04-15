<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:header>Add Widget</sn:header>
 
<sn:tabs>
   <sn:tab-item href='new.php' title='Create Widget from Code' selected='true' />
   <sn:tab-item href='providers.php' title='Provider Gallery' />
   <sn:tab-item href='featured.php' title='Featured Widget' />
</sn:tabs>

<sn:editor action='action.php?create'>
<sn:editor-text label='Name' name='title' value='' maxlength='64' size='64' />
<sn:editor-textarea label='Code' name='code' rows='6' cols='61' />
<sn:editor-buttonset>
	<sn:editor-button value='Create Widget' />
	<sn:editor-cancel href='index.php' />
</sn:editor-buttonset>
</sn:editor>

<sn:explanation>
     <sn:message>Looking for widget code?</sn:message>
     	You can find widget code browsing the sites in our Provider Gallery or from any site that publishes widgets, 
     	flash games or video that can be embedded on a web page.&nbsp; You can also check out our Featured Widget
     	which includes code to grab and use right away.
     	<br /><br />
     	When you're ready, <b>1) type in your new widget's name,</b> and <b>2) paste
	    the widget code into the box above</b>.&nbsp; When you click Create Widget, your new widget will appear under a new tab inside Hypercube.
</sn:explanation>
EndHereDoc;


echo $fbml;

?>
