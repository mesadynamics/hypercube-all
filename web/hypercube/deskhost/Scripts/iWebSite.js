//
//  iWeb - iWebSite.js
//  Copyright (c) 2007 Apple Inc. All rights reserved.
//
//
//  This file includes a copy of the Prototype JavaScript framework:
//
//  Prototype JavaScript framework, version 1.5.0
//  (c) 2005-2007 Sam Stephenson
//
//  Prototype is freely distributable under the terms of an MIT-style license.
//  For details, see the Prototype web site: http://prototype.conio.net/

var windowsInternetExplorer=false;var isGecko=false;var isMozilla=false;var isFirefox=false;var isCamino=false;var isSafari=false;var isNS=false;var isWebKit=false;var isOpera=false;var isiPhone=false;var isEarlyWebKitVersion=false;var browserDetected=false;var listOfIE7FloatsFix=[];function detectBrowser()
{if(browserDetected===false)
{windowsInternetExplorer=false;var appVersion=navigator.appVersion;if((appVersion.indexOf("MSIE")!=-1)&&(appVersion.indexOf("Macintosh")==-1))
{var temp=appVersion.split("MSIE");browserVersion=parseFloat(temp[1]);windowsInternetExplorer=true;if(typeof(Node)=="undefined")
{Node={};Node.ELEMENT_NODE=1;Node.ATTRIBUTE_NODE=2;Node.TEXT_NODE=3;Node.CDATA_SECTION_NODE=4;Node.ENTITY_REFERENCE_NODE=5;Node.ENTITY_NODE=6;Node.PROCESSING_INSTRUCTION_NODE=7;Node.COMMENT_NODE=8;}}
else
{var ua=navigator.userAgent.toLowerCase();isGecko=(ua.indexOf('gecko')!=-1);isMozilla=(this.isGecko&&ua.indexOf("gecko/")+14==ua.length);isFirefox=(this.isGecko&&ua.indexOf("firefox")!=-1);isCamino=(this.isGecko&&ua.indexOf("camino")!=-1);isSafari=(this.isGecko&&ua.indexOf("safari")!=-1);isNS=((this.isGecko)?(ua.indexOf('netscape')!=-1):((ua.indexOf('mozilla')!=-1)&&(ua.indexOf('spoofer')==-1)&&(ua.indexOf('compatible')==-1)&&(ua.indexOf('opera')==-1)&&(ua.indexOf('webtv')==-1)&&(ua.indexOf('hotjava')==-1)));isOpera=!!window.opera;var matchResult=ua.match(/applewebkit\/(\d+)/);if(matchResult)
{isiPhone=(ua.indexOf("mobile/")!=-1);isWebKit=true;webKitVersion=parseInt(matchResult[1]);isEarlyWebKitVersion=(webKitVersion<522);}}
browserDetected=true;}}
function shouldApplyCSSBackgroundPNGFix()
{detectBrowser();return(windowsInternetExplorer&&(browserVersion<7));}
function photocastHelper(url)
{var feed=new IWURL(url);var iPhotoVersionMin=600;var iPhotoMimeTypePlugin="application/photo";if(navigator.mimeTypes&&navigator.mimeTypes.length>0)
{var iPhoto=navigator.mimeTypes[iPhotoMimeTypePlugin];if(iPhoto)
{var description=iPhoto.description;try
{var components=description.split(" ");if(components&&components.length>1)
{var pluginVersion=components[1];if(pluginVersion>=iPhotoVersionMin)
{feed.mProtocol="photo";}}}
catch(exception)
{}}}
window.location=feed.toURLString();}
function loadCSS(file)
{var cssNode=document.createElement('link');cssNode.setAttribute('rel','stylesheet');cssNode.setAttribute('type','text/css');cssNode.setAttribute('href',file);document.getElementsByTagName('head')[0].appendChild(cssNode);}
function loadMozillaCSS(file)
{detectBrowser();if((isMozilla)||(isFirefox)||(isCamino))
{loadCSS(file);}}
function utf8sequence(c)
{if(c<=0x0000007f)return[c];if(c<=0x000007ff)return[(0xc0|(c>>>6)),(0x80|(c&0x3f))];if(c<=0x0000ffff)return[(0xe0|(c>>>12)),(0x80|((c>>>6)&0x3f)),(0x80|(c&0x3f))];if(c<=0x001fffff)return[(0xf0|(c>>>18)),(0x80|((c>>>12)&0x3f)),(0x80|((c>>>6)&0x3f)),(0x80|(c&0x3f))];if(c<=0x03ffffff)return[(0xf8|(c>>>24)),(0x80|((c>>>18)&0x3f)),(0x80|((c>>>12)&0x3f)),(0x80|((c>>>6)&0x3f)),(0x80|(c&0x3f))];if(c<=0x7fffffff)return[(0xfc|(c>>>30)),(0x80|((c>>>24)&0x3f)),(0x80|((c>>>18)&0x3f)),(0x80|((c>>>12)&0x3f)),(0x80|((c>>>6)&0x3f)),(0x80|(c&0x3f))];return[];}
function utf8encode(s)
{var result=[];var firstSurrogate=0;for(var i=0;i<s.length;++i)
{var code=s.charCodeAt(i);if(firstSurrogate!=0)
{if((code>=0xDC00)&&(code<=0xDFFF))
{code=(firstSurrogate-0xD800)*0x400+(code-0xDC00)+0x10000;firstSurrogate=0;}}
else
{if((code<0xD800)||(code>0xDFFF))
{}
else if((code>=0xD800)&&(code<0xDC00))
{firstSurrogate=code;continue;}
else
{continue;}}
result=result.concat(utf8sequence(code));}
var resultString="";for(i=0;i<result.length;++i)
{resultString+=String.fromCharCode(result[i]);}
return resultString;}
function IELatin1Munge(UTF8String)
{var munged="";for(var i=0;i<UTF8String.length;i++)
{var c=UTF8String.charCodeAt(i);switch(c){case 0x0080:c=0x20AC;break;case 0x0081:break;case 0x0082:c=0x201A;break;case 0x0083:c=0x0192;break;case 0x0084:c=0x201E;break;case 0x0085:c=0x2026;break;case 0x0086:c=0x2020;break;case 0x0087:c=0x2021;break;case 0x0088:c=0x02C6;break;case 0x0089:c=0x2030;break;case 0x008A:c=0x0160;break;case 0x008B:c=0x2039;break;case 0x008C:c=0x0152;break;case 0x008D:break;case 0x008E:c=0x017D;break;case 0x008F:break;case 0x0090:break;case 0x0091:c=0x2018;break;case 0x0092:c=0x2019;break;case 0x0093:c=0x201C;break;case 0x0094:c=0x201D;break;case 0x0095:c=0x2022;break;case 0x0096:c=0x2013;break;case 0x0097:c=0x2014;break;case 0x0098:c=0x02DC;break;case 0x0099:c=0x2122;break;case 0x009A:c=0x0161;break;case 0x009B:c=0x203A;break;case 0x009C:c=0x0153;break;case 0x009D:break;case 0x009E:c=0x017E;break;case 0x009F:c=0x0178;break;}
munged+=String.fromCharCode(c);}
return munged;}
function IEConvertURLForPNGFix(urlString)
{var result=urlString;detectBrowser();if(windowsInternetExplorer)
{var decoded=decodeURI(urlString);if(decoded.match(/[^\x00-\x7f]/))
{result=IELatin1Munge(utf8encode(decodeURI(urlString)));}}
return result;}
function fixAllIEPNGs(transparentGif)
{detectBrowser();if(windowsInternetExplorer)
{for(var i=0;i<document.images.length;++i)
{if(document.images[i].src.slice(-4).toLowerCase()==".png")
{var img=$(document.images[i]);var fixPng=function(img)
{if(!img.originalSrc)
{if((img.style.width=="")&&(img.style.height==""))
{var width=img.width;var height=img.height;img.style.width=width+"px";img.style.height=height+"px";}
var filterName='progid:DXImageTransform.Microsoft.AlphaImageLoader';var filterParams='src="'+IEConvertURLForPNGFix(img.src)+'", sizingMethod="scale"';img.setFilter(filterName,filterParams);img.originalSrc=img.src;img.src=transparentGif;}};if(img.complete)
{fixPng(img);}
else
{img.onload=fixPng.bind(null,img);}}}}}
function toPixels(value)
{var converted=0;var px_per_pt=window.screen.logicalXDPI?(window.screen.logicalXDPI/72.0):1.3333;if(value.indexOf("px")>0)
{converted=parseFloat(value);}
else if(value.indexOf("pt")>0)
{converted=px_per_pt*parseFloat(value);}
else if(value.indexOf("in")>0)
{converted=72*px_per_pt*parseFloat(value);}
else if(value.indexOf("pc")>0)
{converted=12*px_per_pt*parseFloat(value);}
else if(value.indexOf("mm")>0)
{converted=2.83465*px_per_pt*parseFloat(value);}
else if(value.indexOf("cm")>0)
{converted=28.3465*px_per_pt*parseFloat(value);}
return converted;}
function toPixelsAtElement(element,value,vertical)
{var converted=0;if(value.indexOf("%")>0)
{var containerSize=0;if(vertical)
{containerSize=$(element.parentNode).getHeight();}
else
{containerSize=$(element.parentNode).getWidth();}
converted=containerSize*parseFloat(value)/100.0;}
else if(value.indexOf("em")>0)
{converted=parseFloat(value)*toPixels(Element.getStyle(element,'fontSize'));}
else
{converted=toPixels(value);}
return converted;}
function backgroundPositionDimension(oBlock,currentBGPosition,blockDimension,imageDimension)
{var position=0;if(currentBGPosition==='center')
{position=(blockDimension/2)-(imageDimension/2);}
else if((currentBGPosition==='right')||(currentBGPosition==='bottom'))
{position=blockDimension-imageDimension;}
else if((currentBGPosition==='left')||(currentBGPosition==='top'))
{position=0;}
else if(currentBGPosition.indexOf("px")>0)
{position=parseFloat(currentBGPosition);}
else if(currentBGPosition.indexOf("em")>0)
{position=parseFloat(currentBGPosition)*toPixels(oBlock.currentStyle.fontSize);}
else if(currentBGPosition.indexOf("%")>0)
{position=parseFloat(currentBGPosition)*blockDimension/100.0;}
else if((currentBGPosition.indexOf("pt")>0)||(currentBGPosition.indexOf("in")>0)||(currentBGPosition.indexOf("pc")>0)||(currentBGPosition.indexOf("cm")>0)||(currentBGPosition.indexOf("mm")>0))
{position=toPixels(currentBGPosition);}
return position;}
function elementHasCSSBGPNG(element)
{return(element.currentStyle&&element.currentStyle.backgroundImage&&(element.currentStyle.backgroundImage.indexOf('url(')!=-1)&&(element.currentStyle.backgroundImage.indexOf('.png")')!=-1));}
function fixupIEPNGBG(oBlock)
{if(oBlock)
{if(elementHasCSSBGPNG(oBlock))
{var currentBGImage=oBlock.currentStyle.backgroundImage;var currentBGRepeat=oBlock.currentStyle.backgroundRepeat;var currentBGPositionX=oBlock.currentStyle.backgroundPositionX;var currentBGPositionY=oBlock.currentStyle.backgroundPositionY;var urlStart=currentBGImage.indexOf('url(');var urlEnd=currentBGImage.indexOf(')',urlStart);var imageURL=currentBGImage.substring(urlStart+4,urlEnd);if(imageURL.charAt(0)=='"')
{imageURL=imageURL.substring(1);}
if(imageURL.charAt(imageURL.length-1)=='"')
{imageURL=imageURL.substring(0,imageURL.length-1);}
imageURL=IEConvertURLForPNGFix(imageURL);var overrideRepeat=false;var filterStyle="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+
imageURL+"', sizingMethod='crop');";if(RegExp("/C[0-9A-F]{8}.png$").exec(imageURL)!==null)
{filterStyle="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+
imageURL+"', sizingMethod='scale');";overrideRepeat=true;}
var fixupIEPNGBG_helper=function(img)
{var tileWidth=img.width;var tileHeight=img.height;var blockWidth=0;var blockHeight=0;if(oBlock.style.width)
{blockWidth=parseInt(oBlock.style.width,10);}
else
{blockWidth=oBlock.offsetWidth;}
if(oBlock.style.height)
{blockHeight=parseInt(oBlock.style.height,10);}
else
{blockHeight=oBlock.offsetHeight;}
var blockPaddingLeft=parseInt(oBlock.style.paddingLeft||0,10);if((blockWidth===0)||(blockHeight===0))
{return;}
var wholeRows=1;var wholeCols=1;var extraHeight=0;var extraWidth=0;if((currentBGRepeat.indexOf("no-repeat")!=-1)||((tileWidth===0)&&(tileHeight===0))||overrideRepeat)
{tileWidth=blockWidth;tileHeight=blockHeight;}
else if((currentBGRepeat.indexOf("repeat-x")!=-1)||(tileHeight===0))
{wholeCols=Math.floor(blockWidth/tileWidth);extraWidth=blockWidth-(tileWidth*wholeCols);tileHeight=blockHeight;}
else if(currentBGRepeat.indexOf("repeat-y")!=-1)
{wholeRows=Math.floor(blockHeight/tileHeight);extraHeight=blockHeight-(tileHeight*wholeRows);tileWidth=blockWidth;}
else
{wholeCols=Math.floor(blockWidth/tileWidth);wholeRows=Math.floor(blockHeight/tileHeight);extraWidth=blockWidth-(tileWidth*wholeCols);extraHeight=blockHeight-(tileHeight*wholeRows);}
var wrappedContent=document.createElement("div");var pngBGFixIsWrappedContentEmpty=true;wrappedContent.style.position="relative";wrappedContent.style.zIndex="1";wrappedContent.style.left="0px";wrappedContent.style.top="0px";wrappedContent.style.background="transparent";if(!isNaN(parseInt(oBlock.style.width,10)))
{wrappedContent.style.width=""+blockWidth+"px";}
if(!isNaN(parseInt(oBlock.style.height,10)))
{wrappedContent.style.height=""+blockHeight+"px";}
while(oBlock.hasChildNodes())
{if(oBlock.firstChild.nodeType==3)
{if(RegExp("^ *$").exec(oBlock.firstChild.data)===null)
{pngBGFixIsWrappedContentEmpty=false;}}
else
{pngBGFixIsWrappedContentEmpty=false;}
wrappedContent.appendChild(oBlock.firstChild);}
if(pngBGFixIsWrappedContentEmpty)
{wrappedContent.style.lineHeight="0px";}
var bgPositionX=backgroundPositionDimension(oBlock,currentBGPositionX,blockWidth,img.width);var bgPositionY=backgroundPositionDimension(oBlock,currentBGPositionY,blockHeight,img.height);bgPositionX-=blockPaddingLeft;var newMarkup="";for(var currentRow=0;currentRow<wholeRows;currentRow++)
{for(currentCol=0;currentCol<wholeCols;currentCol++)
{newMarkup+="<div class='pngtile' style="+"\"position: absolute; line-height: 0px; "+"width: "+tileWidth+"px; "+"height: "+tileHeight+"px; "+"left:"+(bgPositionX+(currentCol*tileWidth))+"px; "+"top:"+(bgPositionY+(currentRow*tileHeight))+"px; "+"filter:"+filterStyle+"\" > </div>";}
if(extraWidth!==0)
{newMarkup+="<div class='pngtile' style="+"\"position: absolute; line-height: 0px; "+"width: "+extraWidth+"px; "+"height: "+tileHeight+"px; "+"left:"+(bgPositionX+(currentCol*tileWidth))+"px; "+"top:"+(bgPositionY+(currentRow*tileHeight))+"px; "+"filter:"+filterStyle+"\" > </div>";}}
if(extraHeight!==0)
{for(currentCol=0;currentCol<wholeCols;currentCol++)
{newMarkup+="<div class='pngtile' style="+"\"position: absolute; line-height: 0px; "+"width: "+tileWidth+"px; "+"height: "+extraHeight+"px; "+"left:"+(bgPositionX+(currentCol*tileWidth))+"px; "+"top:"+(bgPositionY+(currentRow*tileHeight))+"px; "+"filter:"+filterStyle+"\" > </div>";}
if(extraWidth!==0)
{newMarkup+="<div class='pngtile' style="+"\"position: absolute; line-height: 0px; "+"width: "+extraWidth+"px; "+"height: "+extraHeight+"px; "+"left:"+(bgPositionX+(currentCol*tileWidth))+"px; "+"top:"+(bgPositionY+(currentRow*tileHeight))+"px; "+"filter:"+filterStyle+"\" > </div>";}}
oBlock.innerHTML=newMarkup;if(!pngBGFixIsWrappedContentEmpty)
{oBlock.appendChild(wrappedContent);}
oBlock.style.background="";}
var backgroundImage=new Image();backgroundImage.src=imageURL;if(backgroundImage.complete)
{fixupIEPNGBG_helper(backgroundImage);}
else
{backgroundImage.onload=fixupIEPNGBG_helper.bind(null,backgroundImage);}}}}
function fixupIEPNGBGsInTree(oAncestor,forceAutoFixup)
{if(shouldApplyCSSBackgroundPNGFix())
{try
{var allDivs=$A(oAncestor.getElementsByTagName('DIV'));if(isDiv(oAncestor))
{allDivs.push(oAncestor);}
allDivs.each(function(oNode)
{if(!$(oNode).hasClassName("noAutoPNGFix")||forceAutoFixup)
{fixupIEPNGBG(oNode);}});}
catch(e)
{}}}
function fixupAllIEPNGBGs()
{setTimeout(fixupIEPNGBGsInTree.bind(null,document),1);}
function optOutOfCSSBackgroundPNGFix(element)
{if(shouldApplyCSSBackgroundPNGFix())
{var allDivs=$A(element.getElementsByTagName("DIV"));allDivs.each(function(item)
{if(elementHasCSSBGPNG(item))
{$(item).addClassName("noAutoPNGFix");}});}}
function fixupIECSS3Opacity(strElementID)
{detectBrowser();if(windowsInternetExplorer)
{var oNode=$(strElementID);if(oNode&&(oNode.getStyle('opacity')<1))
{var opacity=oNode.getStyle('opacity');oNode.style.height=''+oNode.offsetHeight+'px';var targetNode=oNode;if(oNode.tagName.toLowerCase()=='img')
{targetNode=$(document.createElement('div'));targetNode.style.position=oNode.style.position;targetNode.style.top=oNode.style.top;targetNode.style.left=oNode.style.left;targetNode.style.width=oNode.style.width;targetNode.style.height=oNode.style.height;targetNode.style.opacity=oNode.style.opacity;targetNode.style.zIndex=oNode.style.zIndex;oNode.style.left='0px';oNode.style.top='0px';oNode.style.opacity='';if(oNode.parentNode.tagName.toLowerCase()=='a')
{var anchor=oNode.parentNode;anchor.parentNode.insertBefore(targetNode,anchor);targetNode.appendChild(anchor);}
else
{oNode.parentNode.insertBefore(targetNode,oNode);targetNode.appendChild(oNode);}}
else if(oNode.tagName.toLowerCase()=='div')
{var bufferWidth=100;var oNodeWidth=oNode.offsetWidth;var oNodeHeight=oNode.offsetHeight;extents=new IWExtents(-bufferWidth,-bufferWidth,oNodeWidth+bufferWidth,oNodeHeight*2+bufferWidth);var positionStyleVal=oNode.getStyle("position");var floatStyleVal=oNode.getStyle("float");var positioned=((positionStyleVal=="relative")||(positionStyleVal=="absolute"));var absolutelyPositioned=(positionStyleVal=="absolute"&&(floatStyleVal=="none"));targetNode=$(document.createElement('div'));var classString=oNode.className;classString=classString.replace(/(shadow_\d+)/g,'');classString=classString.replace(/(stroke_\d+)/g,'');classString=classString.replace(/(reflection_\d+)/g,'');targetNode.className=classString;targetNode.style.position=positioned?positionStyleVal:"relative";targetNode.style.styleFloat=floatStyleVal;targetNode.style.clear=oNode.getStyle("clear");targetNode.style.width=extents.right-extents.left+"px";targetNode.style.height=extents.bottom-extents.top+"px";targetNode.style.opacity=oNode.style.opacity;targetNode.style.zIndex=oNode.style.zIndex;if(absolutelyPositioned)
{targetNode.style.top=(parseFloat(oNode.getStyle("top"))||0)+extents.top+"px";targetNode.style.left=(parseFloat(oNode.getStyle("left"))||0)+extents.left+"px";}
else
{targetNode.style.marginTop=(parseFloat(oNode.getStyle("marginTop"))||0)+extents.top+"px";targetNode.style.marginLeft=(parseFloat(oNode.getStyle("marginLeft"))||0)+extents.left+"px";targetNode.style.marginBottom=(parseFloat(oNode.getStyle("marginBottom"))||0)-
(extents.bottom-oNodeHeight)+"px";targetNode.style.marginRight=(parseFloat(oNode.getStyle("marginRight"))||0)-
(extents.right-oNodeWidth)+"px";}
oNode.style.position="absolute";oNode.style.styleFloat="none";oNode.style.clear="none";oNode.style.left=-extents.left+"px";oNode.style.top=-extents.top+"px";oNode.style.margin='0px';oNode.style.verticalAlign='baseline';oNode.style.display='block';oNode.style.opacity='';if(browserVersion<7)
{oNode.className=oNode.className.replace(/(shadow_\d+)/g,'');}
oNode.parentNode.insertBefore(targetNode,oNode);targetNode.appendChild(oNode);}
$(targetNode).setFilter('progid:DXImageTransform.Microsoft.BasicImage','opacity='+opacity);}}}
function IWSetDivOpacity(div,fraction,suppressFilterRemoval)
{if(windowsInternetExplorer)
{if(fraction<.99||(suppressFilterRemoval==true))
{$(div).setFilter('alpha','opacity='+fraction*100);}
else
{$(div).killFilter('alpha');}}
else
{div.style.opacity=fraction;}}
function IMpreload(path,name,areaIndex)
{var rolloverName=name+'_rollover_'+areaIndex;var rolloverPath=path+'/'+rolloverName+'.png';self[rolloverName]=new Image();self[rolloverName].src=rolloverPath;var linkName=name+'_link_'+areaIndex;var linkPath=path+'/'+linkName+'.png';self[linkName]=new Image();self[linkName].src=linkPath;return true;}
function swapAlphaImageLoaderFilterSrc(img,src)
{var filterName='progid:DXImageTransform.Microsoft.AlphaImageLoader';var filterParams='src="'+IEConvertURLForPNGFix(src)+'", sizingMethod="scale"';img.setFilter(filterName,filterParams);img.originalSrc=img.src;}
function IMmouseover(name,areaIndex)
{var rolloverName=name+'_rollover_'+areaIndex;var linkName=name+'_link_'+areaIndex;var img=document.getElementById(linkName);if(img)
{detectBrowser();if(windowsInternetExplorer&&img.originalSrc)
{swapAlphaImageLoaderFilterSrc(img,self[rolloverName].src);}
else
{img.src=self[rolloverName].src;}}
return true;}
function IMmouseout(name,areaIndex)
{var linkName=name+'_link_'+areaIndex;var img=document.getElementById(linkName);if(img)
{detectBrowser();if(windowsInternetExplorer&&img.originalSrc)
{swapAlphaImageLoaderFilterSrc(img,self[linkName].src);}
else
{img.src=self[linkName].src;}}
return true;}
var quicktimeAvailable=false;var quicktimeVersion702=false;var isQuicktimeDetectionInitialized=false;var minVersionNum=0x7028000;var minVersionArray=['7','0','2'];function initializeQuicktimeDetection()
{if((navigator.plugins!==null)&&(navigator.plugins.length>0))
{for(i=0;i<navigator.plugins.length;i++)
{var plugin=navigator.plugins[i];if(plugin.name.toLowerCase().indexOf('quicktime plug-in ')!=-1)
{quicktimeAvailable=true;quicktimeVersionString=plugin.name.substring(18);var qtVersionArray=quicktimeVersionString.split('.');for(j=0;j<minVersionArray.length&&j<qtVersionArray.length;j++)
{var qtVersionComponent=qtVersionArray[j];var minVersionComponent=minVersionArray[j];if((qtVersionComponent>minVersionComponent)||((qtVersionComponent==minVersionComponent)&&(j==minVersionArray.length-1)))
{quicktimeVersion702=true;break;}
else if(qtVersionComponent<minVersionComponent)
{break;}}
break;}}}
else if(window.ActiveXObject)
{try
{quicktimeObj=new ActiveXObject('QuickTimeCheckObject.QuickTimeCheck.1');if(quicktimeObj!==null)
{quicktimeAvailable=true;quicktimeVersionNum=quicktimeObj.QuickTimeVersion;if(quicktimeVersionNum>=minVersionNum)
{quicktimeVersion702=true;}}}
catch(e)
{}}
isQuictimeDetectionInitialized=true;}
function fixupPodcast(mediaId,anchorId)
{if(!isQuicktimeDetectionInitialized)
{initializeQuicktimeDetection();}
if(!quicktimeVersion702)
{var oMediaElem=document.getElementById(mediaId);var oAnchorElem=document.getElementById(anchorId);if(oMediaElem&&oAnchorElem)
{oAnchorElem.style.display='inline';oMediaElem.parentNode.removeChild(oMediaElem);}}}
function allListBulletImagesContainedBy(node)
{var result=[];for(var i=0;i<node.childNodes.length;++i)
{var child=node.childNodes[i];if((child.nodeName=="IMG")&&((node.nodeName=="SPAN")||(node.nodeName=="A"))&&(node.parentNode!=null)&&(node.parentNode.nodeName=="P")&&(node.parentNode.parentNode!=null)&&(node.parentNode.parentNode.nodeName=="LI"))
{result=result.concat([child]);}
result=result.concat(allListBulletImagesContainedBy(child));}
return result;}
function hideAllListBulletImagesContainedBy(node)
{var images=allListBulletImagesContainedBy(node);for(var i=0;((images!=null)&&(i<images.length));++i)
{images[i].style.display="none";}}
function showAllListBulletImagesContainedBy(node)
{var images=allListBulletImagesContainedBy(node);for(var i=0;((images!=null)&&(i<images.length));++i)
{images[i].style.display="";}}
function getChildOfType(oParent,sNodeName,requestedIndex)
{var childrenOfType=oParent.getElementsByTagName(sNodeName);return(requestedIndex<childrenOfType.length)?childrenOfType.item(requestedIndex):null;}
function isDescendantInsideFixedHeightDescendantOfAncestor(oDescendant,oAncestor)
{if(oDescendant===oAncestor||oDescendant==null)
{return false;}
else if(parseFloat(oDescendant.style.height)>0)
{return true;}
else
{return isDescendantInsideFixedHeightDescendantOfAncestor(oDescendant.parentNode,oAncestor);}}
function getShrinkableParaDescendants(oAncestor)
{var oParaDescendants=[];var oPotentialParagraphs=oAncestor.getElementsByTagName('DIV');for(var iIndex=0;iIndex<oPotentialParagraphs.length;iIndex++)
{var oNode=oPotentialParagraphs.item(iIndex);if(oNode.className.lastIndexOf('paragraph')!=-1)
{if(isDescendantInsideFixedHeightDescendantOfAncestor(oNode,oAncestor))
{continue;}
oParaDescendants.push(oNode);}}
var oPotentialParagraphs=oAncestor.getElementsByTagName('P');for(var iIndex=0;iIndex<oPotentialParagraphs.length;iIndex++)
{var oNode=oPotentialParagraphs.item(iIndex);if(isDescendantInsideFixedHeightDescendantOfAncestor(oNode,oAncestor))
{continue;}
oParaDescendants.push(oNode);}
return oParaDescendants;}
var MINIMUM_FONT="10";var UNITS="";function elementFontSize(element)
{var fontSize=MINIMUM_FONT;if(document.defaultView)
{var computedStyle=document.defaultView.getComputedStyle(element,null);if(computedStyle)
{fontSize=computedStyle.getPropertyValue("font-size");}}
else if(element.currentStyle)
{fontSize=element.currentStyle.fontSize;}
if((UNITS.length===0)&&(fontSize!=MINIMUM_FONT))
{UNITS=fontSize.substring(fontSize.length-2,fontSize.length);}
return parseFloat(fontSize);}
function isExceptionToOneLineRule(element)
{return($(element).hasClassName("Header"))}
var HEIGHT_ERROR_MARGIN=2;function adjustFontSizeIfTooBig(idOfElement)
{var oParagraphDiv;var oSpan;var oTextBoxInnerDiv;var oTextBoxOuterDiv=document.getElementById(idOfElement);if(oTextBoxOuterDiv)
{oTextBoxInnerDiv=getElementsByTagAndClassName(oTextBoxOuterDiv,"DIV","text-content")[0];if(oTextBoxInnerDiv)
{hideAllListBulletImagesContainedBy(oTextBoxInnerDiv);var offsetHeight=oTextBoxInnerDiv.offsetHeight;var specifiedHeight=offsetHeight;if(oTextBoxOuterDiv.style.height!=="")
{specifiedHeight=parseFloat(oTextBoxOuterDiv.style.height);}
if(offsetHeight>(specifiedHeight+HEIGHT_ERROR_MARGIN))
{var smallestFontSize=200;var aParaChildren=getShrinkableParaDescendants(oTextBoxInnerDiv);var oneLine=false;var exceptionToOneLineRule=false;for(i=0;i<aParaChildren.length;i++)
{oParagraphDiv=aParaChildren[i];var lineHeight=elementLineHeight(oParagraphDiv);if(!isNaN(lineHeight))
{oneLine=oneLine||(lineHeight*1.5>=specifiedHeight);exceptionToOneLineRule=oneLine&&isExceptionToOneLineRule(oParagraphDiv);}
var fontSize=elementFontSize(oParagraphDiv);if(!isNaN(fontSize))
{smallestFontSize=Math.min(smallestFontSize,fontSize);}
for(j=0;j<oParagraphDiv.childNodes.length;j++)
{oSpan=oParagraphDiv.childNodes[j];if((oSpan.nodeName=="SPAN")||(oSpan.nodeName=="A"))
{fontSize=elementFontSize(oSpan);if(!isNaN(fontSize))
{smallestFontSize=Math.min(smallestFontSize,fontSize);}}}}
var minimum=parseFloat(MINIMUM_FONT);var count=0;while((smallestFontSize>minimum)&&(offsetHeight>(specifiedHeight+HEIGHT_ERROR_MARGIN))&&(count<10))
{++count;if(oneLine&&!exceptionToOneLineRule)
{var oldWidth=parseInt(oTextBoxOuterDiv.style.width,10);oTextBoxInnerDiv.style.width=""+oldWidth*Math.pow(1.05,count)+"px";}
else
{var scale=Math.max(0.95,minimum/smallestFontSize);for(i=0;i<aParaChildren.length;i++)
{oParagraphDiv=aParaChildren[i];var paraFontSize=elementFontSize(oParagraphDiv)*scale;var paraLineHeight=elementLineHeight(oParagraphDiv)*scale;for(j=0;j<oParagraphDiv.childNodes.length;j++)
{oSpan=oParagraphDiv.childNodes[j];if((oSpan.nodeName=="SPAN")||(oSpan.nodeName=="A"))
{var spanLineHeight=elementLineHeight(oSpan)*scale;if(!isNaN(spanLineHeight))
{oSpan.style.lineHeight=spanLineHeight+UNITS;}
var spanFontSize=elementFontSize(oSpan)*scale;if(!isNaN(spanFontSize))
{oSpan.style.fontSize=spanFontSize+UNITS;smallestFontSize=Math.min(smallestFontSize,spanFontSize);}}}
if(!isNaN(paraLineHeight))
{oParagraphDiv.style.lineHeight=paraLineHeight+UNITS;}
if(!isNaN(paraFontSize))
{oParagraphDiv.style.fontSize=paraFontSize+UNITS;smallestFontSize=Math.min(smallestFontSize,paraFontSize);}}}
offsetHeight=oTextBoxInnerDiv.offsetHeight;}}
showAllListBulletImagesContainedBy(oTextBoxInnerDiv);}}}
function elementLineHeight(element)
{var lineHeight=MINIMUM_FONT;if(document.defaultView)
{var computedStyle=document.defaultView.getComputedStyle(element,null);if(computedStyle)
{lineHeight=computedStyle.getPropertyValue("line-height");}}
else if(element.currentStyle)
{lineHeight=element.currentStyle.lineHeight;}
if((UNITS.length===0)&&(lineHeight!=MINIMUM_FONT))
{UNITS=lineHeight.substring(lineHeight.length-2,lineHeight.length);}
return parseFloat(lineHeight);}
function adjustLineHeightIfTooBig(idOfElement)
{var oTextBoxInnerDiv;var oTextBoxOuterDiv=document.getElementById(idOfElement);if(oTextBoxOuterDiv)
{oTextBoxInnerDiv=getElementsByTagAndClassName(oTextBoxOuterDiv,"DIV","text-content")[0];if(oTextBoxInnerDiv)
{hideAllListBulletImagesContainedBy(oTextBoxInnerDiv);var offsetHeight=oTextBoxInnerDiv.offsetHeight;var specifiedHeight=offsetHeight;if(oTextBoxOuterDiv.style.height!=="")
{specifiedHeight=parseFloat(oTextBoxOuterDiv.style.height);}
if(offsetHeight>(specifiedHeight+HEIGHT_ERROR_MARGIN))
{var adjusted=true;var count=0;while((adjusted)&&(offsetHeight>(specifiedHeight+HEIGHT_ERROR_MARGIN))&&(count<10))
{adjusted=false;++count;var aParaChildren=getShrinkableParaDescendants(oTextBoxInnerDiv);for(i=0;i<aParaChildren.length;i++)
{var fontSize;var lineHeight;var oParagraphDiv=aParaChildren[i];fontSize=elementFontSize(oParagraphDiv);lineHeight=elementLineHeight(oParagraphDiv)*0.95;if(!isNaN(lineHeight)&&lineHeight>=(fontSize*1.1))
{oParagraphDiv.style.lineHeight=lineHeight+UNITS;adjusted=true;}
for(j=0;j<oParagraphDiv.childNodes.length;j++)
{var oSpan=oParagraphDiv.childNodes[j];if((oSpan.nodeName=="SPAN")||(oSpan.nodeName=="A"))
{fontSize=elementFontSize(oSpan);lineHeight=elementLineHeight(oSpan)*0.95;if(!isNaN(lineHeight)&&lineHeight>=(fontSize*1.1))
{oSpan.style.lineHeight=lineHeight+UNITS;adjusted=true;}}}}
offsetHeight=oTextBoxInnerDiv.offsetHeight;}}
showAllListBulletImagesContainedBy(oTextBoxInnerDiv);}}}
function isDiv(node)
{return(node.nodeType==Node.ELEMENT_NODE)&&(node.tagName=="DIV");}
function fixupAllMozInlineBlocks()
{detectBrowser();if(isFirefox||isCamino)
{var oInlineBlocks=getElementsByTagAndClassName(document.body,"DIV","inline-block");for(var i=0,inlineBlocksLength=oInlineBlocks.length;i<inlineBlocksLength;++i)
{var oInlineBlock=oInlineBlocks[i];var oInterposingDiv=document.createElement("div");oInterposingDiv.style.position="relative";oInterposingDiv.style.overflow="visible";for(var j=0,childNodesLength=oInlineBlock.childNodes.length;j<childNodesLength;++j)
{var oChildNode=oInlineBlock.childNodes[0];oInlineBlock.removeChild(oChildNode);oInterposingDiv.appendChild(oChildNode);}
oInlineBlock.appendChild(oInterposingDiv);}}}
function getWidthDefiningAncestor(elem)
{var ancestor=elem.up('[style~="width:"]');if(!ancestor)
{ancestor=$$('body')[0];}
return ancestor;}
function updateListOfIE7FloatsFix(div)
{var div=$(div);var floatValue=div.getStyle("float");if(floatValue=="left"||floatValue=="right")
{var commonAncestor=getWidthDefiningAncestor(div);var floatDescendants=commonAncestor.getElementsBySelector('[style~="float:"]');while(floatDescendants.length>0)
{var floatElem=floatDescendants.shift();floatValue=floatElem.getStyle("float");if(floatValue=="left"||floatValue=="right")
{var floatAncestor=getWidthDefiningAncestor(floatElem);if(floatAncestor===commonAncestor)
{if(!listOfIE7FloatsFix.include(floatElem))
{listOfIE7FloatsFix.push(floatElem);}}}}}}
function fixupFloatsIfIE7()
{detectBrowser();if(windowsInternetExplorer&&browserVersion==7)
{if(listOfIE7FloatsFix.length>0)
{var floatsToRestore=[];var floatElem;var displayStyle;while(listOfIE7FloatsFix.length>0)
{floatElem=listOfIE7FloatsFix.shift();displayStyle=floatElem.getStyle("display");floatElem.setStyle({"display":"none"});floatsToRestore.push({element:floatElem,displayStyle:displayStyle});}
while(floatsToRestore.length>0)
{var queueEntry=floatsToRestore.shift();floatElem=queueEntry.element;displayStyle=queueEntry.displayStyle;floatElem.setStyle({"display":displayStyle});}}}}
function performPostEffectsFixups()
{fixupAllMozInlineBlocks();fixupFloatsIfIE7();}
function reduceLeftMarginIfIE6(element)
{detectBrowser();if(windowsInternetExplorer&&browserVersion<7)
{$(element).style.marginLeft=px(parseFloat($(element).style.marginLeft||0)-1);}}
function reduceRightMarginIfIE6(element)
{detectBrowser();if(windowsInternetExplorer&&browserVersion<7)
{$(element).style.marginRight=px(parseFloat($(element).style.marginRight||0)-1);}}
if(Object.keys===undefined)
{Object.keys=function(obj)
{var result=[];for(attr in obj)
result.push(attr);return result;}}
Object.objectType=function(obj)
{var result=typeof obj;if(result=="object")
{if(obj.constructor==Array)
result="Array";}
return result;}
Array.prototype.contains=function(value)
{for(var i=0;i<this.length;++i)
{if(this[i]==value)
{return true;}}
return false;};Array.prototype.forEach=function(f)
{for(var i=0;i<this.length;++i)
{f(this[i]);}};Array.prototype.indexOf=function(value)
{for(var i=0;i<this.length;++i)
{if(this[i]==value)
{return i;}}
return null;};Array.prototype.isEqual=function(that)
{if(this.length==that.length)
{for(var i=0;i<this.length;++i)
{if(this[i]!=that[i])
return false;}
return true;}
return false;}
Array.prototype.minusArray=function(that)
{var i=0;while(i<this.length)
{if(that.contains(this[i]))
this.splice(i,1);else
++i;}}
String.stringWithFormat=function(format)
{var formatted="";var nextArgument=1;var formatPattern=/%((\d+)\$)?([%s])?/;while(true)
{foundIndex=format.search(formatPattern);if(foundIndex==-1)
{formatted+=format;break;}
if(foundIndex>0)
{formatted+=format.substring(0,foundIndex)}
var matchInfo=format.match(formatPattern);var formatCharacter=matchInfo[3];if(formatCharacter=="%")
{formatted+="%";}
else
{if(matchInfo[2])
{argumentNumber=parseInt(matchInfo[2]);}
else
{argumentNumber=nextArgument++;}
argument=(argumentNumber<arguments.length)?arguments[argumentNumber]:"";if(formatCharacter=="s")
{formatted+=argument;}}
format=format.substring(foundIndex+matchInfo[0].length);}
return formatted;}
String.prototype.hasSuffix=function(suffix)
{return this.slice(-1*suffix.length)==suffix;};String.prototype.hasPrefix=function(prefix)
{return this.substr(0,prefix.length)==prefix;}
String.prototype.lastPathComponent=function()
{return this.substr(this.lastIndexOf("/")+1);};String.prototype.stringByDeletingLastPathComponent=function()
{return this.substr(0,this.lastIndexOf("/"));};String.prototype.stringByDeletingPathExtension=function()
{var lastSeparatorIndex=this.lastIndexOf("/");var lastDotIndex=this.lastIndexOf(".");if((lastDotIndex>lastSeparatorIndex+1)&&lastDotIndex>0)
return this.slice(0,lastDotIndex);return this;}
String.prototype.stringByAppendingPathComponent=function(component)
{if(this.hasSuffix("/"))
{return this+component;}
return this+"/"+component;};String.prototype.stringByAppendingAsQueryString=function(parameters)
{var result=this;if(parameters)
{var prependChar="?";Object.keys(parameters).forEach(function(key)
{if(parameters.hasOwnProperty(key))
{result+=prependChar+escape(key)+"="+escape(parameters[key]);prependChar="&";}});}
return result;};String.prototype.stringByUnescapingXML=function()
{var str=this.replace(/&lt;/g,'<');str=str.replace(/&gt;/g,'>');str=str.replace(/&quot;/g,'"');str=str.replace(/&apos;/g,"'");str=str.replace(/&amp;/g,'&');return str;};String.prototype.stringByEscapingXML=function(escapeAdditionalCharacters)
{var str=this.replace(/&/g,'&amp;');str=str.replace(/</g,'&lt;');if(escapeAdditionalCharacters)
{str=str.replace(/>/g,'&gt;');str=str.replace(/"/g,'&quot;');str=str.replace(/'/g,'&apos;');}
return str;};String.prototype.stringByConvertingNewlinesToBreakTags=function()
{return this.replace(/\n\r|\n|\r/g,'<br />');};String.prototype.urlStringByDeletingQueryAndFragment=function()
{var result=this;var lastIndex=result.lastIndexOf("?");if(lastIndex>0)
return result.substr(0,lastIndex);lastIndex=result.lastIndexOf("#");if(lastIndex>0)
result=result.substr(0,lastIndex);return result;}
String.prototype.toRelativeURL=function(baseURL)
{var result=this;if(baseURL&&this.indexOf(baseURL)==0)
{var chop=baseURL.length;if(this.charAt(chop)=='/')
++chop;result=this.substring(chop);}
return result;}
String.prototype.toAbsoluteURL=function()
{var result=this;if(this.indexOf(":/")==-1)
{var pageURL=document.URL.urlStringByDeletingQueryAndFragment();var pathURL=pageURL.stringByDeletingLastPathComponent();result=pathURL.stringByAppendingPathComponent(this);}
return result;}
String.prototype.toRebasedURL=function(baseURL)
{return this.toRelativeURL(baseURL).toAbsoluteURL();}
String.prototype.replaceStringWithString=function(target,replacement,global)
{var result=this;while(true)
{var pos=result.indexOf(target);if(pos==-1)
break;result=result.substr(0,pos)+replacement+result.substr(pos+target.length);pos+=replacement.length;if(pos>=result.length||!global)
break;}
return result;}
var trace=function(){};function ajaxRequest(url,func,obj)
{if(window.XMLHttpRequest)
{var req=new XMLHttpRequest();}
else if(window.ActiveXObject)
{isIE=true;try
{req=new ActiveXObject("Msxml2.XMLHTTP");}
catch(e)
{req=new ActiveXObject("Microsoft.XMLHTTP");}}
if(func)
{req.onreadystatechange=function(){func(req,obj);}}
req.open('GET',url,true);req.setRequestHeader('X-Requested-With','XMLHttpRequest');if(req.overrideMimeType)
{req.overrideMimeType("text/xml");}
req.send(null);return false;}
function isAjaxRequestReady(req)
{var result=req.readyState==4&&(req.status==null||req.status==0||req.status==200);return result;}
function ajaxGetDocumentElement(req)
{var elem=null;if(req.responseXML.documentElement)
{elem=req.responseXML.documentElement;}
else
{var dom=new ActiveXObject("MSXML.DOMDocument");dom.loadXML(req.responseText);elem=dom.documentElement;}
return elem;}
function iWLog(str)
{if(window.console)
{window.console.log(str);}
else if(window.dump)
{window.dump(str+"\n");}}
function position(abs,left,top,width,height)
{var pos="";if(abs)
pos="position: absolute; ";var size="";if(width&&height)
size=' width: '+width+'px; height: '+height+'px;';return pos+'left: '+left+'px; top: '+top+'px;'+size;}
var gIWUtilsTransparentGifURL="";function setTransparentGifURL(url)
{if(gIWUtilsTransparentGifURL=="")
{gIWUtilsTransparentGifURL=url;}}
function transparentGifURL()
{(function(){return gIWUtilsTransparentGifURL!=""}).assert("Transparent image URL not set");return gIWUtilsTransparentGifURL;}
function imgMarkup(src,style,attributes,alt)
{var markup="";if(src)
{if(style==null)
{style="";}
if(attributes==null)
{attributes="";}
if(alt==null)
{alt="";}
detectBrowser();if(windowsInternetExplorer)
{style+=" filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+IEConvertURLForPNGFix(src)+"', sizingMethod='scale');";src=gIWUtilsTransparentGifURL;}
if(style.length>0)
{style=' style="'+style+'"';}
if(attributes.length>0)
{attributes=' '+attributes;}
if(alt.length>0)
{alt=' alt="'+alt.stringByEscapingXML(true)+'"';}
markup='<img src="'+src+'"'+style+attributes+alt+' />';}
return markup;}
function setImgSrc(imgElement,src)
{detectBrowser();if(windowsInternetExplorer&&src.slice(-4).toLowerCase()==".png")
{$(imgElement).setFilter('progid:DXImageTransform.Microsoft.AlphaImageLoader','src="'+IEConvertURLForPNGFix(src)+'", sizingMethod="scale"');imgElement.src=gIWUtilsTransparentGifURL;}
else
{imgElement.src=src;}}
function iWOpacity(opacity)
{var style="";detectBrowser();if(windowsInternetExplorer)
{style=" progid:DXImageTransform.Microsoft.Alpha(opacity="+opacity*100+"); ";}
else
{style=" opacity: "+opacity+"; ";}
return style;}
function getElementsByTagAndClassName(that,tagName,className)
{var elementsByClassAndTag=[];var elementsByClass=$(that).getElementsByClassName(className);if(tagName=='*')
{elementsByClassAndTag=elementsByClass;}
else
{tagName=tagName.toLowerCase();for(var i=0,len=elementsByClass.length;i<len;++i)
{if(elementsByClass[i].tagName.toLowerCase()==tagName)
{elementsByClassAndTag.push(elementsByClass[i]);}}}
return elementsByClassAndTag;}
function getArgs()
{var args=new Object();var query=location.search.substring(1);var pairs=query.split("&");for(var i=0;i<pairs.length;++i)
{var pair=pairs[i];var pos=pair.indexOf('=');if(pos>0)
{var argname=decodeURIComponent(pair.substring(0,pos));var value=decodeURIComponent(pair.substring(pos+1));args[argname]=value;}}
return args;}
function IWRange(location,length)
{this.setLocation(location);this.setLength(length);}
IWRange.prototype.length=function()
{return this.p_length;}
IWRange.prototype.setLength=function(length)
{this.p_length=parseFloat(length);}
IWRange.prototype.location=function()
{return this.p_location;}
IWRange.prototype.setLocation=function(location)
{this.p_location=parseFloat(location);}
IWRange.prototype.max=function()
{return this.location()+this.length();}
IWRange.prototype.min=function()
{return this.location();}
IWRange.prototype.shift=function(amount)
{this.setLocation(this.location()+amount);}
IWRange.prototype.containsLocation=function(location)
{return((location>=this.min())&&(location<this.max()));}
function IWPageRange(location,length)
{IWRange.apply(this,arguments);}
IWPageRange.prototype=new IWRange();IWPageRange.prototype.constructor=IWRange;IWPageRange.prototype.setMax=function(newMax)
{var maxLength=this.p_lengthForMax(newMax);this.setLocation(Math.max(newMax-maxLength,0))
this.setLength(newMax-this.location());}
IWPageRange.prototype.shift=function(amount)
{IWRange.prototype.shift.call(this,amount);this.setMax(this.max());}
IWPageRange.prototype.p_lengthForMax=function(max)
{return(max<=9)?5:3;}
function px(s)
{return s.toString()+"px";}
function depx(s)
{return parseInt(s||0);}
function globalOriginOfDivNode(div)
{(function(){return div!==null;}).assert("div must not be null");(function(){return div.offsetParent!==null;}).assert("div has null offset parent, maybe hidden?");var p=Position.cumulativeOffset(div);return new IWPoint(p[0],p[1]);}
function globalRectOfDivNode(div)
{var globalOrigin=globalOriginOfDivNode(div);var size=new IWSize(div.offsetWidth,div.offsetHeight);return new IWRect(globalOrigin,size);}
function pageSetBodyLayerResidentRectangle(divId,rectangle)
{var div=$(divId);if(div)
{if(window.bodyLayerResidents===undefined)
{window.bodyLayerResidents=new Hash({});}
if(rectangle===null)
{bodyLayerResidents.remove(divId);}
else
{bodyLayerResidents[divId]=rectangle;}
var desiredBottom=0;bodyLayerResidents.each(function(pair)
{var itemBottom=pair.value.origin.y+pair.value.size.height;desiredBottom=Math.max(desiredBottom,itemBottom);});var bodyLayer=$('body_layer');if(bodyLayer)
{var bodyLayerSpacer=bodyLayer.getElementsByClassName('spacer')[0];if(bodyLayerSpacer)
{var bodySpacerRect=globalRectOfDivNode(bodyLayerSpacer);var desiredHeight=desiredBottom-bodySpacerRect.origin.y;bodyLayerSpacer.style.height=px(desiredHeight);}}}}
function locationHRef()
{var result=window.location.href;if(result.match(/file:\/[^\/]/))
{result="file://"+result.substr(5);}
return result;}
function IWSize(width,height)
{this.width=width;this.height=height;}
function IWZeroSize()
{return new IWSize(0,0);}
IWSize.prototype.scale=function(hscale,vscale,round)
{if(round===undefined)round=false;if(vscale===undefined)vscale=hscale;var scaled=new IWSize(this.width*hscale,this.height*vscale);if(round)
{scaled.width=Math.round(scaled.width);scaled.height=Math.round(scaled.height);}
return scaled;}
IWSize.prototype.round=function()
{return this.scale(1,1,true);}
IWSize.prototype.toString=function()
{return"Size("+this.width+", "+this.height+")";}
IWSize.prototype.aspectRatio=function()
{return this.width/this.height;}
IWSize.prototype.subtractSize=function(s)
{return new IWSize(this.width-s.width,this.height-s.height);}
function IWPoint(x,y)
{this.x=x;this.y=y;}
function IWZeroPoint()
{return new IWPoint(0,0);}
IWPoint.prototype.scale=function(hscale,vscale,round)
{if(round===undefined)round=false;if(vscale===undefined)vscale=hscale;var scaled=new IWPoint(this.x*hscale,this.y*vscale);if(round)
{scaled.x=Math.round(scaled.x);scaled.y=Math.round(scaled.y);}
return scaled;}
IWPoint.prototype.round=function()
{return this.scale(1,1,true);}
IWPoint.prototype.offset=function(deltaX,deltaY)
{return new IWPoint(this.x+deltaX,this.y+deltaY);}
IWPoint.prototype.toString=function()
{return"Point("+this.x+", "+this.y+")";}
function IWRect()
{if(arguments.length==1)
{this.origin=arguments[0].origin;this.size=arguments[0].size;}
else if(arguments.length==2)
{this.origin=arguments[0];this.size=arguments[1];}
else if(arguments.length==4)
{this.origin=new IWPoint(arguments[0],arguments[1]);this.size=new IWSize(arguments[2],arguments[3]);}}
IWRect.prototype.clone=function()
{return new IWRect(this.origin.x,this.origin.y,this.size.width,this.size.height);}
function IWZeroRect()
{return new IWRect(0,0,0,0);}
IWRect.prototype.toString=function()
{return"Rect("+this.origin.toString()+", "+this.size.toString()+")";}
IWRect.prototype.maxX=function()
{return this.origin.x+this.size.width;}
IWRect.prototype.maxY=function()
{return this.origin.y+this.size.height;}
IWRect.prototype.union=function(that)
{var minX=Math.min(this.origin.x,that.origin.x);var minY=Math.min(this.origin.y,that.origin.y);var maxX=Math.max(this.maxX(),that.maxX());var maxY=Math.max(this.maxY(),that.maxY());return new IWRect(minX,minY,maxX-minX,maxY-minY);}
IWRect.prototype.intersection=function(that)
{var intersectionRect;var minX=Math.max(this.origin.x,that.origin.x);var minY=Math.max(this.origin.y,that.origin.y);var maxX=Math.min(this.maxX(),that.maxX());var maxY=Math.min(this.maxY(),that.maxY());if((minX<maxX)&&(minY<maxY))
{intersectionRect=new IWRect(minX,minY,maxX-minX,maxY-minY);}
else
{intersectionRect=new IWRect(0,0,0,0);}
return intersectionRect;}
IWRect.prototype.scale=function(hscale,vscale,round)
{if(round===undefined)round=false;if(vscale===undefined)vscale=hscale;var scaledOrigin=this.origin.scale(hscale,vscale,round);var scaledSize=this.size.scale(hscale,vscale,round);return new IWRect(scaledOrigin.x,scaledOrigin.y,scaledSize.width,scaledSize.height);}
IWRect.prototype.scaleSize=function(hscale,vscale,round)
{var scaledSize=this.size.scale(hscale,vscale,round);return new IWRect(this.origin.x,this.origin.y,scaledSize.width,scaledSize.height);}
IWRect.prototype.round=function()
{return this.scale(1,1,true);}
IWRect.prototype.offset=function(deltaX,deltaY)
{var offsetOrigin=this.origin.offset(deltaX,deltaY);return new IWRect(offsetOrigin.x,offsetOrigin.y,this.size.width,this.size.height);}
IWRect.prototype.offsetToOrigin=function()
{return this.offset(-this.origin.x,-this.origin.y)}
IWRect.prototype.centerPoint=function()
{return this.offset(this.size.width/2,this.size.height/2);}
IWRect.prototype.position=function()
{return"position: absolute; left: "+this.origin.x+"px; top: "+this.origin.y+"px; width: "+this.size.width+"px; height: "+this.size.height+"px; ";}
IWRect.prototype.clip=function()
{return"clip: rect("+this.origin.y+"px, "+this.maxX()+"px, "+this.maxY()+"px, "+this.origin.x+"px);";}
IWRect.prototype.toExtents=function()
{return new IWExtents(this.origin.x,this.origin.y,this.origin.x+this.size.width,this.origin.y+this.size.height);}
IWRect.prototype.paddingToRect=function(padded)
{return new IWPadding(this.origin.x-padded.origin.x,this.origin.y-padded.origin.y,padded.maxX()-this.maxX(),padded.maxY()-this.maxY());}
function IWExtents(left,top,right,bottom)
{this.left=left;this.top=top;this.right=right;this.bottom=bottom;}
IWExtents.prototype.clone=function()
{return new IWExtents(this.left,this.top,this.right,this.bottom);}
IWExtents.prototype.toRect=function()
{return new IWRect(this.left,this.top,this.right-this.left,this.bottom-this.top);}
function IWPadding(left,top,right,bottom)
{this.left=left;this.top=top;this.right=right;this.bottom=bottom;}
IWRect.prototype.fill=function(context)
{context.fillRect(this.origin.x,this.origin.y,this.size.width,this.size.height);}
IWRect.prototype.clear=function(context)
{context.clearRect(this.origin.x,this.origin.y,this.size.width,this.size.height);}
var NotificationCenter=new IWNotificationCenter();function IWNotificationCenter()
{this.mDispatchTable=new Array();}
IWNotificationCenter.prototype.addObserver=function(observer,method,name,object)
{this.p_observersForName(name).push(new Array(observer,method,object));}
IWNotificationCenter.prototype.removeObserver=function(observer)
{}
IWNotificationCenter.prototype.postNotification=function(notification)
{if(notification.name()!=null)
{var observersForName=this.mDispatchTable[notification.name()];this.p_postNotificationToObservers(notification,observersForName);}
var observersForNullName=this.mDispatchTable[null];this.p_postNotificationToObservers(notification,observersForNullName);}
IWNotificationCenter.prototype.postNotificationWithInfo=function(name,object,userInfo)
{this.postNotification(new IWNotification(name,object,userInfo));}
IWNotificationCenter.prototype.p_postNotificationToObservers=function(notification,observers)
{if(notification!=null&&observers!=null)
{for(var i=0;i<observers.length;i++)
{var observer=observers[i][0];var method=observers[i][1];var obj=observers[i][2];if(obj==null||obj===notification.object())
{method.call(observer,notification);}}}}
IWNotificationCenter.prototype.p_observersForName=function(name)
{if(this.mDispatchTable[name]===undefined)
{this.mDispatchTable[name]=new Array();}
return this.mDispatchTable[name];}
function IWNotification(name,object,userInfo)
{this.mName=name;this.mObject=object;this.mUserInfo=userInfo;}
IWNotification.prototype.name=function()
{return this.mName;}
IWNotification.prototype.object=function()
{return this.mObject;}
IWNotification.prototype.userInfo=function()
{return this.mUserInfo;}
var IWAssertionsEnabled=true;function IWAssert(func,description)
{if(IWAssertionsEnabled)
{function IWAssertionFailed(func,description)
{var formatter=new RegExp("return[\t\r ]*([^};\r]*)");var assertionText=func.toString().match(formatter)[1];var message='Assertion failed: "'+assertionText+'"';if(description!=null)
message+='.  '+description;iWLog(message);}
function IWCoreAssert(func,description)
{if(func()==false)
{IWAssertionFailed(func,description);}}
IWCoreAssert(function(){return typeof(func)=='function'},"IWAssert requires its first argument to be a function.  "+"Try wrapping your assertion in function(){return ... }");var result=func();IWCoreAssert(function(){return result!=null},"The result of your assertion function is null; "+"did you remember your return statement?");IWCoreAssert(function(){return result==true||result==false},"The result of your assertion function is neither true nor false");if(result==false)
{IWAssertionFailed(func,description);}}}
Function.prototype.assert=function(description)
{IWAssert(this,description);}
function makeAjaxHandler(callback)
{return function(request)
{if(request.readyState==4)
{callback(request,(request.status==200)||(request.status===undefined)||(request.status==0));}};}
function makeXmlHttpRequest(url,handler)
{var request=false;if(window.XMLHttpRequest)
{request=new XMLHttpRequest();}
else if(window.ActiveXObject)
{try
{request=new ActiveXObject("Msxml2.XMLHTTP");}
catch(e)
{request=new ActiveXObject("Microsoft.XMLHTTP");}}
if(!request)
{return false;}
if(handler)
{request.onreadystatechange=function(){handler(request);};}
try
{request.open('GET',url,true);request.setRequestHeader('X-Requested-With','XMLHttpRequest');request.setRequestHeader('If-Modified-Since','Wed, 15 Nov 1995 00:00:00 GMT');if(request.overrideMimeType)
{request.overrideMimeType('text/xml');}
request.send(null);}
catch(e)
{return false;}
return true;}
function getTextFromNode(node)
{var result="";if(node.nodeType==Node.ELEMENT_NODE)
{var children=node.childNodes;for(var i=0;i<children.length;++i)
{result=result+getTextFromNode(children[i]);}}
else if(node.nodeType==Node.TEXT_NODE)
{return node.nodeValue;}
return result;}
function getChildElementsByTagName(node,name)
{var result=[];for(var i=0;i<node.childNodes.length;++i)
{if(node.childNodes[i].tagName==name)
{result.push(node.childNodes[i]);}}
return result;}
function getChildElementsByTagNameNS(node,ns,nsPrefix,localName)
{var result=[];for(var i=0;i<node.childNodes.length;++i)
{var childNode=node.childNodes[i];if(childNode.namespaceURI)
{if(childNode.namespaceURI==ns)
{if(childNode.localName&&(childNode.localName==localName))
{result.push(childNode);}
else if(childNode.tagName==(nsPrefix+":"+localName))
{result.push(childNode);}}}
else
{if((ns=="")&&(childNode.tagName==localName))
{result.push(childNode);}}}
return result;}
function getFirstChildElementByTagNameNS(node,ns,nsPrefix,localName)
{var children=getChildElementsByTagNameNS(node,ns,nsPrefix,localName);if(children.length>0)
return children[0];return null;}
function getFirstChildElementByTagName(node,name)
{for(var i=0;i<node.childNodes.length;++i)
{if(node.childNodes[i].tagName==name)
{return node.childNodes[i];}}
return null;}
function getChildElementTextByTagName(node,tagName)
{var result="";if(node!==null)
{var children=getChildElementsByTagName(node,tagName);if(children.length>1)
{throw"MultipleResults";}
if(children.length==1)
{result=getTextFromNode(children[0]);}}
return result;}
function getChildElementTextByTagNameNS(node,ns,nsPrefix,localName)
{var result="";if(node)
{var children=getChildElementsByTagNameNS(node,ns,nsPrefix,localName);if(children.length>1)
throw"MultipleResults";if(children.length==1)
{result=getTextFromNode(children[0]);}}
return result;}
function getChildElements(node)
{var result=[];for(var i=0;i<node.childNodes.length;++i)
{var child=node.childNodes[i];if(child.nodeType==Node.ELEMENT_NODE)
result.push(child);}
return result;}
function adjustNodeIds(node,suffix)
{var undefined;if(node.id!="")
{node.id+=("$"+suffix);}
var childElements=getChildElements(node);for(var i=0;i<childElements.length;++i)
{adjustNodeIds(childElements[i],suffix);}}
function removeAllChildNodes(node)
{while(node.childNodes.length>0)
{node.removeChild(node.childNodes[0]);}}
function nodeIsChildOf(node,ancestor)
{if(node)
{if(node.parentNode==ancestor)
return true;else
return nodeIsChildOf(node.parentNode,ancestor)}
return false;}
function substituteSpans(parentNode,replacements)
{Object.keys(replacements).forEach(function(key)
{var spans=getElementsByTagAndClassName(parentNode,"span",key);spans.forEach(function(node)
{var contentType=replacements[key][0];var newContent=replacements[key][1];if(contentType=="text")
{removeAllChildNodes(node);node.appendChild(document.createTextNode(newContent));}
else if(contentType=="html")
{node.innerHTML=newContent;}});});}
var Prototype={Version:'1.5.0',BrowserFeatures:{XPath:!!document.evaluate},ScriptFragment:'(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)',emptyFunction:function(){},K:function(x){return x}}
var Class={create:function(){return function(){this.initialize.apply(this,arguments);}}}
var Abstract=new Object();Object.extend=function(destination,source){for(var property in source){destination[property]=source[property];}
return destination;}
Object.extend(Object,{inspect:function(object){try{if(object===undefined)return'undefined';if(object===null)return'null';return object.inspect?object.inspect():object.toString();}catch(e){if(e instanceof RangeError)return'...';throw e;}},keys:function(object){var keys=[];for(var property in object)
keys.push(property);return keys;},values:function(object){var values=[];for(var property in object)
values.push(object[property]);return values;},clone:function(object){return Object.extend({},object);}});Function.prototype.bind=function(){var __method=this,args=$A(arguments),object=args.shift();return function(){return __method.apply(object,args.concat($A(arguments)));}}
Function.prototype.bindAsEventListener=function(object){var __method=this,args=$A(arguments),object=args.shift();return function(event){return __method.apply(object,[(event||window.event)].concat(args).concat($A(arguments)));}}
Object.extend(Number.prototype,{toColorPart:function(){var digits=this.toString(16);if(this<16)return'0'+digits;return digits;},succ:function(){return this+1;},times:function(iterator){$R(0,this,true).each(iterator);return this;}});var Try={these:function(){var returnValue;for(var i=0,length=arguments.length;i<length;i++){var lambda=arguments[i];try{returnValue=lambda();break;}catch(e){}}
return returnValue;}}
var PeriodicalExecuter=Class.create();PeriodicalExecuter.prototype={initialize:function(callback,frequency){this.callback=callback;this.frequency=frequency;this.currentlyExecuting=false;this.registerCallback();},registerCallback:function(){this.timer=setInterval(this.onTimerEvent.bind(this),this.frequency*1000);},stop:function(){if(!this.timer)return;clearInterval(this.timer);this.timer=null;},onTimerEvent:function(){if(!this.currentlyExecuting){try{this.currentlyExecuting=true;this.callback(this);}finally{this.currentlyExecuting=false;}}}}
String.interpret=function(value){return value==null?'':String(value);}
Object.extend(String.prototype,{gsub:function(pattern,replacement){var result='',source=this,match;replacement=arguments.callee.prepareReplacement(replacement);while(source.length>0){if(match=source.match(pattern)){result+=source.slice(0,match.index);result+=String.interpret(replacement(match));source=source.slice(match.index+match[0].length);}else{result+=source,source='';}}
return result;},sub:function(pattern,replacement,count){replacement=this.gsub.prepareReplacement(replacement);count=count===undefined?1:count;return this.gsub(pattern,function(match){if(--count<0)return match[0];return replacement(match);});},scan:function(pattern,iterator){this.gsub(pattern,iterator);return this;},truncate:function(length,truncation){length=length||30;truncation=truncation===undefined?'...':truncation;return this.length>length?this.slice(0,length-truncation.length)+truncation:this;},strip:function(){return this.replace(/^\s+/,'').replace(/\s+$/,'');},stripTags:function(){return this.replace(/<\/?[^>]+>/gi,'');},stripScripts:function(){return this.replace(new RegExp(Prototype.ScriptFragment,'img'),'');},extractScripts:function(){var matchAll=new RegExp(Prototype.ScriptFragment,'img');var matchOne=new RegExp(Prototype.ScriptFragment,'im');return(this.match(matchAll)||[]).map(function(scriptTag){return(scriptTag.match(matchOne)||['',''])[1];});},evalScripts:function(){return this.extractScripts().map(function(script){return eval(script)});},escapeHTML:function(){var div=document.createElement('div');var text=document.createTextNode(this);div.appendChild(text);return div.innerHTML;},unescapeHTML:function(){var div=document.createElement('div');div.innerHTML=this.stripTags();return div.childNodes[0]?(div.childNodes.length>1?$A(div.childNodes).inject('',function(memo,node){return memo+node.nodeValue}):div.childNodes[0].nodeValue):'';},toQueryParams:function(separator){var match=this.strip().match(/([^?#]*)(#.*)?$/);if(!match)return{};return match[1].split(separator||'&').inject({},function(hash,pair){if((pair=pair.split('='))[0]){var name=decodeURIComponent(pair[0]);var value=pair[1]?decodeURIComponent(pair[1]):undefined;if(hash[name]!==undefined){if(hash[name].constructor!=Array)
hash[name]=[hash[name]];if(value)hash[name].push(value);}
else hash[name]=value;}
return hash;});},toArray:function(){return this.split('');},succ:function(){return this.slice(0,this.length-1)+
String.fromCharCode(this.charCodeAt(this.length-1)+1);},camelize:function(){var parts=this.split('-'),len=parts.length;if(len==1)return parts[0];var camelized=this.charAt(0)=='-'?parts[0].charAt(0).toUpperCase()+parts[0].substring(1):parts[0];for(var i=1;i<len;i++)
camelized+=parts[i].charAt(0).toUpperCase()+parts[i].substring(1);return camelized;},capitalize:function(){return this.charAt(0).toUpperCase()+this.substring(1).toLowerCase();},underscore:function(){return this.gsub(/::/,'/').gsub(/([A-Z]+)([A-Z][a-z])/,'#{1}_#{2}').gsub(/([a-z\d])([A-Z])/,'#{1}_#{2}').gsub(/-/,'_').toLowerCase();},dasherize:function(){return this.gsub(/_/,'-');},inspect:function(useDoubleQuotes){var escapedString=this.replace(/\\/g,'\\\\');if(useDoubleQuotes)
return'"'+escapedString.replace(/"/g,'\\"')+'"';else
return"'"+escapedString.replace(/'/g,'\\\'')+"'";}});String.prototype.gsub.prepareReplacement=function(replacement){if(typeof replacement=='function')return replacement;var template=new Template(replacement);return function(match){return template.evaluate(match)};}
String.prototype.parseQuery=String.prototype.toQueryParams;var Template=Class.create();Template.Pattern=/(^|.|\r|\n)(#\{(.*?)\})/;Template.prototype={initialize:function(template,pattern){this.template=template.toString();this.pattern=pattern||Template.Pattern;},evaluate:function(object){return this.template.gsub(this.pattern,function(match){var before=match[1];if(before=='\\')return match[2];return before+String.interpret(object[match[3]]);});}}
var $break=new Object();var $continue=new Object();var Enumerable={each:function(iterator){var index=0;try{this._each(function(value){try{iterator(value,index++);}catch(e){if(e!=$continue)throw e;}});}catch(e){if(e!=$break)throw e;}
return this;},eachSlice:function(number,iterator){var index=-number,slices=[],array=this.toArray();while((index+=number)<array.length)
slices.push(array.slice(index,index+number));return slices.map(iterator);},all:function(iterator){var result=true;this.each(function(value,index){result=result&&!!(iterator||Prototype.K)(value,index);if(!result)throw $break;});return result;},any:function(iterator){var result=false;this.each(function(value,index){if(result=!!(iterator||Prototype.K)(value,index))
throw $break;});return result;},collect:function(iterator){var results=[];this.each(function(value,index){results.push((iterator||Prototype.K)(value,index));});return results;},detect:function(iterator){var result;this.each(function(value,index){if(iterator(value,index)){result=value;throw $break;}});return result;},findAll:function(iterator){var results=[];this.each(function(value,index){if(iterator(value,index))
results.push(value);});return results;},grep:function(pattern,iterator){var results=[];this.each(function(value,index){var stringValue=value.toString();if(stringValue.match(pattern))
results.push((iterator||Prototype.K)(value,index));})
return results;},include:function(object){var found=false;this.each(function(value){if(value==object){found=true;throw $break;}});return found;},inGroupsOf:function(number,fillWith){fillWith=fillWith===undefined?null:fillWith;return this.eachSlice(number,function(slice){while(slice.length<number)slice.push(fillWith);return slice;});},inject:function(memo,iterator){this.each(function(value,index){memo=iterator(memo,value,index);});return memo;},invoke:function(method){var args=$A(arguments).slice(1);return this.map(function(value){return value[method].apply(value,args);});},max:function(iterator){var result;this.each(function(value,index){value=(iterator||Prototype.K)(value,index);if(result==undefined||value>=result)
result=value;});return result;},min:function(iterator){var result;this.each(function(value,index){value=(iterator||Prototype.K)(value,index);if(result==undefined||value<result)
result=value;});return result;},partition:function(iterator){var trues=[],falses=[];this.each(function(value,index){((iterator||Prototype.K)(value,index)?trues:falses).push(value);});return[trues,falses];},pluck:function(property){var results=[];this.each(function(value,index){results.push(value[property]);});return results;},reject:function(iterator){var results=[];this.each(function(value,index){if(!iterator(value,index))
results.push(value);});return results;},sortBy:function(iterator){return this.map(function(value,index){return{value:value,criteria:iterator(value,index)};}).sort(function(left,right){var a=left.criteria,b=right.criteria;return a<b?-1:a>b?1:0;}).pluck('value');},toArray:function(){return this.map();},zip:function(){var iterator=Prototype.K,args=$A(arguments);if(typeof args.last()=='function')
iterator=args.pop();var collections=[this].concat(args).map($A);return this.map(function(value,index){return iterator(collections.pluck(index));});},size:function(){return this.toArray().length;},inspect:function(){return'#<Enumerable:'+this.toArray().inspect()+'>';}}
Object.extend(Enumerable,{map:Enumerable.collect,find:Enumerable.detect,select:Enumerable.findAll,member:Enumerable.include,entries:Enumerable.toArray});var $A=Array.from=function(iterable){if(!iterable)return[];if(iterable.toArray&&!(window.opera&&iterable.callee)){return iterable.toArray();}else{var results=[];for(var i=0,length=iterable.length;i<length;i++)
results.push(iterable[i]);return results;}}
Object.extend(Array.prototype,Enumerable);if(!Array.prototype._reverse)
Array.prototype._reverse=Array.prototype.reverse;Object.extend(Array.prototype,{_each:function(iterator){for(var i=0,length=this.length;i<length;i++)
iterator(this[i]);},clear:function(){this.length=0;return this;},first:function(){return this[0];},last:function(){return this[this.length-1];},compact:function(){return this.select(function(value){return value!=null;});},flatten:function(){return this.inject([],function(array,value){return array.concat(value&&value.constructor==Array?value.flatten():[value]);});},without:function(){var values=$A(arguments);return this.select(function(value){return!values.include(value);});},indexOf:function(object){for(var i=0,length=this.length;i<length;i++)
if(this[i]==object)return i;return-1;},reverse:function(inline){return(inline!==false?this:this.toArray())._reverse();},reduce:function(){return this.length>1?this:this[0];},uniq:function(){return this.inject([],function(array,value){return array.include(value)?array:array.concat([value]);});},clone:function(){return[].concat(this);},size:function(){return this.length;},inspect:function(){return'['+this.map(Object.inspect).join(', ')+']';}});Array.prototype.toArray=Array.prototype.clone;function $w(string){string=string.strip();return string?string.split(/\s+/):[];}
if(window.opera){Array.prototype.concat=function(){var array=[];for(var i=0,length=this.length;i<length;i++)array.push(this[i]);for(var i=0,length=arguments.length;i<length;i++){if(arguments[i].constructor==Array){for(var j=0,arrayLength=arguments[i].length;j<arrayLength;j++)
array.push(arguments[i][j]);}else{array.push(arguments[i]);}}
return array;}}
var Hash=function(obj){Object.extend(this,obj||{});};Object.extend(Hash,{toQueryString:function(obj){var parts=[];this.prototype._each.call(obj,function(pair){if(!pair.key)return;if(pair.value&&pair.value.constructor==Array){var values=pair.value.compact();if(values.length<2)pair.value=values.reduce();else{key=encodeURIComponent(pair.key);values.each(function(value){value=value!=undefined?encodeURIComponent(value):'';parts.push(key+'='+encodeURIComponent(value));});return;}}
if(pair.value==undefined)pair[1]='';parts.push(pair.map(encodeURIComponent).join('='));});return parts.join('&');}});Object.extend(Hash.prototype,Enumerable);Object.extend(Hash.prototype,{_each:function(iterator){for(var key in this){var value=this[key];if(value&&value==Hash.prototype[key])continue;var pair=[key,value];pair.key=key;pair.value=value;iterator(pair);}},keys:function(){return this.pluck('key');},values:function(){return this.pluck('value');},merge:function(hash){return $H(hash).inject(this,function(mergedHash,pair){mergedHash[pair.key]=pair.value;return mergedHash;});},remove:function(){var result;for(var i=0,length=arguments.length;i<length;i++){var value=this[arguments[i]];if(value!==undefined){if(result===undefined)result=value;else{if(result.constructor!=Array)result=[result];result.push(value)}}
delete this[arguments[i]];}
return result;},toQueryString:function(){return Hash.toQueryString(this);},inspect:function(){return'#<Hash:{'+this.map(function(pair){return pair.map(Object.inspect).join(': ');}).join(', ')+'}>';}});function $H(object){if(object&&object.constructor==Hash)return object;return new Hash(object);};ObjectRange=Class.create();Object.extend(ObjectRange.prototype,Enumerable);Object.extend(ObjectRange.prototype,{initialize:function(start,end,exclusive){this.start=start;this.end=end;this.exclusive=exclusive;},_each:function(iterator){var value=this.start;while(this.include(value)){iterator(value);value=value.succ();}},include:function(value){if(value<this.start)
return false;if(this.exclusive)
return value<this.end;return value<=this.end;}});var $R=function(start,end,exclusive){return new ObjectRange(start,end,exclusive);}
var Ajax={getTransport:function(){return Try.these(function(){return new XMLHttpRequest()},function(){return new ActiveXObject('Msxml2.XMLHTTP')},function(){return new ActiveXObject('Microsoft.XMLHTTP')})||false;},activeRequestCount:0}
Ajax.Responders={responders:[],_each:function(iterator){this.responders._each(iterator);},register:function(responder){if(!this.include(responder))
this.responders.push(responder);},unregister:function(responder){this.responders=this.responders.without(responder);},dispatch:function(callback,request,transport,json){this.each(function(responder){if(typeof responder[callback]=='function'){try{responder[callback].apply(responder,[request,transport,json]);}catch(e){}}});}};Object.extend(Ajax.Responders,Enumerable);Ajax.Responders.register({onCreate:function(){Ajax.activeRequestCount++;},onComplete:function(){Ajax.activeRequestCount--;}});Ajax.Base=function(){};Ajax.Base.prototype={setOptions:function(options){this.options={method:'post',asynchronous:true,contentType:'application/x-www-form-urlencoded',encoding:'UTF-8',parameters:''}
Object.extend(this.options,options||{});this.options.method=this.options.method.toLowerCase();if(typeof this.options.parameters=='string')
this.options.parameters=this.options.parameters.toQueryParams();}}
Ajax.Request=Class.create();Ajax.Request.Events=['Uninitialized','Loading','Loaded','Interactive','Complete'];Ajax.Request.prototype=Object.extend(new Ajax.Base(),{_complete:false,initialize:function(url,options){this.transport=Ajax.getTransport();this.setOptions(options);this.request(url);},request:function(url){this.url=url;this.method=this.options.method;var params=this.options.parameters;if(!['get','post'].include(this.method)){params['_method']=this.method;this.method='post';}
params=Hash.toQueryString(params);if(params&&/Konqueror|Safari|KHTML/.test(navigator.userAgent))params+='&_='
if(this.method=='get'&&params)
this.url+=(this.url.indexOf('?')>-1?'&':'?')+params;try{Ajax.Responders.dispatch('onCreate',this,this.transport);this.transport.open(this.method.toUpperCase(),this.url,this.options.asynchronous);if(this.options.asynchronous)
setTimeout(function(){this.respondToReadyState(1)}.bind(this),10);this.transport.onreadystatechange=this.onStateChange.bind(this);this.setRequestHeaders();var body=this.method=='post'?(this.options.postBody||params):null;this.transport.send(body);if(!this.options.asynchronous&&this.transport.overrideMimeType)
this.onStateChange();}
catch(e){this.dispatchException(e);}},onStateChange:function(){var readyState=this.transport.readyState;if(readyState>1&&!((readyState==4)&&this._complete))
this.respondToReadyState(this.transport.readyState);},setRequestHeaders:function(){var headers={'X-Requested-With':'XMLHttpRequest','X-Prototype-Version':Prototype.Version,'Accept':'text/javascript, text/html, application/xml, text/xml, */*'};if(this.method=='post'){headers['Content-type']=this.options.contentType+
(this.options.encoding?'; charset='+this.options.encoding:'');if(this.transport.overrideMimeType&&(navigator.userAgent.match(/Gecko\/(\d{4})/)||[0,2005])[1]<2005)
headers['Connection']='close';}
if(typeof this.options.requestHeaders=='object'){var extras=this.options.requestHeaders;if(typeof extras.push=='function')
for(var i=0,length=extras.length;i<length;i+=2)
headers[extras[i]]=extras[i+1];else
$H(extras).each(function(pair){headers[pair.key]=pair.value});}
for(var name in headers)
this.transport.setRequestHeader(name,headers[name]);},success:function(){return!this.transport.status||(this.transport.status>=200&&this.transport.status<300);},respondToReadyState:function(readyState){var state=Ajax.Request.Events[readyState];var transport=this.transport,json=this.evalJSON();if(state=='Complete'){try{this._complete=true;(this.options['on'+this.transport.status]||this.options['on'+(this.success()?'Success':'Failure')]||Prototype.emptyFunction)(transport,json);}catch(e){this.dispatchException(e);}
if((this.getHeader('Content-type')||'text/javascript').strip().match(/^(text|application)\/(x-)?(java|ecma)script(;.*)?$/i))
this.evalResponse();}
try{(this.options['on'+state]||Prototype.emptyFunction)(transport,json);Ajax.Responders.dispatch('on'+state,this,transport,json);}catch(e){this.dispatchException(e);}
if(state=='Complete'){this.transport.onreadystatechange=Prototype.emptyFunction;}},getHeader:function(name){try{return this.transport.getResponseHeader(name);}catch(e){return null}},evalJSON:function(){try{var json=this.getHeader('X-JSON');return json?eval('('+json+')'):null;}catch(e){return null}},evalResponse:function(){try{return eval(this.transport.responseText);}catch(e){this.dispatchException(e);}},dispatchException:function(exception){(this.options.onException||Prototype.emptyFunction)(this,exception);Ajax.Responders.dispatch('onException',this,exception);}});Ajax.Updater=Class.create();Object.extend(Object.extend(Ajax.Updater.prototype,Ajax.Request.prototype),{initialize:function(container,url,options){this.container={success:(container.success||container),failure:(container.failure||(container.success?null:container))}
this.transport=Ajax.getTransport();this.setOptions(options);var onComplete=this.options.onComplete||Prototype.emptyFunction;this.options.onComplete=(function(transport,param){this.updateContent();onComplete(transport,param);}).bind(this);this.request(url);},updateContent:function(){var receiver=this.container[this.success()?'success':'failure'];var response=this.transport.responseText;if(!this.options.evalScripts)response=response.stripScripts();if(receiver=$(receiver)){if(this.options.insertion)
new this.options.insertion(receiver,response);else
receiver.update(response);}
if(this.success()){if(this.onComplete)
setTimeout(this.onComplete.bind(this),10);}}});Ajax.PeriodicalUpdater=Class.create();Ajax.PeriodicalUpdater.prototype=Object.extend(new Ajax.Base(),{initialize:function(container,url,options){this.setOptions(options);this.onComplete=this.options.onComplete;this.frequency=(this.options.frequency||2);this.decay=(this.options.decay||1);this.updater={};this.container=container;this.url=url;this.start();},start:function(){this.options.onComplete=this.updateComplete.bind(this);this.onTimerEvent();},stop:function(){this.updater.options.onComplete=undefined;clearTimeout(this.timer);(this.onComplete||Prototype.emptyFunction).apply(this,arguments);},updateComplete:function(request){if(this.options.decay){this.decay=(request.responseText==this.lastText?this.decay*this.options.decay:1);this.lastText=request.responseText;}
this.timer=setTimeout(this.onTimerEvent.bind(this),this.decay*this.frequency*1000);},onTimerEvent:function(){this.updater=new Ajax.Updater(this.container,this.url,this.options);}});function $(element){if(arguments.length>1){for(var i=0,elements=[],length=arguments.length;i<length;i++)
elements.push($(arguments[i]));return elements;}
if(typeof element=='string')
element=document.getElementById(element);return Element.extend(element);}
if(Prototype.BrowserFeatures.XPath){document._getElementsByXPath=function(expression,parentElement){var results=[];var query=document.evaluate(expression,$(parentElement)||document,null,XPathResult.ORDERED_NODE_SNAPSHOT_TYPE,null);for(var i=0,length=query.snapshotLength;i<length;i++)
results.push(query.snapshotItem(i));return results;};}
document.getElementsByClassName=function(className,parentElement){if(Prototype.BrowserFeatures.XPath){var q=".//*[contains(concat(' ', @class, ' '), ' "+className+" ')]";return document._getElementsByXPath(q,parentElement);}else{var children=($(parentElement)||document.body).getElementsByTagName('*');var elements=[],child;for(var i=0,length=children.length;i<length;i++){child=children[i];if(Element.hasClassName(child,className))
elements.push(Element.extend(child));}
return elements;}};if(!window.Element)
var Element=new Object();Element.extend=function(element){if(!element||_nativeExtensions||element.nodeType==3)return element;if(!element._extended&&element.tagName&&element!=window){var methods=Object.clone(Element.Methods),cache=Element.extend.cache;if(element.tagName=='FORM')
Object.extend(methods,Form.Methods);if(['INPUT','TEXTAREA','SELECT'].include(element.tagName))
Object.extend(methods,Form.Element.Methods);Object.extend(methods,Element.Methods.Simulated);for(var property in methods){var value=methods[property];if(typeof value=='function'&&!(property in element))
element[property]=cache.findOrStore(value);}}
element._extended=true;return element;};Element.extend.cache={findOrStore:function(value){return this[value]=this[value]||function(){return value.apply(null,[this].concat($A(arguments)));}}};Element.Methods={visible:function(element){return $(element).style.display!='none';},toggle:function(element){element=$(element);Element[Element.visible(element)?'hide':'show'](element);return element;},hide:function(element){$(element).style.display='none';return element;},show:function(element){$(element).style.display='';return element;},remove:function(element){element=$(element);element.parentNode.removeChild(element);return element;},update:function(element,html){html=typeof html=='undefined'?'':html.toString();$(element).innerHTML=html.stripScripts();setTimeout(function(){html.evalScripts()},10);return element;},replace:function(element,html){element=$(element);html=typeof html=='undefined'?'':html.toString();if(element.outerHTML){element.outerHTML=html.stripScripts();}else{var range=element.ownerDocument.createRange();range.selectNodeContents(element);element.parentNode.replaceChild(range.createContextualFragment(html.stripScripts()),element);}
setTimeout(function(){html.evalScripts()},10);return element;},inspect:function(element){element=$(element);var result='<'+element.tagName.toLowerCase();$H({'id':'id','className':'class'}).each(function(pair){var property=pair.first(),attribute=pair.last();var value=(element[property]||'').toString();if(value)result+=' '+attribute+'='+value.inspect(true);});return result+'>';},recursivelyCollect:function(element,property){element=$(element);var elements=[];while(element=element[property])
if(element.nodeType==1)
elements.push(Element.extend(element));return elements;},ancestors:function(element){return $(element).recursivelyCollect('parentNode');},descendants:function(element){return $A($(element).getElementsByTagName('*'));},immediateDescendants:function(element){if(!(element=$(element).firstChild))return[];while(element&&element.nodeType!=1)element=element.nextSibling;if(element)return[element].concat($(element).nextSiblings());return[];},previousSiblings:function(element){return $(element).recursivelyCollect('previousSibling');},nextSiblings:function(element){return $(element).recursivelyCollect('nextSibling');},siblings:function(element){element=$(element);return element.previousSiblings().reverse().concat(element.nextSiblings());},match:function(element,selector){if(typeof selector=='string')
selector=new Selector(selector);return selector.match($(element));},up:function(element,expression,index){return Selector.findElement($(element).ancestors(),expression,index);},down:function(element,expression,index){return Selector.findElement($(element).descendants(),expression,index);},previous:function(element,expression,index){return Selector.findElement($(element).previousSiblings(),expression,index);},next:function(element,expression,index){return Selector.findElement($(element).nextSiblings(),expression,index);},getElementsBySelector:function(){var args=$A(arguments),element=$(args.shift());return Selector.findChildElements(element,args);},getElementsByClassName:function(element,className){return document.getElementsByClassName(className,element);},readAttribute:function(element,name){element=$(element);if(document.all&&!window.opera){var t=Element._attributeTranslations;if(t.values[name])return t.values[name](element,name);if(t.names[name])name=t.names[name];var attribute=element.attributes[name];if(attribute)return attribute.nodeValue;}
return element.getAttribute(name);},getHeight:function(element){return $(element).getDimensions().height;},getWidth:function(element){return $(element).getDimensions().width;},classNames:function(element){return new Element.ClassNames(element);},hasClassName:function(element,className){if(!(element=$(element)))return;var elementClassName=element.className;if(elementClassName.length==0)return false;if(elementClassName==className||elementClassName.match(new RegExp("(^|\\s)"+className+"(\\s|$)")))
return true;return false;},addClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element).add(className);return element;},removeClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element).remove(className);return element;},toggleClassName:function(element,className){if(!(element=$(element)))return;Element.classNames(element)[element.hasClassName(className)?'remove':'add'](className);return element;},observe:function(){Event.observe.apply(Event,arguments);return $A(arguments).first();},stopObserving:function(){Event.stopObserving.apply(Event,arguments);return $A(arguments).first();},cleanWhitespace:function(element){element=$(element);var node=element.firstChild;while(node){var nextNode=node.nextSibling;if(node.nodeType==3&&!/\S/.test(node.nodeValue))
element.removeChild(node);node=nextNode;}
return element;},empty:function(element){return $(element).innerHTML.match(/^\s*$/);},descendantOf:function(element,ancestor){element=$(element),ancestor=$(ancestor);while(element=element.parentNode)
if(element==ancestor)return true;return false;},scrollTo:function(element){element=$(element);var pos=Position.cumulativeOffset(element);window.scrollTo(pos[0],pos[1]);return element;},getStyle:function(element,style){element=$(element);if(['float','cssFloat'].include(style))
style=(typeof element.style.styleFloat!='undefined'?'styleFloat':'cssFloat');style=style.camelize();var value=element.style[style];if(!value){if(document.defaultView&&document.defaultView.getComputedStyle){var css=document.defaultView.getComputedStyle(element,null);value=css?css[style]:null;}else if(element.currentStyle){value=element.currentStyle[style];}}
if((value=='auto')&&['width','height'].include(style)&&(element.getStyle('display')!='none'))
value=element['offset'+style.capitalize()]+'px';if(window.opera&&['left','top','right','bottom'].include(style))
if(Element.getStyle(element,'position')=='static')value='auto';if(style=='opacity'){if(value)return parseFloat(value);if(value=(element.getStyle('filter')||'').match(/alpha\(opacity=(.*)\)/))
if(value[1])return parseFloat(value[1])/100;return 1.0;}
return value=='auto'?null:value;},setStyle:function(element,style){element=$(element);for(var name in style){var value=style[name];if(name=='opacity'){if(value==1){value=(/Gecko/.test(navigator.userAgent)&&!/Konqueror|Safari|KHTML/.test(navigator.userAgent))?0.999999:1.0;if(/MSIE/.test(navigator.userAgent)&&!window.opera)
element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'');}else if(value==''){if(/MSIE/.test(navigator.userAgent)&&!window.opera)
element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'');}else{if(value<0.00001)value=0;if(/MSIE/.test(navigator.userAgent)&&!window.opera)
element.style.filter=element.getStyle('filter').replace(/alpha\([^\)]*\)/gi,'')+'alpha(opacity='+value*100+')';}}else if(['float','cssFloat'].include(name))name=(typeof element.style.styleFloat!='undefined')?'styleFloat':'cssFloat';element.style[name.camelize()]=value;}
return element;},getDimensions:function(element){element=$(element);var display=$(element).getStyle('display');if(display!='none'&&display!=null)
return{width:element.offsetWidth,height:element.offsetHeight};var els=element.style;var originalVisibility=els.visibility;var originalPosition=els.position;var originalDisplay=els.display;els.visibility='hidden';els.position='absolute';els.display='block';var originalWidth=element.clientWidth;var originalHeight=element.clientHeight;els.display=originalDisplay;els.position=originalPosition;els.visibility=originalVisibility;return{width:originalWidth,height:originalHeight};},makePositioned:function(element){element=$(element);var pos=Element.getStyle(element,'position');if(pos=='static'||!pos){element._madePositioned=true;element.style.position='relative';if(window.opera){element.style.top=0;element.style.left=0;}}
return element;},undoPositioned:function(element){element=$(element);if(element._madePositioned){element._madePositioned=undefined;element.style.position=element.style.top=element.style.left=element.style.bottom=element.style.right='';}
return element;},makeClipping:function(element){element=$(element);if(element._overflow)return element;element._overflow=element.style.overflow||'auto';if((Element.getStyle(element,'overflow')||'visible')!='hidden')
element.style.overflow='hidden';return element;},undoClipping:function(element){element=$(element);if(!element._overflow)return element;element.style.overflow=element._overflow=='auto'?'':element._overflow;element._overflow=null;return element;}};Object.extend(Element.Methods,{childOf:Element.Methods.descendantOf});Element._attributeTranslations={};Element._attributeTranslations.names={colspan:"colSpan",rowspan:"rowSpan",valign:"vAlign",datetime:"dateTime",accesskey:"accessKey",tabindex:"tabIndex",enctype:"encType",maxlength:"maxLength",readonly:"readOnly",longdesc:"longDesc"};Element._attributeTranslations.values={_getAttr:function(element,attribute){return element.getAttribute(attribute,2);},_flag:function(element,attribute){return $(element).hasAttribute(attribute)?attribute:null;},style:function(element){return element.style.cssText.toLowerCase();},title:function(element){var node=element.getAttributeNode('title');return node.specified?node.nodeValue:null;}};Object.extend(Element._attributeTranslations.values,{href:Element._attributeTranslations.values._getAttr,src:Element._attributeTranslations.values._getAttr,disabled:Element._attributeTranslations.values._flag,checked:Element._attributeTranslations.values._flag,readonly:Element._attributeTranslations.values._flag,multiple:Element._attributeTranslations.values._flag});Element.Methods.Simulated={hasAttribute:function(element,attribute){var t=Element._attributeTranslations;attribute=t.names[attribute]||attribute;return $(element).getAttributeNode(attribute).specified;}};if(document.all&&!window.opera){Element.Methods.update=function(element,html){element=$(element);html=typeof html=='undefined'?'':html.toString();var tagName=element.tagName.toUpperCase();if(['THEAD','TBODY','TR','TD'].include(tagName)){var div=document.createElement('div');switch(tagName){case'THEAD':case'TBODY':div.innerHTML='<table><tbody>'+html.stripScripts()+'</tbody></table>';depth=2;break;case'TR':div.innerHTML='<table><tbody><tr>'+html.stripScripts()+'</tr></tbody></table>';depth=3;break;case'TD':div.innerHTML='<table><tbody><tr><td>'+html.stripScripts()+'</td></tr></tbody></table>';depth=4;}
$A(element.childNodes).each(function(node){element.removeChild(node)});depth.times(function(){div=div.firstChild});$A(div.childNodes).each(function(node){element.appendChild(node)});}else{element.innerHTML=html.stripScripts();}
setTimeout(function(){html.evalScripts()},10);return element;}};Object.extend(Element,Element.Methods);var _nativeExtensions=false;if(/Konqueror|Safari|KHTML/.test(navigator.userAgent))
['','Form','Input','TextArea','Select'].each(function(tag){var className='HTML'+tag+'Element';if(window[className])return;var klass=window[className]={};klass.prototype=document.createElement(tag?tag.toLowerCase():'div').__proto__;});Element.addMethods=function(methods){Object.extend(Element.Methods,methods||{});function copy(methods,destination,onlyIfAbsent){onlyIfAbsent=onlyIfAbsent||false;var cache=Element.extend.cache;for(var property in methods){var value=methods[property];if(!onlyIfAbsent||!(property in destination))
destination[property]=cache.findOrStore(value);}}
if(typeof HTMLElement!='undefined'){copy(Element.Methods,HTMLElement.prototype);copy(Element.Methods.Simulated,HTMLElement.prototype,true);copy(Form.Methods,HTMLFormElement.prototype);[HTMLInputElement,HTMLTextAreaElement,HTMLSelectElement].each(function(klass){copy(Form.Element.Methods,klass.prototype);});_nativeExtensions=true;}}
var Toggle=new Object();Toggle.display=Element.toggle;Abstract.Insertion=function(adjacency){this.adjacency=adjacency;}
Abstract.Insertion.prototype={initialize:function(element,content){this.element=$(element);this.content=content.stripScripts();if(this.adjacency&&this.element.insertAdjacentHTML){try{this.element.insertAdjacentHTML(this.adjacency,this.content);}catch(e){var tagName=this.element.tagName.toUpperCase();if(['TBODY','TR'].include(tagName)){this.insertContent(this.contentFromAnonymousTable());}else{throw e;}}}else{this.range=this.element.ownerDocument.createRange();if(this.initializeRange)this.initializeRange();this.insertContent([this.range.createContextualFragment(this.content)]);}
setTimeout(function(){content.evalScripts()},10);},contentFromAnonymousTable:function(){var div=document.createElement('div');div.innerHTML='<table><tbody>'+this.content+'</tbody></table>';return $A(div.childNodes[0].childNodes[0].childNodes);}}
var Insertion=new Object();Insertion.Before=Class.create();Insertion.Before.prototype=Object.extend(new Abstract.Insertion('beforeBegin'),{initializeRange:function(){this.range.setStartBefore(this.element);},insertContent:function(fragments){fragments.each((function(fragment){this.element.parentNode.insertBefore(fragment,this.element);}).bind(this));}});Insertion.Top=Class.create();Insertion.Top.prototype=Object.extend(new Abstract.Insertion('afterBegin'),{initializeRange:function(){this.range.selectNodeContents(this.element);this.range.collapse(true);},insertContent:function(fragments){fragments.reverse(false).each((function(fragment){this.element.insertBefore(fragment,this.element.firstChild);}).bind(this));}});Insertion.Bottom=Class.create();Insertion.Bottom.prototype=Object.extend(new Abstract.Insertion('beforeEnd'),{initializeRange:function(){this.range.selectNodeContents(this.element);this.range.collapse(this.element);},insertContent:function(fragments){fragments.each((function(fragment){this.element.appendChild(fragment);}).bind(this));}});Insertion.After=Class.create();Insertion.After.prototype=Object.extend(new Abstract.Insertion('afterEnd'),{initializeRange:function(){this.range.setStartAfter(this.element);},insertContent:function(fragments){fragments.each((function(fragment){this.element.parentNode.insertBefore(fragment,this.element.nextSibling);}).bind(this));}});Element.ClassNames=Class.create();Element.ClassNames.prototype={initialize:function(element){this.element=$(element);},_each:function(iterator){this.element.className.split(/\s+/).select(function(name){return name.length>0;})._each(iterator);},set:function(className){this.element.className=className;},add:function(classNameToAdd){if(this.include(classNameToAdd))return;this.set($A(this).concat(classNameToAdd).join(' '));},remove:function(classNameToRemove){if(!this.include(classNameToRemove))return;this.set($A(this).without(classNameToRemove).join(' '));},toString:function(){return $A(this).join(' ');}};Object.extend(Element.ClassNames.prototype,Enumerable);var Selector=Class.create();Selector.prototype={initialize:function(expression){this.params={classNames:[]};this.expression=expression.toString().strip();this.parseExpression();this.compileMatcher();},parseExpression:function(){function abort(message){throw'Parse error in selector: '+message;}
if(this.expression=='')abort('empty expression');var params=this.params,expr=this.expression,match,modifier,clause,rest;while(match=expr.match(/^(.*)\[([a-z0-9_:-]+?)(?:([~\|!]?=)(?:"([^"]*)"|([^\]\s]*)))?\]$/i)){params.attributes=params.attributes||[];params.attributes.push({name:match[2],operator:match[3],value:match[4]||match[5]||''});expr=match[1];}
if(expr=='*')return this.params.wildcard=true;while(match=expr.match(/^([^a-z0-9_-])?([a-z0-9_-]+)(.*)/i)){modifier=match[1],clause=match[2],rest=match[3];switch(modifier){case'#':params.id=clause;break;case'.':params.classNames.push(clause);break;case'':case undefined:params.tagName=clause.toUpperCase();break;default:abort(expr.inspect());}
expr=rest;}
if(expr.length>0)abort(expr.inspect());},buildMatchExpression:function(){var params=this.params,conditions=[],clause;if(params.wildcard)
conditions.push('true');if(clause=params.id)
conditions.push('element.readAttribute("id") == '+clause.inspect());if(clause=params.tagName)
conditions.push('element.tagName.toUpperCase() == '+clause.inspect());if((clause=params.classNames).length>0)
for(var i=0,length=clause.length;i<length;i++)
conditions.push('element.hasClassName('+clause[i].inspect()+')');if(clause=params.attributes){clause.each(function(attribute){var value='element.readAttribute('+attribute.name.inspect()+')';var splitValueBy=function(delimiter){return value+' && '+value+'.split('+delimiter.inspect()+')';}
switch(attribute.operator){case'=':conditions.push(value+' == '+attribute.value.inspect());break;case'~=':conditions.push(splitValueBy(' ')+'.include('+attribute.value.inspect()+')');break;case'|=':conditions.push(splitValueBy('-')+'.first().toUpperCase() == '+attribute.value.toUpperCase().inspect());break;case'!=':conditions.push(value+' != '+attribute.value.inspect());break;case'':case undefined:conditions.push('element.hasAttribute('+attribute.name.inspect()+')');break;default:throw'Unknown operator '+attribute.operator+' in selector';}});}
return conditions.join(' && ');},compileMatcher:function(){this.match=new Function('element','if (!element.tagName) return false; \
      element = $(element); \
      return '+this.buildMatchExpression());},findElements:function(scope){var element;if(element=$(this.params.id))
if(this.match(element))
if(!scope||Element.childOf(element,scope))
return[element];scope=(scope||document).getElementsByTagName(this.params.tagName||'*');var results=[];for(var i=0,length=scope.length;i<length;i++)
if(this.match(element=scope[i]))
results.push(Element.extend(element));return results;},toString:function(){return this.expression;}}
Object.extend(Selector,{matchElements:function(elements,expression){var selector=new Selector(expression);return elements.select(selector.match.bind(selector)).map(Element.extend);},findElement:function(elements,expression,index){if(typeof expression=='number')index=expression,expression=false;return Selector.matchElements(elements,expression||'*')[index||0];},findChildElements:function(element,expressions){return expressions.map(function(expression){return expression.match(/[^\s"]+(?:"[^"]*"[^\s"]+)*/g).inject([null],function(results,expr){var selector=new Selector(expr);return results.inject([],function(elements,result){return elements.concat(selector.findElements(result||element));});});}).flatten();}});function $$(){return Selector.findChildElements(document,$A(arguments));}
var Form={reset:function(form){$(form).reset();return form;},serializeElements:function(elements,getHash){var data=elements.inject({},function(result,element){if(!element.disabled&&element.name){var key=element.name,value=$(element).getValue();if(value!=undefined){if(result[key]){if(result[key].constructor!=Array)result[key]=[result[key]];result[key].push(value);}
else result[key]=value;}}
return result;});return getHash?data:Hash.toQueryString(data);}};Form.Methods={serialize:function(form,getHash){return Form.serializeElements(Form.getElements(form),getHash);},getElements:function(form){return $A($(form).getElementsByTagName('*')).inject([],function(elements,child){if(Form.Element.Serializers[child.tagName.toLowerCase()])
elements.push(Element.extend(child));return elements;});},getInputs:function(form,typeName,name){form=$(form);var inputs=form.getElementsByTagName('input');if(!typeName&&!name)return $A(inputs).map(Element.extend);for(var i=0,matchingInputs=[],length=inputs.length;i<length;i++){var input=inputs[i];if((typeName&&input.type!=typeName)||(name&&input.name!=name))
continue;matchingInputs.push(Element.extend(input));}
return matchingInputs;},disable:function(form){form=$(form);form.getElements().each(function(element){element.blur();element.disabled='true';});return form;},enable:function(form){form=$(form);form.getElements().each(function(element){element.disabled='';});return form;},findFirstElement:function(form){return $(form).getElements().find(function(element){return element.type!='hidden'&&!element.disabled&&['input','select','textarea'].include(element.tagName.toLowerCase());});},focusFirstElement:function(form){form=$(form);form.findFirstElement().activate();return form;}}
Object.extend(Form,Form.Methods);Form.Element={focus:function(element){$(element).focus();return element;},select:function(element){$(element).select();return element;}}
Form.Element.Methods={serialize:function(element){element=$(element);if(!element.disabled&&element.name){var value=element.getValue();if(value!=undefined){var pair={};pair[element.name]=value;return Hash.toQueryString(pair);}}
return'';},getValue:function(element){element=$(element);var method=element.tagName.toLowerCase();return Form.Element.Serializers[method](element);},clear:function(element){$(element).value='';return element;},present:function(element){return $(element).value!='';},activate:function(element){element=$(element);element.focus();if(element.select&&(element.tagName.toLowerCase()!='input'||!['button','reset','submit'].include(element.type)))
element.select();return element;},disable:function(element){element=$(element);element.disabled=true;return element;},enable:function(element){element=$(element);element.blur();element.disabled=false;return element;}}
Object.extend(Form.Element,Form.Element.Methods);var Field=Form.Element;var $F=Form.Element.getValue;Form.Element.Serializers={input:function(element){switch(element.type.toLowerCase()){case'checkbox':case'radio':return Form.Element.Serializers.inputSelector(element);default:return Form.Element.Serializers.textarea(element);}},inputSelector:function(element){return element.checked?element.value:null;},textarea:function(element){return element.value;},select:function(element){return this[element.type=='select-one'?'selectOne':'selectMany'](element);},selectOne:function(element){var index=element.selectedIndex;return index>=0?this.optionValue(element.options[index]):null;},selectMany:function(element){var values,length=element.length;if(!length)return null;for(var i=0,values=[];i<length;i++){var opt=element.options[i];if(opt.selected)values.push(this.optionValue(opt));}
return values;},optionValue:function(opt){return Element.extend(opt).hasAttribute('value')?opt.value:opt.text;}}
Abstract.TimedObserver=function(){}
Abstract.TimedObserver.prototype={initialize:function(element,frequency,callback){this.frequency=frequency;this.element=$(element);this.callback=callback;this.lastValue=this.getValue();this.registerCallback();},registerCallback:function(){setInterval(this.onTimerEvent.bind(this),this.frequency*1000);},onTimerEvent:function(){var value=this.getValue();var changed=('string'==typeof this.lastValue&&'string'==typeof value?this.lastValue!=value:String(this.lastValue)!=String(value));if(changed){this.callback(this.element,value);this.lastValue=value;}}}
Form.Element.Observer=Class.create();Form.Element.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){return Form.Element.getValue(this.element);}});Form.Observer=Class.create();Form.Observer.prototype=Object.extend(new Abstract.TimedObserver(),{getValue:function(){return Form.serialize(this.element);}});Abstract.EventObserver=function(){}
Abstract.EventObserver.prototype={initialize:function(element,callback){this.element=$(element);this.callback=callback;this.lastValue=this.getValue();if(this.element.tagName.toLowerCase()=='form')
this.registerFormCallbacks();else
this.registerCallback(this.element);},onElementEvent:function(){var value=this.getValue();if(this.lastValue!=value){this.callback(this.element,value);this.lastValue=value;}},registerFormCallbacks:function(){Form.getElements(this.element).each(this.registerCallback.bind(this));},registerCallback:function(element){if(element.type){switch(element.type.toLowerCase()){case'checkbox':case'radio':Event.observe(element,'click',this.onElementEvent.bind(this));break;default:Event.observe(element,'change',this.onElementEvent.bind(this));break;}}}}
Form.Element.EventObserver=Class.create();Form.Element.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){return Form.Element.getValue(this.element);}});Form.EventObserver=Class.create();Form.EventObserver.prototype=Object.extend(new Abstract.EventObserver(),{getValue:function(){return Form.serialize(this.element);}});if(!window.Event){var Event=new Object();}
Object.extend(Event,{KEY_BACKSPACE:8,KEY_TAB:9,KEY_RETURN:13,KEY_ESC:27,KEY_LEFT:37,KEY_UP:38,KEY_RIGHT:39,KEY_DOWN:40,KEY_DELETE:46,KEY_HOME:36,KEY_END:35,KEY_PAGEUP:33,KEY_PAGEDOWN:34,element:function(event){return event.target||event.srcElement;},isLeftClick:function(event){return(((event.which)&&(event.which==1))||((event.button)&&(event.button==1)));},pointerX:function(event){return event.pageX||(event.clientX+
(document.documentElement.scrollLeft||document.body.scrollLeft));},pointerY:function(event){return event.pageY||(event.clientY+
(document.documentElement.scrollTop||document.body.scrollTop));},stop:function(event){if(event.preventDefault){event.preventDefault();event.stopPropagation();}else{event.returnValue=false;event.cancelBubble=true;}},findElement:function(event,tagName){var element=Event.element(event);while(element.parentNode&&(!element.tagName||(element.tagName.toUpperCase()!=tagName.toUpperCase())))
element=element.parentNode;return element;},observers:false,_observeAndCache:function(element,name,observer,useCapture){if(!this.observers)this.observers=[];if(element.addEventListener){this.observers.push([element,name,observer,useCapture]);element.addEventListener(name,observer,useCapture);}else if(element.attachEvent){this.observers.push([element,name,observer,useCapture]);element.attachEvent('on'+name,observer);}},unloadCache:function(){if(!Event.observers)return;for(var i=0,length=Event.observers.length;i<length;i++){Event.stopObserving.apply(this,Event.observers[i]);Event.observers[i][0]=null;}
Event.observers=false;},observe:function(element,name,observer,useCapture){element=$(element);useCapture=useCapture||false;if(name=='keypress'&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||element.attachEvent))
name='keydown';Event._observeAndCache(element,name,observer,useCapture);},stopObserving:function(element,name,observer,useCapture){element=$(element);useCapture=useCapture||false;if(name=='keypress'&&(navigator.appVersion.match(/Konqueror|Safari|KHTML/)||element.detachEvent))
name='keydown';if(element.removeEventListener){element.removeEventListener(name,observer,useCapture);}else if(element.detachEvent){try{element.detachEvent('on'+name,observer);}catch(e){}}}});if(navigator.appVersion.match(/\bMSIE\b/))
Event.observe(window,'unload',Event.unloadCache,false);var Position={includeScrollOffsets:false,prepare:function(){this.deltaX=window.pageXOffset||document.documentElement.scrollLeft||document.body.scrollLeft||0;this.deltaY=window.pageYOffset||document.documentElement.scrollTop||document.body.scrollTop||0;},realOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.scrollTop||0;valueL+=element.scrollLeft||0;element=element.parentNode;}while(element);return[valueL,valueT];},cumulativeOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;element=element.offsetParent;}while(element);return[valueL,valueT];},positionedOffset:function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;element=element.offsetParent;if(element){if(element.tagName=='BODY')break;var p=Element.getStyle(element,'position');if(p=='relative'||p=='absolute')break;}}while(element);return[valueL,valueT];},offsetParent:function(element){if(element.offsetParent)return element.offsetParent;if(element==document.body)return element;while((element=element.parentNode)&&element!=document.body)
if(Element.getStyle(element,'position')!='static')
return element;return document.body;},within:function(element,x,y){if(this.includeScrollOffsets)
return this.withinIncludingScrolloffsets(element,x,y);this.xcomp=x;this.ycomp=y;this.offset=this.cumulativeOffset(element);return(y>=this.offset[1]&&y<this.offset[1]+element.offsetHeight&&x>=this.offset[0]&&x<this.offset[0]+element.offsetWidth);},withinIncludingScrolloffsets:function(element,x,y){var offsetcache=this.realOffset(element);this.xcomp=x+offsetcache[0]-this.deltaX;this.ycomp=y+offsetcache[1]-this.deltaY;this.offset=this.cumulativeOffset(element);return(this.ycomp>=this.offset[1]&&this.ycomp<this.offset[1]+element.offsetHeight&&this.xcomp>=this.offset[0]&&this.xcomp<this.offset[0]+element.offsetWidth);},overlap:function(mode,element){if(!mode)return 0;if(mode=='vertical')
return((this.offset[1]+element.offsetHeight)-this.ycomp)/element.offsetHeight;if(mode=='horizontal')
return((this.offset[0]+element.offsetWidth)-this.xcomp)/element.offsetWidth;},page:function(forElement){var valueT=0,valueL=0;var element=forElement;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;if(element.offsetParent==document.body)
if(Element.getStyle(element,'position')=='absolute')break;}while(element=element.offsetParent);element=forElement;do{if(!window.opera||element.tagName=='BODY'){valueT-=element.scrollTop||0;valueL-=element.scrollLeft||0;}}while(element=element.parentNode);return[valueL,valueT];},clone:function(source,target){var options=Object.extend({setLeft:true,setTop:true,setWidth:true,setHeight:true,offsetTop:0,offsetLeft:0},arguments[2]||{})
source=$(source);var p=Position.page(source);target=$(target);var delta=[0,0];var parent=null;if(Element.getStyle(target,'position')=='absolute'){parent=Position.offsetParent(target);delta=Position.page(parent);}
if(parent==document.body){delta[0]-=document.body.offsetLeft;delta[1]-=document.body.offsetTop;}
if(options.setLeft)target.style.left=(p[0]-delta[0]+options.offsetLeft)+'px';if(options.setTop)target.style.top=(p[1]-delta[1]+options.offsetTop)+'px';if(options.setWidth)target.style.width=source.offsetWidth+'px';if(options.setHeight)target.style.height=source.offsetHeight+'px';},absolutize:function(element){element=$(element);if(element.style.position=='absolute')return;Position.prepare();var offsets=Position.positionedOffset(element);var top=offsets[1];var left=offsets[0];var width=element.clientWidth;var height=element.clientHeight;element._originalLeft=left-parseFloat(element.style.left||0);element._originalTop=top-parseFloat(element.style.top||0);element._originalWidth=element.style.width;element._originalHeight=element.style.height;element.style.position='absolute';element.style.top=top+'px';element.style.left=left+'px';element.style.width=width+'px';element.style.height=height+'px';},relativize:function(element){element=$(element);if(element.style.position=='relative')return;Position.prepare();element.style.position='relative';var top=parseFloat(element.style.top||0)-(element._originalTop||0);var left=parseFloat(element.style.left||0)-(element._originalLeft||0);element.style.top=top+'px';element.style.left=left+'px';element.style.height=element._originalHeight;element.style.width=element._originalWidth;}}
if(/Konqueror|Safari|KHTML/.test(navigator.userAgent)){Position.cumulativeOffset=function(element){var valueT=0,valueL=0;do{valueT+=element.offsetTop||0;valueL+=element.offsetLeft||0;if(element.offsetParent==document.body)
if(Element.getStyle(element,'position')=='absolute')break;element=element.offsetParent;}while(element);return[valueL,valueT];}}
Element.addMethods();Element.addMethods({appendChildrenFromMarkup:function(element,markup)
{element=$(element);try
{detectBrowser();if(windowsInternetExplorer&&browserVersion==7)
{element.insertAdjacentHTML("beforeEnd",markup);}
else
{var dummyDiv=$(document.createElement('div'));dummyDiv.innerHTML=markup;dummyDiv.immediateDescendants().each(function(child){element.appendChild(child);});}}
catch(e)
{}
return element;},ensureHasLayoutForIE:function(element)
{element=$(element);detectBrowser();if(windowsInternetExplorer&&browserVersion<7)
{if(!element.currentStyle.hasLayout)
{element.style.zoom=1;}}},setFilter:function(element,filterName,filterParams)
{element=$(element);var regex=new RegExp(filterName+'\\([^\\)]*\\);','gi');element.style.filter=element.style.filter.replace(regex,'')+
filterName+'('+filterParams+'); ';return element;},killFilter:function(element,filterName)
{element=$(element);var regex=new RegExp(filterName+'\\([^\\)]*\\);','gi');element.style.filter=element.style.filter.replace(regex,'');return element;}});function IWURL(urlString)
{try
{if((arguments.length==0)||(arguments.length==1&&(urlString==""||urlString==null)))
{this.p_initWithParts(null,null,null,null,null);}
else if(arguments.length==1)
{urlString.replace("file://localhost/","file:///");var urlParts=urlString.match(/^([A-Z]+):\/\/([^/]*)((\/[^?#]*)(\?([^#]*))?(#(.*))?)?/i);if(urlParts)
{this.p_initWithParts(urlParts[1],urlParts[2],urlParts[4]||"/",urlParts[6]||null,urlParts[8]||null);}
else
{urlParts=urlString.match(/^([^?#]*)(\?([^#]*))?(#(.*))?/);if(urlParts)
{this.p_initWithParts(null,null,urlParts[1],urlParts[3]||null,urlParts[5]||null);}
else
{}}}}
catch(e)
{print("Exception Parsing URL:"+e);}}
Object.extend(IWURL,{p_normalizePathComponents:function(components)
{var index=0;while(index<components.length)
{var component=components[index];if(component==""||component==".")
{components.splice(index,1);}
else if(component=="..")
{if(index>0)
{var previousComponent=components[index-1];if(previousComponent=="/")
{components.splice(index,1);}
else if(previousComponent!="..")
{components.splice(index-1,2);index-=1;}
else
{index+=1;}}
else
{index+=1;}}
else
{index+=1;}}
return components;}});Object.extend(IWURL.prototype,{p_initWithParts:function(inProtocol,inAuthority,inPath,inQuery,inFragment)
{this.mProtocol=inProtocol;this.mAuthority=inAuthority;this.mQuery=inQuery;this.mFragment=inFragment;this.mPathComponents=null;if(inPath)
{this.mPathComponents=inPath.split('/');if(this.mPathComponents[0]=="")
this.mPathComponents[0]='/';for(var i=0;i<this.mPathComponents.length;++i)
{this.mPathComponents[i]=decodeURIComponent(this.mPathComponents[i]);}
this.mPathComponents=IWURL.p_normalizePathComponents(this.mPathComponents);}},copy:function()
{var copy=new IWURL();copy.mProtocol=this.mProtocol;copy.mAuthority=this.mAuthority;copy.mQuery=this.mQuery;copy.mFragment=this.mFragment;copy.mPathComponents=null;if(this.mPathComponents)
{copy.mPathComponents=[];for(var i=0;i<this.mPathComponents.length;++i)
{copy.mPathComponents[i]=String(this.mPathComponents[i]);}}
return copy;},toString:function()
{var path="null";if(this.mPathComponents)
{path="";this.mPathComponents.each(function(component)
{if(path=="")
path="[ "+component;else
path+=", "+component;});if(path=="")
path="[]";else
path+=" ]";}
var result="{"+this.mProtocol+", "+this.mAuthority+", "+path+", "+this.mQuery+", "+this.mFragment+"}";return result;},isAbsolute:function()
{return(this.mPathComponents&&this.mPathComponents.length&&this.mPathComponents[0]=="/");},isRelative:function()
{return(this.mProtocol==null);},encodedPathComponents:function()
{var result=[];var index=0;while(index<this.mPathComponents.length)
{if((index==0)&&(this.mPathComponents[0]=="/"))
{result.push("/");}
else
{result.push(encodeURIComponent(this.mPathComponents[index]));}
index+=1;}
return result;},encodedPath:function()
{if(this.isAbsolute())
{return"/"+this.encodedPathComponents().slice(1).join("/");}
else
{return this.encodedPathComponents().join("/");}},toURLString:function()
{if(this.isRelative())
{return this.encodedPath()+
(this.mQuery?"?"+this.mQuery:"")+
(this.mFragment?"#"+this.mFragment:"");}
else
{return this.mProtocol+":"+"//"+this.mAuthority+this.encodedPath()+
(this.mQuery?"?"+this.mQuery:"")+
(this.mFragment?"#"+this.mFragment:"");}},isEqual:function(that)
{var pathMatches=true;if((this.mPathComponents)&&(that.mPathComponents)&&(this.mPathComponents.length==that.mPathComponents.length))
{for(var index=0;index<this.mPathComponents.length;++index)
{if(this.mPathComponents[index]!=that.mPathComponents[index])
{pathMatches=false;break;}}}
else
{pathMatches=false;}
return(this.mProtocol==that.mProtocol)&&(this.mAuthority==that.mAuthority)&&pathMatches&&(this.mQuery==that.mQuery)&&(this.mFragment==that.mFragment);},resolve:function(base)
{if(!this.isRelative())
return new IWURL(this.toURLString());var resolved=base.copy();resolved.mQuery=null;resolved.mFragment=null;if(resolved.mPathComponents==null)
{resolved.mPathComponents=[];}
this.mPathComponents.each(function(component)
{resolved.mPathComponents.push(component);});resolved.mPathComponents=IWURL.p_normalizePathComponents(resolved.mPathComponents);return resolved;},relativize:function(base)
{if(base&&(base.mPathComponents&&base.mPathComponents.length>0)&&(this.mProtocol==base.mProtocol)&&(this.mAuthority==base.mAuthority))
{var commonAncestorIndex=0;for(var index=0;index<Math.min(this.mPathComponents.length,base.mPathComponents.length);++index)
{if(this.mPathComponents[index]==base.mPathComponents[index])
commonAncestorIndex=index;else
break;}
var relativePath=[];for(var up=base.mPathComponents.length-1;up>commonAncestorIndex;--up)
{relativePath.push("..");}
for(var down=commonAncestorIndex+1;down<this.mPathComponents.length;++down)
{relativePath.push(this.mPathComponents[down]);}
var relativized=new IWURL();relativized.mPathComponents=IWURL.p_normalizePathComponents(relativePath);relativized.mQuery=this.mQuery;relativized.mFragment=this.mFragment;return relativized;}
else
{return this.copy();}}});