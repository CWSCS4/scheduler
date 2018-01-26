<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Conference Information for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<br><big><big style="font-weight: bold;">Conference Information for
<%= studentName %></big></big><br>
<br>

You have indicated that you will be available for the following time slots:
<ul><%

ResultSet results = state.executeQuery( "SELECT start, end FROM available WHERE type = 0 AND ID = " + studentID );

while( results.next() ) { 
    DateFormat tdf = new SimpleDateFormat("h:mm a");
    DateFormat ddf = new SimpleDateFormat("MMMM d 'at' h:mm a");
    %><li><%= ddf.format( results.getTimestamp( 1 ) ) %> - <%= tdf.format( results.getTimestamp( 2 ) ) %></li>
<% } %></ul>

<p />

Your have selected that you would like to meet with the following teachers:
<p><%

results = state.executeQuery( "SELECT teachers.name, rank, max_conferences FROM preferences LEFT JOIN teachers ON preferences.withID = teachers.teacherID WHERE isTeacher = 0 AND ID = " + studentID + " ORDER BY preferences.rank" );
%>
<table>
    <tr><td>Importance</td><td>Teacher</td></tr>
    <%
    while(results.next()) { %>
        <tr>
            <td><% 
                
                switch(results.getInt(2)){
                   case 1:
                        %>Not Important<%
                        break;
                   case 3:
                        %>Somewhat Important<%
                        break;
                   case 5:
                        %>Important<%
                        break;
                   case 7:
                        %>Very Important<%
                        break;
                   case 9:
                        %>Urgent<%
                        break;  
                }
                %><%= (results.getInt(3) > 1) ? " (2 conferences)" : "" %></td>
            <td><%= results.getString(1) %></td>
        </tr>
    <% } %>
    </table>
<br>
<%
results = state.executeQuery( "SELECT email FROM students WHERE studentID = " + studentID );
results.first();
%>
<!-- [areyzin] disabled emails
You have indicated that you wish your final schedule to be emailed to "<%= results.getString( 1 ) %>".
-->
<p>Please click <a href="/parent/request.jsp">here</a> if you would like to change this information by redoing the signup procedure.

</body>
</html>
