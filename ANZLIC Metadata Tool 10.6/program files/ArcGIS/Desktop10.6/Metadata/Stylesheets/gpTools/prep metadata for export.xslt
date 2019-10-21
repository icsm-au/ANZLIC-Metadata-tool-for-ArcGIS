<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XMLSpy v2012 rel. 2 sp1 (http://www.altova.com) by Ronnie Steyn (Esri Australia,2013/03/27) -->
<!-- Processes ArcGIS metadata to prepare it for export to a standard metadata format. -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:esri="http://www.esri.com/metadata/">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="no"/>
	<!-- start processing all nodes and attributes in the XML document -->
	<!-- any CDATA blocks in the original XML will be lost because they can't be handled by XSLT -->
	<xsl:template match="/">
		<xsl:apply-templates select="node() | @*"/>
	</xsl:template>
	<!-- copy all nodes and attributes in the XML document -->
	<xsl:template match="node() | @*" priority="0">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	<!-- templates below override the default template above that copies all noes and attributes -->
	<!-- add data quality section if geoprocessing history entries are marked for export but no other quality informaiton is present -->
	<xsl:template match="metadata[not(dqInfo) and (/metadata/Esri/DataProperties/lineage/Process/@export = 'True')]" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
			<dqInfo>
				<dataLineage>
					<xsl:for-each select="/metadata/Esri/DataProperties/lineage/Process[@export = 'True']">
						<prcStep>
							<stepDesc>
								<xsl:value-of select="."/>
							</stepDesc>
							<stepDateTm>
								<xsl:call-template name="dateType">
									<xsl:with-param name="value" select="@Date"/>
								</xsl:call-template>
							</stepDateTm>
						</prcStep>
					</xsl:for-each>
				</dataLineage>
			</dqInfo>
		</xsl:copy>
	</xsl:template>
	<!-- keep image description element if content type is image whether there is content in ImageDescription elements or not -->
	<xsl:template match="ImgDesc[contentTyp/ContentTypCd/@value = '001']" priority="2">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
		</xsl:copy>
	</xsl:template>
	<!-- keep image description element if ImageDescription elements have content, regardless of content type -->
	<!-- otherwise, use coverage description element -->
	<xsl:template match="ImgDesc" priority="1">
		<xsl:choose>
			<xsl:when test="(illElevAng != '') or (illAziAng != '') or (imagCond/ImgCondCd/@value != '') or (imagQuCode != '') or (cloudCovPer != '') or (prcTypCde != '') or (cmpGenQuan != '') or (trianInd != '') or (radCalDatAv != '') or (camCalInAv != '') or (filmDistInAv != '') or (lensDistInAv)">
				<xsl:copy>
					<xsl:apply-templates select="node() | @*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<CovDesc>
					<xsl:apply-templates select="node() | @*"/>
				</CovDesc>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- keep band element if Band elements have content, otherwise, use range dimension element instead -->
	<xsl:template match="Band" priority="1">
		<xsl:choose>
			<xsl:when test="(maxVal != '') or (minVal != '') or (valUnit != '') or (pkResp != '') or (bitsPerVal != '') or (toneGrad != '') or (sclFac != '') or (offset != '')">
				<xsl:copy>
					<xsl:apply-templates select="node() | @*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<RangeDim>
					<xsl:apply-templates select="node() | @*"/>
				</RangeDim>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- keep georectified element if georectified elements have content, otherwise, use general grid element -->
	<xsl:template match="Georect" priority="1">
		<xsl:choose>
			<xsl:when test="(chkPtAv != '') or (chkPtDesc != '') or (cornerPts != '') or (centerPt != '') or (ptInPixel/PixOrientCd/@value != '') or (transDimDesc != '') or (transDimMap != '')">
				<xsl:copy>
					<xsl:apply-templates select="node() | @*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<GridSpatRep>
					<xsl:apply-templates select="node() | @*"/>
				</GridSpatRep>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- keep georeferenceable element if georeferenceable elements have content, otherwise, use general grid element -->
	<xsl:template match="Georef" priority="1">
		<xsl:choose>
			<xsl:when test="(ctrlPtAv != '') or (orieParaAv != '') or (orieParaDs != '') or (georefPars != '') or (paraCit != '')">
				<xsl:copy>
					<xsl:apply-templates select="node() | @*"/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<GridSpatRep>
					<xsl:apply-templates select="node() | @*"/>
				</GridSpatRep>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- if geoprocessing history entries are marked for inclusion in lineage, format and include the information -->
	<xsl:template match="dataLineage[(/metadata/Esri/DataProperties/lineage/Process/@export = 'True')]" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
			<xsl:for-each select="/metadata/Esri/DataProperties/lineage/Process[@export = 'True']">
				<prcStep>
					<stepDesc>
						<xsl:value-of select="."/>
					</stepDesc>
					<stepDateTm>
						<xsl:call-template name="dateType">
							<xsl:with-param name="value" select="@Date"/>
						</xsl:call-template>
					</stepDateTm>
				</prcStep>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	<!-- add lineage section if geoprocessing history entries are marked for export but no other lineage informaiton is present -->
	<xsl:template match="dqInfo[not(dataLineage) and (/metadata/Esri/DataProperties/lineage/Process/@export = 'True')]" priority="1">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*"/>
			<dataLineage>
				<xsl:for-each select="/metadata/Esri/DataProperties/lineage/Process[@export = 'True']">
					<prcStep>
						<stepDesc>
							<xsl:value-of select="."/>
						</stepDesc>
						<stepDateTm>
							<xsl:call-template name="dateType">
								<xsl:with-param name="value" select="@Date"/>
							</xsl:call-template>
						</stepDateTm>
					</prcStep>
				</xsl:for-each>
			</dataLineage>
		</xsl:copy>
	</xsl:template>
	<xsl:template name="dateType">
		<xsl:param name="value"/>
		<xsl:choose>
			<xsl:when test="number($value)">
				<xsl:value-of select="substring($value,1,4)"/>
				<xsl:if test="string-length($value) > 4">
					-<xsl:value-of select="substring($value,5,2)"/>
				</xsl:if>
				<xsl:if test="string-length($value) > 6">
					-<xsl:value-of select="substring($value,7,2)"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--xsl:template name="timeType">
		<e   name="value"/>
		<xsl:choose>
			<xsl:when test="number($value)">
				<xsl:value-of select="substring($value,1,2)"/>
				<xsl:if test="string-length($value) > 2">:<xsl:value-of select="substring($value,3,2)"/>
				</xsl:if>
				<xsl:if test="string-length($value) > 4">:<xsl:value-of select="substring($value,5,2)"/>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$value"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template-->
	<!-- if abstract contains escaped HTML or real HTML, extract just the text from it for export -->
	<xsl:template match="idAbs|idPurp|idCredit|useLimit" priority="1">
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="./*">
					<xsl:variable name="htmlText">
						<xsl:for-each select=".//text()">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="normalize-space($htmlText)"/>
				</xsl:when>
				<xsl:when test="(contains(.,'&lt;/')) or (contains(.,'/&gt;'))">
					<xsl:variable name="escapedHtmlText">
						<xsl:value-of select="esri:striphtml(., '')"/>
					</xsl:variable>
					<xsl:value-of select="normalize-space($escapedHtmlText)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:copy>
	</xsl:template>
	<xsl:template match="@gmlID" priority="1">
		<xsl:choose>
			<xsl:when test="(. = '')">
				<xsl:attribute name="gmlID">
					<xsl:value-of select="generate-id()"/>
				</xsl:attribute>
				<xsl:apply-templates select="node() | @*"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
				<xsl:apply-templates select="node() | @*"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
