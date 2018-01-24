<%@page contentType="text/html"%>
<html>
<head><title>Administrator Interface</title></head>
<body>

<%@ page import="java.sql.*" %>

<body bgcolor="#cccccc">
<img src="images/flower_tech_3.jpg" />

<%
String passwd = request.getParameter( "passwd" );
if ( ( passwd == null || passwd.equals( "" ) ) && session.getAttribute( "admin" ) != Boolean.TRUE ) {
%>

<br><big><big style="font-weight: bold;">Enter Administrator Password</big></big><br>
<br>
<form method="post" action="admin.jsp">
<input type="password" name="passwd" />
<input type="submit" value="Login" />
</form>

<% 
} else if ( session.getAttribute( "admin" ) != Boolean.TRUE ) {

Connection connect = null;
Statement state = null;
try {
    Class.forName( "com.mysql.jdbc.Driver" ).newInstance();
    connect = DriverManager.getConnection( "jdbc:mysql://127.0.0.1/scheduler", "scheduler", "" );
    connect.setAutoCommit( true );
} catch ( Exception e ) {
    %>Internal error! Unable to connect to database."<%
}

try {
    PreparedStatement getPasswd = connect.prepareStatement( "SELECT adminPasswd FROM config" );
    ResultSet rgetPasswd = getPasswd.executeQuery();
    rgetPasswd.first();
    String adminPasswd = rgetPasswd.getString( 1 );

    PreparedStatement hashPassword = connect.prepareStatement( "SELECT PASSWORD( ? )" );
    hashPassword.setString( 1, request.getParameter( "passwd" ) );
    ResultSet hashedPasswd = hashPassword.executeQuery();
    hashedPasswd.first();
    if ( adminPasswd.equals( hashedPasswd.getString( 1 ) ) ) {
        session.setAttribute( "db", connect );
	session.setAttribute( "admin", Boolean.TRUE );
%>

<br><big><big style="font-weight: bold;">Administrative Options</big></big><br>
<ul>
<li><a href="setperiod.jsp">Set conference period</a></li>
<li><a href="adminpasswd.jsp">Set admin password</a></li>
<li><a href="su.jsp">Login as user</a></li>
<li><a href="smtp.jsp">Adjust SMTP settings</a></li>
<li><a href="template.jsp">Set mail templates</a></li>
<li>Send email: <a href="send_mail.jsp?type=schedule">Schedule</a> <a href="send_email.jsp?type=reminder">Reminder</a></li>
</ul>

<%
    } else {
        %><p>Sorry, you entered an invalid password.
        <br><a href="admin.jsp">Return</a> to the login page.<%
    }
} catch ( SQLException e ) {
    %><p>Internal Error<%
}

%>

<% } else { %>

<br><big><big style="font-weight: bold;">Administrative Options</big></big><br>
<ul>
<li><a href="setperiod.jsp">Set conference period</a></li>
<li><a href="adminpasswd.jsp">Set admin password</a></li>
<li><a href="su.jsp">Login as user</a></li>
<li><a href="smtp.jsp">Adjust SMTP settings</a></li>
<li><a href="template.jsp">Set mail templates</a></li>
<li>Send email: <a href="send_mail.jsp?type=schedule">Schedule</a> <a href="send_email.jsp?type=reminder">Reminder</a></li>
</ul>

<% } %>
</body>
</html>
