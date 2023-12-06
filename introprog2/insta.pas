program instapas;

uses sysutils;

type
    arbolusuarios= ^nodoarbol;
    plistaseguidos = ^listaseguidos;
    plistahistorias = ^nodohistoria;


    listaseguidos = record
        nusuario : string;
        seguir   : arbolusuarios;
        sig      : plistaseguidos;
        end;

    string8=string[8];

    nodohistoria = record
        fecha_hora   : string;
        texto   : string;
        sig     : plistahistorias;
        end;

    nodoarbol = record
        nombre      : string;
        password    : string[8];
        email       : string;
        seguidos    : plistaseguidos;
        historias   : plistahistorias;
        mayores     : arbolusuarios;
        menores     : arbolusuarios;
        end;
    
    reg_arb = record
        nombre      : string;
        password    : string[8];
        email       : string;
    end;
    
    reg_seg = record
        nusuario : string;
        nseguidor:string;
        end;
    
    reg_his = record
        ncreador: string;
        fecha_hora   : string;
        texto   : string;
        end;
        
    archusuarios = file of reg_arb;
    archhistorias = file of reg_his;
    archseguidos = file of reg_seg;
    
procedure abrirus(var archus:archusuarios;nombre:string);
    begin
        assign(archus, nombre);
        {$I-}
        reset(archus);
        {$I+}
        if ioresult <> 0 then 
            begin
                rewrite(archus);
        end;
    end;

procedure abrirhis(var archhis:archhistorias;nombre:string);
    begin
        assign(archhis, nombre);
        {$I-}
        reset(archhis);
        {$I+}
        if ioresult <> 0 then 
            begin
                rewrite(archhis);
            end;
    end;

procedure abrirseg(var archseg:archseguidos;nombre:string);
    begin
        assign(archseg, nombre);
        {$I-}
        reset(archseg);
        {$I+}
    if ioresult <> 0 then 
        begin
            rewrite(archseg);
        end;
end;


   
       
function ubicacionusuario(nombre : string;elarbol:arbolusuarios ):arbolusuarios;
    begin
        if nombre=elarbol^.nombre then
            begin
                ubicacionusuario:=elarbol;
            end
        else
            if nombre>elarbol^.nombre then
                begin
                    ubicacionusuario:=ubicacionusuario(nombre,elarbol^.mayores);
                end
            else
                if nombre<elarbol^.nombre then
                    begin
                        ubicacionusuario:=ubicacionusuario(nombre,elarbol^.menores);
                    end;
    end;

function existe(nombre: string;elarbol:arbolusuarios): boolean;
    begin
        if  elarbol= nil then
            begin
                existe := false;
            end
        else
            if nombre = elarbol^.nombre then
                begin
                    existe := true;
                end
            else
                if nombre < elarbol^.nombre then
                    begin
                        existe := existe(nombre, elarbol^.menores);
                    end
                else
                    begin
                        existe := existe(nombre, elarbol^.mayores);
                    end;
    end;

   
function verifica(password:string8;elarbol:arbolusuarios):boolean;
    begin
        if (password=elarbol^.password) then
            begin
                verifica:=true;
            end
        else
            begin
                verifica:=false;
            end;
    end;


function verificarlogin (nombre : string; password:string8; elarbol:arbolusuarios ):boolean;
    var 
        aux:arbolusuarios;
    begin
        if (existe(nombre,elarbol)) then
            begin
                aux:=ubicacionusuario(nombre,elarbol);
                if (verifica(password,aux)) then
                    begin
                        verificarlogin:=true;
                    end
                else
                    begin
                        writeln('password incorrecto');
                    end
            end
        else
            begin
                writeln('no existe el usuario con el nombre:', nombre);
                verificarlogin:=false;
            end;
    end;

function limite_dias_historias(dias :string ):string;
    var  
        dias_tdatetime: TDateTime;
        limite:tdatetime;
    begin
        dias_tdatetime:=strtodatetime(dias);
        limite:=now-dias_tdatetime;
        limite_dias_historias:=datetimetostr(limite);
    end;

