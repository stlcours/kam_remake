unit KM_InterfaceGamePlay;
interface
uses SysUtils, KromUtils, KromOGLUtils, Math, Classes, Controls, StrUtils, Windows,
  KM_Controls, KM_Houses, KM_Units, KM_Defaults, KM_LoadDAT, KM_CommonTypes, KM_Utils;


//todo: @Krom: I think we should highlight the selected message, (make it brighter or something) so that people know which one they have open.

type TKMGamePlayInterface = class
  protected
    ToolBarX:integer;
  protected
    ShownUnit:TKMUnit;
    ShownHouse:TKMHouse;
    ShownHint:TObject;
    ShownMessage:integer;
    LastSchoolUnit:integer;  //Last unit that was selected in School, global for all schools player owns
    LastBarracksUnit:integer;//Last unit that was selected in Barracks, global for all barracks player owns
    fMessageList:TKMMessageList;
    AskDemolish:boolean;

    Panel_Main:TKMPanel;
      Image_Main1,Image_Main2,Image_Main3,Image_Main4:TKMImage; //Toolbar background
      KMMinimap:TKMMinimap;
      Label_Stat,Label_Hint,Label_PointerCount:TKMLabel;
      Button_Main:array[1..5]of TKMButton; //4 common buttons + Return
      Image_Message:array[1..32]of TKMImage; //Queue of messages covers 32*48=1536px height
      Image_Clock:TKMImage; //Clock displayed when game speed is increased
      Label_Clock:TKMLabel;
      Label_MenuTitle: TKMLabel; //Displays the title of the current menu to the right of return
    Panel_Message:TKMPanel;
      Image_MessageBG:TKMImage;
      Image_MessageBGTop:TKMImage;
      Label_MessageText:TKMLabel;
      Button_MessageGoTo: TKMButton;
      Button_MessageDelete: TKMButton;
      Button_MessageClose: TKMButton;
      //For multiplayer: Send, reply, text area for typing, etc.
    Panel_Pause:TKMPanel;
      Bevel_Pause:TKMBevel;
      Image_Pause:TKMImage;
      Label_Pause1:TKMLabel;
      Label_Pause2:TKMLabel;
    Panel_Ratios:TKMPanel;
      Button_Ratios:array[1..4]of TKMButton;
      Image_RatioPic0:TKMImage;
      Label_RatioLab0:TKMLabel;
      Image_RatioPic:array[1..4]of TKMImage;
      Label_RatioLab:array[1..4]of TKMLabel;
      Ratio_RatioRat:array[1..4]of TKMRatioRow;
    Panel_Stats:TKMPanel;
      Stat_HousePic,Stat_UnitPic:array[1..32]of TKMImage;
      Stat_HouseQty,Stat_UnitQty:array[1..32]of TKMLabel;

    Panel_Build:TKMPanel;
      Label_Build:TKMLabel;
      Image_Build_Selected:TKMImage;
      Image_BuildCost_WoodPic:TKMImage;
      Image_BuildCost_StonePic:TKMImage;
      Label_BuildCost_Wood:TKMLabel;
      Label_BuildCost_Stone:TKMLabel;
      Button_BuildRoad,Button_BuildField,Button_BuildWine{,Button_BuildWall},Button_BuildCancel:TKMButtonFlat;
      Button_Build:array[1..HOUSE_COUNT]of TKMButtonFlat;

    Panel_Menu:TKMPanel;
      Button_Menu_Save,Button_Menu_Load,Button_Menu_Settings,Button_Menu_Quit,Button_Menu_TrackUp,Button_Menu_TrackDown:TKMButton;
      Label_Menu_Music, Label_Menu_Track: TKMLabel;

      Panel_Save:TKMPanel;
        Button_Save:array[1..SAVEGAME_COUNT]of TKMButton;

      Panel_Load:TKMPanel;
        Button_Load:array[1..SAVEGAME_COUNT]of TKMButton;

      Panel_Settings:TKMPanel;
        Label_Settings_BrightValue:TKMLabel;
        Button_Settings_Dark,Button_Settings_Light:TKMButton;
        CheckBox_Settings_Autosave,CheckBox_Settings_FastScroll:TKMCheckBox;
        Label_Settings_MouseSpeed,Label_Settings_SFX,Label_Settings_Music,Label_Settings_Music2:TKMLabel;
        Ratio_Settings_Mouse,Ratio_Settings_SFX,Ratio_Settings_Music:TKMRatioRow;
        Button_Settings_Music:TKMButton;

      Panel_Quit:TKMPanel;
        Button_Quit_Yes,Button_Quit_No:TKMButton;

    Panel_Unit:TKMPanel;
      Label_UnitName:TKMLabel;
      Label_UnitCondition:TKMLabel;
      Label_UnitTask:TKMLabel;
      Label_UnitAct:TKMLabel;
      Label_UnitDescription:TKMLabel;
      ConditionBar_Unit:TKMPercentBar;
      Image_UnitPic:TKMImage;
      Button_Die:TKMButton;

    Panel_House:TKMPanel;
      Label_House:TKMLabel;
      Button_House_Goods,Button_House_Repair:TKMButton;
      Image_House_Logo,Image_House_Worker:TKMImage;
      HealthBar_House:TKMPercentBar;
      Label_HouseHealth:TKMLabel;

    Panel_House_Common:TKMPanel;
      Label_Common_Demand,Label_Common_Offer,Label_Common_Costs,
      Label_House_UnderConstruction,Label_House_Demolish:TKMLabel;
      Button_House_DemolishYes,Button_House_DemolishNo:TKMButton;
      Row__Common_Resource:array[1..4]of TKMResourceRow; //4 bars is the maximum
      Row__Order:array[1..4]of TKMResourceOrderRow; //3 bars is the maximum
      Row__Costs:array[1..4]of TKMCostsRow; //3 bars is the maximum
    Panel_HouseStore:TKMPanel;
      Button_Store:array[1..28]of TKMButtonFlat;
      Image_Store_Accept:array[1..28]of TKMImage;
    Panel_House_School:TKMPanel;
      Label_School_Res:TKMLabel;
      ResRow_School_Resource:TKMResourceRow;
      Button_School_UnitWIP:TKMButton;
      Button_School_UnitWIPBar:TKMPercentBar;
      Button_School_UnitPlan:array[1..5]of TKMButtonFlat;
      Label_School_Unit:TKMLabel;
      Image_School_Right,Image_School_Train,Image_School_Left:TKMImage;
      Button_School_Right,Button_School_Train,Button_School_Left:TKMButton;
    Panel_HouseBarracks:TKMPanel;
      Button_Barracks:array[1..12]of TKMButtonFlat;
      Label_Barracks_Unit:TKMLabel;
      Image_Barracks_Right,Image_Barracks_Train,Image_Barracks_Left:TKMImage;
      Button_Barracks_Right,Button_Barracks_Train,Button_Barracks_Left:TKMButton;
  private
    procedure Create_Message_Page;
    procedure Create_Pause_Page;
    procedure Create_Build_Page;
    procedure Create_Ratios_Page;
    procedure Create_Stats_Page;
    procedure Create_Menu_Page;
    procedure Create_Save_Page;
    procedure Create_Load_Page;
    procedure Create_Settings_Page;
    procedure Create_Quit_Page;
    procedure Create_Unit_Page;
    procedure Create_House_Page;
    procedure Create_Store_Page;
    procedure Create_School_Page;
    procedure Create_Barracks_Page;

    procedure SaveGame(Sender: TObject);
    procedure Load_Click(Sender: TObject);
    procedure SwitchPage(Sender: TObject);
    procedure SwitchPageRatios(Sender: TObject);
    procedure RatiosChange(Sender: TObject);
    procedure DisplayHint(Sender: TObject; AShift:TShiftState; X,Y:integer);
    procedure Minimap_Update(Sender: TObject);
    procedure UpdateMessageStack;
    procedure DisplayMessage(Sender: TObject);
    procedure CloseMessage(Sender: TObject);
    procedure DeleteMessage(Sender: TObject);
    procedure GoToMessage(Sender: TObject);
    procedure Build_ButtonClick(Sender: TObject);
    procedure Build_Fill(Sender:TObject);
    procedure Store_Fill(Sender:TObject);
    procedure Stats_Fill(Sender:TObject);
    procedure Menu_Fill(Sender:TObject);
  public
    MyControls: TKMControlsCollection;
    constructor Create;
    destructor Destroy; override;
    procedure SetScreenSize(X,Y:word);
    procedure ShowHouseInfo(Sender:TKMHouse; aAskDemolish:boolean=false);
    procedure ShowUnitInfo(Sender:TKMUnit);
    procedure Unit_Die(Sender:TObject);
    procedure House_Demolish(Sender:TObject);
    procedure House_RepairToggle(Sender:TObject);
    procedure House_WareDeliveryToggle(Sender:TObject);
    procedure House_OrderClick(Sender:TObject);
    procedure House_OrderClickRight(Sender:TObject);
    procedure House_BarracksUnitChange(Sender:TObject);
    procedure House_BarracksUnitChangeRight(Sender:TObject);
    procedure House_SchoolUnitChange(Sender:TObject);
    procedure House_SchoolUnitChangeRight(Sender:TObject);
    procedure House_SchoolUnitRemove(Sender:TObject);
    procedure House_StoreAcceptFlag(Sender:TObject);
    procedure Menu_ShowSettings(Sender: TObject);
    procedure Menu_Settings_Change(Sender:TObject);
    procedure Menu_ShowLoad(Sender: TObject);
    procedure Menu_QuitMission(Sender:TObject);
    procedure Menu_NextTrack(Sender:TObject);
    procedure Menu_PreviousTrack(Sender:TObject);
    procedure Build_SelectRoad;
    procedure Build_RightClickCancel;
    procedure IssueMessage(MsgTyp:TKMMessageType; Text:string; Loc:TKMPoint);
    procedure EnableOrDisableMenuIcons(NewValue:boolean);
    procedure ShowClock(DoShow:boolean);
    procedure ShowPause(DoShow:boolean);
    procedure ShortcutPress(Key:Word; IsDown:boolean=false);
    property GetShownUnit: TKMUnit read ShownUnit;
    procedure ClearShownUnit;
    procedure Save(SaveStream:TKMemoryStream);
    procedure Load(LoadStream:TKMemoryStream);
    procedure UpdateState;
    procedure Paint;
  end;


implementation
uses KM_Unit1, KM_PlayersCollection, KM_Render, KM_LoadLib, KM_Terrain, KM_Viewport, KM_Game, KM_SoundFX;


{Switch between pages}
procedure TKMGamePlayInterface.SwitchPageRatios(Sender: TObject);
const ResPic:array[1..4] of TResourceType = (rt_Steel,rt_Coal,rt_Wood,rt_Corn);
      ResLab:array[1..4] of word = (298,300,302,304);
      ResQty:array[1..4] of byte = (2,4,2,3);
      ResHouse:array[1..4,1..4] of THouseType = (
      (ht_WeaponSmithy,ht_ArmorSmithy,ht_None,ht_None),
      (ht_IronSmithy,ht_Metallurgists,ht_WeaponSmithy,ht_ArmorSmithy),
      (ht_ArmorWorkshop,ht_WeaponWorkshop,ht_None,ht_None),
      (ht_Mill,ht_Swine,ht_Stables,ht_None));
