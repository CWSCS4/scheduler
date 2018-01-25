<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
Statement state2 = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );

%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/timepicker@1.11.12/jquery.timepicker.min.css">
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>
<h2>Set Available Meeting Times (Step 1)</h2>
<form action="/parent/request.jsp" method="post">
<%
ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );
%>
<p>Conferences will take place at the following times; be sure you specify that
you are available within at least one of these time periods:</p>
<ul><%
DateFormat tdf = DateFormat.getTimeInstance();
DateFormat ddf = DateFormat.getDateInstance();

Calendar firstDate = null;
Calendar lastDate = null;
while ( results.next() ) { 
    
    Calendar startTime = Calendar.getInstance();
    Calendar stopTime = Calendar.getInstance();
    startTime.setTime(results.getTimestamp(1));
    stopTime.setTime(results.getTimestamp(2));
    if ((firstDate == null) || (firstDate.after(startTime))) firstDate = startTime;
    if ((lastDate == null) || (lastDate.before(stopTime))) lastDate = stopTime;
    %><li><%= ddf.format(startTime.getTime()) + " " + tdf.format(startTime.getTime()) %> - <%= tdf.format(stopTime.getTime()) %></li>
<% } %></ul>

<%
results.first();
Calendar example = Calendar.getInstance();
example.setTime( results.getTimestamp( 1 ) );
%>

<p>Please enter the times that you will be available for conferences.
<!-- (Month, Date, Year, Begin Time - Stop Time) --></p>
<!-- <small>NOTE: In order to make your time more effective <a href="available.jsp" target="_new">click here</a> to look at the availability information for each of the teachers you would like to see, and enter your time accordingly.</small> -->
<div>
                

<input type="radio" name="timetype" value="all" onClick="showTimes()">I will be availible for the entire period <br />
    <ul id="times" style="display:none"><%
      results = state.executeQuery( "SELECT * FROM conferencePeriod" );
      tdf = DateFormat.getTimeInstance();
      ddf = DateFormat.getDateInstance();
      int dateNum=0;
      firstDate = null;
      lastDate = null;
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

          %><li><input type="checkbox" name=<%=str.concat(String.valueOf(dateNum))%>><%= ddf.format(startTime.getTime()) + " " + tdf.format(startTime.getTime()) %> - <%= tdf.format(stopTime.getTime()) %></li>
      <% } %></ul>
      
      <%
      results.first();
      example = Calendar.getInstance();
      example.setTime( results.getTimestamp( 1 ) );
      %>
<input type="radio" name="timetype" value="none" onClick="hideCustom()">I will not be attending any conferences.<br />
<input type="radio" name="timetype" value="custom" onClick="showCustom()">I will select a custom set of times below:

</div>

<div id="Slots" style="display: none">
<div id="slotWithButton" style="display:flex;flex-direction:row">

<div class="datepairExample" name="custom1" style="display: block">
<input type="text" name="start1" class="time start"/> to
<input type="text" name="end1" class="time end" />
</div> 
</div>
</div>
<p><input type="submit" value="Continue" id="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>
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

