<%@page contentType="text/html"%>
<html>
<head><title>Login</title></head>
<body bgcolor="#cccccc">

<%@ page import="java.sql.*" %>

<%
Connection connect = null;
Statement state = null;
try {
    Class.forName( "com.mysql.jdbc.Driver" ).newInstance();
    connect = DriverManager.getConnection( "jdbc:mysql://127.0.0.1/scheduler", "scheduler", "" );
    state = connect.createStatement();
} catch ( Exception e ) {
    %>Error accessing database: <%= e %><%
}
%>
<img src="images/flower_tech_1.jpg" />
<h1>Login to the Scheduler <br>
</h1>
<form action="auth.jsp" method="post">
  <table cellpadding="2" cellspacing="2" border="0"
 style="text-align: left;">
    <tbody>
      <tr>
        <td style="vertical-align: top;"><big>Name:<br>
        </big></td>
        <td style="vertical-align: top;">
        <h1><select name="user">
<%
ResultSet results = state.executeQuery( "SELECT name, studentID FROM students ORDER BY name" );
while ( results.next() ) {
    %><option value="<%= results.getInt( 2 ) %>"><%= results.getString( 1 ) %>
<% } %>
</select></h1>
        </td>
      </tr>
      <tr>
        <td style="vertical-align: top;"><big>Password:<br>
        </big></td>
        <td style="vertical-align: top;">
        <h1><input type="password" name="passwd"></h1>
        </td>
      </tr>
    </tbody>
  </table>
  <br>
  <input type="submit" name="Login" value="Login">
</form>

</body>
</html>

