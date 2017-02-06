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
  <title>Conferences Scheduled for <%= studentName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />
<br><big><big style="font-weight: bold;">Conferences Scheduled for
<%= studentName %></big></big><br>
<br>

Your have been scheduled for the following conferences:
<p><%

ResultSet results = state.executeQuery( "SELECT teachers.name, conference.start FROM conference LEFT JOIN teachers ON conference.teacherID = teachers.teacherID WHERE studentID = " + studentID + " ORDER BY start" );
%>
<table border="1">
<tr><td>Teacher</td><td>Time</td></tr>
<%
while( results.next() ) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance(); %>
    <tr><td><%= results.getString( 1 ) %></td><td><%= ddf.format( results.getTimestamp( 2 ) ) + " " + tdf.format( results.getTimestamp( 2 ) ) %></td></tr>
<% } %>
</table>
<br>

<p>As the schedule has already been generated you can no longer enter or change your preferences. If there is a problem please call the school.</p>

</body>
</html>
