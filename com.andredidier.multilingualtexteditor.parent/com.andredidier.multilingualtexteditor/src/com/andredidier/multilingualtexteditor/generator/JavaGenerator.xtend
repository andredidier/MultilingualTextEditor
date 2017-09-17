package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
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
				fsa.generateFile(className + '.java', t.compile(className, lc))
			}
		}

	}
	
	def CharSequence compile(Text text, String className, LanguageCode code) {
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
				//COMPILE
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
	
}
