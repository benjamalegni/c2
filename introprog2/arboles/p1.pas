
type puntar = ^tiponodoarbol;
      tiponodoarbol = record 
        nro:integer;
        menores,mayores:puntar
      end;

var pos:puntar;

procedure alta(var pos:puntar; valor:integer);
begin
  if pos = nil then begin
    new(pos);
    pos^.nro:=valor;
    pos^.menores:=nil;
    pos^.mayores:=nil; end
  else
    if pos^.nro<valor then
        alta(pos^.mayores, valor)
      else
        alta(pos^.menores,valor);
end;

procedure iteracion();
var i:integer;
begin
  for i:=30 downto 1 do 
    alta(pos, i);
end;


begin
  iteracion();

  end.
