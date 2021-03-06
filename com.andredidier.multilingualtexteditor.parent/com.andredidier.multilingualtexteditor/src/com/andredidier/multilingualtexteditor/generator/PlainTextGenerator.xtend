/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.BasicConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementPlainConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Sentence
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import java.util.Collections
import java.util.LinkedList
import java.util.function.Function
import org.eclipse.emf.common.util.EList

import static extension com.andredidier.multilingualtexteditor.generator.ConfigurationExtensions.*

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PlainTextGenerator {

	def String compile(Sentence w) {
		'''«IF w.deletionReview === null»«w.value»«ENDIF»'''
	}
	
	def String replaceLineBreaks(String str) {
		return str.replace("\\n", "\n");
	}

	@Deprecated	
	def String compile(LocalizedText langContents) {
		val texts = new LinkedList<String>()
		for (sentence : langContents.values) {
			var r = sentence.compile
			if (r !== "") {
				texts.add(r)
			}
		} 
		'''«texts.join(" ")»'''
	}
	
	def String compile(Text t, EList<ElementPlainConfiguration> configs, BasicConfiguration bc) {
		'''«FOR c : t.textualContents»«c.compileIfMeets(configs, bc, [it.compile])»«ENDFOR»'''
	}
	
	
	def String compileIfMeets(TextualContent el, EList<ElementPlainConfiguration> configs, BasicConfiguration bc, Function<Sentence, String> sentenceCompile) {
		if (el.hasContents(bc) && configs.findFirst(el.element.elementPlainConfigurationFilter).nullSafe[!it.hide]) {
			el.compile(configs, bc, sentenceCompile)
		} else {
			""
		}
	}
	
	def String compile(LocalizedText lt, Function<Sentence, String> sentenceCompile) {
		val texts = new LinkedList<String>()
		for (sentence : lt.nullSafe([it.values], Collections.emptyList)) {
			var r = sentenceCompile.apply(sentence)
			if (r !== "") {
				texts.add(r)
			}
		} 
		'''«texts.join(" ")»'''
	}
	
	def String compile(TextualContent c, EList<ElementPlainConfiguration> configs, BasicConfiguration bc, Function<Sentence, String> sentenceCompile) {
		val elementConfig = configs.elementFilter.apply(c.element)
		if (elementConfig === null) {
			//FIXME throw error or warning
			return ""
		}
		val prefix = elementConfig.nullSafe[it.prefix]
		val suffix = elementConfig.nullSafe[it.suffix]
		if (c.children.empty) {
			val localizedText = c.values.findFirst(bc.localizedTextFilter)
			if (!localizedText.nullSafe([it.hiddenContent], false)) {
				'''«prefix»«localizedText.compile(sentenceCompile)»«suffix»'''
			}
			
		} else {
			'''«prefix»«FOR child : c.children»«child.compileIfMeets(configs, bc, sentenceCompile)»«ENDFOR»«suffix»'''
		}
	}
	
}
