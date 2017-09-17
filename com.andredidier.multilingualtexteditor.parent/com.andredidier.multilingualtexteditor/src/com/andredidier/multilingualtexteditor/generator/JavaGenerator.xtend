package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.CountryCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

class JavaGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		for (lc : resource.allContents.toIterable.filter(LanguageCode)) {
			var suffix = lc.value;
			if (lc.countryCode !== null) {
				suffix += "_" + lc.countryCode.value;
				if (lc.countryCode.variantCode !== null) {
					suffix += "_" + lc.countryCode.variantCode;
				}
			}
			
			val className = resource.URI.lastSegment.replace(".mte", "") + "_" + suffix;

			for (t : resource.allContents.toIterable.filter(Text)) {
				fsa.generateFile("java/" + className + '.java', t.compile(className, lc))
			}
		}

	}
	
	def String compile(Text text, String className, LanguageCode code) {
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
	
	//TODO generalize this method to an extension point
	
	
	def boolean equivalent(LanguageCode l1, LanguageCode l2) {
		if (l1.value != l2.value) return false;
		if (l1.countryCode === null) {
			return l2.countryCode === null; 
		} else {
			return l1.countryCode.equivalent(l2.countryCode);
		}
	}
	def boolean equivalent(CountryCode c1, CountryCode c2) {
		if (c1.value != c2.value) return false;
		if (c1.variantCode === null) {
			return c2.variantCode === null;
		} else {
			return c1.variantCode === c2.variantCode;
		}
	}
	def String compile(TextualContent tc, LanguageCode code) {
		if (!tc.hiddenContent)
			'''
			atb.addMarkup("«tc.type»");
			«FOR v : tc.values»
			«IF v.languageCode.equivalent(code)»«v.compile»«ENDIF»
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
