<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
String teacherName = (String)session.getAttribute( "teacherName" );
int teacherID = ((Integer)session.getAttribute( "teacherID" )).intValue();
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

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
  <title>Request Conferences for <%= teacherName %></title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted3" ) == null || !request.getParameter( "submitted3" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">Final Options (Step 3 of 3)</big></big><br>


<form action="trequest3.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT email FROM teachers WHERE teacherID = " + teacherID );
results.first();
%>

<p>Please enter the email address at which you would like to receive messages regarding your conference schedule:
<br><input type="text" name="email" value="<%= results.getString(1) == null ? "" : results.getString( 1 ) %>" />

<p>If you want to change your password, here is your opportunity:
<br><input type="password" name="oldpasswd" /> Old Password
<br><input type="password" name="newpasswd" /> New Password
<br><input type="password" name="confirmpasswd" /> Repeat New Password

<p><input type="submit" value="Finish" />
<input type="hidden" name="submitted3" value="yes" />
</form>

<% } else { %>

<%
boolean errors = false;

ResultSet results = state.executeQuery( "SELECT teacherID, email FROM teachers WHERE teacherID = " + teacherID );
results.first();

String email = request.getParameter( "email" );
if ( email.equals( "" ) || email == null ) {
   errors = true;
   %><p>You did not enter an email address.<%
}
results.updateString( 2, email );
results.updateRow();

String oldpasswd = request.getParameter( "oldpasswd" );
String newpasswd = request.getParameter( "newpasswd" );
String confirmpasswd = request.getParameter( "confirmpasswd" );

results = state.executeQuery( "SELECT PASSWORD('" + oldpasswd + "')" );
results.first();
String oldpasswdh = results.getString( 1 );

results = state.executeQuery( "SELECT PASSWORD('" + newpasswd + "')" );
results.first();
String newpasswdh = results.getString( 1 );

results = state.executeQuery( "SELECT teacherID, password FROM teachers WHERE teacherID = " + teacherID );
results.first();

if ( results.getString( 2 ).equals( oldpasswdh ) && newpasswd.equals( confirmpasswd ) ) {
   results.updateString( 2, newpasswdh );
   results.updateRow();
}

%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="tconfirm.jsp" />
<% } %>
<% } %>
</body>
</html>

