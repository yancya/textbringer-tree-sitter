{ Block comment style 1 }
(* Block comment style 2 *)
// Line comment

program SampleProgram;

uses
  SysUtils, Classes, Math;

const
  MaxSize = 100;
  Pi = 3.14159;
  Greeting: string = 'Hello, World!';
  NilValue = nil;

type
  // --- Enum ---
  TColor = (Red, Green, Blue);

  // --- Set ---
  TColorSet = set of TColor;

  // --- Record ---
  TPoint = record
    X: Double;
    Y: Double;
  end;

  // --- Class ---
  TAnimal = class
  private
    FName: string;
    FAge: Integer;
  protected
    procedure SetName(const Value: string);
  public
    constructor Create(const AName: string; AAge: Integer);
    destructor Destroy; override;
    function Speak: string; virtual; abstract;
    property Name: string read FName write SetName;
    property Age: Integer read FAge;
  end;

  // --- Inherited class ---
  TDog = class(TAnimal)
  public
    function Speak: string; override;
  end;

  // --- Interface ---
  IGreetable = interface
    function Greet: string;
  end;

  // --- Generic class ---
  TContainer<T> = class
  private
    FItems: array of T;
    FCount: Integer;
  public
    procedure Add(const Item: T);
    function Get(Index: Integer): T;
    property Count: Integer read FCount;
  end;

  // --- Array type ---
  TIntArray = array[0..MaxSize - 1] of Integer;
  TMatrix = array of array of Double;

  // --- Pointer type ---
  PPoint = ^TPoint;

  // --- Function type ---
  TCompareFunc = function(A, B: Integer): Integer;

var
  GlobalVar: Integer;
  Colors: TColorSet;

// --- TAnimal implementation ---
constructor TAnimal.Create(const AName: string; AAge: Integer);
begin
  inherited Create;
  FName := AName;
  FAge := AAge;
end;

destructor TAnimal.Destroy;
begin
  inherited Destroy;
end;

procedure TAnimal.SetName(const Value: string);
begin
  FName := Value;
end;

// --- TDog implementation ---
function TDog.Speak: string;
begin
  Result := 'Woof!';
end;

// --- Generic implementation ---
procedure TContainer<T>.Add(const Item: T);
begin
  SetLength(FItems, FCount + 1);
  FItems[FCount] := Item;
  Inc(FCount);
end;

function TContainer<T>.Get(Index: Integer): T;
begin
  Result := FItems[Index];
end;

// --- Standalone functions ---
function Add(A, B: Integer): Integer;
begin
  Result := A + B;
end;

procedure Greet(const Name: string);
begin
  WriteLn('Hello, ', Name, '!');
end;

function Factorial(N: Integer): Integer;
begin
  if N <= 1 then
    Result := 1
  else
    Result := N * Factorial(N - 1);
end;

// --- Inline function ---
function Max(A, B: Integer): Integer; inline;
begin
  if A > B then
    Result := A
  else
    Result := B;
end;

// --- Main program ---
var
  I, J, Sum: Integer;
  F: Double;
  S: string;
  Dog: TDog;
  Point: TPoint;
  Arr: TIntArray;
  DynArr: array of Integer;
begin
  // --- Strings ---
  S := 'Single quoted string';
  WriteLn(S);

  // --- Numbers ---
  I := 42;
  F := 3.14;
  J := $FF;     // Hex
  Sum := %1010; // Binary

  // --- Boolean ---
  if True then
    WriteLn('true')
  else if False then
    WriteLn('false');

  // --- Control flow: if/else ---
  if I > 0 then
    WriteLn('positive')
  else if I < 0 then
    WriteLn('negative')
  else
    WriteLn('zero');

  // --- Case ---
  case I of
    0: WriteLn('zero');
    1..10: WriteLn('small');
    11..100: WriteLn('medium');
  else
    WriteLn('large');
  end;

  // --- For loop ---
  Sum := 0;
  for I := 1 to 10 do
    Sum := Sum + I;

  for I := 10 downto 1 do
    WriteLn(I);

  // --- While loop ---
  I := 0;
  while I < 10 do
  begin
    Inc(I);
    if I = 5 then
      Break;
    if I = 3 then
      Continue;
  end;

  // --- Repeat/Until ---
  I := 0;
  repeat
    Inc(I);
  until I >= 10;

  // --- With statement ---
  Point.X := 1.0;
  Point.Y := 2.0;
  with Point do
    WriteLn('X=', X:0:2, ' Y=', Y:0:2);

  // --- Operators ---
  Sum := 1 + 2;
  Sum := 5 - 3;
  Sum := 4 * 2;
  F := 10 / 3;
  Sum := 10 div 3;
  Sum := 10 mod 3;
  Sum := 1 shl 4;
  Sum := 16 shr 2;

  if (I > 0) and (J > 0) then
    WriteLn('both positive');
  if (I > 0) or (J > 0) then
    WriteLn('at least one positive');
  if not (I = 0) then
    WriteLn('not zero');

  // --- Object creation ---
  Dog := TDog.Create('Rex', 5);
  try
    WriteLn(Dog.Name, ': ', Dog.Speak);
    Dog.Name := 'Max';
  finally
    Dog.Free;
  end;

  // --- Exception handling ---
  try
    raise Exception.Create('Something went wrong');
  except
    on E: Exception do
      WriteLn('Error: ', E.Message);
  end;

  // --- Dynamic array ---
  SetLength(DynArr, 5);
  for I := 0 to High(DynArr) do
    DynArr[I] := I * I;

  // --- Set operations ---
  Colors := [Red, Green];
  if Blue in Colors then
    WriteLn('has blue');
  Colors := Colors + [Blue];
  Colors := Colors - [Red];

  // --- Goto (rare but valid) ---
  goto 999;
  WriteLn('skipped');
  999:
  WriteLn('jumped here');

  // --- Exit ---
  if I = 0 then
    Exit;

  WriteLn('Done!');
end.
