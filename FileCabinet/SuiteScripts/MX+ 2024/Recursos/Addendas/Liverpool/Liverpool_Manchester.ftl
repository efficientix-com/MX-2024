<#setting locale = "es_MX">
<#assign jsonBody = transaction.custbody_efx_fe_tax_json>
<#assign jsonBodyEval = {}>
<#if jsonBody?has_content>
        <#assign jsonBodyEval = jsonBody?eval>
</#if>
<cfdi:Complemento>
    <detallista:detallista xmlns:detallista="http://www.sat.gob.mx/detallista" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sat.gob.mx/detallista http://www.sat.gob.mx/sitio_internet/cfd/detallista/detallista.xsd" type="SimpleInvoiceType" contentVersion="1.3.1" documentStructureVersion="AMC8.1" documentStatus="ORIGINAL">
        <detallista:requestForPaymentIdentification>
            <detallista:entityType>INVOICE</detallista:entityType>
        </detallista:requestForPaymentIdentification>
        <detallista:specialInstruction code="AAB">
            <detallista:text>${transaction.terms}</detallista:text>
        </detallista:specialInstruction>
        <detallista:specialInstruction code="DUT">
            <detallista:text>IVA</detallista:text>
        </detallista:specialInstruction>
        <detallista:specialInstruction code="PUR">
            <detallista:text>${transaction.otherrefnum}</detallista:text>
        </detallista:specialInstruction>
        <detallista:specialInstruction code="ZZZ">
            <detallista:text>${transaction.custbody_efx_fe_total_text}</detallista:text>
        </detallista:specialInstruction>
        <detallista:orderIdentification>
            <detallista:referenceIdentification type="ON">${transaction.otherrefnum}</detallista:referenceIdentification>
            <detallista:ReferenceDate>${transaction.custbody_efx_liverpool_fecha_ordencomp?string("yyyy-MM-dd")}</detallista:ReferenceDate>
        </detallista:orderIdentification>
        <detallista:AdditionalInformation>
            <detallista:referenceIdentification type="DQ">${transaction.custbody_efx_liverpool_folio_recibo}</detallista:referenceIdentification>
        </detallista:AdditionalInformation>
        <detallista:DeliveryNote>
            <detallista:referenceIdentification>${transaction.custbody_efx_liverpool_orden_compra}</detallista:referenceIdentification>
            <detallista:ReferenceDate>${transaction.custbody_efx_liverpool_fecha_recibo?string("yyyy-MM-dd")}</detallista:ReferenceDate>
        </detallista:DeliveryNote>
        <detallista:buyer>
            <#if shipaddress.custrecord_efx_fe_buyer_gln?has_content>
                <detallista:gln>${shipaddress.custrecord_efx_fe_buyer_gln}</detallista:gln>
            <#else>
                <detallista:gln>${customer.custentity_efx_liverpool_buyergln}</detallista:gln>
            </#if>
            <detallista:contactInformation>
                <detallista:personOrDepartmentName>
                    <detallista:text>${customer.custentity_efx_liverpool_persondepartmen}</detallista:text>
                </detallista:personOrDepartmentName>
            </detallista:contactInformation>
        </detallista:buyer>
        <detallista:seller>
            <detallista:gln>${customer.custentity_efx_liverpool_sellergln}</detallista:gln>
            <detallista:alternatePartyIdentification
                    type="SELLER_ASSIGNED_IDENTIFIER_FOR_A_PARTY">${customer.custentity_efx_liverpool_sellergln?substring(7, 13)}</detallista:alternatePartyIdentification>
        </detallista:seller>
        <detallista:shipTo>
            <#if shipaddress.custrecord_efx_fe_buyer_gln?has_content>
                <detallista:gln>${shipaddress.custrecord_efx_fe_buyer_gln}</detallista:gln>
            <#else>
                <detallista:gln>${customer.custentity_efx_liverpool_buyergln}</detallista:gln>
            </#if>
            <detallista:nameAndAddress>
                <detallista:name>${shipaddress.addressee}</detallista:name>
                <detallista:streetAddressOne>${shipaddress.custrecord_streetname}</detallista:streetAddressOne>
                <detallista:city>${shipaddress.city}</detallista:city>
                <detallista:postalCode>${shipaddress.zip}</detallista:postalCode>
            </detallista:nameAndAddress>
        </detallista:shipTo>
        <#assign rfcEmpresa = "">
        <#list subsidiary.taxregistration as rfclista>
            <#assign rfcEmpresa = rfclista.taxregistrationnumber>
        </#list>
        <detallista:InvoiceCreator>
            <detallista:gln>${customer.custentity_efx_liverpool_sellergln}</detallista:gln>
            <#if subsidiary.federalidnumber?has_content>
                <detallista:alternatePartyIdentification type="VA">${subsidiary.federalidnumber}</detallista:alternatePartyIdentification>
            <#elseif rfcEmpresa?has_content>
                <detallista:alternatePartyIdentification type="VA">${rfcEmpresa}</detallista:alternatePartyIdentification>
            <#else>
                <detallista:alternatePartyIdentification type="VA">${subsidiary.employerid}</detallista:alternatePartyIdentification>
            </#if>
            <detallista:nameAndAddress>
                <detallista:name>${subsidiary.legalname}</detallista:name>
                <detallista:streetAddressOne>${subsidiaryaddress.custrecord_streetname}</detallista:streetAddressOne>
                <detallista:city>${subsidiaryaddress.city}</detallista:city>
                <detallista:postalCode>${shipaddress.zip}</detallista:postalCode>
            </detallista:nameAndAddress>
        </detallista:InvoiceCreator>
        <detallista:Customs>
            <detallista:gln>${customer.custentity_efx_liverpool_sellergln}</detallista:gln>
        </detallista:Customs>
        <detallista:currency currencyISOCode="${transaction.currencysymbol}">
            <detallista:currencyFunction>BILLING_CURRENCY</detallista:currencyFunction>
            <detallista:rateOfChange>${transaction.exchangerate?string["0"]}</detallista:rateOfChange>
        </detallista:currency>
        <detallista:paymentTerms PaymentTermsRelationTime="REFERENCE_AFTER" paymentTermsEvent="DATE_OF_INVOICE">
            <detallista:netPayment netPaymentTermsType="BASIC_NET">
                <detallista:paymentTimePeriod>
                    <detallista:timePeriodDue timePeriod="DAYS">
                        <detallista:value>${transaction.terms?keep_before(" ")}</detallista:value>
                    </detallista:timePeriodDue>
                </detallista:paymentTimePeriod>
            </detallista:netPayment>
            <detallista:discountPayment discountType="ALLOWANCE_BY_PAYMENT_ON_TIME">
                <detallista:percentage>0</detallista:percentage>
            </detallista:discountPayment>
        </detallista:paymentTerms>
        <detallista:shipmentDetail/>
        <detallista:allowanceCharge sequenceNumber="1" allowanceChargeType="ALLOWANCE_GLOBAL" settlementType="OFF_INVOICE">
            <detallista:specialServicesType>EAB</detallista:specialServicesType>
            <detallista:monetaryAmountOrPercentage>
                <detallista:rate base="INVOICE_VALUE">
                    <detallista:percentage>0.00</detallista:percentage>
                </detallista:rate>
            </detallista:monetaryAmountOrPercentage>
        </detallista:allowanceCharge>
        <#assign lineas = 0>
        <#list transaction.item as item>
            <#if item.itemtype != "Discount">
                <#assign jsonLineast = item.custcol_efx_fe_tax_json>
                <#if jsonLineast?has_content>
                    <#assign jsonLinea = jsonLineast?eval>
                </#if>
                <#assign lineas = lineas+1>
                <detallista:lineItem type="SimpleInvoiceLineItemType" number="${lineas}">
                    <detallista:tradeItemIdentification>
                        <detallista:gtin>${item.custcol_efx_fe_upc_code}</detallista:gtin>
                    </detallista:tradeItemIdentification>
                    <detallista:alternateTradeItemIdentification type="BUYER_ASSIGNED"/>
                    <detallista:tradeItemDescriptionInformation language="ES">
                    <#if item.description?length gt 35>
                        <detallista:longText>${item.description?substring(0,34)}</detallista:longText>
                        <#else>
                        <detallista:longText>${item.description}</detallista:longText>
                    </#if>
                    </detallista:tradeItemDescriptionInformation>
                    <detallista:invoicedQuantity unitOfMeasure="PZA">${item.quantity?string["0"]}</detallista:invoicedQuantity>
                    <detallista:aditionalQuantity QuantityType="FREE_GOODS">0</detallista:aditionalQuantity>
                    <detallista:grossPrice>
                        <detallista:Amount>${item.rate?string["0.00"]}</detallista:Amount>
                    </detallista:grossPrice>
                    <detallista:netPrice>
                        <detallista:Amount>${item.rate?string["0.00"]}</detallista:Amount>
                    </detallista:netPrice>
                    <detallista:AdditionalInformation>
                        <detallista:referenceIdentification type="ON">${transaction.otherrefnum}</detallista:referenceIdentification>
                    </detallista:AdditionalInformation>
                    <detallista:Customs>
                        <detallista:gln>${customer.custentity_efx_liverpool_sellergln}</detallista:gln>
                        <detallista:alternatePartyIdentification type="TN" />
                        <detallista:ReferenceDate>${transaction.custbody_efx_liverpool_fecha_ordencomp?string("yyyy-MM-dd")}</detallista:ReferenceDate>
                        <detallista:nameAndAddress>
                            <detallista:name>${customer.custentity_efx_liverpool_sellergln}</detallista:name>
                        </detallista:nameAndAddress>
                    </detallista:Customs>
                    <detallista:LogisticUnits>
                        <detallista:serialShippingContainerCode type="SRV">${item.item?keep_before(" :")}</detallista:serialShippingContainerCode>
                    </detallista:LogisticUnits>
                    <detallista:palletInformation>
                        <detallista:palletQuantity>1</detallista:palletQuantity>
                        <detallista:description type="BOX">CAJAS</detallista:description>
                        <detallista:transport>
                            <detallista:methodOfPayment>PREPAID_BY_SELLER</detallista:methodOfPayment>
                        </detallista:transport>
                    </detallista:palletInformation>
                    <detallista:extendedAttributes>
                        <detallista:lotNumber productionDate="${transaction.trandate?string("yyyy-MM-dd")}">${item.item?keep_before(" :")}</detallista:lotNumber>
                    </detallista:extendedAttributes>
                    <detallista:allowanceCharge settlementType="OFF_INVOICE" allowanceChargeType="ALLOWANCE_GLOBAL" sequenceNumber="${lineas}">
                        <detallista:specialServicesType>AJ</detallista:specialServicesType>
                        <#assign descuentoRate = 0>
                        <#list transaction.promotions as promotions>
                        <#assign descuentoRate = promotions.discountrate>
                        </#list>
                        <detallista:monetaryAmountOrPercentage>
                            <detallista:percentagePerUnit>${(descuentoRate*-1)*100}</detallista:percentagePerUnit>
                            <detallista:ratePerUnit>
                                <detallista:amountPerUnit><#if jsonLinea.descuentoConImpuesto?has_content>${jsonLinea.iva.descuento?number?round?string["0"]}<#else>0</#if></detallista:amountPerUnit>
                            </detallista:ratePerUnit>
                        </detallista:monetaryAmountOrPercentage>
                    </detallista:allowanceCharge>
                    <detallista:tradeItemTaxInformation>
                        <detallista:taxTypeDescription>VAT</detallista:taxTypeDescription>
                        <detallista:tradeItemTaxAmount>
                            <detallista:taxPercentage>${jsonLinea.iva.rate}</detallista:taxPercentage>
                            <detallista:taxAmount>${jsonLinea.iva.importe}</detallista:taxAmount>
                        </detallista:tradeItemTaxAmount>
                        <detallista:taxCategory>TRANSFERIDO</detallista:taxCategory>
                    </detallista:tradeItemTaxInformation>
                    <detallista:totalLineAmount>
                        <detallista:grossAmount>
                            <detallista:Amount>${(item.amount-jsonLinea.iva.descuento?number)?string["0.00"]}</detallista:Amount>
                        </detallista:grossAmount>
                        <detallista:netAmount>
                            <detallista:Amount>${(item.grossamt-jsonLinea.iva.descuento?number)?string["0.00"]}</detallista:Amount>
                        </detallista:netAmount>
                    </detallista:totalLineAmount>
                </detallista:lineItem>
            </#if>
        </#list>
        <#assign montototalDescuento = 0>
        <#assign monsubTotal = 0>
        <#if jsonBodyEval?has_content>
            <#assign montototalDescuento = jsonBodyEval.descuentoSinImpuesto?number>
            <#assign monsubTotal = jsonBodyEval.subtotal?number>
        </#if>
        <detallista:totalAmount>
            <detallista:Amount>${monsubTotal?string["0.00"]}</detallista:Amount>
        </detallista:totalAmount>
        <detallista:TotalAllowanceCharge allowanceOrChargeType="ALLOWANCE">
            <detallista:specialServicesType>TD</detallista:specialServicesType>
            <detallista:Amount>${montototalDescuento?string["0.00"]}</detallista:Amount>
        </detallista:TotalAllowanceCharge>
    </detallista:detallista>
</cfdi:Complemento>