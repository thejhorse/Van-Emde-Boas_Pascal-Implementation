unit TvebArbolUnit;

interface

uses Math;

type
  TvebNodo = class
  public
    iUniverso: Integer;
    iMinimo: Integer;
    iMaximo: Integer;

    nSummary: TvebNodo;
    nCluster: Array of TvebNodo;

    constructor fnCreate(iUniversoPropuesto: integer);
  end;

  TvebArbol = class
  private
    nNodoRaiz: TvebNodo;
    function lowerSquarenRoot(nNodo: TvebNodo): Double;
    function fnIndice(nNodo: TvebNodo; x: Integer; y: Integer): Integer;
    function fnLow(nNodo: TvebNodo; x: Integer): Integer;
    function fnHigh(nNodo: TvebNodo; x: Integer): Integer;
    function fnBuscar_Helper(nNodo: TvebNodo; x: Integer): Boolean;
    procedure fnEliminar_Helper(nNodo: TvebNodo; x: Integer);
    procedure fnInsertar_Helper(nNodo: TvebNodo; x: Integer);
    function fnPredecesor_Helper(nNodo: TvebNodo; x: Integer): Integer;
    function fnSucesor_Helper(nNodo: TvebNodo; x: Integer): Integer;
  public
    constructor fnCreate(iUniversoPropuesto: integer);
    function fnMaximo(): Integer;
    function fnMinimo(): Integer;
    function fnPredecesor(x: Integer): Integer;
    function fnSucesor(x: Integer): Integer;
    function fnBuscar(x: Integer): Boolean;
    procedure fnEliminar(x: Integer);
    procedure fnInsertar(x: Integer);
  end;

CONST
  DEF_NULL = -1;

implementation

{ VEBNode }

constructor TvebNodo.fnCreate(iUniversoPropuesto: integer);
var
  iSubUniverso: Integer;
  i: Integer;
  function higherSquareRoot(): Integer;
  begin
    //Result := Trunc(Power(2, Ceil(Log2(iUniverso) / 2)));
    Result := Trunc(Sqrt(iUniverso));
  end;
begin
  iUniverso := iUniversoPropuesto;
  iMinimo := DEF_NULL;
  iMaximo := DEF_NULL;

  if iUniverso <= 2 then
  begin
    nSummary := nil;
    nCluster := nil;
  end
  else
  begin
    iSubUniverso := higherSquareRoot();

    nSummary := TvebNodo.fnCreate(iSubUniverso);
    SetLength(nCluster, iSubUniverso);

    for i := 0 to iSubUniverso - 1 do
      nCluster[i] := TvebNodo.fnCreate(iSubUniverso);
  end;
end;

{ TvebArbol }

constructor TvebArbol.fnCreate(iUniversoPropuesto: integer);
begin
  nNodoRaiz := TvebNodo.fnCreate(iUniversoPropuesto);
end;


function TvebArbol.fnHigh(nNodo: TvebNodo; x: Integer): Integer;
begin
  Result := Trunc(Floor(x / lowerSquarenRoot(nNodo)));
end;

function TvebArbol.fnLow(nNodo: TvebNodo; x: Integer): Integer;
begin
  Result := x mod Trunc(lowerSquarenRoot(nNodo));
end;

function TvebArbol.fnIndice(nNodo: TvebNodo; x, y: Integer): Integer;
begin
  Result := Trunc(x * lowerSquarenRoot(nNodo) + y);
end;

function TvebArbol.lowerSquarenRoot(nNodo: TvebNodo): Double;
begin
  //Result := Trunc(Power(2, Floor(Log2(nNodo.iUniverso) / 2)));
  Result := Trunc(Sqrt(nNodo.iUniverso));
end;

function TvebArbol.fnMaximo(): Integer;
begin
  Result := nNodoRaiz.iMaximo;
end;

function TvebArbol.fnMinimo: Integer;
begin
  Result := nNodoRaiz.iMinimo;
end;

function TvebArbol.fnSucesor(x: Integer): Integer;
begin
  Result := fnSucesor_Helper(nNodoRaiz, x);
end;