var i:integer; ResID:TResourceType; HouseID:THouseType;
begin

  if (MyPlayer=nil)or(MyPlayer.fMissionSettings=nil) then exit; //We need to be able to access these

  if not (Sender is TKMButton) then exit;

  //Hide everything but the tab buttons
  for i:=1 to Panel_Ratios.ChildCount do
    if not (Panel_Ratios.Childs[i] is TKMButton) then
      Panel_Ratios.Childs[i].Hide;

  ResID:=ResPic[TKMButton(Sender).Tag];

  Image_RatioPic0.TexID:=350+byte(ResID);
  Label_RatioLab0.Caption:=fTextLibrary.GetTextString(ResLab[TKMButton(Sender).Tag]);
  Image_RatioPic0.Show;
  Label_RatioLab0.Show;

  for i:=1 to ResQty[TKMButton(Sender).Tag] do begin
    HouseID:=ResHouse[TKMButton(Sender).Tag,i];
    Image_RatioPic[i].TexID:=GUIBuildIcons[byte(HouseID)];
    Label_RatioLab[i].Caption:=fTextLibrary.GetTextString(GUIBuildIcons[byte(HouseID)]-300);
    Ratio_RatioRat[i].Position:=MyPlayer.fMissionSettings.GetRatio(ResID,HouseID);
    Image_RatioPic[i].Show;
    Label_RatioLab[i].Show;
    Ratio_RatioRat[i].Show;
  end;
end;


procedure TKMGamePlayInterface.RatiosChange(Sender: TObject);
var ResID:TResourceType; HouseID:THouseType;
begin
  if (MyPlayer=nil)or(MyPlayer.fMissionSettings=nil) then exit; //We need to be able to access these
  if not (Sender is TKMRatioRow) then exit;

  ResID:=TResourceType(Image_RatioPic0.TexID-350);
  HouseID:=THouseType(Image_RatioPic[TKMRatioRow(Sender).Tag].TexID-300);

  MyPlayer.fMissionSettings.SetRatio(ResID,HouseID,TKMRatioRow(Sender).Position);
end;


procedure TKMGamePlayInterface.SaveGame(Sender: TObject);
var savename:string;
begin
  if not (Sender is TKMButton) then exit; //Just in case

  savename := fGame.Save(TKMControl(Sender).Tag);

  if savename <> '' then
    TKMButton(Sender).Caption := savename
  else
    TKMButton(Sender).Caption := 'Savegame #'+inttostr(TKMControl(Sender).Tag);
  
  SwitchPage(nil); //Close save menu after saving
end;


procedure TKMGamePlayInterface.Load_Click(Sender: TObject);
begin
  fGame.Load(TKMControl(Sender).Tag);
end;



{Switch between pages}
procedure TKMGamePlayInterface.SwitchPage(Sender: TObject);
var i:integer; LastVisiblePage: TKMPanel;

  procedure Flip4MainButtons(ShowEm:boolean);
  var k:integer;
  begin
    for k:=1 to 4 do Button_Main[k].Visible:=ShowEm;
    Button_Main[5].Visible:=not ShowEm;
    Label_MenuTitle.Visible:=not ShowEm;
  end;

begin

  if (Sender=Button_Main[1])or(Sender=Button_Main[2])or
     (Sender=Button_Main[3])or(Sender=Button_Main[4])or
     (Sender=Button_Menu_Settings)or(Sender=Button_Menu_Quit) then begin
    ShownHouse:=nil;
    ShownUnit:=nil;
    fPlayers.Selected:=nil;
  end;

  //Reset the CursorMode, to cm_None
  Build_ButtonClick(nil);

  //Set LastVisiblePage to which ever page was last visible, out of the ones needed
  if Panel_Settings.Visible then LastVisiblePage := Panel_Settings else
  if Panel_Save.Visible     then LastVisiblePage := Panel_Save     else
  if Panel_Load.Visible     then LastVisiblePage := Panel_Load     else
    LastVisiblePage := nil;

  //If they just closed settings then we should save them (if something has changed)
  if LastVisiblePage = Panel_Settings then
    if fGame.fGameSettings.GetNeedsSave then
      fGame.fGameSettings.SaveSettings;

  //First thing - hide all existing pages, except for message page
    for i:=1 to Panel_Main.ChildCount do
      if (Panel_Main.Childs[i] is TKMPanel) and (Panel_Main.Childs[i] <> Panel_Message) then
        Panel_Main.Childs[i].Hide;
  //First thing - hide all existing pages
    for i:=1 to Panel_House.ChildCount do
      if Panel_House.Childs[i] is TKMPanel then
        Panel_House.Childs[i].Hide;

  //If Sender is one of 4 main buttons, then open the page, hide the buttons and show Return button
  Flip4MainButtons(false);
  if Sender=Button_Main[1] then begin
    Build_Fill(nil);
    Panel_Build.Show;
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(166);
    Build_SelectRoad;
  end else

  if Sender=Button_Main[2] then begin
    Panel_Ratios.Show;
    SwitchPageRatios(Button_Ratios[1]); //Open 1st tab
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(167);
  end else

  if Sender=Button_Main[3] then begin
    Stats_Fill(nil);
    Panel_Stats.Show;
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(168);
  end else

  if (Sender=Button_Main[4]) or (Sender=Button_Quit_No) or
     ((Sender=Button_Main[5]) and (LastVisiblePage=Panel_Settings)) or
     ((Sender=Button_Main[5]) and (LastVisiblePage=Panel_Load)) or
     ((Sender=Button_Main[5]) and (LastVisiblePage=Panel_Save)) then begin
    Menu_Fill(Sender); //Make sure updating happens before it is shown
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(170);
    Panel_Menu.Show;
  end else

  if Sender=Button_Menu_Save then begin
    Panel_Save.Show;
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(173);
  end else

  if Sender=Button_Menu_Load then begin
    Panel_Load.Show;
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(172);
  end else

  if Sender=Button_Menu_Settings then begin
    Panel_Settings.Show;
    Label_MenuTitle.Caption:=fTextLibrary.GetTextString(179);
  end else

  if Sender=Button_Menu_Quit then begin
    Panel_Quit.Show;
  end else
    //If Sender is anything else - then show all 4 buttons and hide Return button
    Flip4MainButtons(true);

  //Now process all other kinds of pages
  if Sender=Panel_Unit then begin
    TKMPanel(Sender).Show;
  end else

  if Sender=Panel_House then begin
    TKMPanel(Sender).Show;
  end;

  if Sender=Panel_House_Common then begin
    TKMPanel(Sender).Parent.Show;
    TKMPanel(Sender).Show;
  end else

  if Sender=Panel_House_School then begin
    TKMPanel(Sender).Parent.Show;
    TKMPanel(Sender).Show;
  end else

  if Sender=Panel_HouseBarracks then begin
    TKMPanel(Sender).Parent.Show;
    TKMPanel(Sender).Show;
  end else

  if Sender=Panel_HouseStore then begin
    TKMPanel(Sender).Parent.Show;
    TKMPanel(Sender).Show;
  end;

end;


procedure TKMGamePlayInterface.DisplayHint(Sender: TObject; AShift:TShiftState; X,Y:integer);
begin
  ShownHint:=Sender;
  if((ShownHint<>nil) and ((not TKMControl(ShownHint).CursorOver) or (not TKMControl(ShownHint).Visible)) ) then ShownHint:=nil; //only set if cursor is over and control is visible
  if ((ShownHint<>nil) and (TKMControl(ShownHint).Parent <> nil)) then //only set if parent is visible (e.g. panel)
    if (ShownHint<>nil)and(not (ShownHint as TKMControl).Parent.Visible) then ShownHint:=nil;

  Label_Hint.Top:=fRender.GetRenderAreaSize.Y-16;
  //If hint hasn't changed then don't refresh it
  if ((ShownHint<>nil) and (Label_Hint.Caption = TKMControl(Sender).Hint)) then exit;
  if ((ShownHint=nil) and (Label_Hint.Caption = '')) then exit;
  if ShownHint=nil then Label_Hint.Caption:='' else
    Label_Hint.Caption:=(Sender as TKMControl).Hint;
end;


{Update minimap data}
procedure TKMGamePlayInterface.Minimap_Update(Sender: TObject);
begin
  if Sender=nil then begin //UpdateState loop
    KMMinimap.MapSize:=KMPoint(fTerrain.MapX,fTerrain.MapY);
  end else
    if KMMinimap.CenteredAt.X*KMMinimap.CenteredAt.Y <> 0 then //Quick bugfix incase minimap yet not inited it will center vp on 0;0
    fViewport.SetCenter(KMMinimap.CenteredAt.X,KMMinimap.CenteredAt.Y);

  KMMinimap.CenteredAt:=fViewport.GetCenter;
  KMMinimap.ViewArea:=fViewport.GetMinimapClip;
end;


constructor TKMGamePlayInterface.Create();
var i:integer;
begin
Inherited;
fLog.AssertToLog(fViewport<>nil,'fViewport required to be init first');

  MyControls := TKMControlsCollection.Create;

  ShownUnit:=nil;
  ShownHouse:=nil;

  LastSchoolUnit:=1;
  LastBarracksUnit:=1;
  fMessageList:=TKMMessageList.Create;

{Parent Page for whole toolbar in-game}
  Panel_Main:=MyControls.AddPanel(nil,0,0,224,768);

    Image_Main1:=MyControls.AddImage(Panel_Main,0,0,224,200,407);
    Image_Main3:=MyControls.AddImage(Panel_Main,0,200,224,168,554);
    Image_Main4:=MyControls.AddImage(Panel_Main,0,368,224,400,404);
                   MyControls.AddImage(Panel_Main,0,768,224,400,404);

    KMMinimap:=MyControls.AddMinimap(Panel_Main,10,10,176,176);
    KMMinimap.OnChange:=Minimap_Update;

    {Main 4 buttons +return button}
    for i:=0 to 3 do begin
      Button_Main[i+1]:=MyControls.AddButton(Panel_Main,  8+46*i, 372, 42, 36, 439+i);
      Button_Main[i+1].OnClick:=SwitchPage;
      Button_Main[i+1].Hint:=fTextLibrary.GetTextString(160+i);
    end;
    Button_Main[4].Hint:=fTextLibrary.GetTextString(164); //This is an exception to the rule above
    Button_Main[5]:=MyControls.AddButton(Panel_Main,  8, 372, 42, 36, 443);
    Button_Main[5].OnClick:=SwitchPage;
    Button_Main[5].Hint:=fTextLibrary.GetTextString(165);
    Label_MenuTitle:=MyControls.AddLabel(Panel_Main,54,372,138,36,'',fnt_Metal,kaLeft);

    Image_Clock:=MyControls.AddImage(Panel_Main,232,8,67,65,556);
    Image_Clock.Hide;
    Label_Clock:=MyControls.AddLabel(Panel_Main,265,80,0,0,'mm:ss',fnt_Outline,kaCenter);
    Label_Clock.Hide;

    Create_Message_Page; //Must go bellow message stack

    for i:=low(Image_Message) to high(Image_Message) do
    begin
      Image_Message[i] := MyControls.AddImage(Panel_Main,ToolBarWidth,fRender.GetRenderAreaSize.Y-i*48,30,48,495);
      Image_Message[i].Tag := i;
      Image_Message[i].Disable;
      Image_Message[i].Hide;
      Image_Message[i].OnClick := DisplayMessage;
    end;

    Label_Stat:=MyControls.AddLabel(Panel_Main,224+8,16,0,0,'',fnt_Outline,kaLeft);
    Label_Hint:=MyControls.AddLabel(Panel_Main,224+32,fRender.GetRenderAreaSize.Y-16,0,0,'',fnt_Outline,kaLeft);
    Label_PointerCount:=MyControls.AddLabel(Panel_Main,224+8,100,0,0,'',fnt_Outline,kaLeft);
    Label_PointerCount.Visible := SHOW_POINTER_COUNT;

