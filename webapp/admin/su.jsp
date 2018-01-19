<%@ include file="/include/init.jsp" %>

<% Statement state = connect.createStatement(); %>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Access User Account</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if ( request.getParameter( "type" ) == null || request.getParameter( "type" ).equals( "" ) ) { %>

<h2>Access User Account</h2>
<ul>
	<li><a href="#students">Students</a></li>
	<li><a href="#teachers">Teachers</a></li>
</ul>
<h3 id="students">Students</h3>
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
<a href="/admin/su.jsp?id=<%= results.getInt( 1 ) %>&type=0"><%= results.getString( 2 ) %></a> (<%= ( results.getInt( 3 ) == 1 ? "Has Signed In" : "" ) %><%= ( studentHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ? " Preferences" : "" ) %><%= ( studentHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ? " Availability" : "" ) %>)
</li>
<%
}

%></ul>
<h3 id="teachers">Teachers</h3>
<ul>
<%
results = state.executeQuery( "SELECT teacherID, name, hasSignedIn FROM teachers ORDER BY name" );

while( results.next() ) {
    %><li><a href="/admin/su.jsp?id=<%= results.getInt( 1 ) %>&type=1"><%= results.getString( 2 ) %></a> (<%= ( results.getInt( 3 ) == 1 ? "Has Signed In" : "" ) %><%= ( teacherHasPreferences.contains( new Integer( results.getInt( 1 ) ) ) ? " Preferences" : "" ) %><%= ( teacherHasAvailability.contains( new Integer( results.getInt( 1 ) ) ) ? " Availability" : "" ) %>)</li><%
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
if ( conferences ) {
       response.sendRedirect("/parent/conferences.jsp");
} else if ( !setTimes ) {
response.sendRedirect("/parent/request.jsp");
} else if ( !setPreferences ) {
response.sendRedirect("/parent/request2.jsp");
} else {
response.sendRedirect("/parent/view.jsp");
}

} else {

/* session.setAttribute( "db", connect );
ResultSet results = state.executeQuery( "SELECT name FROM teachers WHERE teacherID = " + id );
results.first();
session.setAttribute( "teacherName", results.getString( 1 ) ); */
session.setAttribute( "teacherID", new Integer( id ) );
/* results = state.executeQuery( "SELECT * FROM available WHERE type = 1 AND ID = " + id );
boolean setTimes = results.first();
results = state.executeQuery( "SELECT * FROM conference WHERE teacherID = " + id  );
boolean conferences = results.first();
if ( conferences ) {
       response.sendRedirect("/teacher/conferences.jsp");
} else if ( !setTimes ) {
	response.sendRedirect("/teacher/request.jsp");
} else {
	response.sendRedirect("/teacher/view.jsp");
} */

response.sendRedirect("/teacher/");

} 

}
%>
</body>
</html>
