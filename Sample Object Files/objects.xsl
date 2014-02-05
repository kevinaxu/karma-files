<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl [
  <!ENTITY crm "http://erlangen-crm.org/current/">
  <!ENTITY foaf "http://xmlns.com/foaf/0.1/">
  <!ENTITY lido "http://www.lido-schema.org/">
  <!ENTITY skos "http://www.w3.org/2004/02/skos/core#">
  <!ENTITY bibo "http://purl.org/ontology/bibo/">
  <!ENTITY dcterms "http://purl.org/dc/terms/">
  <!ENTITY geo-pos "http://www.w3.org/2003/01/geo/wgs84_pos#">
  
  <!ENTITY bmo "http://collection.britishmuseum.org/id/ontology/">
  
  <!ENTITY getty_tgn "http://vocab.getty.edu/tgn/">	
  <!ENTITY getty_aat "http://vocab.getty.edu/aat/">
  <!ENTITY getty_ulan "http://vocab.getty.edu/ulan/">
  <!ENTITY unit "http://qudt.org/vocab/unit#"	>

  <!ENTITY viaf "http://viaf.org/viaf/">
  <!ENTITY odnb "http://www.oxforddnb.com/view/article/">
  <!--ENTITY dbpedia "http://dbpedia.org/resource/"-->
  <!--ENTITY freebase "http://rdf.freebase.com/ns/"-->
  <!ENTITY iconclass "http://www.iconclass.org/rkd/">
  
  <!ENTITY loc_subjects "http://id.loc.gov/authorities/subjects/">
  <!ENTITY loc_names "http://id.loc.gov/authorities/names/">
	
  <!ENTITY ycba "http://collection.britishart.yale.edu/id/">
  <!ENTITY ycba_dimension "http://collection.britishart.yale.edu/id/thesauri/dimension/">
  
  <!ENTITY oclc "http://www.worldcat.org/oclc/">
  <!ENTITY bmo "http://collection.britishmuseum.org/id/ontology/">
  <!ENTITY ycba_img_base "http://deliver.odai.yale.edu/info/repository/YCBA/id/">
  <!ENTITY ycba_base "http://collection.britishart.yale.edu/">
  <!ENTITY ycba_thesauri "http://collection.britishart.yale.edu/id/thesauri/">
  <!ENTITY ycba_img_flag "http://collection.britishart.yale.edu/id/thesauri/image/flag/">
  <!ENTITY ycba_img_format "http://collection.britishart.yale.edu/id/thesauri/image/format/">
  <!ENTITY yale_iiif "http://scale.ydc2.yale.edu/iiif/">
  <!ENTITY xsd "http://www.w3.org/2001/XMLSchema#">
  
]>

<xsl:stylesheet version="2.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:lido="http://www.lido-schema.org/"
	xmlns:ycba_fn="http://collection.britishart.yale.edu/functions/"
	exclude-result-prefixes="lido ycba_fn"
