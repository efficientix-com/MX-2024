/**
 * @NApiVersion 2.1
 * @NScriptType ClientScript
 * @NModuleScope SameAccount
 */
define(['N/runtime', '../../../Lib/fb_tp_const_lib.js', 'N/ui/message', 'N/url', 'N/https', 'N/ui/dialog'],
/**
 * @param{https} https
 */
function(runtime, constLib, mensajes, url, https, dialog) {

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
        var myMsg_create = mensajes.create({
            title: "Mensaje",
            message: "Mensaje chido...",
            type: mensajes.Type.INFORMATION
        });
        myMsg_create.show();
        /* try {
            var obj_record = scriptContext.currentRecord;
            var uso_cfdi = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.USO_CFDI });
            console.log({title: 'uso_cfdi', details: uso_cfdi});
            var forma_pago = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.FORMA_PAGO });
            console.log({title: 'forma_pago', details: forma_pago});
            var metodo_pago = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.METODO_PAGO });
            console.log({title: 'metodo_pago', details: metodo_pago});
            var tipo_exportación = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.TIPO_EXPORTACION });
            console.log({title: 'tipo_exportación', details: tipo_exportación});
            var plantilla_xml = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.TIPO_EXPORTACION });
            console.log({title: 'plantilla_xml', details: plantilla_xml});
            var metodo_envio = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.METODO_ENVIO });
            console.log({title: 'metodo_envio', details: metodo_envio});
            var genera_pdf = obj_record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.GENERA_PDF });
            console.log({title: 'genera_pdf', details: genera_pdf});
        } catch (errorOnPageInit) {
            log.error({title:'errorOnPageInit', details: errorOnPageInit});
            console.error('errorOnPageInit', errorOnPageInit);
        } */

    }


    return {
        pageInit: pageInit
    };

});
