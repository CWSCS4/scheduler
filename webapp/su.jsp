<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
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
    state = connect.createStatement();
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Access User Account</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "type" ) == null || request.getParameter( "type" ).equals( "" ) ) { %>

<br><big><big style="font-weight: bold;">Access User Account</big></big><br>

<p>Students:
<ul>
<%
Vector teacherHasPreferences = new Vector();
Vector studentHasPreferences = new Vector();
ResultSet results = state.executeQuery( "SELECT ID, isTeacher FROM preferences" );
while( results.next() ) {
       if ( results.getInt( 2 ) == 0 ) {
       	  if ( !studentHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ) {
	     studentHasPreferences.add( new Integer( results.getInt( 1 ) ) );
	  }
       } else if ( results.getInt( 2 ) == 1 ) {
       	  if ( !teacherHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ) {
	     teacherHasPreferences.add( new Integer( results.getInt( 1 ) ) );
	  }
       }
}

Vector teacherHasAvailability = new Vector();
Vector studentHasAvailability = new Vector();
results = state.executeQuery( "SELECT ID, type FROM available" );
while( results.next() ) {
       if ( results.getInt( 2 ) == 0 ) {
       	  if ( !studentHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ) {
	     studentHasAvailability.add( new Integer( results.getInt( 1 ) ) );
	  }
       } else if ( results.getInt( 2 ) == 1 ) {
       	  if ( !teacherHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ) {
	     teacherHasAvailability.add( new Integer( results.getInt( 1 ) ) );
	  }
       }
}

results = state.executeQuery( "SELECT studentID, name, hasSignedIn FROM students ORDER BY name" );

while( results.next() ) {
    %>
<li>
<a href="su.jsp?id=<%= results.getInt( 1 ) %>&type=0"><%= results.getString( 2 ) %></a> (<%= ( results.getInt( 3 ) == 1 ? "Has Signed In" : "" ) %><%= ( studentHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ? " Preferences" : "" ) %><%= ( studentHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ? " Availability" : "" ) %>)
</li>
<%
}

%></ul>
<p>Teachers:
<ul>
<%
results = state.executeQuery( "SELECT teacherID, name, hasSignedIn FROM teachers ORDER BY name" );

while( results.next() ) {
    %><li><a href="su.jsp?id=<%= results.getInt( 1 ) %>&type=1"><%= results.getString( 2 ) %></a> (<%= ( results.getInt( 3 ) == 1 ? "Has Signed In" : "" ) %><%= ( teacherHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ? " Preferences" : "" ) %><%= ( teacherHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ? " Availability" : "" ) %>)</li><%
}

%>
</ul>
<% } else { %>

<%

int id = ( new Integer( request.getParameter( "id" ) ) ).intValue();

if ( request.getParameter( "type" ).equals( "0" ) ) {

session.setAttribute( "db", connect );
ResultSet results = state.executeQuery( "SELECT name FROM students WHERE studentID = " + id );
results.first();
session.setAttribute( "studentName", results.getString( 1 ) );
session.setAttribute( "studentID", new Integer( id ) );
results = state.executeQuery( "SELECT * FROM preferences WHERE isTeacher = 0 AND ID = " + id );
boolean setPreferences = results.first();
results = state.executeQuery( "SELECT * FROM available WHERE type = 0 AND ID = " + id );
boolean setTimes = results.first();
results = state.executeQuery( "SELECT * FROM conference WHERE studentID = " + id  );
boolean conferences = results.first();
<%-- if ( conferences ) {
  %><jsp:forward page="conferences.jsp" /><%
} else --%> if ( !setTimes ) {
  %><jsp:forward page="request.jsp" /><%
} else if ( !setPreferences ) {
  %><jsp:forward page="request2.jsp" /><%
} else {
  %><jsp:forward page="view.jsp" /><%
}

} else {

session.setAttribute( "db", connect );
ResultSet results = state.executeQuery( "SELECT name FROM teachers WHERE teacherID = " + id );
results.first();
session.setAttribute( "teacherName", results.getString( 1 ) );
session.setAttribute( "teacherID", new Integer( id ) );
results = state.executeQuery( "SELECT * FROM available WHERE type = 1 AND ID = " + id );
boolean setTimes = results.first();
results = state.executeQuery( "SELECT * FROM conference WHERE teacherID = " + id  );
boolean conferences = results.first();
<%-- if ( conferences ) {
  %><jsp:forward page="tconferences.jsp" /><%
} else --%> if ( !setTimes ) {
  %><jsp:forward page="trequest.jsp" /><%
} else {
  %><jsp:forward page="tview.jsp" /><%
}

}

}
%>
</body>
</html>
