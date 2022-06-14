SET SERVEROUTPUT ON;
--TATIANA PATRICIA RUIDIAZ PEDROZO BLOQUE DE PRUEBAS
DECLARE
    TIPO_DOCUMENTO      VARCHAR2(4) := 'CC';  -- Ingresar el tipo de documento: 'CC' - 'CE' - 'NIT'
    NUMERO_DOCUMENTO    NUMBER      := 108168563; -- Ingresar el nůmero del documento
    error               VARCHAR2(1000);
    
    r_cliente 	 	   cliente%ROWTYPE;
BEGIN    
    pk_crud_factura.pr_validar_factura(tipo_documento, numero_documento, error);
    IF error IS NOT NULL THEN
        dbms_output.put_line(error);
    END IF;
END;