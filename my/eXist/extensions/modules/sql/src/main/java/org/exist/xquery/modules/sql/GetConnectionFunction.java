/*
 *  eXist SQL Module Extension GetConnectionFunction
 *  Copyright (C) 2008-10 Adam Retter <adam@exist-db.org>
 *  www.adamretter.co.uk
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 *  $Id: GetConnectionFunction.java 11988 2010-07-17 15:55:25Z chaeron $
 */

package org.exist.xquery.modules.sql;

import org.apache.log4j.Logger;

import org.exist.dom.QName;
import org.exist.xquery.BasicFunction;
import org.exist.xquery.Cardinality;
import org.exist.xquery.FunctionSignature;
import org.exist.xquery.XPathException;
import org.exist.xquery.XQueryContext;
import org.exist.util.ParametersExtractor;
import org.exist.xquery.value.FunctionParameterSequenceType;
import org.exist.xquery.value.FunctionReturnSequenceType;
import org.exist.xquery.value.IntegerValue;
import org.exist.xquery.value.NodeValue;
import org.exist.xquery.value.Sequence;
import org.exist.xquery.value.SequenceType;
import org.exist.xquery.value.Type;

import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.DriverPropertyInfo;
import java.sql.SQLException;
import java.util.Properties;


/**
 * eXist SQL Module Extension GetConnectionFunction.
 *
 * <p>Get a connection to a SQL Database</p>
 *
 * @author   Adam Retter <adam@exist-db.org>
 * @author   Loren Cahlander
 * @version  1.21
 * @see      org.exist.xquery.BasicFunction#BasicFunction(org.exist.xquery.XQueryContext, org.exist.xquery.FunctionSignature)
 * @serial   2008-05-29
 */
public class GetConnectionFunction extends BasicFunction
{
    protected static final FunctionReturnSequenceType    RETURN_TYPE                 = new FunctionReturnSequenceType( Type.LONG, Cardinality.ZERO_OR_ONE, "an xs:long representing the connection handle" );

    protected static final FunctionParameterSequenceType JDBC_PASSWORD_PARAM         = new FunctionParameterSequenceType( "password", Type.STRING, Cardinality.EXACTLY_ONE, "The SQL database password" );

    protected static final FunctionParameterSequenceType JDBC_USERNAME_PARAM         = new FunctionParameterSequenceType( "username", Type.STRING, Cardinality.EXACTLY_ONE, "The SQL database username" );

    protected static final FunctionParameterSequenceType JDBC_PROPERTIES_PARAM       = new FunctionParameterSequenceType( "properties", Type.ELEMENT, Cardinality.ZERO_OR_ONE, "The JDBC database connection properties in the form <properties><property name=\"\" value=\"\"/></properties>." );

    protected static final FunctionParameterSequenceType JDBC_URL_PARAM              = new FunctionParameterSequenceType( "url", Type.STRING, Cardinality.EXACTLY_ONE, "The JDBC connection URL" );

    protected static final FunctionParameterSequenceType JDBC_DRIVER_CLASSNAME_PARAM = new FunctionParameterSequenceType( "driver-classname", Type.STRING, Cardinality.EXACTLY_ONE, "The JDBC driver classname" );

    protected static final FunctionParameterSequenceType JDBC_DRIVER_URL_PARAM		= new FunctionParameterSequenceType( "driver-url", Type.STRING, Cardinality.EXACTLY_ONE, "The JDBC driver URL in the form 'jar:file:/path/to/driver.jar!/'" );
    
    private static final Logger                          logger                      = Logger.getLogger( GetConnectionFunction.class );

    public final static FunctionSignature[] signatures = {
			new FunctionSignature(
					new QName("get-connection", SQLModule.NAMESPACE_URI, SQLModule.PREFIX),
					"Opens a connection to a SQL Database",
					new SequenceType[] { JDBC_DRIVER_CLASSNAME_PARAM, JDBC_URL_PARAM },
					RETURN_TYPE),

			new FunctionSignature(
					new QName("get-connection", SQLModule.NAMESPACE_URI, SQLModule.PREFIX),
					"Opens a connection to a SQL Database",
					new SequenceType[] { JDBC_DRIVER_CLASSNAME_PARAM, JDBC_URL_PARAM, JDBC_PROPERTIES_PARAM },
					RETURN_TYPE),

			new FunctionSignature(
					new QName("get-connection", SQLModule.NAMESPACE_URI, SQLModule.PREFIX),
					"Opens a connection to a SQL Database",
					new SequenceType[] { JDBC_DRIVER_CLASSNAME_PARAM, JDBC_URL_PARAM, JDBC_USERNAME_PARAM, JDBC_PASSWORD_PARAM },
					RETURN_TYPE),

			new FunctionSignature(
					new QName("get-connection", SQLModule.NAMESPACE_URI, SQLModule.PREFIX),
					"Opens a connection to a SQL Database",
					new SequenceType[] { JDBC_DRIVER_CLASSNAME_PARAM, JDBC_URL_PARAM, JDBC_DRIVER_URL_PARAM, JDBC_USERNAME_PARAM, JDBC_PASSWORD_PARAM },
					RETURN_TYPE) 
	};

