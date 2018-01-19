<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Send Mail</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<h2>Send Mail</h2>

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
    %><p>Error: No message type given.</p><%
}

if ( studentTemplate != null ) {
    results = state.executeQuery( "SELECT studentID, name, email FROM students" );
    
    Vector studentIDs = new Vector();
    Vector studentNames = new Vector();
    Vector studentEmails = new Vector();
    
    while ( results.next() ) {
	if ( results.getString( 2 ) != null ) {
	    studentIDs.add( new Integer( results.getInt( 1 ) ) );
	    studentNames.add( results.getString( 2 ) );
	    studentEmails.add( results.getString( 3 ) );
	}
    }
    
    for ( int i = 0; i < studentIDs.size(); i++ ) {
	results = state.executeQuery( "SELECT * FROM conference WHERE studentID = " + studentIDs.get( i ) );
	if ( !results.first() )
	    continue;

	String temp = new String( studentTemplate );
	temp = temp.replaceAll( "%n", (String)studentNames.get( i ) );
	temp = temp.replaceAll( "%e", (String)studentEmails.get( i ) );
	
	String confBlock = temp.substring( temp.indexOf( "%z" ) + 2, temp.lastIndexOf( "%z" ) -1 );
	temp = temp.replaceAll( "\\Q" + confBlock, "" );
	temp = temp.replaceFirst( "\n%z", "" );
	
	Hashtable ht = new Hashtable();
	results = state.executeQuery( "SELECT teachers.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN teachers ON classes.teacherID = teachers.teacherID WHERE studentID = " + studentIDs.get( i ) );
	
	while ( results.next() ) {
	    String s = (String)ht.get( results.getString( 1 ) );
	    if ( s == null )
		ht.put( results.getString( 1 ), results.getString( 2 ) );
	    else
		ht.put( results.getString( 1 ), s + ", " + results.getString( 2 ) );
	}

	String confArea = "";
	results = state.executeQuery( "SELECT teachers.name, teachers.room, conference.start, conference.end FROM conference LEFT JOIN teachers ON teachers.teacherID = conference.teacherID WHERE studentID = " + ((Integer)studentIDs.get( i )).intValue() + " ORDER BY conference.start" );
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
	
	boolean result = Sendmail.send( server, from, (String)studentEmails.get( i ), temp );
	if ( !result ) {
	    %><p>Error sending mail to <%= studentEmails.get( i ) %>! See server logs for details.</p><%
	} else {
	    %><p>Message sent to <%= studentEmails.get( i ) %>.</p><%
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
    %><p>Error: No message type given here either.</p><%
}
    
if ( teacherTemplate != null ) {
    results = state.executeQuery( "SELECT teacherID, name, email FROM teachers" );
    
    Vector teacherIDs = new Vector();
    Vector teacherNames = new Vector();
    Vector teacherEmails = new Vector();
    
    while ( results.next() ) {
	if ( results.getString( 2 ) != null ) {
	    teacherIDs.add( new Integer( results.getInt( 1 ) ) );
	    teacherNames.add( results.getString( 2 ) );
	    teacherEmails.add( results.getString( 3 ) );
	}
    }
    
    for ( int i = 0; i < teacherIDs.size(); i++ ) {
	results = state.executeQuery( "SELECT * FROM conference WHERE teacherID = " + teacherIDs.get( i ) );
	if ( !results.first() )
	    continue;

	Hashtable ht = new Hashtable();
	results = state.executeQuery( "SELECT students.name, classes.name FROM classMembers LEFT JOIN classes ON classes.classID = classMembers.classID LEFT JOIN students ON classMembers.studentID = students.studentID WHERE classes.teacherID = " + teacherIDs.get( i ) );
	
	while ( results.next() ) {
	    String s = (String)ht.get( results.getString( 1 ) );
	    if ( s == null )
		ht.put( results.getString( 1 ), results.getString( 2 ) );
	    else
		ht.put( results.getString( 1 ), s + ", " + results.getString( 2 ) );
	}	

	String temp = new String( teacherTemplate );
	temp = temp.replaceAll( "%t", (String)teacherNames.get( i ) );
	temp = temp.replaceAll( "%e", (String)teacherEmails.get( i ) );
	
	String confBlock = temp.substring( temp.indexOf( "%z" ) + 2, temp.lastIndexOf( "%z" ) -1 );
	temp = temp.replaceAll( "\\Q" + confBlock, "" );
	temp = temp.replaceFirst( "\n%z", "" );
	
	String confArea = "";
	results = state.executeQuery( "SELECT students.name, teachers.room, conference.start, conference.end FROM conference LEFT JOIN students ON students.studentID = conference.studentID LEFT JOIN teachers ON teachers.teacherID = conference.teacherID WHERE conference.teacherID = " + ((Integer)teacherIDs.get( i )).intValue() + " ORDER BY conference.start" );
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
	
	boolean result = Sendmail.send( server, from, (String)teacherEmails.get( i ), temp );
	if ( !result ) {
	    %><p>Error sending mail to <%= teacherEmails.get( i ) %>! See server logs for details.</p><%
	} else {
	    %><p>Message sent to <%= teacherEmails.get( i ) %>.</p><%
	}
    }
}

%>

</body>
</html>