function th(puntusuario : arbolusuarios;dias:string):boolean;{recorre historias buscando}
    begin
        while (puntusuario^.historias<>nil) and (puntusuario^.historias^.fecha_hora<limite_dias_historias(dias)) do
            begin
                puntusuario^.historias:=puntusuario^.historias^.sig;
            end;
    if puntusuario^.historias=nil then
        begin
            th:=false;
        end
    else
        begin
            th:=true;
        end;
    end;


procedure usuarios_qsh(elarbol : arbolusuarios;dias:string); {usuarios que subieron historias, usando el limite de dias}
    var
        pusuario:arbolusuarios;
    begin
        if elarbol<>nil then 
        begin
            pusuario:=ubicacionusuario(elarbol^.nombre,elarbol);
            usuarios_qsh(elarbol^.menores,dias);
            if (th(pusuario,dias)=true)then 
                writeln(pusuario^.nombre, ' ha subido una historia/historias desde hace: ', dias, ' dias.');
            usuarios_qsh(elarbol^.mayores,dias);
        end;
    end;


procedure crear_n_historia(var nhistoria :plistahistorias);
    begin
        new(nhistoria);
        writeln('ingrese el texto a la historia');
        readln(nhistoria^.texto);
        nhistoria^.fecha_hora:=datetimetostr(now);
        nhistoria^.sig:=nil;
    end;

procedure insertar_historia(var nhistoria :plistahistorias ; var elarbol:arbolusuarios;var puntusuario:arbolusuarios);
    var  
        punthistorias: plistahistorias;
    begin
        if puntusuario^.historias=nil then
            begin
                puntusuario^.historias:=nhistoria;
            end
        else
            begin
                punthistorias:=puntusuario^.historias;
                while punthistorias^.sig<>nil do
                    begin
                        punthistorias:=punthistorias^.sig;
                    end;
                punthistorias^.sig:=nhistoria;
             end;
    end;
   
procedure info_hs(primernodo:plistahistorias);
    begin
        writeln('La historia se ha subido en la fecha: ', primernodo^.fecha_hora);
        writeln('**',primernodo^.texto ,'**');
    end;

function hsdr(primernodo:plistahistorias;dias:string):plistahistorias;{historias seguidos dentro del rango}
    begin
        while primernodo^.fecha_hora<limite_dias_historias(dias) do
            primernodo:=primernodo^.sig;
        if primernodo=nil then
            hsdr:=nil
        else
            hsdr:=primernodo;
    end;



procedure ver_hs(puntusuario :arbolusuarios );{ver historias seguidos}
    var
        primernodo:plistahistorias;
        pnodoseguidos:plistaseguidos;
        dias: string;
    begin
    writeln('inserte la cantidad de dias hacia atras que desee ver');
    readln(dias);
    if puntusuario^.seguidos<>nil then
        begin
            primernodo:=hsdr(puntusuario^.seguidos^.seguir^.historias,dias);
            pnodoseguidos:=puntusuario^.seguidos;
            while pnodoseguidos<>nil do
                begin
                    if (pnodoseguidos^.seguir^.historias<>nil) then
                        begin
                            if hsdr(primernodo,dias)<>nil then
                                begin
                                    writeln('#########################################');
                                    writeln('historias subidas por:', pnodoseguidos^.nusuario );
                                    while primernodo<>nil do
                                        begin
                                            info_hs(primernodo);
                                            primernodo:=primernodo^.sig;
                                        end;
                                    writeln('#########################################');
                                end
                            else
                                writeln('no hay historias dentro del rango de ',dias,' dias');
                        end
                    else
                        writeln(puntusuario^.nombre,' debo informarle que ninguna persona de sus seguidos ha subido historias dentro del rango dado');
                        pnodoseguidos:=pnodoseguidos^.sig;
                end;
        end
    else
        writeln('no seguis a nadie');
    end;    
 
   
procedure agregar_historia(var elarbol:arbolusuarios;var puntusuario:arbolusuarios);{pasasr}
    var
        nhistoria:plistahistorias;
    begin
        crear_n_historia(nhistoria);
        insertar_historia(nhistoria,elarbol,puntusuario);
    end;

