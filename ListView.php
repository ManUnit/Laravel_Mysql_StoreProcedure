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
        $aaaa =  DB::select( 'CALL listview("2021-08-01","2021-08-31", ' . $id .'  )'  ) ;
       
        dd('test',$aaaa );
        return view('user.index', ['users' => $users]);
    }
}
