program QRTest;

{$mode objfpc}{$H+}

{ Based on :-
        Demo app for ZXing QRCode port to Delphi, by Debenu Pty Ltd
        www.debenu.com

  pjde 2021
}

uses
  RaspberryPi3,
  GlobalConfig,
  GlobalConst,
  GlobalTypes,
  Platform,
  Threads,
  SysUtils,
  Classes,
  DelphiZXingQRCode,
  Console,
  GraphicsConsole,
  uTFTP,
  Winsock2,
  Ultibo;

var
  Console1, Console2 : TWindowHandle;
  QRCode : TDelphiZXingQRCode;
  Row, Column : integer;
  IPAddress : string;
  Properties : TWindowProperties;
  xo, yo : integer;

const
  Size = 8;       // nos of pixels making one bit

procedure Log (s : string);
begin
  ConsoleWindowWriteLn (Console1, s);
end;

procedure Msg (Sender : TObject; s : string);
begin
  Log (s);
end;

procedure WaitForSDDrive;
begin
  while not DirectoryExists ('C:\') do sleep (500);
end;

function WaitForIPComplete : string;
var
  TCP : TWinsock2TCPClient;
begin
  TCP := TWinsock2TCPClient.Create;
  Result := TCP.LocalAddress;
  if (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') then
    begin
      while (Result = '') or (Result = '0.0.0.0') or (Result = '255.255.255.255') do
        begin
          sleep (1000);
          Result := TCP.LocalAddress;
        end;
    end;
  TCP.Free;
end;

begin
  Console1 := ConsoleWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_RIGHT, true);
  Console2 := GraphicsWindowCreate (ConsoleDeviceGetDefault, CONSOLE_POSITION_LEFT);
  GraphicsWindowsetBackcolor (Console2, COLOR_BLACK);
  GraphicsWindowClear (Console2);
  GraphicsWindowGetProperties (Console2, @Properties);
  Log ('Quick Response Code Test.');
  WaitForSDDrive;
  Log ('SD Drive Ready.');
  IPAddress := WaitForIPComplete;
  Log ('TFTP Syntax "tftp -i ' + IPAddress + ' put kernel7.img"');
  SetOnMsg (@Msg);

  QRCode := TDelphiZXingQRCode.Create;
  try
    QRCode.Data := 'https://ultibo.org/forum/index.php';
    QRCode.Encoding := qrAuto;
    QRCode.QuietZone := 4;
    yo := 100;
    xo := ((Properties.X2 - Properties.X1) - (QRCode.Columns * Size)) div 2;
    for Row := 0 to QRCode.Rows - 1 do
      for Column := 0 to QRCode.Columns - 1 do
        if not QRCode.IsBlack[Row, Column] then
          begin
            GraphicsWindowDrawBlock (Console2, Column * Size + xo, Row * Size + yo, (Column + 1) * Size + xo, (Row + 1) * Size + yo, COLOR_WHITE);
          end;
  finally
    QRCode.Free;
  end;
end.

