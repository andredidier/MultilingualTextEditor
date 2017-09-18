/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Element
import com.andredidier.multilingualtexteditor.multilingualTextEditor.HTMLConfig
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Sentence
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import java.util.function.Function
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension com.andredidier.multilingualtexteditor.generator.GeneratedResourcesFileName.*

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class HtmlGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (t : resource.allContents.toIterable.filter(Text)) {
			t.generate([ lc, m |
				fsa.generateFile("html/" + resource.URI.lastSegment.replace(".mte", "") + "_" + lc.suffix(m) + '.html',
					t.compile(lc, m))
			]);
		}
	}

	def String applyModifier(String m, String text) {
		switch m {
			case 'bold': '''<b>«text»</b>'''
			case 'italics': '''<i>«text»</i>'''
			case 'underline': '''<u>«text»</u>'''
			default:
				text
		}
	}

	def String compile(Sentence w) {
		var t = w.value;
		for (m : w.modifier) {
			t = m.applyModifier(t);
		}
		'''«t» '''
	}

	def String compile(TextualContent c, Language lc, Model model) {
		if (!c.hiddenContent && (c.models.empty || c.models.map[it.name].contains(model.name))) {
			if (c.children.isEmpty) {
				val lt = c.values.findFirst[it.language.name == lc.name];
				if (!lt.hiddenContent) {
					'''«c.opening»«lt.compile»«c.closing»'''
				}
			
			}
			else
				'''«c.opening»«FOR child : c.children»«child.compile(lc,model)»«ENDFOR»«c.closing»'''
		}
	}
	
	def opening(TextualContent tc) {
		val config = tc.element.htmlConfig;
		'''<«config.htmlElement»«config.classes»>'''
	}
	
	def classes(HTMLConfig config) {
		'''«IF !config.htmlClassNames.empty» class="«FOR cn : config.htmlClassNames»«cn»«ENDFOR»"«ENDIF»'''
	}
	
	def closing(TextualContent tc) {
		val config = tc.element.htmlConfig;
		'''</«config.htmlElement»>'''
	}

	def String compile(LocalizedText langContents) {
		'''«FOR w : langContents.values»«w.compile»«ENDFOR»'''
	}
	
	def hasConfig(HTMLConfig c, Function<HTMLConfig,Boolean> f) {
		if (c===null) {
			return false
		} else {
			return f.apply(c)
		}
	}

	def hasConfig(Element c, Function<HTMLConfig,Boolean> f) {
		if (c===null) {
			return false
		} else {
			return c.htmlConfig.hasConfig(f)
		}
	}
	
	def hasConfig(TextualContent c, Function<HTMLConfig,Boolean> f) {
		if (c===null) {
			return false
		} else {
			return c.element.hasConfig(f)
		}
	}

	def String compile(Text t, Language lc, Model model) {
		'''
			<html>
			<head>
				<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
				«FOR c : t.textualContents.filter[it.hasConfig[c|c.header]]»«c.compile(lc, model)»«ENDFOR»
			</head> 
			<body>
				«FOR c : t.textualContents.filter[it.hasConfig[c|c.body]]»«c.compile(lc, model)»«ENDFOR»
			</body>
			<footer>
				«FOR c : t.textualContents.filter[it.hasConfig[c|c.footer]]»«c.compile(lc, model)»«ENDFOR»
			</footer>
			</html> 
		'''
	}

}
