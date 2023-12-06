program instapas;

uses
    sysutils;
    
type
    punt_seguidos = ^listaseguidos;
    punt_usuarios = ^listausuarios;
    punt_historias = ^listahistorias;
        
    listahistorias = record
        fecha_hora: string;
        texto: string;
        sig: punt_historias
        end;

    listaseguidos = record
        seguido: punt_usuarios;
        sig: punt_seguidos
        end;

    listausuarios = record
        nombre: string[15];
        password: string[8];
        email: string[64];
        seguidos: punt_seguidos;
        historias: punt_historias;
        sig: punt_usuarios;
        ant: punt_usuarios
        end;
        
    reg_usuarios = record
        nombre: string[15];
        password: string[8];
        email: string[64];
        end;
        
    reg_historias = record
        nombre: string[15];
        fecha_hora: string[19];
        texto: string;
        end;
        
    reg_seguidos = record
        seguidor: string[15];
        seguido: string[15]
        end;
        
    tipoarchusuarios = file of reg_usuarios;
    tipoarchhistorias = file of reg_historias;
    tipoarchseguidos = file of reg_seguidos;
    
procedure ActualizarArchivos( var ArbUsuarios: punt_usuarios; var archusuarios: tipoarchusuarios; var archhistorias: tipoarchhistorias; var archseguidos: tipoarchseguidos);
var
    datos_usuario: reg_usuarios;
    datos_historias: reg_historias;
    datos_seguidos: reg_seguidos;
    arb_historias: punt_historias;
    arb_seguidos: punt_seguidos;

begin
    if ArbUsuarios <> nil then
        begin
            writeln('< Guardando información del usuario >');
            //se copian los datos del usuario.
            datos_usuario.nombre:= ArbUsuarios^.nombre;
            datos_usuario.password:= ArbUsuarios^.password;
            datos_usuario.email:= ArbUsuarios^.email;
            write(archusuarios, datos_usuario);
            //Mostrando en pantalla.
            writeln('usuario: ', datos_usuario.nombre);
            writeln('password: ', datos_usuario.password);
            writeln('email: ', datos_usuario.email);
            writeln;
            //se copian las historias del usuario.
            arb_historias:= ArbUsuarios^.historias;
            while arb_historias <> nil do
                begin
                    datos_historias.nombre:= ArbUsuarios^.nombre;
                    datos_historias.fecha_hora:= arb_historias^.fecha_hora;
                    datos_historias.texto:= arb_historias^.texto;
                    write(archhistorias, datos_historias);
                    //mostrando en pantalla.
                    writeln('[', datos_historias.fecha_hora, '] de ', datos_historias.nombre, ': ', datos_historias.texto);
                    writeln;
                    arb_historias:= arb_historias^.sig;
                end;
            //se copian los seguidos del usuario.
            arb_seguidos:= ArbUsuarios^.seguidos;
            while arb_seguidos <> nil do
                begin
                    datos_seguidos.seguido:= arb_seguidos^.seguido^.nombre;
                    datos_seguidos.seguidor:= ArbUsuarios^.nombre;
                    write(archseguidos, datos_seguidos);
                    //mostrando en pantalla.
                    writeln(datos_seguidos.seguidor, ' sigue a ', datos_seguidos.seguido);
                    writeln;
                    arb_seguidos:= arb_seguidos^.sig;
                end;
            //se retipe lo mismo para los hijos del nodo.
            ActualizarArchivos(ArbUsuarios^.ant, archusuarios, archhistorias, archseguidos);
            ActualizarArchivos(ArbUsuarios^.sig, archusuarios, archhistorias, archseguidos);
        end;
end;

procedure Seguir( var miusuario, usuario: punt_usuarios);
var
    nuevo, anterior, seguidos: punt_seguidos;
    
