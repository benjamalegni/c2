program cuatro;

type puntarbol=^tipoarbol;
   tipoarbol = record
                  nro     : integer;
                  menores : puntarbol;
                  mayores : puntarbol;
               end;

var arbol,nod:puntarbol;

procedure insertarnodo(var arbol : puntarbol;nod:puntarbol);
begin
   if arbol=nil then
      arbol:=crearnodo(nod)
   else
      if (nod^.nro>arbol^.nro) then
         insertarnodo(arbol^.mayores,nod,arbol)
   else
      if (nod^.nro<arbol^.nro) then
         insertarnodo(arbol^.menores,nod,arbol)
end;

procedure crearnodo(var nod:puntarbol );
begin
   new(nod);
   writeln('ingrese numero del arbol');
   readln(nod^.nro);
   nod^.menores:=nil;
   nod^.mayores:=nil;
end;

procedure creacion(var nod,arbol :puntarbol);
begin
   crearnodo(nod);
   while (nod^.nro<>-1) do begin
      insertarnodo(arbol,nod);
      crearnodo(nod);
   end;
end;

{procedure cargararbol(var arbol :puntarbol );
var dni,nro : integer;
   begin
writeln('ingrese dni');
readln(dni);
writeln('ingrese nro alumno');
readln(nro);

writeln('ingresar 0 cuando no quiera cargar mas');

while (dni<>0) do begin
insertarnodo(arbol,);
writeln('ingrese dni y nroalumno');
readln(dni);
readln(nro);
      end;
   end;
}




procedure buscarnro(arbol : puntarbol);
var nro : integer;
   temp : puntarbol
begin
   writeln('ingrese nro');
   readln(nro);
   if (arbol^.mayores.nro=nro) then
      begin
      temp:=arbol^.mayores
      dispose(arbol^.mayores)
         end
      else
   if (arbol^.menores.nro=nro) then
      dispose(arbol^.menores)
      else
   if (nro<arbol^.nro) then
      buscarnro(arbol^.menores)
      else
         if (nro<arbol^.nro) then
            buscarnro(arbol^.mayores);

end;




begin
end.
