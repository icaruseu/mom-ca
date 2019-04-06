package org.exist.xquery.functions.validation;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.xml.sax.Attributes;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;

public class XrxValidationHandler extends DefaultHandler {

	private static String NODE_ELEMENT_START = "element-start";
	private static String NODE_ELEMENT_END = "element-end";
	
	// validation error report items
	private XrxValidationReport xrxValidationReport = null;
    private List<XrxValidationReportItem> validationReport = new ArrayList<XrxValidationReportItem>();
    private XrxValidationReportItem lastItem;
    
    // validation status
    private Throwable throwed = null;	
    
	// node ID
	private String currentNodeId = "";
	private int level = 0;
	private ArrayList<Integer> levelId = new ArrayList<Integer>();
	private String previousEventType = "";
	
	public void startElement(String uri, String localName, String qName, Attributes attributes) {
		
		level += 1;
		if(levelId.size() < level) {
			levelId.add(new Integer(1));
		} else {
			int lastPos = levelId.size() - 1;
			levelId.set(lastPos, new Integer(levelId.get(lastPos) + 1));
		}
		setCurrentNodeId();		
		previousEventType = NODE_ELEMENT_START;
		
		System.out.println(qName + " " + getCurrentNodeId());
	}
	
	public void endElement(String uri, String localName, String qName) {
		
		if(previousEventType == NODE_ELEMENT_END) levelId.remove(levelId.size() - 1);
		setCurrentNodeId();
		if(xrxValidationReport.getCurrentException() != null) 
			addItem( createValidationReportItem(xrxValidationReport.getCurrentLevel(), xrxValidationReport.getCurrentException()) );
		level -= 1;
		previousEventType = NODE_ELEMENT_END;
	}
	
	// validation report item list
    private void addItem(XrxValidationReportItem newItem) {
    	
        if (lastItem == null) {
            validationReport.add(newItem);
            lastItem = newItem;
        } else if (lastItem.getMessage().equals(newItem.getMessage())) {
            // Message is repeated
            lastItem.increaseRepeat();
        } else {
            validationReport.add(newItem);
            lastItem = newItem;
        }
    }
    
    private XrxValidationReportItem createValidationReportItem(int type, SAXParseException exception) {
        
        XrxValidationReportItem vri = new XrxValidationReportItem();
        vri.setType(type);
        vri.setLineNumber(exception.getLineNumber());
        vri.setColumnNumber(exception.getColumnNumber());
        vri.setMessage(exception.getMessage());
        vri.setPublicId(exception.getPublicId());
        vri.setSystemId(exception.getSystemId());
        vri.setNodeId(getCurrentNodeId());
        return vri;
    }
    
    public List getValidationReportItemList() {
    	
        return validationReport;
    }
    
    public void setXrxValidationReport(XrxValidationReport report) {
    	
    	xrxValidationReport = report;
    }

    // validation status
    public boolean isValid() {
    	
        return( (validationReport.size()==0) && (throwed==null) );
    }
    
	// node ID
	public String getCurrentNodeId() {
		
		return currentNodeId;
	}
	
	private void setCurrentNodeId() {
		
		String idString = "";
		Iterator<Integer> iter = levelId.iterator();
		while(iter.hasNext()) {
			idString += String.valueOf(iter.next());
			if(iter.hasNext()) idString += ".";
		}
		currentNodeId = idString;		
	}
}
