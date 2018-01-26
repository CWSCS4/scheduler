<%@ include file="/include/init.jsp" %>
<%@ include file="/include/doctype.jsp" %>
<% Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>
<% Statement state2 = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>





<html>
<head>
<%@ include file="/include/meta.jsp" %>
<title>Remove a student/conference/teacher</title>
</head>


<style>
        button {
            cursor: pointer;
        }

        button.deleteStudentButton {
            background: #bd4f4f;
            margin-top: 5px;
            width: 100%;    
            font-size: 24px;
            outline:none;
            border-radius: 5px;
            border:none;
            background: -webkit-linear-gradient(top, #bd4f4f 0, #ad3636 100%);
            background: linear-gradient(to bottom, #bd4f4f 0, #7c1212 100%);
            box-shadow: 0 2px 0 #3b0a0a;
            color: #f8f8f8;
        }

        button:hover.deleteStudentButton {background-color: rgb(121, 0, 0); color: #f8f8f8}
        
        button:active.deleteStudentButton {
            background-color: rgb(121, 0, 0);
            background: linear-gradient(to bottom, #7c1212 0, #bd4f4f 100%);
            box-shadow: 0 -2px 0 #3b0a0a;
            transform: scale(.96);
        }

        button.deleteTeacherButton {
            background: #bd4f4f; 
            font-size: 12px;
            outline:none;
            border-radius: 5px;
            border:none;
            background: -webkit-linear-gradient(top, #bd4f4f 0, #ad3636 100%);
            background: linear-gradient(to bottom, #bd4f4f 0, #7c1212 100%);
            box-shadow: 0 2px 0 #3b0a0a;
            color: #f8f8f8;
        }

        button:hover.deleteTeacherButton {background-color: rgb(121, 0, 0); color: #f8f8f8}
        
        button:active.deleteTeacherButton {
            background-color: rgb(121, 0, 0);
            background: linear-gradient(to bottom, #7c1212 0, #bd4f4f 100%);
            box-shadow: 0 -2px 0 #3b0a0a;
            transform: scale(.96);
        }
        button.deleteNoShowsButton {
            background: #bd4f4f; 
            font-size: 12px;
            outline:none;
            border-radius: 5px;
            border:none;
            background: -webkit-linear-gradient(top, #bd4f4f 0, #ad3636 100%);
            background: linear-gradient(to bottom, #bd4f4f 0, #7c1212 100%);
            box-shadow: 0 2px 0 #3b0a0a;
            color: #f8f8f8;
        }

        button:hover.deleteNoShowsButton {background-color: rgb(121, 0, 0); color: #f8f8f8}
        
        button:active.deleteNoShowsButton {
            background-color: rgb(121, 0, 0);
            background: linear-gradient(to bottom, #7c1212 0, #bd4f4f 100%);
            box-shadow: 0 -2px 0 #3b0a0a;
            transform: scale(.96);
        }
        button.deleteAllNoShowsButton {
            background: #bd4f4f; 
            font-size: 15px;
            outline:none;
            border-radius: 5px;
            width: 100%;
            border:none;
            margin: 10px;
            background: -webkit-linear-gradient(top, #bd4f4f 0, #ad3636 100%);
            background: linear-gradient(to bottom, #bd4f4f 0, #7c1212 100%);
            box-shadow: 0 2px 0 #3b0a0a;
            color: #f8f8f8;
        }

        button:hover.deleteAllNoShowsButton {background-color: rgb(121, 0, 0); color: #f8f8f8}
        
        button:active.deleteAllNoShowsButton {
            background-color: rgb(121, 0, 0);
            background: linear-gradient(to bottom, #7c1212 0, #bd4f4f 100%);
            box-shadow: 0 -2px 0 #3b0a0a;
            transform: scale(.96);
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
        case ("noShowsDeletion") :
            PreparedStatement getNoShowsQuery = connect.prepareStatement("SELECT studentID FROM students WHERE hasSetAvail = 0 ");
            ResultSet allNoShows = getNoShowsQuery.executeQuery();

            
            PreparedStatement deleteStudents;
            PreparedStatement deleteConferences;
            PreparedStatement deleteClassmembersAllNoShows;
            PreparedStatement deletePreferences;

            while (allNoShows.next()) {
                deleteStudents = connect.prepareStatement("DELETE FROM students WHERE students.studentID = ?");
                deleteConferences = connect.prepareStatement("DELETE FROM conference WHERE conference.studentID = ?");
                deleteClassmembersAllNoShows = connect.prepareStatement("DELETE FROM classmembers WHERE classmembers.studentID = ?");
                deletePreferences = connect.prepareStatement("DELETE FROM preferences WHERE preferences.ID = ? AND isTeacher = 0");

                deleteStudents.setInt(1, allNoShows.getInt(1));
                deleteConferences.setInt(1, allNoShows.getInt(1));
                deleteClassmembersAllNoShows.setInt(1, allNoShows.getInt(1));
                deletePreferences.setInt(1, allNoShows.getInt(1));
                
                deleteStudents.executeUpdate();
                deleteConferences.executeUpdate();
                deleteClassmembersAllNoShows.executeUpdate();
                deletePreferences.executeUpdate();
            }
    }
        
}%>


<div onClick='slideElem("noShows")' style="color:blue; text-decoration:underline; cursor: pointer;">
    <h3>No Shows</h3>
</div>

<div style="display:none" id="noShows">
    <form>
        <input type="hidden" value="noShowsDeletion" name="type">
        <input type="hidden" id='submitNoShows' value="no" name="submitted">
        <script>
                function makeSureNoShows() {
                    if (confirm("Are you sure you want to delete all no shows?")) {
                        $('#submitNoShows').val("yes");
                    } else {
                        $('#submitNoShows').val("huh?");
                    }
                }
        </script>
        <button onClick='makeSureNoShows()' class="deleteAllNoShowsButton">
            Delete All No Shows
        </button>
    </form>

    <ul>
        <% ResultSet noShows = state.executeQuery("SELECT name, studentID FROM students WHERE hasSetAvail = 0");

        while (noShows.next()) {
            %><li>

            <%-- Display Name of Student --%>
                <div id='noShows<%=String.valueOf(noShows.getInt(2))%>' onclick="slideElem('noShowsConferences<%=String.valueOf(noShows.getInt(2))%>')" style="padding: 5px">
                    <%=noShows.getString(1)%>
                </div>

                    <form>
                        <input type="hidden" value="<%=String.valueOf(noShows.getInt(2))%>" name="studentID"></input>
                        <input type="hidden" value="studentDeletion" name="type"></input>
                        <input type="hidden" id='submit<%=String.valueOf(noShows.getInt(2))%>' value="no" name="submitted"></input>
                        <script>
                            function makeSure(id, name) {
                                if (confirm("Are you sure you want to delete " + name + "?")) {
                                    $('#submit' + id).val("yes");
                                } else {
                                    $('#submit' + id).val("no");
                                }
                            }
                        </script>
                        <button onClick='makeSure("<%=String.valueOf(noShows.getInt(2))%>", "<%=noShows.getString(1)%>")' class="deleteNoShowsButton">
                            Delete Student
                        </button>
                    </form>
            </li>
        <%}%>
    </ul>
</div>

<div onClick='slideElem("students")' style="color:blue; text-decoration:underline; cursor: pointer;"> 
    <h3>Students</h3> 
</div>

<ul id=students style="display:none;"><% 
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
                Delete Student
            </button>
        </form>
    </div>


    </li>
        <%}%>
</ul>

<div onClick='slideElem("teachers")' style="color:blue; text-decoration:underline; cursor: pointer;">
    <h3>Teachers</h3>
</div>

<ul id="teachers" style="display:none"><%
    results = state.executeQuery("SELECT name, teacherID FROM teachers");
    while (results.next()) {%>
        <%-- Display Name of Student --%>
        <div id='teacher<%=String.valueOf(results.getInt(2))%>' onclick="slideElem('teacherRemoval<%=String.valueOf(results.getInt(2))%>')" style="padding: 5px">
            <li><%=results.getString(1)%></li>
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
                Delete Teacher
            </button>
        </form>
    <%}%>
</ul>


<% if (request.getParameter("submitted") != null && request.getParameter("submitted").equals("yes") && request.getParameter("type").equals("conferenceDeletion")) {
        
    int formStudentID = Integer.parseInt(request.getParameter("studentID"));
    %><script>
    console.log("testing");
    $('#conferences<%=String.valueOf(request.getParameter("studentID"))%>').css("display", "inline");
    $('html, body').animate({
                scrollTop: ($('#student<%=String.valueOf(request.getParameter("studentID"))%>').offset().top)
            }, 0);
    </script><%

}%>
</body>
</html>