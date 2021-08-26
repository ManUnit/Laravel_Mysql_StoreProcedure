<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class Listview extends Controller
{
    //
       public function index($start,$stop,$id)
    {  
       // $id = 35 ; 
        $dateStart = $start ; 
        $dateStop =  $stop  ;
        $attendances =  DB::select( 'CALL listview("' . $dateStart. '","'. $dateStop .'",' . $id .')'  ) ;
       //  dd('test',$aaaa );
        return view('montlyattendance', ['attendances' => (array) $attendances]);
    }
}
