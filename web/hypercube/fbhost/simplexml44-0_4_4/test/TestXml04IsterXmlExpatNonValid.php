<?php

require_once 'PHPUnit.php';
require_once 'IsterXmlExpatNonValid.php';

class TestXml04IsterXmlExpatNonValid extends PHPUnit_TestCase
{

  function setUp()
  {
    $this->expat = new IsterXmlExpatNonValid;
    $this->file  = 'simple.xml';
  }

  function tearDown()
  {
  }


  function testParse()
  {
    $this->expat->setSourceFile($this->file);
    ob_start();
    $this->expat->parse();
    $ob = ob_get_contents();
    $result   = $ob ? '' : get_class($this->expat->getDocument());
    $expected = 'isterxmlnode';
    $this->assertFalse( strcmp($expected, $result) );
    if($ob)
      print $ob;
    ob_end_clean();
  }

  function testEntityDeclaration()
  {
    $xml = '<?xml version="1.0"?><!DOCTYPE Test SYSTEM "test.dtd" [<!ENTITY ent "foo">]><root></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc   = $this->expat->getDocument();
    $result = $doc->___entities['ent'];
    $expected = 'foo';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testNotationDeclaration()
  {
    $xml = '<?xml version="1.0"?><!DOCTYPE Test SYSTEM "test.dtd" [<!NOTATION handler SYSTEM "handler.sh" >]><root></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc   = $this->expat->getDocument();
    $result = $doc->___notations['handler']['sys'];
    $expected = 'handler.sh';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testTag()
  {
    $xml = '<?xml version="1.0"?><root></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $result = $doc->___c[1]->___t;
    $expected = ISTER_XML_TAG;
    $this->assertTrue( $expected === $result );
  }


  function testAttributes()
  {
    $xml = '<?xml version="1.0"?><root><node a1="1" a2="2"/></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $attr =  $doc->___c[1]->___c[0]->___a;
    $result = $attr['a1'] + $attr['a2'];
    $expected = 3;
    $this->assertTrue( $expected === $result );
  }

  function testCDATASection()
  {
    $xml = '<?xml version="1.0"?><root><![CDATA[<node/>]]></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $result = $doc->___c[1]->___c[1]->___t;
    $expected = ISTER_XML_CDATA;
    $this->assertTrue( $expected === $result );
  }

  function testComment()
  {
    $xml = '<?xml version="1.0"?><root><!-- comment -->></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $pi = $doc->___c[1]->___c[0];
    $result = $pi->___t;
    $expected = ISTER_XML_COMMENT;
    $this->assertTrue( $expected === $result );
  }

  function testPIparse()
  {
    $xml = '<?xml version="1.0"?><root><?PI data ?></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $pi = $doc->___c[1]->___c[0];
    $result = $pi->___t;
    $expected = ISTER_XML_PI;
    $this->assertTrue( $expected === $result );
  }

  function testPIrun()
  {
    $xml = '<?xml version="1.0"?><root><?PI data ?></root>';
    $expat = new PIRunner;
    $expat->setSourceString($xml);
    ob_start();
    $expat->parse();
    $result = trim(ob_get_contents());
    $expected = 'data';
    $this->assertFalse( strcmp($expected, $result) );
    ob_end_clean();
  }

  function testParsedEntity()
  {
    $xml = '<?xml version="1.0"?><!DOCTYPE Test SYSTEM "test.dtd" [<!ENTITY ent "<extra></extra><a></a>">]><root>&ent;</root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $root = $doc->getRoot();
    $result = $root->hasChildren();
    $expected = 2;
    $this->assertTrue( $expected === $result );
  }

  function testExternalEntity()
  {
    $xml = '<?xml version="1.0"?><!DOCTYPE Test SYSTEM "test.dtd" [<!ENTITY ext1 SYSTEM "ext1.xml">]><root>&ext1;</root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $root = $doc->getRoot();
    $result = preg_replace('/\s/', '', $root->asXML());
    $expected = '<root><movie><title>external</title><title>internal</title></movie></root>';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testNamespace()
  {
    $xml = '<?xml version="1.0"?><root xmlns="http://www.zero.ns" xmlns:ns="http://www.first.ns"><node attr="val">name</node><ns:node>x</ns:node></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $root = $doc->getRoot();
    $ns0  = $root->___c[0];
    $ns1  = $root->___c[1];
    $result  = $ns0->___ns == null ? 1 : 0;
    $result += $ns1->___ns == 'ns' ? 1 : 0;
    $result += $doc->___ns[0]    == 'http://www.zero.ns'  ? 1 : 0;
    $result += $doc->___ns['ns'] == 'http://www.first.ns' ? 1 : 0;
    $expected = 4;
    $this->assertTrue( $expected === $result );
  }

  function testStringBug1()
  {
    $xml = '<?xml version="1.0"?><root><node attr="val">name</node><node>x</node></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $result = $doc->asXML();
    $expected = $xml;
    $this->assertTrue( $expected == $result );
  }

  function testStringBug2()
  {
    $xml = '<?xml version="1.0"?><root><node attr="val">name</node> <node>x</node></root>';
    $this->expat->setSourceString($xml);
    $this->expat->parse();
    $doc  = $this->expat->getDocument();
    $result = $doc->asXML();
    $expected = $xml;
    $this->assertTrue( $expected == $result );
  }
  
  function testUnicode()
  {
	if(! function_exists('file_get_contents')) {
		print "missing function 'file_get_contents', skip testUnicode()\n";
		return true;
	}
	$file = 'unicode.xml';
	$this->expat->setSourceFile($file);
	$this->expat->parse();
	$doc = $this->expat->getDocument();
	$result   = $doc->asXML();
	$expected = file_get_contents($file);
	$this->assertFalse( (boolean) strcmp($expected, $result) );
  }

  //not implemented
  // function testXInclude()
  // {
    // $xml = '<?xml version="1.0" ? ><root></root>';
    // $this->expat->setSourceString($xml);
    // $this->expat->parse();
    // $this->expat->xinclude();
    // $doc  = $this->expat->getDocument();
    // $result = 'nop';
    // $expected = '';
    // $this->assertFalse( strcmp($expected, $result) );
  // }
}


class PIRunner extends IsterXmlExpatNonValid {

  function PIRunner()
  {
    parent::IsterXmlExpatNonValid();
  }


  function pi_run($target, $data)
  {
    if($target == 'PI')
      print $data;
    return true;
  }

}

?>