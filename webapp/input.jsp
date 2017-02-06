<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.*" %>
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
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Data Input</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">Data Input</big></big><br>

<p>

<form action="template.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT * FROM templates" );

while ( results.next() ) {
      %><p><bold><%= results.getString( 1 ) %>:</bold>
      <br><textarea name="<%= results.getString( 1 ) %>" rows="10" cols="80"><%= results.getString( 2 ) %></textarea>
      <%
}

%>

<p><input type="submit" value="Submit"/>
<input type="hidden" name="submitted" value="yes"/>
</form>



<% } else { %>

<%
ResultSet results = state.executeQuery( "SELECT * FROM templates" );

while ( results.next() ) {
      results.updateString( 2, request.getParameter( results.getString( 1 ) ) );
      results.updateRow();
}

results.close();

%><jsp:forward page="admin.jsp" /><%

} %>
</body>
</html>
