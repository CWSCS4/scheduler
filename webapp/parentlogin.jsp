<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement();
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Parent Login</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<h2>Log in (Parents)</h2>
<form action="parentauth.jsp" method="post">
<p>Student Name: <select name="user">
<%
ResultSet results = state.executeQuery("SELECT name, studentID FROM students ORDER BY name");
while (results.next()) { %>
<option value="<%= results.getInt(2) %>"><%= results.getString(1) %></option>
<% } %>
</select></p>
<p>Password: <input type="password" name="passwd"></p>
<p><input type="submit" name="Login" value="Login" /></p>
</form>
</body>
</html>
