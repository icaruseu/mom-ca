package org.exist.xquery.modules.image;

import java.awt.*;
import java.awt.image.*;
import java.io.*;
import javax.imageio.ImageIO;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.exist.dom.QName;
import org.exist.xquery.*;
import org.exist.xquery.value.*;

/**
 * image:crop($image, $dimension, $mimeType) — crops an image.
 *
 * Dimension is a sequence of 4 integers: x1, y1, x2, y2.
 * Registers under the existing image module namespace.
 */
public class CropFunction extends BasicFunction {

    private static final Logger LOG = LogManager.getLogger(CropFunction.class);

    public static final String IMAGE_NAMESPACE_URI = "http://exist-db.org/xquery/image";
    public static final String IMAGE_PREFIX = "image";

    public static final FunctionSignature signature =
        new FunctionSignature(
            new QName("crop", IMAGE_NAMESPACE_URI, IMAGE_PREFIX),
            "Crops an image to the specified rectangle (x1, y1, x2, y2).",
            new SequenceType[] {
                new FunctionParameterSequenceType("image", Type.BASE64_BINARY, Cardinality.EXACTLY_ONE, "The image data"),
                new FunctionParameterSequenceType("dimension", Type.INTEGER, Cardinality.ONE_OR_MORE, "Crop rectangle: x1, y1, x2, y2"),
                new FunctionParameterSequenceType("mimeType", Type.STRING, Cardinality.EXACTLY_ONE, "MIME type (e.g. image/jpeg)")
            },
            new FunctionReturnSequenceType(Type.BASE64_BINARY, Cardinality.ZERO_OR_ONE, "The cropped image")
        );

    public CropFunction(XQueryContext context) {
        super(context, signature);
    }

    @Override
    public Sequence eval(Sequence[] args, Sequence contextSequence) throws XPathException {
        if (args[0].isEmpty()) {
            return Sequence.EMPTY_SEQUENCE;
        }

        BinaryValue imageData = (BinaryValue) args[0].itemAt(0);
        Sequence dimSeq = args[1];
        String mimeType = args[2].getStringValue();

        // Parse crop dimensions (defaults: 0, 0, 100, 100)
        int x1 = dimSeq.getItemCount() > 0 ? ((IntegerValue) dimSeq.itemAt(0)).getInt() : 0;
        int y1 = dimSeq.getItemCount() > 1 ? ((IntegerValue) dimSeq.itemAt(1)).getInt() : 0;
        int x2 = dimSeq.getItemCount() > 2 ? ((IntegerValue) dimSeq.itemAt(2)).getInt() : 100;
        int y2 = dimSeq.getItemCount() > 3 ? ((IntegerValue) dimSeq.itemAt(3)).getInt() : 100;

        int width = x2 - x1;
        int height = y2 - y1;

        if (width <= 0 || height <= 0) {
            throw new XPathException(this, "Invalid crop dimensions: width and height must be > 0");
        }

        // Determine image format from MIME type
        String formatName = mimeType.contains("png") ? "PNG" : "JPEG";

        try {
            // Decode image
            InputStream is = imageData.getInputStream();
            BufferedImage originalImage = ImageIO.read(is);
            is.close();

            if (originalImage == null) {
                throw new XPathException(this, "Could not decode image data");
            }

            // Clamp to image bounds
            x1 = Math.max(0, Math.min(x1, originalImage.getWidth()));
            y1 = Math.max(0, Math.min(y1, originalImage.getHeight()));
            width = Math.min(width, originalImage.getWidth() - x1);
            height = Math.min(height, originalImage.getHeight() - y1);

            // Crop
            BufferedImage croppedImage = originalImage.getSubimage(x1, y1, width, height);

            // Encode result
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(croppedImage, formatName, baos);

            return BinaryValueFromInputStream.getInstance(context,
                new Base64BinaryValueType(), new ByteArrayInputStream(baos.toByteArray()), this);

        } catch (IOException e) {
            throw new XPathException(this, "Image processing failed: " + e.getMessage(), e);
        }
    }
}
