program practica;

const 
  nivel_raiz=0;
  nivel_buscado:8;

type puntarbol=^tiponodoarbol;
  regfecha=record
      dia:1..31;
      mes:1..12;
      anio:1900..2022;
  end;

  puntarbol=^regarbol;
  regarbol=record
    fecha:regfecha;
    id_cliente:integer;
    monto:real;
    menores:puntarbol;
    mayores:puntarbol;
  end;

  puntlistasecundaria=^reglistasecundaria;
  reglistasecundaria=record
    id_cliente:integer;
    monto:real;
    proxsecundaria:puntlistasecundaria;
  end;

  puntlistaprimaria=^reglistaprimaria;
  reglistaprimaria=record
      fecha:regfecha;
      antprimaria:puntlistaprimaria;
      proxprimaria:puntlistaprimaria;
      ventas:puntlistasecundaria;
    end;

procedure generarlista(arbol:puntarbol;var lista:puntlistaprimaria;nivel:integer);
begin
  if ((arbol<>nil) and (nivel<=nivel_buscado)) then begin
    generarlista(arbol^.menores,lista,nivel+1);
    agregarnodoenlista(arbol,lista);
    generarlista(arbol^.mayores,lista,nivel+1);
  end;
end;

procedure agregarnodoenlista(arbol:puntarbol;var lista:puntlistaprimaria);
var nodoprimaria:puntlistaprimaria;
begin
  nodoprimeriaagregarnodoenprimaria(arbol,lista,nil);
  agregarnodoensecundaria(nodoprimaria^.ventas,arbol);
end;

function agregarnodoenprimaria(arbol:puntarbol;var lista:puntlistaprimaria; var antlista:puntlistaprimaria):puntlistaprimaria;
var auxlista:puntlistaprimaria;
begin
  if ((lista=nil) or comparafechas(arbol^.fecha,lista^.fecha)=mayor) then begin
    new(auxlista);
    auxlista^.fecha.dia:=arbol^.fecha.dia;
    auxlista^.fecha.mes:=arbol^.fecha.mes;
    auxlista^.fecha.anio:=arbol^.fecha.anio;
    auxlista^.ventas:=nil;
    auxlista^.proxprimaria:=lista;
    auxlista^.antprimaria:=nil;
    if (lista<>nil) then auxlista^.antprimaria := antlista;
    end 
      else 
        if (comparafechas(arbol.fecha,lista.fecha)=igual) then begin
          //ya existe el nodo con esa fecha en la primaria
          agregarnodoenprimaria:=lista;
          end else begin
            //sigo recorriendo
          agregarnodoenprimaria:=agregarnodoenprimaria(arbol,lista^.proxprimaria,lista);
end;

procedure agregarnodoensecundaria(var listasec:puntlistasecundaria;arbol:puntarbol);
begin
  {la recursion se puede elimianr y crear el nodo al principio recorriendo el arbol en orden inverso}
  if (listasec<>nil) then begin
    agregarnodoensecundaria(listasec^.proxsecundaria,arbol);
  end else
    begin
      new(listasec);
      listasec^.id_cliente:=arbol^.id_cliente;
      listasec^.monto:=arbol^.monto;
      listasec^.proxsecundaria:=nil;
    end;
end;


begin
  generarlista(arbol,lista,nivel_raiz);
  end.
