<?php

require_once 'PHPUnit.php';
require_once 'IsterXmlNode.php';
require_once 'IsterXmlExpatNonValid.php';

class TestXml01IsterXmlNode extends PHPUnit_TestCase
{

  function setUp()
  {
    $this->expat  = new IsterXmlExpatNonValid;
    $this->file   = 'simple.xml';
    $this->string = '<?xml version="1.0"?><root><node attr="val">name</node></root>';
  }

  function tearDown()
  {
  }


  function testAppend()
  {
    $root = new IsterXmlNode(ISTER_XML_TAG, 1, 'root');
    $node1 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $node2 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $root->append($node1);
    $root->append($node2);
    $result   = $root->hasChildren();
    $expected = 2;
    $this->assertTrue( $expected === $result );
  }


  function testAsXml()
  {
    $root = new IsterXmlNode(ISTER_XML_TAG, 1, 'root');
    $node1 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $node2 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $root->append($node1);
    $root->append($node2);
    $result = $root->asXML();
    $expected = '<root><node/><node/></root>';
    $this->assertFalse( strcmp($expected, $result) );
    //print $result;
    
  }

  function testGetRoot()
  {
    $doc = $this->getDoc();
    $root = $doc->getRoot();
    $result = $root->asXML();
    $expected = '<root><node/><node/></root>';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testHasChildren()
  {
    $doc  = $this->getDoc();
    $root = $doc->getRoot();
    $result = $root->hasChildren();
    $expected = 2;
    $this->assertTrue( $expected === $result );
    //print $root->asXML();
  }


  function testXPath()
  {
    //not implementd
    return true;
    $xpath = '/root/node';
    $doc   = $this->getDoc();
    $node  = $doc->xpath($xpath);
    $result   = is_object($node) ? $node->asXML() : 'nop';
    $expected = '<node/>';
    $this->assertFalse( strcmp($expected, $result) );
  }


  function testToSimpleXML()
  {
    $doc = $this->getDoc();
    $result   = get_class($doc->toSimpleXML());
    $expected = 'istersimplexmlelement';
    $this->assertFalse( strcmp($expected, $result) );
  }

  function testToDOM()
  {
    //not implemented
    return true;
    $this->expat->setSourceString($this->string);
    $this->expat->parse();
    $doc = $this->expat->getDocument();
    $result   = get_class($doc->toDOM());
    $expected = 'isterxmldomdocument';
    $this->assertFalse( strcmp($expected, $result) );
  }


  function getDoc()
  {
    $doc   = new IsterXmlNode(ISTER_XML_DOCUMENT, 0);
    $root  = new IsterXmlNode(ISTER_XML_TAG, 1, 'root');
    $node1 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $node2 = new IsterXmlNode(ISTER_XML_TAG, 2, 'node');
    $doc->append($root);
    $doc->append($node1);
    $doc->append($node2);
    return $doc;
  }
}

?>