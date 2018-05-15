<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:t="http://www.tei-c.org/ns/1.0" xmlns:f="http://example.com/ns/functions"
	xmlns:html="http://www.w3.org/1999/html" exclude-result-prefixes="t f" version="2.0">
	<!--

Pietro notes on 14/8/2015 work on this template, from mail to Gabriel.

- I have converted the TEI bibliography of IRT and IGCyr to ZoteroRDF 
(https://github.com/EAGLE-BPN/BiblioTEI2ZoteroRDF) in this passage I have tried to 
distinguish books, bookparts, articles and conference proceedings.

- I have uploaded these to the zotero eagle open group bibliography 
(https://www.zotero.org/groups/eagleepigraphicbibliography)

- I have created a parametrized template in my local epidoc xslts which looks at the json 
and TEI output of the Zotero api basing the call on the content of ptr/@target in each 
bibl. It needs both because the key to build the link is in the json but the TEI xml is 
much more accessible for the other data. I tried also to grab the html div exposed in the 
json, which would have been the easiest thing to do, but I can only get it escaped and 
thus is not usable.
** If set on 'zotero' it prints surname, name, title and year with a link to the zotero 
item in the eagle group bibliography. It assumes bibl only contains ptr and citedRange.
** If set on 'localTEI' it looks at a local bibliography (no zotero) and compares the 
@target to the xml:id to take the results and print something (in the sample a lot, but 
I'd expect more commonly Author-Year references(.
** I have also created sample values for irt and igcyr which are modification of the 
zotero option but deal with some of the project specific ways of encoding the 
bibliography. All examples only cater for book and article.



-->

	<!--
		
		Pietro Notes on 10.10.2016
		
		this should be modified based on parameters to
		
		* decide wheather to use zotero or a local version of the bibliography in TEI
	
		* assuming that the user has entered a unique tag name as value of ptr/@target, decide group or user in zotero to look up based on parameter value entered at transformation time
	
		* output style based on Zotero Style Repository stored in a parameter value entered at transformation time
		
		
	
	-->

	<xsl:template match="t:bibl" priority="1">
		<xsl:param name="parm-bib" tunnel="yes" required="no"/>
		<xsl:param name="parm-bibloc" tunnel="yes" required="no"/>
		<xsl:param name="parm-zoteroUorG" tunnel="yes" required="no"/>
		<xsl:param name="parm-zoteroKey" tunnel="yes" required="no"/>
		<xsl:param name="parm-zoteroNS" tunnel="yes" required="no"/>
		<xsl:param name="parm-zoteroStyle" tunnel="yes" required="no"/>
			<!-- default general zotero behaviour prints 
				author surname and name, title in italics, date and links to the zotero item page on the zotero bibliography. 
				assumes the inscription source has no free text in bibl, 
				!!!!!!!only a <ptr target='key'/> and a <citedRange>pp. 45-65</citedRange>!!!!!!!
			it also assumes that the content of ptr/@target is a unique tag used in the zotero bibliography as the ids assigned by Zotero are not
			reliable enough for this purpose according to Zotero forums.
			
			if there is no ptr/@target, this will try anyway and take a lot of time.
			-->
				<xsl:choose>
					<!--					check if there is a ptr at all
					
					WARNING. if the pointer is not there, the transformation will simply stop and return a premature end of file message e.g. it cannot find what it is looking for via the zotero api
					-->
					<xsl:when test=".[t:ptr]">

						<!--						check if a namespace is provided for tags/xml:ids and use it as part of the tag for zotero-->
						<xsl:variable name="biblentry" select="./t:ptr/@target"/>

						<xsl:variable name="zoteroapitei">

							<xsl:value-of
								select="concat('https://api.zotero.org/users/4272137/items?tag=', $biblentry, '&amp;format=tei')"/>
							<!-- to go to the json with the escaped html included  use &amp;format=json&amp;include=bib,data and the code below: the result is anyway escaped... -->

						</xsl:variable>

						<xsl:variable name="zoteroapijson">
							<xsl:value-of
								select="concat('https://api.zotero.org/users/4272137/items?tag=', $biblentry, '&amp;format=json&amp;style=chicaco-author-date&amp;include=citation')"
							/>
						</xsl:variable>
						<xsl:variable name="unparsedtext" select="unparsed-text($zoteroapijson)"/>
						<xsl:variable name="zoteroitemKEY">

							<xsl:analyze-string select="$unparsedtext"
								regex="(\[\s+\{{\s+&quot;key&quot;:\s&quot;)(.+)&quot;">
								<xsl:matching-substring>
									<xsl:value-of select="regex-group(2)"/>
								</xsl:matching-substring>
							</xsl:analyze-string>

						</xsl:variable>

						<xsl:choose>
							<!-- this will print a citation according to the selected style with a link around it pointing to the resource DOI, url or zotero item view -->
							<xsl:when test="not(ancestor::t:div[@type = 'bibliography'])">
								<xsl:variable name="pointerurl">
									<xsl:choose>
										<xsl:when
											test="document($zoteroapitei)//t:idno[@type = 'DOI']">
											<xsl:value-of
												select="document($zoteroapitei)//t:idno[@type = 'DOI']"
											/>
										</xsl:when>
										<xsl:when
											test="document($zoteroapitei)//t:idno[@type = 'url']">
											<xsl:value-of
												select="document($zoteroapitei)//t:idno[@type = 'url']"
											/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of
												select="document($zoteroapitei)//t:biblStruct/@corresp"
											/>
										</xsl:otherwise>
									</xsl:choose>

								</xsl:variable>

								<a href="{$pointerurl}">

									<xsl:variable name="citation">

										<xsl:analyze-string select="$unparsedtext"
											regex="(\s+&quot;citation&quot;:\s&quot;&lt;span&gt;)(.+)(&lt;/span&gt;&quot;)">
											<xsl:matching-substring>
												<xsl:value-of select="regex-group(2)"/>
											</xsl:matching-substring>
										</xsl:analyze-string>
									</xsl:variable>
									<xsl:value-of select="$citation"/>
									<xsl:if test="t:biblScope">
										<xsl:text>, </xsl:text>
										<xsl:value-of select="t:biblScope"/>
									</xsl:if>
								</a>
						</xsl:when>
							<!--	if it is in the bibliography print styled reference -->
						<xsl:otherwise>
								<!--	print out using Zotoro parameter format with value bib and the selected style-->
					     <xsl:copy-of select="document(concat('https://api.zotero.org/users/4272137/items?tag=', $biblentry, '&amp;format=bib&amp;style=deutsches-archaologisches-institut'))/div"/>

							</xsl:otherwise>
						</xsl:choose>

					</xsl:when>

					<!-- if there is no ptr, print simply what is inside bibl and a warning message-->
					<xsl:otherwise>
						<xsl:value-of select="."/>
						<xsl:message>There is no ptr with a @target in the bibl element <xsl:copy-of
								select="."/>. A target equal to a tag in your zotero bibliography is
							necessary.</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:value-of select="t:biblScope"/>
	</xsl:template>


</xsl:stylesheet> 
