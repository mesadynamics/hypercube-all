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
   <sn:tab-item href='providers.php' title='Provider Gallery' selected='true' />
   <sn:tab-item href='featured.php' title='Featured Widget' />
</sn:tabs>

<ul>
Widget Directories |
<a href="providers1.php" target="_top">Fun &amp; Games</a> |
<a href="providers2.php" target="_top">Embeddable Video</a> |
<a href="providers3.php" target="_top">Photo Slideshows</a> |
<a href="providers4.php" target="_top">Music Players</a> |
<a href="providers5.php" target="_top">Other Widgets</a>
</ul>

<table border='0' align='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FancyGens.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FancyGens.png' /><p>FancyGens</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoogleGadgets.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoogleGadgets.png' /><p>Google Gadgets</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/LabPixies.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/LabPixies.png' /><p>LabPixies</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Pageflakes.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Pageflakes.png' /><p>Pageflakes</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/RockYou.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/RockYou.png' /><p>RockYou!</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/SpringWidgets.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/SpringWidgets.png' /><p>SpringWidgets</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Widgetbox.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Widgetbox.png' /><p>Widgetbox</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/yourminis.html' target='_blank'>
		<img width='64' height='48'src='http://www.amnestywidgets.com/hypercube/providers/images/yourminis.png' /><p>yourminis</p></a>
	</td>
</tr>
</table>

EndHereDoc;

echo $fbml;

?>
