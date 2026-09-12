Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$visuRoot = Join-Path $projectRoot 'Logical\Visu1'
$pagesRoot = Join-Path $visuRoot 'Pages'
$dataSourcePath = Join-Path $projectRoot 'Logical\VCShared\DataSources\DataSource.dso'
$initPagePath = Join-Path $pagesRoot 'Init_Page.page'
$packagePath = Join-Path $visuRoot 'Package.vcp'

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $encoding)
}

function Escape-Xml([string]$Value) {
    return [System.Security.SecurityElement]::Escape($Value)
}

function New-DataPoint([string]$Name, [string]$PlcType, [string]$VcType, [string]$Indent) {
    $scaled = if ($VcType -eq 'SCALED') {
        "`r`n$Indent  <Property Name=`"DPLimit`" Value=`"None`"/>" +
        "`r`n$Indent  <Property Name=`"PLCUnit`" Value=`"None`"/>" +
        "`r`n$Indent  <Property Name=`"UnitGroup`" Value=`"None`"/>"
    } else { '' }

    return @"
$Indent<DataPoint Name="$Name">
$Indent  <Property Name="ConnectedBySharedResource" Value="False"/>
$Indent  <Property Name="ConnectingVisus" Value="Visu1"/>$scaled
$Indent  <Property Name="Description" Value=""/>
$Indent  <Property Name="PLCType" Value="$PlcType"/>
$Indent  <Property Name="UpdateTime" Value="Default"/>
$Indent  <Property Name="UserID" Value="None"/>
$Indent  <Property Name="VCType" Value="$VcType"/>
$Indent</DataPoint>
"@
}

function New-AirReleaseFolder([string]$Name, [string]$Indent) {
    $result = "$Indent<Folder Name=`"$Name`">`r`n$Indent  <Property Name=`"Description`" Value=`"`"/>`r`n$Indent  <Property Name=`"FolderType`" Value=`"Struct`"/>`r`n"
    $result += New-DataPoint 'NumberOfLS' 'USINT' 'INTEGER' ($Indent + '  ')
    $result += New-DataPoint 'PressureSP_bar' 'REAL' 'SCALED' ($Indent + '  ')
    $result += New-DataPoint 'PressureHysteresis_bar' 'REAL' 'SCALED' ($Indent + '  ')
    foreach ($stage in 'LS1', 'LS2', 'LS3') {
        $result += "$Indent  <Folder Name=`"$stage`">`r`n$Indent    <Property Name=`"Description`" Value=`"`"/>`r`n$Indent    <Property Name=`"FolderType`" Value=`"Struct`"/>`r`n"
        $result += New-DataPoint 'SP_Percent' 'REAL' 'SCALED' ($Indent + '    ')
        $result += New-DataPoint 'Ramp_PercentPerSecond' 'REAL' 'SCALED' ($Indent + '    ')
        $result += New-DataPoint 'ConfirmTime_s' 'REAL' 'SCALED' ($Indent + '    ')
        $result += "$Indent  </Folder>`r`n"
    }
    $result += "$Indent</Folder>`r`n"
    return $result
}

function New-TextControl([string]$Name, [int]$TextId, [int]$Left, [int]$Top, [int]$Width, [int]$Height = 30) {
    return @"
        <Control ClassId="0x00001004" Name="$Name">
                    <Property Name="AlignmentHorizontal" Value="Left"/>
                    <Property Name="AlignmentVertical" Value="Center"/>
          <Property Name="ControlID" Value="0"/>
          <Property Name="Description" Value=""/>
          <Property Name="Font" Value="Source[local].Font[Arial12px]"/>
          <Property Name="Height" Value="$Height"/>
          <Property Name="Left" Value="$Left"/>
                    <Property Name="SimulationIndex" Value="0"/>
                    <Property Name="SimulationValue" Value=""/>
          <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[Text]"/>
          <Property Name="TextGroup" Value="Source[embedded].TextGroup"/>
                    <Property Name="TextIndexOffset" Value="$TextId"/>
          <Property Name="TextSource" Value="SingleText"/>
          <Property Name="Top" Value="$Top"/>
          <Property Name="Width" Value="$Width"/>
        </Control>
"@
}

function New-NumericControl([string]$Name, [string]$DataPoint, [int]$Left, [int]$Top, [double]$Min, [double]$Max, [int]$FractionDigits) {
    return @"
        <Control ClassId="0x00001007" Name="$Name">
          <Property Name="AddFractionDigits" Value="$FractionDigits"/>
          <Property Name="AlignmentHorizontal" Value="Center"/>
          <Property Name="ControlID" Value="0"/>
          <Property Name="Description" Value=""/>
          <Property Name="Font" Value="Source[local].Font[Arial12px]"/>
          <Property Name="Height" Value="30"/>
          <Property Name="Input" Value="True"/>
          <Property Name="InputStart" Value="Any Key"/>
          <Property Name="InputTouchpad" Value="Source[local].TouchPad[NumPad]"/>
          <Property Name="InputUpDown" Value="Progressive"/>
          <Property Name="Left" Value="$Left"/>
          <Property Name="MaxDatapoint" Value="None"/>
          <Property Name="MaxValue" Value="$Max"/>
          <Property Name="MinDatapoint" Value="None"/>
          <Property Name="MinIntegerDigits" Value="1"/>
          <Property Name="MinValue" Value="$Min"/>
          <Property Name="SimulationValue" Value="0"/>
          <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[Output]"/>
          <Property Name="TeachDatapoint" Value="None"/>
          <Property Name="Top" Value="$Top"/>
          <Property Name="ValueDatapoint" Value="Source[global].Variable[$DataPoint]"/>
          <Property Name="ValueMode" Value="Standard"/>
          <Property Name="Width" Value="100"/>
        </Control>
"@
}