begin
    new(nuevo);
    nuevo^.seguido:= usuario;
    nuevo^.sig:= nil;
    if miusuario^.seguidos = nil then
        begin
            writeln('< Usuario Seguido >');
            miusuario^.seguidos:= nuevo;
        end
    else
        begin
            seguidos:= miusuario^.seguidos;
            anterior:= nil;
            while (seguidos <> nil) and (seguidos^.seguido^.nombre < nuevo^.seguido^.nombre ) do
                begin
                    anterior:= seguidos;
                    seguidos:= seguidos^.sig;
                end;
            if seguidos <> nil then
                begin
                    if nuevo^.seguido^.nombre = seguidos^.seguido^.nombre then
                        writeln('< Ya sigues a este usuario >')
                    else
                        begin
                            nuevo^.sig:=seguidos;
                            if anterior <> nil then
                                anterior^.sig:= nuevo
                            else
                                miusuario^.seguidos:= nuevo;
                            writeln('< Usuario Seguido >');
                        end;
                end
            else
                begin
                    nuevo^.sig:= seguidos;
                    anterior^.sig:= nuevo;
                    writeln('< Usuario Seguido >');
                end;
        end;
end;

Procedure ListarSeguidos( miusuario: punt_usuarios);
var
    seguidos: punt_seguidos;
    n: integer;
    
begin
    n:= 0;
    seguidos:= miusuario^.seguidos;
    if seguidos <> nil then
        begin
            while seguidos <> nil do
                begin
                    n:= n + 1;
                    writeln(n, ' < ', seguidos^.seguido^.nombre, ' > ');
                    seguidos:= seguidos^.sig;
                end;
        end
    else
        writeln('< Lista vacía >');
end;

procedure EliminarSeguido( var miusuario, usuario: punt_usuarios; mostrar_comentarios: boolean);
var
    anterior, seguidos: punt_seguidos;
    
begin
    if miusuario^.seguidos = nil then
        begin
            if mostrar_comentarios then
                writeln('< No sigues a este usuario >');
        end
    else
        begin
            seguidos:= miusuario^.seguidos;
            anterior:= nil;
            while (seguidos <> nil) and (seguidos^.seguido^.nombre < usuario^.nombre ) do
                begin
                    anterior:= seguidos;
                    seguidos:= seguidos^.sig;
                end;
            if seguidos <> nil then
                if seguidos^.seguido^.nombre = usuario^.nombre then
                    begin
                        if anterior <> nil then
                            anterior^.sig:= seguidos^.sig
                        else
                            miusuario^.seguidos:= seguidos^.sig;
                        dispose(seguidos);
                    end
                else
                    begin
                        if mostrar_comentarios then
                            writeln('< No sigues a este usuario >');
                    end
            else
                begin
                    if mostrar_comentarios then
                        writeln('< No sigues a este usuario >');
                end;
        end;
end;



procedure VerHistoriasSeguidosULtDias( var nodo: punt_usuarios; fecha_limite: string);
var
    historias: punt_historias;

begin
    if nodo <> nil then
        begin
            VerHistoriasSeguidosULtDias(nodo^.ant, fecha_limite);
            historias:= nodo^.historias;
            while (historias <> nil) and (historias^.fecha_hora < fecha_limite) do
                historias:= historias^.sig;
            if historias <> nil then
                begin
                    while (historias <> nil) do
                        begin
                            write('< ', nodo^.nombre, ' ');
                            write(historias^.fecha_hora,' ');
                            writeln(historias^.texto,' >');
                            historias:= historias^.sig;
                        end;
                end;
            VerHistoriasSeguidosULtDias(nodo^.sig, fecha_limite);
        end;
end;

procedure CrearHistoria( var miusuario: punt_usuarios);
var
    historia, ult_pos: punt_historias;
    texto: string;

begin
    write('> Historia de (', miusuario^.nombre, '): ');
    readln(texto);
    new(historia);
    historia^.texto:= texto;
    historia^.fecha_hora:= DateTimeToStr(Now);
    historia^.sig:= nil;
    if miusuario^.historias = nil then
        miusuario^.historias:= historia
    else
        begin
            ult_pos:= miusuario^.historias;
            while ult_pos^.sig <> nil do
                ult_pos:= ult_pos^.sig;
            ult_pos^.sig:= historia;
        end;
