CREATE OR REPLACE PACKAGE PK_CRUD_FACTURA IS
   TYPE ty_t_compra IS TABLE OF COMPRA%ROWTYPE INDEX BY BINARY_INTEGER;

   PROCEDURE pr_validar_factura( tipo_documento    IN    VARCHAR2,
                                 numero_documento  IN    NUMBER,
                                 error             OUT   VARCHAR2);

   PROCEDURE pr_totalizar_compra(Id_compra      IN    NUMBER,
                                 id_productos   IN    NUMBER, 
                                 cantidad       IN    NUMBER);

	PROCEDURE pr_generar_factura(r_manteni IN mantenimiento%ROWTYPE);

   PROCEDURE pr_imprimir_factura(r_manteni      mantenimiento%ROWTYPE,
                                 r_cliente      cliente%ROWTYPE,
                                 error          VARCHAR2);

END PK_CRUD_FACTURA;


CREATE OR REPLACE PACKAGE BODY PK_CRUD_FACTURA AS

   PROCEDURE pr_validar_factura( tipo_documento    IN    VARCHAR2,
                                 numero_documento  IN    NUMBER,
                                 error             OUT   VARCHAR2) IS

      CURSOR c_compra (p_id MANTENIMIENTO.id_mantenimiento%TYPE) IS
         SELECT * FROM COMPRA
            WHERE  id_mantenimiento = p_id;

      error_factura  EXCEPTION; 
      r_cliente      CLIENTE%ROWTYPE;
      r_manteni      MANTENIMIENTO%ROWTYPE;
      c_loop         BINARY_INTEGER := 1;
      t_compra       ty_t_compra;

      BEGIN

         IF tipo_documento IS NOT NULL AND numero_documento IS NOT NULL THEN

            pk_crud_car_center.pr_buscar_cliente(tipo_documento, numero_documento, r_cliente);                              
            IF r_cliente.id_cliente IS NULL THEN
               error := 'El cliente no se encuentra registrado en la base de datos';
               RAISE error_factura;
            END IF;

            EXECUTE IMMEDIATE ' SELECT * FROM MANTENIMIENTO'||
                              ' WHERE  id_cliente = '|| r_cliente.id_cliente||
                              ' AND estado = '||CHR(39)||'TERMINADO'||CHR(39) INTO  r_manteni;

            IF r_manteni.id_mantenimiento IS NULL THEN
               error := 'El cliente no se encuentra registrado en la base de datos';
               RAISE error_factura;
            END IF;

            t_compra.DELETE;
            FOR r_compra IN  c_compra(r_manteni.id_mantenimiento) LOOP
               pr_totalizar_compra(r_compra.id_compra,r_compra.id_productos, r_compra.cantidad);
               c_loop := c_loop +1;        
            END LOOP;
            pr_generar_factura(r_manteni);            
			   pr_imprimir_factura(r_manteni, r_cliente, error);
            COMMIT;
         ELSE
            error := 'Los datos suministrados estan incompletos. Por favor intente de nuevo.';
            RAISE error_factura;
         END IF;

      EXCEPTION
         WHEN error_factura THEN
            ROLLBACK;
            error := 'Se presento un error al generar la factura. '|| error;
         WHEN OTHERS THEN                   
         RAISE_APPLICATION_ERROR (-20000,'Se presento un error al generar la factura. '||SQLERRM);         
   END pr_validar_factura;

   PROCEDURE pr_totalizar_compra(Id_compra      IN    NUMBER,
                                 id_productos   IN    NUMBER, 
                                 cantidad       IN    NUMBER) IS

      valor_por_unidad     NUMBER;
      descuento            NUMBER;
      total_valor          NUMBER;
      BEGIN
         EXECUTE IMMEDIATE ' SELECT valor_por_unidad, descuento FROM PRODUCTOS'||
                           ' WHERE  id_productos = '||id_productos INTO  valor_por_unidad, descuento;
         total_valor := valor_por_unidad * cantidad;
         IF descuento > 0 THEN
				total_valor	:= total_valor - ((total_valor * descuento)/100);
		   END IF;
         pk_crud_car_center.pr_actualiza_inventario( id_productos, cantidad);         
         EXECUTE IMMEDIATE ' UPDATE COMPRA  SET valor_unitario = '||valor_por_unidad||',descuento= '||descuento||', total_valor='||total_valor||
                           ' WHERE id_compra = '||id_compra;
      EXCEPTION
         WHEN OTHERS THEN                   
         RAISE_APPLICATION_ERROR (-20000,'Se presento un error al totalizar la compra. '||SQLERRM);         
   END pr_totalizar_compra;

   PROCEDURE pr_generar_factura(r_manteni IN mantenimiento%ROWTYPE) IS

      id_factura     factura.id_factura%TYPE;   
      subtotal       factura.subtotal%TYPE;
      impuestos      factura.impuestos%TYPE;
      valor_total    factura.valor_total%TYPE;
      repuestos      NUMBER;
      BEGIN
         EXECUTE IMMEDIATE ' SELECT SUM(total_valor) FROM COMPRA WHERE id_mantenimiento = '||r_manteni.id_mantenimiento INTO  subtotal;
         EXECUTE IMMEDIATE ' SELECT SUM(c.total_valor) FROM compra c JOIN productos P ON p.id_productos = c.id_productos'||
                           ' WHERE p.tipo_producto= '||CHR(39)||'REPUESTO'||CHR(39)||
                           ' AND c.id_mantenimiento ='|| r_manteni.id_mantenimiento INTO repuestos;
         IF repuestos > 3000000 THEN
            EXECUTE IMMEDIATE ' SELECT SUM(c.total_valor) FROM compra c JOIN productos P ON p.id_productos = c.id_productos'||
                              ' WHERE p.tipo_producto= '||CHR(39)||'SERVICIO'||CHR(39)||
                              ' AND c.id_mantenimiento ='|| r_manteni.id_mantenimiento INTO repuestos;
            repuestos := (repuestos * 50)/ 100;
         END IF;
         impuestos   := subtotal * 0.19;
         valor_total := subtotal + NVL(impuestos,0);
         id_factura 	:= sec_factura.NEXTVAL;
         INSERT INTO factura(
            ID_FACTURA,
            ID_MANTENIMIENTO,
            ID_CLIENTE,
            PLACA,
            ID_MECANICO,
            SUBTOTAL,
            impuestos,
            valor_total,
			FECHA)
         VALUES(
            id_factura,
            r_manteni.id_mantenimiento,
            r_manteni.id_cliente,
            r_manteni.placa,
            r_manteni.id_mecanico,
            subtotal,
            impuestos,
            valor_total,
			   SYSDATE);
      EXCEPTION
         WHEN OTHERS THEN                   
         RAISE_APPLICATION_ERROR (-20000,'Se presento un error al totalizar la compra. '||SQLERRM);         
   END pr_generar_factura;

   PROCEDURE pr_imprimir_factura(r_manteni      mantenimiento%ROWTYPE,
                                 r_cliente      cliente%ROWTYPE,
                                 error          VARCHAR2) IS

      CURSOR c_compra (p_id MANTENIMIENTO.id_mantenimiento%TYPE, p_tipo VARCHAR2) IS
         SELECT C.* FROM compra c JOIN productos P ON p.id_productos = c.id_productos
         WHERE p.tipo_producto= p_tipo
         AND c.id_mantenimiento = p_id;

      valor_por_unidad     NUMBER;
      descuento            NUMBER;
      total_valor          NUMBER;
      c_loop         		BINARY_INTEGER := 1;
      t_compra             ty_t_compra;
      r_mecani 	      	mecanico%ROWTYPE;
      r_factura 	       	factura%ROWTYPE;
      error_factura        EXCEPTION; 

      BEGIN
         pk_crud_car_center.pr_buscar_mecan(r_manteni.id_mecanico, r_mecani);
         pk_crud_car_center.pr_buscar_factura(r_manteni.id_mantenimiento,r_factura);

         IF r_manteni.presupuesto > r_factura.valor_total OR r_manteni.presupuesto IS NULL THEN

            dbms_output.put_line('************CAR CENTER************');
            dbms_output.put_line('**********************************');
            dbms_output.put_line('CLIENTE___________________________');
            dbms_output.put_line('  '||r_cliente.primer_nombre||' '||
                                 r_cliente.segundo_nombre||' '||
                                 r_cliente.primer_apellido||' '||
                                 r_cliente.segundo_apellido);
            dbms_output.put_line('  '||r_cliente.tipo_documento||'-'||r_cliente.numero_documento);
            dbms_output.put_line('  '||r_cliente.celular||' '||r_cliente.direccion);
            dbms_output.put_line('  '||r_cliente.correo);
            dbms_output.put_line('MECANICO___________________________');                              
            dbms_output.put_line('  '||r_mecani.primer_nombre||' '||
                                 r_mecani.segundo_nombre||' '||
                                 r_mecani.primer_apellido||' '||
                                 r_mecani.segundo_apellido);
            dbms_output.put_line('  '||r_mecani.tipo_documento||'-'||r_mecani.numero_documento);
            dbms_output.put_line('  '||r_mecani.celular||' '||r_mecani.direccion);
            dbms_output.put_line('  '||r_mecani.correo||' ' ||r_mecani.estado);                              
            dbms_output.put_line('**********************************');
            dbms_output.put_line('REPUESTOS_________________________');
            dbms_output.put_line('  Cantidad\\  #  \\ Descuento      ');
            dbms_output.put_line('**********************************');
            t_compra.DELETE;
            FOR r_compra IN  c_compra(r_manteni.id_mantenimiento, 'REPUESTO') LOOP
               dbms_output.put_line('  '||r_compra.cantidad||'\\ '||r_compra.valor_unitario||'\\ '||r_compra.descuento);
               c_loop := c_loop +1;        
            END LOOP;
            dbms_output.put_line('**********************************');
            dbms_output.put_line('  SERVICIO');
            dbms_output.put_line('  Precio\\   Descuento            ');
            dbms_output.put_line('**********************************');         
            t_compra.DELETE;
            FOR r_compra IN  c_compra(r_manteni.id_mantenimiento, 'SERVICIO') LOOP
               dbms_output.put_line('  '||r_compra.total_valor||'\\   '||r_compra.descuento);
               c_loop := c_loop +1;
            END LOOP;
            dbms_output.put_line('__________________________________');
            dbms_output.put_line('  SUBTOTAL = '||r_factura.subtotal);
            dbms_output.put_line('  IVA = '||r_factura.impuestos);
            dbms_output.put_line('__________________________________');
            dbms_output.put_line('TOTAL = '||r_factura.valor_total);
            dbms_output.put_line('**********************************');
         ELSE
            RAISE error_factura;
         END IF;          
      EXCEPTION
         WHEN error_factura THEN
            ROLLBACK;
            --error := 'La factura no se puede generar ya que el presupuesto es menor al valor total del mantenimiento';
         WHEN OTHERS THEN                   
         RAISE_APPLICATION_ERROR (-20000,'Se presento un error al totalizar la compra. '||SQLERRM);         
   END pr_imprimir_factura;
END PK_CRUD_FACTURA;