function TvebArbol.fnSucesor_Helper(nNodo: TvebNodo; x: Integer): Integer;
var
  iHighDeX: Integer;
  iLowDeX: Integer;
  iMaxCluster: Integer;
  iClusterSucesor: Integer;
begin
  if 2 = nNodo.iUniverso then
  begin
    if (x = 0) and (nNodo.iMaximo = 1) then
    begin
      Result := 1;
      Exit;
    end
    else
    begin
      Result := DEF_NULL;
      Exit;
    end;
  end
  else
    if (nNodo.iMinimo <> DEF_NULL) and (x < nNodo.iMinimo) then
    begin
      Result := nNodo.iMinimo;
      Exit;
    end
    else
    begin
      iHighDeX := fnHigh(nNodo, x);
      iLowDeX := fnLow(nNodo, x);

      iMaxCluster := nNodo.nCluster[iHighDeX].iMaximo;

      if (iMaxCluster <> DEF_NULL) and (iLowDeX < iMaxCluster) then
      begin
        Result := fnIndice(nNodo, iHighDeX, fnSucesor_Helper(nNodo.nCluster[iHighDeX], iLowDeX));
        Exit;
      end
      else
      begin
        iClusterSucesor := fnSucesor_Helper(nNodo.nSummary, iHighDeX);

        if iClusterSucesor = DEF_NULL then
        begin
          Result := DEF_NULL;
          Exit;
        end
        else
        begin
          Result := fnIndice(nNodo, iClusterSucesor, nNodo.nCluster[iClusterSucesor].iMinimo);
          Exit;
        end;
      end;
    end;
end;

function TvebArbol.fnPredecesor(x: Integer): Integer;
begin
  Result := fnPredecesor_Helper(nNodoRaiz, x);
end;

function TvebArbol.fnPredecesor_Helper(nNodo: TvebNodo; x: Integer): Integer;
var
  iHighDeX: Integer;
  iLowDeX: Integer;
  iMinCluster: Integer;
  iClusterPredecesor: Integer;
begin
  if 2 = nNodo.iUniverso then
  begin
    if (1 = x) and (0 = nNodo.iMinimo) then
    begin
      Result := 0;
      Exit;
    end
    else
    begin
      Result := DEF_NULL;
      Exit;
    end;
  end
  else
    if (nNodo.iMaximo <> DEF_NULL) and (x > nNodo.iMaximo) then
    begin
      Result := nNodo.iMaximo;
      Exit;
    end
    else
    begin
      iHighDeX := fnHigh(nNodo, x);
			iLowDeX := fnLow(nNodo, x);

       iMinCluster := nNodo.nCluster[iHighDeX].iMinimo;

       if (iMinCluster <> DEF_NULL) and (iLowDeX > iMinCluster) then
       begin
         Result := fnIndice(nNodo, iHighDeX, fnPredecesor_Helper(nNodo.nCluster[iHighDeX], iLowDeX));
         Exit;
       end
       else
       begin
         iClusterPredecesor := fnPredecesor_Helper(nNodo.nSummary, iHighDeX);

         if (DEF_NULL = iClusterPredecesor) then
         begin
           if (DEF_NULL <> nNodo.iMinimo) and (x > nNodo.iMinimo) then
           begin
             Result := nNodo.iMinimo;
             Exit;
           end
           else
           begin
             Result := DEF_NULL;
             Exit;
           end;
         end
         else
         begin
           Result := fnIndice(nNodo, iClusterPredecesor, nNodo.nCluster[iClusterPredecesor].iMaximo);
           Exit;
         end;
       end;
    end;
end;

function TvebArbol.fnBuscar(x: Integer): Boolean;
begin
  Result := fnBuscar_Helper(nNodoRaiz, x);
end;

function TvebArbol.fnBuscar_Helper(nNodo: TvebNodo; x: Integer): Boolean;
begin
  if (x = nNodo.iMinimo) or (x = nNodo.iMaximo) then
    Result := True
  else
    if 2 = nNodo.iUniverso then
      Result := False
    else
      Result := fnBuscar_Helper(nNodo.nCluster[fnHigh(nNodo, x)], fnLow(nNodo, x));
end;

procedure TvebArbol.fnInsertar(x: Integer);
begin
  fnInsertar_Helper(nNodoRaiz, x)
