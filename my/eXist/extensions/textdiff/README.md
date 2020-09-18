# Additional features for eXist-db - Itinera Nova #

This repository holds the source code for the eXist-db Java extension module.

## Compiling
Requirements: Java 8, Maven 3.

1. `git clone https://github.com/cceh/ItineraNova-features

2. `cd ItineraNova-features`

3. `mvn package`

You will then find a file named similar to `target/itineranova-features-1.0.xar`.

## Installation into eXist-db
You can install the module into eXist-db in either one of two ways:
1. As an EXPath Package (.xar file)
2. Directly as a XQuery Java Extension Module (.jar file)

### EXPath Package Installation into eXist-db (.xar)
1. If you have compiled yourself (see above), you can take the `target/itineranova-features-1.0.xar` file and upload it via eXist's EXPath Package Manager app in its Dashboard

2. Otherwise, the latest release version will also be available from the eXist's EXPath Package Manager app in its Dashboard


### Direct Installation into eXist-db (.jar)
1. If you have compiled yourself (see above), copy `target/itineranova-features-1.0.jar` to `$EXIST_HOME/lib/user`.

2. Edit `$EXIST_HOME/conf.xml` and add the following to the `<builtin-modules>`:

    ```xml
    <module uri="http://itineranova.be/features" class="org.itineranova.features.text.TextModule"/>
    ```

3. Restart eXist-db


### API Overview

Namespace URI: `http://itineranova.be/features`

Namespace Prefix: `textdiff`

Class: `org.itineranova.features.text.TextModule`


1. To find the differences between two nodes:
    ```xquery
    textdiff:diff($a as xs:string(), $b as xs:string()) as node()
    ```

### Utility API Overview

Namespace URI: `http://itineranova.be/features`

Namespace Prefix: `textdiff`
