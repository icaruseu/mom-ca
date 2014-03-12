package net.monasterium.xquery.exista;


import java.io.StringReader;
import java.io.StringWriter;

import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;

import org.exist.dom.QName;
import org.exist.security.Permission;
import org.exist.xmldb.UserManagementService;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.StringValue;
import org.exist.xquery.value.Type;
import org.exist.xquery.value.ValueSequence;
import org.exist.xquery.XPathException;
import org.xmldb.api.base.*;
import org.xmldb.api.modules.*;
import org.xmldb.api.*;

public class TransactFunction extends BasicFunction {

	static final String driver = "org.exist.xmldb.DatabaseImpl";
	
    public final static FunctionSignature signature =
		new FunctionSignature(
			new QName("transact-collection", ArchiveModule.NAMESPACE_URI, ArchiveModule.PREFIX),
			"Transacts a database collection from one into another database via XMLRPC. All resource permissions are copied. Optionally a stylesheet can be applied to a XMLResource before copying it.",
			new SequenceType[] { 
				new FunctionParameterSequenceType(
						"collection-uri",
						Type.ANY_URI,
						Cardinality.EXACTLY_ONE,
						"The collection URI to be copied from a source to a destination database. E.g. '/db/path/to/col'"
						),
				new FunctionParameterSequenceType(
						"source-xmlrpc-uri",
						Type.ANY_URI,
						Cardinality.EXACTLY_ONE,
						"The xmlrpc URI of the source database. E.g. 'xmldb:exist://localhost:8080/exist/xmlrpc'"
						),
				new FunctionParameterSequenceType(
						"username", 
						Type.STRING, 
						Cardinality.EXACTLY_ONE, 
						"Username to acces the collection in the source database."
						),				
				new FunctionParameterSequenceType(
						"password", 
						Type.STRING, 
						Cardinality.EXACTLY_ONE, 
						"Password to access the collection in the source database."
						),
				new FunctionParameterSequenceType(
						"destination-xmlrpc-uri",
						Type.ANY_URI,
						Cardinality.EXACTLY_ONE,
						"The xmlrpc URI of the destination database. E.g. 'xmldb:exist://localhost:8181/exist/xmlrpc'"
						),
				new FunctionParameterSequenceType(
						"username", 
						Type.STRING, 
						Cardinality.EXACTLY_ONE, 
						"Username to access the collection in the destination database."
						),				
				new FunctionParameterSequenceType(
						"password", 
						Type.STRING, 
						Cardinality.EXACTLY_ONE, 
						"Password to access the collection in the destination database."
						),
				new FunctionParameterSequenceType(
						"stylesheet-uri",
						Type.ANY_URI,
						Cardinality.ZERO_OR_ONE,
						"Optional stylesheet which is applied before copying a XMLRessource into the collection of the destination database."
						)
				},
			new FunctionReturnSequenceType(
					Type.STRING, 
					Cardinality.EXACTLY_ONE, 
					"a XML document containing information about the success status of the transaction.")
			);
    
	public TransactFunction(XQueryContext context) {
		super(context, signature);
	}
	
