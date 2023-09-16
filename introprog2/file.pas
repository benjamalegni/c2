program prueba1;


type arch = File of integer;

var archivo1 : arch;
   nota      : integer;
   i         : integer;

begin
   assign(archivo1,'/home/shiven/Documents/introprog2/datos.dat');
   rewrite(archivo1);
   for i:=1 to 10 do
      read(archivo1,nota);
   close(archivo1);
end.
