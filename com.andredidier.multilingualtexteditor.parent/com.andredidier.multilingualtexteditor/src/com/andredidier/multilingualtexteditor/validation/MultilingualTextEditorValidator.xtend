/*
 * generated by Xtext 2.12.0
 */
package com.andredidier.multilingualtexteditor.validation

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.MultilingualTextEditorPackage
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check

/**
 * This class contains custom validation rules. 
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class MultilingualTextEditorValidator extends AbstractMultilingualTextEditorValidator {

//	public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					MultilingualTextEditorPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}
	@Check
	def checkAllLanguages(Text text) {
	}

	def Text getRoot(EObject o) {
		if (o instanceof Text) {
			return o;
		} else if (o.eContainer !== null) {
			return o.eContainer.root;
		} else {
			return null;
		}
	}

	def format(Language lc) {
		'''«lc.code»«IF lc.country!==null»_«lc.country.name»«IF lc.country.variantCode!==null»_«
		lc.country.variantCode»«ENDIF»«ENDIF»'''
	}
	
	@Check
	def void checkAllLanguages(TextualContent textualContent) {
		if (textualContent.children.isEmpty) {
			for (language : textualContent.root.languages) {
				val found = textualContent.values.map[it.language].exists[it.name.equals(language.name)];
				if (!found ) {
					error("Text not translated for " + language.format,
						MultilingualTextEditorPackage.Literals.TEXTUAL_CONTENT__VALUES, "missingTranslation");
				}
			}
		} else {
			for (child : textualContent.children) {
				child.checkAllLanguages
			}
		}
	}

}
