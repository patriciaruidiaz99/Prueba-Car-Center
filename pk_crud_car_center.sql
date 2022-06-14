CREATE OR REPLACE PACKAGE pk_crud_car_center IS

	PROCEDURE pr_insertar_cliente(r_cliente   IN   cliente%ROWTYPE,
											v_error   	OUT  VARCHAR2);

	PROCEDURE pr_buscar_cliente(	tipo_doc 	IN		cliente.tipo_documento%TYPE,
											num_doc 		IN		cliente.numero_documento%TYPE,
											r_cliente 	OUT 	cliente%ROWTYPE);

  	PROCEDURE pr_buscar_mecan(	id_mecani 	IN 	mecanico.id_mecanico%TYPE,
										r_mecani 	OUT 	mecanico%ROWTYPE);

  	PROCEDURE pr_buscar_factura(	id_mantenimiento 	IN 	factura.id_mantenimiento%TYPE,
											r_factura 			OUT 	factura%ROWTYPE);

  	PROCEDURE pr_actualiza_inventario(  id_producto IN productos.id_productos%TYPE,
                                       cantidad    IN productos.id_productos%TYPE);

END pk_crud_car_center;


CREATE OR REPLACE PACKAGE BODY pk_crud_car_center AS

	/*-||13-JUN-2022(TPR)||----------------------------------------------+
	| Inserta cliente                                                 	|
	+--------------------------------------------------------------------*/

	PROCEDURE pr_insertar_cliente(r_cliente   IN   cliente%ROWTYPE,
											v_error   OUT  VARCHAR2)IS

	BEGIN

		INSERT INTO cliente(
					id_cliente,                        
					primer_nombre,                      
					segundo_nombre,                      
					primer_apellido,                    
					segundo_apellido,                    
					tipo_documento,                      
					numero_documento,                      
					celular,                          
					direccion,                          
					correo)
		VALUES(
					r_cliente.id_cliente,                        
					r_cliente.primer_nombre,                      
					r_cliente.segundo_nombre,                      
					r_cliente.primer_apellido,                    
					r_cliente.segundo_apellido,                    
					r_cliente.tipo_documento,                      
					r_cliente.numero_documento,                      
					r_cliente.celular,                          
					r_cliente.direccion,                          
					r_cliente.correo);

		EXCEPTION WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20000,'Error en pr_insertar_cliente * '||sqlerrm);
  	END pr_insertar_cliente;

	/*-||13-JUN-2022(TPR)||----------------------------------------------+
	| Buscar cliente                                                 		|
	+--------------------------------------------------------------------*/
  	PROCEDURE pr_buscar_cliente(	tipo_doc 	IN		cliente.tipo_documento%TYPE,
											num_doc 		IN		cliente.numero_documento%TYPE,
                               	r_cliente 	OUT 	cliente%ROWTYPE) IS

      CURSOR c_cliente( p_tipo_doc	cliente.tipo_documento%TYPE, 
								p_num_doc	cliente.numero_documento%TYPE) IS
			SELECT *
			FROM  cliente
			WHERE tipo_documento= p_tipo_doc
			AND	numero_documento = p_num_doc;

   BEGIN
      r_cliente := NULL;
      FOR r_c_cliente IN c_cliente(tipo_doc, num_doc) LOOP
         r_cliente := r_c_cliente;
      END LOOP;

		EXCEPTION WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20000,'Error en pr_buscar_cliente '||SQLERRM);
	END pr_buscar_cliente;

	/*-||13-JUN-2022(TPR)||----------------------------------------------+
	| Buscar mecanico por id                                         		|
	+--------------------------------------------------------------------*/
  	PROCEDURE pr_buscar_mecan(	id_mecani 	IN 	mecanico.id_mecanico%TYPE,
										r_mecani 	OUT 	mecanico%ROWTYPE) IS

      CURSOR c_mecani( p_id_mecani  	mecanico.id_mecanico%TYPE) IS
			SELECT *
			FROM  mecanico
			WHERE id_mecanico=p_id_mecani;

   BEGIN
      r_mecani := NULL;
      FOR r_c_mecani IN c_mecani(id_mecani) LOOP
         r_mecani := r_c_mecani;
      END LOOP;

		EXCEPTION WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20000,'Error en pr_buscar_mecan '||SQLERRM);
	END pr_buscar_mecan;

	/*-||13-JUN-2022(TPR)||----------------------------------------------+
	| Buscar LA FACTURA generada para un mantenimiento              		|
	+--------------------------------------------------------------------*/
  	PROCEDURE pr_buscar_factura(	id_mantenimiento 	IN 	factura.id_mantenimiento%TYPE,
											r_factura 			OUT 	factura%ROWTYPE) IS

      CURSOR c_factura( p_id_mantenimiento  	factura.id_mantenimiento%TYPE) IS
			SELECT *
			FROM  factura
			WHERE id_mantenimiento=p_id_mantenimiento;

   BEGIN
      r_factura := NULL;
      FOR r_c_factura IN c_factura(id_mantenimiento) LOOP
         r_factura := r_c_factura;
      END LOOP;

		EXCEPTION WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20000,'Error en pr_buscar_factura '||SQLERRM);
	END pr_buscar_factura;

	/*-||13-JUN-2022(TPR)||----------------------------------------------+
	| Actualiza el inventario de productos existente en tienda           |
	+--------------------------------------------------------------------*/
  	PROCEDURE pr_actualiza_inventario(  id_producto IN productos.id_productos%TYPE,
                                       cantidad    IN productos.id_productos%TYPE) IS
      query       CLOB;
      cant_actual NUMBER;
   BEGIN
      EXECUTE IMMEDIATE ' SELECT cantidad FROM productos WHERE  id_productos = '||id_producto INTO cant_actual;
      cant_actual := cant_actual - cantidad;
      EXECUTE IMMEDIATE ' UPDATE productos SET cantidad='||cant_actual||' WHERE id_productos = '||id_producto;

		EXCEPTION WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20000,'Error en pr_actualiza_inventario '||SQLERRM);
	END pr_actualiza_inventario;

END pk_crud_car_center;