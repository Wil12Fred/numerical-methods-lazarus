program numerictests;

{ Console known-answer tests for the numerical routines behind the GUI.
  The units pull in LCL/cmdbox, so this is built with lazbuild and run
  under xvfb-run. Exit code = number of failed checks. }

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}cthreads,{$ENDIF}
  Interfaces, Classes, SysUtils, Math, fpexprpars,
  class_close, class_open, class_integral, class_edo, class_lag;

var
  Failures: Integer = 0;

procedure Check(const Name: string; Got, Want, Tol: Double);
begin
  if IsNaN(Got) or (Abs(Got - Want) > Tol) then begin
    Inc(Failures);
    WriteLn('FAIL ', Name, ': got ', FloatToStr(Got), ', want ', FloatToStr(Want), ' +/- ', FloatToStr(Tol));
  end else
    WriteLn('ok   ', Name, ' = ', FormatFloat('0.0000000000', Got));
end;

function RootClose(Kind: Integer): Double;
var C: TClose;
begin
  C := TClose.create;
  C.Parse.Expression := 'power(x,2)-2';
  C.Parse.AddVariable('x', 0);
  C.xleft := 0; C.xright := 2;
  C.CloseType := Kind;
  Result := C.execute;
end;

function RootOpen(Kind: Integer): Double;
var O: TOpen;
begin
  O := TOpen.create;
  O.Parse1.Expression := 'power(x,2)-2';
  O.Parse1.AddVariable('x', 0);
  O.Parse2.Expression := '2*x';
  O.Parse2.AddVariable('x', 0);
  O.x := 1;
  O.OpenType := Kind;
  Result := O.execute;
end;

function NewIntegral(n: Integer): TIntegral;
begin
  Result := TIntegral.create();
  Result.Parse.Expression := 'power(x,3)';
  Result.Parse.AddVariable('x', 0);
  Result.n := n;
end;

function NewEdo(n: Integer): TEdo;
begin
  { y' = y, y(0) = 1  ->  y(1) = e }
  Result := TEdo.create();
  Result.Parse.Expression := 'y';
  Result.Parse.AddVariable('x', 0);
  Result.Parse.AddVariable('y', 0);
  Result.n := n;
end;

function ConsoleNewton(x0: Double): Double;
{ newt('power(x,2)-2','2*x','x',x0) as the console calls it }
var Args: TExprParameterArray; R: TFPExpressionResult;
begin
  SetLength(Args, 4);
  Args[0].ResultType := rtString; Args[0].ResString := 'power(x,2)-2';
  Args[1].ResultType := rtString; Args[1].ResString := '2*x';
  Args[2].ResultType := rtString; Args[2].ResString := 'x';
  Args[3].ResultType := rtFloat;  Args[3].ResFloat := x0;
  R.ResultType := rtFloat;
  newton(R, Args);
  Result := R.ResFloat;
end;

var
  L: TLag;
begin
  { Roots of x^2 - 2 (sqrt 2 = 1.41421356...) }
  Check('bisection  x^2-2 on [0,2]', RootClose(F_BIS), Sqrt(2), 1e-4);
  Check('false-pos  x^2-2 on [0,2]', RootClose(F_FAL), Sqrt(2), 1e-3);
  Check('newton     x^2-2 from 1', RootOpen(F_NEW), Sqrt(2), 1e-6);
  { the console wrapper must start from the 4th argument, x0 }
  Check('newt(...) console from -1', ConsoleNewton(-1), -Sqrt(2), 1e-6);
  Check('secant     x^2-2 from 1', RootOpen(F_SEC), Sqrt(2), 1e-6);

  { Integral of x^3 on [0,2] = 4 }
  Check('midpoint   x^3 [0,2] n=1000', NewIntegral(1000).puntomedio(0, 2), 4, 1e-4);
  Check('trapezoid  x^3 [0,2] n=1000', NewIntegral(1000).trapecio(0, 2), 4, 1e-4);
  Check('simpson1/3 x^3 [0,2] n=1000', NewIntegral(1000).simpson1(0, 2), 4, 1e-9);
  Check('simpson3/8 x^3 [0,2] n=1000', NewIntegral(1000).simpson3(0, 2), 4, 1e-9);
  { n divisible by 3 used to leave the panel count uninitialised }
  Check('simpson3/8 x^3 [0,2] n=999 ', NewIntegral(999).simpson3(0, 2), 4, 1e-9);

  { ODE y' = y, y(0)=1, y(1) = e }
  Check('euler      y''=y n=1000', NewEdo(1000).euler(1, 0, 1), Exp(1), 2e-3);
  Check('heun       y''=y n=100', NewEdo(100).heun(1, 0, 1), Exp(1), 1e-4);
  Check('runge4     y''=y n=100', NewEdo(100).runge4(1, 0, 1), Exp(1), 1e-8);

  { Lagrange through x^2 + 1, points inserted out of order plus a duplicate }
  L := TLag.Create;
  L.insert(2, 5);
  L.insert(0, 1);
  L.insert(1, 7);
  L.insert(1, 2);   { same x again: replaces the value }
  Check('lagrange   size after duplicate', Length(L.DatX), 3, 0);
  Check('lagrange   x^2+1 at 1.5', L.interPolar(1.5), 3.25, 1e-9);
  Check('lagrange   x^2+1 at 3', L.interPolar(3), 10, 1e-9);

  if Failures = 0 then WriteLn('all tests passed') else WriteLn(Failures, ' test(s) failed');
  Halt(Failures);
end.
