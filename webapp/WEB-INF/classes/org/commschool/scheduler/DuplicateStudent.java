package org.commschool.scheduler;

/**
 * DuplicateStudent.java - Create a new student that's an exact copy of 
 * a given one.
 * Copyright (C) 2004 Reilly Grant <reillyeon@qotw.net>
 * 
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 * 
 * Also add information on how to contact you by electronic and paper mail.
 */

import java.sql.*;

/**
 * DuplicateStudent
 *
 * Run on a already generated database and given a student name already 
 * in existance it will create a new student with the same classes.
 * 
 * Syntax:
 *         java DuplicateUser [-h hostname] [-u username] [-d database] [-p passwd]
 *                       origional_student name_of_copy
 *
 *         -h hostname   --server     Database server hostname
 *                                      (default: 127.0.0.1)
 *         -u username   --user       Database username (default: scheduler)
 *         -d database   --database   Database name (default: scheduler)
 *         -p password   --password   Database password (default: none)
 *
 * Have fun!
 */

public class DuplicateStudent {

    String hostname = "127.0.0.1";
    String username = "scheduler";
    String database = "scheduler";
    String dbpasswd = "";

    String origional_name = null;
    String new_name = null;

    Connection connect = null;

    public static void main( String[] args ) {
	DuplicateStudent dup = new DuplicateStudent();
	dup.run( args );
    }

    public void run( String[] args ) {
	if ( args.length == 0 ) {
	    printHelp();
	    return;
	}

	for ( int i = 0; i < args.length; i++ ) {
	    if ( args[i].equals( "-h" ) || args[i].equals( "--hostname" ) ) {
		hostname = args[++i];
   	    } else if ( args[i].equals( "-u" ) || args[i].equals( "--username" ) ) {
		username = args[++i];
	    } else if ( args[i].equals( "-d" ) || args[i].equals( "--database" ) ) {
		database = args[++i];
	    } else if ( args[i].equals( "-p" ) || args[i].equals( "--passwd" ) ) {
		dbpasswd = args[++i];
	    } else if ( args[i].equals( "-h" ) || args[i].equals( "--help" ) ) {
		printHelp();
		return;
	    } else {
		if ( origional_name == null )
		    origional_name = args[i];
		else if ( new_name == null )
		    new_name = args[i];
		else {
		    System.err.println( "Too many parameters!" );
		    printHelp();
		    return;
		}
	    }
	}

	if ( origional_name == null || new_name == null ) {
	    System.err.println( "Too few parameters!" );
	    printHelp();
	    return;
	}

	connectDatabase();

	copyUser();

	try {
	    connect.close();
	} catch ( SQLException e ) {
	    System.err.println( "Error closing database, but it doesn't matter because we are done!" + e );
	}
    }

    public void printHelp() {
	System.out.println( "Syntax:\n" +
			    "         java DuplicateUser [-h hostname] [-u username] [-d database] [-p password]\n" +
			    "                       origional_name name_of_copy\n" +
			    "\n" +
			    "         -h hostname   --server     Database server hostname\n" +
			    "                                      (default: 127.0.0.1)\n" +
			    "         -u username   --user       Database username (default: scheduler)\n" +
			    "         -d database   --database   Database name (default: scheduler)\n" +
			    "         -p password   --password   Database password (default: none)\n" );
    }

    public void connectDatabase() {
	try {
	    Class.forName( "com.mysql.jdbc.Driver" ).newInstance();
	    connect = DriverManager.getConnection( "jdbc:mysql://" + hostname + "/" + database, username, "" );
	    connect.setAutoCommit( true );
	} catch ( Exception e ) {
	    System.err.println( "Error opening database: " + e );
	    System.exit( -1 );
	}
    }

    public void copyUser() {
	try {
	    PreparedStatement queryOrigUser = connect.prepareStatement( "SELECT * FROM students WHERE name = ?" );
	    PreparedStatement queryOrigUserClasses = connect.prepareStatement( "SELECT * FROM classMembers WHERE studentID = ?" );
	    PreparedStatement queryNewUser = connect.prepareStatement( "SELECT * FROM students WHERE name = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
	    PreparedStatement queryNewUserClasses = connect.prepareStatement( "SELECT * FROM classMembers WHERE studentID = ?", ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );

	    queryOrigUser.setString( 1, origional_name );
	    ResultSet origUser = queryOrigUser.executeQuery();
	    if ( !origUser.first() ) {
		System.err.println( "User \"" + origional_name + "\" not found!" );
		return;
	    }

	    queryNewUser.setString( 1, new_name );
	    ResultSet newUser = queryNewUser.executeQuery();

	    newUser.moveToInsertRow();
	    newUser.updateString( 2, new_name );
	    newUser.updateString( 6, origUser.getString( 6 ) );
	    newUser.insertRow();
	    newUser.close();

	    newUser = queryNewUser.executeQuery();
	    if ( !newUser.first() ) {
		System.err.println( "New user not sucessfully entered!" );
		return;
	    }

	    queryOrigUserClasses.setInt( 1, origUser.getInt( 1 ) );
	    ResultSet origUserClasses = queryOrigUserClasses.executeQuery();
	    
	    queryNewUserClasses.setInt( 1, origUser.getInt( 1 ) );
	    ResultSet newUserClasses = queryNewUserClasses.executeQuery();

	    while( origUserClasses.next() ) {
		newUserClasses.moveToInsertRow();
		newUserClasses.updateInt( 1, origUserClasses.getInt( 1 ) );
		newUserClasses.updateInt( 2, newUser.getInt( 1 ) );
		newUserClasses.insertRow();
	    }

	    origUser.close();
	    origUserClasses.close();
	    newUser.close();
	    newUserClasses.close();
	    
	    queryOrigUser.close();
	    queryOrigUserClasses.close();
	    queryNewUser.close();
	    queryNewUserClasses.close();
	} catch ( SQLException e ) {
	    System.err.println( "SQL error while copying user!" );
	    e.printStackTrace();
	}
    }
    
}
