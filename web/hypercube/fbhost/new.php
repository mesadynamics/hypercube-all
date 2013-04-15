<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<fb:header>Add Widget</fb:header>
 
<fb:tabs>
   <fb:tab-item href='new.php' title='Create Widget from Code' selected='true' />
   <fb:tab-item href='providers.php' title='Provider Gallery' />
   <fb:tab-item href='featured.php' title='Featured Widget' />
</fb:tabs>

<fb:editor action='action.php?create'>
<fb:editor-text label='Name' name='title' value='' maxlength='64' />
<fb:editor-textarea label='Code' name='code' rows='6' />
<fb:editor-buttonset>
	<fb:editor-button value='Create Widget' />
	<fb:editor-cancel href='index.php' />
</fb:editor-buttonset>
</fb:editor>

<fb:explanation>
     <fb:message>Looking for widget code?</fb:message>
     	You can find widget code browsing the sites in our Provider Gallery or from any site that publishes widgets, 
     	flash games or video that can be embedded on a web page.&nbsp; You can also check out our Featured Widget
     	which includes code to grab and use right away.
     	<br /><br />
     	When you're ready, <b>1) type in your new widget's name,</b> and <b>2) paste
	    the widget code into the box above</b>.&nbsp; When you click Create Widget, your new widget will appear under a new tab inside Hypercube.
</fb:explanation>
EndHereDoc;


echo $fbml;

?>
