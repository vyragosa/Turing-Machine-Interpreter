program MTInterpreter;
uses mtlist;
const
  DIRECTION_RIGHT = 'R';
  DIRECTION_LEFT  = 'L';
  DIRECTION_STAY  = 'S';
  SYMBOL_STATE    = 'q';
  SYMBOL_DIVIDER  = ':';
  LOOPCHECK_BOUNDARY = 1000000;
type
  Instruction = record
    forvalue   : Char;
    printvalue : Char;
    direction  : Char;
    forstate   : Integer;
    nextstate  : Integer;
  end;
  MTProgramType = Array of Instruction;



procedure ReadSymbol( var input : Text; var symbol : Char; var line : Integer );
begin
  Read(input, symbol);
  if (symbol = #10) then line := line + 1;
end;

procedure ReadStateNumber( var input : Text; var expresion : String; var line : Integer );
var
  symbol : Char;
begin
  expresion := '';
  while true do begin
    ReadSymbol(input, symbol, line);
    if (symbol = SYMBOL_DIVIDER) then Break;
    expresion := expresion + symbol;
  end;
end;

procedure EvaluateStateNumber( const expresion : String; var forstate : Integer; line : Integer );
var
  errcode : Word;
begin
  Val(expresion, forstate, errcode);
  if (errcode <> 0) then begin
    Writeln('ERROR (2): State Number Evaluation Fail (line ', line, ') ');
    Writeln('(cannot recognise the number at position ', errcode, ' of "', expresion, '")');
    Halt(2);
  end;
end;

procedure CheckStatesNumber( forstate, nextstate, line : Integer );
begin
  if (forstate < 0) or (nextstate < 0) then begin
    Writeln('ERROR (1): Array Index Overflow (line ', line, ') ');
    Writeln('(state number is less than zero)');
    Halt(1);
  end;
end;

procedure MTParse( const filename : String; var mtprogram : MTProgramType; var instructions : Integer );
var
  symbol : Char;
  direction : Char;
  forvalue, printvalue : Char;
  line : Integer;
  programsize : Integer;
  forstate, nextstate : Integer;
  expresion : String;
  input : Text;
begin
  Assign(input, filename);
  Reset(input);
  
  line := 1;
  programsize := 0;
  
  while not EOF(input) do begin
    if (symbol = SYMBOL_STATE) then begin
      ReadStateNumber(input, expresion, line);
      ReadSymbol(input, symbol, line);
      
      EvaluateStateNumber(expresion, forstate, line);
      forvalue := symbol;
      
      while not (symbol = SYMBOL_STATE) do ReadSymbol(input, symbol, line);
      
      ReadStateNumber(input, expresion, line);
      ReadSymbol(input, symbol, line);
      
      EvaluateStateNumber(expresion, nextstate, line);
      printvalue := symbol;
      
      ReadSymbol(input, symbol, line);
      if (symbol = DIRECTION_RIGHT) or (symbol = DIRECTION_LEFT) then begin
        direction := symbol;
      end else direction := DIRECTION_STAY;
      
      CheckStatesNumber(forstate, nextstate, line);
      
      SetLength(mtprogram, programsize + 1);
      mtprogram[programsize].forvalue   := forvalue;
      mtprogram[programsize].printvalue := printvalue;
      mtprogram[programsize].direction  := direction;
      mtprogram[programsize].forstate   := forstate;
      mtprogram[programsize].nextstate  := nextstate;
      
      programsize := programsize + 1;
    end else ReadSymbol(input, symbol, line);
  end;
  
  instructions := programsize;
  Close(input);
end;

procedure MTParseTape( const filename : String; var tape : ListPointer );
var
  input : Text;
  value : Char;
begin
  Assign(input, filename);
  Reset(input);
    Create(tape);
    while not EOF(input) do begin
      Read(input, value);
      AppendRight(tape, value);
    end;
  Close(input);
end;

procedure MTRun( const mtprogram : MTProgramType; const instructions : Integer; const tape : ListPointer );
var
  value : Char;
  valid : Boolean;
  limit : LongInt;
  state, position, i : Integer;
  current : ListPointer;
begin
  state    := 1;
  limit    := 0;
  valid    := false;
  position := state;
  current  := GetLeft(tape);
  
  while true do begin
    if limit >= LOOPCHECK_BOUNDARY then begin
      Write('ERROR: Infinite loop detected! ');
      WriteLn('Check your program.');
      Break;
    end;
    limit := limit + 1;
    
    if state = 0 then Break;
    
    value := current^.value;
    for i := 0 to instructions-1 do begin
      if (mtprogram[i].forstate = state) and (mtprogram[i].forvalue = value) then begin
        current^.value := mtprogram[i].printvalue;
        state := mtprogram[i].nextstate;
        
        case mtprogram[i].direction of
          DIRECTION_RIGHT: begin
            if current^.next = nil then AppendRight(current, '0');
            current := current^.next;
            position := position + 1;
          end;
          DIRECTION_LEFT: begin
            if current^.prev = nil then AppendLeft(current, '0');
            current := current^.prev;
            position := position - 1;
          end;
        end;
        
        valid := true;
        Break;
      end else valid := false;
    end;
    
    if not valid then begin
      Write('ERROR: Instruction not found! ');
      Write('[State: ', state, '; Value: ', value);
      WriteLn('; Position: ', position, ']');
      Break;
    end;
  end;
end;

procedure MTOutputResult( const filename : String; const tape : ListPointer );
var
  current : ListPointer;
  output : Text;
begin
  Assign(output, filename);
  Rewrite(output);
    current := GetLeft(tape);
    while not (current = nil) do begin
      Write(output, current^.value);
      current := current^.next;
    end;
  Close(output);
end;

var
  tape : ListPointer;
  mtprogram : MTProgramType;
  instructions : Integer;
begin
  MTParseTape('input.txt', tape);
  MTParse('program.txt', mtprogram, instructions);
  MTRun(mtprogram, instructions, tape);
  MTOutputResult('output.txt', tape);
end.
