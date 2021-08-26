<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class Listview extends Controller
{
    //
       public function index($start,$stop,$id)
    {  
       // $id = 35 ; 
        $dateStart = $this->minDate($start) ; 
        $dateStop =  $this->maxDate($stop)  ;
        // dd($dateStart,$dateStop) ;
        $attendances =  DB::select( 'CALL listview("' . $dateStart. '","'. $dateStop .'",' . $id .')'  ) ;
       //  dd('test',$aaaa );
        return view('admin.employees.montlyattendance', ['attendances' => (array) $attendances]);
    }

    private function minDate($dateYmD){

        $day = preg_split ("/[\-]/",$dateYmD);
        $daynum =   ( ( (int) $day[2] ) < 1  )? 1 : $day[2] ;  
        return $day[0]."-".$day[1]."-".$daynum ; 
   }
   
   private function maxDate($dateYmD){
       $day = preg_split ("/[\-]/",$dateYmD); 
       //dd($dateYmD , $yearnum , $month , $daynum  ) ; 
       if ((int) $day[1] == 2 && (int) $day[2]  > 28 ){ 
           $getday = ($this->isLeapYeay($day[0] ))?29:28 ; 
           return $day[0]."-".$day[1]."-".$getday  ; 
       } elseif ( (int) $day[1] > 12  ){ 
           return $day[0]."-12-".$day[2]  ;  ;
       }else{
           return $dateYmD ;
       }
   
   }
   
   private function isLeapYeay($my_year)
   {
      if ($my_year % 400 == 0) return true;
      if ($my_year % 4 == 0) { 
          return true;
      }
      else if ($my_year % 100 == 0){
          return false;
      }
      else{
          return false;
      }
   }
}



