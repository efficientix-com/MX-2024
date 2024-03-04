<?xml version="1.0" encoding="utf-8"?>
<#setting locale = "es_MX">
<#setting time_zone= "America/Mexico_City">
<#function getAttrPair attr value>
    <#if value?has_content>
        <#assign result="${attr}=\"${value}\"">
        <#return result>
    </#if>

</#function>
<#if custom.multiCurrencyFeature == "true">
    <#assign "currencyCode" = transaction.currencysymbol>
    <#if transaction.exchangerate == 1>
        <#assign exchangeRate = 1>
    <#else>
        <#assign exchangeRate = transaction.exchangerate?string["0.000000"]>
    </#if>
<#else>
    <#assign "currencyCode" = "MXN">
    <#assign exchangeRate = 1>
</#if>
<#if custom.oneWorldFeature == "true">
    <#assign customCompanyInfo = transaction.subsidiary>
<#else>
    <#assign "customCompanyInfo" = companyinformation>
</#if>
<#if customer.isperson == "T">
    <#assign customerName = customer.firstname + ' ' + customer.lastname>
<#else>
    <#assign "customerName" = customer.companyname>
</#if>
<#assign "summary" = custom.summary>
<#assign "satCodes" = custom.satcodes>
<#assign "companyTaxRegNumber" = custom.companyInfo.rfc>
<#assign tipocambioCustom = 1>
<cfdi:Comprobante xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:cfdi="http://www.sat.gob.mx/cfd/4" xsi:schemaLocation="http://www.sat.gob.mx/cfd/4 http://www.sat.gob.mx/sitio_internet/cfd/4/cfdv40.xsd http://www.sat.gob.mx/Pagos20 http://www.sat.gob.mx/sitio_internet/cfd/Pagos/Pagos20.xsd"
        <#if transaction.custbody_efx_fe_actual_date == true>
            <#assign aDateTime = .now>
            <#assign aDate = aDateTime?date>
            <#if transaction.custbody_efx_fe_fechadepago?has_content>
            <#assign aDatePago = transaction.custbody_efx_fe_fechadepago?string.iso_nz +"T"+transaction.custbody_efx_fe_actual_hour>
            <#else>
            <#assign aDatePago = transaction.trandate?string.iso_nz +"T"+transaction.custbody_efx_fe_actual_hour>
            </#if>
            Fecha="${aDate?string("yyyy-MM-dd")}T${aDate?string("HH:mm:ss")}"
        <#else>
            <#if transaction.custbody_efx_fe_fechadepago?has_content>
            <#assign aDatePago = transaction.custbody_efx_fe_fechadepago?string.iso_nz +"T"+ transaction.custbody_efx_fe_actual_hour>
            <#else>
            <#assign aDatePago = transaction.trandate?string.iso_nz +"T"+ transaction.custbody_efx_fe_actual_hour>
            </#if>
            Fecha="${transaction.trandate?string.iso_nz}T${transaction.custbody_efx_fe_actual_hour}"
        </#if>

        <#assign serie_parteuno = transaction.tranid?keep_before("-")>

        <#assign folio_transaction = transaction.tranid?keep_after("-")>
        <#assign jsonParcialidadField = transaction.custbody_efx_fe_parcialidad>
        <#assign jsonParcialidad = "">
        <#if jsonParcialidadField?has_content>
            <#assign jsonParcialidad = jsonParcialidadField?eval>
        </#if>

        <#assign serie_parteuno = "">
        <#assign folio_transaction = "">
        <#assign tranidd = transaction.tranid?length>
        <#assign traniddpos = transaction.tranid>
        <#list 0..tranidd as x>
        <#if traniddpos[x] != "-">
        <#assign esnum = traniddpos[x]?matches("\\d+")>
        <#if esnum>
        <#assign folio_transaction = folio_transaction+traniddpos[x]>
        <#else>
        <#assign serie_parteuno = serie_parteuno+traniddpos[x]>
        </#if>
        </#if>
        </#list>


        ${getAttrPair("Folio",folio_transaction)}
        ${getAttrPair("Serie",serie_parteuno)}
                  LugarExpedicion="${customCompanyInfo.zip}"
                  Moneda="XXX"
                  SubTotal="0"
                  TipoDeComprobante="P"
                  Total="0"
                  Version="4.0"
        <#assign exportacion = transaction.custbody_mx_cfdi_sat_export_type?keep_before(' -')>
                  Exportacion="${exportacion}">
    <#if transaction.recmachcustrecord_mx_rcs_orig_trans?has_content>
        <#list custom.relatedCfdis.types as cfdiRelType>
            <cfdi:CfdiRelacionados TipoRelacion="${cfdiRelType}">
                <#assign "cfdisArray" = custom.relatedCfdis.cfdis["k"+cfdiRelType?index]>
                <#if cfdisArray?has_content>
                    <#list cfdisArray as cfdiIdx>
                        <cfdi:CfdiRelacionado  UUID="${transaction.recmachcustrecord_mx_rcs_orig_trans[cfdiIdx.index?number].custrecord_mx_rcs_uuid}" />
                    </#list>
                </#if>
            </cfdi:CfdiRelacionados>
        </#list>
    </#if>
    <cfdi:Emisor ${getAttrPair("Nombre", customCompanyInfo.custrecord_mx_sat_registered_name)} RegimenFiscal="${satCodes.industryType}" Rfc="${companyTaxRegNumber}" />

    <#assign regfiscalreceptor = customer.custentity_mx_sat_industry_type?keep_before(" -")>
    <#if customer.custentity_mx_rfc == "XAXX010101000" || customer.custentity_mx_rfc == "XEXX010101000" || customer.custentity_mx_rfc == "">
        <#assign DomicilioFiscalReceptor = customCompanyInfo.zip>
    <#else>
        <#assign DomicilioFiscalReceptor = customer.billzip>
    </#if>

    <#if transaction.custbody_efx_fe_entity_timbra?has_content>
        <cfdi:Receptor Nombre="${transaction.custbody_efx_fe_factoraje_receptor}" Rfc="${transaction.custbody_efx_fe_factoraje_rfc}" ${getAttrPair("DomicilioFiscalReceptor", DomicilioFiscalReceptor)} ${getAttrPair("RegimenFiscalReceptor", regfiscalreceptor)} UsoCFDI="${satCodes.cfdiUsage}" />
    <#else>
        <cfdi:Receptor Nombre="${customer.custentity_mx_sat_registered_name}" Rfc="${customer.custentity_mx_rfc}" ${getAttrPair("DomicilioFiscalReceptor", DomicilioFiscalReceptor)} ${getAttrPair("RegimenFiscalReceptor", regfiscalreceptor)} UsoCFDI="${satCodes.cfdiUsage}" />
    </#if>

    <cfdi:Conceptos>
        <cfdi:Concepto Cantidad="1" ClaveProdServ="84111506" ClaveUnidad="ACT" Descripcion="Pago" Importe="0" ValorUnitario="0" ObjetoImp="01" />
    </cfdi:Conceptos>
    <#if currencyCode != "MXN">
        <#assign exchangeRateVal = exchangeRate>
    </#if>


    <#if transaction.custbody_efx_fe_moneda?has_content>
        <#if transaction.custbody_efx_fe_moneda != transaction.currency>
            <#assign currencyCode = transaction.custbody_efx_fe_moneda.symbol>
            <#assign exchangeRateVal = exchangeRate>
        </#if>
    </#if>


    <cfdi:Complemento>
        <pago20:Pagos xmlns:pago20="http://www.sat.gob.mx/Pagos20" Version="2.0">
            <#assign totaltrasladosiva16 = 0>
            <#assign totaltrasladosiva16div = 0>
            <#assign totaltrasladosiva16base = 0>
            <#assign totaltrasladosiva8 = 0>
            <#assign totaltrasladosiva8div = 0>
            <#assign totaltrasladosiva8base = 0>
            <#assign totaltrasladosiva0 = 0>
            <#assign totaltrasladosiva0div = 0>
            <#assign totaltrasladosiva0base = 0>
            <#assign totaltrasladosivaExentobase = 0>
            <#assign totaltrasladosivaExentodiv = 0>
            <#assign totaltrasladosRetencionesIva = 0>
            <#assign montoTotalPago = 0>
            <#assign esTrasladoIva = false>
            <#assign esRetencion = false>
            <#assign esIeps = false>
            <#list custom.appliedTxns as appliedTxn>
                <#assign "txnitem" = transaction.apply[appliedTxn.line?number]>
                <#assign "invPaymentTerm" = satCodes.paymentTermInvMap["d"+appliedTxn.id]>
                <#assign jsonImpuestoVar = appliedTxn.custbody_efx_fe_tax_json>
                <#assign equivalenciaImpuestoCalculo = (txnitem.amount*100)/txnitem.total>
                <#assign equivalenciaImpuesto = equivalenciaImpuestoCalculo/100>
                <#if jsonImpuestoVar?has_content>
                    <#assign impuestosPago = jsonImpuestoVar?eval>
                        <#list impuestosPago.bases_iva as ivaRate, ivaValue>
                            <#assign esTrasladoIva = true>
                            <#if ivaRate=="16">
                                <#assign totaltrasladosiva16 = totaltrasladosiva16+((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string["0.00"]?number)>
                                <#assign totaltrasladosiva16div = (totaltrasladosiva16div+(((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string["0.00"]?number)/0.16)?string["0.00"]?number)>
                                <#assign totaltrasladosiva16base = totaltrasladosiva16base+(ivaValue?number*equivalenciaImpuesto)>
                            <#elseif ivaRate=="8">
                                <#assign totaltrasladosiva8 = totaltrasladosiva8+(impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)>
                                <#assign totaltrasladosiva8div = (totaltrasladosiva8div+((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)/0.08)?string["0.00"]?number)>
                                <#assign totaltrasladosiva8base = totaltrasladosiva8base+(ivaValue?number*equivalenciaImpuesto)>
                            <#elseif ivaRate=="0">
                                <#assign totaltrasladosiva0 = totaltrasladosiva0+(impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)>
                                <#assign totaltrasladosiva0div = (totaltrasladosiva0div+((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto))?string["0.00"]?number)>
                                <#assign totaltrasladosiva0base = totaltrasladosiva0base+(ivaValue?number*equivalenciaImpuesto)>
                            </#if>
                        </#list>

                        <#list impuestosPago.bases_exento as exentoRate, exentoValue>
                            <#assign esTrasladoIva = true>
                            <#assign totaltrasladosivaExentobase = totaltrasladosivaExentobase+(exentoValue?number*equivalenciaImpuesto)>
                        </#list>

                        <#list impuestosPago.rates_retencion_data as retRate, retValue>
                        <#assign esRetencion = true>
                            <#assign totaltrasladosRetencionesIva = totaltrasladosRetencionesIva+(retValue?number*equivalenciaImpuesto)>
                    </#list>
                </#if>
                <#assign montoTotalPago = montoTotalPago+txnitem.amount>
            </#list>
            
            <pago20:Totales <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>MontoTotalPagos="${(montoTotalPago*transaction.exchangerate)?string["0.00"]}"<#else>MontoTotalPagos="${montoTotalPago?string["0.00"]}"</#if>
            <#if esTrasladoIva==true>
                <#if totaltrasladosiva16base gt 0>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosBaseIVA16="${(totaltrasladosiva16div*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosBaseIVA16="${totaltrasladosiva16div?string["0.00"]}"</#if>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosImpuestoIVA16="${(totaltrasladosiva16*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosImpuestoIVA16="${totaltrasladosiva16?string["0.00"]}"</#if>
                </#if>
                <#if totaltrasladosiva8base gt 0>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosBaseIVA8="${(totaltrasladosiva8div*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosBaseIVA8="${totaltrasladosiva8div?string["0.00"]}"</#if>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosImpuestoIVA8="${(totaltrasladosiva8*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosImpuestoIVA8="${totaltrasladosiva8?string["0.00"]}"</#if>
                </#if>
                <#if totaltrasladosiva0base gt 0>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosBaseIVA0="${(totaltrasladosiva0base*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosBaseIVA0="${totaltrasladosiva0base?string["0.00"]}"</#if>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalTrasladosImpuestoIVA0="${(totaltrasladosiva0*transaction.exchangerate)?string["0.00"]}"<#else>TotalTrasladosImpuestoIVA0="${totaltrasladosiva0?string["0.00"]}"</#if>
                </#if>
                <#if totaltrasladosivaExentobase gt 0>
                    TotalTrasladosBaseIVAExento="${totaltrasladosivaExentobase?string["0.00"]}"
                </#if>
            </#if>
            <#if esRetencion == true>
                <#if totaltrasladosRetencionesIva gt 0>
                    <#if currencyCode==transaction.custbody_efx_fe_moneda.symbol>TotalRetencionesIVA="${totaltrasladosRetencionesIva?string["0.00"]}"<#else>TotalRetencionesIVA="${totaltrasladosRetencionesIva?string["0.00"]}"</#if>
                </#if>
            </#if>
            />

            <pago20:Pago
                    FechaPago="${aDatePago}"
                    FormaDePagoP="${satCodes.paymentMethod}"
                    MonedaP="${currencyCode}"
                    <#if currencyCode != "MXN">
                        TipoCambioP="${exchangeRateVal}"
                    <#elseif transaction.custbody_efx_fe_moneda.symbol == "MXN" && transaction.currencysymbol != "MXN">
                        TipoCambioP="1"
                        <#if transaction.custbody_efx_fe_tipo_cambio?has_content>
                            <#assign tipocambioCustom = transaction.custbody_efx_fe_tipo_cambio?number>
                        <#else>
                            <#assign tipocambioCustom = 1>
                        </#if>
                        <#assign pagodolarenpeso = true>
                    <#elseif currencyCode == "MXN">
                            TipoCambioP="1"
                    </#if>
                    <#if transaction.custbody_efx_fe_chbx_factorage == true>
                        <#if transaction.custbody_efx_fe_moneda?has_content &&  transaction.custbody_efx_fe_importe?has_content>
                            <#assign MontoFactor = transaction.custbody_efx_total_factoraje?number / transaction.custbody_efx_fe_tipo_cambio?number>
                            Monto="${(transaction.custbody_efx_fe_importe - MontoFactor?number)?string["0.00"]}"
                        <#else>
                            <#assign MontoFactor = transaction.custbody_efx_total_factoraje>
                            Monto="${(transaction.applied)?string["0.00"]}"
                        </#if>
                    <#else>
                        <#if transaction.custbody_efx_fe_moneda?has_content &&  transaction.custbody_efx_fe_importe?has_content>
                            Monto="${transaction.custbody_efx_fe_importe}"
                        <#else>
                            Monto="${transaction.applied?string["0.00"]}"
                        </#if>
                    </#if>

                    <#if transaction.custbody_mx_cfdi_payment_id?has_content>
                        NumOperacion="${transaction.custbody_mx_cfdi_payment_id}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_issuer_entity_rfc?has_content>
                        RfcEmisorCtaOrd="${transaction.custbody_mx_cfdi_issuer_entity_rfc}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_issue_bank_name?has_content>
                        NomBancoOrdExt="${transaction.custbody_mx_cfdi_issue_bank_name}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_payer_account?has_content>
                        CtaOrdenante="${transaction.custbody_mx_cfdi_payer_account}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_recipient_entity_rfc?has_content>
                        RfcEmisorCtaBen="${transaction.custbody_mx_cfdi_recipient_entity_rfc}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_recipient_account?has_content>
                        CtaBeneficiario="${transaction.custbody_mx_cfdi_recipient_account}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_payment_string_type?has_content>
                        TipoCadPago="${satCodes.paymentStringTypeCode}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_payment_certificate?has_content>
                        CertPago="${transaction.custbody_mx_cfdi_payment_certificate}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_payment_string?has_content>
                        CadPago="${transaction.custbody_mx_cfdi_payment_string}"
                    </#if>
                    <#if transaction.custbody_mx_cfdi_payment_signature?has_content>
                        SelloPago="${transaction.custbody_mx_cfdi_payment_signature}"
                    </#if>
            >

                <#assign ImpuestosP_array = []>
                <#assign "ImpuestosPTraslados_base" = {}>
                <#assign "ImpuestosPTraslados_importe" = {}>
                <#assign ImpuestosPTraslados_importediv = {}>
                <#assign "ImpuestosPTraslados_tasa" = {}>
                <#assign "ImpuestosPRetencion_tasa" = {}>
                <#assign "ImpuestosPRetencion_base" = {}>
                <#assign "ImpuestosPRetencion_importe" = {}>

                    <#list custom.appliedTxns as appliedTxn>
                        <#assign "txnitem" = transaction.apply[appliedTxn.line?number]>
                        <#assign "invPaymentTerm" = satCodes.paymentTermInvMap["d"+appliedTxn.id]>
                        <#if custom.multiCurrencyFeature == "true">
                            <#assign appliedTxnCurrency = appliedTxn.currencysymbol>
                        <#else>
                            <#assign appliedTxnCurrency = currencyCode>
                        </#if>
                        <#assign jsonImpuestoVar = appliedTxn.custbody_efx_fe_tax_json>
                        <#assign objetoimpDR = "">
                        <#if jsonImpuestoVar?has_content>
                            <#if impuestosPago.bases_iva?has_content || impuestosPago.bases_ieps?has_content || impuestosPago.bases_retencion?has_content>
                                <#assign objetoimpDR = "02">
                                <#else>
                                <#assign objetoimpDR = "01">
                            </#if>
                        </#if>

                        <#assign foliorelated = txnitem.refnum>
                        <#assign foliorelated_serie = foliorelated?keep_before("-")>
                        <#assign foliorelated_folio = foliorelated?keep_after("-")>
                        <#assign ImpSaldoAnt = "">
                        <#assign CalculoParcialidad = "">
                        <#assign equivalenciaImpuestoCalculo = (txnitem.amount*100)/txnitem.total>
                        <#assign equivalenciaImpuesto = equivalenciaImpuestoCalculo/100>

                        <#if appliedTxn.imp?has_content>
                                <#if appliedTxn.imp?number gt 0>
                                    <#assign ImpSaldoAnt = appliedTxn.imp?number>
                                <#else>
                                    <#assign jsonParcialidadField = transaction.custbody_efx_fe_parcialidad>
                                    <#if jsonParcialidadField?has_content>
                                        <#assign jsonParcialidad = jsonParcialidadField?eval>
                                        <#list jsonParcialidad as jsonParcialidad_line>

                                            <#if foliorelated==jsonParcialidad_line.facturaRef>
                                                <#assign ImpSaldoAnt = jsonParcialidad_line.imp>
                                            </#if>
                                        </#list>

                                    </#if>
                                </#if>
                            <#assign CalculoParcialidad = appliedTxn.parcialidad>
                            <#else>
                                <#assign jsonParcialidadField = transaction.custbody_efx_fe_parcialidad>
                                <#if jsonParcialidadField?has_content>
                                    <#assign jsonParcialidad = jsonParcialidadField?eval>
                                    <#list jsonParcialidad as jsonParcialidad_line>
                                        <#if foliorelated==jsonParcialidad_line.facturaRef>
                                            <#assign ImpSaldoAnt = jsonParcialidad_line.imp>
                                        </#if>
                                        <#assign CalculoParcialidad = jsonParcialidad_line.parcialidad>
                                    </#list>

                                </#if>

                        </#if>

                        <#assign impinsoluto = ImpSaldoAnt - txnitem.amount>

                        <#if transaction.custbody_efx_fe_chbx_factorage == true>
                            <#if impinsoluto gt 0>
                                <#assign impinsoluto = impinsoluto>
                                <#else>
                                <#assign impinsoluto = txnitem.disc>
                            </#if>

                            <pago20:DoctoRelacionado IdDocumento="${appliedTxn.custbody_mx_cfdi_uuid}" ${getAttrPair("Folio",foliorelated_folio)} ${getAttrPair("Serie",foliorelated_serie)} MonedaDR="${appliedTxnCurrency}" <#if transaction.custbody_efx_fe_moneda?has_content &&  transaction.custbody_efx_fe_importe?has_content>EquivalenciaDR="${transaction.custbody_efx_fe_tipo_cambio}"<#elseif transaction.custbody_efx_fe_tipo_cambio_factura == true>EquivalenciaDR="${appliedTxn.exchangerate}"<#else><#if currencyCode!=appliedTxnCurrency>EquivalenciaDR="${transaction.exchangerate?string["0.000000"]}"<#else>EquivalenciaDR="1"</#if></#if> NumParcialidad="${CalculoParcialidad}" ImpSaldoAnt="${(ImpSaldoAnt)?string["0.00"]}" ImpPagado="${txnitem.amount?string["0.00"]}" ImpSaldoInsoluto="${impinsoluto?string["0.00"]}" ObjetoImpDR="${objetoimpDR}">
                                <#assign jsonImpuestoVar = appliedTxn.custbody_efx_fe_tax_json>
                                <#if jsonImpuestoVar?has_content>
                                    <#assign impuestosPago = jsonImpuestoVar?eval>
                                    <pago20:ImpuestosDR>

                                        <#if impuestosPago.bases_iva?has_content || impuestosPago.bases_ieps?has_content>
                                            <pago20:TrasladosDR>
                                                <#list impuestosPago.bases_iva as ivaRate, ivaValue>

                                                    <#if ImpuestosPTraslados_base?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_base?keys as key>

                                                            <#if key == ivaRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((ivaValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPTraslados_importe?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_importe?keys as key>

                                                            <#if key == ivaRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_iva_data[ivaRate]?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {ivaRate : impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPTraslados_tasa?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_tasa?keys as key>

                                                            <#if key == ivaRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                    </#if>
                                                    <#assign rateDR = ivaRate?number/100>
                                                    <#assign montoimpuestosPago = ((impuestosPago.rates_iva_data[ivaRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                    <#assign rateimpuestosPago = (ivaRate?number/100)?string["0.00"]>
                                                    <pago20:TrasladoDR BaseDR="${((montoimpuestosPago/ rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                                </#list>
                                                <#list impuestosPago.bases_ieps as iepsRate, iepsValue>
                                                    <#if ImpuestosPTraslados_base?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_base?keys as key>

                                                            <#if key == iepsRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((iepsValue?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPTraslados_importe?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_importe?keys as key>

                                                            <#if key == iepsRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_ieps_data[iepsRate]?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPTraslados_tasa?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPTraslados_tasa?keys as key>

                                                            <#if key == iepsRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                    </#if>
                                                    <#assign rateDR = iepsRate?number/100>
                                                    <#assign montoimpuestosPago = ((impuestosPago.rates_ieps_data[iepsRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                    <#assign rateimpuestosPago = (iepsRate?number/100)?string["0.00"]>
    
                                                    <pago20:TrasladoDR BaseDR="${((montoimpuestosPago/ rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="003" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                                </#list>
                                            </pago20:TrasladosDR>
                                        </#if>

                                        <#if impuestosPago.bases_retencion?has_content>
                                            <pago20:RetencionesDR>
                                                <#list impuestosPago.bases_retencion as retRate, retValue>
                                                    <#if ImpuestosPRetencion_base?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPRetencion_base?keys as key>

                                                            <#if key == retRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPRetencion_base[key]?number + ((retValue?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPRetencion_base = ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPRetencion_importe?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPRetencion_importe?keys as key>

                                                            <#if key == retRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "total_rate" = ImpuestosPRetencion_importe[key]?number + ((impuestosPago.rates_retencion_data[retRate]?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                                <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : total_rate?number}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPRetencion_importe = ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                    </#if>
                                                    <#if ImpuestosPRetencion_tasa?has_content>
                                                        <#assign "conteos" = 0>
                                                        <#list ImpuestosPRetencion_tasa?keys as key>

                                                            <#if key == retRate>
                                                                <#assign "conteos" = 1>

                                                                <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>

                                                            </#if>
                                                        </#list>
                                                        <#if conteos == 0>
                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                        </#if>

                                                    <#else>
                                                        <#assign ImpuestosPRetencion_tasa = ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                    </#if>
                                                    <#assign rateDR = retRate?number/100>
                                                    <#assign montoimpuestosPago = ((impuestosPago.rates_retencion_data[retRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                    <#assign rateimpuestosPago = (retRate?number/100)?string["0.00"]>
    
                                                    <pago20:RetencionDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                                </#list>
                                            </pago20:RetencionesDR>
                                        </#if>

                                    </pago20:ImpuestosDR>
                                </#if>
                        <#else>
                            <pago20:DoctoRelacionado IdDocumento="${appliedTxn.custbody_mx_cfdi_uuid}" ${getAttrPair("Folio",foliorelated_folio)} ${getAttrPair("Serie",foliorelated_serie)} MonedaDR="${appliedTxnCurrency}" <#if transaction.custbody_efx_fe_moneda?has_content &&  transaction.custbody_efx_fe_importe?has_content>EquivalenciaDR="${transaction.custbody_efx_fe_tipo_cambio}"<#elseif transaction.custbody_efx_fe_tipo_cambio_factura == true>EquivalenciaDR="${appliedTxn.exchangerate}"<#else><#if currencyCode!=appliedTxnCurrency>EquivalenciaDR="${transaction.exchangerate?string["0.000000"]}"<#else>EquivalenciaDR="1"</#if></#if> NumParcialidad="${CalculoParcialidad}" ImpSaldoAnt="${(ImpSaldoAnt)?string["0.00"]}" ImpPagado="${txnitem.amount?string["0.00"]}" ImpSaldoInsoluto="${impinsoluto?string["0.00"]}" ObjetoImpDR="${objetoimpDR}">
                                <#assign jsonImpuestoVar = appliedTxn.custbody_efx_fe_tax_json>
                                <#if jsonImpuestoVar?has_content>
                                    <#assign impuestosPago = jsonImpuestoVar?eval>
                                    <pago20:ImpuestosDR>

                                    <#if impuestosPago.bases_iva?has_content || impuestosPago.bases_ieps?has_content>
                                        <pago20:TrasladosDR>
                                            <#list impuestosPago.bases_iva as ivaRate, ivaValue>

                                                <#if ImpuestosPTraslados_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_base?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((ivaValue?number * equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_importe?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : ((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00'])?number}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {ivaRate : ((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00'])?number}>
                                                    
                                                </#if>
                                                <#if ImpuestosPTraslados_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_tasa?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                </#if>
                                                <#assign rateDR = ivaRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_iva_data[ivaRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (ivaRate?number/100)?string["0.00"]>
                                                <pago20:TrasladoDR <#if montoimpuestosPago gt 0>BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}"<#else>BaseDR="${((ivaValue?number*equivalenciaImpuesto))?string['0.00']}"</#if> ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                            </#list>
                                            <#list impuestosPago.bases_ieps as iepsRate, iepsValue>
                                                <#if ImpuestosPTraslados_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_base?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((iepsValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    
                                                    <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_importe?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_tasa?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                </#if>
                                                <#assign rateDR = iepsRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_ieps_data[iepsRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (iepsRate?number/100)?string["0.00"]>

                                                <pago20:TrasladoDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="003" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                            </#list>
                                        </pago20:TrasladosDR>
                                        </#if>

                                    <#if impuestosPago.bases_retencion?has_content>
                                        <pago20:RetencionesDR>
                                            <#list impuestosPago.bases_retencion as retRate, retValue>
                                                <#if ImpuestosPRetencion_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_base?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPRetencion_base[key]?number + ((retValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_base = ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPRetencion_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_importe?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPRetencion_importe[key]?number + ((impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_importe = ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPRetencion_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_tasa?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_tasa = ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                </#if>
                                                <#assign rateDR = retRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_retencion_data[retRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (retRate?number/100)?string["0.00"]>

                                                <pago20:RetencionDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string["0.000000"]}" ImporteDR="${(impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto)?string["0.00"]}"/>
                                            </#list>
                                        </pago20:RetencionesDR>
                                    </#if>

                                    </pago20:ImpuestosDR>
                                </#if>

                        </#if>
                        </pago20:DoctoRelacionado>
                    </#list>

                
                    <pago20:ImpuestosP>
                        <#if ImpuestosPTraslados_base?has_content>
                            <pago20:TrasladosP>
                                <#list ImpuestosPTraslados_base as baseTkey, baseTvalue>
                                    <#assign impuestoPType = "">
                                    <#list ImpuestosPTraslados_tasa as tasaTkey, tasaTvalue>
                                        <#if baseTkey==tasaTkey>
                                            <#assign impuestoPType = tasaTvalue>
                                        </#if>
                                    </#list>
                                    <#assign tasaCuota = baseTkey?number / 100>
                                    <#if ImpuestosPTraslados_importe[baseTkey]?number gt 0>
                                        <#assign basePmonto = (((ImpuestosPTraslados_importe[baseTkey]?string["0.00"]?number)/tasaCuota?number)?string["0.00"]?number)/tipocambioCustom>
                                        
                                    <#else>
                                        <#assign basePmonto = baseTvalue?number>
                                    </#if>
                                    <pago20:TrasladoP BaseP="${basePmonto?string["0.00"]}" ImpuestoP="${impuestoPType}" TipoFactorP="Tasa" TasaOCuotaP="${tasaCuota?string["0.000000"]}" ImporteP="${((ImpuestosPTraslados_importe[baseTkey]?string["0.00"])?number/tipocambioCustom)?string["0.00"]}"/>
                                </#list>
                            </pago20:TrasladosP>
                        </#if>

                        <#if ImpuestosPRetencion_base?has_content>
                            <pago20:RetencionesP>
                                <#list ImpuestosPRetencion_base as baseRkey, baseRvalue>
                                    <#assign impuestoPType = "">
                                    <#list ImpuestosPRetencion_tasa as tasaRkey, tasaRvalue>
                                        <#if baseRkey==tasaRkey>
                                            <#assign impuestoPType = tasaRvalue>
                                        </#if>
                                    </#list>
                                    <pago20:RetencionP ImpuestoP="${impuestoPType} ImporteP="${ImpuestosPRetencion_importe[baseRkey]?string["0.00"]}"/>
                                </#list>
                            </pago20:RetencionesP>
                        </#if>
                    </pago20:ImpuestosP>
            </pago20:Pago>


            <#if transaction.custbody_efx_fe_chbx_factorage == true>
                <pago20:Pago
                        FechaPago="${aDatePago}"
                        FormaDePagoP="17"
                        MonedaP="${currencyCode}"
                        <#if currencyCode != "MXN">
                            TipoCambioP="${exchangeRateVal}"
                        <#elseif transaction.custbody_efx_fe_moneda.symbol == "MXN" && transaction.currencysymbol != "MXN">
                            TipoCambioP="1"
                            <#if transaction.custbody_efx_fe_tipo_cambio?has_content>
                                <#assign tipocambioCustom = transaction.custbody_efx_fe_tipo_cambio?number>
                            <#else>
                                <#assign tipocambioCustom = 1>
                            </#if>
                            <#assign pagodolarenpeso = true>
                        <#elseif currencyCode == "MXN">
                                TipoCambioP="1"
                        </#if>
                        Monto="${MontoFactor?number?string["0.00"]}"
                        <#if transaction.custbody_mx_cfdi_payment_id?has_content>
                            NumOperacion="${transaction.custbody_mx_cfdi_payment_id}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_issuer_entity_rfc?has_content>
                            RfcEmisorCtaOrd="${transaction.custbody_mx_cfdi_issuer_entity_rfc}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_issue_bank_name?has_content>
                            NomBancoOrdExt="${transaction.custbody_mx_cfdi_issue_bank_name}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_payer_account?has_content>
                            CtaOrdenante="${transaction.custbody_mx_cfdi_payer_account}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_recipient_entity_rfc?has_content>
                            RfcEmisorCtaBen="${transaction.custbody_mx_cfdi_recipient_entity_rfc}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_recipient_account?has_content>
                            CtaBeneficiario="${transaction.custbody_mx_cfdi_recipient_account}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_payment_string_type?has_content>
                            TipoCadPago="${satCodes.paymentStringTypeCode}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_payment_certificate?has_content>
                            CertPago="${transaction.custbody_mx_cfdi_payment_certificate}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_payment_string?has_content>
                            CadPago="${transaction.custbody_mx_cfdi_payment_string}"
                        </#if>
                        <#if transaction.custbody_mx_cfdi_payment_signature?has_content>
                            SelloPago="${transaction.custbody_mx_cfdi_payment_signature}"
                        </#if>
                >
                    <#assign ImpuestosP_array = []>
                    <#assign "ImpuestosPTraslados_base" = {}>
                    <#assign "ImpuestosPTraslados_importe" = {}>
                    <#assign "ImpuestosPTraslados_tasa" = {}>
                    <#assign "ImpuestosPRetencion_tasa" = {}>
                    <#assign "ImpuestosPRetencion_base" = {}>
                    <#assign "ImpuestosPRetencion_importe" = {}>
                    <#list custom.appliedTxns as appliedTxn>
                        <#assign "txnitem" = transaction.apply[appliedTxn.line?number]>
                        <#assign "invPaymentTerm" = satCodes.paymentTermInvMap["d"+appliedTxn.id]>
                        <#if custom.multiCurrencyFeature == "true">
                            <#assign appliedTxnCurrency = appliedTxn.currencysymbol>
                        <#else>
                            <#assign appliedTxnCurrency = currencyCode>
                        </#if>


                        <#assign foliorelated = txnitem.refnum>
                        <#assign foliorelated_serie = foliorelated?keep_before("-")>
                        <#assign foliorelated_folio = foliorelated?keep_after("-")>
                        <#assign ImpSaldoAnt = "">
                        <#assign CalculoParcialidad = "">
                        <#assign equivalenciaImpuestoCalculo = (txnitem.disc*100)/txnitem.total>
                        <#assign equivalenciaImpuesto = equivalenciaImpuestoCalculo/100>

                        <#if appliedTxn.imp?has_content>
                            <#if appliedTxn.imp?number gt 0>
                                <#assign ImpSaldoAnt = appliedTxn.imp?number>
                            <#else>
                                <#assign jsonParcialidadField = transaction.custbody_efx_fe_parcialidad>
                                <#if jsonParcialidadField?has_content>
                                    <#assign jsonParcialidad = jsonParcialidadField?eval>
                                    <#list jsonParcialidad as jsonParcialidad_line>

                                        <#if foliorelated==jsonParcialidad_line.facturaRef>
                                            <#assign ImpSaldoAnt = jsonParcialidad_line.imp>
                                        </#if>
                                    </#list>

                                </#if>
                            </#if>
                            <#assign CalculoParcialidad = appliedTxn.parcialidad>
                        <#else>
                            <#assign jsonParcialidadField = transaction.custbody_efx_fe_parcialidad>
                            <#if jsonParcialidadField?has_content>
                                <#assign jsonParcialidad = jsonParcialidadField?eval>
                                <#list jsonParcialidad as jsonParcialidad_line>
                                    <#if foliorelated==jsonParcialidad_line.facturaRef>
                                        <#assign ImpSaldoAnt = jsonParcialidad_line.imp>
                                    </#if>
                                    <#assign CalculoParcialidad = jsonParcialidad_line.parcialidad>
                                </#list>

                            </#if>

                        </#if>

                        <#assign ImpSaldoAnt = ImpSaldoAnt - txnitem.amount>

                        <#if ImpSaldoAnt gt 0>
                        <#assign ImpSaldoAnt = ImpSaldoAnt>
                        <#else>
                        <#assign ImpSaldoAnt = txnitem.disc>
                        </#if>


                        <#assign impinsoluto = ImpSaldoAnt - txnitem.disc>
                        <pago20:DoctoRelacionado IdDocumento="${appliedTxn.custbody_mx_cfdi_uuid}" ${getAttrPair("Folio",foliorelated_folio)} ${getAttrPair("Serie",foliorelated_serie)} MonedaDR="${appliedTxnCurrency}" <#if transaction.custbody_efx_fe_moneda?has_content &&  transaction.custbody_efx_fe_importe?has_content>EquivalenciaDR="${transaction.custbody_efx_fe_tipo_cambio}"<#elseif transaction.custbody_efx_fe_tipo_cambio_factura == true>EquivalenciaDR="${appliedTxn.exchangerate}"<#else><#if currencyCode!=appliedTxnCurrency>EquivalenciaDR="${transaction.exchangerate?string["0.000000"]}"<#else>EquivalenciaDR="1"</#if></#if> NumParcialidad="${CalculoParcialidad?number + 1}" ImpSaldoAnt="${(ImpSaldoAnt)?string["0.00"]}" ImpPagado="${txnitem.disc?string["0.00"]}" ImpSaldoInsoluto="${impinsoluto?string["0.00"]}" ObjetoImpDR="${objetoimpDR}">
                            <#assign jsonImpuestoVar = appliedTxn.custbody_efx_fe_tax_json>
                            <#if jsonImpuestoVar?has_content>
                                <#assign impuestosPago = jsonImpuestoVar?eval>
                                <pago20:ImpuestosDR>

                                    <#if impuestosPago.bases_iva?has_content || impuestosPago.bases_ieps?has_content>
                                        <pago20:TrasladosDR>
                                            <#list impuestosPago.bases_iva as ivaRate, ivaValue>

                                                <#if ImpuestosPTraslados_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_base?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((ivaValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {ivaRate : ivaValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_importe?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {ivaRate : impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {ivaRate : impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_tasa?keys as key>

                                                        <#if key == ivaRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {ivaRate : "002"}>
                                                </#if>
                                                <#assign rateDR = ivaRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_iva_data[ivaRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (ivaRate?number/100)?string["0.00"]>

                                                <pago20:TrasladoDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_iva_data[ivaRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                            </#list>
                                            <#list impuestosPago.bases_ieps as iepsRate, iepsValue>
                                                <#if ImpuestosPTraslados_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_base?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_base[key]?number + ((iepsValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_base"= ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_base = ImpuestosPTraslados_base + {iepsRate : iepsValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_importe?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPTraslados_importe[key]?number + ((impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_importe"= ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_importe = ImpuestosPTraslados_importe + {iepsRate : impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPTraslados_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPTraslados_tasa?keys as key>

                                                        <#if key == iepsRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPTraslados_tasa = ImpuestosPTraslados_tasa + {iepsRate : "003"}>
                                                </#if>
                                                <#assign rateDR = iepsRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_ieps_data[iepsRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (iepsRate?number/100)?string["0.00"]>

                                                <pago20:TrasladoDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="003" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_ieps_data[iepsRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                            </#list>
                                        </pago20:TrasladosDR>
                                    </#if>

                                    <#if impuestosPago.bases_retencion?has_content>
                                        <pago20:RetencionesDR>
                                            <#list impuestosPago.bases_retencion as retRate, retValue>
                                                <#if ImpuestosPRetencion_base?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_base?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPRetencion_base[key]?number + ((retValue?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPRetencion_base"= ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_base = ImpuestosPRetencion_base + {retRate : retValue?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPRetencion_importe?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_importe?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "total_rate" = ImpuestosPRetencion_importe[key]?number + ((impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto)?string['0.00'])?number>
                                                            <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : total_rate?number}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPRetencion_importe"= ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_importe = ImpuestosPRetencion_importe + {retRate : impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto}>
                                                </#if>
                                                <#if ImpuestosPRetencion_tasa?has_content>
                                                    <#assign "conteos" = 0>
                                                    <#list ImpuestosPRetencion_tasa?keys as key>

                                                        <#if key == retRate>
                                                            <#assign "conteos" = 1>

                                                            <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>

                                                        </#if>
                                                    </#list>
                                                    <#if conteos == 0>
                                                        <#assign "ImpuestosPTraslados_tasa"= ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                    </#if>

                                                <#else>
                                                    <#assign ImpuestosPRetencion_tasa = ImpuestosPRetencion_tasa + {retRate : "002"}>
                                                </#if>
                                                <#assign rateDR = retRate?number/100>
                                                <#assign montoimpuestosPago = ((impuestosPago.rates_retencion_data[retRate]?number)*equivalenciaImpuesto)?string['0.00']?number>
                                                <#assign rateimpuestosPago = (retRate?number/100)?string["0.00"]>

                                                <pago20:RetencionDR BaseDR="${((montoimpuestosPago/rateimpuestosPago?number))?string['0.00']}" ImpuestoDR="002" TipoFactorDR="Tasa" TasaOCuotaDR="${rateDR?string['0.000000']}" ImporteDR="${(impuestosPago.rates_retencion_data[retRate]?number*equivalenciaImpuesto)?string['0.00']}"/>
                                            </#list>
                                        </pago20:RetencionesDR>
                                    </#if>

                                </pago20:ImpuestosDR>
                            </#if>
                            </pago20:DoctoRelacionado>
                    </#list>

                    
                    <pago20:ImpuestosP>
                        <#if ImpuestosPTraslados_base?has_content>
                            <pago20:TrasladosP>
                                <#list ImpuestosPTraslados_base as baseTkey, baseTvalue>
                                    <#assign impuestoPType = "">
                                    <#list ImpuestosPTraslados_tasa as tasaTkey, tasaTvalue>
                                        <#if baseTkey==tasaTkey>
                                            <#assign impuestoPType = tasaTvalue>
                                        </#if>
                                    </#list>
                                    <#assign tasaCuota = baseTkey?number / 100>
                                    <#if ImpuestosPTraslados_importe[baseTkey]?number gt 0>
                                        <#assign basePmonto = (((ImpuestosPTraslados_importe[baseTkey]?string["0.00"]?number)/tasaCuota?number)?string["0.00"]?number)/tipocambioCustom>
                                        
                                    <#else>
                                        <#assign basePmonto = baseTvalue?number>
                                    </#if>
                                    <pago20:TrasladoP BaseP="${basePmonto?string["0.00"]}" ImpuestoP="${impuestoPType}" TipoFactorP="Tasa" TasaOCuotaP="${tasaCuota?string["0.000000"]}" ImporteP="${((ImpuestosPTraslados_importe[baseTkey]?string["0.00"])?number/tipocambioCustom)?string["0.00"]}"/>
                                </#list>
                            </pago20:TrasladosP>
                        </#if>

                        <#if ImpuestosPRetencion_base?has_content>
                            <pago20:RetencionesP>
                                <#list ImpuestosPRetencion_base as baseRkey, baseRvalue>
                                    <#assign impuestoPType = "">
                                    <#list ImpuestosPRetencion_tasa as tasaRkey, tasaRvalue>
                                        <#if baseRkey==tasaRkey>
                                            <#assign impuestoPType = tasaRvalue>
                                        </#if>
                                    </#list>
                                    <pago20:RetencionP ImpuestoP="${impuestoPType} ImporteP="${ImpuestosPRetencion_importe[baseRkey]?string["0.00"]}"/>
                                </#list>
                            </pago20:RetencionesP>
                        </#if>
                    </pago20:ImpuestosP>
                </pago20:Pago>
            </#if>


        </pago20:Pagos>
    </cfdi:Complemento>
</cfdi:Comprobante>