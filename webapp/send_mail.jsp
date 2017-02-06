<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

if ( session.getAttribute( "admin" ) != Boolean.TRUE ) {
   %><jsp:forward page="admin.jsp" /><%
}

try {
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Send Mail</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<p><h1>Send Mail</h1>

<%

ResultSet results = state.executeQuery( "SELECT SMTPserver, mailFrom FROM config" );
results.first();
String server = results.getString( 1 );
String from = results.getString( 2 );

// Do students.

String studentTemplate = "";
if ( request.getParameter( "type" ).equals( "schedule" ) ) {
   results = state.executeQuery( "SELECT * FROM templates WHERE name = \"schedule-parent\"" );
   results.first();
   studentTemplate = results.getString( 2 );
} else if ( request.getParameter( "type" ).equals( "reminder" ) ) {
   results = state.executeQuery( "SELECT * FROM templates WHERE name = \"reminder-parent\"" );
   results.first();
   studentTemplate = results.getString( 2 );
} else {
    %>Error: No message type given.<%
}

if ( studentTemplate != null ) {
    results = state.executeQuery( "SELECT studentID, name, email FROM students" );
    
    Vector studentID = new Vector();
    Vector studentName = new Vector();
    Vector studentEmail = new Vector();
    
    while ( results.next() ) {
	if ( results.getString( 2 ) != null ) {
	    studentID.add( new Integer( results.getInt( 1 ) ) );
	    studentName.add( results.getString( 2 ) );
	    studentEmail.add( results.getString( 3 ) );
	}
    }
    
    for ( int i = 0; i < studentID.size(); i++ ) {
	results = state.executeQuery( "SELECT * FROM conference WHERE studentID = " + studentID.get( i ) );
	if ( !results.first() )
	    continue;

	String temp = new String( studentTemplate );
	temp = temp.replaceAll( "%n", (String)studentName.get( i ) );
	temp = temp.replaceAll( "%e", (String)studentEmail.get( i ) );
	
	String confBlock = temp.substring( temp.indexOf( "%z" ) + 2, temp.lastIndexOf( "%z" ) -1 );
	temp = temp.replaceAll( "\\Q" + confBlock, "" );
	temp = temp.replaceFirst( "\n%z", "" );
	
	Hashtable ht = new Hashtable();
	results = state.executeQuery( "SELECT teachers.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE studentID = " + studentID.get( i ) );
	
	while ( results.next() ) {
	    String s = (String)ht.get( results.getString( 1 ) );
	    if ( s == null )
		ht.put( results.getString( 1 ), results.getString( 2 ) );
	    else
		ht.put( results.getString( 1 ), s + ", " + results.getString( 2 ) );
	}

	String confArea = "";
	results = state.executeQuery( "SELECT teachers.name, teachers.room, conference.start, conference.end FROM conference LEFT JOIN teachers ON teachers.teacherID = conference.teacherID WHERE studentID = " + ((Integer)studentID.get( i )).intValue() + " ORDER BY conference.start" );
	while( results.next() ) {
	    confArea += confBlock;
	    confArea = confArea.replaceAll( "%t", results.getString( 1 ) );
	    confArea = confArea.replaceAll( "%c", (String)ht.get( results.getString( 1 ) ) );
	    confArea = confArea.replaceAll( "%l", results.getString( 2 ) );
	    DateFormat tdf = DateFormat.getTimeInstance();
	    DateFormat ddf = DateFormat.getDateInstance();
	    confArea = confArea.replaceAll( "%s", tdf.format( results.getTimestamp( 3 ) ) + " " + ddf.format( results.getTimestamp( 3 ) ) );
	    confArea = confArea.replaceAll( "%f", tdf.format( results.getTimestamp( 4 ) ) );
	}
	
	temp = temp.replaceAll( "%z", confArea );
	
	boolean result = Sendmail.send( server, from, (String)studentEmail.get( i ), temp );
	if ( !result ) {
	    %><br>Error sending mail to <%= studentEmail.get( i ) %>! See server logs for details.<%
	} else {
	    %><br>Message sent to <%= studentEmail.get( i ) %>.<%
	}
    }
}

// Do teachers.


String teacherTemplate = "";
if ( request.getParameter( "type" ).equals( "schedule" ) ) {
    results = state.executeQuery( "SELECT * FROM templates WHERE name = \"schedule-teacher\"" );
    results.first();
    teacherTemplate = results.getString( 2 );
} else if ( request.getParameter( "type" ).equals( "reminder" ) ) {
    results = state.executeQuery( "SELECT * FROM templates WHERE name = \"reminder-teacher\"" );
    results.first();
    teacherTemplate = results.getString( 2 );
} else {
    %>Error: No message type given here either.<%
}
    
if ( teacherTemplate != null ) {
    results = state.executeQuery( "SELECT teacherID, name, email FROM teachers" );
    
    Vector teacherID = new Vector();
    Vector teacherName = new Vector();
    Vector teacherEmail = new Vector();
    
    while ( results.next() ) {
	if ( results.getString( 2 ) != null ) {
	    teacherID.add( new Integer( results.getInt( 1 ) ) );
	    teacherName.add( results.getString( 2 ) );
	    teacherEmail.add( results.getString( 3 ) );
	}
    }
    
    for ( int i = 0; i < teacherID.size(); i++ ) {
	results = state.executeQuery( "SELECT * FROM conference WHERE teacherID = " + teacherID.get( i ) );
	if ( !results.first() )
	    continue;

	Hashtable ht = new Hashtable();
	results = state.executeQuery( "SELECT students.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN students ON classMembers.studentID = students.studentID WHERE classes.teacherID = " + teacherID.get( i ) );
	
	while ( results.next() ) {
	    String s = (String)ht.get( results.getString( 1 ) );
	    if ( s == null )
		ht.put( results.getString( 1 ), results.getString( 2 ) );
	    else
		ht.put( results.getString( 1 ), s + ", " + results.getString( 2 ) );
	}	

	String temp = new String( teacherTemplate );
	temp = temp.replaceAll( "%t", (String)teacherName.get( i ) );
	temp = temp.replaceAll( "%e", (String)teacherEmail.get( i ) );
	
	String confBlock = temp.substring( temp.indexOf( "%z" ) + 2, temp.lastIndexOf( "%z" ) -1 );
	temp = temp.replaceAll( "\\Q" + confBlock, "" );
	temp = temp.replaceFirst( "\n%z", "" );
	
	String confArea = "";
	results = state.executeQuery( "SELECT students.name, teachers.room, conference.start, conference.end FROM conference LEFT JOIN students ON students.studentID = conference.studentID LEFT JOIN teachers ON teachers.teacherID = conference.teacherID WHERE conference.teacherID = " + ((Integer)teacherID.get( i )).intValue() + " ORDER BY conference.start" );
	while( results.next() ) {
	    confArea += confBlock;
	    confArea = confArea.replaceAll( "%n", results.getString( 1 ) );
	    confArea = confArea.replaceAll( "%c", (String)ht.get( results.getString( 1 ) ) );
	    confArea = confArea.replaceAll( "%l", results.getString( 2 ) );
	    DateFormat tdf = DateFormat.getTimeInstance();
	    DateFormat ddf = DateFormat.getDateInstance();
	    confArea = confArea.replaceAll( "%s", tdf.format( results.getTimestamp( 3 ) ) + " " + ddf.format( results.getTimestamp( 3 ) ) );
	    confArea = confArea.replaceAll( "%f", tdf.format( results.getTimestamp( 4 ) ) );
	}
	
	temp = temp.replaceAll( "%z", confArea );
	
	boolean result = Sendmail.send( server, from, (String)teacherEmail.get( i ), temp );
	if ( !result ) {
	    %><br>Error sending mail to <%= teacherEmail.get( i ) %>! See server logs for details.<%
	} else {
	    %><br>Message sent to <%= teacherEmail.get( i ) %>.<%
	}
    }
}

%>

</body>
</html>
