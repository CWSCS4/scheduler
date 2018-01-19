<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Mail Templates</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<h2>Mail Templates</h2>

<p>The following templates are used for all email messages sent from the
scheduler application. Here is where you can also set the contents of the
From:, To:, and Subject: lines for each message. The information sent in
these messages is inserted in the place of the following keywords.</p>

<p>%p - parent name (not supported yet)<br />
%n - student name<br />
%e - email address<br />
%a - reply address<br />
%s - start time<br />
%f - end time<br />
%r - priority ranking<br />
%t - teacher name<br />
%l - meeting location<br />
%c - class name<br />
%x - start/end availability time repeat block<br />
%y - start/end ranking repeat block<br />
%z - start/end conferences repeat block</p>

<form action="template.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT * FROM templates" );

while ( results.next() ) {
      %><h3><%= results.getString( 1 ) %>:</h3>
      <p><textarea name="<%= results.getString( 1 ) %>" rows="10" cols="70"><%= results.getString( 2 ) %></textarea></p>
      <%
}

%>

<p><input type="submit" value="Submit"/></p>
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

%><jsp:forward page="/admin/" /><%

} %>
</body>
</html>
