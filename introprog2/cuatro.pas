program cuatro;

type puntarbol=^tipoarbol;
   tipoarbol = record
                  nro     : integer;
                  menores : puntarbol;
                  mayores : puntarbol;
                  padre   : puntarbol
               end;

var arbol,nod:puntarbol;

procedure insertarnodo(var arbol : puntarbol;nod,padre:puntarbol);
begin
   if arbol=nil then
      arbol:=crearnodo(nod,padre)
   else
      if (nod^.nro>arbol^.nro) then
         insertarnodo(arbol^.mayores,nod,arbol)
   else
      if (nod^.nro<arbol^.nro) then
         insertarnodo(arbol^.menores,nod,arbol)
end;

procedure crearnodo(var nod,padre:puntarbol );
begin
   new(nod);
   writeln('ingrese numero del arbol');
   readln(nod^.nro);
   nod^.menores:=nil;
   nod^.mayores:=nil;
   nod^.padre:=padre;
end;

procedure creacion(var nod,arbol :puntarbol);
begin
   crearnodo(nod);
   nod^.padre:=nil;
   while (nod^.nro<>-1) do begin
      insertarnodo(arbol,nod,padre);
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




function buscarnro(arbol : puntarbol):puntarbol;
var nro : integer;
begin
   writeln('ingrese nro');
   readln(nro);
   if (arbol^.nro=nro) then
      buscarnro:=arbol
      else
         if (nro>arbol^.nro) then
            buscarnro:=buscarnro(arbol^.mayores)
            else
               if (nro<arbol^.nro) then
                  buscarnro:=buscarnro(arbol^.menores);
end;



procedure eliminar (var arbol : puntarbol ; valor:integer);
begin
   if arbol=nil then
      arbol:=nil
end;


begin
end.