{I plan to store all possible layouts on different pages which gets displayed one at a time}
{==========================================================================================}
  Create_Build_Page();
  Create_Ratios_Page();
  Create_Stats_Page();
  Create_Menu_Page();
    Create_Save_Page();
    Create_Load_Page();
    Create_Settings_Page();
    Create_Quit_Page();

  Create_Unit_Page();
  Create_House_Page();
    Create_Store_Page();
    Create_School_Page();
    Create_Barracks_Page();
    //Create_TownHall_Page();
  Create_Pause_Page(); //Must go at the bottom so that all controls above are faded

  //Here we must go through every control and set the hint event to be the parameter
  for i := 0 to MyControls.Count - 1 do
    if MyControls.Items[i] <> nil then
      TKMControl(MyControls.Items[i]).OnHint := DisplayHint;

  SwitchPage(nil); //Update
end;


destructor TKMGamePlayInterface.Destroy;
begin
  FreeAndNil(fMessageList);
  FreeAndNil(MyControls);
  inherited;
end;


procedure TKMGamePlayInterface.SetScreenSize(X,Y:word);
var i: integer;
begin
  Bevel_Pause.Width:=X+2;
  Image_Pause.Left:=X div 2;
  Label_Pause1.Left:=X div 2;
  Label_Pause2.Left:=X div 2;

  Bevel_Pause.Height:=Y+2;
  Image_Pause.Top:=(Y div 2)-40;
  Label_Pause1.Top:=(Y div 2);
  Label_Pause2.Top:=(Y div 2)+20;

  //Update Hint position and all messages in queue
  Label_Hint.Top:=Y-16;
  for i:=low(Image_Message) to high(Image_Message) do
  begin
    Image_Message[i].Top := Y-i*48;
  end;
end;


{Pause overlay page}
procedure TKMGamePlayInterface.Create_Pause_Page;
begin
  Panel_Pause:=MyControls.AddPanel(Panel_Main,0,0,fRender.GetRenderAreaSize.X,fRender.GetRenderAreaSize.Y);
    Bevel_Pause:=MyControls.AddBevel(Panel_Pause,-1,-1,fRender.GetRenderAreaSize.X+2,fRender.GetRenderAreaSize.Y+2);
    Image_Pause:=MyControls.AddImage(Panel_Pause,(fRender.GetRenderAreaSize.X div 2),(fRender.GetRenderAreaSize.Y div 2)-40,0,0,556);
    Image_Pause.Center;
    Label_Pause1:=MyControls.AddLabel(Panel_Pause,(fRender.GetRenderAreaSize.X div 2),(fRender.GetRenderAreaSize.Y div 2),64,16,fTextLibrary.GetTextString(308),fnt_Antiqua,kaCenter);
    Label_Pause2:=MyControls.AddLabel(Panel_Pause,(fRender.GetRenderAreaSize.X div 2),(fRender.GetRenderAreaSize.Y div 2)+20,64,16,'Press ''P'' to resume the game',fnt_Grey,kaCenter);
    Panel_Pause.Hide
end;


{Message page}
procedure TKMGamePlayInterface.Create_Message_Page;
begin
  Panel_Message:=MyControls.AddPanel(Panel_Main, TOOLBARWIDTH, fRender.GetRenderAreaSize.Y - 190, fRender.GetRenderAreaSize.X - TOOLBARWIDTH, 190);
    Image_MessageBG:=MyControls.AddImage(Panel_Message,0,20,600,170,409);
    Image_MessageBG.Anchors := Image_MessageBG.Anchors + [anRight];
    Image_MessageBGTop:=MyControls.AddImage(Panel_Message,0,0,600,20,551);
    Image_MessageBGTop.Anchors := Image_MessageBGTop.Anchors + [anRight];
    Label_MessageText:=MyControls.AddLabel(Panel_Message,47,67,432,122,'',fnt_Antiqua,kaLeft);
    Label_MessageText.AutoWrap := true;
    Button_MessageGoTo:=MyControls.AddButton(Panel_Message,490,74,100,24,fTextLibrary.GetTextString(280),fnt_Antiqua);
    Button_MessageGoTo.Hint := fTextLibrary.GetTextString(281);
    Button_MessageGoTo.OnClick := GoToMessage;
    Button_MessageGoTo.MakesSound := false;
    Button_MessageDelete:=MyControls.AddButton(Panel_Message,490,104,100,24,fTextLibrary.GetTextString(276),fnt_Antiqua);
    Button_MessageDelete.Hint := fTextLibrary.GetTextString(277);
    Button_MessageDelete.OnClick := DeleteMessage;
    Button_MessageDelete.MakesSound := false;
    Button_MessageClose:=MyControls.AddButton(Panel_Message,490,134,100,24,fTextLibrary.GetTextString(282),fnt_Antiqua);
    Button_MessageClose.Hint := fTextLibrary.GetTextString(283);
    Button_MessageClose.OnClick := CloseMessage;
    Button_MessageClose.MakesSound := false;
  Panel_Message.Hide; //Hide it now because it doesn't get hidden by SwitchPage
end;

{Build page}
procedure TKMGamePlayInterface.Create_Build_Page;
var i:integer;
begin
  Panel_Build:=MyControls.AddPanel(Panel_Main,0,412,196,400);
    Label_Build:=MyControls.AddLabel(Panel_Build,100,10,100,30,'',fnt_Outline,kaCenter);
    Image_Build_Selected:=MyControls.AddImage(Panel_Build,8,40,32,32,335);
    Image_Build_Selected.Center;
    Image_BuildCost_WoodPic:=MyControls.AddImage(Panel_Build,75,40,32,32,353);
    Image_BuildCost_WoodPic.Center;
    Image_BuildCost_StonePic:=MyControls.AddImage(Panel_Build,130,40,32,32,352);
    Image_BuildCost_StonePic.Center;
    Label_BuildCost_Wood:=MyControls.AddLabel(Panel_Build,105,50,10,30,'',fnt_Outline,kaLeft);
    Label_BuildCost_Stone:=MyControls.AddLabel(Panel_Build,160,50,10,30,'',fnt_Outline,kaLeft);
    Button_BuildRoad   := MyControls.AddButtonFlat(Panel_Build,  8,80,33,33,335);
    Button_BuildField  := MyControls.AddButtonFlat(Panel_Build, 45,80,33,33,337);
    Button_BuildWine   := MyControls.AddButtonFlat(Panel_Build, 82,80,33,33,336);
//    Button_BuildWall   := MyControls.AddButtonFlat(Panel_Build,119,80,33,33,339);
    Button_BuildCancel := MyControls.AddButtonFlat(Panel_Build,156,80,33,33,340);
    Button_BuildRoad.OnClick:=Build_ButtonClick;
    Button_BuildField.OnClick:=Build_ButtonClick;
    Button_BuildWine.OnClick:=Build_ButtonClick;
//    Button_BuildWall.OnClick:=Build_ButtonClick;
    Button_BuildCancel.OnClick:=Build_ButtonClick;
    Button_BuildRoad.Hint:=fTextLibrary.GetTextString(213);
    Button_BuildField.Hint:=fTextLibrary.GetTextString(215);
    Button_BuildWine.Hint:=fTextLibrary.GetTextString(219);
//    Button_BuildWall.Hint:='Build a wall';
    Button_BuildCancel.Hint:=fTextLibrary.GetTextString(211);

    for i:=1 to HOUSE_COUNT do
      if GUIHouseOrder[i] <> ht_None then begin
        Button_Build[i]:=MyControls.AddButtonFlat(Panel_Build, 8+((i-1) mod 5)*37,120+((i-1) div 5)*37,33,33,
        GUIBuildIcons[byte(GUIHouseOrder[i])]);

        Button_Build[i].OnClick:=Build_ButtonClick;
        Button_Build[i].Hint:=fTextLibrary.GetTextString(GUIBuildIcons[byte(GUIHouseOrder[i])]-300);
      end;
end;


{Ratios page}
procedure TKMGamePlayInterface.Create_Ratios_Page;
const ResPic:array[1..4] of TResourceType = (rt_Steel,rt_Coal,rt_Wood,rt_Corn);
      ResHint:array[1..4] of word = (297,299,301,303);
var i:integer;
begin
  Panel_Ratios:=MyControls.AddPanel(Panel_Main,0,412,200,400);

  for i:=1 to 4 do begin
    Button_Ratios[i]         := MyControls.AddButton(Panel_Ratios, 8+(i-1)*40,20,32,32,350+byte(ResPic[i]));
    Button_Ratios[i].Hint    := fTextLibrary.GetTextString(ResHint[i]);
    Button_Ratios[i].Tag     := i;
    Button_Ratios[i].OnClick := SwitchPageRatios;
  end;

  Image_RatioPic0 := MyControls.AddImage(Panel_Ratios,12,76,32,32,327);
  Label_RatioLab0 := MyControls.AddLabel(Panel_Ratios,44,72,100,30,'<<<LEER>>>',fnt_Outline,kaLeft);

  for i:=1 to 4 do begin
    Image_RatioPic[i]         :=MyControls.AddImage(Panel_Ratios,12,124+(i-1)*50,32,32,327);
    Label_RatioLab[i]         :=MyControls.AddLabel(Panel_Ratios,50,116+(i-1)*50,100,30,'<<<LEER>>>',fnt_Grey,kaLeft);
    Ratio_RatioRat[i]         :=MyControls.AddRatioRow(Panel_Ratios,48,136+(i-1)*50,140,20,0,5);
    Ratio_RatioRat[i].Tag     :=i;
    Ratio_RatioRat[i].OnChange:=RatiosChange;
  end;
  //todo: @Lewin: We shall hide or disable ratios for blocked houses, that would make sense, right?
end;


{Statistics page}
procedure TKMGamePlayInterface.Create_Stats_Page;
const LineHeight=34; Nil_Width=10; House_Width=30; Unit_Width=26;
var i,k:integer; hc,uc,off:integer;
  LineBase:integer;
