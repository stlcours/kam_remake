unit KM_GUIMenuResultsMP;
{$I KaM_Remake.inc}
interface
uses
  Controls, Math, StrUtils, SysUtils,
  KM_Controls, KM_Defaults, KM_Pics, KM_InterfaceDefaults;


type
  TKMGUIMenuResultsMP = class
  private
    fOnPageChange: TGUIEventText; //will be in ancestor class

    fGameResultMsg: TGameResultMsg; //So we know where to go after results screen
    fWaresVisible: array [WARE_MIN..WARE_MAX] of Boolean; //For MP results page

    procedure BackClick(Sender: TObject);
    procedure Create_ResultsMP(aParent: TKMPanel);
    procedure ResultsMP_Toggle(Sender: TObject);
    procedure ResultsMP_PlayerSelect(Sender: TObject);
    procedure Refresh;
  protected
    Panel_ResultsMP: TKMPanel;
      Button_MPResultsStats,
      Button_MPResultsArmy,
      Button_MPResultsEconomy,
      Button_MPResultsWares: TKMButtonFlat;
      Label_ResultsMP: TKMLabel;
      Panel_StatsMP1, Panel_StatsMP2: TKMPanel;
        Label_ResultsPlayerName1, Label_ResultsPlayerName2:array[0..MAX_PLAYERS-1] of TKMLabel;
        Bar_Results:array[0..MAX_PLAYERS-1, 0..9] of TKMPercentBar;
        Image_ResultsRosette:array[0..MAX_PLAYERS-1, 0..9] of TKMImage;
      Panel_GraphsMP: TKMPanel;
        Chart_MPArmy: TKMChart;
        Chart_MPCitizens: TKMChart;
        Chart_MPHouses: TKMChart;
        Chart_MPWares: array[0..MAX_PLAYERS-1] of TKMChart; //One for each player
        Image_MPResultsBackplate: TKMImage;
        Radio_MPResultsWarePlayer: TKMRadioGroup;
      Button_ResultsMPBack:TKMButton;
  public
    constructor Create(aParent: TKMPanel; aOnPageChange: TGUIEventText);
    destructor Destroy; override;

    procedure Show(aMsg: TGameResultMsg);
  end;


implementation
uses KM_Main,  KM_TextLibrary, KM_Game,  KM_PlayersCollection,
  KM_Utils, KM_Log,  KM_Resource,  KM_CommonTypes, KM_RenderUI;


{ TKMGUIMenuResultsMP }
constructor TKMGUIMenuResultsMP.Create(aParent: TKMPanel; aOnPageChange: TGUIEventText);
begin
  inherited Create;

  fOnPageChange := aOnPageChange;

  Create_ResultsMP(aParent);
end;


destructor TKMGUIMenuResultsMP.Destroy;
begin

  inherited;
end;


procedure TKMGUIMenuResultsMP.ResultsMP_Toggle(Sender: TObject);
var I: Integer;
begin
  Panel_StatsMP1.Visible := Sender = Button_MPResultsStats;
  Panel_StatsMP2.Visible := Sender = Button_MPResultsStats;

  Panel_GraphsMP.Visible   :=(Sender = Button_MPResultsArmy)
                          or (Sender = Button_MPResultsEconomy)
                          or (Sender = Button_MPResultsWares);
  Chart_MPArmy.Visible     := Sender = Button_MPResultsArmy;
  Chart_MPCitizens.Visible := Sender = Button_MPResultsEconomy;
  Chart_MPHouses.Visible   := Sender = Button_MPResultsEconomy;
  for I := 0 to MAX_PLAYERS - 1 do
    Chart_MPWares[I].Visible := (Sender = Button_MPResultsWares) and (Radio_MPResultsWarePlayer.ItemIndex = I);
  Radio_MPResultsWarePlayer.Visible := Sender = Button_MPResultsWares;
  Image_MPResultsBackplate.Visible  := Sender = Button_MPResultsWares;

  Button_MPResultsStats.Down := Sender = Button_MPResultsStats;
  Button_MPResultsArmy.Down := Sender = Button_MPResultsArmy;
  Button_MPResultsEconomy.Down := Sender = Button_MPResultsEconomy;
  Button_MPResultsWares.Down := Sender = Button_MPResultsWares;
