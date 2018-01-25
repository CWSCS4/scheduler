<%@ include file="/include/init.jsp" %>

<%
Statement state = null;
int numberOfTimeSlots = 0;
state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Add Conference</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<select>
<option value="Remove Parent"></option>
<option value="Remove Student"></option>
</select>
<button type="button">execute</button>
<% } else {
state.executeUpdate("INSERT INTO conferences values ");
}
%><jsp:forward page="admin.jsp" /><%
} %>
</body>
</html>
