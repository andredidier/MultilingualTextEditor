/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.CountryCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Words
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
class PlainTextGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (t : resource.allContents.toIterable.filter(Text)) {
			t.generate([lc, m |
				fsa.generateFile(resource.URI.lastSegment.replace(".mte", "") + "_" + lc.suffix(m) + '.txt', t.compile(lc, m))
			]);
		}
	}
	
	def String compile(Words w) {
		'''«IF !w.modifier.contains("strikethrough")»«w.value» «ENDIF»'''
	}
	
	def boolean equivalent(CountryCode c1, CountryCode c2) {
		if (c1.value != c2.value) return false;
		if (c1.variantCode === null) {
			return c2.variantCode === null;
		} else {
			return c1.variantCode === c2.variantCode;
		}
	}
	
	def boolean equivalent(LanguageCode l1, LanguageCode l2) {
		if (l1.value != l2.value) return false;
		if (l1.countryCode === null) {
			return l2.countryCode === null; 
		} else {
			return l1.countryCode.equivalent(l2.countryCode);
		}
	}
	
	def String compile(TextualContent c, LanguageCode lc, Model model) {
		if (!c.hiddenContent && (c.models.isEmpty || c.models.contains(model.name)))
			'''
			«FOR langContents : c.values»«langContents.compile(lc)»«ENDFOR»
			'''
	}
	
	def String compile(LocalizedText langContents, LanguageCode lc) {
		if (!langContents.hiddenContent)
			'''
			«FOR w : langContents.values»«IF langContents.languageCode.equivalent(lc)»«w.compile»«ENDIF»«ENDFOR»
			'''
	}
	
	def String compile(Text t, LanguageCode lc, Model m) {
		'''
		«FOR c : t.textualContents»«c.compile(lc, m)»«"\n"»«ENDFOR» 
		'''
	}
	
}
