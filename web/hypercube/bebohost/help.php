<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<sn:dashboard>
	<sn:action href="index.php">&laquo; Back to Widgets</sn:action>
	<sn:help href='help.php'>Help</sn:help>
</sn:dashboard>

<sn:explanation>
     <sn:message>Help</sn:message>
     <p>
     Amnesty&trade; Hypercube is a Bebo application that allows you to collect and share <i>web widgets</i> with your friends.  What's a web widget?  A web
     widget is a mini-application that is supposed to be embedded inside a blog or home page.  Examples include photo slideshows, streaming audio players,
     flash games and embeddable video.
     For example, a YouTube video could be considered a widget.  As could a small flash game available from Miniclip.  The main
     thing that web widgets have in common is that they are published as small <i>snippets</i> of HTML code.</p>
     <p>
     Using Hypercube, you can convert these code snippets into widgets that run inside of Bebo.  And if you find a really great widget you
     can easily share it with your friends here on Bebo.
     </p>
     <p>
     The trick is to find code snippets and that's where Hypercube's Provider Gallery can help.
     The Provider Gallery is a list of web sites that publish widgets as code snippets.  We keep the Provider Gallery up-to-date with widget sites
     as they come into existence, so it's a good place to check often.  Each site has a different process by which you obtain widget code,
     but once you get the code, you just cut-and-paste the snippet into Hypercube and start using your new widget right away.
     </p>
     <p>
     Another convenient place to get widgets is Hypercube's Featured Widget tab.  We'll update the Featured Widget regularly with cool widgets that
     we find to share with you.
     </p>
     <p>
     We have lots of plans for Hypercube on Bebo, including integration with our free desktop widget platform version of Amnesty Hypercube.  That way
     you'll be able to access your widgets directly on your desktop, Vista's Sidebar, Apple's Dashboard or here in Bebo.  As we continue to
     enhance both products we'll
     be sure to keep you in the loop on our Bebo Profile page.</p>
</sn:explanation>
<sn:explanation>
	<sn:message>Credits</sn:message>
	<p>
	Amnesty&trade; Hypercube &copy; 2008 Danny Espinoza
	</p>
</sn:explanation>

EndHereDoc;

echo $fbml;

?>
