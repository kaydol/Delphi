unit Tetrino_Effects;

{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, RTTICtrls, Forms, Controls, Graphics,
  Dialogs, ExtCtrls, EditBtn, LResources, mmsystem;


type
  TetrinoEffects = class(TForm)
    procedure PlayRezSound(SoundName: string);
  end;

implementation

procedure TetrinoEffects.PlayRezSound(SoundName: string);
var
  lres : TLazarusResourceStream;
begin
  lres:=TLazarusResourceStream.Create(SoundName,'WAV');
  sndPlaySound(lres.Memory, SND_MEMORY or SND_ASYNC);
  lres.Free;
end;

initialization
{$I sound.lrc}

end.

