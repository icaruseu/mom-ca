package org.exist.xquery.functions.text;

import java.util.LinkedList;

import org.exist.dom.QName;
import org.exist.memtree.MemTreeBuilder;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.functions.text.diff_match_patch.Diff;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;

public class TextDiff extends BasicFunction {

	public final static FunctionSignature signature = new FunctionSignature(
			new QName("diff", TextModule.NAMESPACE_URI, TextModule.PREFIX),
			"Compute the difference between two texts",
			new SequenceType[]{
					new FunctionParameterSequenceType("text1", Type.STRING, Cardinality.ZERO_OR_ONE, "The first text as string"),
					new FunctionParameterSequenceType("text2", Type.STRING, Cardinality.ZERO_OR_ONE, "The second text as string")
					},
			new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "a XML document describing the difference"));
	
	public TextDiff(XQueryContext context) {
		super(context, signature);
	}
	
	/* (non-Javadoc)
	 * @see org.exist.xquery.BasicFunction#eval(org.exist.xquery.value.Sequence[], org.exist.xquery.value.Sequence)
	 */
	public Sequence eval(Sequence[] args, Sequence contextSequence)
		throws XPathException {
		
		if(args[0].isEmpty())
			return Sequence.EMPTY_SEQUENCE;
		
		// initialize
		Sequence xmlResponse = null;
		MemTreeBuilder builder = context.getDocumentBuilder();
		diff_match_patch dmp = new diff_match_patch();
		LinkedList<Diff> diffs = null;
		
		// get the function parameter values
		String text1 = args[0].getStringValue();
		String text2 = args[1].getStringValue();
		
		// compute the text difference
		diffs = dmp.diff_main(text1, text2);
		dmp.diff_cleanupSemantic(diffs);
		
		// build response document
		builder.startDocument();
		builder.startElement( new QName( "diff", TextModule.NAMESPACE_URI, TextModule.PREFIX ), null );
		
		for(Diff aDiff : diffs) {
			
			switch(aDiff.operation) {
			case INSERT:
				//builder.startElement( new QName( "insert", TextModule.NAMESPACE_URI, TextModule.PREFIX ), null );
				builder.characters("++");
				builder.characters(aDiff.text);
				builder.characters("++");
				//builder.endElement();
				break;
			case DELETE:
				//builder.startElement( new QName( "delete", TextModule.NAMESPACE_URI, TextModule.PREFIX ), null );
				builder.characters("--");
				builder.characters(aDiff.text);
				builder.characters("--");
				//builder.endElement();
				break;
			case EQUAL:
				//builder.startElement( new QName( "equal", TextModule.NAMESPACE_URI, TextModule.PREFIX ), null );
				builder.characters(aDiff.text);
				//builder.endElement();
				break;
			}
		}
		
		builder.endElement();		
		builder.endDocument();
		
		xmlResponse = (NodeValue)builder.getDocument().getDocumentElement();
		
		return (xmlResponse);
	}
}