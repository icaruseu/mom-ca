package org.exist.xquery.functions.validation;

import org.exist.validation.ValidationReportItem;

public class XrxValidationReportItem extends ValidationReportItem {
	
	private String nodeId = null;
	
	public String getNodeId() {
		return nodeId;
	}
	
	public void setNodeId(String id) {
		nodeId = id;
	}
}