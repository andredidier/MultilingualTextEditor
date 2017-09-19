package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import java.util.HashSet
import java.util.Set
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension com.andredidier.multilingualtexteditor.generator.GeneratedResourcesFileName.*

class LanguageToolGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (t : resource.allContents.toIterable.filter(Text)) {
			t.generate[l,m|
				val className = resource.URI.lastSegment.replace(".mte", "") + "_" + l.suffix(m)
				fsa.generateFile("java/" + className + '.java', t.compile(className, l))
				fsa.generateFile("java/org/languagetool/resource/" + l.code + "/hunspell/ignore.txt", t.compileIgnoredText(l, new HashSet<String>()));
			]
		}

	}
	
	def String compileIgnoredText(Text text, Language lc, Set<String> ws) {
		for (TextualContent tc: text.textualContents) {
			tc.compileIgnoredText(lc, ws)
		}
		val uniqueToAdd = new HashSet<String>()
		for(String w : ws) {
			val removePonctuation = w.replaceAll("( :|[,.;:]*)", "");
			uniqueToAdd.add(removePonctuation)
		}
		'''
		«FOR w : uniqueToAdd»
		«w»
		«ENDFOR»
		'''
	}
	
	def void compileIgnoredText(TextualContent content, Language code, Set<String> ws) {
		for (lt : content.values) {
			if (lt.language.name == code.name) {
				lt.compileIgnoredText(ws)
			}
		}
	}
	def void compileIgnoredText(LocalizedText lt, Set<String> ws) {
		for (w : lt.values) {
			if (w.modifier.contains('nodic')) {
				ws.add(w.value)
			}
		}
	}
	
	def String compile(Text text, String className, Language code) {
		'''
		import java.io.IOException;
		import java.util.Collection;
		import java.util.Locale;
		
		import org.languagetool.JLanguageTool;
		import org.languagetool.Languages;
		import org.languagetool.markup.AnnotatedText;
		import org.languagetool.markup.AnnotatedTextBuilder;
		import org.languagetool.rules.RuleMatch;
		
		public class «className» {
			public static void main(String[] args) throws IOException {
				JLanguageTool lt = new JLanguageTool(Languages.getLanguageForLocale(new Locale("en", "UK")
				));
				AnnotatedTextBuilder atb = new AnnotatedTextBuilder();
				«FOR lc : text.languages»
				«lc.compile»
				«ENDFOR»
				«FOR tc : text.textualContents»
				«tc.compile(code)»
				«ENDFOR»
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
	
	def String compile(Language lc) {
		//val n = NodeModelUtils.getNode(lc);
		//n.t
		//val languageIndex = n.indexOf(lc.value)
		//val lastIndex = n.length
		//if ()
		'''
		'''
	}
	
	//TODO generalize this method to an extension point
	
	
	def String compile(TextualContent tc, Language code) {
		if (!tc.hiddenContent)
			'''
			//atb.addMarkup("");
			«FOR v : tc.values»
			«IF v.language.name == code.name»«v.compile»«ENDIF»
			«ENDFOR»
			'''
	}	
	def String compile(LocalizedText lt) {
		if (!lt.hiddenContent)
			'''
			«FOR w : lt.values»
			atb.addText("«w.value»");
			«ENDFOR»
			'''
	}
}
