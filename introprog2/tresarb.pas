program tresarb;

type puntarbol=^tipoarbol;

tipoarbol = record
               nro     : integer;
               dni     : integer;
               menores : puntarbol;
               mayores : puntarbol;
            end;

var arbol  : puntarbol;
   dni,nro : integer;

procedure insertarnodo(var arbol : puntarbol; nod:puntarbol );
begin
   if (arbol=nil) then
      arbol:=nod
      else
         if (nod^.dni>arbol^.dni) then
            insertarnodo(arbol^.mayores,nod)
   else
      if (nod^.dni>arbol^.dni) then
         insertarnodo(arbol^.menores,nod);
end;

function nuevonodo(dni,nro :integer ):puntarbol;
var nod : puntarbol;
begin
   new(nod);
   nod^.dni:=dni;
   nod^.nro:=nro;
   nod^.menores:=nil;
   nod^.mayores:=nil;
end;

procedure mostrararbol(arbol :puntarbol );
begin
   if arbol<>nil then
      begin
         mostrararbol(arbol^.menores);
         writeln(arbol^.nro);
         mostrararbol(arbol^.mayores);
      end;
end;

procedure cargararbol(var arbol :puntarbol );
var dni,nro : integer;
   begin
      writeln('ingrese dni');
      readln(dni);
      writeln('ingrese nro alumno');
      readln(nro);

      writeln('ingresar 0 cuando no quiera cargar mas');

      while (dni<>0) do begin
         insertarnodo(arbol,nuevonodo(dni,nro));
         writeln('ingrese dni y nroalumno');
         readln(dni);
         readln(nro);
      end;
   end;

function buscardni(arbol : puntarbol ;dni:integer):puntarbol;
begin
   if arbol=nil then
      writeln('no se encontro el dni')
      else
         if (arbol^.dni = dni) then
            buscardni:=arbol
      else
         if (arbol^.dni > dni) then
            buscardni:=buscardni(arbol^.menores,dni)
      else
         if (arbol^.dni < dni) then
            buscardni:=buscardni(arbol^.mayores,dni);
end;

function buscarnro(arbol : puntarbol;nro:integer ):puntarbol;
begin
   if arbol<>nil then
      begin
         if (arbol^.nro=nro) then
            buscarnro:=arbol
            else
               begin
                  buscarnro:=buscarnro(arbol^.menores,nro);
                  buscarnro:=buscarnro(arbol^.mayores,nro);
               end;
      end
end;





begin
   cargararbol(arbol);
   writeln('ingrese el dni que desea buscar para obtener el nro alumno');
   readln(dni);
   writeln('nro alumno:');
   writeln(buscarnro(arbol,dni)^.nro);

   writeln('ingrese nro de alumno para obtener dni');
   readln(nro);
   writeln(buscardni(arbol,dni)^.dni); 
end.
