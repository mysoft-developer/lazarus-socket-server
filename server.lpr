program server;

uses
  Classes,
  SysUtils,
  Math,
  SfmlNetwork in '.\SfmlNetwork.pas';

const
  PORT = 1717;

var
  pSocket: PsfmlTcpSocket;
  Listener: TsfmlTcpListener;
  AddressRecord: TSfmlIpAddress;
  MsgFromClient: array[0..99] of char;
  MsgSize: longword;
  PMsg: pointer;

  procedure Loop;
  var
    i: integer;
    msg: string;
    status: TSfmlSocketStatus;
    flag: boolean;

  begin
    i := 0;
    flag := True;

    while flag do
    begin
      i := i + 1;
      msg := 'mensagem : ' + IntToStr(i);

      status := SfmlTcpSocketSend(psocket, PChar(msg), 18);
      if status = sfSocketDone then
      begin
        writeln('Message sent to the client: ', PChar(msg));

        PMsg := @MsgFromClient;
        if SfmlTcpSocketReceive(pSocket, PMsg, 100, MsgSize) = sfSocketDone then
          writeln('Answer received from the client: ', MsgFromClient);
      end
      else if status = sfSocketDisconnected then
      begin
        SfmlTcpSocketDisconnect(pSocket);
        flag := False;
      end;
    end;
  end;

  procedure Wait;
  begin
    // Wait for a connection
    while True do
    begin
      if Listener.accept(pSocket) = sfSocketDone then
      begin
        AddressRecord := SfmlTcpSocketGetRemoteAddress(psocket);
        writeln('Client connected: ', AddressRecord.Address);

        Loop;

        AddressRecord := SfmlTcpSocketGetRemoteAddress(psocket);
        if AddressRecord.Address = '0.0.0.0' then
          writeln('Server is listening to port ', port, ' waiting for connections... ');
      end;
    end;
  end;

  procedure Connect(MyPort: integer);
  begin
    Listener := TsfmlTcpListener.Create;

    // Listen to the given port for incoming connections
    while Listener.listen(MyPort, AddressRecord) <> sfSocketDone do
    begin
      Sleep(100);
    end;

    writeln('Server is listening to port ', MyPort, ' waiting for connections... ');
    Wait;
  end;

begin
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
    exOverflow, exUnderflow, exPrecision]);

  Connect(port);
  Loop;
end.
