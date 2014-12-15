unit FileAPI;

interface

uses
  Windows, ShFolder, ShellAPI;

function CreateFile(const FileName: string; CreatingFlag: LongWord = OPEN_ALWAYS; CreatePathIfNotExists: Boolean = True): THandle; overload;
{
  ������ ��� ��������� ���� � ���������� ����� �� ����.

  CreatingFlag:
    CREATE_ALWAYS - ������ ��������� ����
    CREATE_NEW - ���������, ������ ���� ���� �� ����������, � ���� ���������� - ���������� ������
    OPEN_ALWAYS - ���� ���� ���������� - ���������, ���� ��� - ������ � ���������
    OPEN_EXISTING - ���������, ������ ���� ���� ����������
    TRUNCATE_EXISTING - ��������� � ������� ����������
	
  CreatePathIfNotExists:
    True - ��������� �������� ��������� ���� � �����
	False - �� ��������� ����� 
}

function GetFileSize(const FileName: string): LongWord; overload;
{
  �������� ������ �����
}

function LoadFileToMemory(const FileName: string): Pointer;
{
  ��������� ���� � ������
}

function DeleteDirectory(Directory: string): Boolean;
{
  ������� ����� ������ � ������� (�������������� �����, �������� *.exe)
}

function GetSpecialFolderPath(Folder: Integer): string;
{
  �������� ����, ��������� � ���������� ����� (CSIDL_*)
}

const  
  CSIDL_APPDATA          = 26;
  CSIDL_DRIVES           = 17; // ��� ���������
  CSIDL_SYSTEM           = 37; // C:\Windows\System32
  CSIDL_WINDOWS          = 36; // C:\Windows
  CSIDL_BITBUCKET        = 10; // �������

  CSIDL_COOKIES          = 33;
  CSIDL_DESKTOP          = 0;
  CSIDL_FONTS            = 20;
  CSIDL_HISTORY          = 34;
  CSIDL_INTERNET         = 1;
  CSIDL_INTERNET_CACHE   = 32;
  CSIDL_COMMON_STARTMENU = 22;
  CSIDL_STARTMENU        = 11;
  CSIDL_LOCAL_APPDATA    = 28;
  CSIDL_ADMINTOOLS       = 48;    


procedure CreatePath(EndDir: string);
{
  ������ �������� ��������� �� ��������� �������� ������������.
  ����������� �����������: "\" � "/"
}

function ExtractFileDir(Path: string): string;
{
  ��������� ���� � �����. ����������� �����������: "\" � "/"
}

function ExtractFileName(Path: string): string;
{
  ��������� ��� �����. ����������� �����������: "\" � "/"
}

function ExtractHost(Path: string): string;
{
  ��������� ��� ����� �� �������� ������.
  http://site.ru/folder/script.php  -->  site.ru
}

function ExtractObject(Path: string): string;
{
  ��������� ��� ������� �� �������� ������:
  http://site.ru/folder/script.php  -->  folder/script.php
}

implementation

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// ��������� ������ � �������� �������� � ��������:
// ����������� ����������� "\" � "/"

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function CreateFile(const FileName: string; CreatingFlag: LongWord = OPEN_ALWAYS; CreatePathIfNotExists: Boolean = True): THandle; overload;
begin
  if CreatePathIfNotExists then CreatePath(ExtractFileDir(FileName) + '\');

  Result := Windows.CreateFile(
                                PChar(FileName),
                                GENERIC_READ or GENERIC_WRITE,
                                FILE_SHARE_READ or FILE_SHARE_WRITE,
                                nil,
                                CreatingFlag,
                                FILE_ATTRIBUTE_NORMAL,
                                0
                               );

end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetFileSize(const FileName: string): LongWord; overload;
var
  hFile: THandle;
begin
  hFile := CreateFile(FileName);
  Result := Windows.GetFileSize(hFile, nil);
  CloseHandle(hFile);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function LoadFileToMemory(const FileName: string): Pointer;
var
  hFile: THandle;
  FileSize: LongWord;
  ReadBytes: LongWord;
begin
  Result := nil;
  hFile := CreateFile(FileName);
  
  if hFile <> 0 then
  begin
    FileSize := Windows.GetFileSize(hFile, nil);
    GetMem(Result, FileSize);

    ReadFile(hFile, Result^, FileSize, ReadBytes, nil);
    CloseHandle(hFile);
  end;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function DeleteDirectory(Directory: string): Boolean;
var
  FileOpStruct: TSHFileOpStruct;
begin
  ZeroMemory(@FileOpStruct, SizeOf(FileOpStruct));
  with FileOpStruct do
  begin
    wFunc  := FO_DELETE;
    fFlags := FOF_SILENT or FOF_NOCONFIRMATION;
    pFrom  := PChar(Directory + #0);
  end;
  Result := ShFileOperation(FileOpStruct) = 0;
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

function GetSpecialFolderPath(Folder: Integer): string;
const
  SHGFP_TYPE_CURRENT = 0;
var
  Path: array [0..MAX_PATH] of Char;
begin
  if SUCCEEDED(SHGetFolderPath(0, Folder, 0, SHGFP_TYPE_CURRENT, @Path[0])) then
    Result := Path
  else
    Result := '';
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// ������ �������� ����� �� �������� ��������� ����� ������������:
procedure CreatePath(EndDir: string);
var
  I: LongWord;
  PathLen: LongWord;
  TempPath: string;
begin
  PathLen := Length(EndDir);
  if (EndDir[PathLen] = '\') or (EndDir[PathLen] = '/') then Dec(PathLen);
  TempPath := Copy(EndDir, 0, 3);
  for I := 4 to PathLen do
  begin
    if (EndDir[I] = '\') or (EndDir[I] = '/') then CreateDirectory(PAnsiChar(TempPath), nil);
    TempPath := TempPath + EndDir[I];
  end;
  CreateDirectory(PAnsiChar(TempPath), nil);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// �������� �������, � ������� ����� ����:
function ExtractFileDir(Path: string): string;
var
  I: LongWord;
  PathLen: LongWord;
begin
  PathLen := Length(Path);
  I := PathLen;
  while (I <> 0) and (Path[I] <> '\') and (Path[I] <> '/') do Dec(I);
  Result := Copy(Path, 0, I);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// �������� ��� �����:
function ExtractFileName(Path: string): string;
var
  I: LongWord;
  PathLen: LongWord;
begin
  PathLen := Length(Path);
  I := PathLen;
  while (Path[I] <> '\') and (Path[I] <> '/') and (I <> 0) do Dec(I);
  Result := Copy(Path, I + 1, PathLen - I);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// ��������� ��� �����:
// http://site.ru/folder/script.php  -->  site.ru
function ExtractHost(Path: string): string;
var
  I: LongWord;
  PathLen: LongWord;
begin
  PathLen := Length(Path);
  I := 8; // ����� "http://"
  while (I <= PathLen) and (Path[I] <> '\') and (Path[I] <> '/') do Inc(I);
  Result := Copy(Path, 8, I - 8);
end;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

// ��������� ��� �������:
// http://site.ru/folder/script.php  -->  folder/script.php
function ExtractObject(Path: string): string;
var
  I: LongWord;
  PathLen: LongWord;
begin
  PathLen := Length(Path);
  I := 8;
  while (I <= PathLen) and (Path[I] <> '\') and (Path[I] <> '/') do Inc(I);
  Result := Copy(Path, I + 1, PathLen - I);
end;


end.