procedure mis_seguidos(var elarbol:arbolusuarios;var puntusuario:arbolusuarios);
    var
        puntseguidos:plistaseguidos;
    begin
        if puntusuario^.seguidos<>nil then
            begin
                puntseguidos:=puntusuario^.seguidos;
                writeln('||||usuarios a los que sigo||||');
                writeln(puntseguidos^.nusuario);
                while puntseguidos^.sig<> nil do
                    begin
                        puntseguidos:=puntseguidos^.sig;
                        writeln('_',puntseguidos^.nusuario);
                    end;
            end
        else
            begin
                writeln('el usuario no sigue a ningun otro usuario');
            end;
    end;
           
procedure nuevo_seguido(var nuevoseg:plistaseguidos;nom:string; var elarbol:arbolusuarios);
    begin
        new(nuevoseg);
        nuevoseg^.nusuario:=nom;
        nuevoseg^.seguir:=ubicacionusuario(nom,elarbol);
        nuevoseg^.sig:=nil;
    end;



function rs(puntusuario:arbolusuarios;nom:string):boolean;{recorre seguidos}
    var
        aux:plistaseguidos;
    begin
        if puntusuario^.seguidos<>nil then
            begin
                aux:=puntusuario^.seguidos;
                while (aux<>nil) and (aux^.nusuario<>nom) do
                    begin
                        aux:=aux^.sig;
                    end;
                if (aux<>nil) and (aux^.nusuario=nom) then
                    begin
                        rs:=false;
                    end
                else
                    begin
                        rs:=true;
                    end
            end
        else
            begin
                rs:=true;
            end;
    end;


procedure seguir_usuario(var elarbol: arbolusuarios; var puntusuario: arbolusuarios);
    var
        nuevoseg, aux: plistaseguidos;
        nom: string;
    begin
        writeln('Ingrese el nombre de usuario que quiere seguir');
        readln(nom);
        if existe(nom,elarbol) then
            begin
                if rs(puntusuario,nom) = true then
                    begin
                        nuevo_seguido(nuevoseg, nom, elarbol);
                        if puntusuario^.seguidos = nil then
                            begin
                                puntusuario^.seguidos := nuevoseg;
                            end
                        else
                            if puntusuario^.seguidos^.nusuario>nuevoseg^.nusuario then
                                begin
                                    nuevoseg^.sig:=puntusuario^.seguidos;
                                    puntusuario^.seguidos:=nuevoseg;
                                end
                            else
                                begin
                                    aux := puntusuario^.seguidos;
                                    while (aux^.sig <> nil) and (aux^.nusuario<nuevoseg^.nusuario) and (aux^.sig^.nusuario<nuevoseg^.nusuario)do
                                        begin
                                            aux := aux^.sig;
                                        end;
                                    if (aux^.sig=nil) and (aux^.nusuario<nuevoseg^.nusuario) then
                                        begin
                                            aux^.sig:=nuevoseg;
                                        end
                                    else
                                        if (aux^.sig^.nusuario>nuevoseg^.nusuario) then
                                            begin
                                                nuevoseg^.sig:=aux^.sig;
                                                aux^.sig:=nuevoseg;
                                            end;
                                end;
                        writeln('Ahora seguis a:',nom);
                    end
                else
                    begin
                        writeln('ya seguis a',nom);
                    end;
            end
        else
            begin
                writeln('no existe un usuario asociado a',nom);
            end;
        nuevoseg:=nil;
    end;

procedure chs(var elarbol:arbolusuarios;reg:reg_his);{cargar historias}
var phis:plistahistorias;
begin
    if elarbol<>nil then
        begin
            if reg.ncreador<elarbol^.nombre then
                chs(elarbol^.menores,reg)
            else
                if reg.ncreador>elarbol^.nombre then
                    chs(elarbol^.mayores,reg)
        end
    else
        begin
            phis:=elarbol^.historias;
            while phis<>nil do
                phis:=phis^.sig;
            new(phis);
            phis^.texto:=reg.texto;
            phis^.fecha_hora:=reg.fecha_hora;
            phis^.sig:=nil;
        end;
    
end;


