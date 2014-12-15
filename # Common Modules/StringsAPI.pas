unit StringsAPI;

interface

const
  METHOD_SIMPLE    = 0; // ������� ������
  METHOD_SELECTIVE = 1; // ������, ���� �������� �� ���������� � ������,
                        // ���������� ���������� ������������������

procedure SimpleReplaceParam(var Source: string; const Param, ReplacingString: string);
procedure SelectiveReplaceParam(var Source: string; const Param, ReplacingString: string);
function ReplaceParam(const Source, Param, ReplacingString: string; Method: LongWord = METHOD_SIMPLE): string;

{
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  * Simple - ������� �����:
  Source          = aFFabFFabc
  Param           = ab
  ReplacingString = abc

  Result = aFFabcFFabcc

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  * Selective - ������������� �����:
  Source          = aFFabFFabc
  Param           = ab
  ReplacingString = abc

  Result = aFFabcFFabc - ������� ������������������ ����� ��, ���
                         ���������� ������ (abc), ������� � �� �������

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

implementation


procedure SimpleReplaceParam(var Source: string; const Param, ReplacingString: string);
var
  SourceLength: Integer;
  ParamLength: Integer;
  ReplacingStrLength: Integer;

  StartPos: Integer;
  NewPos: Integer;

  TempStr: string;
begin
  SourceLength := Length(Source);
  ParamLength := Length(Param);
  ReplacingStrLength := Length(ReplacingString);
  
  NewPos := 1;

  StartPos := Pos(Param, Source);
  while StartPos <> 0 do
  begin
    StartPos := StartPos + NewPos - 1;
    Delete(Source, StartPos, ParamLength);
    Insert(ReplacingString, Source, StartPos);

    NewPos := StartPos + ReplacingStrLength;
    SourceLength := SourceLength + (ReplacingStrLength - ParamLength);

    TempStr := Copy(Source, NewPos, SourceLength - NewPos + 1);
    StartPos := Pos(Param, TempStr);
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


procedure SelectiveReplaceParam(var Source: string; const Param, ReplacingString: string);
var
  SourceLength: Integer;
  ParamLength: Integer;
  ReplacingStrLength: Integer;

  StartPos: Integer;
  NewPos: Integer;

  ParamPosInReplacingString: Integer;
  LeftDelta, RightDelta: Integer;
  ParamEnvironment: string;
  TempStr: string;
begin
  SourceLength := Length(Source);
  ParamLength := Length(Param);
  ReplacingStrLength := Length(ReplacingString);

  LeftDelta := 1;
  RightDelta := ReplacingStrLength;

  ParamPosInReplacingString := Pos(Param, ReplacingString);
  if ParamPosInReplacingString <> 0 then
  begin
    LeftDelta := ParamPosInReplacingString - 1;
    RightDelta := ReplacingStrLength - ParamPosInReplacingString;
    {
      ������ ������: Pos - LeftDelta
      ����� ������: Pos + RightDelta
    }
  end;

  NewPos := 1;

  StartPos := Pos(Param, Source);
  while StartPos <> 0 do
  begin
    // ��������� ���������� ��������:
    StartPos := StartPos + NewPos - 1;

    // �������� ��������� ���������:
    if (StartPos - LeftDelta > 0) and (StartPos + RightDelta <= SourceLength) then
    begin
      ParamEnvironment := Copy(Source, StartPos - LeftDelta, ReplacingStrLength);
      if ParamEnvironment = ReplacingString then
      begin
        NewPos := StartPos + RightDelta + 1;

        if NewPos > SourceLength then Exit;

        TempStr := Copy(Source, NewPos, SourceLength - NewPos + 1);
        StartPos := Pos(Param, TempStr);
        Continue;
      end;
    end;

    Delete(Source, StartPos, ParamLength);
    Insert(ReplacingString, Source, StartPos);
    NewPos := StartPos + ReplacingStrLength;
    SourceLength := SourceLength + (ReplacingStrLength - ParamLength);

    TempStr := Copy(Source, NewPos, SourceLength - NewPos + 1);
    StartPos := Pos(Param, TempStr);
  end;
end;


// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


function ReplaceParam(const Source, Param, ReplacingString: string; Method: LongWord = METHOD_SIMPLE): string;
begin
  Result := Source;

  case Method of
    METHOD_SIMPLE:    SimpleReplaceParam(Result, Param, ReplacingString);
    METHOD_SELECTIVE: SelectiveReplaceParam(Result, Param, ReplacingString);
  end;
end;

end.