	public Sequence eval(Sequence[] args, Sequence contextSequence) 
		throws XPathException {
		
		ValueSequence result 					= new ValueSequence();

		String collectionUri 					= args[0].toString();
		String sourceXmlrpcUri 					= args[1].toString();
		String userNameSourceCollection 		= args[2].toString();
		String passwordSourceCollection 		= args[3].toString();
		String destinationXmlrpcUri 			= args[4].toString();
		String userNameDestinationCollection 	= args[5].toString();
		String passwordDestinationCollection 	= args[6].toString();
		String stylesheetUri;					
		if(args[7].isEmpty()) {
			stylesheetUri = "";
		}
		else {
			stylesheetUri = args[7].toString();
		}
		
		try {
			
	        Class cl											= Class.forName(driver);
	        Database database 									= (Database)cl.newInstance();
	        DatabaseManager.registerDatabase(database);
	        
	        // ********************************
	        // get info about and initialize source collection
	        // ********************************
	        
	        // initialize source collection
	        Collection sourceCollection 						= DatabaseManager.getCollection(sourceXmlrpcUri + collectionUri, userNameSourceCollection, passwordSourceCollection);
	        // initialize permission service for source collection
	        UserManagementService sourceManagementService 		= (UserManagementService)sourceCollection.getService("UserManagementService", "1.0");
	        // list XML resources of source collection
	        String[] resourceNames 								= sourceCollection.listResources();
	        
	        // ********************************
	        // initialize destination collection
	        // ********************************

	        // initialize permission service for destination collection
	        Collection destinationCollection 					= DatabaseManager.getCollection(destinationXmlrpcUri + collectionUri, userNameDestinationCollection, passwordDestinationCollection);
	        // if the collection already exists we return 
	        // with a warning to avoid that the resources of 
	        // a destination collection are overwritten
	        if(destinationCollection != null) {
	        	result.add(new StringValue("Destination collection already exists."));
	        	return result;
	        }
	        
	        // initialize and create collection where resources
	        // will be copied into
	        String collectionNameToBeCreated 						= getCollectionName(collectionUri);
	        String baseCollectionUri 								= getBaseCollectionUri(collectionUri);
	        
	        Collection destinationCollectionForCollectionToBeCreated 	= DatabaseManager.getCollection(destinationXmlrpcUri + baseCollectionUri, userNameDestinationCollection, passwordDestinationCollection);
	        CollectionManagementService colManagementService 			= (CollectionManagementService)destinationCollectionForCollectionToBeCreated.getService("CollectionManagementService", "1.0");
	        colManagementService.createCollection(collectionNameToBeCreated);
	        
	        // as the destination collection now exists 
	        // we try to initialize it again
	        destinationCollection 									= DatabaseManager.getCollection(destinationXmlrpcUri + collectionUri, userNameDestinationCollection, passwordDestinationCollection);
	        UserManagementService destinationManagementService 		= (UserManagementService)destinationCollection.getService("UserManagementService", "1.0");
	        
	        // ********************************
	        // copy all resources including 
	        // resource permissions
	        // ********************************
	        
	        for(int i = 0; i < 1/*resourceNames.length*/; i++) {
	        	
	        	Resource resourceToCopy 	= (XMLResource)sourceCollection.getResource(resourceNames[i]);
		        Permission permissionToCopy	= sourceManagementService.getPermissions(resourceToCopy);
		        
		        // XML resources are separately handled as we have
		        // to apply a XSLT stylesheet possibly
	        	if(resourceToCopy.getResourceType() == "XMLResource") {

			        // Transform the resource if a stylesheet URI is given as 
			        // last parameter. If the URI parameter is empty, we make
			        // a simple copy of the XML resource 
			        
	        		if(stylesheetUri != "") {
	        			
				        TransformerFactory transFact			= TransformerFactory.newInstance();
				        Source xsltSource 						= new StreamSource(stylesheetUri);
				        Source xmlSource 						= new StreamSource(new StringReader((String)resourceToCopy.getContent()));
				        StringWriter writer 					= new StringWriter();
				        StreamResult streamResult 				= new StreamResult(writer);
				        
				        Transformer trans 						= transFact.newTransformer(xsltSource);
				        
				        // transform XML Resource
				        trans.transform(xmlSource, streamResult);
				        
				        
				        // create a new XML resource
				        XMLResource transformedResourceToCopy	= (XMLResource)destinationCollection.createResource(resourceToCopy.getId(), "XMLResource");
				        // set transformed content
				        transformedResourceToCopy.setContent(streamResult.getWriter().toString());
				        // write the resource to the destination collection
				        destinationCollection.storeResource(transformedResourceToCopy);
				        
				        result.add(new StringValue("SUCCESS"));
	        		}
	        		else {
	        			
	        			// if no stylesheet is set, simply copy untransformed XML resource
	        			destinationCollection.storeResource(resourceToCopy);    			
	        			result.add(new StringValue("SUCCESS"));
	        		}  
	        	}
	        	else {
	        		
        			// copy resource
        			destinationCollection.storeResource(resourceToCopy);
	        		result.add(new StringValue("SUCCESS"));
	        	}
	        	
	        	// get the just created resource again
		        Resource destinationResource 			= destinationCollection.getResource(resourceNames[i]);
		        // copy user permissions
		        destinationManagementService.setPermissions(destinationResource, permissionToCopy);
	        }
	        

		}
		catch(Exception e) {
			
			result.add(new StringValue("ERROR"));
			return result;
		}
		return result;
	}
	
	private String getCleanedCollectionUri(String collectionUri) {
		
		String cleanedCollectionUri;
		if(collectionUri.endsWith("/"))
			cleanedCollectionUri = collectionUri.substring(0, collectionUri.length() - 1);
		else 
			cleanedCollectionUri = collectionUri;
		if(cleanedCollectionUri.startsWith("/"))
			cleanedCollectionUri = cleanedCollectionUri.substring(1);
		return cleanedCollectionUri;
	}
	
	private String getCollectionName(String collectionUri) {
		
        String[] tokenizedCollectionUri = getCleanedCollectionUri(collectionUri).split("/");
        int length = tokenizedCollectionUri.length;
        String collectionNameToCreate = tokenizedCollectionUri[length - 1];
        return collectionNameToCreate;
	}
	
	private String getBaseCollectionUri(String collectionUri) {
		
		String[] tokenizedCollectionUri = getCleanedCollectionUri(collectionUri).split("/");
		String baseCollectionUri = "";
		for(int i = 0; i < tokenizedCollectionUri.length - 1; i++) {
			
			baseCollectionUri += "/";
			baseCollectionUri += tokenizedCollectionUri[i];
		}
		return baseCollectionUri;
	}
}
