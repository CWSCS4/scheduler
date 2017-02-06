<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DateFormat" %>

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
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Conference Information for <%= studentName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />
<br><big><big style="font-weight: bold;">Conference Information for
<%= studentName %></big></big><br>
<br>

You have indicated that you will be available for the following time slots:
<ul><%

ResultSet results = state.executeQuery( "SELECT start, end FROM available WHERE type = 0 AND ID = " + studentID );

while( results.next() ) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format( results.getTimestamp( 1 ) ) + " " + tdf.format( results.getTimestamp( 1 ) ) %> - <%= tdf.format( results.getTimestamp( 2 ) ) %></li>
<% } %></ul>

<p />

Your have selected that you would like to meet with the following teachers in the priority listed: (9 is highest priority)
<p><%

results = state.executeQuery( "SELECT teachers.name, rank, max_conferences FROM preferences LEFT JOIN teachers ON preferences.withID = teachers.teacherID WHERE isTeacher = 0 AND ID = " + studentID + " ORDER BY preferences.rank" );
%>
<table border="1">
<tr><td>Priority</td><td>Teacher</td></tr>
<%
while( results.next() ) { %>
    <tr><td><%= results.getInt( 2 ) %><%= results.getInt( 3 ) > 1 ? " (2 conferences)" : "" %></td><td><%= results.getString( 1 ) %></td></tr>
<% } %>
</table>
<br>
<%
results = state.executeQuery( "SELECT email FROM students WHERE studentID = " + studentID );
results.first();
%>
You have indicated that you wish your final schedule to be emailed to "<%= results.getString( 1 ) %>".

<p>Please click <a href="request.jsp">here</a> if you would like to change this information by redoing the signup procedure.

</body>
</html>
