unit UConsModelos;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, UConsNovo, StdCtrls, ComCtrls, Grids, DBGrids, Buttons, ExtCtrls, DB, 
  UVendasCaixa, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, 
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, 
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Stan.Param, FireDAC.DatS, 
  FireDAC.DApt.Intf, FireDAC.DApt, FireDAC.Comp.ScriptCommands, 
  FireDAC.Stan.Util, FireDAC.Comp.Client, FireDAC.Comp.Script, 
  FireDAC.Comp.DataSet;

type
  TFrmConsModelos = class(TFrmConsNovo)
    QModelos: TFDQuery;
    DSModelos: TDataSource;
    QModelosCODIGO: TIntegerField;
    QModelosDESCRICAO: TStringField;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BtnOKClick(Sender: TObject);
    procedure BtnSairClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnLocalizarClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmConsModelos: TFrmConsModelos;

implementation
uses
  Udm, UDAVOrdemServico, UMenuFiscal;

{$R *.dfm}

procedure TFrmConsModelos.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  inherited;
  if dm.IBTRServer.Active then
     dm.IBTRServer.Commit;
  QModelos.Close;

  {grava a posicao do combo}
  dm.GravaIni(GetCurrentDir + '\cnfcomercio.ini', 'PosicaoCombobox', 'FrmConsModelos.ComboCons', inttostr(ComboCons.itemIndex));
  Action:= caFree;
  Self := nil;
end;

procedure TFrmConsModelos.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  inherited;
   if (ssAlt in Shift) and (chr(Key) in ['M', 'm']) then
      begin
         if (iCodPreVenda = 0) and (iCodOrcamento = 0) and (iCodOrdemServico = 0) and (iCodigoVenda = 0) and (iCodContaCliente = 0) then
            begin
               Application.CreateForm(TFrmMenuFiscal, FrmMenuFiscal);
               FrmMenuFiscal.showmodal;
            end;
      end;
end;

procedure TFrmConsModelos.BtnOKClick(Sender: TObject);
begin
  inherited;
  if dm.IBTRServer.Active then
     dm.IBTRServer.Commit;
  dm.IBTRServer.StartTransaction;
  with QModelos do
     begin
        close;
        sql.Clear;
        sql.Add('SELECT * FROM MODELOS');
        case ComboCons.ItemIndex of
         0: sql.add(' WHERE DESCRICAO LIKE ' + #39 + '%' +
                      edtcons.Text + '%' + #39 + ' ORDER BY DESCRICAO');
         1: sql.add(' WHERE DESCRICAO LIKE ' + #39 +
                      edtcons.Text + '%' + #39 + ' ORDER BY DESCRICAO');
         2: begin
               if EdtCons.Text = '' then
                  sql.add(' ORDER BY CODIGO')
               else
                  sql.add(' WHERE CODIGO = ' + edtcons.Text);
            end;
        end;
        open;
     end;
  dbgrid.SetFocus;
end;

procedure TFrmConsModelos.BtnSairClick(Sender: TObject);
begin
  inherited;
  close;
end;

procedure TFrmConsModelos.FormShow(Sender: TObject);
begin
  inherited;
  {busca a posicao do combo}
  try
    ComboCons.ItemIndex:= strtoint(dm.LeINI(GetCurrentDir + '\cnfcomercio.ini', 'PosicaoCombobox', 'FrmConsModelos.ComboCons'));
  except
    ComboCons.ItemIndex:= 0;
  end;
end;

procedure TFrmConsModelos.BtnLocalizarClick(Sender: TObject);
begin
  inherited;
  case tag of
   0: begin
         with FrmDAVOrdemServico do
            begin
               EdtCodModelo.Text  := QModelosCODIGO.AsString;
               EdtNomeModelo.Text := QModelosDESCRICAO.AsString;
               EdtAnoFabricacao.SetFocus;
            end;
         close;
      end;
  end;
end;

end.
