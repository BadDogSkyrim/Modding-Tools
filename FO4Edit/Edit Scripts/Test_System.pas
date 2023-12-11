unit Test_System;

interface

implementation

uses xEditAPI, Classes, SysUtils, StrUtils, Windows;

Function Finalize: Integer;
var 
    ibig: Int64;
begin
    ibig := 100000;
    AddMessage(ibig);
end;

end.