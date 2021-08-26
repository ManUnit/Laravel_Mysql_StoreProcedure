<!DOCTYPE html>
<html>
<head>
<style>
h1 {
  color: blue;
  font-family: verdana;
  font-size: 300%;
}
p {
  color: red;
  font-family: courier;
  font-size: 160%;
}
table th {
   text-align: center; 
   color: white;
   background-color:#000000;
  
}
table td {
   text-align: center; 
}
</style>
</head>

<br>



<table>
<thead>
    <tr>
    
      <th scope="col">Date</th>
      <th scope="col">Checkin</th>
      <th scope="col">Checkout</th>
    </tr>
  </thead>
  <tbody>
@foreach ($attendances as $attendance) 
     @php 
      
      list(  $checkin  , $inbgcolor ) =  ($attendance->checkin == null )?  [ "N/A"  , "#FF0000"  ] :  [ $attendance->checkin , "#00FF00" ]  ;
      list ( $checkout , $outbgcolor ) =  ($attendance->checkout == null )?  [ "N/A"  , "#FF0000"  ] :  [ $attendance->checkout , "#00FF00" ]  ;
      //  is SUNDAY ? chage background = orenged  
      list( $inbgcolor , $outbgcolor ) = (date('w', strtotime($attendance->date)) == 0 )? ["#FFFF00" , "#FFFF00"] :   [$inbgcolor , $outbgcolor ]   ; 

     @endphp
 <tr>
  <td style="background-color:#AAAAAA">   {{ $attendance->date }} </td>
  <td style="background-color:{{$inbgcolor}}">  {{ $checkin  }} </td>
  <td style="background-color:{{$outbgcolor}}">  {{ $checkout }} </td>
</tr>
@endforeach
</tbody>
</table>