end;

procedure BuscarSeguidores(var ArbUsuarios: punt_usuarios; miusuario: punt_usuarios);
var
    mostrar_comentarios: boolean;
    
begin
    mostrar_comentarios:= false;
    if ArbUsuarios <> nil then
        begin
            if ArbUsuarios^.seguidos <> nil then
                EliminarSeguido(Arbusuarios, miusuario, mostrar_comentarios);
            BuscarSeguidores(ArbUsuarios^.ant, miusuario);
            BuscarSeguidores(ArbUsuarios^.sig, miusuario);
        end;
end;

procedure EliminarListaSeguidos(var seguidos: punt_seguidos);
    
begin
    if seguidos <> nil then
        begin
            EliminarListaSeguidos(seguidos^.sig);
            dispose(seguidos);
        end;
end;

procedure EliminarListaHistorias(var historias: punt_historias);

begin
    if historias <> nil then
        begin
            EliminarListaHistorias(historias^.sig);
            dispose(historias);
        end;
end;

procedure EliminarUsuario(var ArbUsuarios, miusuario: punt_usuarios);
//Este procedimiento elimina al usuario del arbol.
var
    eliminar, sucesor: punt_usuarios;
    
begin
    if miusuario^.ant = nil then
        begin
            eliminar:= miusuario;
            miusuario:= miusuario^.sig;
            dispose(eliminar);
        end
    else
        if miusuario^.sig = nil then
            begin
                eliminar:= miusuario;
                miusuario:= miusuario^.ant;
                dispose(eliminar);
            end
        else
            begin
                sucesor:= miusuario^.sig;
                while sucesor^.ant <> nil do
                    sucesor:= sucesor^.ant;
                miusuario^.nombre:= sucesor^.nombre;
                miusuario^.email:= sucesor^.email;
                miusuario^.password:= sucesor^.password;
                EliminarUsuario(miusuario^.sig, sucesor);
            end;
end;

function ExisteUsuario( var nodo: punt_usuarios; datos: reg_usuarios): boolean;
//Este procedimiento devuelve true si existe el usuario buscado o false si no existe.
begin
    if nodo <> nil then
        if  datos.nombre < nodo^.nombre then
            ExisteUsuario:= ExisteUsuario(nodo^.ant,  datos)
        else
            if datos.nombre > nodo^.nombre then
                ExisteUsuario:= ExisteUsuario(nodo^.sig,  datos)
            else
                ExisteUsuario:= true
    else
        ExisteUsuario:= false;
end;

function ObtenerPunteroUsuario( var nodo: punt_usuarios; datos: reg_usuarios): punt_usuarios;
//Esta función devuelve un puntero con la ubicacion del usuario buscado, si no la encuentra, el resultado es nil.
begin
    if nodo <> nil then
        if datos.nombre < nodo^.nombre then
            ObtenerPunteroUsuario:= ObtenerPunteroUsuario(nodo^.ant, datos)
        else
            if datos.nombre > nodo^.nombre then
                ObtenerPunteroUsuario:= ObtenerPunteroUsuario(nodo^.sig, datos)
            else
                ObtenerPunteroUsuario:= nodo
    else
        ObtenerPunteroUsuario:= nil;
end;

procedure Login( var ArbUsuarios: punt_usuarios; var archusuarios: tipoarchusuarios; var archhistorias: tipoarchhistorias; var archseguidos: tipoarchseguidos); forward;

procedure Menu( var ArbUsuarios, miusuario: punt_usuarios; var archusuarios: tipoarchusuarios; var archhistorias: tipoarchhistorias; var archseguidos: tipoarchseguidos);
var
    opcion: integer;
    limite_dias: integer;
    datos: reg_usuarios;
    mostrar_comentarios: boolean;
    usuario: punt_usuarios;
    historias: punt_historias;
    seguidos: punt_seguidos;
    
