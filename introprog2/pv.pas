program parcialviejo1;

const minos = 1;
   maxpac   = 5
   minanio  = 2010
   maxanio  =  2015 {suponiendo que ya esten cargados}

type nlista= record
                nro_paciente : integer;
                anio_ingreso : integer;
                ste,extra    : plista;
             end;

             plista=^nlista;

             narbol=record
                       nro_os  : integer;
                       pac     : plista;
                       izq,der : plista;
                    end;

             parbol=^narbol;

procedure nuevo_criterio_arbol(var nuevalista : plista;arbol:parbol;minos,maxpac,minanio,maxanio:integer);
begin
   if arbol<>nil then
      begin
         if (arbol^.nro_os<=minos) then
            nuevo_criterio_arbol(nuevalista,arbol^.der,minos,maxpac,minanio,maxanio)
         else
            begin
               nuevo_criterio_lista(nuevalista,arbol^.pac,maxpac,minanio,maxanio);
               nuevo_criterio_arbol(nuevalista,arbol^.der,minos,maxpac,minanio,maxanio);
               nuevo_criterio_arbol(nuevalista,arbol^.izq,minos,maxpac,minanio,maxanio);
            end
      end;
end;

procedure nuevo_criterio_lista(var nuevalista : plista;lista:plista;maxpac,minanio,maxanio:integer );
var cursor : plista;
   begin
      cursor:=lista;
      while (cursor<>nil) and (cursor^.nro_pac<maxpac) do
         begin
            if (cursor^.anio_ingreso>minanio) and (cursor^.anio_ingreso<maxanio) then
               insertar_ordenado_lord(nl,cursor);
            cursor:=cursor^.ste;
         end;
   end;


procedure insertar_ordenado_lord(var nuevalista : plista;nodo:plista );
begin
   if (nuevalista=nil) or (nuevalista^.anio_ingreso>nodo^.anio_ingreso) or ((nuevalista^.anio_ingreso=nodo^.anio_ingreso) and (nuevalista^.nro_pac>nodo^.nro_pac)) then
      begin
         nodo^.extra:=nuevalista;
         nuevalista:=nodo;
      end;
end;






begin
end.
