package org.exist.xquery.modules.text;

import java.util.LinkedList;

import org.exist.dom.QName;
import org.exist.dom.memtree.MemTreeBuilder;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.xquery.modules.text.diff_match_patch.Diff;
import org.exist.xquery.value.*;

/**
 * text:diff($text1, $text2) — computes text differences.
 * Returns XML with ++inserted++ and --deleted-- markers.
 *
 * Used by charter-version-difference for comparing charter versions.
 */
public class TextDiffFunction extends BasicFunction {

    public static final FunctionSignature signature = new FunctionSignature(
        new QName("diff", TextDiffModule.NAMESPACE_URI, TextDiffModule.PREFIX),
        "Compute the difference between two texts using diff-match-patch",
        new SequenceType[] {
            new FunctionParameterSequenceType("text1", Type.STRING, Cardinality.ZERO_OR_ONE, "The first text"),
            new FunctionParameterSequenceType("text2", Type.STRING, Cardinality.ZERO_OR_ONE, "The second text")
        },
        new FunctionReturnSequenceType(Type.NODE, Cardinality.EXACTLY_ONE, "XML element with diff markers")
    );

    public TextDiffFunction(XQueryContext context) {
        super(context, signature);
    }

    @Override
    public Sequence eval(Sequence[] args, Sequence contextSequence) throws XPathException {
        if (args[0].isEmpty()) {
            return Sequence.EMPTY_SEQUENCE;
        }

        String text1 = args[0].getStringValue();
        String text2 = args[1].isEmpty() ? "" : args[1].getStringValue();

        diff_match_patch dmp = new diff_match_patch();
        LinkedList<Diff> diffs = dmp.diff_main(text1, text2);
        dmp.diff_cleanupSemantic(diffs);

        MemTreeBuilder builder = context.getDocumentBuilder();
        builder.startDocument();
        builder.startElement(new QName("diff", TextDiffModule.NAMESPACE_URI, TextDiffModule.PREFIX), null);

        for (Diff aDiff : diffs) {
            switch (aDiff.operation) {
                case INSERT:
                    builder.characters("++" + aDiff.text + "++");
                    break;
                case DELETE:
                    builder.characters("--" + aDiff.text + "--");
                    break;
                case EQUAL:
                    builder.characters(aDiff.text);
                    break;
            }
        }

        builder.endElement();
        builder.endDocument();

        return (NodeValue) builder.getDocument().getDocumentElement();
    }
}
