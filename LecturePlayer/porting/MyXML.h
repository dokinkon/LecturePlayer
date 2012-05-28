#ifndef MyXMLH
#define MyXMLH

//#include <stdio.h>
#include <libxml/parser.h>
#include <libxml/tree.h>


class  MyXML
{
public:
    bool HasAttribute(xmlNodePtr node,xmlChar* str)
    {
        xmlChar* uri = xmlGetProp(node,str);
        if(uri==NULL)
            return false;
        else
            return true;
    }

    xmlChar* GetAttribute(xmlNodePtr node,xmlChar* str)
    {
        xmlChar* uri = xmlGetProp(node,str);
        return uri;
    }

//look for a hierarchy
     xmlNodePtr FindChildNode(xmlNodePtr node,xmlChar* str)
    {
        xmlNodePtr cur = node->xmlChildrenNode;
	     while (cur != NULL) {
	         if ((!xmlStrcmp(cur->name, str))) {
		          return cur;
 	                      }
	         cur = cur->next;
	            }
        return NULL;
    }

//count for a hierarchy
    int CountChildNode(xmlNodePtr node)
    {
        int number=0;

        xmlNodePtr cur = node->xmlChildrenNode;
	     while (cur != NULL) {
	         if (cur->type == XML_ELEMENT_NODE){
                number++;
	         }
	         cur = cur->next;
        }
        return number;
    }
//count for a hierarchy of the child list(testing)
    int CountNode(xmlNodePtr node)
    {
        int number=0;

        xmlNodePtr cur = node;
	     while (cur != NULL) {
	         if (cur->type == XML_ELEMENT_NODE){
                number++;
	         }
	         cur = cur->next;
        }
        return number;
    }

//return find child by index
    xmlNodePtr FindChildIndex(xmlNodePtr node,int index)  //start from 0
    {
        int count = index;
        xmlNodePtr cur = node->xmlChildrenNode;
	     while (count>=0) {
	         if (cur->type == XML_ELEMENT_NODE){
                 count--;
            }
            cur = cur->next;
	     }
        return cur->prev;
    }
//return find child by index in the list(testing)
    xmlNodePtr FindIndex(xmlNodePtr node,int index) //start from 0
    {
        int count = index;
        xmlNodePtr cur = node;
	    while (count>=0) {
	         if (cur->type == XML_ELEMENT_NODE){
                 count--;
            }
            cur = cur->next;
	     }
        return cur->prev;
    }

};

#endif
