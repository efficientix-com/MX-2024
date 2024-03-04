/**
 * @NApiVersion 2.1
 * @NScriptType ClientScript
 * @NModuleScope SameAccount
 */
define(['N/record', '../../../Lib/fb_tp_const_lib.js', 'N/search', 'N/ui/dialog', 'N/runtime'],
    /**
     * @param{record} record
     */
    function (record, constLib, search, dialog, runtime) {
        /**
         * Function to be executed after page is initialized.
        *
        * @param {Object} scriptContext
        * @param {Record} scriptContext.currentRecord - Current form record
        * @param {string} scriptContext.mode - The mode in which the record is being accessed (create, copy, or edit)
        *
        * @since 2015.2
        */
        function pageInit(scriptContext) {
            console.log('Inicio');
        }

        /**
         * Function to be executed when field is changed.
        *
        * @param {Object} scriptContext
        * @param {Record} scriptContext.currentRecord - Current form record
        * @param {string} scriptContext.sublistId - Sublist name
        * @param {string} scriptContext.fieldId - Field name
        * @param {number} scriptContext.lineNum - Line number. Will be undefined if not a sublist or matrix field
        * @param {number} scriptContext.columnNum - Line number. Will be undefined if not a matrix field
        *
        * @since 2015.2
        */
        function fieldChanged(scriptContext) {
            try {
                const { CUSTOMER, SCRIPTS } = constLib
                if (scriptContext.fieldId == CUSTOMER.FIELDS.RAZON_SOCIAL) {
                    var recObj = scriptContext.currentRecord;
                    var mensaje = runtime.getCurrentScript().getParameter({name: SCRIPTS.RAZON_SOCIAL.PARAMETERS.MESSAGE});
                    var razon_social = recObj.getValue({ fieldId: CUSTOMER.FIELDS.RAZON_SOCIAL }).toLowerCase();
                    // console.log('razon social', razon_social );
                    razon = razon_social.replaceAll('.', '');
                    // console.log('razon sin puntos: ', razon );
                    var sociedades_mercantiles = getSociedadMercantil();
                    // console.log('datos de la busqueda: ', sociedades_mercantiles)
                    for (let posicion = 0; posicion < sociedades_mercantiles.length; posicion++) {
                        var soci = sociedades_mercantiles[posicion].toLowerCase()
                        soci = soci.replaceAll('.', '');
                        // console.log('sin puntos: ', soci);
                        // console.log('validacion: ', razon_social + ' contiene: ' + soci)
                        if (razon.includes(soci)) {
                            dialog.alert({
                                title: '¡WARNING!',
                                message: mensaje
                            });
                            break;
                        }
                    }

                }
            } catch (fieldChangedError) {
                console.error({ title: 'Error on fieldChanged', details: fieldChangedError })
            }
        }

        function getSociedadMercantil(){
            try {
                const { LISTAS, BUSQUEDAS } = constLib
                var sociedades = []
                var buscaSociedad = search.create({
                    type: LISTAS.SOCIEDADES_MERCANTILES,
                    filters: [],
                    columns: [
                        search.createColumn({ name: BUSQUEDAS.GETSOCIEDADMERCANTIL.COLUMNAS.NAME }),
                    ]
                });
                buscaSociedad.run().each(function (result) {
                    sociedades.push(result.getValue({ name: BUSQUEDAS.GETSOCIEDADMERCANTIL.COLUMNAS.NAME }) || "");
                    return true;
                });

                return sociedades
            } catch (errorGetSociedadMercantil) {
                console.error({title: 'error on getSociedadMercantil', errorGetSociedadMercantil})
            }

        }

        return {
            pageInit: pageInit,
            fieldChanged: fieldChanged
        };

    });
