package org.exist.xquery.modules.minify;

import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;

import org.exist.dom.QName;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;
import org.exist.xquery.Cardinality;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.XPathException;
import org.exist.xquery.value.SequenceIterator;
import org.exist.xquery.value.ValueSequence;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.StringValue;
import com.yahoo.platform.yui.compressor.CssCompressor;

public class CssFunction extends BasicFunction {

    private final static QName CSS_FUNCTION_NAME = new QName("css", MinifyModule.NAMESPACE_URI, MinifyModule.PREFIX);
    private final static String CSS_FUNCTION_DESCRIPTION = "Minify CSS files.";

    public final static FunctionSignature signature =
		new FunctionSignature(
				CSS_FUNCTION_NAME,
				CSS_FUNCTION_DESCRIPTION,
				new SequenceType[] { new FunctionParameterSequenceType("css", Type.STRING, Cardinality.ZERO_OR_MORE, "The CSS files to minify as string values")},
				new FunctionReturnSequenceType(Type.STRING, Cardinality.EXACTLY_ONE, "the minified CSS")
			);
    
	public CssFunction(XQueryContext context) {
		super(context, signature);
	}

	public Sequence eval(Sequence[] args, Sequence contextSequence)
		throws XPathException {

		ValueSequence result = new ValueSequence();
		String minified = "";
		
		try {
			for (SequenceIterator i = args[0].iterate(); i.hasNext();) {
				String css = i.nextItem().getStringValue();
				StringReader reader = new StringReader(css);
				CssCompressor compressor = new CssCompressor(reader);
				StringWriter writer = new StringWriter();
				compressor.compress(writer, -1);
				minified += writer.toString();
			}
			result.add(new StringValue(minified));
		} catch (IOException e) {
			e.printStackTrace();
		}
		
		return result;
	}
}