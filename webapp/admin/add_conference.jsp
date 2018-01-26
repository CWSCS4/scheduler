<%@ include file="/include/init.jsp" %>

<%
int numberOfTimeSlots = 0;
Statement state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);

%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Add Conference</title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/timepicker@1.11.12/jquery.timepicker.min.css">

<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Add Conference</h2>
<form action="add_conference.jsp" method="post">

<p>Student: <select name="student_name">
<%
ResultSet students = state.executeQuery("SELECT name, studentID FROM students ORDER BY name");
while (students.next()) { %>
<option value="<%= students.getInt(2) %>"><%= students.getString(1) %></option>
<% } %>
</select></p>

<p>Teacher: <select name="teacher_name">
<%
ResultSet teachers = state.executeQuery( "SELECT name, teacherID FROM teachers ORDER BY name" );
while (teachers.next()) { %>
<option value="<%= teachers.getInt( 2 ) %>"><%= teachers.getString( 1 ) %></option>
<% } %>
</select></p>

<%
ResultSet period = state.executeQuery( "SELECT * FROM conferencePeriod" );
Calendar current = Calendar.getInstance();
Calendar cal = Calendar.getInstance();
period.next();
cal.setTime( period.getTimestamp( 1 ) );
%>

<p><select name="month">
<option value="-1"></option>
<option value="1" <%= ( cal.get( Calendar.MONTH ) == Calendar.JANUARY ) ? "SELECTED" : "" %>>January</option>
<option value="2" <%= ( cal.get( Calendar.MONTH ) == Calendar.FEBRUARY ) ? "SELECTED" : "" %>>February</option>
<option value="3" <%= ( cal.get( Calendar.MONTH ) == Calendar.MARCH ) ? "SELECTED" : "" %>>March</option>
<option value="4" <%= ( cal.get( Calendar.MONTH ) == Calendar.APRIL ) ? "SELECTED" : "" %>>April</option>
<option value="5" <%= ( cal.get( Calendar.MONTH ) == Calendar.MAY ) ? "SELECTED" : "" %>>May</option>
<option value="6" <%= ( cal.get( Calendar.MONTH ) == Calendar.JUNE ) ? "SELECTED" : "" %>>June</option>
<option value="7" <%= ( cal.get( Calendar.MONTH ) == Calendar.JULY ) ? "SELECTED" : "" %>>July</option>
<option value="8" <%= ( cal.get( Calendar.MONTH ) == Calendar.AUGUST ) ? "SELECTED" : "" %>>August</option>
<option value="9" <%= ( cal.get( Calendar.MONTH ) == Calendar.SEPTEMBER ) ? "SELECTED" : "" %>>September</option>
<option value="10" <%= ( cal.get( Calendar.MONTH ) == Calendar.OCTOBER ) ? "SELECTED" : "" %>>October</option>
<option value="11" <%= ( cal.get( Calendar.MONTH ) == Calendar.NOVEMBER ) ? "SELECTED" : "" %>>November</option>
<option value="12" <%= ( cal.get( Calendar.MONTH ) == Calendar.DECEMBER ) ? "SELECTED" : "" %>>December</option>
</select>
<select name="day">
<option value="-1"></option>
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>
<select name="year">
<option value="-1"></option>
<option value="<%= current.get( Calendar.YEAR )-1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )-1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )-1 %></option>
<option value="<%= current.get( Calendar.YEAR ) %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR ) ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR ) %></option>
<option value="<%= current.get( Calendar.YEAR )+1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )+1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )+1 %></option>
</select>
<div class="datepair1" name="custom" style="display: block">
  <input type="text" name="start" class="time start"/> to
  <input type="text" name="end" class="time end" />