function New-NumericOutput([string]$Name, [string]$DataPoint, [int]$Left, [int]$Top, [int]$FractionDigits, [int]$Width = 110) {
        return @"
                <Control ClassId="0x00001007" Name="$Name">
                    <Property Name="AddFractionDigits" Value="$FractionDigits"/>
                    <Property Name="AlignmentHorizontal" Value="Center"/>
                    <Property Name="ControlID" Value="0"/>
                    <Property Name="Description" Value=""/>
                    <Property Name="Font" Value="Source[local].Font[Arial12px]"/>
                    <Property Name="Height" Value="30"/>
                    <Property Name="Left" Value="$Left"/>
                    <Property Name="MaxDatapoint" Value="None"/>
                    <Property Name="MaxValue" Value="100000"/>
                    <Property Name="MinDatapoint" Value="None"/>
                    <Property Name="MinIntegerDigits" Value="1"/>
                    <Property Name="MinValue" Value="-100000"/>
                    <Property Name="SimulationValue" Value="0"/>
                    <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[Output]"/>
                    <Property Name="TeachDatapoint" Value="None"/>
                    <Property Name="Top" Value="$Top"/>
                    <Property Name="ValueDatapoint" Value="Source[global].Variable[$DataPoint]"/>
                    <Property Name="ValueMode" Value="Standard"/>
                    <Property Name="Width" Value="$Width"/>
                </Control>
"@
}

function New-StringOutput([string]$Name, [string]$DataPoint, [int]$Left, [int]$Top, [int]$Width) {
        return @"
                <Control ClassId="0x0000100B" Name="$Name">
                    <Property Name="BackColor" Value="252"/>
                    <Property Name="ControlID" Value="0"/>
                    <Property Name="Description" Value=""/>
                    <Property Name="Font" Value="Source[local].Font[Arial12px]"/>
                    <Property Name="ForeColor" Value="0"/>
                    <Property Name="Height" Value="30"/>
                    <Property Name="Left" Value="$Left"/>
                    <Property Name="SimulationValue" Value=""/>
                    <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[Output]"/>
                    <Property Name="Top" Value="$Top"/>
                    <Property Name="ValueDatapoint" Value="Source[global].Variable[$DataPoint]"/>
                    <Property Name="Width" Value="$Width"/>
                </Control>
"@
}

function New-NavButton([string]$Name, [int]$TextId, [string]$VirtualKey, [int]$Left, [int]$Width = 190) {
    return @"
        <Control ClassId="0x00001002" Name="$Name">
          <Property Name="AlignmentHorizontal" Value="Center"/>
                    <Property Name="BitmapIndexDatapoint" Value="None"/>
                    <Property Name="BitmapSource" Value="None"/>
          <Property Name="ControlID" Value="0"/>
          <Property Name="Description" Value=""/>
          <Property Name="EmbVirtualKey" Value="Source[local].VirtualKey[$VirtualKey]"/>
          <Property Name="Font" Value="Source[local].Font[Arial10pxBold]"/>
          <Property Name="Height" Value="48"/>
                    <Property Name="KeyMatrixOffset" Value="None"/>
          <Property Name="Left" Value="$Left"/>
                    <Property Name="PressedBitmapSource" Value="Source[embedded].Property[BitmapSource]"/>
                    <Property Name="PressedTextSource" Value="Source[embedded].Property[TextSource]"/>
          <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[BasicButton]"/>
          <Property Name="TextGroup" Value="Source[embedded].TextGroup"/>
          <Property Name="TextIndex" Value="$TextId"/>
                    <Property Name="TextIndexDatapoint" Value="None"/>
                    <Property Name="TextSimulationValue" Value="0"/>
          <Property Name="TextSource" Value="SingleText"/>
          <Property Name="Top" Value="58"/>
          <Property Name="VirtualKey" Value="Source[local].VirtualKey[$VirtualKey]"/>
          <Property Name="Width" Value="$Width"/>
        </Control>
"@
}