begin
  Panel_Stats:=MyControls.AddPanel(Panel_Main,0,412,200,400);

  hc:=1; uc:=1;
  for i:=1 to 8 do begin
    LineBase := (i-1)*LineHeight;
    case i of //todo 1: This should be simplified, compacted and automated
    1: begin
          MyControls.AddBevel(Panel_Stats,  8,LineBase,56,30);
          MyControls.AddBevel(Panel_Stats, 71,LineBase,56,30);
          MyControls.AddBevel(Panel_Stats,134,LineBase,56,30);
       end;
    2: begin
          MyControls.AddBevel(Panel_Stats,  8,LineBase,86,30);
          MyControls.AddBevel(Panel_Stats,104,LineBase,86,30);
       end;
    3: begin
          MyControls.AddBevel(Panel_Stats,  8,LineBase,86,30);
          MyControls.AddBevel(Panel_Stats,104,LineBase,86,30);
       end;
    4: begin
          MyControls.AddBevel(Panel_Stats,  8,LineBase,86,30);
          MyControls.AddBevel(Panel_Stats,104,LineBase,86,30);
       end;
    5:    MyControls.AddBevel(Panel_Stats,8,LineBase,116,30);
    6:    MyControls.AddBevel(Panel_Stats,8,LineBase,146,30);
    7:    MyControls.AddBevel(Panel_Stats,8,LineBase,86,30);
    8: begin
          MyControls.AddBevel(Panel_Stats,  8,LineBase,120,30);
          MyControls.AddBevel(Panel_Stats,138,LineBase,52,30);
       end;
    end;

    off:=8;
    for k:=1 to 8 do
    case StatCount[i,k] of
      0: if i=1 then
           inc(off,Nil_Width-3) //Special fix to fit first row of 3x2 items
         else
           inc(off,Nil_Width);
      1: begin
        Stat_HousePic[hc]:=MyControls.AddImage(Panel_Stats,off,LineBase,House_Width,30,41{byte(StatHouse[hc])+300});
        Stat_HouseQty[hc]:=MyControls.AddLabel(Panel_Stats,off+House_Width-2,LineBase+16,37,30,'-',fnt_Grey,kaRight);
        Stat_HousePic[hc].Hint:=TypeToString(StatHouse[hc]);
        Stat_HouseQty[hc].Hint:=TypeToString(StatHouse[hc]);
        inc(hc);
        inc(off,House_Width);
         end;
      2: begin
        Stat_UnitPic[uc]:=MyControls.AddImage(Panel_Stats,off,LineBase,Unit_Width,30,byte(StatUnit[uc])+140);
        Stat_UnitQty[uc]:=MyControls.AddLabel(Panel_Stats,off+Unit_Width-2,LineBase+16,33,30,'-',fnt_Grey,kaRight);
        Stat_UnitPic[uc].Hint:=TypeToString(StatUnit[uc]);
        Stat_UnitQty[uc].Hint:=TypeToString(StatUnit[uc]);
        inc(uc);
        inc(off,Unit_Width);
         end;
    end;
  end;
end;


{Menu page}
procedure TKMGamePlayInterface.Create_Menu_Page;
begin
  Panel_Menu:=MyControls.AddPanel(Panel_Main,0,412,196,400);
    Button_Menu_Save:=MyControls.AddButton(Panel_Menu,8,20,180,30,fTextLibrary.GetTextString(175),fnt_Metal);
    Button_Menu_Save.OnClick:=Menu_ShowLoad;
    Button_Menu_Save.Hint:=fTextLibrary.GetTextString(175);
    Button_Menu_Load:=MyControls.AddButton(Panel_Menu,8,60,180,30,fTextLibrary.GetTextString(174),fnt_Metal);
    Button_Menu_Load.OnClick:=Menu_ShowLoad;
    Button_Menu_Load.Hint:=fTextLibrary.GetTextString(174);
    Button_Menu_Settings:=MyControls.AddButton(Panel_Menu,8,100,180,30,fTextLibrary.GetTextString(179),fnt_Metal);
    Button_Menu_Settings.OnClick:=Menu_ShowSettings;
    Button_Menu_Settings.Hint:=fTextLibrary.GetTextString(179);
    Button_Menu_Quit:=MyControls.AddButton(Panel_Menu,8,180,180,30,fTextLibrary.GetTextString(180),fnt_Metal);
    Button_Menu_Quit.Hint:=fTextLibrary.GetTextString(180);
    Button_Menu_Quit.OnClick:=SwitchPage;
    Button_Menu_TrackUp  :=MyControls.AddButton(Panel_Menu,158,320,30,30,'>',fnt_Metal);
    Button_Menu_TrackDown:=MyControls.AddButton(Panel_Menu,  8,320,30,30,'<',fnt_Metal);
    Button_Menu_TrackUp.Hint  :=fTextLibrary.GetTextString(209);
    Button_Menu_TrackDown.Hint:=fTextLibrary.GetTextString(208);
    Button_Menu_TrackUp.OnClick  :=Menu_NextTrack;
    Button_Menu_TrackDown.OnClick:=Menu_PreviousTrack;
    Label_Menu_Music:=MyControls.AddLabel(Panel_Menu,100,298,100,30,fTextLibrary.GetTextString(207),fnt_Metal,kaCenter);
    Label_Menu_Track:=MyControls.AddLabel(Panel_Menu,100,326,100,30,'Spirit',fnt_Grey,kaCenter);
end;


{Save page}
procedure TKMGamePlayInterface.Create_Save_Page;
var i:integer;
begin
  Panel_Save:=MyControls.AddPanel(Panel_Main,0,412,200,400);
    for i:=1 to SAVEGAME_COUNT do begin
      Button_Save[i]:=MyControls.AddButton(Panel_Save,12,10+(i-1)*28,170,24,'Savegame #'+inttostr(i),fnt_Grey);
      Button_Save[i].OnClick:=SaveGame;
      Button_Save[i].Tag:=i; //Simplify usage
    end;
end;


{Load page}
procedure TKMGamePlayInterface.Create_Load_Page;
var i:integer;
begin
  Panel_Load := MyControls.AddPanel(Panel_Main,0,412,200,400);
    for i:=1 to SAVEGAME_COUNT do begin
      Button_Load[i] := MyControls.AddButton(Panel_Load,12,10+(i-1)*28,170,24,'Savegame #'+inttostr(i),fnt_Grey);
      Button_Load[i].Tag := i;
      Button_Load[i].OnClick := Load_Click;
    end;
end;


{Options page}
procedure TKMGamePlayInterface.Create_Settings_Page;
var i:integer;
begin
  Panel_Settings:=MyControls.AddPanel(Panel_Main,0,412,200,400);
    MyControls.AddLabel(Panel_Settings,100,10,100,30,fTextLibrary.GetTextString(181),fnt_Metal,kaCenter);
    Button_Settings_Dark:=MyControls.AddButton(Panel_Settings,8,30,36,24,fTextLibrary.GetTextString(183),fnt_Metal);
    Button_Settings_Light:=MyControls.AddButton(Panel_Settings,154,30,36,24,fTextLibrary.GetTextString(182),fnt_Metal);
    Button_Settings_Dark.Hint:=fTextLibrary.GetTextString(185);
    Button_Settings_Light.Hint:=fTextLibrary.GetTextString(184);
    Label_Settings_BrightValue:=MyControls.AddLabel(Panel_Settings,100,34,100,30,'',fnt_Grey,kaCenter);
    CheckBox_Settings_Autosave:=MyControls.AddCheckBox(Panel_Settings,8,70,100,30,fTextLibrary.GetTextString(203),fnt_Metal);
    CheckBox_Settings_FastScroll:=MyControls.AddCheckBox(Panel_Settings,8,95,100,30,fTextLibrary.GetTextString(204),fnt_Metal);
    Label_Settings_MouseSpeed:=MyControls.AddLabel(Panel_Settings,24,130,100,30,fTextLibrary.GetTextString(192),fnt_Metal,kaLeft);
    Label_Settings_MouseSpeed.Disable;
    Ratio_Settings_Mouse:=MyControls.AddRatioRow(Panel_Settings,18,150,160,20,fGame.fGameSettings.GetSlidersMin,fGame.fGameSettings.GetSlidersMax);
    Ratio_Settings_Mouse.Disable;
    Ratio_Settings_Mouse.Hint:=fTextLibrary.GetTextString(193);
    Label_Settings_SFX:=MyControls.AddLabel(Panel_Settings,24,178,100,30,fTextLibrary.GetTextString(194),fnt_Metal,kaLeft);
    Ratio_Settings_SFX:=MyControls.AddRatioRow(Panel_Settings,18,198,160,20,fGame.fGameSettings.GetSlidersMin,fGame.fGameSettings.GetSlidersMax);
    Ratio_Settings_SFX.Hint:=fTextLibrary.GetTextString(195);
    Label_Settings_Music:=MyControls.AddLabel(Panel_Settings,24,226,100,30,fTextLibrary.GetTextString(196),fnt_Metal,kaLeft);
    Ratio_Settings_Music:=MyControls.AddRatioRow(Panel_Settings,18,246,160,20,fGame.fGameSettings.GetSlidersMin,fGame.fGameSettings.GetSlidersMax);
    Ratio_Settings_Music.Hint:=fTextLibrary.GetTextString(195);
    Label_Settings_Music2:=MyControls.AddLabel(Panel_Settings,100,280,100,30,fTextLibrary.GetTextString(197),fnt_Metal,kaCenter);
    Button_Settings_Music:=MyControls.AddButton(Panel_Settings,8,300,180,30,'',fnt_Metal);
    Button_Settings_Music.Hint:=fTextLibrary.GetTextString(198);
    //There are many clickable controls, so let them all be handled in one procedure to save dozens of lines of code
    for i:=1 to Panel_Settings.ChildCount do
    begin
      TKMControl(Panel_Settings.Childs[i]).OnClick:=Menu_Settings_Change;
      TKMControl(Panel_Settings.Childs[i]).OnChange:=Menu_Settings_Change;
    end;
end;


{Quit page}
procedure TKMGamePlayInterface.Create_Quit_Page;
begin
  Panel_Quit:=MyControls.AddPanel(Panel_Main,0,412,200,400);
    MyControls.AddLabel(Panel_Quit,100,30,100,30,fTextLibrary.GetTextString(176),fnt_Outline,kaCenter);
    Button_Quit_Yes:=MyControls.AddButton(Panel_Quit,8,100,180,30,fTextLibrary.GetTextString(177),fnt_Metal);
    Button_Quit_No:=MyControls.AddButton(Panel_Quit,8,140,180,30,fTextLibrary.GetTextString(178),fnt_Metal);
    Button_Quit_Yes.Hint:=fTextLibrary.GetTextString(177);
    Button_Quit_No.Hint:=fTextLibrary.GetTextString(178);
    Button_Quit_Yes.OnClick:=Menu_QuitMission;
    Button_Quit_No.OnClick:=SwitchPage;
end;


{Unit page}
procedure TKMGamePlayInterface.Create_Unit_Page;
begin
  Panel_Unit:=MyControls.AddPanel(Panel_Main,0,412,200,400);
    Label_UnitName:=MyControls.AddLabel(Panel_Unit,100,16,100,30,'',fnt_Outline,kaCenter);
    Image_UnitPic:=MyControls.AddImage(Panel_Unit,8,38,54,100,521);
    Label_UnitCondition:=MyControls.AddLabel(Panel_Unit,120,40,100,30,fTextLibrary.GetTextString(254),fnt_Grey,kaCenter);
    ConditionBar_Unit:=MyControls.AddPercentBar(Panel_Unit,73,55,116,15,80);
    Label_UnitTask:=MyControls.AddLabel(Panel_Unit,73,74,130,30,'',fnt_Grey,kaLeft);
    Label_UnitAct:=MyControls.AddLabel(Panel_Unit,73,94,130,30,'',fnt_Grey,kaLeft);
    Label_UnitAct.AutoWrap:=true;
    Button_Die:=MyControls.AddButton(Panel_Unit,73,112,54,20,'Die',fnt_Grey);
    Button_Die.OnClick:=Unit_Die;
    Label_UnitDescription:=MyControls.AddLabel(Panel_Unit,8,152,236,200,'',fnt_Grey,kaLeft); //Taken from LIB resource
    //Military buttons start at 8.170 and are 52x38/30 (60x46)
end;