</div>
<%
ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );
DateFormat tdf = DateFormat.getTimeInstance();
DateFormat ddf = DateFormat.getDateInstance();
int dateNum=0;
Calendar firstDate = null;
Calendar lastDate = null;
Calendar startTime = Calendar.getInstance();
Calendar stopTime = Calendar.getInstance();
String[] startTimes;
String[] stopTimes;
startTimes = new String[24];
stopTimes = new String[24];
while ( results.next() ) { 
    startTime = Calendar.getInstance();
    stopTime = Calendar.getInstance();
    startTime.setTime(results.getTimestamp(1));
    stopTime.setTime(results.getTimestamp(2));
    if ((firstDate == null) || (firstDate.after(startTime))) firstDate = startTime;
    if ((lastDate == null) || (lastDate.before(stopTime))) lastDate = stopTime;
    String str="dates";
    startTimes[dateNum]=tdf.format(startTime.getTime());
    stopTimes[dateNum]=tdf.format(stopTime.getTime());
    dateNum++;
}
%>
<script>
  var starts=[];
  var stops=[];
  var ranges=[];
  <%
  for(int i=0;i<dateNum;i++){
  %>
    starts.push("<%=startTimes[i]%>");
    stops.push("<%=stopTimes[i]%>");
  <%
  }
  %>
  for(var i=0;i<starts.length;i++){
    ranges.push([starts[i],stops[i]])
  }
  function compareDateStrings(str1,str2){
    if(str1.substring(str1.length-2,str1.length)>str2.substring(str2.length-2,str2.length)){
      return false;
    } else if (str1.substring(str1.length-2,str1.length)<str2.substring(str2.length-2,str2.length)){
      return true;
    } else {
      if (str1>str2){
        return false;
      } else {
        return true;
      }
    }
  }
  var orderRanges=[];
  for(var j=0;j<ranges.length;j++){
    var min=ranges[0];
    for(var i=0;i<ranges.length;j++){
      if (compareDateStrings(ranges[i][0],min[0])){
        min=ranges[i];
      }
    orderRanges.push(min);
    ranges.pop(min);
    }
  }
  String.prototype.replaceAt=function(index, replacement) {
    return this.substr(0, index) + replacement+ this.substr(index + replacement.length);
  }
  var invertedRanges=[];
  invertedRanges[0]=["12:00 AM",orderRanges[0][0]]
  for(var j=0;j<orderRanges.length-1;j++){
    invertedRanges.push([orderRanges[j][1].replaceAt(orderRanges[j][1].length-4,"1"),orderRanges[j+1][0]]);
  }
  invertedRanges.push([orderRanges[orderRanges.length-1][1].replaceAt(orderRanges[j][1].length-4,"1"),"11:59 PM"]);

</script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script src="http://jonthornton.github.io/Datepair.js/dist/datepair.js"></script>
<script src="http://jonthornton.github.io/Datepair.js/dist/jquery.datepair.js"></script>
<script src="https://cdn.jsdelivr.net/npm/timepicker@1.11.12/jquery.timepicker.min.js"></script>
<script>
    $('.datepair1 .time').timepicker({
        'showDuration': true,
        'timeFormat': 'h:ia',
        'disableTimeRanges': invertedRanges
    });

    $('.datepair1').datepair();
</script>
<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>
<% } else {
ResultSet results = state.executeQuery( "SELECT * FROM conference" );
SimpleDateFormat formatTime = new SimpleDateFormat("yyyy-MM-dd H:mm:ss");
String year=(request.getParameter("year"));
String month=(request.getParameter("month"));
String dy=(request.getParameter("day"));
String min=(request.getParameter("start")).substring(3,5);
String tomin=(request.getParameter("end")).substring(3,5);
String pm=(request.getParameter("start")).substring(5,7);
String topm=(request.getParameter("end")).substring(5,7);
String hour;
String tohour;
if(pm=="am"){
  hour=(request.getParameter("start")).substring(0,2);
} else {
  hour=String.valueOf(Integer.parseInt((request.getParameter("start")).substring(0,2))+12);
}
if(topm=="am"){
  tohour=(request.getParameter("end")).substring(0,2);
} else {
  tohour=String.valueOf(Integer.parseInt((request.getParameter("end")).substring(0,2))+12);
}
java.util.Date parsedStartTime=formatTime.parse((year+"-"+month+"-"+dy) + " " + hour+":"+min+":"+"00");
java.util.Date parsedEndTime=formatTime.parse((year+"-"+month+"-"+dy) + " " + tohour+":"+tomin+":"+"00");
Timestamp startDate = new Timestamp(parsedStartTime.getTime());
Timestamp endDate= new Timestamp(parsedEndTime.getTime());
PreparedStatement insertConference = connect.prepareStatement("INSERT INTO conference (studentID, teacherID, start,end) VALUES (?, ?, ?, ?)");
insertConference.setTimestamp(3,startDate);
insertConference.setTimestamp(4,endDate);
insertConference.setInt(1,Integer.parseInt(request.getParameter("student_name")));
insertConference.setInt(2,Integer.parseInt(request.getParameter("teacher_name")));
insertConference.executeUpdate();
%><jsp:forward page="index.jsp" /><%
} %>

</body>
</html>
