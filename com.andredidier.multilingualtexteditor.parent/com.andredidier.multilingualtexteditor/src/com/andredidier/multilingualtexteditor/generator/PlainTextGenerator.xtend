/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Sentence
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
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
	
	def String compile(Sentence w) {
		'''«IF w.deletionReview === null»«w.value» «ENDIF»'''
	}
	
	def String compile(TextualContent c, Language lc, Model model) {
		val prefix = if (c.element.plainText === null) "" else c.element.plainText.prefix
		val suffix = if (c.element.plainText === null) "" else c.element.plainText.suffix
		if (c.children.empty) {
			val localizedText = c.values.findFirst[it.language.name == lc.name]
			if (!localizedText.hiddenContent) {
				'''«prefix»«localizedText.compile»«suffix»'''
			}
			
		} else {
			'''«prefix»«FOR child : c.children»«child.compile(lc, model)»«ENDFOR»«suffix»'''
		}
	}
	
	def String replaceLineBreaks(String str) {
		return str.replace("\\n", "\n");
	}
	
	def String compile(LocalizedText langContents) {
		'''«FOR w : langContents.values»«w.compile»«ENDFOR»'''
	}
	
	def String compile(Text t, Language lc, Model m) {
		'''«FOR c : t.textualContents»«IF c.hasContents(lc, m)»«c.compile(lc, m)»«ENDIF»«ENDFOR»'''
	}
	
	def boolean hasContents(TextualContent c, Language lc, Model model) {
		return !c.hiddenContent && (c.models.isEmpty || c.models.map[it.name].contains(model.name))
	}
	
}