procedure cda(var elarbol:arbolusuarios;var ausuarios:archusuarios);{cargar desde el arbol}
var temp:reg_arb;
begin
    if (elarbol<>nil) and (not eof(ausuarios)) then
        begin
            read(ausuarios,temp);
            new(elarbol);

            elarbol^.nombre:=temp.nombre;
            elarbol^.password:=temp.password;
            elarbol^.email:=temp.email;
            elarbol^.historias:=nil;
            elarbol^.seguidos:=nil;
            cda(elarbol^.menores,ausuarios);
            cda(elarbol^.mayores,ausuarios);
        end;
end;

function puntseguido(var elarbol:arbolusuarios;seguidos:reg_seg):arbolusuarios;
begin
    if elarbol<>nil then
        if elarbol^.nombre>seguidos.nusuario then
            puntseguido:=puntseguido(elarbol^.menores,seguidos)
        else
            if elarbol^.nombre<seguidos.nusuario then
                puntseguido:=puntseguido(elarbol^.mayores,seguidos)
            else
            puntseguido:=elarbol;
end;

procedure cls(var elarbol:arbolusuarios;puntusuario:arbolusuarios;seg:reg_seg);{cargar lista seguidos}
begin
    if elarbol<>nil then
    begin
        if elarbol^.nombre>seg.nseguidor then
            cls(elarbol^.menores,puntusuario,seg)
        else
            if elarbol^.nombre<seg.nseguidor then
                cls(elarbol^.mayores,puntusuario,seg);
    end
        else
            begin
                while elarbol^.seguidos<>nil do
                    elarbol^.seguidos:=elarbol^.seguidos^.sig;
                new(elarbol^.seguidos);
                elarbol^.seguidos^.seguir:=puntusuario;
                elarbol^.seguidos^.sig:=nil;
            end;
    
end;


procedure asg_arch(var elarbol:arbolusuarios;var ausuarios:archusuarios;var ahistorias:archhistorias;var aseguidos:archseguidos);
   var 
        aux_historias:reg_his;
        aux_seguidos:reg_seg;
    begin

        cda(elarbol,ausuarios);
        
        while not eof(aseguidos) do
            begin
                read(aseguidos,aux_seguidos);
                cls(elarbol,puntseguido(elarbol,aux_seguidos),aux_seguidos);
            end;

        while not eof(ahistorias) do
        begin
            read(ahistorias,aux_historias);
            chs(elarbol,aux_historias)
        end;

        close(ausuarios);
        close(ahistorias);
        close(aseguidos);
    end;



  
procedure act_arch(var elarbol:arbolusuarios;var ausuarios:archusuarios;var ahistorias:archhistorias;var aseguidos:archseguidos);
    var     
        phistorias:plistahistorias;
        pseguidos:plistaseguidos;
        aux_usuario:reg_arb;
        aux_historias:reg_his;
        aux_seguidos:reg_seg;

    begin
        if elarbol<>nil then
            begin
                writeln('PROCESANDO INFO');
                
                {nodo}
                aux_usuario.nombre:=elarbol^.nombre;
                aux_usuario.password:=elarbol^.password;
                aux_usuario.email:=elarbol^.email;
                
                
                write(ausuarios,aux_usuario);
                {historias}
                phistorias:=elarbol^.historias;
                while phistorias<>nil do
                    begin
                        aux_historias.fecha_hora:=phistorias^.fecha_hora;
                        aux_historias.texto:=phistorias^.texto;
                        write(ahistorias,aux_historias);
                        phistorias:=phistorias^.sig;
                    end;
                
                {seguidos}
                pseguidos:=elarbol^.seguidos;
                while pseguidos<>nil do
                    begin
                        aux_seguidos.nusuario:=pseguidos^.nusuario;
                        aux_seguidos.nseguidor:=elarbol^.nombre;
                        write(aseguidos,aux_seguidos);
                        pseguidos:=pseguidos^.sig;
                    end;
                
                
                act_arch(elarbol^.menores,ausuarios,ahistorias,aseguidos);
                act_arch(elarbol^.mayores,ausuarios,ahistorias,aseguidos);
            end;
    end;


   
   
