program parcial;

type plistanotas = ^listanotas;
   listanotas    = record
                      codigomateria : integer;
                      nota          : real;
                      siguiente     : plistanotas;
                   end;

   arbolalumnos  =^nodoalumno;
   nodoalumno = record
                   legajo             : integer;
                   listanotas         : ^listanotas;
                   izquierza,derecha  : arbolalumnos;
                end;

notaarchivo = record
                 legajo        : integer;
                 codigomateria : integer;
                 nota          : real;
              end;

var elarbolalumnos : arbolalumnos;
   archivonotas    : string;

procedure agregarnotasdesdearchivo(archivo : string;var arbol:arbolalumnos);
var
   archivonotas : file of notaarchivo;
   nota         : notaarchivo;
   begin
      assign(archivonotas,archivo); {archivo notas es el nombre del archivo}
      reset(archivonotas);
      while not EOF(archivonotas) do begin
         read(archivonotas,nota);
         agregarnotaalumno(arbol,nota);
      end;
      close(archivonotas);
   end;

function nuevonodoarbol(legajo :integer ):arbolalumnos;
var arbol : arbolalumnos;
   begin
      new(arbol);
      arbol^.legajo:=legajo;
      arbol^.listanotas:=nil;
      arbol^.izquierda:=nil;
      arbol^.derecha:=nil;
      nuevonodoarbol:=arbol;
   end;


procedure agregarnotaalumno(var arbol : arbolalumnos;nota:notaarchivo );
begin
   if arbol = nil the begin //crear nodo
      arbol:=nuevonodoarbol(nota.legajo);
      else
         if nota.legajo<arbol^.legajo then begin
            agregarnotaalumno(arbol^.izquierda,nota)
            end
      else
         if nota.legajo>arbol^.legajo then begin
            agregarnotaalumno(arbol^.derecha,nota)
         end
      else
         begin
            agregarnota(arbol^.listanotas,nota.codigomateria,nota.nota)
         end;
end;


function nuevonodonota(codigomateria : integer;nota:real ):plistanotas;
var nuevonodo : plistanotas;
begin
   new(nuevonodo);
   nuevonodo^.codigomateria:=codigomateria;
   nuevonodo^.nota:=nota;
   nuevonodo^.siguiente:=nil;
   nuevonodonota:=nuevonodo;
end;

procedure agregarnota(var lista : plistanota; codigomateria:integer;nota:real );
var nuevonodo,actual,anterior : plistanotas;
   begin
      nuevonodo:=nuevonodonota(codigomateria,nota);
      actual:=lista;
      anterior:=nil;
      while (actual<>nil) and (actual^.codigomateria<codigomateria) do begin
         anterior:=actual;
         actual:=actual^.siguiente;
         end;

      if anterior = nil then begin
         nuevonodo^.siguiente:=lista;
         lista:=nuevonodo;
         end
      else
         begin
            anterior^.siguiente:=nuevonodo;
            nuevonodo^.siguiente:=actual;
         end;
   end;



begin
   elarbolalumnos:=nil;
   archivonotas:='notas_finales.txt';
   agregarnotasdesdearchivo(archivonotas,elarbolalumnos);
   end.
