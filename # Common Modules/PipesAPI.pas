unit PipesAPI;

interface

uses
  Windows;

type
  TPipeInformation = record
    StdIn: THandle;
    WriteStdIn: THandle;
    StdOut: THandle;
    ReadStdOut: THandle;
    ProcessInfo: TProcessInformation;
  end;

const
  REDIRECT_INPUT  = 1;  // �������������� ������ ����
  REDIRECT_OUTPUT = 2;  // �������������� ������ �����
  REDIRECT_ALL    = 3;  // �������������� ��

function CreatePipes(ExecObject, CommandLine, CurrentDir: PAnsiChar; ShowWindow: LongWord; RedirectType: byte; out PipeInformation: TPipeInformation): LongBool;
function GetOutputPipeDataSize(ReadStdOut: THandle): LongWord;
function ReadPipe(ReadStdOut: THandle; Buffer: pointer; BytesToRead: LongWord; out BytesRead: LongWord): LongBool;
function WritePipe(WriteStdIn: THandle; Buffer: pointer; BytesToWrite: LongWord; out BytesWritten: LongWord): LongBool;
procedure DestroyPipes(StdIn, WriteStdIn, StdOut, ReadStdOut: THandle);
procedure DestroyConsole(ProcessHandle, ThreadHandle: THandle; Wait: Boolean);

function ConvertToAnsi(OEM: PAnsiChar): PAnsiChar;
function ConvertToOEM(Ansi: PAnsiChar): PAnsiChar;

function ReadConsole(ReadStdOut: THandle): string;
function WriteConsole(WriteStdIn: THandle; Command: string): LongWord;

implementation


function CreatePipes(ExecObject, CommandLine, CurrentDir: PAnsiChar; ShowWindow: LongWord; RedirectType: byte; out PipeInformation: TPipeInformation): LongBool;
var
  SecurityAttributes: TSecurityAttributes;
  StdIn, WriteStdIn, StdOut, ReadStdOut: THandle;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  SecurityAttributes.nLength := SizeOf(SecurityAttributes);
  SecurityAttributes.lpSecurityDescriptor := nil;
  SecurityAttributes.bInheritHandle := true;

  // ���� ��� StdIn:
  if not CreatePipe(StdIn, WriteStdIn, @SecurityAttributes, 0) then
  begin
    Result := false;
    Exit;
  end;

  // ���� ��� StdOut:
  if not CreatePipe(ReadStdOut, StdOut, @SecurityAttributes, 0) then
  begin
    Result := false;
    Exit;
  end;

  // ����� �������, ������ �������:
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb := SizeOf(StartupInfo);
  StartupInfo.wShowWindow := ShowWindow;

  // ��������������� �����:
  if (RedirectType and REDIRECT_INPUT) = REDIRECT_INPUT then
    StartupInfo.hStdInput := StdIn;

  // ��������������� ������:
  if (RedirectType and REDIRECT_OUTPUT) = REDIRECT_OUTPUT then
  begin
    StartupInfo.hStdOutput := StdOut;
    StartupInfo.hStdError := StdOut;
  end;

  StartupInfo.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;

  Result := CreateProcess(
                           ExecObject,
                           CommandLine,
                           nil,
                           nil,
                           true,
                           0,
                           nil,
                           CurrentDir,
                           StartupInfo,
                           ProcessInfo
                          );

  // ������� ������, ���������� ���������:
  FillChar(PipeInformation, SizeOf(PipeInformation), #0);
  if Result = true then
  begin
    PipeInformation.StdIn := StdIn;
    PipeInformation.StdOut := StdOut;
    PipeInformation.WriteStdIn := WriteStdIn;
    PipeInformation.ReadStdOut := ReadStdOut;
    PipeInformation.ProcessInfo := ProcessInfo;
  end;
end;

function GetOutputPipeDataSize(ReadStdOut: THandle): LongWord;
var
  BytesRead, AvailToRead: LongWord;
begin
  if not PeekNamedPipe(ReadStdOut, nil, 0, @BytesRead, @AvailToRead, nil) then
    Result := 0
  else
    Result := AvailToRead;
end;

function ReadPipe(ReadStdOut: THandle; Buffer: pointer; BytesToRead: LongWord; out BytesRead: LongWord): LongBool;
var
  AvailToRead: LongWord;
begin
  // ���������, ���� �� ������ � �����:
  if not PeekNamedPipe(ReadStdOut, nil, 0, @BytesRead, @AvailToRead, nil) then AvailToRead := 0;

  // ���� ����, �� ������:
  if AvailToRead > 0 then
  begin
    Result := ReadFile(ReadStdOut, Buffer^, BytesToRead, BytesRead, nil);
  end
  else
  begin
    Result := false;
    BytesRead := 0;
  end;
end;

function WritePipe(WriteStdIn: THandle; Buffer: pointer; BytesToWrite: LongWord; out BytesWritten: LongWord): LongBool;
begin
  Result := WriteFile(WriteStdIn, Buffer^, BytesToWrite, BytesWritten, nil);
end;

procedure DestroyPipes(StdIn, WriteStdIn, StdOut, ReadStdOut: THandle);
begin
  CloseHandle(StdIn);
  CloseHandle(WriteStdIn);
  CloseHandle(StdOut);
  CloseHandle(ReadStdOut);
end;

procedure DestroyConsole(ProcessHandle, ThreadHandle: THandle; Wait: Boolean);
begin
  TerminateProcess(ProcessHandle, 0);
  if Wait then WaitForSingleObject(ProcessHandle, 0);
  CloseHandle(ThreadHandle);
  CloseHandle(ProcessHandle);
end;

//------------------------------------------------------------------------------

function ConvertToAnsi(OEM: PAnsiChar): PAnsiChar;
begin
  OemToAnsi(OEM, OEM);
  Result := OEM;
end;

function ConvertToOEM(Ansi: PAnsiChar): PAnsiChar;
begin
  AnsiToOem(Ansi, Ansi);
  Result := Ansi;
end;

function WriteConsole(WriteStdIn: THandle; Command: string): LongWord;
var
  Size: LongWord;
  Buffer: PAnsiChar;
  BytesWritten: LongWord;
begin
  Command := Command + #13#10;
  Size := Length(Command);
  Buffer := PAnsiChar(Command);
  WritePipe(WriteStdIn, Buffer, Size, BytesWritten);
  Result := BytesWritten;
end;

function ReadConsole(ReadStdOut: THandle): string;
var
  BufferSize: LongWord;
  Buffer: Pointer;
  BytesRead: LongWord;
begin
  Result := '';
  BufferSize := GetOutputPipeDataSize(ReadStdOut);
  if BufferSize <= 0 then Exit;

  GetMem(Buffer, BufferSize + 2);
  FillChar(Buffer^, BufferSize + 2, #0);
  if ReadPipe(ReadStdOut, Buffer, BufferSize, BytesRead) then
    Result := PAnsiChar(Buffer)
  else
    Result := '';

  FreeMem(Buffer);
end;

end.