{House description page}
procedure TKMGamePlayInterface.Create_House_Page;
var i:integer;
begin
  Panel_House:=MyControls.AddPanel(Panel_Main,0,412,200,400);
    //Thats common things
    //Custom things come in fixed size blocks (more smaller Panels?), and to be shown upon need
    Label_House:=MyControls.AddLabel(Panel_House,100,14,100,30,'',fnt_Outline,kaCenter);
    Button_House_Goods:=MyControls.AddButton(Panel_House,9,42,30,30,37);
    Button_House_Goods.OnClick := House_WareDeliveryToggle;
    Button_House_Goods.Hint := fTextLibrary.GetTextString(249);
    Button_House_Repair:=MyControls.AddButton(Panel_House,39,42,30,30,40);
    Button_House_Repair.OnClick := House_RepairToggle;
    Button_House_Repair.Hint := fTextLibrary.GetTextString(250);
    Image_House_Logo:=MyControls.AddImage(Panel_House,68,41,32,32,338);
    Image_House_Worker:=MyControls.AddImage(Panel_House,98,41,32,32,141);
    Label_HouseHealth:=MyControls.AddLabel(Panel_House,156,45,30,50,fTextLibrary.GetTextString(228),fnt_Mini,kaCenter,$FFFFFFFF);
    HealthBar_House:=MyControls.AddPercentBar(Panel_House,129,57,55,15,50,'',fnt_Mini);
    Label_House_UnderConstruction:=MyControls.AddLabel(Panel_House,100,170,100,30,fTextLibrary.GetTextString(230),fnt_Grey,kaCenter);

    Label_House_Demolish:=MyControls.AddLabel(Panel_House,100,130,100,30,fTextLibrary.GetTextString(232),fnt_Grey,kaCenter);
    Button_House_DemolishYes:=MyControls.AddButton(Panel_House,8,185,180,30,fTextLibrary.GetTextString(231),fnt_Metal);
    Button_House_DemolishNo :=MyControls.AddButton(Panel_House,8,220,180,30,fTextLibrary.GetTextString(224),fnt_Metal);
    Button_House_DemolishYes.Hint:=fTextLibrary.GetTextString(233);
    Button_House_DemolishNo.Hint:= fTextLibrary.GetTextString(224);
    Button_House_DemolishYes.OnClick:=House_Demolish;
    Button_House_DemolishNo.OnClick:= House_Demolish;

    Panel_House_Common:=MyControls.AddPanel(Panel_House,0,76,200,400);
      Label_Common_Demand:=MyControls.AddLabel(Panel_House_Common,100,2,100,30,fTextLibrary.GetTextString(227),fnt_Grey,kaCenter);
      Label_Common_Offer:=MyControls.AddLabel(Panel_House_Common,100,2,100,30,'',fnt_Grey,kaCenter);
      Label_Common_Costs:=MyControls.AddLabel(Panel_House_Common,100,2,100,30,fTextLibrary.GetTextString(248),fnt_Grey,kaCenter);
      Row__Common_Resource[1] :=MyControls.AddResourceRow(Panel_House_Common,  8,22,180,20,rt_Trunk,5);
      Row__Common_Resource[2] :=MyControls.AddResourceRow(Panel_House_Common,  8,42,180,20,rt_Stone,5);
      Row__Common_Resource[3] :=MyControls.AddResourceRow(Panel_House_Common,  8,62,180,20,rt_Trunk,5);
      Row__Common_Resource[4] :=MyControls.AddResourceRow(Panel_House_Common,  8,82,180,20,rt_Stone,5);
      for i:=1 to 4 do begin
        Row__Order[i] :=MyControls.AddResourceOrderRow(Panel_House_Common,  8,22,180,20,rt_Trunk,5);
        Row__Order[i].OrderRem.OnClick:=House_OrderClick;
        Row__Order[i].OrderRem.OnRightClick:=House_OrderClickRight;
        Row__Order[i].OrderRem.Hint:=fTextLibrary.GetTextString(234);
        Row__Order[i].OrderAdd.OnClick:=House_OrderClick;
        Row__Order[i].OrderAdd.OnRightClick:=House_OrderClickRight;
        Row__Order[i].OrderAdd.Hint:=fTextLibrary.GetTextString(235);
      end;
      Row__Costs[1] :=MyControls.AddCostsRow(Panel_House_Common,  8,22,180,20, 1);
      Row__Costs[2] :=MyControls.AddCostsRow(Panel_House_Common,  8,22,180,20, 1);
      Row__Costs[3] :=MyControls.AddCostsRow(Panel_House_Common,  8,22,180,20, 1);
      Row__Costs[4] :=MyControls.AddCostsRow(Panel_House_Common,  8,22,180,20, 1);
end;

{Store page}
procedure TKMGamePlayInterface.Create_Store_Page;
var i:integer;
begin
    Panel_HouseStore:=MyControls.AddPanel(Panel_House,0,76,200,400);
      for i:=1 to 28 do begin
        Button_Store[i]:=MyControls.AddButtonFlat(Panel_HouseStore, 8+((i-1)mod 5)*36,19+((i-1)div 5)*42,32,36,350+i);
        Button_Store[i].OnClick:=House_StoreAcceptFlag;
        Button_Store[i].Tag:=i;
        Button_Store[i].Hint:=TypeToString(TResourceType(i));
        Image_Store_Accept[i]:=MyControls.AddImage(Panel_HouseStore, 8+((i-1)mod 5)*36+9,18+((i-1)div 5)*42-11,32,36,49);
        Image_Store_Accept[i].Center;
        Image_Store_Accept[i].FOnClick:=House_StoreAcceptFlag;
        Image_Store_Accept[i].Hint:=TypeToString(TResourceType(i));
      end;
end;


{School page}
procedure TKMGamePlayInterface.Create_School_Page;
var i:integer;
begin
    Panel_House_School:=MyControls.AddPanel(Panel_House,0,76,200,400);
      Label_School_Res:=MyControls.AddLabel(Panel_House_School,100,2,100,30,fTextLibrary.GetTextString(227),fnt_Grey,kaCenter);
      ResRow_School_Resource :=MyControls.AddResourceRow(Panel_House_School,  8,22,180,20,rt_Gold,5);
      ResRow_School_Resource.Hint :=TypeToString(rt_Gold);
      Button_School_UnitWIP :=MyControls.AddButton(Panel_House_School,  8,48,32,32,0);
      Button_School_UnitWIP.Hint:=fTextLibrary.GetTextString(225);
      Button_School_UnitWIPBar:=MyControls.AddPercentBar(Panel_House_School,42,54,138,20,0);
      Button_School_UnitWIP.OnClick:= House_SchoolUnitRemove;
      for i:=1 to 5 do begin
        Button_School_UnitPlan[i]:= MyControls.AddButtonFlat(Panel_House_School, 8+(i-1)*36,80,32,32,0);
        Button_School_UnitPlan[i].OnClick:= House_SchoolUnitRemove;
      end;
      Label_School_Unit:=MyControls.AddLabel(Panel_House_School,100,116,100,30,'',fnt_Outline,kaCenter);
      Image_School_Left :=MyControls.AddImage(Panel_House_School,  8,136,54,80,521);
      Image_School_Left.Enabled := false;
      Image_School_Train:=MyControls.AddImage(Panel_House_School, 70,136,54,80,522);
      Image_School_Right:=MyControls.AddImage(Panel_House_School,132,136,54,80,523);
      Image_School_Right.Enabled := false;
      Button_School_Left :=MyControls.AddButton(Panel_House_School,  8,226,54,40,35);
      Button_School_Train:=MyControls.AddButton(Panel_House_School, 70,226,54,40,42);
      Button_School_Right:=MyControls.AddButton(Panel_House_School,132,226,54,40,36);
      Button_School_Left.OnClick:=House_SchoolUnitChange;
      Button_School_Train.OnClick:=House_SchoolUnitChange;
      Button_School_Right.OnClick:=House_SchoolUnitChange;
      Button_School_Left.OnRightClick:=House_SchoolUnitChangeRight;
      Button_School_Right.OnRightClick:=House_SchoolUnitChangeRight;
      Button_School_Left.Hint :=fTextLibrary.GetTextString(242);
      Button_School_Train.Hint:=fTextLibrary.GetTextString(243);
      Button_School_Right.Hint:=fTextLibrary.GetTextString(241);
end;


{Barracks page}
procedure TKMGamePlayInterface.Create_Barracks_Page;
var i:integer;
begin
    Panel_HouseBarracks:=MyControls.AddPanel(Panel_House,0,76,200,400);
      for i:=1 to 12 do
      begin
        Button_Barracks[i]:=MyControls.AddButtonFlat(Panel_HouseBarracks, 8+((i-1)mod 6)*31,8+((i-1)div 6)*42,28,38,366+i);
        Button_Barracks[i].TexOffsetX:=1;
        Button_Barracks[i].TexOffsetY:=1;
        Button_Barracks[i].CapOffsetY:=2;
        Button_Barracks[i].HideHighlight:=true;
        Button_Barracks[i].Hint:=TypeToString(TResourceType(16+i));
      end;
      Button_Barracks[12].TexID:=154;
      Button_Barracks[12].Hint:=TypeToString(ut_Recruit);

      Label_Barracks_Unit:=MyControls.AddLabel(Panel_HouseBarracks,100,96,100,30,'',fnt_Outline,kaCenter);

      Image_Barracks_Left :=MyControls.AddImage(Panel_HouseBarracks,  8,116,54,80,535);
      Image_Barracks_Left.Enabled := false;
      Image_Barracks_Train:=MyControls.AddImage(Panel_HouseBarracks, 70,116,54,80,536);
      Image_Barracks_Right:=MyControls.AddImage(Panel_HouseBarracks,132,116,54,80,537);
      Image_Barracks_Right.Enabled := false;

      Button_Barracks_Left :=MyControls.AddButton(Panel_HouseBarracks,  8,226,54,40,35);
      Button_Barracks_Train:=MyControls.AddButton(Panel_HouseBarracks, 70,226,54,40,42);
      Button_Barracks_Right:=MyControls.AddButton(Panel_HouseBarracks,132,226,54,40,36);
      Button_Barracks_Left.OnClick:=House_BarracksUnitChange;
      Button_Barracks_Train.OnClick:=House_BarracksUnitChange;
      Button_Barracks_Right.OnClick:=House_BarracksUnitChange;
      Button_Barracks_Left.OnRightClick:=House_BarracksUnitChangeRight;
      Button_Barracks_Right.OnRightClick:=House_BarracksUnitChangeRight;
      Button_Barracks_Left.Hint :=fTextLibrary.GetTextString(237);
      Button_Barracks_Train.Hint:=fTextLibrary.GetTextString(240);
      Button_Barracks_Right.Hint:=fTextLibrary.GetTextString(238);
      Button_Barracks_Train.Disable; //Unimplemented yet
end;


