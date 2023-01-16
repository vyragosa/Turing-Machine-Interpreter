unit mtlist;
interface
  
  type
    ListPointer = ^ListItem;
    ListType = char;
    ListItem = record
      value : ListType;
      prev, next : ListPointer;
    end;
  
  procedure Create( var list : ListPointer );
  procedure PrintList( const list : ListPointer );
  
  procedure AppendLeft ( var list : ListPointer; value : ListType );
  procedure AppendRight( var list : ListPointer; value : ListType );
  
  function GetLeft  ( const list : ListPointer ) : ListPointer;
  function GetRight ( const list : ListPointer ) : ListPointer;
  function GetLength( const list : ListPointer ) : Integer;
  
implementation
  
  procedure Create( var list : ListPointer );
  begin
    New(list);
    list := nil;
  end;
  
  procedure PrintList( const list : ListPointer );
  var
    current : ListPointer;
  begin
    current := GetLeft(list);
    while not (current = nil) do begin
      Write(current^.value, ' ');
      current := current^.next;
    end;
    WriteLn;
  end;
  
  procedure AppendLeft( var list : ListPointer; value : ListType );
  var
    item, current : ListPointer;
  begin
    New(item);
    
    item^.value := value;
    item^.prev := nil;
    
    if list = nil then begin
      item^.next := nil;
      list := item;
    end else begin
      current := GetLeft(list);
      item^.next := current;
      current^.prev := item;
    end;
  end;
  
  procedure AppendRight( var list : ListPointer; value : ListType );
  var
    item, current : ListPointer;
  begin
    New(item);
    
    item^.value := value;
    item^.next := nil;
    
    if list = nil then begin
      item^.prev := nil;
      list := item;
    end else begin
      current := GetRight(list);
      item^.prev := current;
      current^.next := item;
    end;
  end;

  function GetLeft( const list : ListPointer ) : ListPointer;
  var
    current : ListPointer;
  begin
    current := list;
    while not (current^.prev = nil) do
      current := current^.prev;
    
    GetLeft := current;
  end;
  
  function GetRight( const list : ListPointer ) : ListPointer;
  var
    current : ListPointer;
  begin
    current := list;
    while not (current^.next = nil) do
      current := current^.next;
    
    GetRight := current;
  end;
  
  function GetLength ( const list : ListPointer ) : Integer;
  var
    length : Integer;
    current : ListPointer;
  begin
    length := 0;
    current := GetLeft(list);
    while not (current = nil) do begin
      length := length + 1;
      current := current^.next;
    end;
    GetLength := length;
  end;
  
end.
