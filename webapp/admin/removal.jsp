<%@ include file="/include/init.jsp" %>
<%@ include file="/include/doctype.jsp" %>
<% Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>





<html>
<head>
<%@ include file="/include/meta.jsp" %>
<title>Remove a student/conference/teacher</title>
</head>


<style>
        button.deleteStudentButton {
            display: inline-block;
            padding: 15px 25px;
            font-size: 24px;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            outline: none;
            color: #fff;
            background-color: black;
            border: none;
            border-radius: 15px;
        }
        
        button:hover.deleteStudentButton {background-color: rgb(121, 0, 0); color: black}
        
        button:active.deleteStudentButton {
            background-color: rgb(121, 0, 0);
            transform: scale(.9);
        }
    </style>

<body>
<%@ include file="/include/admin_header.jsp"%>

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

<!-- Check to See If a Form Submission Exists and Deals With It -->
<% if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("yes")) {
        
    switch (request.getParameter("type")) {
        case ("conferenceDeletion") :
            int formTeacherID = Integer.parseInt(request.getParameter("teacherID"));
            int formStudentID = Integer.parseInt(request.getParameter("studentID"));
            PreparedStatement deletion = connect.prepareStatement("DELETE FROM conference WHERE conference.teacherID = ? AND conference.studentID = ? ");
            deletion.setInt(1, formTeacherID );
            deletion.setInt(2, formStudentID);
            deletion.executeUpdate();
            break;

        case ("studentDeletion") : 
            int formStudent = Integer.parseInt(request.getParameter("studentID"));
            PreparedStatement deletionStudents = connect.prepareStatement("DELETE FROM students WHERE students.studentID = ?");
            PreparedStatement deletionConferences = connect.prepareStatement("DELETE FROM conference WHERE conference.studentID = ?");
            PreparedStatement deletionClassmembers = connect.prepareStatement("DELETE FROM classmembers WHERE classmembers.studentID = ?");
            PreparedStatement deletionPreferences = connect.prepareStatement("DELETE FROM preferences WHERE preferences.ID = ? AND isTeacher = 0");

            deletionStudents.setInt(1, formStudent);
            deletionConferences.setInt(1, formStudent);
            deletionClassmembers.setInt(1, formStudent);
            deletionPreferences.setInt(1, formStudent);

            deletionStudents.executeUpdate();
            deletionConferences.executeUpdate();
            deletionClassmembers.executeUpdate();
            deletionPreferences.executeUpdate();
            
            break;
        case ("teacherDeletion") : 
            int formTeacher = Integer.parseInt(request.getParameter("teacherID"));
            PreparedStatement deletionTeachers = connect.prepareStatement("DELETE FROM teachers WHERE teachers.teacherID = ?");
            PreparedStatement deltionTeacherConferences = connect.prepareStatement("DELETE FROM conference WHERE conference.teacherID = ?");
            PreparedStatement deletionTeacherPreferences = connect.prepareStatement("DELETE FROM preferences WHERE preferences.ID = ? AND isTeacher = 0");
            PreparedStatement deletionTeacherClass = connect.prepareStatement("DELETE FROM classes WHERE classes.teacherID = ?");
            
            PreparedStatement retrieveTeacherClasses = connect.prepareStatement("SELECT classID FROM classes WHERE teacherID = ?");
            retrieveTeacherClasses.setInt(1, formTeacher);
            ResultSet classes = retrieveTeacherClasses.executeQuery();


            deletionTeachers.setInt(1, formTeacher);
            deltionTeacherConferences.setInt(1, formTeacher);
            deletionTeacherPreferences.setInt(1, formTeacher);
            deletionTeacherClass.setInt(1, formTeacher);

            deletionTeachers.executeUpdate();
            deltionTeacherConferences.executeUpdate();
            deletionTeacherPreferences.executeUpdate();
            deletionTeacherClass.executeUpdate();
            

            PreparedStatement deleteClassmembers = connect.prepareStatement("DELETE FROM classmembers WHERE classID = ?");
            while (classes.next()) {
                deleteClassmembers.setInt(1, classes.getInt(1));
                deleteClassmembers.executeUpdate();
            }

            break;
    }
        
}%>


    
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
        <div id='student<%=String.valueOf(results.getInt(2))%>' onclick="slideElem('conferences<%=String.valueOf(results.getInt(2))%>')" style="color:blue; text-decoration:underline; cursor: pointer; padding: 5px">
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
                            <input type="hidden" value="conferenceDeletion" name="type">
                            <button value="x"> x </button> 
                        </form>
                    </td>
                </tr>
            <%}%>
        </table>
        <form>
            <input type="hidden" value="<%=String.valueOf(results.getInt(2))%>" name="studentID">
            <input type="hidden" value="studentDeletion" name="type">
            <input type="hidden" id='submit<%=String.valueOf(results.getInt(2))%>' value="no" name="submitted">
            <script>
                function makeSure(id, name) {
                    if (confirm("Are you sure you want to delete " + name + "?")) {
                        $('#submit' + id).val("yes");
                    } else {
                        $('#submit' + id).val("no");
                    }
                }
            </script>
            <button onClick='makeSure("<%=String.valueOf(results.getInt(2))%>", "<%=results.getString(1)%>")' class="deleteStudentButton">
                delete student
            </button>
        </form>
    </div>


    </li>
<%}%>
</ul>

<h3 id="teachers">Teachers</h3>
<ul><%
    results = state.executeQuery("SELECT name, teacherID FROM teachers");
    while (results.next()) {%>
        <%-- Display Name of Student --%>
        <div id='teacher<%=String.valueOf(results.getInt(2))%>' onclick="slideElem('teacherRemoval<%=String.valueOf(results.getInt(2))%>')" style="color:blue; text-decoration:underline; cursor: pointer; padding: 5px">
            <%=results.getString(1)%>
        </div>

        <form>
            <input type="hidden" value="<%=String.valueOf(results.getInt(2))%>" name="teacherID">
            <input type="hidden" value="teacherDeletion" name="type">
            <input type="hidden" id='submit<%=String.valueOf(results.getInt(2))%>' value="no" name="submitted">
            <script>
                function makeSure(id, name) {
                    if (confirm("Are you sure you want to delete " + name + "?")) {
                        $('#submit' + id).val("yes");
                    } else {
                        $('#submit' + id).val("no");
                    }
                }
            </script>
            <button onClick='makeSure("<%=String.valueOf(results.getInt(2))%>", "<%=results.getString(1)%>")' class="deleteTeacherButton">
                delete teacher
            </button>
        </form>
    <%}%>
</ul>


<% if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("yes")) {
        
    int formStudentID = Integer.parseInt(request.getParameter("studentID"));
    %><script>
    $('#conferences<%=String.valueOf(request.getParameter("studentID"))%>').css("display", "inline");
    $('html, body').animate({
                scrollTop: ($('#student<%=String.valueOf(request.getParameter("studentID"))%>').offset().top)
            }, 0);
    </script><%

}%>
</body>
</html>