procedure eliminar_hduae(var phistorias:plistahistorias);{eliminar historias de usuario a eliminar}
    begin
        while phistorias<>nil do
            begin
                eliminar_hduae(phistorias^.sig);
                dispose(phistorias);
            end;
    end;

procedure eliminar_ds(var elarbol:arbolusuarios;nom:string);
    var
        aux,borrarnodo:plistaseguidos;
    begin
        if elarbol^.seguidos= nil then
            begin
                exit;
            end
        else
            if elarbol^.seguidos<>nil then
                begin
                    aux:=elarbol^.seguidos;
                    if elarbol^.seguidos^.nusuario=nom then
                        begin
                            if elarbol^.seguidos^.sig=nil then
                                begin
                                    dispose(elarbol^.seguidos);
                                    elarbol^.seguidos:=nil;
                                end
                            else
                                if elarbol^.seguidos^.sig<>nil then
                                    begin
                                        elarbol^.seguidos:=elarbol^.seguidos^.sig;
                                    end;
                        end
                    else
                        begin
                            while (aux^.nusuario<>nom) and (aux^.sig<>nil) and (aux^.sig^.nusuario<>nom) do
                                begin
                                  	aux:=aux^.sig;
                                end;
                            if aux^.sig=nil then
                                begin
                                    exit;
                                end
                            else
                                if aux^.sig^.nusuario=nom then
                                    begin
                                        if aux^.sig^.sig=nil then
                                            begin
                                                dispose(aux^.sig);
                                            end
                                        else
                                            if aux^.sig^.sig<>nil then
                                                begin
                                                    borrarnodo:=aux^.sig;
                                                    aux^.sig:=aux^.sig^.sig;
                                                    dispose(borrarnodo);
                                                end;
                                    end;
                        end;
                end;
	end;

procedure eliminar_rapes(var elarbol:arbolusuarios;nom:string);{recorre arbol para eliminar seguido}
    begin
        if elarbol<>nil then
            begin
                eliminar_rapes(elarbol^.menores,nom);
                eliminar_rapes(elarbol^.mayores,nom);
                eliminar_ds(elarbol,nom);
            end;
    end;
    
    
    
    
procedure eliminar_da(var elarbol:arbolusuarios; var puntusuario: arbolusuarios);
    var
        temp: arbolusuarios;
    begin
        if puntusuario^.nombre < elarbol^.nombre then
            begin
                eliminar_da(elarbol^.menores, puntusuario);
            end
        else
            if puntusuario^.nombre > elarbol^.nombre then
                begin
                    eliminar_da(elarbol^.mayores, puntusuario);
                end
            else
                begin
                    if elarbol^.menores = nil then
                        begin
                            temp := elarbol;
                            elarbol := elarbol^.mayores;
                            dispose(temp);
                        end
                    else
                        if elarbol^.mayores = nil then
                            begin
                                temp := elarbol;
                                elarbol := elarbol^.menores;
                                dispose(temp);
                            end
                        else
                            begin
                                temp := elarbol^.mayores;
                                while (temp <> nil) and (temp^.menores <> nil) do
                                    begin
                                        temp := temp^.menores;
                                    end;
                                if temp <> nil then
                                    begin
                                        if temp = elarbol then
                                            begin
                                                elarbol^.mayores := temp^.mayores;
                                                elarbol^.nombre := temp^.nombre;
                                                dispose(temp);
                                            end
                                        else
                                            begin
                                                elarbol^.nombre := temp^.nombre;
                                                eliminar_da(elarbol^.mayores, temp);
                                            end;
                                    end
                                else
                                    begin {si es hoja}
                                        temp := elarbol;
                                        elarbol := nil;
                                        dispose(temp);
                                    end;
                            end;
                end;
    end;

procedure eliminar_cuenta(var elarbol,puntusuario:arbolusuarios);
    var 
        nom:string;
    begin
        nom:=puntusuario^.nombre;
        eliminar_rapes(elarbol,nom);
        eliminar_hduae(puntusuario^.historias);
        eliminar_da(elarbol,puntusuario);
        writeln('tu cuenta ha sido eliminada');
    end;

 
