package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import java.util.LinkedList
import java.util.List
import org.eclipse.emf.common.util.EList
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext

import static extension com.andredidier.multilingualtexteditor.generator.GeneratedResourcesFileName.*

class JavaWordGenerator extends AbstractGenerator {
	
	static class LanguageContext {
		private Language l
		private Model m
		private String name
		
		new(Language l, Model m) {
			this.l = l;
			this.m = m;
			this.name = l.name + if (m === null) "" else "_" + m.name 
		}
		
		def getName() {
			return name  
		}
		
		def getModel() {return m}
		def getLanguage() {return l}
	}

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		val contexts = new LinkedList<LanguageContext>()
		for (t : resource.allContents.toIterable.filter(Text)) {
			t.generate[l,m| contexts.add(new LanguageContext(l,m))]
			fsa.generateFile("word/GenerateWordDocuments.java", t.compile(contexts))
		}
	}
	
	def compile(EList<TextualContent> tcs, LanguageContext context) {
		var index = 1;
		'''«FOR tc : tcs»«tc.compile(index++, context)»«ENDFOR»'''
	}
	def compile(TextualContent tc, int index, LanguageContext c) {
		val pName = String.format("p%d_%s", index, c.name)
		'''
		«IF (!tc.hiddenContent && (tc.models.isEmpty || tc.models.map[it.name].contains(c.model.name)))»
		XWPFParagraph «pName» = doc_«c.name».createParagraph();
		«pName».setStyle("«tc.element.wordConfig.styleName»");
		XWPFRun «pName»_r1 = «pName».createRun();
		«pName»_r1.setBold(true);
		«pName»_r1.setText("The quick brown fox");
		«pName»_r1.setBold(true);
		«pName»_r1.setFontFamily("Courier");
		«pName»_r1.setUnderline(UnderlinePatterns.DOT_DOT_DASH);
		«pName»_r1.setTextPosition(100);
		«ENDIF»
		'''
	}
	
	def compile(Text t, List<LanguageContext> contexts) {
		'''
			import java.io.FileOutputStream;
			
			import org.apache.poi.xwpf.usermodel.Borders;
			import org.apache.poi.xwpf.usermodel.BreakClear;
			import org.apache.poi.xwpf.usermodel.BreakType;
			import org.apache.poi.xwpf.usermodel.LineSpacingRule;
			import org.apache.poi.xwpf.usermodel.ParagraphAlignment;
			import org.apache.poi.xwpf.usermodel.TextAlignment;
			import org.apache.poi.xwpf.usermodel.UnderlinePatterns;
			import org.apache.poi.xwpf.usermodel.VerticalAlign;
			import org.apache.poi.xwpf.usermodel.XWPFDocument;
			import org.apache.poi.xwpf.usermodel.XWPFParagraph;
			import org.apache.poi.xwpf.usermodel.XWPFRun;
			
			public class GenerateWordDocuments {
			
				public static void main(String[] args) throws Exception {
					«FOR c: contexts»
					XWPFDocument doc_«c.name» = new XWPFDocument();
					«t.textualContents.compile(c)»
					FileOutputStream out_«c.name» = new FileOutputStream("simple_«c.name».docx");
					doc_«c.name».write(out_«c.name»);
					out_«c.name».close();
					doc_«c.name».close();
					«ENDFOR»
				}
			}
		'''
	}	
	
}

