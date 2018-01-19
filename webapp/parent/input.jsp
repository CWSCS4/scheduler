<%@ include file="/include/init.jsp" %>

<%
Statement state = state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Data Input</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Data Input</h2>
<form action="template.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT * FROM templates" );

while (results.next()) { %>
<h3><%= results.getString(1) %>:</h3>
<p><textarea name="<%= results.getString(1) %>" rows="10" cols="80"><%= results.getString(2) %></textarea></p>
<% } %>

<p><input type="submit" value="Submit" /></p>
<input type="hidden" name="submitted" value="yes" />
</form>

<% } else {

ResultSet results = state.executeQuery("SELECT * FROM templates");

while (results.next()) {
      results.updateString(2, request.getParameter(results.getString(1)));
      results.updateRow();
}

results.close();

%><jsp:forward page="admin.jsp" /><%

} %>
</body>
</html>