end;


procedure TKMGUIMenuResultsMP.ResultsMP_PlayerSelect(Sender: TObject);
var ID, I, K: Integer;
begin
  ID := Radio_MPResultsWarePlayer.ItemIndex;
  Assert(ID in [0..MAX_PLAYERS-1]);

  for I:=0 to MAX_PLAYERS-1 do
    if Chart_MPWares[I].Visible then
    begin
      Chart_MPWares[I].Visible := False; //Hide the old one
      //Update the values of which lines are visible in our internal record
      for K := 0 to Chart_MPWares[I].LineCount-1 do
        fWaresVisible[TResourceType(Chart_MPWares[I].Lines[K].Tag)] := Chart_MPWares[I].Lines[K].Visible;
    end;

  Chart_MPWares[ID].Visible := True;
  //Show only the line that are visible in our internal record
  for K := 0 to Chart_MPWares[ID].LineCount-1 do
    Chart_MPWares[ID].SetLineVisible(K,fWaresVisible[TResourceType(Chart_MPWares[ID].Lines[K].Tag)]);
end;


procedure TKMGUIMenuResultsMP.Refresh;

  procedure SetPlayerControls(aPlayer: Integer; aEnabled: Boolean);
  var I: Integer;
  begin
    Label_ResultsPlayerName1[aPlayer].Visible := aEnabled;
    Label_ResultsPlayerName2[aPlayer].Visible := aEnabled;
    for I := 0 to 9 do
    begin
      Bar_Results[aPlayer,I].Visible := aEnabled;
      Image_ResultsRosette[aPlayer,I].Visible := aEnabled;
    end;
  end;

var
  I,K,Index, EnabledPlayerCount: Integer;
  UnitsMax, HousesMax, GoodsMax, WeaponsMax, MaxValue: Integer;
  Bests: array [0..9] of Cardinal;
  Totals: array [0..9] of Cardinal;
  R: TResourceType;
  G: TKMCardinalArray;
