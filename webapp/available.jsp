<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.text.DateFormat" %>
<%@ page import="java.sql.*" %>
<%
String studentName = (String)session.getAttribute( "studentName" );
int studentID = ((Integer)session.getAttribute( "studentID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

int numberOfTimeSlots = 0;

if ( studentName == null ) {
   %><jsp:forward page="login.jsp" /><%
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
  <title>Availability Information</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />
<br><big><big style="font-weight: bold;">Availability Information for
<%= studentName %>'s Teachers</big></big><br>

<%
ResultSet results = state.executeQuery( "SELECT teachers.teacherID, teachers.name, classes.name, start, end FROM available LEFT JOIN teachers ON available.ID = teachers.teacherID LEFT JOIN classes ON teachers.teacherID = classes.teacherID LEFT JOIN classMembers ON classMembers.classID = classes.classID WHERE available.type = 1 AND classMembers.studentID = " + studentID );

int lastID = -1;

while ( results.next() ) {
    if ( lastID != results.getInt( 1 ) ) {
       %></ul><p><%= results.getString( 2 ) %> (<%= results.getString( 3 ) %>):
       <ul><%
    }
    lastID = results.getInt( 1 );
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format( results.getTimestamp(4) ) + " " + tdf.format( results.getTimestamp(4) ) %> - <%= tdf.format( results.getTimestamp(5) ) %></li>
<% } %>
</body>
</html>
