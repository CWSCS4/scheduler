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
  <title>SMTP Settings</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">SMTP Settings</big></big><br>

<form action="smtp.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT SMTPserver, mailFrom FROM config" );
results.first();
%>

<p><input type="text" name="server" value="<%= results.getString( 1 ) == null ? "" : results.getString( 1 ) %>"/> SMTP Server
<br><input type="text" name="from" value="<%= results.getString( 2 ) == null ? "" : results.getString( 2 ) %>"/> Return address for all messages

<p><input type="submit" value="Continue"/>
<input type="hidden" name="submitted" value="yes"/>
</form>



<% } else { %>

<%
ResultSet results = state.executeQuery( "SELECT priKey, SMTPserver, mailFrom FROM config" );
results.first();

results.updateString( 2, request.getParameter( "server" ) );
results.updateString( 3, request.getParameter( "from" ) );
results.updateRow();

results.close();

%><jsp:forward page="admin.jsp" /><%

} %>
</body>
</html>