{Should update any items changed by game (resource counts, hp, etc..)}
{If it ever gets a bottleneck then some static Controls may be excluded from update}
procedure TKMGamePlayInterface.UpdateState;
begin
  if ShownUnit<>nil then ShowUnitInfo(ShownUnit) else
  if ShownHouse<>nil then ShowHouseInfo(ShownHouse,AskDemolish);

  if ShownHint<>nil then DisplayHint(ShownHint,[],0,0);
  if ShownHint<>nil then
    if (Mouse.CursorPos.X>ToolBarWidth) and (TKMControl(ShownHint).Parent<>Panel_Message) then
      DisplayHint(nil,[],0,0); //Don't display hints if not over ToolBar (Message panel is an exception)

  Minimap_Update(nil);
  if Image_Clock.Visible then begin
    Image_Clock.TexID := ((Image_Clock.TexID-556)+1)mod 16 +556;
    Label_Clock.Caption := int2time(fGame.GetMissionTime); 
  end;

  if SHOW_POINTER_COUNT then
    Label_PointerCount.Caption := 'Pointers: U,H: '+IntToStr(MyPlayer.GetUnits.GetTotalPointers)+','+IntToStr(MyPlayer.GetHouses.GetTotalPointers);

  if Panel_Build.Visible then Build_Fill(nil);
  if Panel_Stats.Visible then Stats_Fill(nil);
  if Panel_Menu.Visible then Menu_Fill(nil);

  if SHOW_SPRITE_COUNT then
  Label_Stat.Caption:=
        inttostr(fPlayers.GetUnitCount)+' units'+#124+
        inttostr(fRender.Stat_Sprites)+'/'+inttostr(fRender.Stat_Sprites2)+' sprites/rendered'+#124+
        '';
end;


procedure TKMGamePlayInterface.DisplayMessage(Sender: TObject);
var i: integer;
begin
  if not TKMImage(Sender).Visible then exit; //Exit if the message is not active

  ShownMessage:=0;
  for i:=low(Image_Message) to high(Image_Message) do
    if Sender = Image_Message[i] then
      ShownMessage := i;

  if ShownMessage=0 then exit; //Exit if the sender cannot be found

  Label_MessageText.Caption := fMessageList.GetText(ShownMessage);
  Button_MessageGoTo.Enabled := fMessageList.GetPicID(ShownMessage)-400 in [92..93]; //Only show Go To for house and units
  Panel_Message.Show;
  fSoundLib.Play(sfx_MessageOpen); //Play parchment sound when they open the message
end;


procedure TKMGamePlayInterface.CloseMessage(Sender: TObject);
begin
  UpdateMessageStack;
  fSoundLib.Play(sfx_MessageClose);
  ShownMessage := 0;
  Panel_Message.Hide;
end;


procedure TKMGamePlayInterface.DeleteMessage(Sender: TObject);
begin
  fMessageList.RemoveEntry(ShownMessage);
  CloseMessage(Sender);
end;


procedure TKMGamePlayInterface.GoToMessage(Sender: TObject);
begin
  if (fMessageList.GetLoc(ShownMessage).X <> 0) and (fMessageList.GetLoc(ShownMessage).Y <> 0) then
    fViewport.SetCenter(fMessageList.GetLoc(ShownMessage).X,fMessageList.GetLoc(ShownMessage).Y);
end;


procedure TKMGamePlayInterface.Build_ButtonClick(Sender: TObject);
var i:integer;
begin
  if Sender=nil then begin CursorMode.Mode:=cm_None; exit; end;

  //Release all buttons
  for i:=1 to Panel_Build.ChildCount do
    if Panel_Build.Childs[i] is TKMButtonFlat then
      TKMButtonFlat(Panel_Build.Childs[i]).Down:=false;

  //Press the button
  TKMButtonFlat(Sender).Down:=true;

  //Reset cursor and see if it needs to be changed
  CursorMode.Mode:=cm_None;
  CursorMode.Param:=0;
  Label_BuildCost_Wood.Caption:='-';
  Label_BuildCost_Stone.Caption:='-';
  Label_Build.Caption := '';

  
  if Button_BuildCancel.Down then begin
    CursorMode.Mode:=cm_Erase;
    Image_Build_Selected.TexID := 340;
    Label_Build.Caption := fTextLibrary.GetTextString(210);
  end;
  if Button_BuildRoad.Down then begin
    CursorMode.Mode:=cm_Road;
    Image_Build_Selected.TexID := 335;
    Label_BuildCost_Stone.Caption:='1';
    Label_Build.Caption := fTextLibrary.GetTextString(212);
  end;
  if Button_BuildField.Down then begin
    CursorMode.Mode:=cm_Field;
    Image_Build_Selected.TexID := 337;
    Label_Build.Caption := fTextLibrary.GetTextString(214);
  end;
  if Button_BuildWine.Down then begin
    CursorMode.Mode:=cm_Wine;
    Image_Build_Selected.TexID := 336;
    Label_BuildCost_Wood.Caption:='1';
    Label_Build.Caption := fTextLibrary.GetTextString(218);
  end;
{  if Button_BuildWall.Down then begin
    CursorMode.Mode:=cm_Wall;
    Image_Build_Selected.TexID := 339;
    Label_BuildCost_Wood.Caption:='1';
    //Label_Build.Caption := fTextLibrary.GetTextString(218);
  end;}

  for i:=1 to HOUSE_COUNT do
  if GUIHouseOrder[i] <> ht_None then
  if Button_Build[i].Down then begin
     CursorMode.Mode:=cm_Houses;
     CursorMode.Param:=byte(GUIHouseOrder[i]);
     Image_Build_Selected.TexID := GUIBuildIcons[byte(GUIHouseOrder[i])]; //Now update the selected icon
     Label_BuildCost_Wood.Caption:=inttostr(HouseDAT[byte(GUIHouseOrder[i])].WoodCost);
     Label_BuildCost_Stone.Caption:=inttostr(HouseDAT[byte(GUIHouseOrder[i])].StoneCost);
     Label_Build.Caption := TypeToString(THouseType(byte(GUIHouseOrder[i])));
  end;
end;


procedure TKMGamePlayInterface.ShowHouseInfo(Sender:TKMHouse; aAskDemolish:boolean=false);
const LineAdv = 25; //Each new Line is placed ## pixels after previous
var i,RowRes,Base,Line:integer;
begin
  ShownUnit:=nil;
  ShownHouse:=Sender;
  AskDemolish:=aAskDemolish;

  if (not Assigned(Sender)) then begin //=nil produces wrong result when there's no object at all
    SwitchPage(nil);
    exit;
  end;

  {Common data}
  Label_House.Caption:=TypeToString(Sender.GetHouseType);
  Image_House_Logo.TexID:=300+byte(Sender.GetHouseType);
  Image_House_Worker.TexID:=140+HouseDAT[byte(Sender.GetHouseType)].OwnerType+1;
  Image_House_Worker.Hint := TypeToString(TUnitType(HouseDAT[byte(Sender.GetHouseType)].OwnerType+1));
  HealthBar_House.Caption:=inttostr(round(Sender.GetHealth))+'/'+inttostr(HouseDAT[byte(Sender.GetHouseType)].MaxHealth);
  HealthBar_House.Position:=round( Sender.GetHealth / HouseDAT[byte(Sender.GetHouseType)].MaxHealth * 100 );

  if AskDemolish then
  begin
    for i:=1 to Panel_House.ChildCount do
      Panel_House.Childs[i].Hide; //hide all
    Label_House_Demolish.Show;
    Button_House_DemolishYes.Show;
    Button_House_DemolishNo.Show;
    Label_House.Show;
    Image_House_Logo.Show;
    Image_House_Worker.Show;
    Image_House_Worker.Enable;
    HealthBar_House.Show;
    Label_HouseHealth.Show;
    SwitchPage(Panel_House);
    exit;
  end;

  if not Sender.IsComplete then
  begin
    for i:=1 to Panel_House.ChildCount do
      Panel_House.Childs[i].Hide; //hide all
    Label_House_UnderConstruction.Show;
    Label_House.Show;
    Image_House_Logo.Show;
    Image_House_Worker.Show;
    Image_House_Worker.Enable;
    HealthBar_House.Show;
    Label_HouseHealth.Show;
    SwitchPage(Panel_House);
    exit;
  end;


  for i:=1 to Panel_House.ChildCount do
    Panel_House.Childs[i].Show; //show all
  Image_House_Worker.Enabled := Sender.GetHasOwner;
  Image_House_Worker.Visible := TUnitType(HouseDAT[byte(Sender.GetHouseType)].OwnerType+1) <> ut_None;
  Button_House_Goods.Enabled := not (HouseInput[byte(Sender.GetHouseType)][1] in [rt_None,rt_All,rt_Warfare]);
  if Sender.BuildingRepair then Button_House_Repair.TexID:=39 else Button_House_Repair.TexID:=40;
  if Sender.WareDelivery then Button_House_Goods.TexID:=37 else Button_House_Goods.TexID:=38;
  Label_House_UnderConstruction.Hide;
  Label_House_Demolish.Hide;
  Button_House_DemolishYes.Hide;
  Button_House_DemolishNo.Hide;
  SwitchPage(Panel_House);

  case Sender.GetHouseType of
    ht_Store: begin
          Store_Fill(nil);
          SwitchPage(Panel_HouseStore);
        end;

    ht_School: begin
          ResRow_School_Resource.ResourceCount:=Sender.CheckResIn(rt_Gold);
          House_SchoolUnitChange(nil);
          SwitchPage(Panel_House_School);
        end;

    ht_Barracks: begin
          Image_House_Worker.Enabled := true; //In the barrack the recruit icon is always enabled
          House_BarracksUnitChange(nil);
          SwitchPage(Panel_HouseBarracks);
          end;
    ht_TownHall:;
  else begin

    //First thing - hide everything
    for i:=1 to Panel_House_Common.ChildCount do
      Panel_House_Common.Childs[i].Hide;

    //Now show only what we need
    RowRes:=1; Line:=0; Base:=Panel_House_Common.Top+2;
    //Show Demand
    if HouseInput[byte(Sender.GetHouseType),1] in [rt_Trunk..rt_Fish] then begin
      Label_Common_Demand.Show;
      Label_Common_Demand.Top:=Base+Line*LineAdv+6;
      inc(Line);
      for i:=1 to 4 do if HouseInput[byte(Sender.GetHouseType),i] in [rt_Trunk..rt_Fish] then begin
        Row__Common_Resource[RowRes].Resource:=HouseInput[byte(Sender.GetHouseType),i];
        Row__Common_Resource[RowRes].Hint:=TypeToString(HouseInput[byte(Sender.GetHouseType),i]);
        Row__Common_Resource[RowRes].ResourceCount:=Sender.CheckResIn(HouseInput[byte(Sender.GetHouseType),i]);
        Row__Common_Resource[RowRes].Show;
        Row__Common_Resource[RowRes].Top:=Base+Line*LineAdv;
        inc(Line);
        inc(RowRes);
      end;
    end;
    //Show Output
    if not HousePlaceOrders[byte(Sender.GetHouseType)] then
    if HouseOutput[byte(Sender.GetHouseType),1] in [rt_Trunk..rt_Fish] then begin
      Label_Common_Offer.Show;
      Label_Common_Offer.Caption:=fTextLibrary.GetTextString(229)+'(x'+inttostr(HouseDAT[byte(Sender.GetHouseType)].ResProductionX)+'):';
      Label_Common_Offer.Top:=Base+Line*LineAdv+6;
      inc(Line);
      for i:=1 to 4 do
      if HouseOutput[byte(Sender.GetHouseType),i] in [rt_Trunk..rt_Fish] then begin
        Row__Common_Resource[RowRes].Resource:=HouseOutput[byte(Sender.GetHouseType),i];
        Row__Common_Resource[RowRes].ResourceCount:=Sender.CheckResOut(HouseOutput[byte(Sender.GetHouseType),i]);
        Row__Common_Resource[RowRes].Show;
        Row__Common_Resource[RowRes].Top:=Base+Line*LineAdv;
        Row__Common_Resource[RowRes].Hint:=TypeToString(HouseOutput[byte(Sender.GetHouseType),i]);
        inc(Line);
        inc(RowRes);
      end;
    end;
    //Show Orders
    if HousePlaceOrders[byte(Sender.GetHouseType)] then begin
      Label_Common_Offer.Show;
      Label_Common_Offer.Caption:=fTextLibrary.GetTextString(229)+'(x'+inttostr(HouseDAT[byte(Sender.GetHouseType)].ResProductionX)+'):';
      Label_Common_Offer.Top:=Base+Line*LineAdv+6;
      inc(Line);
      for i:=1 to 4 do //Orders
      if HouseOutput[byte(Sender.GetHouseType),i] in [rt_Trunk..rt_Fish] then begin
        Row__Order[i].Resource:=HouseOutput[byte(Sender.GetHouseType),i];
        Row__Order[i].ResourceCount:=Sender.CheckResOut(HouseOutput[byte(Sender.GetHouseType),i]);
        Row__Order[i].OrderCount:=Sender.CheckResOrder(i);
        Row__Order[i].Show;
        Row__Order[i].OrderAdd.Show;
        Row__Order[i].OrderRem.Show;
        Row__Order[i].Hint:=TypeToString(HouseOutput[byte(Sender.GetHouseType),i]);
        Row__Order[i].Top:=Base+Line*LineAdv;
        inc(Line);
      end;
      Label_Common_Costs.Show;
      Label_Common_Costs.Top:=Base+Line*LineAdv+6;
      inc(Line);
      for i:=1 to 4 do //Costs
      if HouseOutput[byte(Sender.GetHouseType),i] in [rt_Trunk..rt_Fish] then begin
        Row__Costs[i].CostID:=byte(HouseOutput[byte(Sender.GetHouseType),i]);
        Row__Costs[i].Show;
        Row__Costs[i].Top:=Base+Line*LineAdv;
        inc(Line);
      end;

    end;
  SwitchPage(Panel_House_Common);
  end;
  end;
