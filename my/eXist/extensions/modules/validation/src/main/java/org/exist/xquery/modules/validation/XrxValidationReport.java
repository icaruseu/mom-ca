package org.exist.xquery.functions.validation;

import org.xml.sax.ErrorHandler;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class XrxValidationReport implements ErrorHandler {
    
    // validation duration
    private long duration = -1L;
    private long start = -1L;
    private long stop = -1L;
    
    private SAXParseException currentException = null;
    private int currentLevel;
    
	@Override
	public void error(SAXParseException exception) throws SAXException {
		
		setCurrentException(exception);
		setCurrentLevel(XrxValidationReportItem.ERROR);
	}

	@Override
	public void fatalError(SAXParseException exception) throws SAXException {
		
		setCurrentException(exception);
		setCurrentLevel(XrxValidationReportItem.FATAL);
	}

	@Override
	public void warning(SAXParseException exception) throws SAXException {
		
		setCurrentException(exception);
		setCurrentLevel(XrxValidationReportItem.WARNING);
	}
    
	// getter
	public SAXParseException getCurrentException() {
		
		return currentException;
	}
	
	public int getCurrentLevel() {
		
		return currentLevel;
	}
	
	// setter
	public void setCurrentException(SAXParseException exception) {
		
		currentException = exception;
	}
	
	public void setCurrentLevel(int level) {
		
		currentLevel = level;
	}
	
    // validation duration
    public void setValidationDuration(long time) {
    	
        duration=time;
    }
    
    public long getValidationDuration() {
    	
        return duration;
    }
    
    public void start() {
    	
        start=System.currentTimeMillis();
    }
    
    public void stop() {
    	
        if(getValidationDuration() == -1L){ // not already stopped
            stop=System.currentTimeMillis();
            setValidationDuration(stop-start);
        }
    }
}
