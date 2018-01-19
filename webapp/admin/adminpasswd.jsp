<%@ include file="/include/init.jsp" %>

<%
Statement state = null;
int numberOfTimeSlots = 0;
state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Set Admin Password</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Set Admin Password</h2>
<form action="adminpasswd.jsp" method="post">
<p><input type="password" name="current" /> Current Password<br />
<input type="password" name="new" /> New Password<br />
<input type="password" name="repeat" /> Retype Password</p>
<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>
<% } else {
ResultSet results = state.executeQuery("SELECT priKey, adminPasswd FROM config");
results.first();
String current = results.getString(2);
results = state.executeQuery("SELECT PASSWORD('" + request.getParameter("current") + "'), PASSWORD('" + request.getParameter("new") + "')");
results.first();

String currenth = results.getString(1);
String newh = results.getString(2);

if (current.equals(currenth)) {
   if (request.getParameter("new").equals(request.getParameter("repeat"))) {
      results = state.executeQuery("SELECT priKey, adminPasswd FROM config");
      results.first();
      results.updateString(2, newh);
      results.updateRow();
      results.close();
   } else {
      %>Two passwords do not match. <a href="adminPasswd.jsp">Click here</a> to try again.<%
   }
} else {
%>Admin password is incorrect. <a href="adminPasswd.jsp">Click here</a> to try again.<%
}
%><jsp:forward page="admin.jsp" /><%
} %>
</body>
</html>