function New-CommandButton([string]$Name, [int]$TextId, [string]$VirtualKey, [int]$Left, [int]$Top, [int]$Width) {
    $button = New-NavButton $Name $TextId $VirtualKey $Left $Width
    return $button.Replace('<Property Name="Top" Value="58"/>', "<Property Name=`"Top`" Value=`"$Top`"/>")
}

function New-PageKey([string]$VirtualKey, [string]$TargetPage) {
    return @"
        <VirtualKey Name="$VirtualKey">
          <Property Name="Description" Value=""/>
          <Property Name="VirtualKey_LED" Value="False"/>
          <KeyActions>
            <KeyAction ClassId="0x00000160">
              <Property Name="Description" Value=""/>
              <Property Name="Locking" Value="Never"/>
              <Property Name="Name" Value="Action_0"/>
              <Property Name="Page" Value="Source[local].Page[$TargetPage]"/>
              <Property Name="Target" Value="Page"/>
            </KeyAction>
          </KeyActions>
        </VirtualKey>
"@
}

function New-MomentaryKey([string]$VirtualKey, [string]$DataPoint) {
        return @"
                <VirtualKey Name="$VirtualKey">
                    <Property Name="Description" Value=""/>
                    <Property Name="VirtualKey_LED" Value="False"/>
                    <KeyActions>
                        <KeyAction ClassId="0x0000016B">
                            <Property Name="CompletionDatapoint" Value="None"/>
                            <Property Name="CompletionValue" Value="0"/>
                            <Property Name="Description" Value=""/>
                            <Property Name="Locking" Value="Never"/>
                            <Property Name="Name" Value="Action_0"/>
                            <Property Name="ResetValue" Value="0"/>
                            <Property Name="SetValue" Value="1"/>
                            <Property Name="ValueDatapoint" Value="Source[global].Variable[$DataPoint]"/>
                        </KeyAction>
                    </KeyActions>
                </VirtualKey>
"@
}

function New-SettingsPage([string]$Name, [string]$Title, [array]$Fields) {
    $texts = [System.Collections.Generic.List[string]]::new()
    $controls = [System.Collections.Generic.List[string]]::new()
    $keys = [System.Collections.Generic.List[string]]::new()
    $textId = 0

    $texts.Add("          <Text ID=`"$textId`" Value=`"$(Escape-Xml $Title)`"/>")
    $controls.Add((New-TextControl 'PageTitle' $textId 30 15 850 40))
    $textId++

    $nav = @(
        @{ Label = 'PROCES'; Page = 'Para_Settings'; Left = 20; Width = 150 },
        @{ Label = 'VREMENA'; Page = 'Para_Times'; Left = 180; Width = 150 },
        @{ Label = 'AIR RELEASE BRB2'; Page = 'Para_AR_BRB2'; Left = 340; Width = 200 },
        @{ Label = 'AIR RELEASE IEBKB1'; Page = 'Para_AR_IEB'; Left = 550; Width = 220 },
        @{ Label = 'KOMANDE'; Page = 'Main_Command'; Left = 900; Width = 170 },
        @{ Label = 'INIT'; Page = 'Init_Page'; Left = 1090; Width = 160 }
    )
    $navIndex = 0
    foreach ($item in $nav) {
        $texts.Add("          <Text ID=`"$textId`" Value=`"$($item.Label)`"/>")
        $virtualKey = "%nav_$navIndex"
        $width = if ($item.ContainsKey('Width')) { $item.Width } else { 185 }
        $controls.Add((New-NavButton "Nav_$navIndex" $textId $virtualKey $item.Left $width))
        $keys.Add((New-PageKey $virtualKey $item.Page))
        $textId++
        $navIndex++
    }

    $fieldIndex = 0
    foreach ($field in $Fields) {
        $column = [math]::Floor($fieldIndex / 12)
        $row = $fieldIndex % 12
        $left = 35 + ($column * 615)
        $top = 125 + ($row * 53)
        $texts.Add("          <Text ID=`"$textId`" Value=`"$(Escape-Xml $field.Label)`"/>")
        $controls.Add((New-TextControl "Label_$fieldIndex" $textId $left $top 430))
        $controls.Add((New-NumericControl "Value_$fieldIndex" $field.DataPoint ($left + 450) $top $field.Min $field.Max $field.Digits))
        $textId++
        $fieldIndex++
    }

    if ($Name -eq 'Para_Settings') {
        $texts.Add("          <Text ID=`"$textId`" Value=`"VRATI DEFAULT PARAMETRE`"/>")
        $controls.Add((New-CommandButton 'Btn_DefaultParameters' $textId '%cmd_defaults' 910 710 300))
        $keys.Add((New-MomentaryKey '%cmd_defaults' 'DataSource.Rad_PG_KB.CmdSetDefaultParameters'))
        $textId++
    }

    $textBlock = $texts -join "`r`n"
    $indexEntries = for ($index = 0; $index -lt $textId; $index++) {
        "          <Index ID=`"$index`" Value=`"$index`"/>"
    }
    $indexMapBlock = $indexEntries -join "`r`n"
    $controlBlock = $controls -join "`r`n"
    $keyBlock = $keys -join "`r`n"
    $pageIndex = switch ($Name) {
        'Para_Settings' { 40 }
        'Para_Times' { 41 }
        'Para_AR_BRB2' { 42 }
        'Para_AR_IEB' { 43 }
        default { throw "Unknown settings page: $Name" }
    }
    $page = @"
<?xml version="1.0" encoding="UTF-8"?>
<?AutomationStudio Version="4.12.3.127 SP"?>
<Page xmlns="http://br-automation.co.at/AS/VC/Project" Name="$Name">
  <Property Name="Description" Value="$Title"/>
  <Property Name="Height" Value="800"/>
    <Property Name="Index" Value="$pageIndex"/>
  <Property Name="MoveFocus" Value="Circular"/>
  <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[default]"/>
  <Property Name="Width" Value="1280"/>
  <Layers>
    <Layer Name="Default">
      <Property Name="BackColor" Value="9"/>
      <Property Name="Description" Value=""/>
      <Property Name="EditingMode" Value="Normal"/>
      <Property Name="Height" Value="800"/>
      <Property Name="Left" Value="0"/>
    <Property Name="OutlineColor" Value="0"/>
    <Property Name="OutlineDisplayControl" Value="False"/>
    <Property Name="OutlineDisplayName" Value="True"/>
    <Property Name="OutlineHatched" Value="False"/>
      <Property Name="StatusDatapoint" Value="None"/>
      <Property Name="Top" Value="0"/>
      <Property Name="VisibilityMode" Value="Normal"/>
      <Property Name="Width" Value="1280"/>
      <Property Name="Z-Order" Value="0"/>
      <TextGroup>
        <TextLayer LanguageId="en">
$textBlock
        </TextLayer>
        <TextLayer LanguageId="de">
$textBlock
        </TextLayer>
        <IndexMap>
    $indexMapBlock
        </IndexMap>
      </TextGroup>
      <Controls>
$controlBlock
      </Controls>
      <KeyMapping>
$keyBlock
      </KeyMapping>
    </Layer>
  </Layers>
  <MovementOrder/>
  <TabSequence/>
</Page>
"@
    Write-Utf8NoBom (Join-Path $pagesRoot "$Name.page") $page
}

function New-MainCommandPage {
    $texts = @(
        'GLAVNI KOMANDNI EKRAN', 'PARAMETRI', 'INIT',
        'START', 'STOP', 'RESET GRESKE',
        'OPERATIVNI IZBORI', 'Izvor: 0=Nijedan, 1=BRB2, 2=IEBKB1',
        'Regulacija: 0=Off, 1=Pritisak, 2=Nivo, 3=Temp',
        'Aktivna pumpa: 0=Nijedna, 1=Pu1, 2=Pu2',
        'Aktivni PV: 0=Nijedan, 1=PV01, 2=PV02', 'AutoRestart: 0=OFF, 1=ON',
        'ZADATE I STVARNE VREDNOSTI', 'Pritisak potisa SP [bar]', 'Pritisak potisa PV [bar]',
        'Nivo tanka SP [m]', 'Nivo tanka PV [m]', 'Protok PV [l/s]',
        'STATUS PROCESA', 'State', 'Substep', 'Fault', 'Fault code', 'Fault tekst',
        'STATUS UREDJAJA', 'Pumpa 1 FR [Hz]', 'Pumpa 1 greska', 'Pumpa 2 FR [Hz]', 'Pumpa 2 greska',
        'PV01 polozaj [%]', 'PV02 polozaj [%]', 'PV03 odzraka [%]', 'PV04 odzraka [%]', 'PV05 drenaza [%]'
    )
    $textLines = for ($index = 0; $index -lt $texts.Count; $index++) {
        "          <Text ID=`"$index`" Value=`"$(Escape-Xml $texts[$index])`"/>"
    }
    $indexLines = for ($index = 0; $index -lt $texts.Count; $index++) {
        "          <Index ID=`"$index`" Value=`"$index`"/>"
    }

    $controls = [System.Collections.Generic.List[string]]::new()
    $keys = [System.Collections.Generic.List[string]]::new()
    $controls.Add((New-TextControl 'PageTitle' 0 25 15 700 40))
    $controls.Add((New-NavButton 'Nav_Settings' 1 '%nav_settings' 900 170))
    $controls.Add((New-NavButton 'Nav_Init' 2 '%nav_init' 1090 160))
    $keys.Add((New-PageKey '%nav_settings' 'Para_Settings'))
    $keys.Add((New-PageKey '%nav_init' 'Init_Page'))

    $controls.Add((New-CommandButton 'Btn_Start' 3 '%cmd_start' 35 85 180))
    $controls.Add((New-CommandButton 'Btn_Stop' 4 '%cmd_stop' 235 85 180))
    $controls.Add((New-CommandButton 'Btn_Reset' 5 '%cmd_reset' 435 85 220))
    $keys.Add((New-MomentaryKey '%cmd_start' 'DataSource.Rad_PG_KB.KomandaStart'))
    $keys.Add((New-MomentaryKey '%cmd_stop' 'DataSource.Rad_PG_KB.KomandaStop'))
    $keys.Add((New-MomentaryKey '%cmd_reset' 'DataSource.Rad_PG_KB.KomandaReset'))

    $controls.Add((New-TextControl 'Head_Choices' 6 35 155 500 32))
    $choiceFields = @(
        @{ Text = 7; DP = 'DataSource.PGRad.Ctrl.SelektovaniIzvor'; Min = 0; Max = 2 },
        @{ Text = 8; DP = 'DataSource.PGRad.Ctrl.RegulacionaVarijanta'; Min = 0; Max = 3 },
        @{ Text = 9; DP = 'DataSource.PGRad.Ctrl.AktivnaPumpaIzlazTanka'; Min = 0; Max = 2 },
        @{ Text = 10; DP = 'DataSource.PGRad.Ctrl.AktivniPropVentilUlazTanka'; Min = 0; Max = 2 },
        @{ Text = 11; DP = 'DataSource.PGRad.Ctrl.AutoRestart'; Min = 0; Max = 1 }
    )
    for ($index = 0; $index -lt $choiceFields.Count; $index++) {
        $top = 200 + ($index * 48)
        $controls.Add((New-TextControl "ChoiceLabel_$index" $choiceFields[$index].Text 35 $top 410))
        $controls.Add((New-NumericControl "ChoiceValue_$index" $choiceFields[$index].DP 455 $top $choiceFields[$index].Min $choiceFields[$index].Max 0))
    }

    $controls.Add((New-TextControl 'Head_Process' 12 35 455 500 32))
    $processRows = @(
        @{ Text = 13; DP = 'DataSource.PGRad.Par.SetPritisakPotisa'; Input = $true; Digits = 2; Min = 0; Max = 10 },
        @{ Text = 14; DP = 'DataSource.PG.Sens.Pt._5.AI_Output.ScaledValue'; Digits = 2 },
        @{ Text = 15; DP = 'DataSource.PGRad.Par.SetPointNivoTanka'; Input = $true; Digits = 2; Min = 0; Max = 3 },
        @{ Text = 16; DP = 'DataSource.NivoPRihvatniSud'; Digits = 2 },
        @{ Text = 17; DP = 'DataSource.PG.Sens.MP._1.AI_Output.ScaledValue'; Digits = 2 }
    )
    for ($index = 0; $index -lt $processRows.Count; $index++) {
        $top = 500 + ($index * 45)
        $controls.Add((New-TextControl "ProcessLabel_$index" $processRows[$index].Text 35 $top 410))
        if ($processRows[$index].ContainsKey('Input') -and $processRows[$index].Input) {
            $controls.Add((New-NumericControl "ProcessValue_$index" $processRows[$index].DP 455 $top $processRows[$index].Min $processRows[$index].Max $processRows[$index].Digits))
        } else {
            $controls.Add((New-NumericOutput "ProcessValue_$index" $processRows[$index].DP 455 $top $processRows[$index].Digits))
        }
    }

    $controls.Add((New-TextControl 'Head_Status' 18 650 155 500 32))
    $statusRows = @(
        @{ Text = 19; DP = 'DataSource.Rad_PG_KB.State'; Digits = 0 },
        @{ Text = 20; DP = 'DataSource.Rad_PG_KB.Substep'; Digits = 0 },
        @{ Text = 21; DP = 'DataSource.Rad_PG_KB.FaultLatched'; Digits = 0 },
        @{ Text = 22; DP = 'DataSource.Rad_PG_KB.FaultCode'; Digits = 0 }
    )
    for ($index = 0; $index -lt $statusRows.Count; $index++) {
        $top = 200 + ($index * 45)
        $controls.Add((New-TextControl "StatusLabel_$index" $statusRows[$index].Text 650 $top 260))
        $controls.Add((New-NumericOutput "StatusValue_$index" $statusRows[$index].DP 920 $top $statusRows[$index].Digits))
    }
    $controls.Add((New-TextControl 'FaultTextLabel' 23 650 380 260))
    $controls.Add((New-StringOutput 'FaultTextValue' 'DataSource.Rad_PG_KB.FaultText' 650 415 580))

    $controls.Add((New-TextControl 'Head_Devices' 24 650 465 500 32))
    $deviceRows = @(
        @{ Text = 25; DP = 'DataSource.PG.Act.Pu._1.params.Freq'; Digits = 1 },
        @{ Text = 26; DP = 'DataSource.PG.Act.Pu._1.mapping.DIO.r_error'; Digits = 0 },
        @{ Text = 27; DP = 'DataSource.PG.Act.Pu._2.params.Freq'; Digits = 1 },
        @{ Text = 28; DP = 'DataSource.PG.Act.Pu._2.mapping.DIO.r_error'; Digits = 0 },
        @{ Text = 29; DP = 'DataSource.PG.Act.PV._1.PV_Output.PV_Percent'; Digits = 1 },
        @{ Text = 30; DP = 'DataSource.PG.Act.PV._2.PV_Output.PV_Percent'; Digits = 1 },
        @{ Text = 31; DP = 'DataSource.PG.Act.PV._3.PV_Output.PV_Percent'; Digits = 1 },
        @{ Text = 32; DP = 'DataSource.PG.Act.PV._4.PV_Output.PV_Percent'; Digits = 1 },
        @{ Text = 33; DP = 'DataSource.PG.Act.PV._5.PV_Output.PV_Percent'; Digits = 1 }
    )
    for ($index = 0; $index -lt $deviceRows.Count; $index++) {
        $column = [math]::Floor($index / 5)
        $row = $index % 5
        $left = 650 + ($column * 300)
        $top = 510 + ($row * 45)
        $controls.Add((New-TextControl "DeviceLabel_$index" $deviceRows[$index].Text $left $top 180))
        $controls.Add((New-NumericOutput "DeviceValue_$index" $deviceRows[$index].DP ($left + 185) $top $deviceRows[$index].Digits 95))
    }

    $page = @"
<?xml version="1.0" encoding="UTF-8"?>
<?AutomationStudio Version="4.12.3.127 SP"?>
<Page xmlns="http://br-automation.co.at/AS/VC/Project" Name="Main_Command">
  <Property Name="Description" Value="Glavni komandni ekran podstanice"/>
  <Property Name="Height" Value="800"/>
  <Property Name="Index" Value="30"/>
  <Property Name="MoveFocus" Value="Circular"/>
  <Property Name="StyleClass" Value="Source[relative:StyleGroup].StyleClass[default]"/>
  <Property Name="Width" Value="1280"/>
  <Layers><Layer Name="Default">
    <Property Name="BackColor" Value="9"/><Property Name="Description" Value=""/>
    <Property Name="EditingMode" Value="Normal"/><Property Name="Height" Value="800"/>
    <Property Name="Left" Value="0"/><Property Name="OutlineColor" Value="0"/>
    <Property Name="OutlineDisplayControl" Value="False"/><Property Name="OutlineDisplayName" Value="True"/>
    <Property Name="OutlineHatched" Value="False"/><Property Name="StatusDatapoint" Value="None"/>
    <Property Name="Top" Value="0"/><Property Name="VisibilityMode" Value="Normal"/>
    <Property Name="Width" Value="1280"/><Property Name="Z-Order" Value="0"/>
    <TextGroup>
      <TextLayer LanguageId="en">$($textLines -join "`r`n")</TextLayer>
      <TextLayer LanguageId="de">$($textLines -join "`r`n")</TextLayer>
      <IndexMap>$($indexLines -join "`r`n")</IndexMap>
    </TextGroup>
    <Controls>$($controls -join "`r`n")</Controls>
    <KeyMapping>$($keys -join "`r`n")</KeyMapping>
  </Layer></Layers>
  <MovementOrder/><TabSequence/>
</Page>
"@
    Write-Utf8NoBom (Join-Path $pagesRoot 'Main_Command.page') $page
}

function New-Field([string]$Label, [string]$DataPoint, [double]$Min, [double]$Max, [int]$Digits) {
    return @{ Label = $Label; DataPoint = $DataPoint; Min = $Min; Max = $Max; Digits = $Digits }
}

# Extend datasource with time and AirRelease parameters once.
$dataSource = Get-Content -Raw -LiteralPath $dataSourcePath
if ($dataSource -notmatch '<Folder Name="AirRelease">') {
    $extra = ''
    foreach ($timeName in 'T_PrelazPV05Cuvar', 'T_OverlapPumpi', 'T_AutoRestartDelay', 'T_ValvePositionTimeout', 'T_InterlockDebounce') {
        $extra += New-DataPoint $timeName 'TIME' 'INTEGER' '        '
    }
    $extra += "        <Folder Name=`"AirRelease`">`r`n          <Property Name=`"Description`" Value=`"AirRelease parametri po izvoru`"/>`r`n          <Property Name=`"FolderType`" Value=`"Struct`"/>`r`n"
    foreach ($source in 'BRB2', 'IEBKB1') {
        $extra += "          <Folder Name=`"$source`">`r`n            <Property Name=`"Description`" Value=`"`"/>`r`n            <Property Name=`"FolderType`" Value=`"Struct`"/>`r`n"
        $extra += New-AirReleaseFolder 'PV03' '            '
        $extra += New-AirReleaseFolder 'PV04' '            '
        $extra += "          </Folder>`r`n"
    }
    $extra += "        </Folder>`r`n"

    $anchor = '        <DataPoint Name="MaxOtvorPropZaZatvaranje">'
    $start = $dataSource.IndexOf($anchor)
    if ($start -lt 0) { throw 'Datasource anchor MaxOtvorPropZaZatvaranje not found.' }
    $close = $dataSource.IndexOf('        </DataPoint>', $start) + '        </DataPoint>'.Length
    $dataSource = $dataSource.Insert($close, "`r`n$extra")
}

if ($dataSource -notmatch '<Folder Name="Rad_PG_KB">') {
    $programFolder = @"
    <Folder Name="Rad_PG_KB">
      <Property Name="Description" Value="HMI komande state masine"/>
      <Property Name="FolderType" Value="Program"/>
$(New-DataPoint 'CmdSetDefaultParameters' 'BOOL' 'BOOL' '      ')
    </Folder>
"@
    $dataSource = $dataSource.Replace('  </DataPoints>', "$programFolder  </DataPoints>")
}
$programDataPoints = @(
    @{ Name = 'KomandaStart'; Plc = 'BOOL'; Vc = 'BOOL' },
    @{ Name = 'KomandaStop'; Plc = 'BOOL'; Vc = 'BOOL' },
    @{ Name = 'KomandaReset'; Plc = 'BOOL'; Vc = 'BOOL' },
    @{ Name = 'State'; Plc = 'E_PGRad_State'; Vc = 'INTEGER' },
    @{ Name = 'Substep'; Plc = 'USINT'; Vc = 'INTEGER' },
    @{ Name = 'FaultLatched'; Plc = 'BOOL'; Vc = 'BOOL' },
    @{ Name = 'FaultCode'; Plc = 'USINT'; Vc = 'INTEGER' }
)
foreach ($point in $programDataPoints) {
    if ($dataSource -notmatch "(?s)<Folder Name=`"Rad_PG_KB`">.*?<DataPoint Name=`"$($point.Name)`">") {
        $entry = New-DataPoint $point.Name $point.Plc $point.Vc '      '
        $dataSource = $dataSource.Replace('    </Folder>  </DataPoints>', "$entry    </Folder>  </DataPoints>")
    }
}
if ($dataSource -notmatch '(?s)<Folder Name="Rad_PG_KB">.*?<DataPoint Name="FaultText">') {
    $faultTextPoint = @"
      <DataPoint Name="FaultText">
        <Property Name="ConnectedBySharedResource" Value="False"/>
        <Property Name="ConnectingVisus" Value="Visu1"/>
        <Property Name="Description" Value="Aktivna procesna greska"/>
        <Property Name="PLCType" Value="STRING"/>
        <Property Name="StringLength" Value="80"/>
        <Property Name="UpdateTime" Value="Default"/>
        <Property Name="UserID" Value="None"/>
        <Property Name="VCType" Value="STRING"/>
      </DataPoint>
"@
    $dataSource = $dataSource.Replace('    </Folder>  </DataPoints>', "$faultTextPoint    </Folder>  </DataPoints>")
}
Write-Utf8NoBom $dataSourcePath $dataSource

$processFields = @(
    (New-Field 'Izvor: 0=Nijedan, 1=BRB2, 2=IEBKB1' 'DataSource.PGRad.Ctrl.SelektovaniIzvor' 0 2 0),
    (New-Field 'Regulacija: 0=Off, 1=Pritisak, 2=Nivo, 3=Temp' 'DataSource.PGRad.Ctrl.RegulacionaVarijanta' 0 3 0),
    (New-Field 'Aktivna pumpa: 0=Nijedna, 1=Pu1, 2=Pu2' 'DataSource.PGRad.Ctrl.AktivnaPumpaIzlazTanka' 0 2 0),
    (New-Field 'Aktivni PV ulaza: 0=Nijedan, 1=PV01, 2=PV02' 'DataSource.PGRad.Ctrl.AktivniPropVentilUlazTanka' 0 2 0),
    (New-Field 'AutoRestart: 0=OFF, 1=ON' 'DataSource.PGRad.Ctrl.AutoRestart' 0 1 0),
    (New-Field 'Pritisak potisa [bar]' 'DataSource.PGRad.Par.SetPritisakPotisa' 0 10 2),
    (New-Field 'Minimalni protok [l/s]' 'DataSource.PGRad.Par.MinProtok' 0 72 2),
    (New-Field 'Maksimalni protok [l/s]' 'DataSource.PGRad.Par.MaxProtok' 0 72 2),
    (New-Field 'Minimalni protok pumpe [l/s]' 'DataSource.PGRad.Par.MinFR_Pumpe' 0 72 2),
    (New-Field 'Maksimalni protok pumpe [l/s]' 'DataSource.PGRad.Par.MaxFR_Pumpe' 0 72 2),
    (New-Field 'Ciljni nivo tanka [m]' 'DataSource.PGRad.Par.SetPointNivoTanka' 0 3 2),
    (New-Field 'Minimalna temperatura ispiranja [degC]' 'DataSource.PGRad.Par.SetPointMinTempIspiranja' 0 120 1),
    (New-Field 'PV05 pritisak ispiranja [bar]' 'DataSource.PGRad.Par.SetPointPritisakPV05Ispiranje' 0 10 2),
    (New-Field 'Pritisak ulaza u tank [bar]' 'DataSource.PGRad.Par.SetPointPritisakUlazTanka' 0 10 2),
    (New-Field 'Maks. pritisak dolazne cevi [bar]' 'DataSource.PGRad.Par.SetPointMaxPritisakDolaznaCev' 0 10 2),
    (New-Field 'Pocetna frekvencija pumpe [Hz]' 'DataSource.PGRad.Par.PocetnaFrekvencaIzlaznePumpe' 0 100 1),
    (New-Field 'Maks. otvor za potvrdu zatvaranja [%]' 'DataSource.PGRad.Par.MaxOtvorPropZaZatvaranje' 0 100 1)
)

$timeFields = @(
    (New-Field 'Prelaz PV05 cuvar [s]' 'DataSource.PGRad.Par.TimeSP.PrelazPV05Cuvar_s' 0.1 3600 1),
    (New-Field 'Maksimalni overlap pumpi [s]' 'DataSource.PGRad.Par.TimeSP.OverlapPumpi_s' 0.1 3600 1),
    (New-Field 'AutoRestart kasnjenje [s]' 'DataSource.PGRad.Par.TimeSP.AutoRestartDelay_s' 0.1 3600 1),
    (New-Field 'Timeout polozaja ventila [s]' 'DataSource.PGRad.Par.TimeSP.ValvePositionTimeout_s' 0.1 3600 1),
    (New-Field 'Interlock debounce [s]' 'DataSource.PGRad.Par.TimeSP.InterlockDebounce_s' 0.1 3600 1)
)

function New-AirFields([string]$Source) {
    $fields = [System.Collections.Generic.List[object]]::new()
    foreach ($valve in 'PV03', 'PV04') {
        $base = "DataSource.PGRad.Par.AirRelease.$Source.$valve"
        $fields.Add((New-Field "$valve - prag pritiska [bar]" "$base.PressureSP_bar" 0 15 2))
        $fields.Add((New-Field "$valve - histereza pritiska [bar]" "$base.PressureHysteresis_bar" 0 15 2))
        foreach ($stage in 'LS1', 'LS2') {
            $fields.Add((New-Field "$valve $stage - otvor [%]" "$base.$stage.SP_Percent" 0 100 1))
            $fields.Add((New-Field "$valve $stage - rampa [%/s]" "$base.$stage.Ramp_PercentPerSecond" 0.01 100 2))
            $fields.Add((New-Field "$valve $stage - potvrda [s]" "$base.$stage.ConfirmTime_s" 0 3600 1))
        }
    }
    return $fields.ToArray()
}

New-SettingsPage 'Para_Settings' 'PARA / SETTINGS - PROCES' $processFields
New-SettingsPage 'Para_Times' 'PARA / SETTINGS - VREMENA' $timeFields
New-SettingsPage 'Para_AR_BRB2' 'PARA / SETTINGS - AIR RELEASE BRB2' (New-AirFields 'BRB2')
New-SettingsPage 'Para_AR_IEB' 'PARA / SETTINGS - AIR RELEASE IEBKB1' (New-AirFields 'IEBKB1')
New-MainCommandPage

# Add the Settings button and its page action to Init_Page once.
$initPage = Get-Content -Raw -LiteralPath $initPagePath
if ($initPage -notmatch 'Name="Btn_ParaSettings"') {
    $initPage = $initPage.Replace('<Text ID="96783" Value="Pu1 AUTO"/>', '<Text ID="96783" Value="Pu1 AUTO"/>' + "`r`n          <Text ID=`"97000`" Value=`"PARAMETRI`"/>")
    $button = New-NavButton 'Btn_ParaSettings' 97000 '%nav_settings' 1090 160
    $initPage = $initPage.Replace('      </Controls>' + "`r`n" + '      <KeyMapping>', $button + '      </Controls>' + "`r`n" + '      <KeyMapping>')
    $key = New-PageKey '%nav_settings' 'Para_Settings'
    $initPage = $initPage.Replace('      </KeyMapping>', $key + '      </KeyMapping>')
}
$initPage = [regex]::Replace(
    $initPage,
    '(?s)(<TextLayer LanguageId="[^"]+">)(.*?)(</TextLayer>)',
    {
        param($match)
        $content = $match.Groups[2].Value
        if ($content -match '<Text ID="97000"') {
            $content = [regex]::Replace($content, '<Text ID="97000" Value="[^"]*"/>', '<Text ID="97000" Value="KOMANDE"/>')
            return $match.Groups[1].Value + $content + $match.Groups[3].Value
        }
        return $match.Groups[1].Value + $content + "`r`n          <Text ID=`"97000`" Value=`"KOMANDE`"/>`r`n        " + $match.Groups[3].Value
    }
)
$settingsTextIndex = 143
if ($initPage -notmatch '<Index ID="97000"') {
    $initPage = $initPage.Replace('        </IndexMap>', "          <Index ID=`"97000`" Value=`"$settingsTextIndex`"/>`r`n        </IndexMap>")
}
$settingsButton = New-NavButton 'Btn_ParaSettings' $settingsTextIndex '%nav_settings' 1090 160
$initPage = [regex]::Replace(
    $initPage,
    '(?s)        <Control ClassId="0x00001002" Name="Btn_ParaSettings">.*?</Control>',
    [System.Text.RegularExpressions.MatchEvaluator]{ param($match) $settingsButton.TrimEnd() }
)
$initPage = [regex]::Replace(
    $initPage,
    '(?s)(<VirtualKey Name="%nav_settings">.*?<Property Name="Page" Value=")Source\[local\]\.Page\[[^]]+\]("/>.*?</VirtualKey>)',
    '$1Source[local].Page[Main_Command]$2'
)
Write-Utf8NoBom $initPagePath $initPage

# Register all generated pages in the VC package once.
$package = Get-Content -Raw -LiteralPath $packagePath
foreach ($pageName in 'Main_Command', 'Para_Settings', 'Para_Times', 'Para_AR_BRB2', 'Para_AR_IEB') {
    if ($package -notmatch [regex]::Escape("Pages\$pageName.page")) {
        $package = $package.Replace('    <Source File="Pages\Init_Page.page"/>', '    <Source File="Pages\Init_Page.page"/>' + "`r`n    <Source File=`"Pages\$pageName.page`"/>")
    }
}
Write-Utf8NoBom $packagePath $package

$xmlPaths = @(
    $dataSourcePath,
    $initPagePath,
    $packagePath,
    (Join-Path $pagesRoot 'Para_Settings.page'),
    (Join-Path $pagesRoot 'Para_Times.page'),
    (Join-Path $pagesRoot 'Para_AR_BRB2.page'),
    (Join-Path $pagesRoot 'Para_AR_IEB.page'),
    (Join-Path $pagesRoot 'Main_Command.page')
)
foreach ($xmlPath in $xmlPaths) {
    [xml](Get-Content -Raw -LiteralPath $xmlPath) | Out-Null
    $bytes = [System.IO.File]::ReadAllBytes($xmlPath)
    if (($bytes.Length -ge 3) -and ($bytes[0] -eq 0xEF) -and ($bytes[1] -eq 0xBB) -and ($bytes[2] -eq 0xBF)) {
        throw "UTF-8 BOM detected: $xmlPath"
    }
}

Write-Output 'Para_Settings generation completed: XML valid, UTF-8 without BOM.'