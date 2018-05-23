<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet exclude-result-prefixes="#all" version="2.0"
                xmlns:kiln="http://www.kcl.ac.uk/artshums/depts/ddh/kiln/ns/1.0"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:import href="../../kiln/stylesheets/solr/tei-to-solr.xsl" />

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Oct 18, 2010</xd:p>
      <xd:p><xd:b>Author:</xd:b> jvieira</xd:p>
      <xd:p>This stylesheet converts a TEI document into a Solr index document. It expects the parameter file-path,
      which is the path of the file being indexed.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:template match="/">
    <add>
      <xsl:apply-imports />
    </add>
  </xsl:template>
  
  <xsl:template match="//tei:textClass/tei:keywords/tei:term/text()" mode="facet_term">
    <field name="term">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  
  <xsl:template match="tei:placeName[@type='civitas']/text()" mode="facet_civitas">
    <field name="civitas">
      <xsl:value-of select="."/>
    </field>
  </xsl:template>
  
  <xsl:template match="//tei:persName[@type='divine']" mode="facet_deity">
    <field name="deity">
      <xsl:value-of select="@key"/>
    </field>
  </xsl:template>

  <!-- This template is called by the Kiln tei-to-solr.xsl as part of
       the main doc for the indexed file. Put any code to generate
       additional Solr field data (such as new facets) here. -->
  <xsl:template name="extra_fields" >
    <xsl:call-template name="field_term"/>
    <xsl:call-template name="field_civitas"/>
    <xsl:call-template name="field_deity"/>
  </xsl:template>
  
  <xsl:template name="field_term">
    <xsl:apply-templates mode="facet_term" select="//tei:textClass/tei:keywords/tei:term/text()"/>
  </xsl:template>
  
  <xsl:template name="field_civitas">
    <xsl:apply-templates mode="facet_civitas" select="//tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:history/tei:origin/tei:origPlace"/>
  </xsl:template>
  
  <xsl:template name="field_deity">
    <xsl:apply-templates mode="facet_deity" select="//tei:text/tei:body/tei:div"/>
  </xsl:template>

</xsl:stylesheet>