end;


procedure TKMGamePlayInterface.ShowUnitInfo(Sender:TKMUnit);
begin
  ShownUnit:=Sender;
  ShownHouse:=nil;
  if (not Assigned(Sender))or(not Sender.IsVisible)or((Sender<>nil)and(Sender.IsDead)) then begin
    SwitchPage(nil);
    ShownUnit:=nil; //Make sure it doesn't come back again, especially if it's dead!
    exit;
  end;
  SwitchPage(Panel_Unit);
  Label_UnitName.Caption:=TypeToString(Sender.GetUnitType);
  Image_UnitPic.TexID:=520+byte(Sender.GetUnitType);
  ConditionBar_Unit.Position:=EnsureRange(round(Sender.GetCondition / UNIT_MAX_CONDITION * 100),-10,110);
  if Sender.GetHome<>nil then
    Label_UnitTask.Caption:='Task: '+Sender.GetUnitTaskText
  else
    Label_UnitTask.Caption:='Task: '+Sender.GetUnitTaskText;
  Label_UnitAct.Caption:='Act: '+Sender.GetUnitActText;
  if Sender is TKMUnitWarrior then
  begin
    //Warrior specific
    Label_UnitDescription.Hide;
  end
  else
  begin
    //Citizen specific
    Label_UnitDescription.Caption := fTextLibrary.GetTextString(siUnitDescriptions+byte(Sender.GetUnitType));
    Label_UnitDescription.Show;
  end;
end;


procedure TKMGamePlayInterface.Unit_Die(Sender:TObject);
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMUnit) then exit;
  TKMUnit(fPlayers.Selected).KillUnit;
end;


procedure TKMGamePlayInterface.House_Demolish(Sender:TObject);
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouse) then exit;

  if Sender=Button_House_DemolishYes then begin
    MyPlayer.RemHouse(TKMHouse(fPlayers.Selected).GetPosition,false);
    ShowHouseInfo(nil, false); //Simpliest way to reset page and ShownHouse
  end else begin
    AskDemolish:=false;
    SwitchPage(Button_Main[1]); //Cancel and return to build menu
  end;
end;


procedure TKMGamePlayInterface.House_RepairToggle(Sender:TObject);
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouse) then exit;

  with TKMHouse(fPlayers.Selected) do begin
    BuildingRepair := not BuildingRepair;
    if BuildingRepair then Button_House_Repair.TexID:=39
                      else Button_House_Repair.TexID:=40;
    if BuildingRepair then EnableRepair
                      else DisableRepair;
  end;
end;


procedure TKMGamePlayInterface.House_WareDeliveryToggle(Sender:TObject);
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouse) then exit;

  with TKMHouse(fPlayers.Selected) do begin
    WareDelivery := not WareDelivery;
    if WareDelivery then Button_House_Goods.TexID:=37
                    else Button_House_Goods.TexID:=38;
    end;
end;


procedure TKMGamePlayInterface.House_OrderClick(Sender:TObject);
var i:integer;
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouse) then exit;

  for i:=1 to 4 do begin
    if Sender = Row__Order[i].OrderRem then TKMHouse(fPlayers.Selected).ResRemOrder(i);
    if Sender = Row__Order[i].OrderAdd then TKMHouse(fPlayers.Selected).ResAddOrder(i);
  end;
end;


procedure TKMGamePlayInterface.House_OrderClickRight(Sender:TObject);
var i:integer;
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouse) then exit;

  for i:=1 to 4 do begin
    if Sender = Row__Order[i].OrderRem then TKMHouse(fPlayers.Selected).ResRemOrder(i,10);
    if Sender = Row__Order[i].OrderAdd then TKMHouse(fPlayers.Selected).ResAddOrder(i,10);
  end;
end;


procedure TKMGamePlayInterface.House_BarracksUnitChange(Sender:TObject);
var i, k, Tmp: integer; Barracks:TKMHouseBarracks; CanEquip: boolean;
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouseBarracks) then exit;

  Barracks:=TKMHouseBarracks(fPlayers.Selected);
  if (Sender=Button_Barracks_Left)and(LastBarracksUnit > 1) then dec(LastBarracksUnit);
  if (Sender=Button_Barracks_Right)and(LastBarracksUnit < length(Barracks_Order)) then inc(LastBarracksUnit);

  if Sender=Button_Barracks_Train then //Equip unit
  begin
    //Barracks.Equip;
  end;

  CanEquip:=true;
  for i:=1 to 12 do begin
    if i in [1..11] then Tmp:=TKMHouseBarracks(fPlayers.Selected).ResourceCount[i]
                    else Tmp:=TKMHouseBarracks(fPlayers.Selected).RecruitsInside;
    if Tmp=0 then Button_Barracks[i].Caption:='-'
             else Button_Barracks[i].Caption:=inttostr(Tmp);
    //Set highlights
    Button_Barracks[i].Down:=false;
    for k:=1 to 4 do
      if i = TroopCost[TUnitType(14+LastBarracksUnit),k] then
      begin
        Button_Barracks[i].Down:=true;
        if Tmp=0 then CanEquip := false; //Can't equip if we don't have a required resource
      end;
  end;
  Button_Barracks[12].Down:=true; //Recruit is always enabled, all troops require one

  Button_Barracks_Train.Enabled := CanEquip and (Barracks.RecruitsInside > 0);
  Button_Barracks_Left.Enabled := LastBarracksUnit > 1;
  Button_Barracks_Right.Enabled := LastBarracksUnit < length(Barracks_Order);
  Image_Barracks_Left.Visible:= Button_Barracks_Left.Enabled;
  Image_Barracks_Right.Visible:= Button_Barracks_Right.Enabled;

  if Button_Barracks_Left.Enabled then
    Image_Barracks_Left.TexID:=520+byte(Barracks_Order[LastBarracksUnit-1]);

  Label_Barracks_Unit.Caption:=TypeToString(TUnitType(Barracks_Order[LastBarracksUnit]));
  Image_Barracks_Train.TexID:=520+byte(Barracks_Order[LastBarracksUnit]);

  if Button_Barracks_Right.Enabled then
    Image_Barracks_Right.TexID:=520+byte(Barracks_Order[LastBarracksUnit+1]);
end;


procedure TKMGamePlayInterface.House_BarracksUnitChangeRight(Sender:TObject);
begin
  if Sender=Button_Barracks_Left  then LastBarracksUnit := 1;
  if Sender=Button_Barracks_Right then LastBarracksUnit := Length(Barracks_Order);
  House_BarracksUnitChange(nil);
end;


{Process click on Left-Train-Right buttons of School}
procedure TKMGamePlayInterface.House_SchoolUnitChange(Sender:TObject);
var i:byte; School:TKMHouseSchool;
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouseSchool) then exit;
  School:=TKMHouseSchool(fPlayers.Selected);

  if (Sender=Button_School_Left)and(LastSchoolUnit > 1) then dec(LastSchoolUnit);
  if (Sender=Button_School_Right)and(LastSchoolUnit < length(School_Order)) then inc(LastSchoolUnit);

  if Sender=Button_School_Train then //Add unit to training queue
  begin
    School.AddUnitToQueue(TUnitType(School_Order[LastSchoolUnit]));
  end;

  if School.UnitQueue[1]<>ut_None then
    Button_School_UnitWIP.TexID :=140+byte(School.UnitQueue[1])
  else
    Button_School_UnitWIP.TexID :=41; //Question mark

  Button_School_UnitWIPBar.Position:=School.GetTrainingProgress;

  for i:=1 to 5 do
    if School.UnitQueue[i+1]<>ut_None then
    begin
      Button_School_UnitPlan[i].TexID:=140+byte(School.UnitQueue[i+1]);
      Button_School_UnitPlan[i].Hint:=TypeToString(School.UnitQueue[i+1]);
    end
    else
    begin
      Button_School_UnitPlan[i].TexID:=0;
      Button_School_UnitPlan[i].Hint:='';
    end;

  Button_School_Train.Enabled := School.UnitQueue[length(School.UnitQueue)]=ut_None;
  Button_School_Left.Enabled := LastSchoolUnit > 1;
  Button_School_Right.Enabled := LastSchoolUnit < length(School_Order);
  Image_School_Left.Visible:= Button_School_Left.Enabled;
  Image_School_Right.Visible:= Button_School_Right.Enabled;

  if Button_School_Left.Enabled then
    Image_School_Left.TexID:=520+byte(School_Order[LastSchoolUnit-1]);

  Label_School_Unit.Caption:=TypeToString(TUnitType(School_Order[LastSchoolUnit]));
  Image_School_Train.TexID:=520+byte(School_Order[LastSchoolUnit]);

  if Button_School_Right.Enabled then
    Image_School_Right.TexID:=520+byte(School_Order[LastSchoolUnit+1]);
end;


{Process right click on Left-Right buttons of School}
procedure TKMGamePlayInterface.House_SchoolUnitChangeRight(Sender:TObject);
begin
  if Sender=Button_School_Left then LastSchoolUnit := 1;
  if Sender=Button_School_Right then LastSchoolUnit := Length(School_Order);
  House_SchoolUnitChange(nil);
end;


{Process click on Remove-from-queue buttons of School}
procedure TKMGamePlayInterface.House_SchoolUnitRemove(Sender:TObject);
var i:integer;
begin
  if Sender = Button_School_UnitWIP then
    TKMHouseSchool(fPlayers.Selected).RemUnitFromQueue(1)
  else for i:=1 to 5 do
    if Sender = Button_School_UnitPlan[i] then
    begin
      TKMHouseSchool(fPlayers.Selected).RemUnitFromQueue(i+1);
      fSoundLib.Play(sfx_click); //This is done for all buttons now, see fGame.OnMouseDown
      //True, but these are not buttons, they are flat buttons. They still have to make the sound though. To be deleted
    end;
  House_SchoolUnitChange(nil);