procedure eliminar_seguido(var puntusuario:arbolusuarios);
    var 
        nombre_s:string;
    begin
        writeln('ingrese el nombre de usuario del seguido que quiera eliminar');
        readln(nombre_s);
        if rs(puntusuario,nombre_s) then
            begin
                eliminar_ds(puntusuario,nombre_s);
            end
        else
            begin
                writeln(nombre_s,' no forma parte de tus seguidos');
            end;
    end;
     
procedure accesousuario(var nombre:string;var elarbol:arbolusuarios);
    var        
        iacceso:integer;
        puntusuario:arbolusuarios;
    begin
        puntusuario:=ubicacionusuario(nombre,elarbol);
        iacceso:=0;
        while (iacceso<>7) and (iacceso<>6) do
            begin
                writeln('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
                writeln('_HOLA ',nombre);
                writeln('_ingrese 1 para mirar las historias de tus seguidos');
                writeln('_ingrese 2 para subir una historia');
                writeln('_ingrese 3 para mirar tus seguidos');
                writeln('_ingrese 4 para seguir a un nuevo usuario');
                writeln('_ingrese 5 para eliminar un usuario de mis seguidos');
                writeln('_ingrese 6 para eliminar mi cuenta');
                writeln('_ingrese 7 para cerrar sesion');
                writeln('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
                readln(iacceso);
                if iacceso=1 then
                    begin
                        ver_hs(puntusuario);
                    end;
                if iacceso=2 then
                    begin
                        agregar_historia(elarbol,puntusuario);
                    end;
                if iacceso=3 then
                    begin
                        mis_seguidos(elarbol,puntusuario);
                    end;
                if iacceso=4 then
                    begin
                        seguir_usuario(elarbol,puntusuario);
                    end;
                if iacceso=5 then
                    begin
                        eliminar_seguido(elarbol);
                    end;
            end;
        if iacceso=7 then
            begin
                writeln('###la sesion ha sido cerrada###');
            end;
        if iacceso=6 then
            begin
                eliminar_cuenta(elarbol,puntusuario);
            end;
    end;


function cantidadseguidos(elarbol:arbolusuarios):integer;
    var
        cantidad:integer;
        pseguidos:plistaseguidos;
    begin
        cantidad:=0;
        if elarbol^.seguidos<>nil then
            begin
                pseguidos:=elarbol^.seguidos;
                cantidad:=cantidad+1;
                while pseguidos^.sig<>nil do
                    begin
                        pseguidos:=pseguidos^.sig;
                        cantidad:=cantidad+1;
                    end;
                cantidadseguidos:=cantidad;
            end;
    end;



function totalseguidos(elarbol:arbolusuarios):integer;
    var total:integer;
    begin
        if elarbol=nil then
            begin
                totalseguidos:=0;    
            end
        else
            begin
                totalseguidos:=cantidadseguidos(elarbol)+totalseguidos(elarbol^.mayores)+totalseguidos(elarbol^.menores);
            end;
    end;

function cantidad_usuarios_reg(elarbol:arbolusuarios):integer;
    begin
        if  elarbol=nil then
            begin
                cantidad_usuarios_reg:=0;
            end
        else
            begin
              cantidad_usuarios_reg:=1+cantidad_usuarios_reg(elarbol^.menores)+cantidad_usuarios_reg(elarbol^.mayores);
            end;
    end;        

function promedio_seguidos(elarbol:arbolusuarios):real;
    var
        cantidad:real;
        total:real;
    begin
        cantidad:=cantidad_usuarios_reg(elarbol);
        total:=totalseguidos(elarbol);
        if cantidad_usuarios_reg(elarbol)<>0 then
            begin
                promedio_seguidos:=(total / cantidad);
            end;
    end;



procedure nuevousuario(var usuario,elarbol: arbolusuarios);
    begin
        new(usuario);
        writeln('ingrese nuevo nombre');
        readln(usuario^.nombre);
        while (existe(usuario^.nombre,elarbol)=true) do
            begin
                writeln('el nombre ingresado ya esta registrado, por favor ingrese otro nombre');
                readln(usuario^.nombre);
            end;
        writeln('ingrese nuevo password de 8 digitos');
        readln(usuario^.password);
        writeln('ingrese nuevo email');
        readln(usuario^.email);
        usuario^.seguidos:=nil;
        usuario^.historias:=nil;
        usuario^.menores:=nil;
        usuario^.mayores:=nil;
    end;

procedure insertarusuario(var elarbol,usuario:arbolusuarios);
    begin
        if elarbol=nil then
            begin
                elarbol:=usuario;
            end
        else
            begin
                if usuario^.nombre>elarbol^.nombre then
                    begin
                        insertarusuario(elarbol^.mayores,usuario);
                    end
                else
                    begin
                        insertarusuario(elarbol^.menores,usuario);
                    end;
            end;
      end;

procedure registrar_nuevo_usuario(var elarbol:arbolusuarios;var usuario:arbolusuarios);
    begin
        nuevousuario(usuario,elarbol);
        insertarusuario(elarbol,usuario);
    end;
   
procedure login(var elarbol:arbolusuarios);
    var
        nombre:string;
        password:string8;
    begin
        writeln('ingresar nombre de usuario');
        readln(nombre);
        writeln('ingresar contrasena');
        readln(password);
        if (verificarlogin(nombre,password,elarbol))then {ingreso a la cuenta}
            begin
                accesousuario(nombre,elarbol);
            end;
    end;

procedure menu(var elarbol :arbolusuarios);
    var
        i,imenu:integer;
        usuario:arbolusuarios;
        dias:string;
    begin
        imenu:=0;
        while imenu<>6 do
            begin
                writeln('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
                writeln('_ingrese 1 para iniciar sesion');
                writeln('_ingrese 2 para crear un nuevo usuario');
                writeln('_ingrese 3 para saber la cantidad total de usuarios registrados');
                writeln('_ingrese 4 para indicar el promedio de la cantidad de usuarios que siguen todos los usuarios');
                writeln('_ingrese 5 para saber que usuarios realizaron una historia en los ultimos x dias');
                writeln('_ingrese 6 para salir');
                writeln('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
                readln(imenu);
                 
                if imenu=1 then {iniciar sesion}
                    begin
                        login(elarbol);
                    end;
                if imenu=2 then {registrar nuevo usuario}
                    begin
                        registrar_nuevo_usuario(elarbol,usuario);
                    end;
                if imenu=3 then {usuarios registrados}
                    begin
                        writeln('la cantidad de usuarios registrados es:',cantidad_usuarios_reg(elarbol));
                    end;
                if imenu=4 then
                    begin
                        writeln('el promedio es:',promedio_seguidos(elarbol));
                    end;
                if imenu=5 then
                    begin
                        writeln('ingrese la cantidad de dias');
                        readln(dias);
                        usuarios_qsh(elarbol,dias);
                    end;
            end;

    end;
var
    elarbol: arbolusuarios;
    ausuarios:archusuarios;
    ahistorias:archhistorias;
    aseguidos:archseguidos;
    

begin
    
    assign(ausuarios,'archivousuariobenjamalegni.dat');
    assign(ahistorias,'archivohistoriasbenjamalegni.dat');
    assign(aseguidos,'archivoseguidosbenjamalegni.dat');		
    
    if (fileexists('archivousuariobenjamalegni.dat')) and (fileexists('archivohistoriasbenjamalegni.dat')) and (fileexists('archivoseguidosbenjamalegni.dat')) then
    begin
                reset(ausuarios);
                reset(aseguidos);
                reset(ahistorias);
    end;

    if (not fileexists('archivousuariobenjamalegni.dat')) and (not fileexists('archivohistoriasbenjamalegni.dat')) and (not fileexists('archivoseguidosbenjamalegni.dat')) then

		begin	
                rewrite(ausuarios);
                rewrite(aseguidos);
                rewrite(ahistorias);
		end;
    asg_arch(elarbol,ausuarios,ahistorias,aseguidos);
    //asignar archivos
    
    
	menu(elarbol);



				reset(ausuarios);
				reset(ahistorias);
				reset(aseguidos);
				
				
                act_arch(elarbol,ausuarios,ahistorias,aseguidos);
                close(ausuarios);
                close(aseguidos);
                close(ahistorias);
end.