>
    <xsl:output method="html"
            encoding="UTF-8"
            indent="yes"
			omit-xml-declaration="yes"/>	

	<!-- FUNCTIONS -->
		<!-- ycba_fn:zeroString(k)
			 Return a string of k zeroes 
			 Mainly for padding AAT codes that need to be 9 digits long
			 Usage: param1: number of zeroes needed
		-->
		
	<!-- UPDATES -->
		<!--
			08-27-2013 11:07pm / Lec - had to remove urlencode in 2 places, added comment: removed urlencode, caused problems
			08-28-2013 11:09pm / Daniel - modified urlencode function to exclude semicolons, and not add underscore at the end of the string Allowed: a-zA-Z&*+-:/0-9 
			08-29-2013 11:10pm / Lec - fixed nationality, tokenizing based on comma, forwarded ticked 1922 to Emmanuele, rest of the data has to be tockenized somehow, otherwise cannot verify parsing always return same results 
			08-30-2013 12:28am / Lec - added validation for inscriptions, if blank it will not generate RDF
			08-30-2013 12:30am / Lec - object rights completed
			09-01-2013 10:41pm / Lec - "active in" - expanded after parsing string, may require further testing
			09-02-2013 03:00am / Daniel - ??
			09-02-2013 08:30am / Lec - corrected line 1651 select had "'='" and threw error so config would not process
			09-02-2013 - processing data for Jana, should be done 9am
		-->
			<xsl:function name="ycba_fn:pad-AAT-code">
				<xsl:param name="AATCode"/>
				<xsl:variable name="AAT_Code_Length">9</xsl:variable>
				<xsl:variable name="numZeroes" select="$AAT_Code_Length - (string-length($AATCode) + 1)" />
				<xsl:variable name="zeroes" select="ycba_fn:pad-helper($numZeroes, 0, '')" />
				<xsl:value-of select="concat('3', $zeroes, $AATCode)" />
			</xsl:function>	
		  
				<xsl:function name="ycba_fn:pad-helper">
					<xsl:param name="k"/>
					<xsl:param name="index"/>
					<xsl:param name="str"/>
					<xsl:if test="$index &lt; $k">
						<xsl:value-of select="ycba_fn:pad-helper($k, $index + 1, concat($str, '0'))"/>
					</xsl:if>
					<xsl:if test="$index = $k">
						<xsl:value-of select="$str"/>
					</xsl:if>
				</xsl:function>
				
		<!-- ycba_fn:urlencode(str)
			 Replaces special characters with a dash (-)
			 Usage: param1: string to be encoded for uri
		-->
			<xsl:function name="ycba_fn:urlencode">
				<xsl:param name="str"/>
				<xsl:variable name="temp" select="lower-case(string-join(tokenize($str, '[^!#$&amp;*+\--:=\?-\[\]_a-z~]+'), '_'))" />
				<xsl:choose>
					<xsl:when test="ends-with($temp,'_')">
						<xsl:value-of select="substring($temp, 0, string-length($temp))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$temp" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:function>	
			
		<!-- ycba_fn:get-prod-type(str)
			 Returns the production type given roleactor
			 Usage: str:
		-->
			<xsl:function name="ycba_fn:get-prod-type">
				<xsl:param name="str"/>
				<xsl:choose>
					<xsl:when test="$str='Artist'">
						<xsl:value-of>Artistic Production</xsl:value-of>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="replace($str, 'er', 'ing')" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:function>	
			
		<!-- ycba_fn:date-type(date)
			 Returns xsd type of the date entered
			 Usage: param1: date
		-->
			<xsl:function name="ycba_fn:date-type">
				<xsl:param name="date"/>
				<xsl:variable name="isgYearMonth" select="tokenize($date, '[0-9]{4}-(0[1-9]{1})|(1[0-1])')[1]=''"/>
				<xsl:choose>
					<xsl:when test="$isgYearMonth">
						<xsl:value-of select="'&xsd;gYearMonth'"></xsl:value-of>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="'&xsd;gYear'"></xsl:value-of>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:function>

		<!-- ycba_fn:is-influenced-by(term)
			 Returns true if term gets P15_influenced_by
			 Trivial function for sure, but prevents repetition
				Also easy to modify if valid terms change
			 Usage: param1: term
		-->
			<xsl:function name="ycba_fn:is-influenced-by">
				<xsl:param name="term"/>
				<xsl:value-of select="$term='After' or $term='Follower of' or $term='Imitator of' or $term='Style of'"/>
			</xsl:function>	
	 
	<!-- Does nothing for now. Useful to avoid printing the header info -->
	<xsl:template match="//record/header">
	
	</xsl:template>
	
	<!--
		See http://creativecommons.org/choose/mark/ and http://creativecommons.org/about/pdm
		Another option is CC0, see http://creativecommons.org/about/cc0
	-->
	<xsl:variable name="cck_mark_1">http://creativecommons.org/publicdomain/mark/1.0/</xsl:variable>
	
	<!-- MAIN ACTION -->
    <xsl:template match="//*[local-name() = 'lido']">
		<xsl:param name="MAIN_IMG_FORMAT_ID">2</xsl:param>
		<xsl:param name="DEEP_ZOOM_FORMAT_ID">7</xsl:param>
		<rdf:RDF
			xmlns:bmo="http://collection.britishmuseum.org/id/ontology/"
			xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
			xmlns:skos="http://www.w3.org/2004/02/skos/core#"
			xmlns:crm="http://erlangen-crm.org/current/"
			xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
			xmlns:dc="http://purl.org/dc/elements/1.1/"
			xmlns:exif="http://www.w3.org/2003/12/exif/ns#"
			xmlns:xsd="http://www.w3.org/2001/XMLSchema"
			xmlns:owl="http://www.w3.org/2002/07/owl#"
			xmlns:bibo="http://purl.org/ontology/bibo/"
			xmlns:geo-pos="http://www.w3.org/2003/01/geo/wgs84_pos#"
			xmlns:ycba="http://collection.britishart.yale.edu/id/"
		>	

			<!-- Thesauri -->

				<!-- Titles -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'titleWrap']/*[local-name() = 'titleSet']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/', ycba_fn:urlencode(@*[local-name() = 'type']))" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdfs:label"><xsl:value-of select="@*[local-name() = 'type']" /></xsl:element>
					</xsl:element>
					<xsl:element name="rdf:Description">
						<xsl:variable name="pref" select="*[local-name() = 'appellationValue']/@*[local-name() = 'pref']" />
						<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/', $pref)" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdfs:label"><xsl:value-of select="$pref" /></xsl:element>
					</xsl:element>
				</xsl:for-each>
			
			<!-- Main Object -->
				
				<xsl:variable name="objectUri"><xsl:value-of select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text())"/></xsl:variable>
				
				<xsl:element name="rdf:Description">
					<!-- Object uri -->
					<xsl:attribute name="rdf:about" select="$objectUri"/>
					
					<!-- Object Type -->
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E22_Man-Made_Object'"/>
					</xsl:element>
					
					<!-- Object label -->
					<xsl:element name="rdfs:label">
						<xsl:value-of select="//*[local-name() = 'titleWrap']/*[local-name() = 'titleSet']/*[local-name() = 'appellationValue'][@*[local-name() = 'pref']='preferred']/text()" />
					</xsl:element>
					
					<!-- Object Work Type -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'objectWorkTypeWrap']/*[local-name() = 'objectWorkType']">
						<xsl:choose>
							<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object name'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="crm:P2_has_type">
												<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
											</xsl:element>	
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="crm:P2_has_type">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/objecttype/', *[local-name() = 'conceptID']/text())"/>
											</xsl:element>	
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Genre'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', *[local-name() = 'conceptID']/text())"/>
											</xsl:element>	
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/genre/', *[local-name() = 'conceptID']/text())"/>
											</xsl:element>	
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object name'">
									<xsl:element name="crm:P2_has_type">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/objecttype/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
									</xsl:element>
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Genre'">
									<xsl:element name="crm:P62_depicts">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/genre/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
									</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>	
					</xsl:for-each>
					
					<!-- Object Classification -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'classificationWrap']/*[local-name() = 'classification']">
						<xsl:if test="*[local-name() = 'term']/text()!= ''">
							<xsl:element name="crm:P46i_forms_part_of">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;collection/', string-join(tokenize(*[local-name() = 'term']/text(), '\s+'), '-'))"/>
							</xsl:element>
						</xsl:if>	
					</xsl:for-each>
					
					<!-- Titles -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'titleWrap']/*[local-name() = 'titleSet']">
						<xsl:element name="crm:P102_has_title">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', //*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/title/', position())"/>
						</xsl:element>	
						<xsl:if test="@*[local-name() = 'type']='Alternate title'">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Alternate title :: ', *[local-name() = 'appellationValue'])"/>
							</xsl:element>
						</xsl:if>	
					</xsl:for-each>
					
					<!-- Collective Title = object is part of a collection -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'titleWrap']/*[local-name() = 'titleSet'][@*[local-name() = 'type']='Collective title']">
						<xsl:element name="crm:P46i_forms_part_of">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/series/', ycba_fn:urlencode(*[local-name() = 'appellationValue']))"/>
						</xsl:element>
						<xsl:element name="bmo:PX_display_wrap">
							<xsl:value-of select="concat('Component of series :: ', *[local-name() = 'appellationValue'])"/>
						</xsl:element>			
					</xsl:for-each>
					
					<!-- Inscriptions -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'inscriptionsWrap']/*[local-name() = 'inscriptions']">
						<xsl:if test="*[local-name() = 'inscriptionTranscription']/text() != '' ">
							<xsl:element name="crm:P65_shows_visual_item">
								<xsl:attribute name="rdf:resource" select="concat($objectUri, '/inscription/', position())"/>
							</xsl:element>			
						</xsl:if>
					</xsl:for-each>
					
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'eventWrap']/*[local-name() = 'eventSet']/*[local-name() = 'event']">
						<xsl:element name="crm:P108i_was_produced_by">
							<xsl:attribute name="rdf:resource" select="concat($objectUri, '/production')"/>
						</xsl:element>	
						<!-- Production -->
						<xsl:for-each select="*[local-name() = 'eventActor']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Production by :: ', *[local-name() = 'displayActorInRole'])"/>
							</xsl:element>							
						</xsl:for-each>
						
						<!-- Date -->
						<xsl:for-each select="*[local-name() = 'eventDate']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Production date :: ', *[local-name() = 'displayDate']/text())"/>
							</xsl:element>
													
						</xsl:for-each>
						
						<!-- Period -->
						<xsl:for-each select="*[local-name() = 'periodName']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Production Period / Culture :: ', *[local-name() = 'term']/text())"/>
							</xsl:element>						
						</xsl:for-each>
						
						<!-- Technique -->
						<xsl:for-each select="*[local-name() = 'eventMaterialsTech']/*[local-name() = 'materialsTech']/*[local-name() = 'termMaterialsTech']">
							<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='technique'">
								<xsl:element name="bmo:PX_display_wrap">
									<xsl:value-of select="concat('Uses technique :: ', *[local-name() = 'term']/text())"/>
								</xsl:element>	
							</xsl:if>
						</xsl:for-each>
						
					</xsl:for-each>
					
				<!-- Subject Terms: things describing the object, about the object -->
					<!-- Subject Terms -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectConcept']">
						<xsl:element name="bmo:PX_display_wrap">
							<xsl:value-of select="concat('Subject Concept :: ', *[local-name() = 'term']/text())"/>
						</xsl:element>	
						<xsl:element name="crm:P62_depicts">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
										</xsl:when>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='ICONCLASS'">
											<xsl:attribute name="rdf:resource" select="concat('&iconclass;', *[local-name() = 'conceptID']/text())"/>
										</xsl:when>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='LOC'">
											<xsl:attribute name="rdf:resource" select="concat('&loc_subjects;', *[local-name() = 'conceptID']/text())"/>
										</xsl:when>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='TGN'">
											<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'conceptID']/text())"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/subject/', *[local-name() = 'conceptID']/text())"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/subject/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>	
					</xsl:for-each>
					
					<!-- Subject Events -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectEvent']">
						<xsl:element name="bmo:PX_display_wrap">
							<xsl:value-of select="concat('Subject Event :: ', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']/text())"/>
						</xsl:element>	
						<xsl:element name="crm:P62_depicts">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text()!=-1">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text()))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/subject/', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text())"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/subject/', ycba_fn:urlencode(*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']/text()))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>	
					</xsl:for-each>
					
					<!-- Subject Place (P62_depicts) -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']">
						<xsl:if test="*[local-name() = 'subject']/@*[local-name() = 'type']='description'">
							<xsl:for-each select="*[local-name() = 'subject']/*[local-name() = 'subjectPlace']/*[local-name() = 'place']">
								<xsl:choose>
									<xsl:when test="*[local-name() = 'placeID']!='-1'">
										<xsl:element name="bmo:PX_display_wrap">
											<xsl:value-of select="concat('Subject Place :: ', *[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text())"/>
										</xsl:element>	
										<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'source']='TGN'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'])"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'source']='YCBA'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;place/YCBA/', *[local-name() = 'placeID'])"/>
											</xsl:element>
										</xsl:if>
									</xsl:when>
									
									<xsl:otherwise>
										<xsl:variable name="placeLabel" select="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text()" />
										<xsl:element name="bmo:PX_display_wrap">
											<xsl:value-of select="concat('Subject Place :: ', $placeLabel)"/>
										</xsl:element>	
										<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'source']='TGN'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', ycba_fn:urlencode($placeLabel))"/>
											</xsl:element>
										</xsl:if>
										<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'source']='YCBA'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;place/YCBA/', ycba_fn:urlencode($placeLabel))"/>
											</xsl:element>
										</xsl:if>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:if>
					</xsl:for-each>
					
					<!-- Subject Object -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectObject']">
						<xsl:element name="bmo:PX_display_wrap">
							<xsl:value-of select="concat('Subject Object :: ', *[local-name() = 'displayObject']/text())"/>
						</xsl:element>	
						<xsl:element name="crm:P128_carries">
							<xsl:attribute name="rdf:resource" select="concat($objectUri, '/concept/', position())"/>
						</xsl:element>	
					</xsl:for-each>
					
					<!-- Classification: type of object Frame, Print, Painting, etc. (bmo:PX_object_type) -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'classificationWrap']">
						<xsl:element name="bmo:PX_display_wrap">
							<xsl:value-of select="concat('Object type :: ', *[local-name() = 'classification']/*[local-name() = 'term']/text())"/>
						</xsl:element>	
						<!-- need else to catch other IDs -->
						<xsl:if test="*[local-name() = 'classification']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='ULAN'">
							<xsl:element name="bmo:PX_object_type">
								<xsl:attribute name="rdf:resource" select="concat('&getty_ulan;', *[local-name() = 'classification']/*[local-name() = 'conceptID']/text())" />
							</xsl:element>	
						</xsl:if>
					</xsl:for-each>
					
					<!-- lidoRecID -->
					<xsl:element name="crm:P1_is_identified_by">
						<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/lidoRecID')" />
					</xsl:element>
					
					<!-- TMS ObjectID -->
					<xsl:element name="crm:P1_is_identified_by">
						<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/TMS')" />
					</xsl:element>
					
					<!-- inventory number is now prefered identifier -->
					<xsl:element name="crm:P48_has_preferred_identifier">
						<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/inventory-number')" />
					</xsl:element>
					
					<!-- VuFind CCD ID -->
					<xsl:element name="crm:P1_is_identified_by">
						<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/ccd')" />
					</xsl:element>
					
					<!-- Material -->
					<xsl:for-each select="//*[local-name() = 'eventMaterialsTech']/*[local-name() = 'materialsTech']/*[local-name() = 'termMaterialsTech']">
						<xsl:variable name="techType" select="*[local-name() = 'conceptID']/@*[local-name() = 'type']" />
						<xsl:choose>
							<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
								<xsl:if test="$techType='support' or $techType='medium'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="crm:P45_consists_of">
												<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
											</xsl:element>	
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="crm:P45_consists_of">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/material/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$techType='support' or $techType='medium'">
									<xsl:element name="crm:P45_consists_of">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/material/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
									</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
					
					<!-- Acquisition -->
					<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'repositoryWrap']/*[local-name() = 'repositorySet'][@*[local-name() = 'type']='current']">
						<xsl:element name="crm:P24i_changed_ownership_through">
							<xsl:attribute name="rdf:resource" select="concat($objectUri, '/acquisition/')"/>
						</xsl:element>
						<xsl:element name="crm:P30i_custody_transferred_through">
							<xsl:attribute name="rdf:resource" select="concat($objectUri, '/acquisition/')"/>
						</xsl:element>
					
					<!-- Institution & Department (Current Keeper) -->
						<xsl:if test="*[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/@*[local-name() = 'source']='ULAN'">
							<xsl:element name="crm:P50_has_current_keeper">
								<xsl:attribute name="rdf:resource" select="concat('&getty_ulan;', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/text())"/>
							</xsl:element>
							<xsl:element name="crm:P52_has_current_owner">
								<xsl:attribute name="rdf:resource" select="concat('&getty_ulan;', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/text())"/>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
					
					<!-- Current location of object -->
						<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'repositoryWrap']/*[local-name() = 'repositorySet']/*[local-name() = 'repositoryLocation']/*[local-name() = 'partOfPlace']">
							<xsl:if test="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text()!=''">
								<xsl:element name="bmo:PX_display_wrap">
									<xsl:value-of select="concat('Located in :: ', *[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text())"/>
								</xsl:element>
								<xsl:element name="crm:P55_has_current_location">
									<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/location/', position())"/>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
						
					<!-- Subject Actor (P62_depicts) YCBA uses ULAN, VIAF, ODMP, & DBPEDIA -->
						<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectActor']">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']!='-1'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='ULAN'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&getty_ulan;', *[local-name() = 'actor']/*[local-name() = 'actorID'])"/>
											</xsl:element>
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='VIAF'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&viaf;', *[local-name() = 'actor']/*[local-name() = 'actorID'])"/>
											</xsl:element>
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='ODNB'">
										
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='DBPEDIA'">
										
										</xsl:when>
									</xsl:choose>
								</xsl:when>
								
								<xsl:otherwise> 
									<xsl:choose>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='ULAN'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&getty_ulan;', ycba_fn:urlencode(*[local-name() = 'term']))"/>
											</xsl:element>
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='VIAF'">
											<xsl:element name="crm:P62_depicts">
												<xsl:attribute name="rdf:resource" select="concat('&viaf;', ycba_fn:urlencode(*[local-name() = 'term']))"/>
											</xsl:element>
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='ODNB'">
										
										</xsl:when>
										<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']='DBPEDIA'">
										
										</xsl:when>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					
					<!-- Object Rights -->
						<xsl:for-each select="//*[local-name() = 'administrativeMetadata']/*[local-name() = 'rightsWorkWrap']/*[local-name() = 'rightsWorkSet']">
							<!--xsl:element name="bmo:PX_has_credit_line">
								<xsl:value-of select="*[local-name() = 'creditLine']"/>
							</xsl:element-->
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Rights :: ', *[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyName']/*[local-name() = 'appellationValue'])"/>
							</xsl:element>
							<xsl:choose>
							<xsl:when test="*[local-name() = 'rightsType']/*[local-name() = 'conceptID']='public domain'">
								<xsl:element name="crm:P104_is_subject_to">
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="$cck_mark_1"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:when test="*[local-name() = 'rightsType']/*[local-name() = 'conceptID']='under copyright'">
								<xsl:element name="crm:P104_is_subject_to">
									<xsl:attribute name="rdf:resource">
										<xsl:value-of select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/copyright')"/>
									</xsl:attribute>
								</xsl:element>
							</xsl:when>
							<xsl:otherwise>
								<xsl:message terminate="no">Warning: Object Rights not processed</xsl:message>
							</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						
					<!-- Publications / Bibliography -->
						<xsl:for-each select="//*[local-name() = 'relatedWorkSet']/*[local-name() = 'relatedWork']/*[local-name() = 'displayObject'][../../*[local-name() = 'relatedWorkRelType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='publication']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Bibliograpic reference :: ', ../*[local-name() = 'object']/*[local-name() = 'objectNote']/text())"/>
							</xsl:element>
							<xsl:element name="crm:P70i_is_documented_in">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;bibliography/', ../*[local-name() = 'object']/*[local-name() = 'objectID'][@*[local-name() = 'source']='YCBA'])"/>
							</xsl:element>
						</xsl:for-each>
						
					<!-- Exhibitions -->
						<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'eventWrap']/*[local-name() = 'eventSet']/*[local-name() = 'displayEvent'][../*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']='exhibition history']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Exhibition :: ', .)"/>
							</xsl:element>
							<xsl:element name="crm:P12i_was_present_at">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;exhibition/', ../*[local-name() = 'event']/*[local-name() = 'eventID'])"/>
							</xsl:element>
						</xsl:for-each>
						
					<!-- Curatorial comment -->
						<xsl:variable name="comment">
							<xsl:value-of select="//*[local-name() = 'eventSet']/*[local-name() = 'displayEvent'][../*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']='Curatorial comment']"/>
						</xsl:variable>
						<xsl:if test="$comment!=''">
							<xsl:element name="bmo:PX_curatorial_comment">
								<xsl:value-of select="$comment"/>
							</xsl:element>
						</xsl:if>
						
					<!-- Measurements -->
						<!--
						<xsl:for-each select="//*[local-name() = 'objectMeasurementsWrap']/*[local-name() = 'objectMeasurementsSet']/*[local-name() = 'objectMeasurements']/*[local-name() = 'measurementsSet']">
							<xsl:element name="bmo:PX_display_wrap">
								<xsl:value-of select="concat('Dimension ', *[local-name() = 'measurementType'], ' :: ', *[local-name() = 'measurementValue'], *[local-name() = 'measurementUnit'])"/>
							</xsl:element>
							
							<xsl:choose>
						-->
								<!-- object height -->
						<!--
								<xsl:when test="*[local-name() = 'measurementType']='height'">
									<xsl:element name="crm:P43_has_dimension">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/height')"/>
									</xsl:element>
								</xsl:when>
						-->		
								<!-- object width -->
						<!--
								<xsl:when test="*[local-name() = 'measurementType']='width'">
									<xsl:element name="crm:P43_has_dimension">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/width')"/>
									</xsl:element>
								</xsl:when>
						-->		
								<!-- object depth -->
						<!--
								<xsl:when test="*[local-name() = 'measurementType']='depth'">
									<xsl:element name="crm:P43_has_dimension">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/depth')"/>
									</xsl:element>
								</xsl:when>
							</xsl:choose>
							<xsl:if test="position()=1">
								<xsl:element name="crm:P39i_was_measured_by">
									<xsl:attribute name="rdf:resource" select="concat($objectUri, '/measurement')"/>
								</xsl:element>
							</xsl:if>
							
						</xsl:for-each>
						-->
				</xsl:element>
			<!-- ===================================== End of main object===================================== -->

									
			<!-- Activity (element children) -->
			<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'eventWrap']/*[local-name() = 'eventSet']/*[local-name() = 'event']/*[local-name() = 'eventActor']" >
			<xsl:choose>
				<!-- "active in" -->
				<xsl:when test="contains(lower-case(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()),'active in')">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text(), '/activity')"/>
						</xsl:attribute>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E7_Activity'"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:value-of select="concat('&ycba_thesauri;', 'activity/active')"/>
						</xsl:element>
						<xsl:element name="crm:P7_took_place_at">
							<xsl:variable name="activity_place" select="tokenize(normalize-space(lower-case(substring-after(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor'],'active in'))), ' ')" />
							<xsl:value-of select="concat('&ycba_thesauri;place/', $activity_place[1])"/>
						</xsl:element>						
						<!--xsl:element name="crm:P4_has_time-span">
							<xsl:value-of select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text(), '/activity/date')"/>
						</xsl:element-->		
					</xsl:element>
				</xsl:when>
				<!-- "born in" -->
				<xsl:when test="contains(lower-case(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()),'born in')">
				</xsl:when>
			</xsl:choose>
			</xsl:for-each>
			
			<!-- Object Rights (element children) -->
			<xsl:for-each select="//*[local-name() = 'administrativeMetadata']/*[local-name() = 'rightsWorkWrap']/*[local-name() = 'rightsWorkSet']">
			<xsl:choose>
				<!-- public domain -->
				<xsl:when test="*[local-name() = 'rightsType']/*[local-name() = 'conceptID']='public domain'">
					<xsl:element name="rdf:Description">			<!-- Must be there for every group of triples -->
						<xsl:attribute name="rdf:about">			<!-- Must be there for every group of triples -->
							<xsl:value-of select="$cck_mark_1"/>	<!-- getting variable URI defined on top -->
						</xsl:attribute>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E30_Right'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">Public Domain Mark</xsl:element>
					</xsl:element>
				</xsl:when>
				<!-- under copyright -->
				<xsl:when test="*[local-name() = 'rightsType']/*[local-name() = 'conceptID']='under copyright'">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/copyright')"/>
						</xsl:attribute>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E30_Right'"/>
						</xsl:element>
						<!--xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyName']/*[local-name() = 'appellationValue']/text()"/>
						</xsl:element-->
						<xsl:element name="crm:P3_has_note">
							<xsl:value-of select="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyName']/*[local-name() = 'appellationValue']/text()"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">http://britishart.yale.edu/terms/imaging/under_copyright</xsl:element>
						<xsl:element name="crm:P105_right_held_by">
								<xsl:value-of select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/copyright/owner')"/>
						</xsl:element>
					</xsl:element>
					
					<!-- Copyright owner -->
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about">
							<xsl:value-of select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/copyright/owner')"/>
						</xsl:attribute>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E39_Actor'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyWeblink']/text()"/>
						</xsl:element>
					</xsl:element>
					
					<!-- image terms -->
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about">http://britishart.yale.edu/terms/imaging/under_copyright</xsl:attribute>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">Under copyright</xsl:element>
					</xsl:element>
				</xsl:when>
			</xsl:choose>
			</xsl:for-each>
  
			<!-- Object Work Type -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'objectWorkTypeWrap']/*[local-name() = 'objectWorkType']">
						<xsl:choose>
							<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object name'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/objecttype'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()" />
												</xsl:element>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/objecttype/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/objecttype'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()" />
												</xsl:element>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Genre'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/genre/'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()" />
												</xsl:element>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/genre/', *[local-name() = 'conceptID']/text())" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/genre/'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()" />
												</xsl:element>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object name'">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/objecttype/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/objecttype'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()" />
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'type']='Genre'">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/genre/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/genre/'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()" />
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>	
					</xsl:for-each>
			
			<!-- Object Classification -->
					<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'classificationWrap']/*[local-name() = 'classification']">
						<xsl:if test="*[local-name() = 'term']/text()!=''">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="concat('&ycba;collection/', string-join(tokenize(*[local-name() = 'term']/text(), '\s+'), '-'))" />
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E78_Collection'"/>
								</xsl:element>
								<xsl:element name="rdfs:label"><xsl:value-of select="*[local-name() = 'term']/text()" /></xsl:element>
							</xsl:element>	
						</xsl:if>
					</xsl:for-each>
			
			<!-- Titles -->
			
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'titleWrap']/*[local-name() = 'titleSet']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&ycba;object/', //*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/title/', position())"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E35_Title'"/>
						</xsl:element>
						<xsl:if test="*[local-name() = 'appellationValue']/@*[local-name() = 'pref']='preferred'">
							<xsl:element name="crm:P2_has_type">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/', *[local-name() = 'appellationValue']/@*[local-name() = 'pref'])"/>
							</xsl:element>
						</xsl:if>
						<xsl:if test="@*[local-name() = 'type']!='Repository title'">
							<xsl:element name="crm:P2_has_type">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/', ycba_fn:urlencode(@*[local-name() = 'type']))"/>
							</xsl:element>
						</xsl:if>
						<!--xsl:choose>
							<xsl:when test="*[local-name() = 'appellationValue']/@*[local-name() = 'pref'] = 'preferred'">
								
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:about" select="concat('&ycba;object/', //*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/title/', position())"/>
							</xsl:otherwise>
						</xsl:choose-->
						<xsl:element name="rdfs:label"><xsl:value-of select="*[local-name() = 'appellationValue']/text()" /></xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			<!-- Collective Title = object is part of a collection -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'titleWrap']/*[local-name() = 'titleSet'][@*[local-name() = 'type']='Collective title']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&ycba;object/', ../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/series/', ycba_fn:urlencode(*[local-name() = 'appellationValue']))" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E78_Collection'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'appellationValue']"/>
						</xsl:element>	
					</xsl:element>
				</xsl:for-each>
				
			<!-- Inscriptions -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'inscriptionsWrap']/*[local-name() = 'inscriptions']">
					<xsl:if test="*[local-name() = 'inscriptionTranscription']/text() != '' ">
					<xsl:variable name="inscriptionType">
						<xsl:value-of select="lower-case(string-join(tokenize(@*[local-name() = 'type'], '\s+'), '-'))" />
					</xsl:variable>
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat($objectUri, '/inscription/', position())" />
						<xsl:element name="rdf:type">
							<xsl:choose>
								<xsl:when test="@*[local-name() = 'type']='Marks'">
									<xsl:attribute name="rdf:resource" select="'&crm;E37_Mark'"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="rdf:resource" select="'&crm;E34_Inscription'"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'inscriptionTranscription']/text()"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/inscription/', $inscriptionType)"/>
						</xsl:element>	
					</xsl:element>
					
					<xsl:element name="rdf:Description">	
						<xsl:attribute name="rdf:about" select="concat('&ycba;inscription/', $inscriptionType)" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
						</xsl:element>
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="@*[local-name() = 'type']"/>
						</xsl:element>
						<xsl:element name="skos:inScheme">
							<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/inscription/'"/>
						</xsl:element>	
					</xsl:element>
					</xsl:if>
				</xsl:for-each>
				
				<!-- Inscriptions - Concept Scheme -->
				<xsl:if test="count(*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'inscriptionsWrap']/*[local-name() = 'inscriptions'])>0">
					<xsl:element name="rdf:Description">	
						<xsl:attribute name="rdf:about" select="'&ycba;inscription/'" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;ConceptScheme'"/>
						</xsl:element>
						<xsl:element name="skos:prefLabel">Inscription Type</xsl:element>
					</xsl:element>
				</xsl:if>
				
			<!-- Production-related triples -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'eventWrap']/*[local-name() = 'eventSet']/*[local-name() = 'event'][*[local-name() = 'eventType']/*[local-name() = 'term']/text()='production']">
					
					<xsl:variable name="prodUri" select="'fixme!'" />
					<xsl:variable name="prodUriBase" select="concat($objectUri, '/production')" />
					<xsl:variable name="prodCounter">0</xsl:variable>
					
				<!-- Main Production Object -->
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="$prodUriBase" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E12_Production'"/>
						</xsl:element>
						
						<!-- eventActor -->
						<xsl:for-each select="*[local-name() = 'eventActor']">
							<xsl:variable name="updatedCounter" select="(position()+$prodCounter)" />
							<xsl:variable name="prodUri" select="concat($prodUriBase, '/', $updatedCounter)" />
							<xsl:element name="crm:P9_consists_of">
								<xsl:attribute name="rdf:resource" select="$prodUri"/>
							</xsl:element>
						</xsl:for-each>
						
						<xsl:variable name="prodCounter" select="$prodCounter+count(*[local-name() = 'eventActor'])" />
					
						<!-- Technique -->
						<xsl:variable name="techniqueNode" select="*[local-name() = 'eventMaterialsTech']/*[local-name() = 'materialsTech']/*[local-name() = 'termMaterialsTech'][*[local-name() = 'conceptID']/@*[local-name() = 'type']='technique']" />
						<xsl:for-each select="$techniqueNode">	
							<xsl:variable name="updatedCounter" select="(position()+$prodCounter)" />
							<xsl:variable name="prodUri" select="concat($prodUriBase, '/', $updatedCounter)" />
							<xsl:element name="crm:P9_consists_of">
								<xsl:attribute name="rdf:resource" select="$prodUri"/>
							</xsl:element>										
						</xsl:for-each>
					</xsl:element>
					
					<!-- eventActor -->
						<xsl:for-each select="*[local-name() = 'eventActor']">
							<xsl:variable name="updatedCounter" select="(position()+$prodCounter)" />
							<xsl:variable name="prodUri" select="concat($prodUriBase, '/', $updatedCounter)" />
							<xsl:variable name="roleActor" select="*[local-name() = 'actorInRole']/*[local-name() = 'roleActor'][*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object related role']/*[local-name() = 'term']/text()"/>
								
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="$prodUri" />
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E12_Production'"/>
								</xsl:element>
								
								<!-- person -->
								<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
									<xsl:element name="crm:P14_carried_out_by">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
									</xsl:element>	
								</xsl:if>
								
								<!-- Corporation -->
								<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
									<xsl:element name="crm:P14_carried_out_by">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
									</xsl:element>	
								</xsl:if>
								
								<!-- YCBA type -->
								<xsl:if test="$roleActor!=''">
									<xsl:element name="crm:P2_has_type">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/production/', ycba_fn:urlencode(ycba_fn:get-prod-type($roleActor)))"/>
									</xsl:element>	
								</xsl:if>
								
								<!-- Date -->
								<xsl:if test="position()=1">
									<xsl:for-each select="../*[local-name() = 'eventDate']">
										<xsl:element name="crm:P4_has_time-span">
											<xsl:attribute name="rdf:resource" select="concat($prodUri, '/date')"/>
										</xsl:element>
									</xsl:for-each>
								</xsl:if>
							</xsl:element>	
							
							<!-- YCBA type -->
								<xsl:if test="$roleActor!=''">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/production/', ycba_fn:urlencode(ycba_fn:get-prod-type($roleActor)))"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/production'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="ycba_fn:get-prod-type($roleActor)"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								
							<!-- Date -->
								<xsl:if test="position()=1">
									<xsl:for-each select="../*[local-name() = 'eventDate']">
										<xsl:element name="rdf:Description">
											<xsl:attribute name="rdf:about" select="concat($prodUri, '/date')"/>
											<xsl:element name="rdf:type">
												<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
											</xsl:element>
											<xsl:element name="rdfs:label">
												<xsl:value-of select="*[local-name() = 'displayDate']"/>
											</xsl:element>
											<xsl:choose>
												<!-- if you have one date, better use P82 instead of P82a+P82b -->
												<xsl:when test="*[local-name() = 'date']/*[local-name() = 'earliestDate']=*[local-name() = 'date']/*[local-name() = 'latestDate']">
													<xsl:element name="crm:P82_at_some_time_within">
														<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'date']/*[local-name() = 'earliestDate'])"/>
														<xsl:value-of select="*[local-name() = 'date']/*[local-name() = 'earliestDate']"/>
													</xsl:element>
												</xsl:when>
												<xsl:otherwise>
													<xsl:element name="crm:P82a_begin_of_the_begin">
														<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'date']/*[local-name() = 'earliestDate'])"/>
														<xsl:value-of select="*[local-name() = 'date']/*[local-name() = 'earliestDate']"/>
													</xsl:element>
													<xsl:element name="crm:P82b_end_of_the_end">
														<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'date']/*[local-name() = 'latestDate'])"/>
														<xsl:value-of select="*[local-name() = 'date']/*[local-name() = 'latestDate']"/>
													</xsl:element>	
												</xsl:otherwise>
											</xsl:choose>
										</xsl:element>							
									</xsl:for-each>
								</xsl:if>
								
							<!-- Qualification -->
								<xsl:variable name="qualificationLabel" select="*[local-name() = 'actorInRole']/*[local-name() = 'attributionQualifierActor']"/>
								<xsl:variable name="qualificationUri">
									<xsl:choose>
										<xsl:when test="ycba_fn:is-influenced-by($qualificationLabel)">
											<xsl:value-of select="concat('&ycba;thesauri/likelihood/', ycba_fn:urlencode($qualificationLabel))"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="concat('&ycba;thesauri/qualification/', ycba_fn:urlencode($qualificationLabel))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								
								<xsl:if test="$qualificationLabel!=''">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat($prodUri, '/association')"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&bmo;EX_Association'"/>
										</xsl:element>
										<xsl:element name="crm:P140_assigned_attribute_to">
											<xsl:attribute name="rdf:resource" select="$prodUri"/>
										</xsl:element>
										
										<!-- person -->
										<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
											<xsl:element name="crm:P141_assigned">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
											</xsl:element>	
										</xsl:if>
										
										<!-- Corporation -->
										<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
											<xsl:element name="crm:P141_assigned">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
											</xsl:element>	
										</xsl:if>
										
										<xsl:element name="bmo:PX_property">
											<xsl:choose>
												<xsl:when test="ycba_fn:is-influenced-by($qualificationLabel)">
													<xsl:attribute name="rdf:resource" select="'&crm;P15_was_influenced_by'"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="rdf:resource" select="'&crm;P14_carried_out_by'"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:element>
										<xsl:element name="crm:P2_has_type">
											<xsl:attribute name="rdf:resource" select="$qualificationUri"/>
										</xsl:element>
									</xsl:element>
								
								<!-- Qualification thesauri -->
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="$qualificationUri"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/qualification'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="$qualificationLabel"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								
							<!-- 
								<xsl:variable name="likelihoodLabel" select="*[local-name() = 'actorInRole']/*[local-name() = 'roleActor'][*[local-name() = 'conceptID']/@*[local-name() = 'type']='Object related role']/*[local-name() = 'term']"/>
								<xsl:if test="ycba_fn:is-influenced-by($likelihoodLabel)='true'">
									<xsl:variable name="likelihoodUri">
										<xsl:value-of select="concat('&ycba;thesauri/likelihood/', ycba_fn:urlencode($likelihoodLabel))"/>
									</xsl:variable>
									
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat($prodUri, '/association')"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&bmo;EX_Association'"/>
										</xsl:element>
										<xsl:element name="crm:P140_assigned_attribute_to">
											<xsl:attribute name="rdf:resource" select="$prodUri"/>
										</xsl:element>
										
										<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
											<xsl:element name="crm:P141_assigned">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
											</xsl:element>	
										</xsl:if>
										
										<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
											<xsl:element name="crm:P141_assigned">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
											</xsl:element>	
										</xsl:if>
										
										<xsl:element name="bmo:PX_property">
											<xsl:choose>
												<xsl:when test="ycba_fn:is-influenced-by($likelihoodLabel)">
													<xsl:attribute name="rdf:resource" select="'&crm;P15_was_influenced_by'"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="rdf:resource" select="'&crm;P14_carried_out_by'"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:element>
										<xsl:element name="crm:P2_has_type">
											<xsl:attribute name="rdf:resource" select="$likelihoodUri"/>
										</xsl:element>
									</xsl:element>
								
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="$likelihoodUri"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/likelihood'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="$qualificationLabel"/>
										</xsl:element>
									</xsl:element>
								</xsl:if-->
						</xsl:for-each>
						
					<xsl:variable name="prodCounter" select="$prodCounter+count(*[local-name() = 'eventActor'])" />
					
					<!-- Technique -->
						<xsl:variable name="techniqueNode" select="*[local-name() = 'eventMaterialsTech']/*[local-name() = 'materialsTech']/*[local-name() = 'termMaterialsTech'][*[local-name() = 'conceptID']/@*[local-name() = 'type']='technique']" />
						<xsl:for-each select="$techniqueNode">						
							<xsl:variable name="updatedCounter" select="(position()+$prodCounter)" />
							<xsl:variable name="prodUri" select="concat($prodUriBase, '/', $updatedCounter)" />
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="$prodUri" />
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E12_Production'"/>
								</xsl:element>
								<xsl:element name="crm:P32_used_general_technique">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/text() != -1">
											<xsl:choose>
												<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source'] = 'AAT'">
													<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/technique/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
												</xsl:otherwise>
											</xsl:choose>								
										</xsl:when>
										<xsl:otherwise>		
											<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/technique/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>										
							</xsl:element>										
						</xsl:for-each>
					
					<xsl:variable name="prodCounter" select="$prodCounter+count($techniqueNode)" />
					
					<!-- Production -->
						<!--xsl:element name="rdf:Description">
							<xsl:attribute name="rdf:about" select="$prodUri" />
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&crm;E12_Production'"/>
							</xsl:element-->
						
							<!-- Period -->
							<!--xsl:for-each select="*[local-name() = 'periodName']">
								<xsl:element name="crm:P10_falls_within">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
											<xsl:choose>
												<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
													<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>								
							</xsl:for-each-->
							
							<!-- Culture -->
							<!--xsl:for-each select="*[local-name() = 'culture']">
								<xsl:element name="crm:P10_falls_within">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
											<xsl:choose>
												<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
													<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>								
							</xsl:for-each-->
							
						<!--/xsl:element-->
						
					<!-- Event Actor -->
					<xsl:for-each select="*[local-name() = 'eventActor']">
						
					<!-- Person -->
						<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E21_Person'"/>
								</xsl:element>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
								</xsl:element>
								<xsl:element name="skos:inScheme">
									<xsl:attribute name="rdf:resource" select="'&ycba;person-institution'"/>
								</xsl:element>
								
								<!-- name(s) -->
								<xsl:for-each select="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']" >
									<xsl:choose>
										<xsl:when test="@*[local-name() = 'pref'] != 'preferred'">
											<xsl:element name="skos:altLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="skos:prefLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
								
								<!-- Vital Dates -->
								<xsl:for-each select="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'vitalDatesActor']" >
									
									<!-- Birth -->
									<xsl:element name="crm:P98i_was_born">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/birth')"/>
									</xsl:element>
									
									<!-- Death -->
									<xsl:element name="crm:P100i_died_in">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/death')"/>
									</xsl:element>
								</xsl:for-each>
								
								<!-- Gender -->
								<xsl:element name="bmo:PX_gender">
									<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/gender/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'genderActor']/text())"/>
								</xsl:element>
								
								<!-- Nationality -->
								<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term'] != ''">
									<xsl:variable name="nation" select="tokenize(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text(), ',')" />
									
									<xsl:element name="bmo:PX_nationality">
										<!--xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/nationality/', ycba_fn:urlencode(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()))"/-->
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/nationality/', ycba_fn:urlencode($nation[1]))"/>
									</xsl:element>
									<!-- check case if nationality string contains: "active in" or "born in" -->
									<xsl:choose>
										<!-- "active in" -->
										<xsl:when test="contains(lower-case(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()),'active in')">
											<xsl:element name="crm:P14i_performed">
												<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text(), '/activity')"/>
											</xsl:element>
										</xsl:when>
										<!-- "born in" -->
										<xsl:when test="contains(lower-case(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()),'born in')">
										</xsl:when>
									</xsl:choose>
								</xsl:if>
							</xsl:element>
							
							<xsl:for-each select="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'vitalDatesActor']" >
							
							<!-- Birth -->
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/birth')"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E67_Birth'"/>
									</xsl:element>
									<xsl:element name="crm:P4_has_time-span">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/birth/date')"/>
									</xsl:element>
								</xsl:element>	
								
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/birth/date')"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
									</xsl:element>
									<xsl:element name="rdfs:label">
										<xsl:value-of select="*[local-name() = 'earliestDate']"/>
									</xsl:element>
									<xsl:choose>
										<!-- if you have one date, better use P82 instead of P82a+P82b -->
										<xsl:when test="*[local-name() = 'earliestDate']=*[local-name() = 'latestDate']">
											<xsl:element name="crm:P82a_begin_of_the_begin">
												<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'earliestDate'])"/>
												<xsl:value-of select="*[local-name() = 'earliestDate']"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="crm:P82a_begin_of_the_begin">
												<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'earliestDate'])"/>
												<xsl:value-of select="*[local-name() = 'earliestDate']"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
									
								</xsl:element>	
							
							<!-- Death -->
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/death')"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E69_Death'"/>
									</xsl:element>
									<xsl:element name="crm:P4_has_time-span">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/death/date')"/>
									</xsl:element>
								</xsl:element>	
								
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/death/date')"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
									</xsl:element>
									<xsl:element name="rdfs:label">
										<xsl:value-of select="*[local-name() = 'latestDate']"/>
									</xsl:element>
									<xsl:choose>
										<!-- if you have one date, better use P82 instead of P82a+P82b -->
										<xsl:when test="*[local-name() = 'earliestDate']=*[local-name() = 'latestDate']">
											<xsl:element name="crm:P82a_begin_of_the_begin">
												<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'latestDate'])"/>
												<xsl:value-of select="*[local-name() = 'latestDate']"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="crm:P82b_end_of_the_end">
												<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'latestDate'])"/>
												<xsl:value-of select="*[local-name() = 'latestDate']"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>	
							</xsl:for-each>
							
							<!-- Nationality Thesauri-->
								<xsl:variable name="nationality" select="tokenize(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text(), ',')" />
								<xsl:if test="$nationality != ''">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/nationality/', ycba_fn:urlencode($nationality[1]))"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E74_Group'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/nationality'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="$nationality[1]"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
						</xsl:if>
						
					<!-- Corporation -->
						<xsl:if test="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', *[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E74_Group'"/>
								</xsl:element>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
								</xsl:element>
								<xsl:element name="skos:inScheme">
									<!-- asking vlado about this -->
									<xsl:attribute name="rdf:resource" select="'&getty_ulan;person-institution'"/>
								</xsl:element>
								
								<!-- name(s) -->
								<xsl:for-each select="*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']" >
									<xsl:choose>
										<xsl:when test="*[local-name() = 'pref'] = 'preferred'">
											<xsl:element name="skos:prefLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="skos:altLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
						
					<!-- Period -->
						<xsl:for-each select="*[local-name() = 'periodName']">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/periods'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>								
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/periods/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/periods'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>								
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/periods/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/periods'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()"/>
										</xsl:element>								
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>	
						
					<!-- Culture -->
						<xsl:for-each select="*[local-name() = 'culture']">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E4_Period'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<!-- corrected this select had "'='" in front of it -->
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/matcult'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>								
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E4_Period'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/matcult'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>								
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/matcult/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E4_Period'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/matcult'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()"/>
										</xsl:element>								
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>	
					
				</xsl:for-each>
				
			
				
			<!-- Subject Terms -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectConcept']">
					<xsl:element name="rdf:Description">
						<xsl:choose>
							<xsl:when test="*[local-name() = 'conceptID']!='-1'">
								<xsl:choose>
									<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='ICONCLASS'">
										<xsl:attribute name="rdf:about" select="concat('&iconclass;', *[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='LOC'">
										<xsl:attribute name="rdf:about" select="concat('&loc_subjects;', *[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
										<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
										
									</xsl:when>
									<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='TGN'">
										<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<!-- Source is not defined -->
									<xsl:otherwise>
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/subject/', *[local-name() = 'conceptID']/text())"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/subject/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
						</xsl:element>
						<xsl:choose>
						<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
							<xsl:element name="skos:inScheme">
								<xsl:attribute name="rdf:resource" select="'&getty_aat;subject/'"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="skos:inScheme">
								<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/subject/'"/>
							</xsl:element>
						</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="*[local-name() = 'term']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
			
			<!-- Subject Object -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectObject']">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'conceptID']!='-1'">
							<xsl:variable name="subjectUri" select="concat($objectUri, '/concept/', position())" />
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="$subjectUri"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E73_Information_Object'"/>
								</xsl:element>
								
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='LOC'">
									<xsl:element name="crm:P129_is_about">
										<xsl:attribute name="rdf:resource" select="concat('&loc_subjects;', *[local-name() = 'conceptID']/text())"/>
									</xsl:element>	
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
									<xsl:element name="crm:P129_is_about">
										<xsl:attribute name="rdf:resource" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
									</xsl:element>	
								</xsl:if>
								<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='local'">
									<xsl:element name="crm:P129_is_about">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;', *[local-name() = 'conceptID']/text())"/>
									</xsl:element>	
								</xsl:if>
							</xsl:element>
							
							<!-- Subject Thesauri -->
							<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='LOC'">
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&loc_subjects;', *[local-name() = 'conceptID']/text())"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
									</xsl:element>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
									</xsl:element>
									<xsl:element name="skos:inScheme">
										<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/subject'"/>
									</xsl:element>
									<xsl:element name="skos:prefLabel">
										<xsl:value-of select="*[local-name() = 'term']/text()"/>
									</xsl:element>	
								</xsl:element>
							</xsl:if>
							<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
									</xsl:element>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
									</xsl:element>
									<xsl:element name="skos:inScheme">
										<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/subject'"/>
									</xsl:element>
									<xsl:element name="skos:prefLabel">
										<xsl:value-of select="*[local-name() = 'term']/text()"/>
									</xsl:element>	
								</xsl:element>
							</xsl:if>
							<xsl:if test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='local'">
								<xsl:element name="rdf:Description">
									<xsl:attribute name="rdf:about" select="concat('&ycba;', *[local-name() = 'conceptID']/text())"/>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
									</xsl:element>
									<xsl:element name="rdf:type">
										<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
									</xsl:element>
									<xsl:element name="skos:inScheme">
										<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/place'"/>
									</xsl:element>
									<xsl:element name="skos:prefLabel">
										<xsl:value-of select="*[local-name() = 'term']/text()"/>
									</xsl:element>	
								</xsl:element>										
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/', ycba_fn:urlencode(*[local-name() = 'term']/text()))"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
								</xsl:element>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
								</xsl:element>
								<xsl:element name="skos:inScheme">
									<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/place'"/>
								</xsl:element>
								<xsl:element name="skos:prefLabel">
									<xsl:value-of select="*[local-name() = 'term']/text()"/>
								</xsl:element>	
							</xsl:element>	
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
			
			<!-- Subject Events -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectEvent']">
					<xsl:element name="rdf:Description">
						<xsl:choose>
							<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']!='-1'">
								<xsl:choose>
									<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='ICONCLASS'">
										<xsl:attribute name="rdf:about" select="concat('&iconclass;', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='LOC'">
										<xsl:attribute name="rdf:about" select="concat('&loc_subjects;', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
										<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text()))"/>
										
									</xsl:when>
									<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='TGN'">
										<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text())"/>
									</xsl:when>
									<!-- source not defined -->
									<xsl:otherwise>
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/subject/', *[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/text())"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/subject/', ycba_fn:urlencode(*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']/text()))"/>
							</xsl:otherwise>
						</xsl:choose>
						
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
						</xsl:element>
						<xsl:choose>
						<xsl:when test="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
							<xsl:element name="skos:inScheme">
								<xsl:attribute name="rdf:resource" select="'&getty_aat;subject/'"/>
							</xsl:element>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="skos:inScheme">
								<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/subject/'"/>
							</xsl:element>
						</xsl:otherwise>
						</xsl:choose>
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			<!-- Subject Place (P62_depicts) -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']">
					<xsl:if test="*[local-name() = 'subject']/@*[local-name() = 'type']='description'">
						<xsl:for-each select="*[local-name() = 'subject']/*[local-name() = 'subjectPlace']/*[local-name() = 'place']">
							<xsl:choose>
								<xsl:when test="*[local-name() = 'placeID']!='-1'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'placeID']/@*[local-name() = 'source']='TGN'">
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'])"/>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Place'"/>
												</xsl:element>
												<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
													<xsl:element name="skos:inScheme">
														<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
													</xsl:element>
												</xsl:if>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']"/>
												</xsl:element>
												<xsl:element name="crm:P87_is_identified_by">
													<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/coordinates')"/>
												</xsl:element>
												<xsl:element name="geo-pos:location">
													<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/location')"/>
												</xsl:element>	
											</xsl:element>
											
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/coordinates')"/>
												<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
													<xsl:element name="skos:inScheme">
														<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
													</xsl:element>
												</xsl:if>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E47_Spatial_Coordinates'"/>
												</xsl:element>
												<xsl:element name="crm:P90_has_value">
													<xsl:value-of select="concat('&getty_tgn;', *[local-name() = 'gml']/*[local-name() = 'Point']/*[local-name() = 'coordinates'])"/>
												</xsl:element>	
											</xsl:element>
											
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/location')"/>
												<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
													<xsl:element name="skos:inScheme">
														<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
													</xsl:element>
												</xsl:if>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&geo-pos;SpatialThing'"/>
												</xsl:element>
												<xsl:element name="geo-pos:Point">
													<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/location/point')"/>
												</xsl:element>	
											</xsl:element>
											
											<xsl:element name="rdf:Description">
												<xsl:variable name="coords" select="tokenize(*[local-name() = 'gml']/*[local-name() = 'Point']/*[local-name() = 'coordinates']/text(), '[, ]+')" />
												<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/location/point')"/>
												<xsl:element name="geo-pos:lat">
													<xsl:value-of select="$coords[1]"/>
												</xsl:element>
												<xsl:element name="geo-pos:long">
													<xsl:value-of select="$coords[2]"/>
												</xsl:element>	
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:choose>
												<xsl:when test="*[local-name() = 'placeID']/@*[local-name() = 'source']='YCBA'">
													<xsl:element name="rdf:Description">
														<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'])"/>
														<xsl:element name="rdf:type">
															<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
														</xsl:element>
														<xsl:element name="rdf:type">
															<xsl:attribute name="rdf:resource" select="'&skos;Place'"/>
														</xsl:element>
														<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
															<xsl:element name="skos:inScheme">
																<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
															</xsl:element>
														</xsl:if>
														<xsl:element name="skos:prefLabel">
															<xsl:value-of select="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']"/>
														</xsl:element>
														<xsl:element name="crm:P87_is_identified_by">
															<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/coordinates')"/>
														</xsl:element>	
													</xsl:element>
													
													<xsl:element name="rdf:Description">
														<xsl:attribute name="rdf:about" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/coordinates')"/>
														<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
															<xsl:element name="skos:inScheme">
																<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
															</xsl:element>
														</xsl:if>
														<xsl:element name="rdf:type">
															<xsl:attribute name="rdf:resource" select="'&crm;E47_Spatial_Coordinates'"/>
														</xsl:element>
														<xsl:element name="crm:P90_has_value">
															<xsl:value-of select="concat('&getty_tgn;', *[local-name() = 'gml']/*[local-name() = 'Point']/*[local-name() = 'coordinates'])"/>
														</xsl:element>	
													</xsl:element>
												</xsl:when>
												<xsl:otherwise>
													<!-- error message="Unknown lido:source for location mapping" exit="true" /-->	
												</xsl:otherwise>
											</xsl:choose>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:when>
								<xsl:otherwise>
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/', ycba_fn:urlencode(*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']))"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Place'"/>
										</xsl:element>
										<xsl:if test="*[local-name() = 'placeID']/@*[local-name() = 'type']!='local'">
											<xsl:element name="skos:inScheme">
												<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID']/@*[local-name() = 'type'])"/>
											</xsl:element>
										</xsl:if>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']"/>
										</xsl:element>
										<xsl:element name="crm:P87_is_identified_by">
											<xsl:attribute name="rdf:resource" select="concat('&getty_tgn;', *[local-name() = 'placeID'], '/coordinates')"/>
										</xsl:element>	
									</xsl:element>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			
			<!-- Classification: type of object Frame, Print, Painting, etc. (bmo:PX_object_type) -->
				<xsl:for-each select="*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectClassificationWrap']/*[local-name() = 'classificationWrap']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&getty_ulan;', *[local-name() = 'classification']/*[local-name() = 'conceptID']/text())" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
						</xsl:element>
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="*[local-name() = 'classification']/*[local-name() = 'term']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
		
			<!-- lidoRecID -->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/lidoRecID')" />
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E42_Identifier'"/>
					</xsl:element>
					<xsl:element name="crm:P2_has_type">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier/lidoRecID'"/>
					</xsl:element>
					<xsl:element name="rdfs:label">
						<xsl:value-of select="//*[local-name() = 'lidoRecID']/text()"/>
					</xsl:element>
				</xsl:element>
				
			<!-- lidoRecID thesauri-->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="'&ycba;thesauri/identifier/lidoRecID'"/>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
					</xsl:element>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
					</xsl:element>
					<xsl:element name="skos:inScheme">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier'"/>
					</xsl:element>
					<xsl:element name="skos:prefLabel">
						<xsl:value-of select="'Lido Record ID'"/>
					</xsl:element>
				</xsl:element>
				
			<!-- TMS Object ID -->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/TMS')" />
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E42_Identifier'"/>
					</xsl:element>
					<xsl:element name="crm:P2_has_type">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier/TMS'"/>
					</xsl:element>
					<xsl:element name="rdfs:label">
						<xsl:value-of select="*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text()"/>
					</xsl:element>
				</xsl:element>
				
			<!-- TMS Object thesauri-->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="'&ycba;thesauri/identifier/TMS'"/>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
					</xsl:element>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
					</xsl:element>
					<xsl:element name="skos:inScheme">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier'"/>
					</xsl:element>
					<xsl:element name="skos:prefLabel">
						<xsl:value-of select="'TMS Object ID'"/>
					</xsl:element>
				</xsl:element>
	
			<!-- inventory number -->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/inventory-number')" />
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E42_Identifier'"/>
					</xsl:element>
					<xsl:element name="crm:P2_has_type">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier/inventory-number'"/>
					</xsl:element>
					<xsl:element name="rdfs:label">
						<xsl:value-of select="//*[local-name() = 'workID']/text()"/>
					</xsl:element>
				</xsl:element>
				
			<!-- inventory number thesauri-->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="'&ycba;thesauri/identifier/inventory-number'"/>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
					</xsl:element>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
					</xsl:element>
					<xsl:element name="skos:inScheme">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier'"/>
					</xsl:element>
					<xsl:element name="skos:prefLabel">
						<xsl:value-of select="'Inventory number'"/>
					</xsl:element>
				</xsl:element>
				
			<!-- VuFind CCD ID -->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="concat('&ycba;object/', *[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/ccd')" />
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E42_Identifier'"/>
					</xsl:element>
					<xsl:element name="crm:P2_has_type">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier/ccd'"/>
					</xsl:element>
					<xsl:variable name="ccdLabel" select="tokenize(//*[local-name() = 'recordInfoLink'][@*[local-name() = 'formatResource']='html']/text(), '[/]+')" />
					<xsl:element name="rdfs:label">
						<xsl:value-of select="$ccdLabel[last()]"/>
					</xsl:element>
				</xsl:element>
				
			<!-- VuFind CCD ID thesauri-->
				<xsl:element name="rdf:Description">
					<xsl:attribute name="rdf:about" select="'&ycba;thesauri/identifier/ccd'"/>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
					</xsl:element>
					<xsl:element name="rdf:type">
						<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
					</xsl:element>
					<xsl:element name="skos:inScheme">
						<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier'"/>
					</xsl:element>
					<xsl:element name="skos:prefLabel">
						<xsl:value-of select="'VuFind CCD ID'"/>
					</xsl:element>
				</xsl:element>
			
			<!-- Material -->
					<xsl:for-each select="//*[local-name() = 'eventMaterialsTech']/*[local-name() = 'materialsTech']/*[local-name() = 'termMaterialsTech']">
						<xsl:variable name="techType" select="*[local-name() = 'conceptID']/@*[local-name() = 'type']" />
						<xsl:choose>
							<xsl:when test="*[local-name() = 'conceptID']/text()!=-1">
								<xsl:if test="$techType='support' or $techType='medium'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:variable name="termID" select="*[local-name() = 'conceptID']/text()" />
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code(*[local-name() = 'conceptID']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/material'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/material/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/material'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
								<xsl:if test="$techType='technique'">
									<xsl:choose>
										<xsl:when test="*[local-name() = 'conceptID']/@*[local-name() = 'source']='AAT'">
											<xsl:element name="rdf:Description">
												<xsl:variable name="termID" select="*[local-name() = 'conceptID']/text()" />
												<xsl:attribute name="rdf:about" select="concat('&getty_aat;', ycba_fn:pad-AAT-code($termID))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/technique'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="rdf:Description">
												<xsl:variable name="termID" select="*[local-name() = 'conceptID']/text()" />
												<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/technique/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
												</xsl:element>
												<xsl:element name="rdf:type">
													<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
												</xsl:element>
												<xsl:element name="skos:inScheme">
													<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/technique'"/>
												</xsl:element>
												<xsl:element name="skos:prefLabel">
													<xsl:value-of select="*[local-name() = 'term']/text()"/>
												</xsl:element>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:if test="$techType='support' or $techType='medium'">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/material/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/material'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
								<xsl:if test="$techType='technique'">
									<xsl:element name="rdf:Description">
										<xsl:variable name="termID" select="*[local-name() = 'conceptID']/text()" />
										<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/technique/', ycba_fn:urlencode(*[local-name() = 'term']/text()))" />
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E57_Material'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/technique'"/>
										</xsl:element>
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'term']/text()"/>
										</xsl:element>
									</xsl:element>
								</xsl:if>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
			
			<!-- Acquisition -->
				<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'repositoryWrap']/*[local-name() = 'repositorySet'][@*[local-name() = 'type']='current']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&ycba;object/', ../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/acquisition/')" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E10_Transfer_of_Custody'"/>
						</xsl:element>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E8_Acquisition'"/>
						</xsl:element>
						<xsl:element name="crm:P22_transferred_title_to">
							<!-- removed urlencode, caused problems -->
							<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/@*[local-name() = 'source'], '/', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/text())"/>
						</xsl:element>
						<xsl:element name="crm:P29_custody_received_by">
							<!-- removed urlencode, caused problems -->
							<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/@*[local-name() = 'source'], '/', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/text())"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="concat('Transferred to ', ../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'rightsWorkWrap']/*[local-name() = 'rightsWorkSet']/*[local-name() = 'creditLine'])"/>
						</xsl:element>
					</xsl:element>
					
			<!-- Institution & Department (Current Keeper) -->
					<xsl:if test="*[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/@*[local-name() = 'source']='ULAN'">
						<xsl:element name="rdf:Description">
							<xsl:attribute name="rdf:about" select="concat('&getty_ulan;', *[local-name() = 'repositoryName']/*[local-name() = 'legalBodyID']/text())"/>
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&crm;E40_Legal_Body'"/>
							</xsl:element>
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
							</xsl:element>
							<xsl:element name="skos:prefLabel">
								<xsl:value-of select="*[local-name() = 'repositoryName']/*[local-name() = 'legalBodyName']/*[local-name() = 'appellationValue']/text()"/>
							</xsl:element>
							<xsl:element name="skos:inScheme">
								<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/institution'"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
				
			<!-- Current location of object -->
				<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectIdentificationWrap']/*[local-name() = 'repositoryWrap']/*[local-name() = 'repositorySet']/*[local-name() = 'repositoryLocation']/*[local-name() = 'partOfPlace']">
					<xsl:if test="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text()!=''">
						<xsl:element name="rdf:Description">
							<xsl:attribute name="rdf:about" select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/location/', position())"/>
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&crm;E53_Place'"/>
							</xsl:element>
							<xsl:element name="rdfs:label">
								<xsl:value-of select="*[local-name() = 'namePlaceSet']/*[local-name() = 'appellationValue']/text()"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
				
			<!-- Subject Actor (P62_depicts) YCBA uses ULAN, VIAF, ODMP, & DBPEDIA -->
				<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'objectRelationWrap']/*[local-name() = 'subjectWrap']/*[local-name() = 'subjectSet']/*[local-name() = 'subject'][@*[local-name() = 'type']='description']/*[local-name() = 'subjectActor']">
					<xsl:choose>
						<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']!='-1'"> <!-- Ignore if no ID is assigned -->
							<xsl:choose>
								<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']/@*[local-name() = 'source']='ULAN'">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&getty_ulan;', *[local-name() = 'actor']/*[local-name() = 'actorID'])"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E39_Actor'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;person-institution'"/>
										</xsl:element>
										
										<!-- name(s) TBD Emmanuelle and David -->
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']/text()"/>
										</xsl:element>
									</xsl:element>
								</xsl:when>
								
								<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']/@*[local-name() = 'source']='VIAF'">
									<xsl:element name="rdf:Description">
										<xsl:attribute name="rdf:about" select="concat('&viaf;', *[local-name() = 'actor']/*[local-name() = 'actorID'])"/>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&crm;E39_Actor'"/>
										</xsl:element>
										<xsl:element name="rdf:type">
											<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
										</xsl:element>
										<xsl:element name="skos:inScheme">
											<xsl:attribute name="rdf:resource" select="'&ycba;person-institution'"/>
										</xsl:element>
										
										<!-- name(s) TBD Emmanuelle and David -->
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']/text()"/>
										</xsl:element>
									</xsl:element>
								</xsl:when>
								
								<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']/@*[local-name() = 'source']='ODNB'">
								
								</xsl:when>
								<xsl:when test="*[local-name() = 'actor']/*[local-name() = 'actorID']/@*[local-name() = 'source']='DBPEDIA'">
								
								</xsl:when>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about" select="concat('&ycba;thesauri/', ycba_fn:urlencode(*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']/text()))"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E39_Actor'"/>
								</xsl:element>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
								</xsl:element>
								<xsl:element name="skos:inScheme">
									<xsl:attribute name="rdf:resource" select="'&ycba;person-institution'"/>
								</xsl:element>
								
								<!-- name(s) TBD Emmanuelle and David -->
								<xsl:element name="skos:prefLabel">
									<xsl:value-of select="*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']/text()"/>
								</xsl:element>
								</xsl:element>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:for-each>
				
			<!-- Object Rights -->
				<!--
				<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'rightsWorkWrap']/*[local-name() = 'rightsWorkSet']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about" select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/copyright')"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E30_Right'"/>
						</xsl:element>
						<xsl:element name="crm:P3_has_note">
							<xsl:value-of select="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyName']/*[local-name() = 'appellationValue']"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/', *[local-name() = 'rightsType']/*[local-name() = 'conceptID'])"/>
						</xsl:element>
						<xsl:if test="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyWeblink']!=''">
							<xsl:element name="crm:P105_right_held_by">
								<xsl:attribute name="rdf:resource" select="'&ycba;person-institution/99999-hardcoded'" />
							</xsl:element>
						</xsl:if>
					</xsl:element>
					
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat('&ycba;object/', ../../*[local-name() = 'recordWrap']/*[local-name() = 'recordID']/text(), '/', *[local-name() = 'rightsType']/*[local-name() = 'conceptID'])" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'rightsType']/*[local-name() = 'conceptID']"/>
						</xsl:element>
					</xsl:element>
					
					<xsl:if test="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyWeblink']!=''"> 
						<xsl:element name="rdf:Description">
							<xsl:attribute name="rdf:about"  select="'&ycba;person-institution/99999-hardcoded'" />
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&crm;E39_Owner'"/>
							</xsl:element>
							<xsl:element name="skos:prefLabel">
								<xsl:value-of select="*[local-name() = 'rightsHolder']/*[local-name() = 'legalBodyWeblink']/text()"/>
							</xsl:element>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			-->
			<!-- Publications / Bibliography -->
				<xsl:for-each select="//*[local-name() = 'relatedWorkSet']/*[local-name() = 'relatedWork']/*[local-name() = 'displayObject'][../../*[local-name() = 'relatedWorkRelType']/*[local-name() = 'conceptID']/@*[local-name() = 'source']='publication']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat('&ycba;bibliography/', ../*[local-name() = 'object']/*[local-name() = 'objectID'][@*[local-name() = 'source']='YCBA'])" />
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E31_Document'"/>
						</xsl:element>
						<xsl:if test="../*[local-name() = 'object']/*[local-name() = 'objectID'][@*[local-name() = 'source']='OCLC Number']!=''">
							<xsl:element name="crm:P1_is_identified_by">
								<xsl:attribute name="rdf:resource" select="concat('&oclc;', ../*[local-name() = 'object']/*[local-name() = 'objectID'][@*[local-name() = 'source']='OCLC Number'])"/>
							</xsl:element>
						</xsl:if>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="../*[local-name() = 'object']/*[local-name() = 'objectNote']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			<!-- Exhibitions -->
				<xsl:for-each select="//*[local-name() = 'descriptiveMetadata']/*[local-name() = 'eventWrap']/*[local-name() = 'eventSet']/*[local-name() = 'displayEvent'][../*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']='exhibition history']">
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat('&ycba;exhibition/', ../*[local-name() = 'event']/*[local-name() = 'eventID'])"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E7_Activity'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="."/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/event/exhibition'"/>
						</xsl:element>
						<xsl:element name="crm:P1_is_identified_by">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;event/', ../*[local-name() = 'event']/*[local-name() = 'eventID'], '/exhibition')"/>
						</xsl:element>
					</xsl:element>
					
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat('&ycba;event/', ../*[local-name() = 'event']/*[local-name() = 'eventID'], '/exhibition')"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E42_Identifier'"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/identifier/exhibition'"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="../*[local-name() = 'event']/*[local-name() = 'eventID']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			<!-- Curatorial Comment -->
				<xsl:for-each select="//*[local-name() = 'eventSet'][*[local-name() = 'event']/*[local-name() = 'eventType']/*[local-name() = 'term']='Curatorial comment']">	
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat($objectUri, '/comment/', position())"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&bmo;EX_Association'"/>
						</xsl:element>
						<xsl:element name="crm:P140_assigned_attribute_to">
							<xsl:attribute name="rdf:resource" select="$objectUri"/>
						</xsl:element>
						<xsl:variable name="comment">
							<xsl:value-of select="*[local-name() = 'displayEvent']"/>
						</xsl:variable>
						<xsl:element name="crm:P141_assigned">
							<xsl:value-of select="$comment" />
						</xsl:element>
						<xsl:element name=" bmo:PX_property">
							<xsl:attribute name="rdf:resource" select="'&bmo;PX_curatorial_comment'"/>
						</xsl:element>
						
						<!-- person -->
						<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
							<xsl:element name="crm:P14_carried_out_by">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
							</xsl:element>	
						</xsl:if>
						
						<!-- Corporation -->
						<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
							<xsl:element name="crm:P14_carried_out_by">
								<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', *[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
							</xsl:element>	
						</xsl:if>
						
						<xsl:element name="crm:P4_has_time-span">
							<xsl:attribute  name="rdf:resource" select="concat($objectUri, '/comment/', position(), '/date')"/>
						</xsl:element>
					</xsl:element>
							
					<!-- person -->
						<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='person'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about"  select="concat('&ycba;person-institution/', *[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E21_Person'"/>
								</xsl:element>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
								</xsl:element>
								<xsl:element name="skos:inScheme">
									<xsl:attribute name="rdf:resource" select="'&ycba;person-institution'"/>
								</xsl:element>
								
								<!-- name(s) -->
								<xsl:for-each select="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']" >
									<xsl:choose>
										<xsl:when test="@*[local-name() = 'pref'] != 'preferred'">
											<xsl:element name="skos:altLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:when>
										<xsl:otherwise>
											<xsl:element name="skos:prefLabel">
												<xsl:value-of select="text()"/>
											</xsl:element>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
								
								<!-- Vital Dates -->
								<xsl:for-each select="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'vitalDatesActor']" >
									
									<!-- Birth -->
									<xsl:element name="crm:P98i_was_born">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/birth')"/>
									</xsl:element>
									
									<!-- Death -->
									<xsl:element name="crm:P100i_died_in">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;person-institution/', ../*[local-name() = 'actorID']/text(), '/death')"/>
									</xsl:element>
								</xsl:for-each>
								
								<!-- Gender -->
								<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'genderActor'] != ''">
									<xsl:element name="bmo:PX_gender">
										<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/gender/', ycba_fn:urlencode(*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'genderActor']/text()))"/>
									</xsl:element>
								</xsl:if>
								
								<!-- Nationality -->
								<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term'] != ''">
									<xsl:variable name="nation" select="tokenize(*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term'], ', ()')" />
									
									<xsl:element name="bmo:PX_nationality">
										<!--xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/nationality/', ycba_fn:urlencode(*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nationalityActor']/*[local-name() = 'term']/text()))"/-->
										<xsl:attribute name="rdf:resource" select="concat('&ycba_thesauri;nationality/', ycba_fn:urlencode($nation[1]))"/>
									</xsl:element>
								</xsl:if>	
							</xsl:element>
						</xsl:if>
						
					<!-- Corporation -->
					<xsl:if test="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/@*[local-name() = 'type']='corporation'">
						<xsl:element name="rdf:Description">
							<xsl:attribute name="rdf:about" select="concat('&ycba;person-institution/', *[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'actorID']/text())"/>
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&crm;E74_Group'"/>
							</xsl:element>
							<xsl:element name="rdf:type">
								<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
							</xsl:element>
							<xsl:element name="skos:inScheme">
								<!-- asking vlado about this -->
								<xsl:attribute name="rdf:resource" select="'&getty_ulan;person-institution'"/>
							</xsl:element>
							
							<!-- name(s) -->
							<xsl:for-each select="*[local-name() = 'event']/*[local-name() = 'eventActor']/*[local-name() = 'actorInRole']/*[local-name() = 'actor']/*[local-name() = 'nameActorSet']/*[local-name() = 'appellationValue']" >
								<xsl:choose>
									<xsl:when test="*[local-name() = 'pref'] = 'preferred'">
										<xsl:element name="skos:prefLabel">
											<xsl:value-of select="text()"/>
										</xsl:element>
									</xsl:when>
									<xsl:otherwise>
										<xsl:element name="skos:altLabel">
											<xsl:value-of select="text()"/>
										</xsl:element>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</xsl:element>
					</xsl:if>
					
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat($objectUri, '/comment/', position(), '/date')"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E52_Time-Span'"/>
						</xsl:element>
						<xsl:element name="crm:P3_has_note">
							<xsl:value-of select="*[local-name() = 'event']/*[local-name() = 'eventDate']/*[local-name() = 'displayDate']"/>
						</xsl:element>
						<xsl:element name="rdfs:label">
							<xsl:value-of select="*[local-name() = 'event']/*[local-name() = 'eventDate']/*[local-name() = 'displayDate']"/>
						</xsl:element>	
						<xsl:element name="crm:P82_at_some_time_within">
							<xsl:attribute name="rdf:datatype" select="ycba_fn:date-type(*[local-name() = 'event']/*[local-name() = 'eventDate']/*[local-name() = 'displayDate']/text())"/>
							<xsl:value-of select="*[local-name() = 'event']/*[local-name() = 'eventDate']/*[local-name() = 'displayDate']/text()"/>
						</xsl:element>
					</xsl:element>
				</xsl:for-each>
				
			<!-- Measurements -->
			<!--
				<xsl:for-each select="//*[local-name() = 'objectMeasurementsWrap']/*[local-name() = 'objectMeasurementsSet']/*[local-name() = 'objectMeasurements']/*[local-name() = 'measurementsSet']">
					<xsl:choose>
			-->
						<!-- object height -->
			<!--
						<xsl:when test="*[local-name() = 'measurementType']='height'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about"  select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/height')"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E54_Dimension'"/>
								</xsl:element>
								<xsl:element name="crm:P2_has_type">
									<xsl:attribute name="rdf:resource" select="'&ycba_dimension;height'"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="*[local-name() = 'measurementUnit']=' cm'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'http://qudt.org/vocab/unit#Centimeter'"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="*[local-name() = 'measurementUnit']=' ft'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'http://qudt.org/vocab/unit#Foot'"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
			-->					
								<!-- Here we add the actual value - if the dimension is milli-whatever, then we'll divide be 1000 using modifier funtion unitTomilliunit-->
			<!--
								<xsl:if test="*[local-name() = 'measurementValue']!=''">
									<xsl:element name="crm:P90_has_value">
										<xsl:attribute name="rdf:datatype" select="'&xsd;double'"/>
										<xsl:value-of select="*[local-name() = 'measurementValue']"/>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:when>
			-->			
						<!-- object width -->
			<!--
						<xsl:when test="*[local-name() = 'measurementType']='width'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about"  select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/width')"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E54_Dimension'"/>
								</xsl:element>
								<xsl:element name="crm:P2_has_type">
									<xsl:attribute name="rdf:resource" select="'&ycba_dimension;width'"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="*[local-name() = 'measurementUnit']=' cm'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'&unit;Centimeter'"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="*[local-name() = 'measurementUnit']=' ft'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'&unit;Foot'"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
				-->				
								<!-- Here we add the actual value - if the dimension is milli-whatever, then we'll divide be 1000 using modifier funtion unitTomilliunit-->
				<!--				
								<xsl:if test="*[local-name() = 'measurementValue']!=''">
									<xsl:element name="crm:P90_has_value">
										<xsl:attribute name="rdf:datatype" select="'&xsd;double'"/>
										<xsl:value-of select="*[local-name() = 'measurementValue']"/>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:when>
				-->		
						<!-- object depth -->
				<!--
						<xsl:when test="*[local-name() = 'measurementType']='depth'">
							<xsl:element name="rdf:Description">
								<xsl:attribute name="rdf:about"  select="concat('&ycba;object/', ../../../../../../*[local-name() = 'administrativeMetadata']/*[local-name() = 'recordWrap']/*[local-name() = 'recordID'], '/depth')"/>
								<xsl:element name="rdf:type">
									<xsl:attribute name="rdf:resource" select="'&crm;E54_Dimension'"/>
								</xsl:element>
								<xsl:element name="crm:P2_has_type">
									<xsl:attribute name="rdf:resource" select="'&ycba_dimension;depth'"/>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="*[local-name() = 'measurementUnit']=' cm'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'&unit;Centimeter'"/>
										</xsl:element>
									</xsl:when>
									<xsl:when test="*[local-name() = 'measurementUnit']=' ft'">
										<xsl:element name="crm:P91_has_unit">
											<xsl:attribute name="rdf:resource" select="'&unit;Foot'"/>
										</xsl:element>
									</xsl:when>
								</xsl:choose>
				-->				
								<!-- Here we add the actual value - if the dimension is milli-whatever, then we'll divide be 1000 using modifier funtion unitTomilliunit-->
				<!--
								<xsl:if test="*[local-name() = 'measurementValue']!=''">
									<xsl:element name="crm:P90_has_value">
										<xsl:attribute name="rdf:datatype" select="'&xsd;double'"/>
										<xsl:value-of select="*[local-name() = 'measurementValue']"/>
									</xsl:element>
								</xsl:if>
							</xsl:element>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>
				-->
				
				<!-- Measurement Type -->
				<!--
					<xsl:variable name="objectMeasurementsSet" select="//*[local-name() = 'objectMeasurementsWrap']/*[local-name() = 'objectMeasurementsSet']"/>
					<xsl:variable name="objectMeasurements" select="$objectMeasurementsSet/*[local-name() = 'objectMeasurements']"/>
					<xsl:variable name="extentMeasurements" select="tokenize($objectMeasurements/*[local-name() = 'extentMeasurements']/text(), '\s+')"/>
					<xsl:variable name="extentMeasurements" select="tokenize(string-join($extentMeasurements, '-'), '[()]')"/>
					<xsl:variable name="extentMeasurements" select="string-join($extentMeasurements, '')"/>
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat($objectUri, '/measurement')"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E16_Measurement'"/>
						</xsl:element>
						<xsl:element name="crm:P2_has_type">
							<xsl:attribute name="rdf:resource" select="concat('&ycba;thesauri/', 'measurement/', $extentMeasurements)"/>
						</xsl:element>
						
						<xsl:for-each select="$objectMeasurements/*[local-name() = 'measurementsSet']">
							<xsl:if test="*[local-name() = 'measurementType']='width'">
								<xsl:element name="crm:P40_observed_dimension">
									<xsl:attribute name="rdf:resource"  select="concat($objectUri, '/width')"/>
								</xsl:element>
							</xsl:if>
							
							<xsl:if test="*[local-name() = 'measurementType']='height'">
								<xsl:element name="crm:P40_observed_dimension">
									<xsl:attribute name="rdf:resource"  select="concat($objectUri, '/height')"/>
								</xsl:element>
							</xsl:if>
						</xsl:for-each>
						
						<xsl:element name="rdfs:label">
							<xsl:value-of select="concat($objectMeasurementsSet/*[local-name() = 'displayObjectMeasurements']/text(), '. Extent: ', $objectMeasurements/*[local-name() = 'extentMeasurements'])"/>
						</xsl:element>
					</xsl:element>
					<xsl:element name="rdf:Description">
						<xsl:attribute name="rdf:about"  select="concat('&ycba;thesauri/', 'measurement/', $extentMeasurements)"/>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&skos;Concept'"/>
						</xsl:element>
						<xsl:element name="rdf:type">
							<xsl:attribute name="rdf:resource" select="'&crm;E55_Type'"/>
						</xsl:element>
						<xsl:element name="skos:inScheme">
							<xsl:attribute name="rdf:resource" select="'&ycba;thesauri/measurement'"/>
						</xsl:element>
						<xsl:element name="skos:prefLabel">
							<xsl:value-of select="$objectMeasurements/*[local-name() = 'extentMeasurements']/text()"/>
						</xsl:element>
					</xsl:element>
			-->
		</rdf:RDF>
    </xsl:template>
</xsl:stylesheet>