    /**
     * GetConnectionFunction Constructor.
     *
     * @param  context    The Context of the calling XQuery
     * @param  signature  DOCUMENT ME!
     */
    public GetConnectionFunction( XQueryContext context, FunctionSignature signature )
    {
        super( context, signature );
    }

    /**
     * evaluate the call to the xquery get-connection() function, it is really the main entry point of this class.
     *
     * @param   args             arguments from the get-connection() function call
     * @param   contextSequence  the Context Sequence to operate on (not used here internally!)
     *
     * @return  A xs:long representing a handle to the connection
     *
     * @throws  XPathException  DOCUMENT ME!
     *
     * @see     org.exist.xquery.BasicFunction#eval(org.exist.xquery.value.Sequence[], org.exist.xquery.value.Sequence)
     */
    public Sequence eval( Sequence[] args, Sequence contextSequence ) throws XPathException
    {
        // was a db driver and url specified?
        if( args[0].isEmpty() || args[1].isEmpty() ) {
            return( Sequence.EMPTY_SEQUENCE );
        }

        // get the db connection details
        String dbDriver = args[0].getStringValue();
        String dbURL    = args[1].getStringValue();
        URL driverURL = null;

        try {

            Connection con = null;

            if( args.length == 2 ) {
                // load the driver
                Class.forName( dbDriver ).newInstance();

                // try and get the connection
                con = DriverManager.getConnection( dbURL );
            } else if( args.length == 3 ) {
                // load the driver
                Class.forName( dbDriver ).newInstance();

                // try and get the connection
                Properties props = ParametersExtractor.parseProperties( ( (NodeValue)args[2].itemAt( 0 ) ).getNode() );
                con = DriverManager.getConnection( dbURL, props );
            } else if( args.length == 4 ) {
                // load the driver
                Class.forName( dbDriver ).newInstance();
                
                String dbUser     = args[2].getStringValue();
                String dbPassword = args[3].getStringValue();

                // try and get the connection
                con = DriverManager.getConnection( dbURL, dbUser, dbPassword );
            } 

            // store the Connection and return the uid handle of the Connection
            return( new IntegerValue( SQLModule.storeConnection( context, con ) ) );
        }
        catch( IllegalAccessException iae ) {
            logger.error( "sql:get-connection() Illegal Access to database driver class: " + dbDriver, iae );
            throw( new XPathException( this, "sql:get-connection() Illegal Access to database driver class: " + dbDriver, iae ) );
        }
        catch( ClassNotFoundException cnfe ) {
            logger.error( "sql:get-connection() Cannot find database driver class: " + dbDriver, cnfe );
            throw( new XPathException( this, "sql:get-connection() Cannot find database driver class: " + dbDriver, cnfe ) );
        }
        catch( InstantiationException ie ) {
            logger.error( "sql:get-connection() Cannot instantiate database driver class: " + dbDriver, ie );
            throw( new XPathException( this, "sql:get-connection() Cannot instantiate database driver class: " + dbDriver, ie ) );
        }
        catch( SQLException sqle ) {
            logger.error( "sql:get-connection() Cannot connect to database: " + dbURL, sqle );
            throw( new XPathException( this, "sql:get-connection() Cannot connect to database: " + dbURL, sqle ) );
            
        } 
    }
 //
 //   class DriverShim implements Driver {
 //   	
 //   	private Driver driver;
 //   	DriverShim(Driver d) {
 //   		this.driver = d;
 //   	}
//	public java.util.logging.Logger getParentLogger() throws SQLException {
//		throw new UnsupportedOperationException("This method is not supported");
//	}
 //   	public boolean acceptsURL(String u) throws SQLException {
 //   		return this.driver.acceptsURL(u);
 //   	}
 //   	public Connection connect(String u, Properties p) throws SQLException {
 //   		return this.driver.connect(u, p);
//    	}
 //   	public int getMajorVersion() {
 //   		return this.driver.getMajorVersion();
 //   	}
 //   	public int getMinorVersion() {
//    		return this.driver.getMinorVersion();
 //   	}
 //   	public DriverPropertyInfo[] getPropertyInfo(String u, Properties p) throws SQLException {
//    		return this.driver.getPropertyInfo(u, p);
//    	}
//    	public boolean jdbcCompliant() {
//    		return this.driver.jdbcCompliant();
//    	}
//    }
}