end;

procedure TvebArbol.fnInsertar_Helper(nNodo: TvebNodo; x: Integer);
var
  iValorTemporal: Integer;
  iHighDeX: Integer;
  iLowDeX: Integer;
begin
	if nNodo.iMinimo = DEF_NULL then
  begin
    nNodo.iMinimo := x;
    nNodo.iMaximo := x;
  end;

  if x < nNodo.iMinimo then
  begin
    iValorTemporal := x;
    x := nNodo.iMinimo;
    nNodo.iMinimo := iValorTemporal;
  end;

  if (x > nNodo.iMinimo) and (nNodo.iUniverso > 2) then
  begin
    iHighDeX := fnHigh(nNodo, x);
		iLowDeX := fnLow(nNodo, x);

    if nNodo.nCluster[iHighDeX].iMinimo <> DEF_NULL then
    begin
      fnInsertar_Helper(nNodo.nCluster[iHighDeX], iLowDeX);
    end
    else
    begin
      fnInsertar_Helper(nNodo.nSummary, iHighDeX);
      nNodo.nCluster[iHighDeX].iMinimo := iLowDeX;
      nNodo.nCluster[iHighDeX].iMaximo := iLowDeX;
    end;
  end;

  if x > nNodo.iMaximo then
    nNodo.iMaximo := x;
end;

procedure TvebArbol.fnEliminar(x: Integer);
begin
  fnEliminar_Helper(nNodoRaiz, x);
end;

procedure TvebArbol.fnEliminar_Helper(nNodo: TvebNodo; x: Integer);
var
  iSummaryMin : Integer;
  iSummaryMax : Integer;
  iHighDeX : Integer;
  iLowDeX : Integer;
begin
  if nNodo.iMinimo = nNodo.iMaximo then
  begin
    nNodo.iMinimo := DEF_NULL;
    nNodo.iMaximo := DEF_NULL;
  end
  else
    if nNodo.iUniverso = 2 then
    begin
      if x = 0 then
        nNodo.iMinimo := 1
      else
        nNodo.iMinimo := 0;

      nNodo.iMaximo := nNodo.iMinimo;
    end
    else
    begin
      if x = nNodo.iMinimo then
      begin
        iSummaryMin := nNodo.nSummary.iMinimo;
        x := fnIndice(nNodo, iSummaryMin, nNodo.nCluster[iSummaryMin].iMinimo);
        nNodo.iMinimo := x;

        iHighDeX := fnHigh(nNodo, x);
        iLowDeX := fnLow(nNodo, x);
        fnEliminar_Helper(nNodo.nCluster[iHighDeX], iLowDeX);

      end
      else
      if x = nNodo.iMaximo then
      begin
        iSummaryMax := nNodo.nSummary.iMaximo;
        x := fnIndice(nNodo, iSummaryMax, nNodo.nCluster[iSummaryMax].iMaximo);
        nNodo.iMaximo := x;

        iHighDeX := fnHigh(nNodo, x);
        iLowDeX := fnLow(nNodo, x);
        fnEliminar_Helper(nNodo.nCluster[iHighDeX], iLowDeX);
      end
      else
      begin
        iHighDeX := fnHigh(nNodo, x);
        iLowDeX := fnLow(nNodo, x);
        fnEliminar_Helper(nNodo.nCluster[iHighDeX], iLowDeX);
      end;

      if nNodo.nCluster[iHighDeX].iMinimo = DEF_NULL then
      begin
        fnEliminar_Helper(nNodo.nSummary, iHighDeX);
        if x = nNodo.iMaximo then
        begin
          iSummaryMax := nNodo.nSummary.iMaximo;
          if iSummaryMax = DEF_NULL then
            nNodo.iMaximo := nNodo.iMinimo
          else
            nNodo.iMaximo := fnIndice(nNodo, iSummaryMax, nNodo.nCluster[iSummaryMax].iMaximo);
        end;
      end
      else
        if x = nNodo.iMaximo then
        begin
          nNodo.iMaximo := fnIndice(nNodo, iHighDeX, nNodo.nCluster[iHighDeX].iMaximo);
        end;
    end;
end;

end.
