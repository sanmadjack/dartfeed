import 'package:xml/xml.dart' as xml;
import 'package:intl/intl.dart';

const String headElementName = "head";
const String bodyElementName = "body";
const String outlineElementName = "outline";

OpmlDocument parse(String input) {
  xml.XmlDocument doc = xml.parse(input);
  return new OpmlDocument(doc);
}

class OpmlDocument {
  final xml.XmlDocument _xmlDoc;

  final OpmlHeaderNode header;
  final OpmlBodyNode body;

  OpmlDocument(this._xmlDoc):
        this.header = new OpmlHeaderNode(_findChildElement(_xmlDoc.root.firstChild,headElementName)),
        this.body = new OpmlBodyNode(_findChildElement(_xmlDoc.root.firstChild,bodyElementName))
  {
  }
}

class OpmlHeaderNode {
  final xml.XmlElement _node;


  String get title {
    return _getNodeText(_node,"title");
  }
  void set title(String input) {
    return _setNodeText(_node,"title",input);
  }
  String get ownerName {
    return _getNodeText(_node,"ownerName");
  }
  void set ownerName(String input) {
    return _setNodeText(_node,"ownerName",input);
  }
  String get ownerEmail {
    return _getNodeText(_node,"ownerEmail");
  }
  void set ownerEmail(String input) {
    return _setNodeText(_node,"ownerEmail",input);
  }
  DateTime get dateCreated {
    return _getNodeDate(_node,"dateCreated");
  }
  void set dateCreated(DateTime input) {
    return _setNodeDate(_node,"dateCreated",input);
  }
  DateTime get dateModified {
    return _getNodeDate(_node,"dateModified");
  }
  void set dateModified(DateTime input) {
    return _setNodeDate(_node,"dateModified",input);
  }

  //TODO: expansionState, vertScrollState, windowTop, windowLeft, windowBottom, windowRight

  OpmlHeaderNode(this._node) {
    if(this._node.name.toString().toLowerCase()!=headElementName)
      throw new Exception("Head element not found");
  }
}

class OpmlBodyNode {
  final xml.XmlElement _node;

  final Iterable<OpmlOutlineNode> children;

  OpmlBodyNode(this._node):
        children = _createOutlineList(_node) {
    if(this._node.name.toString().toLowerCase()!=bodyElementName)
      throw new Exception("Body element not found");

    if(children.isEmpty)
      throw new OpmlFormatException("No outline elements found under body");

  }
}

class OpmlOutlineNode {
  final xml.XmlElement _node;


  Iterable<OpmlOutlineNode> _children;
  Iterable<OpmlOutlineNode> get children {
    if(_children==null) {
      _children = _createOutlineList(_node);
    }
    return  _children;
  }

  OpmlOutlineNode(this._node) {

    if(this._node.name.toString().toLowerCase()!="outline")
      throw new OpmlFormatException("Not an outline element");

  }

  String getProperty(String name) {
    String output = _node.getAttribute(name);
    if(output==null) {
      return "";
    }
    return output;
  }
}

class OpmlFormatException implements Exception {
  String message;
  OpmlFormatException(this.message);

  @override
  String toString() {
    return message;
  }
}

Iterable<OpmlOutlineNode> _createOutlineList(xml.XmlElement parentNode) {
  var output = <OpmlOutlineNode>[];
  for(xml.XmlElement node in parentNode.findElements(outlineElementName)) {
    output.add(new OpmlOutlineNode(node));
  }
  return output;
}

xml.XmlElement _findChildElement(xml.XmlElement node, String name) {
  Iterable<xml.XmlElement> eles = node.findElements(name);
  if(eles.isEmpty)
    return null;

  return eles.first;
}

DateTime _getNodeDate(xml.XmlElement node, String name) {
  String output = _getNodeText(node, name);
  if(output=="") {
    return null;
  }
  return DateTime.parse(output);
}

void _setNodeDate(xml.XmlElement node, String name, DateTime input) {
  String value = input.toString();
  //TODO: Get the exact date format needed up and running here
  _setNodeText(node,name,value);
}

String _getNodeText(xml.XmlElement node, String name) {
  xml.XmlElement subNode = _findChildElement(node, name);
  if(subNode==null) {
    return "";
  }
  return subNode.text;
}

void _setNodeText(xml.XmlElement node, String name, String input) {
  xml.XmlElement subNode = _findChildElement(node, name);
  if(subNode==null) {
    subNode = new xml.XmlElement(new xml.XmlName("name"), null, null);
    node.children.add(subNode);
  }
  subNode.text = input;
}