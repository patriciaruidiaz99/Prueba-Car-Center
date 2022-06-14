prompt
prompt Creando TABLA CLIENTE
prompt   
   CREATE TABLE CLIENTE(     
      id_cliente                          NUMBER PRIMARY KEY NOT NULL,
      primer_nombre                       VARCHAR2(40) NOT NULL,
      segundo_nombre                      VARCHAR2(40),
      primer_apellido                     VARCHAR2(40) NOT NULL,
      segundo_apellido                    VARCHAR2(40),
      tipo_documento                      VARCHAR2(4) NOT NULL, 
      numero_documento                    NUMBER NOT NULL,    
      celular                             NUMBER NOT NULL,
      direccion                           VARCHAR2(100),
      correo                              VARCHAR2(100) NOT NULL
   );

prompt
prompt Creando TABLA VEHICULO
prompt 
   CREATE TABLE VEHICULO(     
      placa                         VARCHAR2(10) PRIMARY KEY NOT NULL,
      id_cliente                    NUMBER NOT NULL,      
      modelo                        NUMBER NOT NULL,
      clase                         VARCHAR2(10) NOT NULL,
      color                         VARCHAR2(30) NOT NULL,
      fotos                         CLOB,
      FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente)      
   );

prompt
prompt Creando TABLA MECANICO
prompt 
   CREATE TABLE MECANICO(     
      id_mecanico                         NUMBER PRIMARY KEY NOT NULL,
      primer_nombre                       VARCHAR2(40) NOT NULL,
      segundo_nombre                      VARCHAR2(40),
      primer_apellido                     VARCHAR2(40) NOT NULL,
      segundo_apellido                    VARCHAR2(40),
      tipo_documento                      VARCHAR2(4) NOT NULL,
      numero_documento                    NUMBER NOT NULL,     
      direccion                           VARCHAR2(100),
      correo                              VARCHAR2(100),
      celular                             NUMBER,
      estado                              VARCHAR2(10)
   );

prompt
prompt Creando TABLA MANTENIMIENTO
prompt
   CREATE TABLE MANTENIMIENTO(     
      id_mantenimiento                   NUMBER PRIMARY KEY NOT NULL,
      id_mecanico                        NUMBER NOT NULL,
      placa                              VARCHAR2(10) NOT NULL,
      estado                             VARCHAR2(10) NOT NULL,
      presupuesto                        NUMBER,
      id_cliente                         NUMBER,
      FOREIGN KEY (placa) REFERENCES VEHICULO  (placa),
      FOREIGN KEY (id_mecanico) REFERENCES MECANICO  (id_mecanico)      
   );

prompt
prompt Creando TABLA PRODUCTOS
prompt   
    CREATE TABLE PRODUCTOS(
      id_productos                     NUMBER PRIMARY KEY NOT NULL,
      tipo_producto                    VARCHAR2(20) NOT NULL,
      descripcion                      VARCHAR2(2000),
      valor_por_unidad                 NUMBER,
      descuento                        NUMBER,
      valor_maximo                     NUMBER,
      valor_minimo                     NUMBER,
      cantidad                         NUMBER
   );

prompt
prompt Creando TABLA COMPRA
prompt
    CREATE TABLE COMPRA(
      id_compra                        NUMBER PRIMARY KEY NOT NULL,
      id_mantenimiento                 NUMBER NOT NULL,
      id_productos                     NUMBER NOT NULL,
      cantidad                         NUMBER NOT NULL,
      valor_unitario                   NUMBER,
      total_valor                      NUMBER,      
      FOREIGN KEY (id_mantenimiento) REFERENCES MANTENIMIENTO (id_mantenimiento),
      FOREIGN KEY (id_productos) REFERENCES PRODUCTOS (id_productos)        
   );

