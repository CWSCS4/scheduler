<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

int numberOfTimeSlots = 0;

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
  <title>Set Admin Password</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">SMTP Settings</big></big><br>

<form action="adminpasswd.jsp" method="post">

<p><input type="password" name="current" /> Current Password
<br><input type="password" name="new" /> New Password
<br><input type="password" name="repeat" /> Retype Password

<p><input type="submit" value="Continue"/>
<input type="hidden" name="submitted" value="yes"/>
</form>



<% } else { %>

<%
ResultSet results = state.executeQuery( "SELECT priKey, adminPasswd FROM config" );
results.first();

String current = results.getString( 2 );

results = state.executeQuery( "SELECT PASSWORD( '" + request.getParameter( "current" ) + "' ), PASSWORD( '" + request.getParameter( "new" ) + "' )" );
results.first();

String currenth = results.getString( 1 );
String newh = results.getString( 2 );

if ( current.equals( currenth ) ) {
   if ( request.getParameter( "new" ).equals( request.getParameter( "repeat" ) ) ) {
      results = state.executeQuery( "SELECT priKey, adminPasswd FROM config" );
      results.first();
      results.updateString( 2, newh );
      results.updateRow();
      results.close();
   } else {
      %>Two passwords do not match. <a href="adminPasswd.jsp">Click here</a> to try again.<%
   }
} else {
%>Admin password is incorrent. <a href="adminPasswd.jsp">Click here</a> to try again.<%
}

%><jsp:forward page="admin.jsp" /><%

} %>
</body>
</html>
