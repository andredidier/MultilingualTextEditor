/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.CountryCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Words
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static com.andredidier.multilingualtexteditor.generator.GeneratedResourcesFileName.*;

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class HtmlGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (t : resource.allContents.toIterable.filter(Text)) {
			generate(t, [lc, m |
				fsa.generateFile(resource.URI.lastSegment.replace(".mte", "") + "_" + suffix(lc, m) + '.html', t.compile(lc, m.value))
			]);
		}
	}

	def String applyModifier(String m, String text) {
		switch m {
			case 'bold': '''<b>«text»</b>'''
			case 'italics': '''<i>«text»</i>'''
			case 'underline': '''<u>«text»</u>'''
			case 'strikethrough': '''<strike>«text»</strike>'''
			default:
				text
		}
	}

	def String compile(Words w, String type) {
		var t = w.value;
		for (m : w.modifier) {
			t = m.applyModifier(t);
		}
		'''«t» '''
	}

	def boolean equivalent(CountryCode c1, CountryCode c2) {
		if(c1.value != c2.value) return false;
		if (c1.variantCode === null) {
			return c2.variantCode === null;
		} else {
			return c1.variantCode === c2.variantCode;
		}
	}

	def boolean equivalent(LanguageCode l1, LanguageCode l2) {
		if(l1.value != l2.value) return false;
		if (l1.countryCode === null) {
			return l2.countryCode === null;
		} else {
			return l1.countryCode.equivalent(l2.countryCode);
		}
	}

	def String compile(TextualContent c, LanguageCode lc, String model) {
		if (!c.hiddenContent && (c.models.empty || c.models.contains(model)))
			'''«FOR langContents : c.values»«langContents.compile(c.type, lc, model)»«ENDFOR»'''
	}

	def String applyType(TextualContent c, String text) {
		switch c.type {
			case 'title': '''<p class="title">«text»</p>'''
			case 'heading1': '''<h1>«text»</h1>'''
			case 'heading2': '''<h2>«text»</h2>'''
			case 'heading3': '''<h3>«text»</h3>'''
			case 'paragraph': '''<p>«text»</p>'''
			case 'ul': '''<ul>«text»</ul>'''
			case 'ol': '''<ol>«text»</ol>'''
			default:
				text
		}
	}

	def String compile(LocalizedText langContents, String type, LanguageCode lc, String model) {
		var before = ""
		var after = ""
		if (type == 'ul' || type == 'ol') {
			before = "<li>"
			after = "</li>"
		}
		if (!langContents.hiddenContent)
			'''
			«IF langContents.languageCode.equivalent(lc)»
				«before»«FOR w : langContents.values»«w.compile(type)»«ENDFOR»«after»
			«ENDIF»
			'''
	}

	def String compile(Text t, LanguageCode lc, String model) {
		'''
			<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
			</head> 
			<body>
			«FOR c : t.textualContents»«c.applyType(c.compile(lc, model))»«ENDFOR»
			</body>
			</html> 
		'''
	}

}