begin
  case fGameResultMsg of
    gr_Win:       Label_ResultsMP.Caption := fTextLibrary[TX_MENU_MISSION_VICTORY];
    gr_Defeat:    Label_ResultsMP.Caption := fTextLibrary[TX_MENU_MISSION_DEFEAT];
    gr_Cancel:    Label_ResultsMP.Caption := fTextLibrary[TX_MENU_MISSION_CANCELED];
    gr_ReplayEnd: Label_ResultsMP.Caption := fTextLibrary[TX_MENU_REPLAY_ENDED];
    else          Label_ResultsMP.Caption := NO_TEXT;
  end;
  //Append mission name and time after the result message
  Label_ResultsMP.Caption := Label_ResultsMP.Caption + ' - ' + fGame.GameName + ' - ' + TimeToString(fGame.MissionTime);

  //Update visibility depending on players count
  for I := 0 to MAX_PLAYERS - 1 do
    SetPlayerControls(I, False); //Disable them all to start
  Index := 0;
  for I := 0 to fPlayers.Count - 1 do
    if fPlayers[I].Enabled then
    begin
      SetPlayerControls(Index, True); //Enable used ones
      inc(Index);
    end;
  EnabledPlayerCount := Index; //Number of enabled players

  //Update positioning
  Panel_StatsMP1.Height := 40 + EnabledPlayerCount * 22;
  Panel_StatsMP2.Height := 40 + EnabledPlayerCount * 22;

  Panel_StatsMP1.Top := 144 + (520 - Panel_StatsMP1.Height * 2) div 2 -
                        (768 - Min(Panel_ResultsMP.Height,768)) div 2; //Manually apply anchoring
  //Second panel does not move from the middle of the screen: results always go above and below the middle

  //Calculate best scores
  FillChar(Bests, SizeOf(Bests), #0);
  //These are a special case: Less is better so we initialized them high
  Bests[1] := High(Cardinal);
  Bests[3] := High(Cardinal);
  Bests[6] := High(Cardinal);
  FillChar(Totals, SizeOf(Totals), #0);

  //Calculate bests for each "section"
  for I := 0 to fPlayers.Count - 1 do
    if fPlayers[I].Enabled then
      with fPlayers[I].Stats do
      begin
        if Bests[0] < GetCitizensTrained then Bests[0] := GetCitizensTrained;
        if Bests[1] > GetCitizensLost    then Bests[1] := GetCitizensLost;
        if Bests[2] < GetWarriorsTrained then Bests[2] := GetWarriorsTrained;
        if Bests[3] > GetWarriorsLost    then Bests[3] := GetWarriorsLost;
        if Bests[4] < GetWarriorsKilled  then Bests[4] := GetWarriorsKilled;
        if Bests[5] < GetHousesBuilt     then Bests[5] := GetHousesBuilt;
        if Bests[6] > GetHousesLost      then Bests[6] := GetHousesLost;
        if Bests[7] < GetHousesDestroyed then Bests[7] := GetHousesDestroyed;
        if Bests[8] < GetCivilProduced   then Bests[8] := GetCivilProduced;
        if Bests[9] < GetWeaponsProduced then Bests[9] := GetWeaponsProduced;

        //If Totals is 0 the category skipped and does not have "Best" icon on it
        Inc(Totals[0], GetCitizensTrained);
        Inc(Totals[1], GetCitizensLost);
        Inc(Totals[2], GetWarriorsTrained);
        Inc(Totals[3], GetWarriorsLost);
        Inc(Totals[4], GetWarriorsKilled);
        Inc(Totals[5], GetHousesBuilt);
        Inc(Totals[6], GetHousesLost);
        Inc(Totals[7], GetHousesDestroyed);
        Inc(Totals[8], GetCivilProduced);
        Inc(Totals[9], GetWeaponsProduced);
      end;

  //Fill in raw values
  Index := 0;
  for I := 0 to fPlayers.Count - 1 do
    if fPlayers[I].Enabled then
    begin
      Label_ResultsPlayerName1[Index].Caption   := fPlayers[I].PlayerName;
      Label_ResultsPlayerName1[Index].FontColor := FlagColorToTextColor(fPlayers[I].FlagColor);
      Label_ResultsPlayerName2[Index].Caption   := fPlayers[I].PlayerName;
      Label_ResultsPlayerName2[Index].FontColor := FlagColorToTextColor(fPlayers[I].FlagColor);

      with fPlayers[I].Stats do
      begin
        //Living things
        Bar_Results[Index,0].Tag := GetCitizensTrained;
        Bar_Results[Index,1].Tag := GetCitizensLost;
        Bar_Results[Index,2].Tag := GetWarriorsTrained;
        Bar_Results[Index,3].Tag := GetWarriorsLost;
        Bar_Results[Index,4].Tag := GetWarriorsKilled;
        Image_ResultsRosette[Index,0].Visible := (GetCitizensTrained >= Bests[0]) and (Totals[0] > 0);
        Image_ResultsRosette[Index,1].Visible := (GetCitizensLost    <= Bests[1]) and (Totals[1] > 0);
        Image_ResultsRosette[Index,2].Visible := (GetWarriorsTrained >= Bests[2]) and (Totals[2] > 0);
        Image_ResultsRosette[Index,3].Visible := (GetWarriorsLost    <= Bests[3]) and (Totals[3] > 0);
        Image_ResultsRosette[Index,4].Visible := (GetWarriorsKilled  >= Bests[4]) and (Totals[4] > 0);
        //Objects
        Bar_Results[Index,5].Tag := GetHousesBuilt;
        Bar_Results[Index,6].Tag := GetHousesLost;
        Bar_Results[Index,7].Tag := GetHousesDestroyed;
        Bar_Results[Index,8].Tag := GetCivilProduced;
        Bar_Results[Index,9].Tag := GetWeaponsProduced;
        Image_ResultsRosette[Index,5].Visible := (GetHousesBuilt     >= Bests[5]) and (Totals[5] > 0);
        Image_ResultsRosette[Index,6].Visible := (GetHousesLost      <= Bests[6]) and (Totals[6] > 0);
        Image_ResultsRosette[Index,7].Visible := (GetHousesDestroyed >= Bests[7]) and (Totals[7] > 0);
        Image_ResultsRosette[Index,8].Visible := (GetCivilProduced   >= Bests[8]) and (Totals[8] > 0);
        Image_ResultsRosette[Index,9].Visible := (GetWeaponsProduced >= Bests[9]) and (Totals[9] > 0);
      end;
      inc(Index);
    end;

  //Update percent bars for each category
  UnitsMax := 0;
  for K := 0 to 4 do for I := 0 to EnabledPlayerCount - 1 do
    UnitsMax := Max(Bar_Results[I,K].Tag, UnitsMax);

  HousesMax := 0;
  for K := 5 to 7 do for I := 0 to EnabledPlayerCount - 1 do
    HousesMax := Max(Bar_Results[I,K].Tag, HousesMax);

  GoodsMax := 0;
  for I := 0 to EnabledPlayerCount - 1 do
    GoodsMax := Max(Bar_Results[I,8].Tag, GoodsMax);

  WeaponsMax := 0;
  for I := 0 to EnabledPlayerCount - 1 do
    WeaponsMax := Max(Bar_Results[I,9].Tag, WeaponsMax);

  //Knowing Max in each category we may fill bars properly
  for K := 0 to 9 do
  begin
    case K of
      0..4: MaxValue := UnitsMax;
      5..7: MaxValue := HousesMax;
      8:    MaxValue := GoodsMax;
      else  MaxValue := WeaponsMax;
    end;
    for I := 0 to EnabledPlayerCount - 1 do
    begin
      if MaxValue <> 0 then
        Bar_Results[I,K].Position := Bar_Results[I,K].Tag / MaxValue
      else
        Bar_Results[I,K].Position := 0;
      Bar_Results[I,K].Caption := IfThen(Bar_Results[I,K].Tag <> 0, IntToStr(Bar_Results[I,K].Tag), '-');
    end;
  end;

  //Fill in chart values
  if DISPLAY_CHARTS_RESULT then
  begin
    Radio_MPResultsWarePlayer.Clear;
    for I := 0 to fPlayers.Count - 1 do
      if fPlayers[I].Enabled then
        Radio_MPResultsWarePlayer.Add('[$'+IntToHex(FlagColorToTextColor(fPlayers[I].FlagColor) and $00FFFFFF,6)+']'+fPlayers[I].PlayerName+'[]');

    Radio_MPResultsWarePlayer.ItemIndex := 0;
    Radio_MPResultsWarePlayer.Height := 25*EnabledPlayerCount;
    Image_MPResultsBackplate.Height := 24 + 25*EnabledPlayerCount;

    for R := WARE_MIN to WARE_MAX do
      fWaresVisible[R] := True; //All are visible by default

    Chart_MPArmy.Clear;
    Chart_MPCitizens.Clear;
    Chart_MPHouses.Clear;
    Chart_MPArmy.MaxLength      := MyPlayer.Stats.ChartCount;
    Chart_MPCitizens.MaxLength  := MyPlayer.Stats.ChartCount;
    Chart_MPHouses.MaxLength    := MyPlayer.Stats.ChartCount;

    Chart_MPArmy.MaxTime      := fGame.GameTickCount div 10;
    Chart_MPCitizens.MaxTime  := fGame.GameTickCount div 10;
    Chart_MPHouses.MaxTime    := fGame.GameTickCount div 10;

    for I := 0 to fPlayers.Count - 1 do
    with fPlayers[I] do
      if Enabled then
        Chart_MPArmy.AddLine(PlayerName, FlagColor, Stats.ChartArmy);

    Chart_MPArmy.TrimToFirstVariation;

    for I := 0 to fPlayers.Count - 1 do
    with fPlayers[I] do
    if Enabled then
      Chart_MPCitizens.AddLine(PlayerName, FlagColor, Stats.ChartCitizens);

    for I := 0 to fPlayers.Count - 1 do
    with fPlayers[I] do
      if Enabled then
        Chart_MPHouses.AddLine(PlayerName, FlagColor, Stats.ChartHouses);

    Index := 0;
    for I := 0 to fPlayers.Count - 1 do
    if fPlayers[I].Enabled then
    begin
      Chart_MPWares[Index].Clear;
      Chart_MPWares[Index].MaxLength := MyPlayer.Stats.ChartCount;
      Chart_MPWares[Index].MaxTime := fGame.GameTickCount div 10;
      Chart_MPWares[Index].Caption := fTextLibrary[TX_GRAPH_TITLE_RESOURCES]+' - [$'+IntToHex(FlagColorToTextColor(fPlayers[I].FlagColor) and $00FFFFFF,6)+']'+fPlayers[I].PlayerName+'[]';
      for R := WARE_MIN to WARE_MAX do
      begin
        G := fPlayers[I].Stats.ChartGoods[R];
        for K := 0 to High(G) do
          if G[K] <> 0 then
          begin
            Chart_MPWares[Index].AddLine(fResource.Resources[R].Title, ResourceColor[R] or $FF000000, G, Byte(R));
            Break;
          end;
      end;
      inc(Index);
    end;

    Button_MPResultsWares.Enabled := (fGame.MissionMode = mm_Normal);
    Button_MPResultsEconomy.Enabled := (fGame.MissionMode = mm_Normal);
    ResultsMP_Toggle(Button_MPResultsStats); //Statistics (not graphs) page shown by default every time
  end;
end;



procedure TKMGUIMenuResultsMP.Create_ResultsMP(aParent: TKMPanel);
const
  BarStep = 150;
  RowHeight = 22;
  BarWidth = BarStep - 10;
  BarHalf = BarWidth div 2;
  Columns1: array[0..4] of integer = (TX_RESULTS_MP_CITIZENS_TRAINED, TX_RESULTS_MP_CITIZENS_LOST,
                                     TX_RESULTS_MP_SOLDIERS_EQUIPPED, TX_RESULTS_MP_SOLDIERS_LOST,
                                     TX_RESULTS_MP_SOLDIERS_DEFEATED);
  Columns2: array[0..4] of integer = (TX_RESULTS_MP_BUILDINGS_CONSTRUCTED, TX_RESULTS_MP_BUILDINGS_LOST,
                                     TX_RESULTS_MP_BUILDINGS_DESTROYED,
                                     TX_RESULTS_MP_WARES_PRODUCED, TX_RESULTS_MP_WEAPONS_PRODUCED);
var i,k: Integer;
begin
  Panel_ResultsMP := TKMPanel.Create(aParent, 0, 0, aParent.Width, aParent.Height);
  Panel_ResultsMP.Stretch;
    with TKMImage.Create(Panel_ResultsMP,0,0,aParent.Width, aParent.Height,7,rxGuiMain) do
    begin
      ImageStretch;
      Center;
    end;
    with TKMShape.Create(Panel_ResultsMP,0,0,aParent.Width, aParent.Height) do
    begin
      Center;
      FillColor := $A0000000;
    end;

    Label_ResultsMP := TKMLabel.Create(Panel_ResultsMP,62,125,900,20,NO_TEXT,fnt_Metal,taCenter);
    Label_ResultsMP.Anchors := [akLeft];

    Button_MPResultsStats := TKMButtonFlat.Create(Panel_ResultsMP, 160, 155, 176, 20, 8, rxGuiMain);
    Button_MPResultsStats.TexOffsetX := -78;
    Button_MPResultsStats.TexOffsetY := 6;
    Button_MPResultsStats.Anchors := [akLeft];
    Button_MPResultsStats.Caption := fTextLibrary[TX_RESULTS_STATISTICS];
    Button_MPResultsStats.CapOffsetY := -11;
    Button_MPResultsStats.OnClick := ResultsMP_Toggle;

    Button_MPResultsArmy := TKMButtonFlat.Create(Panel_ResultsMP, 340, 155, 176, 20, 53, rxGui);
    Button_MPResultsArmy.TexOffsetX := -76;
    Button_MPResultsArmy.TexOffsetY := 6;
    Button_MPResultsArmy.Anchors := [akLeft];
    Button_MPResultsArmy.Caption := fTextLibrary[TX_GRAPH_ARMY];
    Button_MPResultsArmy.CapOffsetY := -11;
    Button_MPResultsArmy.OnClick := ResultsMP_Toggle;

    Button_MPResultsEconomy := TKMButtonFlat.Create(Panel_ResultsMP, 520, 155, 176, 20, 589, rxGui);
    Button_MPResultsEconomy.TexOffsetX := -72;
    Button_MPResultsEconomy.TexOffsetY := 6;
    Button_MPResultsEconomy.Anchors := [akLeft];
    Button_MPResultsEconomy.Caption := fTextLibrary[TX_RESULTS_ECONOMY];
    Button_MPResultsEconomy.CapOffsetY := -11;
    Button_MPResultsEconomy.OnClick := ResultsMP_Toggle;

    Button_MPResultsWares := TKMButtonFlat.Create(Panel_ResultsMP, 700, 155, 176, 20, 360, rxGui);
    Button_MPResultsWares.TexOffsetX := -77;
    Button_MPResultsWares.TexOffsetY := 6;
    Button_MPResultsWares.Anchors := [akLeft];
    Button_MPResultsWares.Caption := fTextLibrary[TX_GRAPH_RESOURCES];
    Button_MPResultsWares.CapOffsetY := -11;
    Button_MPResultsWares.OnClick := ResultsMP_Toggle;

    Panel_StatsMP1 := TKMPanel.Create(Panel_ResultsMP, 62, 240, 900, 180);
    Panel_StatsMP1.Anchors := [akLeft];

      for i:=0 to 7 do
        Label_ResultsPlayerName1[i] := TKMLabel.Create(Panel_StatsMP1, 0, 38+i*RowHeight, 150, 20, '', fnt_Metal, taLeft);

      for k:=0 to 4 do
      begin
        with TKMLabel.Create(Panel_StatsMP1, 160 + BarStep*k, 0, BarWidth+6, 40, fTextLibrary[Columns1[k]], fnt_Metal, taCenter) do
          AutoWrap := true;
        for i:=0 to 7 do
        begin
          Bar_Results[i,k] := TKMPercentBar.Create(Panel_StatsMP1, 160 + k*BarStep, 35+i*RowHeight, BarWidth, 20, fnt_Grey);
          Bar_Results[i,k].TextYOffset := -3;
          Image_ResultsRosette[i,k] := TKMImage.Create(Panel_StatsMP1, 164 + k*BarStep, 38+i*RowHeight, 16, 16, 8, rxGuiMain);
        end;
      end;

    Panel_StatsMP2 := TKMPanel.Create(Panel_ResultsMP, 62, 411, 900, 180);
    Panel_StatsMP2.Anchors := [akLeft];

      for i:=0 to 7 do
        Label_ResultsPlayerName2[i] := TKMLabel.Create(Panel_StatsMP2, 0, 38+i*RowHeight, 150, 20, '', fnt_Metal, taLeft);

      for k:=0 to 4 do
      begin
        with TKMLabel.Create(Panel_StatsMP2, 160 + BarStep*k, 0, BarWidth+6, 40, fTextLibrary[Columns2[k]], fnt_Metal, taCenter) do
          AutoWrap := true;
        for i:=0 to 7 do
        begin
          Bar_Results[i,k+5] := TKMPercentBar.Create(Panel_StatsMP2, 160 + k*BarStep, 35+i*RowHeight, BarWidth, 20, fnt_Grey);
          Bar_Results[i,k+5].TextYOffset := -3;
          Image_ResultsRosette[i,k+5] := TKMImage.Create(Panel_StatsMP2, 164 + k*BarStep, 38+i*RowHeight, 16, 16, 8, rxGuiMain);
        end;
      end;

    Panel_GraphsMP := TKMPanel.Create(Panel_ResultsMP, 0, 185, 1024, 560);
    Panel_GraphsMP.Anchors := [akLeft];

      Chart_MPArmy := TKMChart.Create(Panel_GraphsMP, 12, 0, 1000, 435);
      Chart_MPArmy.Caption := fTextLibrary[TX_GRAPH_ARMY];
      Chart_MPArmy.Anchors := [akLeft];

      Chart_MPCitizens := TKMChart.Create(Panel_GraphsMP, 62, 0, 900, 200);
      Chart_MPCitizens.Caption := fTextLibrary[TX_GRAPH_CITIZENS];
      Chart_MPCitizens.Anchors := [akLeft];

      Chart_MPHouses := TKMChart.Create(Panel_GraphsMP, 62, 235, 900, 200);
      Chart_MPHouses.Caption := fTextLibrary[TX_GRAPH_HOUSES];
      Chart_MPHouses.Anchors := [akLeft];

      Image_MPResultsBackplate := TKMImage.Create(Panel_GraphsMP, 12, 56, 178, 224, 3, rxGuiMain);
      Image_MPResultsBackplate.ImageStretch;
      Image_MPResultsBackplate.Center;

      Radio_MPResultsWarePlayer := TKMRadioGroup.Create(Panel_GraphsMP, 26, 70, 150, 200, fnt_Metal);
      Radio_MPResultsWarePlayer.Anchors := [akLeft];
      Radio_MPResultsWarePlayer.OnChange := ResultsMP_PlayerSelect;

      for I := 0 to MAX_PLAYERS - 1 do
      begin
        Chart_MPWares[I] := TKMChart.Create(Panel_GraphsMP, 190, 0, 822, 435);
        Chart_MPWares[I].Caption := fTextLibrary[TX_GRAPH_TITLE_RESOURCES];
        Chart_MPWares[I].Font := fnt_Metal; //fnt_Outline doesn't work because player names blend badly with yellow
        Chart_MPWares[I].Anchors := [akLeft];
      end;

    Button_ResultsMPBack := TKMButton.Create(Panel_ResultsMP,100,630,220,30,fTextLibrary[TX_MENU_BACK],bsMenu);
    Button_ResultsMPBack.Anchors := [akLeft];
    Button_ResultsMPBack.OnClick := BackClick;
end;


procedure TKMGUIMenuResultsMP.Show(aMsg: TGameResultMsg);
begin
  fGameResultMsg := aMsg;

  Refresh;
  Panel_ResultsMP.Show;
end;


procedure TKMGUIMenuResultsMP.BackClick(Sender: TObject);
begin
  //Depending on where we were created we need to return to different place
  //Multiplayer game end -> ResultsMP -> Multiplayer
  //Multiplayer replay end -> ResultsMP -> Replays

  if fGameResultMsg <> gr_ReplayEnd then
    fOnPageChange(Self, gpMultiplayer, '')
  else
    fOnPageChange(Self, gpReplays, '');
end;


end.