end;


{That small red triangle blocking delivery of goods to Storehouse}
{Resource determined by Button.Tag property}
procedure TKMGamePlayInterface.House_StoreAcceptFlag(Sender:TObject);
begin
  if fPlayers.Selected = nil then exit;
  if not (fPlayers.Selected is TKMHouseStore) then exit;
  TKMHouseStore(fPlayers.Selected).ToggleAcceptFlag((Sender as TKMControl).Tag);
end;


procedure TKMGamePlayInterface.Menu_ShowSettings(Sender: TObject);
begin
  Menu_Settings_Change(nil); //Prepare eveything first
  SwitchPage(Sender); //Only then switch
end;


procedure TKMGamePlayInterface.Menu_Settings_Change(Sender:TObject);
begin
  if Sender = Button_Settings_Dark then fGame.fGameSettings.DecBrightness;
  if Sender = Button_Settings_Light then fGame.fGameSettings.IncBrightness;
  if Sender = CheckBox_Settings_Autosave then fGame.fGameSettings.IsAutosave:=not fGame.fGameSettings.IsAutosave;
  if Sender = CheckBox_Settings_FastScroll then fGame.fGameSettings.IsFastScroll:=not fGame.fGameSettings.IsFastScroll;
  if Sender = Ratio_Settings_Mouse then fGame.fGameSettings.SetMouseSpeed(Ratio_Settings_Mouse.Position);
  if Sender = Ratio_Settings_SFX then fGame.fGameSettings.SetSoundFXVolume(Ratio_Settings_SFX.Position);
  if Sender = Ratio_Settings_Music then fGame.fGameSettings.SetMusicVolume(Ratio_Settings_Music.Position);
  if Sender = Button_Settings_Music then fGame.fGameSettings.IsMusic:=not fGame.fGameSettings.IsMusic;
  
  Label_Settings_BrightValue.Caption:=fTextLibrary.GetTextString(185 + fGame.fGameSettings.GetBrightness);
  CheckBox_Settings_Autosave.Checked:=fGame.fGameSettings.IsAutosave;
  CheckBox_Settings_FastScroll.Checked:=fGame.fGameSettings.IsFastScroll;
  Ratio_Settings_Mouse.Position:=fGame.fGameSettings.GetMouseSpeed;
  Ratio_Settings_SFX.Position:=fGame.fGameSettings.GetSoundFXVolume;
  Ratio_Settings_Music.Position:=fGame.fGameSettings.GetMusicVolume;

  if fGame.fGameSettings.IsMusic then
    Button_Settings_Music.Caption:=fTextLibrary.GetTextString(201)
  else
    Button_Settings_Music.Caption:=fTextLibrary.GetTextString(199);
end;


{Show list of savegames and act depending on Sender (Save or Load)}
procedure TKMGamePlayInterface.Menu_ShowLoad(Sender: TObject);
//var i:integer;
begin
{for i:=1 to SAVEGAME_COUNT do
  if CheckSaveGameValidity(i) then begin
    Button_Save[i].Caption:=Savegame.Title+Savegame.Time;
    Button_Load[i].Caption:=Savegame.Title+Savegame.Time;
  end;}
  SwitchPage(Sender);
end;


{Quit the mission and return to main menu}
procedure TKMGamePlayInterface.Menu_QuitMission(Sender:TObject);
var i:integer;
begin
  Panel_Main.Hide;
  for i:=1 to Panel_Main.ChildCount do
    if Panel_Main.Childs[i] is TKMPanel then
      Panel_Main.Childs[i].Hide;

  fGame.StopGame(gr_Cancel);
end;


procedure TKMGamePlayInterface.Menu_NextTrack(Sender:TObject); begin fMusicLib.PlayNextTrack; end;
procedure TKMGamePlayInterface.Menu_PreviousTrack(Sender:TObject); begin fMusicLib.PlayPreviousTrack; end;


procedure TKMGamePlayInterface.Build_Fill(Sender:TObject);
var i:integer;
begin
  for i:=1 to HOUSE_COUNT do
  if GUIHouseOrder[i] <> ht_None then
  if MyPlayer.GetCanBuild(THouseType(byte(GUIHouseOrder[i]))) then begin
    Button_Build[i].Enable;
    Button_Build[i].TexID:=GUIBuildIcons[byte(GUIHouseOrder[i])];
    Button_Build[i].OnClick:=Build_ButtonClick;
    Button_Build[i].Hint:=TypeToString(THouseType(byte(GUIHouseOrder[i])));
  end else begin
    Button_Build[i].OnClick:=nil;
    Button_Build[i].TexID:=41;
    Button_Build[i].Hint:=fTextLibrary.GetTextString(251); //Building not available
  end;
end;


{Virtually press BuildRoad button when changing page to BuildingPage or after house plan is placed}
procedure TKMGamePlayInterface.Build_SelectRoad;
begin
  Build_ButtonClick(Button_BuildRoad);
end;


procedure TKMGamePlayInterface.Build_RightClickCancel;
begin
  //This function will be called if the user right clicks on the screen. We should close the build menu if it's open.
  if Panel_Build.Visible = true then
    SwitchPage(Button_Main[5]);
end;


procedure TKMGamePlayInterface.IssueMessage(MsgTyp:TKMMessageType; Text:string; Loc:TKMPoint);
begin
  fMessageList.AddEntry(MsgTyp,Text,Loc);
  UpdateMessageStack;
  if fMessageList.GetPicID(fMessageList.Count)-400 in [91..93,95] then
    fSoundLib.Play(sfx_MessageNotice,4); //Play horn sound on new message if it is the right type
end;


procedure TKMGamePlayInterface.UpdateMessageStack;
var i:integer;
begin
  //MassageList is unlimited, while Image_Message has fixed depth and samples data from the list on demand
  for i:=low(Image_Message) to high(Image_Message) do
  begin
    Image_Message[i].TexID := fMessageList.GetPicID(i);
    Image_Message[i].Enabled := i in [1..fMessageList.Count]; //Disable and hide at once for safety
    Image_Message[i].Visible := i in [1..fMessageList.Count];
  end;
end;


procedure TKMGamePlayInterface.Store_Fill(Sender:TObject);
var i,Tmp:integer;
begin
  if fPlayers.Selected=nil then exit;
  if not (fPlayers.Selected is TKMHouseStore) then exit;

  for i:=1 to 28 do begin
    Tmp:=TKMHouseStore(fPlayers.Selected).ResourceCount[i];
    if Tmp=0 then Button_Store[i].Caption:='-' else
    //if Tmp>999 then Button_Store[i].Caption:=float2fix(round(Tmp/10)/100,2)+'k' else
                  Button_Store[i].Caption:=inttostr(Tmp);
    Image_Store_Accept[i].Visible := TKMHouseStore(fPlayers.Selected).NotAcceptFlag[i];
  end;
end;


procedure TKMGamePlayInterface.Menu_Fill(Sender:TObject);
begin
  if fGame.fGameSettings.IsMusic then
  begin
    Label_Menu_Track.Caption := fMusicLib.GetTrackTitle;
    Label_Menu_Track.Enabled := true;
    Button_Menu_TrackUp.Enabled := true;
    Button_Menu_TrackDown.Enabled := true;
  end
  else begin
    Label_Menu_Track.Caption := '-';
    Label_Menu_Track.Enabled := false;
    Button_Menu_TrackUp.Enabled := false;
    Button_Menu_TrackDown.Enabled := false;
  end;
end;

procedure TKMGamePlayInterface.Stats_Fill(Sender:TObject);
var i,Tmp:integer;
begin
  for i:=low(StatHouse) to high(StatHouse) do
  begin
    Tmp:=MyPlayer.GetHouseQty(StatHouse[i]);
    if Tmp=0 then Stat_HouseQty[i].Caption:='-' else Stat_HouseQty[i].Caption:=inttostr(Tmp);
    if MyPlayer.GetCanBuild(StatHouse[i]) or (Tmp>0) then
    begin
      Stat_HousePic[i].TexID:=byte(StatHouse[i])+300;
      Stat_HousePic[i].Hint:=TypeToString(StatHouse[i]);
      Stat_HouseQty[i].Hint:=TypeToString(StatHouse[i]);
    end
    else
    begin
      Stat_HousePic[i].TexID:=41;
      Stat_HousePic[i].Hint:=fTextLibrary.GetTextString(251); //Building not available
      Stat_HouseQty[i].Hint:=fTextLibrary.GetTextString(251); //Building not available
    end;
  end;
  for i:=low(StatUnit) to high(StatUnit) do
  begin
    Tmp:=MyPlayer.GetUnitQty(StatUnit[i]);
    if Tmp=0 then Stat_UnitQty[i].Caption:='-' else Stat_UnitQty[i].Caption:=inttostr(Tmp);
    Stat_UnitPic[i].Hint:=TypeToString(StatUnit[i]);
    Stat_UnitQty[i].Hint:=TypeToString(StatUnit[i]);
  end;
end;


procedure TKMGamePlayInterface.EnableOrDisableMenuIcons(NewValue:boolean);
begin
  Button_Main[1].Enabled := NewValue;
  Button_Main[2].Enabled := NewValue;
  Button_Main[3].Enabled := NewValue;
end;


procedure TKMGamePlayInterface.ShowClock(DoShow:boolean);
begin
  Image_Clock.Visible := DoShow;
  Label_Clock.Visible := DoShow;
end;


procedure TKMGamePlayInterface.ShowPause(DoShow:boolean);
begin
  Panel_Pause.Visible := DoShow;
end;


procedure TKMGamePlayInterface.ShortcutPress(Key:Word; IsDown:boolean=false);
begin
  //1-4 game menu shortcuts
  if Key in [49..52] then
  begin
    Button_Main[Key-48].Down := IsDown;
    if (not IsDown) and (not Button_Main[5].Visible) then SwitchPage(Button_Main[Key-48]);
  end;
  if Key=VK_ESCAPE then
  begin
    Button_Main[5].Down := IsDown;
    if (not IsDown) and (Button_Main[5].Visible) then SwitchPage(Button_Main[5]);
  end;
end;


procedure TKMGamePlayInterface.ClearShownUnit;
begin
  ShownUnit := nil;
  SwitchPage(nil);
end;


procedure TKMGamePlayInterface.Save(SaveStream:TKMemoryStream);
begin
  SaveStream.Write(ToolBarX);
  SaveStream.Write(LastSchoolUnit);
  SaveStream.Write(LastBarracksUnit);
  fMessageList.Save(SaveStream);
  //Everything else (e.g. ShownUnit or AskDemolish) can't be seen in Save_menu anyways
end;


procedure TKMGamePlayInterface.Load(LoadStream:TKMemoryStream);
begin
  LoadStream.Read(ToolBarX);
  LoadStream.Read(LastSchoolUnit);
  LoadStream.Read(LastBarracksUnit);
  fMessageList.Load(LoadStream);
  //Everything else (e.g. ShownUnit or AskDemolish) can't be seen in Save_menu anyways
  UpdateMessageStack;
  fLog.AppendLog('Interface loaded');
end;


procedure TKMGamePlayInterface.Paint;
begin
  MyControls.Paint;
end;


end.
