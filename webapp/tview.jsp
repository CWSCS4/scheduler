<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DateFormat" %>

<%
String teacherName = (String)session.getAttribute( "teacherName" );
int teacherID = ((Integer)session.getAttribute( "teacherID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

int numberOfTimeSlots = 0;

if ( teacherName == null ) {
   %><jsp:forward page="tlogin.jsp" /><%
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
  <title>Conference Information for <%= teacherName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />
<br><big><big style="font-weight: bold;">Conference Information for
<%= teacherName %></big></big><br>
<br>

You have indicated that you will be available for the following time slots:
<ul><%

ResultSet results = state.executeQuery( "SELECT start, end FROM available WHERE type = 1 AND ID = " + teacherID );

while( results.next() ) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format( results.getTimestamp( 1 ) ) + " " + tdf.format( results.getTimestamp( 1 ) ) %> - <%= tdf.format( results.getTimestamp( 2 ) ) %></li>
<% } %></ul>

<p />

Your have selected that you would like to meet with the following students in the priority listed: (9 is highest priority)
<p><%

results = state.executeQuery( "SELECT students.name, rank FROM preferences LEFT JOIN students ON preferences.withID = students.studentID WHERE isTeacher = 1 AND ID = " + teacherID + " ORDER BY preferences.rank" );
%>
<table border="1">
<tr><td>Priority</td><td>Student</td></tr>
<%
while( results.next() ) { %>
    <tr><td><%= results.getInt( 2 ) %></td><td><%= results.getString( 1 ) %></td></tr>
<% } %>
</table>
<br>

<%
results = state.executeQuery( "SELECT email FROM teachers WHERE teacherID = " + teacherID );
results.first();
%>
You have indicated that you wish your final schedule to be emailed to "<%= results.getString( 1 ) %>".

<p>Please click <a href="trequest.jsp">here</a> if you would like to change this information by redoing the signup procedure.

</body>
</html>
