package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Words
import java.util.Arrays
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.eclipse.xtext.nodemodel.util.NodeModelUtils

class SyntaxAndGrammarGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for(lc : resource.allContents.toIterable.filter(LanguageCode)) {
			var suffix = lc.value;
			if (lc.countryCode!==null) {
				suffix += "_" + lc.countryCode.value;
				if (lc.countryCode.variantCode!==null) {
					suffix += "_" + lc.countryCode.variantCode;
				}
			}
			
			val className = resource.URI.lastSegment.replace(".mte", "") + "_" + suffix;
			
			for (t:resource.allContents.toIterable.filter(Text)) {
				fsa.generateFile("java/" + className + '.java', 
					t.verifySyntaxAndGrammar(className, lc)
				)
			}
		}
		
	}
	
	def ltLanguageCode(LanguageCode lc) {
		'''«lc.value»«IF lc.countryCode!==null»-«lc.countryCode.value»«IF lc.countryCode.variantCode!==null»«ENDIF»«ENDIF»'''
	}
	
	def locale(LanguageCode lc) {
		'''
		«IF lc.countryCode === null»
			new Locale("«lc.value»")
		«ELSEIF lc.countryCode.variantCode === null»
			new Locale("«lc.value»", "«lc.countryCode.value»")
		«ELSE»
			new Locale("«lc.value»", "«lc.countryCode.value»", "«lc.countryCode.variantCode»")
		«ENDIF»
		'''
	}
	
	
	def verifySyntaxAndGrammar(Text t, String className, LanguageCode lc) {
		var ch = new CursorHandler();
		'''
		public class «className» {
			public static void main(String[] args) throws IOException {
				JLanguageTool lt = new JLanguageTool(Languages.getLanguageForLocale(«lc.locale»));
				AnnotatedTextBuilder atb = new AnnotatedTextBuilder();
				«t.annotate(lc, ch)»
				AnnotatedText at = atb.build();
				System.out.println("Plain text: \"" + at.getPlainText() + "\"");
				Collection<RuleMatch> matches = lt.check(at);
				for (RuleMatch match : matches) {
					System.out.println("Potential error at characters " + match.getFromPos() + "-" + 
						match.getToPos() + ": " + match.getMessage());
					System.out.println("Suggested correction(s): " + 
						match.getSuggestedReplacements());
				}
			}
		}
		'''
	}
	
	def annotate(Text t, LanguageCode lc, CursorHandler ch) {
		'''
		«FOR lcIgnore : t.languageCodes»
			«lcIgnore.addMarkup(ch)»
		«ENDFOR»
		«FOR tc: t.textualContents»
			«tc.annotate(lc, ch)»
		«ENDFOR»
		'''
	}

	def makeEmpty(int size) {
		var charArray = newCharArrayOfSize(size);
		Arrays.fill(charArray, ' ');
		return new String(charArray)
	}
	
	def addMarkup(EObject o, CursorHandler ch) {
		val node = NodeModelUtils.getNode(o)
		val size = node.endOffset - ch.cursor
		ch.cursor = node.endOffset + 1
		'''
		atb.addMarkup("«makeEmpty(size)»\n");
		'''
	}
	
	def addMarkup(String t, CursorHandler ch) {
		ch.cursor = ch.cursor + t.length + 1 + 2
		'''
		atb.addMarkup("«t»");
		'''
	}
	
	def addText(String t, CursorHandler ch) {
		ch.cursor = ch.cursor + t.length + 1 + 2
		'''
		atb.addText("«t»");
		'''
	}
	
	def annotate(TextualContent tc, LanguageCode lc, CursorHandler ch) {
		'''
		«tc.type.addMarkup(ch)»
		«FOR lt: tc.values»
			«IF lt.languageCode.equivalent(lc)»
				«lt.annotate(ch)»
			«ELSE»
				«lt.addMarkup(ch)»
			«ENDIF»
		«ENDFOR»
		'''
	}
	
	def annotate(LocalizedText lt, CursorHandler ch) {
		lt.languageCode.addMarkup(ch)
		'''
		«FOR w : lt.values»
			«w.annotate(ch)»
		«ENDFOR»
		atb.addText("\n");
		'''
	}
	
	def annotate(Words w, CursorHandler ch) {
		'''
		«FOR m : w.modifier»
			«m.addMarkup(ch)»
		«ENDFOR»
		«IF w.modifier.contains("strikethrough")»
			«(w.value + " ").addMarkup(ch)»
		«ELSE»
			«(w.value + " ").addText(ch)»
		«ENDIF»
		
		'''
		/*
		for (m : w.modifier) {
			atb.addMarkup(m);
		}
		atb.addText(w.value)
		atb.addText(' ') */
	}
	def equivalent(LanguageCode l1, LanguageCode l2) {
		return l1.value == l2.value && l1.countryCode.value == l2.countryCode.value && 
			l1.countryCode.variantCode == l2.countryCode.variantCode;
	}
	
/*	

	
	def addMarkup(AnnotatedTextBuilder atb, EObject o) {
		val node = NodeModelUtils.getNode(o);
		println("Adding markup: \"" + node.text + "\"");
		atb.addMarkup(node.text);
	}
	
	def addText(AnnotatedTextBuilder atb, EObject o) {
		val node = NodeModelUtils.getNode(o);
		val nt = node.text;
		println("Adding text: " + nt);
		atb.addMarkup(nt.substring(0,1));
		atb.addText(nt.substring(1, nt.length-1));
		atb.addMarkup(nt.substring(nt.length-1, nt.length))
	}
	 */
}