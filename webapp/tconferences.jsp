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
  <title>Conferences Scheduled for <%= teacherName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />
<br><big><big style="font-weight: bold;">Conferences Scheduled for
<%= teacherName %></big></big><br>
<br>

Your have been scheduled for the following conferences:
<p><%

ResultSet results = state.executeQuery( "SELECT students.name, start FROM conference LEFT JOIN students ON conference.studentID = students.studentID WHERE teacherID = " + teacherID + " ORDER BY start" );
%>
<table border="1">
<tr><td>Student</td><td>Time</td></tr>
<%
while( results.next() ) { 
   DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance(); %>
    <tr><td><%= results.getString( 1 ) %></td><td><%= ddf.format( results.getTimestamp( 2 ) ) + " " + tdf.format( results.getTimestamp( 2 ) ) %></td></tr>
<% } %>
</table>
<br>

</body>
</html>
