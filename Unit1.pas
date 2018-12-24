unit Unit1;

interface

uses
  System.Types, System.Sysutils ,System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.ListBox, FMX.Edit,
  FMX.Objects;

type
  // Sorozat class
  TSorozat = class
    private
      // adatok
      nev    : String;
      evad   : Integer;
      epizod : Integer;
    public
      // getterek
      property GetNev: String
          read nev;
      property GetEvad : Integer
          read evad;
      property GetEpizod : Integer
          read epizod;
      procedure Serialize(serializer: TStringList);

      // konstruktor
      constructor Create(const nev : String; const evad : Integer; const epizod : Integer);
  end;


//Form
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    title: TLabel;
    Label2: TLabel;
    evadEdit: TEdit;
    Label3: TLabel;
    epizodEdit: TEdit;
    save: TButton;
    deleteBtn: TButton;
    Label4: TLabel;
    Line1: TLine;
    Label5: TLabel;
    newEdit: TEdit;
    newSave: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject); //�j "kiv�lasztott"
    procedure saveClick(Sender: TObject);       //kiv�lasztott sorozat adatainak ment�se
    procedure deleteBtnClick(Sender: TObject);  //kiv�lasztott sorozat t�rl�se
    procedure newSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);    //�j sorozat hozz�ad�sa list�hoz

  private
    // sorozatok list�ja
    sorozatlista : TList;
    kivalasztva : TSorozat;    //�ppen kiv�lasztott sorozat
    // procedure
    procedure FillComboBox; //combobox felt�lt�se lista alapj�n
    procedure ChangeComponents(enable : Boolean); //UI elemek ki/be kapcsol�sa
    procedure UpdateUI; //a kiv�lasztott sorozat adatainak megjelen�t�se
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}
//--Sorozat konstruktor--------------------------------------------------------------------------
constructor TSorozat.Create(const nev  : String; const evad : Integer; const epizod : Integer);
begin
  self.nev   := nev;
  self.evad  := evad;
  self.epizod:= epizod;
end;

//--Sorozat serializ�l�---------------------------------------------------------------------------
procedure TSorozat.Serialize(serializer: TStringList);
begin
  serializer.Add(format('%s_%s_%s', [nev, evad.ToString, epizod.ToString]));
end;

function DeserializeSorozatList(const filename: string) : TList;
var
  i: Integer;
  soradat : TArray<string>;
  deserializer: TStringList;
  lista: TList;

begin
  lista := TList.Create;
  deserializer := TStringList.Create;

  deserializer.LoadFromFile(filename);
  for i := 0 to deserializer.Count-1 do
  begin
  soradat := deserializer[i].Split(['_'],3);
    lista.Add(TSorozat.Create(soradat[0],soradat[1].ToInteger,soradat[2].ToInteger()));
    ShowMessage(soradat[0]);
  end;

  Result := lista;
end;


procedure SerializeSorozatList(const sorozatlista: TList; const filename: string);
var
  serializer: TStringList;
  i: integer;
begin
  serializer := TStringList.Create;
  try
    for i := 0 to sorozatlista.Count - 1 do
      TSorozat(sorozatlista[i]).Serialize(serializer);
    serializer.SaveToFile(filename);

  finally
    serializer.Free;
  end;
end;

//////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////


//--Form konstruktor--------------------------------------------------------------------------


procedure TForm1.FormCreate(Sender: TObject);
begin
  // lista l�trehoz�sa
  sorozatlista := DeserializeSorozatList('database.db');


  FillComboBox;

end;

//--Form destruktor----------------------------------------------------------------------------
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SerializeSorozatList(sorozatlista,'database.db');
end;


//--combobox felt�lt�se lista alapj�n-----------------------------------------------------

function CompareSorozat(sorozat1, sorozat2: TSorozat): Integer;   //k�t sorozat �sszehasonl�t�sa c�m alapj�n
begin
  Result := CompareText (sorozat1.nev, sorozat2.nev);
end;

procedure TForm1.FillComboBox;
var
  i : Integer;
begin
  ComboBox1.Clear;
  ChangeComponents(false);


  sorozatlista.Sort(@CompareSorozat);    //rendez�s

  for i := 0 to sorozatlista.Count-1 do
  begin
    ComboBox1.Items.Add(TSorozat(sorozatlista[i]).nev);
  end;
end;



//--UI elemek ki/be kapcsol�sa--------------------------------------------------------------

procedure TForm1.ChangeComponents(enable: Boolean);
begin
  title.Visible := enable;
  evadEdit.Visible := enable;
  epizodEdit.Visible := enable;
  Label2.Visible := enable;
  Label3.Visible := enable;
  save.Visible := enable;
  deleteBtn.Visible := enable;

end;

//---a kiv�lasztott sorozat adatainak megjelen�t�se---------------------------------------

procedure TForm1.UpdateUI;
begin
  title.text := kivalasztva.nev;
  evadEdit.Text := kivalasztva.evad.ToString;
  epizodEdit.Text := kivalasztva.epizod.ToString;
end;

//--eventek-----------------------------------------------------------------------------------------

procedure TForm1.saveClick(Sender: TObject);
begin
  try
    kivalasztva.evad := evadEdit.Text.ToInteger();
    kivalasztva.epizod := epizodEdit.Text.ToInteger();
  except
    ShowMessage('Hib�s adat!');
  end;

end;

procedure TForm1.deleteBtnClick(Sender: TObject);
begin
  sorozatlista.Remove(kivalasztva);
  FillComboBox;
  ChangeComponents(false);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
var
  selected : TSorozat;
begin
  ChangeComponents(true);
  selected := sorozatlista[ComboBox1.Selected.Index];
  kivalasztva := selected;
  title.Text := selected.nev;
  evadEdit.Text := selected.evad.ToString;
  epizodEdit.Text := selected.epizod.ToString;

end;

procedure TForm1.newSaveClick(Sender: TObject);
var
  ujsorozat : TSorozat;
begin
   if String.IsNullOrEmpty(newEdit.Text) then
   begin
    ShowMessage('�res c�m mez�!');
   end
   else
   begin
    ujsorozat := TSorozat.Create(newEdit.Text, 1,1);
    sorozatlista.Add(ujsorozat);
    FillComboBox;
    ComboBox1.ItemIndex := sorozatlista.IndexOf(ujsorozat);
    kivalasztva := ujsorozat;
    UpdateUI;
    ChangeComponents(true);
   end;

end;


end.
