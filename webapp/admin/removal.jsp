<%@ include file="/include/init.jsp" %>
<%@ include file="/include/doctype.jsp" %>
<% Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>





<html>
<head>
<%@ include file="/include/meta.jsp" %>
<title>Remove a student/conference/teacher</title>
</head>

<body>
<%@ include file="/include/admin_header.jsp"%>

<%-- Check to See If a Form Submission Exists and Deals With It--%>
<% if (request.getParameter("submitted") != null || request.getParameter("submitted").equals("yes")) {
        
        int formTeacherID = Integer.parseInt(request.getParameter("teacherID"));
        int formStudentID = Integer.parseInt(request.getParameter("studentID"));
        PreparedStatement deletion = connect.prepareStatement("DELETE FROM conference WHERE conference.teacherID = ? AND conference.studentID = ? ");
        deletion.setInt(1, formTeacherID );
        deletion.setInt(2, formStudentID);
        deletion.executeUpdate();

        %><script>slideElem("conferences")    
}%>

    <%-- Script to Slide Up or Down an Element --%>
    <script>
        function slideElem(id) {
            if ($("#" + id).css("display") == "none") {
                $("#" + id).slideDown('slow');
            } else {
                $("#" + id).slideUp('slow');
            }
        }
    </script>
<ul>
<li><a href="#students">Students</a></li>
<li><a href="#teachers">Teachers</a></li>
</ul>

<h3 id="students">Students</h3> 

<ul id=studentList><% 
ResultSet results = state.executeQuery("SELECT name, studentID FROM students");
DateFormat ddf = new SimpleDateFormat("MMMM, d @ h:mm a");

// While there are students in the ResultSet results, display them.
while (results.next()) {
PreparedStatement conferenceQuery = connect.prepareStatement("SELECT teachers.name, conference.start, teachers.room, teachers.teacherID FROM conference JOIN students on students.studentID = conference.studentID JOIN teachers ON teachers.teacherID = conference.teacherID WHERE students.studentID = ?");
conferenceQuery.setInt(1, results.getInt(2));
ResultSet conferenceResults = conferenceQuery.executeQuery();
%><li id=<%=String.valueOf(results.getInt(2))%>>

<%-- Display Name of Student --%>
    <div onclick="slideElem('conferences<%=String.valueOf(results.getInt(2))%>')" style="color:blue; text-decoration:underline; cursor: pointer">
        <%=results.getString(1)%>
    </div>

<%-- Show All Planned Conferences for Student --%>
<div id="conferences<%=String.valueOf(results.getInt(2))%>"  style="display:none; padding: 0px 0px 50px">
    <table style="border: 2px solid grey; ">
        <tr><th>Teacher</th><th>Time</th><th>Room</th><th> </th></tr><%

        // While There Are Conferences in the ResultSet conferenceResults, display them.
        while (conferenceResults.next()) {%>
            <tr>
                <td><%=conferenceResults.getString(1)%></td>
                <td><%=ddf.format(conferenceResults.getTimestamp(2))%></td>
                <td><%=conferenceResults.getString(3)%></td>
                <td> 
                    <form action="removal.jsp" method="post"> 
                        <input type="hidden" value='<%=(conferenceResults.getInt(4))%>' name="teacherID">
                        <input type="hidden" value='<%=(results.getInt(2))%>' name="studentID">
                        <input type="hidden" value="yes" name="submitted">
                        <button value="x"> x </button> 
                    </form>
                </td>
            </tr>
        <%}%>
    </table>
</div>


</li><%}%>
</ul>

<h3 id="teachers">Teachers</h3>
<ul><%
    results = state.executeQuery("SELECT name, teacherID FROM teachers");
    while (results.next()) {
        %><li><%=results.getString(1)%></li>
    <%}%>
</ul>

</body>
</html>