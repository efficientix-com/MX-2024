/**
 * @NApiVersion 2.1
 * @NScriptType UserEventScript
 */
define(['N/runtime', 'N/ui/serverWidget', '../../../Lib/fb_tp_const_lib.js', 'N/record'],
    /**
 * @param{runtime} runtime
 * @param{serverWidget} serverWidget
 */
    (runtime, serverWidget, constLib, record) => {
        /**
         * Defines the function definition that is executed before record is loaded.
         * @param {Object} scriptContext
         * @param {Record} scriptContext.newRecord - New record
         * @param {string} scriptContext.type - Trigger type; use values from the context.UserEventType enum
         * @param {Form} scriptContext.form - Current form
         * @param {ServletRequest} scriptContext.request - HTTP request information sent from the browser for a client action only.
         * @since 2015.2
         */
        const beforeLoad = (scriptContext) => {
            var record = scriptContext.newRecord;
            var record_type = record.type;
            try {
                const { REGISTROS, BOTONES, CUSTOMER } = constLib
                if (scriptContext.type == scriptContext.UserEventType.VIEW) {

                    var uso_cfdi = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.USO_CFDI });
                    log.audit({title: 'uso_cfdi', details: uso_cfdi});
                    var forma_pago = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.FORMA_PAGO });
                    log.audit({title: 'forma_pago', details: forma_pago});
                    var metodo_pago = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.METODO_PAGO });
                    log.audit({title: 'metodo_pago', details: metodo_pago});
                    var tipo_exportación = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.TIPO_EXPORTACION });
                    log.audit({title: 'tipo_exportación', details: tipo_exportación});
                    var plantilla_xml = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.TIPO_EXPORTACION });
                    log.audit({title: 'plantilla_xml', details: plantilla_xml});
                    var metodo_envio = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.METODO_ENVIO });
                    log.audit({title: 'metodo_envio', details: metodo_envio});
                    var genera_pdf = record.getValue({ fieldId: REGISTROS.INVOICE.CAMPOS.GENERA_PDF });
                    log.audit({title: 'genera_pdf', details: genera_pdf});


                    var form = scriptContext.form;
                    form.clientScriptModulePath = "../UI Events/fb_tp_cfdi_detail_messages_CS.js";
                    log.audit({title: 'form', details: form});
                    form.validaDatosFiscales();
                }
            } catch (errorOnbeforeLoad) {
                log.error({ title: 'errorOnbeforeLoad', details: errorOnbeforeLoad });
            }
        }

        /**
         * Defines the function definition that is executed before record is submitted.
         * @param {Object} scriptContext
         * @param {Record} scriptContext.newRecord - New record
         * @param {Record} scriptContext.oldRecord - Old record
         * @param {string} scriptContext.type - Trigger type; use values from the context.UserEventType enum
         * @since 2015.2
         */
        const beforeSubmit = (scriptContext) => {

        }

        /**
         * Defines the function definition that is executed after record is submitted.
         * @param {Object} scriptContext
         * @param {Record} scriptContext.newRecord - New record
         * @param {Record} scriptContext.oldRecord - Old record
         * @param {string} scriptContext.type - Trigger type; use values from the context.UserEventType enum
         * @since 2015.2
         */
        const afterSubmit = (scriptContext) => {

        }

        return { beforeLoad, beforeSubmit, afterSubmit }

    });