prompt
prompt Creando TABLA FACTURA
prompt
   CREATE TABLE FACTURA(     
      id_factura                       NUMBER PRIMARY KEY NOT NULL,
      id_mantenimiento                 NUMBER NOT NULL,
      id_cliente                       NUMBER NOT NULL,
      placa                            VARCHAR2(10) NOT NULL,      
      id_mecanico                      NUMBER NOT NULL,
      subtotal                         NUMBER,
      impuestos                        NUMBER,
      valor_total                      NUMBER,
      fecha                            DATE,
      FOREIGN KEY (id_mantenimiento) REFERENCES MANTENIMIENTO (id_mantenimiento),
      FOREIGN KEY (id_cliente) REFERENCES CLIENTE (id_cliente),      
      FOREIGN KEY (placa) REFERENCES VEHICULO  (placa),
      FOREIGN KEY (id_mecanico) REFERENCES MECANICO  (id_mecanico)    
   );
   CREATE SEQUENCE sec_factura;

   prompt
   prompt Creando COMENTARIOS para la tabla CLIENTE
   prompt
   COMMENT ON TABLE    CLIENTE          IS 'Tabla pricipal cliente';                     
   COMMENT ON COLUMN   cliente.d_cliente       IS 'Llave primaria'; 
   COMMENT ON COLUMN   cliente.primer_nombre    IS 'Primer nombre del cliente';                      
   COMMENT ON COLUMN   cliente.segundo_nombre   IS 'Segundo nombre del cliente';                      
   COMMENT ON COLUMN   cliente.primer_apellido  IS 'Primer Apellido del cliente';                   
   COMMENT ON COLUMN   cliente.segundo_apellido IS 'Segundo apellido cliente';                   
   COMMENT ON COLUMN   cliente.tipo_documento   IS 'Tipo de documento puede CC,CE,NIT';                   
   COMMENT ON COLUMN   cliente.numero_documento IS 'Numero de documento';                      
   COMMENT ON COLUMN   cliente.celular          IS 'Celudar cliente';                     
   COMMENT ON COLUMN   cliente.direccion        IS 'Direccion cliente';                   
   COMMENT ON COLUMN   cliente.correo           IS 'Correo';  

   COMMENT ON TABLE    VEHICULO   IS 'Tabla principal vehiculo';   
   COMMENT ON COLUMN   vehiculo.placa      IS 'Placa del vehiculo';                      
   COMMENT ON COLUMN   vehiculo.id_cliente IS 'Llave foranea';                          
   COMMENT ON COLUMN   vehiculo.modelo     IS 'Modelo del vehiculo';                     
   COMMENT ON COLUMN   vehiculo.clase      IS 'clase del camioneta, comper';                   
   COMMENT ON COLUMN   vehiculo.color      IS 'Color vehiculo';                    
   COMMENT ON COLUMN   vehiculo.fotos      IS 'Cargue fotos';

   COMMENT ON TABLE    MECANICO           IS 'Tabla principal mecanico';
   COMMENT ON COLUMN   mecanico.id_mecanico        IS 'llave primaria';                
   COMMENT ON COLUMN   mecanico.primer_nombre      IS 'Primer nombre del cliente';                
   COMMENT ON COLUMN   mecanico.segundo_nombre     IS 'Segundo nombre del cliente';               
   COMMENT ON COLUMN   mecanico.primer_apellido    IS 'Primer Apellido del cliente';                
   COMMENT ON COLUMN   mecanico.segundo_apellido   IS 'Primer Apellido del cliente';               
   COMMENT ON COLUMN   mecanico.tipo_documento     IS 'Tipo de documento puede CC,CE,NIT';                
   COMMENT ON COLUMN   mecanico.numero_documento   IS 'Numero de documento';                     
   COMMENT ON COLUMN   mecanico.direccion          IS 'Direccion';                
   COMMENT ON COLUMN   mecanico.correo             IS 'Correo';               
   COMMENT ON COLUMN   mecanico.celular            IS 'Celular';                 
   COMMENT ON COLUMN   mecanico.estado             IS 'Estado'; 


   COMMENT ON TABLE    MANTENIMIENTO        IS 'Tabla principal mantenimiento';
   COMMENT ON COLUMN   mantenimiento.id_mantenimiento     IS 'llave primaria';            
   COMMENT ON COLUMN   mantenimiento.id_mecanico          IS 'llave foranea';             
   COMMENT ON COLUMN   mantenimiento.placa                IS 'Placas';              
   COMMENT ON COLUMN   mantenimiento.estado               IS 'Estado del mantenimiento TERMINADO,PROCESO';              
   COMMENT ON COLUMN   mantenimiento.presupuesto          IS 'Presupuesto del cliente';              
   COMMENT ON COLUMN   mantenimiento.id_cliente           IS 'llave foranea'; 

   COMMENT ON TABLE    PRODUCTOS            IS 'Tabla principal Productos';
   COMMENT ON COLUMN   productos.id_productos         IS 'id productos';           
   COMMENT ON COLUMN   productos.tipo_producto        IS 'Tipo de documento puede CC,CE,NIT';         
   COMMENT ON COLUMN   productos.descripcion          IS 'Descripciom';           
   COMMENT ON COLUMN   productos.valor_por_unidad     IS 'Valor de unidad';            
   COMMENT ON COLUMN   productos.descuento            IS 'Descuento';            
   COMMENT ON COLUMN   productos.valor_maximo         IS 'Valor a cobrar por servicio';           
   COMMENT ON COLUMN   productos.valor_minimo         IS 'valor minino a cobrar por servicio';           
   COMMENT ON COLUMN   productos.cantidad             IS 'Cantidad disponible'; 


   COMMENT ON TABLE    COMPRA              IS 'Tabla principal Compra';
   COMMENT ON COLUMN   compra.id_compra           IS 'id compra';            
   COMMENT ON COLUMN   compra.id_mantenimiento    IS 'llave foranea de la tabla mantemiento';            
   COMMENT ON COLUMN   compra.id_productos        IS 'Llave foranea de la tabla productos';           
   COMMENT ON COLUMN   compra.cantidad            IS 'Cantidad de la compra';            
   COMMENT ON COLUMN   compra.valor_unitario      IS 'Valor por unidad';            
   COMMENT ON COLUMN   compra.total_valor         IS 'Total compra';

   COMMENT ON TABLE  FACTURA               IS 'Tabla principal factura';
   COMMENT ON COLUMN   factura.id_factura          IS 'id factura';
   COMMENT ON COLUMN   factura.id_mantenimiento    IS 'id manteniemto de la tabla mantenimiento';
   COMMENT ON COLUMN   factura.id_cliente          IS 'id cliente de la tabla cliente';
   COMMENT ON COLUMN   factura.placa               IS 'placa';  
   COMMENT ON COLUMN   factura.id_mecanico         IS 'id de la tabla mecanico';
   COMMENT ON COLUMN   factura.subtotal            IS 'Subtotal';
   COMMENT ON COLUMN   factura.impuestos           IS 'Impuestos';
   COMMENT ON COLUMN   factura.valor_total         IS 'Valor total';
   COMMENT ON COLUMN   factura.fecha               IS 'fecha';                                               
















