<?php
//
//  Amnesty(TM) Hypercube
//  Copyright (c) 2007 Mesa Dynamics, LLC. All rights reserved.
//

require_once 'dbappinclude.php';

$fbml = <<<EndHereDoc
<fb:dashboard>
	<fb:action href="index.php">&laquo; Back to Widgets</fb:action>
	<fb:help href='help.php'>Help</fb:help>
</fb:dashboard>

<fb:explanation>
     <fb:message>Web widgets on your desktop</fb:message>
     <p>Amnesty&trade; Hypercube is also available as a free downloadable application: a complete desktop platform solution for running web widgets outside
     of your browser.  And if you're a Sidebar or Dashboard user, you can push your web widgets into
     those environments with one click.</p>
     <p>We'll be rolling out a new version soon that fully integrates with your Hypercube widgets in Facebook: when you
     add a widget here, you'll be able to open it on your desktop automatically (and web widgets you add to your desktop will be accessible here in Facebook).</p>
     <p>If you download a copy of the Amnesty Hypercube public alpha, please keep in touch with your comments, suggestions and bug reports.  Thanks!</p>
</fb:explanation>

<style>
.lists {
	padding-left: 8px;
	padding-bottom: 8px;
}

.lists th {
     text-align: left;
     padding: 5px 10px;
     background: #6d84b4;
}

.lists .spacer {
     background: none;
     border: none;
     padding: 0px;
     margin: 0px;
     width: 10px; 
}

.lists th h4 { float: left; color: white; }
.lists th a { float: right; font-weight: normal; color: #d9dfea; }
.lists th a:hover { color: white; }

.lists td {
     margin:0px 10px;
     padding:0px;
     vertical-align:top;
     width:306px;
}

.lists .list {
     background:white none repeat scroll 0%;
     border-color:-moz-use-text-color #BBBBBB;
     border-style:none solid;
     border-width:medium 1px;
}

.lists .list .list_item { border-top:1px solid #E5E5E5; padding: 10px; }
.lists .list .list_item.first { border-top: none; }

.lists .see_all {
     background:white none repeat scroll 0%;
     border-color:-moz-use-text-color #BBBBBB rgb(187, 187, 187);
     border-style:none solid solid;
     border-width:medium 1px 1px;
     text-align:left;
}

.lists .see_all div { border-top:1px solid #E5E5E5; padding:5px 10px; }
</style>

<div>
     <table class="lists" cellspacing="0" border="0">
          <tr>
               <th>
                    <h4>Hypercube for Windows</h4>
                    <a href="http://www.amnestywidgets.com/software/hyperinstall.exe">Download Now</a>
               </th>
               <th class="spacer"></th>
               <th>
                    <h4>Hypercube for OS X</h4>
                    <a href="http://www.amnestywidgets.com/software/AmnestyHypercube.zip">Download Now</a>
               </th>
          </tr>
          <tr>
               <td class="list">
                   	<div class="list_item clearfix">
                   	<img src="http://www.amnestywidgets.com/hypercube/fbhost/images/hcwin.png" />
                   	</div>
              </td>
               <td class="spacer"></td>
               <td class="list">
                   	<div class="list_item clearfix">
                   	<img src="http://www.amnestywidgets.com/hypercube/fbhost/images/hcmac.png" />
                   	</div>
               </td>
          </tr>
          <tr>
               <td class="see_all"><div><a href="http://www.amnestywidgets.com/HypercubeWin.html" target="_blank">Open product page</a></div></td>
               <td class="spacer"></td>
               <td class="see_all"><div><a href="http://www.amnestywidgets.com/HypercubeMac.html" target="_blank">Open product page</a></div></td>
          </tr>
     </table>
</div>

EndHereDoc;

echo $fbml;

?>
