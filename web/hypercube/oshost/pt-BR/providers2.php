<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

if (!isset($user)) {
	exit;
}

$html = <<<EndHereDoc
<html>
<head>
	<meta http-equiv='content-type' content='text/html; charset=utf-8'>
	<style type='text/css'>
		@import 'main.css';
	</style>
</head>

<body>
<h2>Inlcuir Widget</h2>

<div id='tabs1'><ul>
EndHereDoc;

echo $html;

echo sprintf("<li><a href='new.php?%s'><span>Criar Widget a partir do Código</span></a></li>", $template);
echo "<li id='current'><a href='#'><span>Galeria de Provedores</span></a></li>";
echo sprintf("<li><a href='featured.php?%s'><span>Widget em Destaque</span></a></li>", $template);

echo "</ul></div>";
echo "<div id='widget'><ul>";

echo sprintf("<a href='providers.php?%s'>Diretórios de Widgets</a> | ", $template);
echo sprintf("<a href='providers1.php?%s'>Diversão &amp; Jogos</a> | ", $template);
echo "Vídeo para Páginas | ";
echo sprintf("<a href='providers3.php?%s'>Apresentação de Fotos</a> | ", $template);
echo sprintf("<a href='providers4.php?%s'>Tocadores de Musica</a> | ", $template);
echo sprintf("<a href='providers5.php?%s'>Outros Widgets</a>", $template);

$html2 = <<<EndHereDoc2
</ul>

<table border='0' align='left' cellpadding='0' cellspacing='20'>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/aniBOOM.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/aniBOOM.png' /><p>aniBOOM</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/blip.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/blip.png' /><p>blip.tv</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Break.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Break.png' /><p>Break.com</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Brightcove.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Brightcove.png' /><p>Brightcove</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ChannelFrederator.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ChannelFrederator.png' /><p>Channel Frederator</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ClipShack.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ClipShack.png' /><p>ClipShack</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Crackle.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Crackle.png' /><p>Crackle</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Cruxy.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Cruxy.png' /><p>Cruxy</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Dailymotion.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Dailymotion.png' /><p>Dailymotion</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/DAVE.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/DAVE.png' /><p>DAVE.TV</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/eyespot.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/eyespot.png' /><p>eyespot</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FanCovers.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FanCovers.png' /><p>FanCovers.com</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FlixFocus.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FlixFocus.png' /><p>FlixFocus</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/FunnyOrDie.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/FunnyOrDie.png' /><p>Funny or Die</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Fuzzwich.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Fuzzwich.png' /><p>Fuzzwich</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoFish.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoFish.png' /><p>GoFish</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/GoogleVideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/GoogleVideo.png' /><p>Google Video</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Guba.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Guba.png' /><p>Guba</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Heavy.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Heavy.png' /><p>Heavy</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ifilm.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ifilm.png' /><p>ifilm</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/imeem.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/imeem.png' /><p>imeem</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Jumpcut.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Jumpcut.png' /><p>Jumpcut</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/kewego.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/kewego.png' /><p>kewego</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/kyte.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/kyte.png' /><p>kyte.tv</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/LiveVideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/LiveVideo.png' /><p>LiveVideo</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/lulu.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/lulu.png' /><p>lulu.tv</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Megavideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Megavideo.png' /><p>Megavideo</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Metacafe.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Metacafe.png' /><p>Metacafe</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/motionbox.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/motionbox.png' /><p>motionbox</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/NingVideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/NingVideo.png' /><p>Ning Video</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Operator11.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Operator11.png' /><p>Operator11</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Photobucket.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Photobucket.png' /><p>Photobucket</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Podtech.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Podtech.png' /><p>Podtech.net</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Pyro.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Pyro.png' /><p>Pyro.tv</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Revver.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Revver.png' /><p>Revver</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Sharkle.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Sharkle.png' /><p>Sharkle</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Splashcast.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Splashcast.png' /><p>Splashcast</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/StupidVideos.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/StupidVideos.png' /><p>StupidVideos</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/twango.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/twango.png' /><p>twango</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/UnCutVideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/UnCutVideo.png' /><p>UnCut</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ustream.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ustream.png' /><p>ustream.tv</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Veoh.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Veoh.png' /><p>Veoh</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Viddler.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Viddler.png' /><p>Viddler</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/VideoJug.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/VideoJug.png' /><p>VideoJug</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Vidiac.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Vidiac.png' /><p>Vidiac</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/vidiLife.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/vidiLife.png' /><p>vidiLife</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Vidmax.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Vidmax.png' /><p>Vidmax</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Vimeo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Vimeo.png' /><p>Vimeo</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/VMIX.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/VMIX.png' /><p>VMIX</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/vSocial.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/vSocial.png' /><p>vSocial</p></a>
	</td>
</tr>
<tr>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/WeShow.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/WeShow.png' /><p>WeShow</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/YahooVideo.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/YahooVideo.png' /><p>Yahoo! Video</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/YouTube.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/YouTube.png' /><p>YouTube</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/Ziddio.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/Ziddio.png' /><p>Ziddio</p></a>
	</td>
	<td width='128' align='center' valign='top'>
		<a href='http://www.amnestywidgets.com/hypercube/providers/pages/ZippyVideos.html' target='_blank'>
		<img width='64' height='48' src='http://www.amnestywidgets.com/hypercube/providers/images/ZippyVideos.png' /><p>ZippyVideos</p></a>
	</td>
</tr>
<tr>
</tr>
</table>
</div>
</body>
</html>
EndHereDoc2;

echo $html2;

?>
