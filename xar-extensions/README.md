# MOM-CA Java Extensions

eXist-db library package (.xar) containing custom Java extension modules for MOM-CA.

## Modules

### Excel Module (`http://exist-db.org/xquery/excel`)
Reads Microsoft Excel (.xls) workbooks via Apache POI.

Functions:
- `excel:workbookinfo($url)` — list sheets in a workbook
- `excel:sheetinfo($url, $sheet)` — row range info for a sheet
- `excel:rowinfo($url, $sheet, $row)` — cell range info for a row
- `excel:sheet($url, $sheet, $rows, $cells)` — extract cells as XML

### Image Crop (`http://exist-db.org/xquery/image`)
Extends eXist-db's built-in image module with a crop function.

- `image:crop($image, $dimensions, $mimeType)` — crop image to (x1, y1, x2, y2)

## Build

```bash
cd xar-extensions
mvn package
```

Produces `target/mom-ca-extensions-1.0.0.zip` — rename to `.xar` for installation.

## Install

Upload `mom-ca-extensions-1.0.0.xar` via eXist-db Package Manager,
or place in `autodeploy/` directory.

## Dependencies

- eXist-db 6.0+
- Apache POI 5.2.x (bundled)
- Commons IO 2.15.x (bundled)