begin
    writeln('');
    writeln('Menu Principal');
    writeln('1 ver las historias de los últimos días');
    writeln('2 Escribir una historia');
    writeln('3 Listar seguidos');
    writeln('4 Seguir a un usuario');
    writeln('5 Eliminar a un seguido');
    writeln('6 Borrar mi usuario');
    writeln('7 Salir');
    write('> Elija una opción ');
    readln(opcion);
    if opcion = 1 then
        begin
            write('> Limite (días) ');
            readln(limite_dias);
            VerHistoriasSeguidosULtDias(ArbUsuarios, DateTimeToStr(Now - limite_dias));
            Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
        end
    else
        if opcion = 2 then
            begin
                CrearHistoria(miusuario);
                Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
            end
        else
            if opcion = 3 then
                begin
                    ListarSeguidos(miusuario);
                    Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                end
            else
                if opcion = 4 then
                    begin
                        write('> Usuario ');
                        readln(datos.nombre);
                        if datos.nombre <> miusuario^.nombre then
                            if ExisteUsuario(ArbUsuarios, datos) then
                                begin
                                    usuario:= ObtenerPunteroUsuario(ArbUsuarios, datos);
                                    Seguir(miusuario, usuario);
                                    Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                end
                            else
                                begin
                                writeln('< Usuario inexistente >');
                                Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                end
                        else
                            begin
                                writeln('< No te puedes seguir a ti mismo >');
                                Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                            end;
                    end
                else
                    if opcion = 5 then
                        begin
                            write('> Usuario ');
                            readln(datos.nombre);
                            if datos.nombre <> miusuario^.nombre then
                                if ExisteUsuario(ArbUsuarios, datos) then
                                    begin
                                        usuario:= ObtenerPunteroUsuario(ArbUsuarios, datos);
                                        mostrar_comentarios:= true;
                                        EliminarSeguido(miusuario, usuario, mostrar_comentarios);
                                        Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                    end
                                else
                                    begin
                                    writeln('< Usuario inexistente >');
                                    Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                    end
                            else
                                begin
                                    writeln('< No te puedes eliminar a ti mismo >');
                                    Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                end;
                        end
                    else
                        if opcion = 6 then
                            begin
                                BuscarSeguidores(ArbUsuarios, miusuario);
                                 //proceso para eliminar la lista de historias.
                                if miusuario^.historias <> nil then
                                    begin
                                        historias:= miusuario^.historias;
                                        EliminarListaHistorias(historias);
                                        miusuario^.historias:= nil;
                                    end;
                                //proceso para eliminar la lista de seguidos.
                                if miusuario^.seguidos <> nil then
                                    begin 
                                        seguidos:= miusuario^.seguidos;
                                        EliminarListaSeguidos(seguidos);
                                        miusuario^.seguidos:= nil;
                                    end;
                                EliminarUsuario(ArbUsuarios, miusuario);
                                rewrite(archusuarios);
                                rewrite(archhistorias);
                                rewrite(archseguidos);
                                ActualizarArchivos(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                                close(archusuarios);
                                close(archhistorias);
                                close(archseguidos);
                                writeln(' < Información actualizada > ');
                                Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                            end
                        else
                            if opcion = 7 then
                                begin
                                    writeln('< Sesión terminada >');
                                    rewrite(archusuarios);
                                    rewrite(archhistorias);
                                    rewrite(archseguidos);
                                    ActualizarArchivos(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                                    close(archusuarios);
                                    close(archhistorias);
                                    close(archseguidos);
                                    writeln(' < Información actualizada > ');
                                    Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                                end
                            else
                                begin
                                    Menu(ArbUsuarios, miusuario, archusuarios, archhistorias, archseguidos);
                                end;
end;

procedure UsuariosHistoriasUltDias(var nodo: punt_usuarios; fecha_limite: String);
//Este procedimieto imprime una lista de todos los usuarios que publicaron en despues de la fecha establecida.
var
    historias: punt_historias;

begin
    if nodo <> nil then
        begin
            historias:= nodo^.historias;
            while (historias <> nil) and (historias^.fecha_hora < fecha_limite) do
                historias:= historias^.sig;
            if historias <> nil then
                writeln(' < ', nodo^.nombre, ' > ');
            UsuariosHistoriasUltDias(nodo^.ant, fecha_limite);
            UsuariosHistoriasUltDias(nodo^.sig, fecha_limite);
        end;
end;

function TotalUsuarios( var ArbUsuarios: punt_usuarios): integer;
//Este procedimiento devuelve le total de usuarios registrados en Instapos.
begin
    if ArbUsuarios <> nil then
        TotalUsuarios:= 1 + TotalUsuarios(ArbUsuarios^.ant) + TotalUsuarios(ArbUsuarios^.sig)
    else
        TotalUsuarios:= 0;
end;

function CantSeguidos( var seguidos: punt_seguidos): real;
    
begin
    if seguidos <> nil then
        CantSeguidos:= 1 + CantSeguidos(seguidos^.sig)
    else
        CantSeguidos:= 0;
end;

function PromedioSeguidos( var usuarios: punt_usuarios): real;
    
begin
    if usuarios <> nil then
        PromedioSeguidos := CantSeguidos(usuarios^.seguidos) + PromedioSeguidos(usuarios^.ant) + PromedioSeguidos(usuarios^.sig)
    else
        PromedioSeguidos := 0;
end;

procedure CrearUsuario( var nuevo_usuario: punt_usuarios; datos: reg_usuarios);
    
begin
    if nuevo_usuario <> nil then
        if datos.nombre < nuevo_usuario^.nombre then
            CrearUsuario(nuevo_usuario^.ant, datos)
        else
            CrearUsuario(nuevo_usuario^.sig, datos)
    else
        begin
            new(nuevo_usuario);
            nuevo_usuario^.nombre:= datos.nombre;
            nuevo_usuario^.email:= datos.email;
            nuevo_usuario^.password:= datos.password;
            nuevo_usuario^.seguidos:= nil;
            nuevo_usuario^.historias:= nil;
            nuevo_usuario^.sig:= nil;
            nuevo_usuario^.ant:= nil;
        end;
end;

function PasswordValida(usuarios: punt_usuarios; datos: reg_usuarios): boolean;
var
    usuario: punt_usuarios;

begin
    usuario:= ObtenerPunteroUsuario(usuarios, datos);
    if datos.password = usuario^.password then
        PasswordValida:= true
    else
        PasswordValida:= false;
end;
    
procedure Login( var ArbUsuarios: punt_usuarios; var archusuarios: tipoarchusuarios; var archhistorias: tipoarchhistorias; var archseguidos: tipoarchseguidos);
//nota: de momento, cada vez que se comete un error, se vuele al menú principal.
var
    opcion: integer;
    usuario: punt_usuarios;
    limite_dias: integer;
    datos: reg_usuarios;
    password_2: string[8];
    
begin
    writeln;
    writeln('¡Bienvenido a InstaPas!');
    writeln('1 Ingresar');
    writeln('2 Registrarse');
    writeln('3 Cantidad de Usuarios');
    writeln('4 Promedio de seguidos');
    writeln('5 Usuarios que publicaron en los últimos días');
    writeln('6 Salir');
    write('> Elija una opción ');
    readln(opcion);
    if opcion = 1 then
        begin
            write('> Usuario ');
            readln(datos.nombre);
            write('> Contraseña ');
            readln(datos.password);
            if ExisteUsuario(ArbUsuarios, datos) and PasswordValida(ArbUsuarios, datos) then
                begin
                    writeln('< Sesión Iniciada >');
                    usuario := ObtenerPunteroUsuario(ArbUsuarios, datos);
                    Menu(ArbUsuarios, usuario, archusuarios, archhistorias, archseguidos);
                end
            else
                begin
                    writeln('¡USUARIO Y/O CONTRASEÑA INCORRECTOS!');
                    Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                end;
        end
    else
        if opcion = 2 then
            begin
                write('> Usuario ');
                readln(datos.nombre);
                if not ExisteUsuario(ArbUsuarios, datos) then
                    begin
                        write('> Email ');
                        readln(datos.email);
                        write('> Contraseña ');
                        readln(datos.password);
                        write('> Ingrese nuevamente ');
                        readln(password_2);
                        if datos.password = password_2 then
                            begin
                                CrearUsuario(ArbUsuarios, datos);
                                writeln('< Usuario Creado > ');
                                Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                            end
                        else
                            begin
                                writeln('¡NO COINCIDEN LAS CONTRASEÑAS!');
                                Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                            end;
                    end
                else
                    begin
                        writeln('¡USUARIO NO DISPONIBLE!');
                        Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                    end;
            end
        else
            if opcion = 3 then
                begin
                    writeln('< ', TotalUsuarios(ArbUsuarios), ' usuarios >');
                    Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                end
            else
                if opcion = 4 then
                    begin
                        if TotalUsuarios(ArbUsuarios) <> 0 then
                            writeln('< ', (PromedioSeguidos(ArbUsuarios) / TotalUsuarios(ArbUsuarios)):0:1, ' promedio de seguidos por cada usuario >')
                        else
                            writeln('¡NO HAY USUARIOS REGISTRADOS!');
                        Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                    end
                else
                    if opcion = 5 then
                        begin
                            write('> Limite (días) ');
                            readln(limite_dias);
                            UsuariosHistoriasUltDias(ArbUsuarios, DateTimeToStr(Now - limite_dias));
                            Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                        end
                    else
                        if opcion = 6 then
                            begin
                                rewrite(archusuarios);
                                rewrite(archhistorias);
                                rewrite(archseguidos);
                                ActualizarArchivos(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                                close(archusuarios);
                                close(archhistorias);
                                close(archseguidos);
                                writeln(' < Información actualizada > ');
                            end
                        else
                            begin
                                writeln('¡OPCIÓN INCORRECTA!');
                                Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
                            end;
end;

procedure CargarArbolHistorias(var usuarios: punt_usuarios; datos: reg_historias);
//Este procedimiento carga las historias de todos los usuarios.
var
    historia: punt_historias;
    
begin
    if usuarios <> nil then
        if datos.nombre < usuarios^.nombre then
            CargarArbolHistorias(usuarios^.ant, datos)
        else
            if datos.nombre > usuarios^.nombre then
                CargarArbolHistorias(usuarios^.sig, datos)
            else //se encontro el usuario.
                begin
                    historia:= usuarios^.historias;
                    while historia <> nil do
                        historia := historia^.sig;
                    new(historia);
                    historia^.fecha_hora := datos.fecha_hora;
                    historia^.texto := datos.texto;
                    historia^.sig := nil;
                end;
end;

function ObtenerPuntSeguido( var usuarios: punt_usuarios; seguidos: reg_seguidos): punt_usuarios;
//Esta función devuelve el puntero al seguido por el usuario actual.
begin
    if usuarios <> nil then
        if usuarios^.nombre > seguidos.seguido then
            ObtenerPuntSeguido := ObtenerPuntSeguido (usuarios^.ant, seguidos)
        else
            if usuarios^.nombre < seguidos.seguido then
                ObtenerPuntSeguido := ObtenerPuntSeguido (usuarios^.sig, seguidos)
            else //se encontro el seguidor.
                ObtenerPuntSeguido := usuarios
    else
        ObtenerPuntSeguido:= nil;
end;

procedure CargarArbolSeguidos( var usuarios: punt_usuarios; usuario: punt_usuarios; seguidos: reg_seguidos);
//Este procedimiento carga las listas de seguidos de todos los usuarios.
begin
    if usuarios <> nil then
        if usuarios^.nombre > seguidos.seguidor then
            CargarArbolSeguidos(usuarios^.ant, usuario, seguidos)
        else
            if usuarios^.nombre < seguidos.seguidor then
                CargarArbolSeguidos(usuarios^.sig, usuario, seguidos)
            else
                begin
                    while usuarios^.seguidos <> nil do
                        usuarios^.seguidos := usuarios^.seguidos^.sig;
                    new(usuarios^.seguidos);
                    usuarios^.seguidos^.seguido := usuario;
                    usuarios^.seguidos^.sig := nil;
                end;
end;

procedure CargarArbolUsuarios( var usuarios: punt_usuarios; var usuario: tipoarchusuarios);
//Este procedimiento carga los usuarios en el arbol en Preorden, ascendentemente ordenados por nombre de usuario.
var
    datos_usuario: reg_usuarios;

begin
    if not eof(usuario) then
        begin
            read(usuario, datos_usuario);
            new(usuarios);
            usuarios^.nombre := datos_usuario.nombre;
            usuarios^.password := datos_usuario.password;
            usuarios^.email := datos_usuario.email;
            usuarios^.historias := nil;
            usuarios^.seguidos := nil;
            usuarios^.sig := nil;
            usuarios^.ant := nil;
            CargarArbolUsuarios(usuarios^.ant, usuario);
            CargarArbolUsuarios(usuarios^.sig, usuario);
        end;
end;

procedure ProcesarArchivos( var ArbUsuarios: punt_usuarios; var archusuarios: tipoarchusuarios; var archhistorias: tipoarchhistorias; var archseguidos: tipoarchseguidos);
//Este procedimiento se encarga de cargar y ordenar el arbol de usuarios.
var
    historias: reg_historias;
    seguidos: reg_seguidos;

begin
    //Se leen los archivos.
    assign(archusuarios, 'ArchivoUsuariosInstaPosTobiasMrtnlch.dat');
    assign(archhistorias, 'ArchivoHistoriasInstaPosTobiasMrtnlch.dat');
    assign(archseguidos, 'ArchivoSeguidosInstaPosTobiasMrtnlch.dat');
    //Se verifican si existen los archivos.
    if FileExists('ArchivoUsuariosInstaPosTobiasMrtnlch.dat') then
        reset(archusuarios)
    else
        rewrite(archusuarios);
    if FileExists('ArchivoHistoriasInstaPosTobiasMrtnlch.dat') then
        reset(archhistorias)
    else
        rewrite(archhistorias);
    if FileExists('ArchivoSeguidosInstaPosTobiasMrtnlch.dat') then
        reset(archseguidos)
    else
        rewrite(archseguidos);
    //Se cargan los datos de los  archivos al arbol de usuarios.
   CargarArbolUsuarios(ArbUsuarios, archusuarios);
    while not eof(archhistorias) do
        begin
            read(archhistorias, historias);
            CargarArbolHistorias(ArbUsuarios, historias);
        end;
    while not eof(archseguidos) do
        begin
            read(archseguidos, seguidos);
            
            CargarArbolSeguidos(ArbUsuarios, ObtenerPuntSeguido(ArbUsuarios, seguidos), seguidos);
        end;
    //Se cierran los archivos.
    Close(archusuarios); 
    Close(archhistorias);
    Close(archseguidos);
end;

var
    archusuarios: tipoarchusuarios;
    archhistorias: tipoarchhistorias;
    archseguidos: tipoarchseguidos;
    ArbUsuarios, ArbUsuarios_2: punt_usuarios;

begin
    writeln(DateTimeToStr(Now));
    ProcesarArchivos(ArbUsuarios, archusuarios, archhistorias, archseguidos);
    Login(ArbUsuarios, archusuarios, archhistorias, archseguidos);
    writeln('<segunda sesión de prueba para carga de archivos>');
    Login(ArbUsuarios_2, archusuarios, archhistorias, archseguidos);
    writeln('< Programa terminado. >.');
end.
