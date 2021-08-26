<?php

namespace App\Http\Controllers\Admin;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use App\Http\Controllers\Controller;

class Listview extends Controller
{
    //
       public function index()
    {  
        $id = 35 ; 
        $dateStart = '2021-07-01' ; 
        $dateStop = '2021-08-31' ;
        $aaaa =  DB::select( 'CALL listview("' . $dateStart. '","'. $dateStop .'",' . $id .')'  ) ;
         dd('test',$aaaa );
        return view('user.index', ['users' => $aaa]);
    }
}