<%


} else {
boolean errors = false;
boolean blank = false;

ResultSet results = state.executeQuery( "SELECT * FROM available WHERE type = 0 AND ID = " + studentID );

state.executeUpdate( "DELETE FROM available WHERE type = 0 AND ID = " + studentID );

results = state.executeQuery( "SELECT * FROM conferencePeriod" );
Vector times = new Vector();

while ( results.next() ) {
    times.add( new TimeSlot( results.getTimestamp( 1 ), results.getTimestamp( 2 ) ) );
}

if ( request.getParameter( "timetype" ).equals( "all" ) ) {
  results = state.executeQuery( "SELECT * FROM students WHERE studentID = " + studentID );
  if (results.first()) {
    results.updateInt(8, 1);
    results.updateRow();
  }  
    results = state.executeQuery( "SELECT * FROM available" );
    results.moveToInsertRow();
    for ( int i = 0; i < times.size(); i++ ) {
        String str="dates";
        String checkbox = request.getParameter(str.concat(String.valueOf(i+1)));
        if (checkbox != null) {
          results.updateInt( 1, studentID );
          results.updateInt( 2, 0 );
          results.updateTimestamp( 3, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getStart().getTime() ) );
          results.updateTimestamp( 4, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getFinish().getTime() ) );
          results.insertRow();
        }
    }

    boolean unchecked=true;
    for(int i=1;i<times.size()+1;i++){
      String str="dates";
      String checkbox = request.getParameter(str.concat(String.valueOf(i)));
      if (checkbox != null) {
        unchecked=false;
      } 
    }
    if(unchecked){
      errors=true;
    }
} else if ( request.getParameter( "timetype" ).equals( "none" ) ) {
  results = state.executeQuery( "SELECT * FROM students WHERE studentID = " + studentID );
	if (results.first()) {
		results.updateInt(8, 0);
    results.updateRow();
  }
  blank=true;
} else if ( request.getParameter( "timetype" ).equals( "custom" ) ) {
  int slots=1;
  %>
  <%
  while (request.getParameter("start"+String.valueOf(slots))!=null){
    slots++;
}
  if (errors==false) {
    for(int i=1; i<slots ;i++){
      results= state.executeQuery( "SELECT * FROM available");
      ResultSet results2=state2.executeQuery("SELECT * FROM conferenceperiod");
      results2.first();
      long timestamp = results2.getTimestamp(1).getTime();
      Calendar cal = Calendar.getInstance();
      cal.setTimeInMillis(timestamp);
      SimpleDateFormat formatTime = new SimpleDateFormat("yyyy-MM-dd H:mm:ss");
      String year=String.valueOf(cal.get(Calendar.YEAR));
      String month=String.valueOf(Integer.parseInt(String.valueOf(cal.get(Calendar.MONTH)))+1); //necessary for some reason
      String dy=String.valueOf(cal.get(Calendar.DAY_OF_MONTH));
      String min=(request.getParameter("start"+ String.valueOf(i))).substring(3,5);
      String tomin=(request.getParameter("end"+ String.valueOf(i))).substring(3,5);
      String pm=(request.getParameter("start"+ String.valueOf(i))).substring(5,7);
      String topm=(request.getParameter("end"+ String.valueOf(i))).substring(5,7);
      String hour;
      String tohour;
      if(pm=="am"){
        hour=(request.getParameter("start"+ String.valueOf(i))).substring(0,2);
      } else {
        hour=String.valueOf(Integer.parseInt((request.getParameter("start"+ String.valueOf(i))).substring(0,2))+12);
      }
      if(topm=="am"){
        tohour=(request.getParameter("end"+ String.valueOf(i))).substring(0,2);
      } else {
        tohour=String.valueOf(Integer.parseInt((request.getParameter("end"+ String.valueOf(i))).substring(0,2))+12);
      }
      java.util.Date parsedStartTime=formatTime.parse((year+"-"+month+"-"+dy) + " " + hour+":"+min+":"+"00");
      java.util.Date parsedEndTime=formatTime.parse((year+"-"+month+"-"+dy) + " " + tohour+":"+tomin+":"+"00");
      Timestamp startDate = new Timestamp(parsedStartTime.getTime());
      Timestamp endDate= new Timestamp(parsedEndTime.getTime());
      results.moveToInsertRow();
      results.updateInt( 1, studentID );
      results.updateTimestamp( 3,  startDate);
      results.updateTimestamp( 4,  endDate);
      results.insertRow();
    }
  }
  results = state.executeQuery( "SELECT * FROM students WHERE studentID = " + studentID );
  if (results.first()) {
    results.updateInt(8, 1);
    results.updateRow();
  }

} else {
    blank = true;
}

if ( !errors && !blank && false ) {
   errors = true;
   %><p>You did not specify any times that you are available.</p><%
}

   
%>
<% if ( errors ) { %>
<p>There was an error with your submission. Please use your brower's "Back" button to go back and correct it.</p>
<% } else if ( blank ) { %>
<jsp:forward page="request3.jsp"/>
<% } else { %>
<jsp:forward page="request2.jsp"/>
<% } %>
<% } %>
</div>
<script type="text/javascript">
function showCustom(){
  document.getElementById("Slots").style.display="block";
  document.getElementById("times").style.display="none";

}
function hideCustom(){
  document.getElementById("Slots").style.display="none";
  document.getElementById("times").style.display="none";

}
function showTimes(){
  document.getElementById("Slots").style.display="none";
  document.getElementById("times").style.display="block";
}
</script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.2.1/jquery.min.js"></script>
<script src="http://jonthornton.github.io/Datepair.js/dist/datepair.js"></script>
<script src="http://jonthornton.github.io/Datepair.js/dist/jquery.datepair.js"></script>
<script src="https://cdn.jsdelivr.net/npm/timepicker@1.11.12/jquery.timepicker.min.js"></script>
<script>

    $('.datepairExample .time').timepicker({
        'showDuration': true,
        'timeFormat': 'h:ia',
        'disableTimeRanges': invertedRanges
    });

    // initialize datepair
    $('.datepairExample').datepair();
</script>
</body>
</html>
