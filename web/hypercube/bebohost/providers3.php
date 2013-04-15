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
<a href="providers.php" target="_top">Widget Directories</a> |
<a href="providers1.php" target="_top">Fun &amp; Games</a> |
<a href="providers2.php" target="_top">Embeddable Video</a> |
Photo Slideshows |
<a href="providers4.php" target="_top">Music Players</a> |
<a href="providers5.php" target="_top">Other Widgets</a>
</ul>

<table border='0' align='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/BlueString.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/BlueString.png' /><p>BlueString</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Cellblock.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Cellblock.png' /><p>Cellblock</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Flektor.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Flektor.png' /><p>Flektor</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FlipFrames.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FlipFrames.png' /><p>FlipFrames</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Fliptrack.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Fliptrack.png' /><p>Fliptrack</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Gickr.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Gickr.png' /><p>Gickr</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoodWidgets.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoodWidgets.png' /><p>GoodWidgets</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/imageloop.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/imageloop.png' /><p>imageloop</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Leafletter.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Leafletter.png' /><p>Leafletter</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/PhotoShakr.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/PhotoShakr.png' /><p>PhotoShakr</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/PictureTrail.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/PictureTrail.png' /><p>PictureTrail</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Slide.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Slide.png' /><p>Slide</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Vuvox.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Vuvox.png' /><p>Vuvox</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/webshots.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/webshots.png' /><p>webshots</p></a>
	</td>
</tr>
</table>

EndHereDoc;

echo $fbml;

?>
