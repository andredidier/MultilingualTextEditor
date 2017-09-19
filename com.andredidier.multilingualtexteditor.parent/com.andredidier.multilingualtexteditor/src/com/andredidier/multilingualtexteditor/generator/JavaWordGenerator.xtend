package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Sentence
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
		'''«FOR tc : tcs»«tc.compile(index++, "p", context)»«ENDFOR»'''
	}
	def String compile(TextualContent tc, int index, String prefix, LanguageContext c) {
		if ((!tc.hiddenContent && (tc.models.isEmpty || tc.models.map[it.name].contains(c.model.name)))) {
			val pName = String.format("%s%d_%s", prefix, index, c.name)
			if (tc.children.isEmpty) {
				'''
				XWPFParagraph «pName» = doc_«c.name».createParagraph();
				«pName».setStyle("«tc.element.wordConfig.styleName»");
				«tc.values.compile(pName, c)»
				'''
			} else {
				tc.children.compileChildren(pName, c)
			}
		}
	}
	
	def String compileChildren(EList<TextualContent> children, String prefix, LanguageContext c) {
		var childIndex = 0
		'''
		«FOR child : children»
		«child.compile(childIndex++, prefix, c)»
		«ENDFOR»
		'''
	}
	
	def compile(EList<LocalizedText> lts, String pName, LanguageContext c) {
		var ltIndex = 0;
		//val varName = String.format("%s_r%d", pName, index)
		'''
		«FOR lt : lts»
			«IF lt.language.name == c.language.name»
			«lt.compile(ltIndex++, pName)»
			«ENDIF»
		«ENDFOR»
		'''
	}
	def compile(LocalizedText lt, int ltIndex, String pName) {
		'''«lt.values.compile(ltIndex, pName)»'''
	}
	def compile(EList<Sentence> ss, int ltIndex, String pName) {
		var sIndex = 0;
		'''
		«FOR s : ss»
		«IF s.deletionReview===null»
		«s.compile(sIndex++, ltIndex, pName)»
		«ENDIF»
		«ENDFOR»
		'''
	}
	def compile(Sentence s, int sIndex, int ltIndex, String pName) {
		val varName = String.format("%s_lt%d_s%d", pName, sIndex, ltIndex)
		'''
		XWPFRun «varName» = «pName».createRun();
		«IF s.modifier.contains("bold")»
		«varName».setBold(true);
		«ENDIF»
		«IF s.modifier.contains("italics")»
		«varName».setItalic(true);
		«ENDIF»
		«IF s.modifier.contains("underline")»
		«varName».setUnderline(UnderlinePatterns.DASH);
		«ENDIF»
		«varName».setText("«s.value»");
		'''	
	}
	
	def String numId() {
		val listStyleIDCounter = 1
		val symbol = "\"=\""
		return '''
		"<w:numbering xmlns:wpc=\"http://schemas.microsoft.com/office/word/2010/wordprocessingCanvas\" xmlns:mc=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\" xmlns:v=\"urn:schemas-microsoft-com:vml\" xmlns:wp14=\"http://schemas.microsoft.com/office/word/2010/wordprocessingDrawing\" xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\" xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" xmlns:w14=\"http://schemas.microsoft.com/office/word/2010/wordml\" xmlns:w15=\"http://schemas.microsoft.com/office/word/2012/wordml\" xmlns:wpg=\"http://schemas.microsoft.com/office/word/2010/wordprocessingGroup\" xmlns:wpi=\"http://schemas.microsoft.com/office/word/2010/wordprocessingInk\" xmlns:wne=\"http://schemas.microsoft.com/office/word/2006/wordml\" xmlns:wps=\"http://schemas.microsoft.com/office/word/2010/wordprocessingShape\" mc:Ignorable=\"w14 w15 wp14\">\n" + 
			"<w:abstractNum w:abstractNumId=\""+«listStyleIDCounter»+"\">\n" + 
			"<w:nsid w:val=\"6871722E\"/>\n" + 
			"<w:multiLevelType w:val=\"hybridMultilevel\"/>\n" + 
			"<w:tmpl w:val=\"8FE6E4C8\"/>\n" + 
			"<w:lvl w:ilvl=\"0\" w:tplc=\"0410000D\">\n" + 
			"<w:start w:val=\"1\"/>\n" + 
			"<w:numFmt w:val=\"bullet\"/>\n" + 
			"<w:lvlText w:val=\""+«symbol»+"\"/>\n" + 
			"<w:lvlJc w:val=\"left\"/>\n" + 
			"<w:pPr>\n" + 
			"<w:ind w:left=\"720\" w:hanging=\"360\"/>\n" + 
			"</w:pPr>\n" + 
			"<w:rPr>\n" + 
			"<w:rFonts w:ascii=\"Webdings\" w:hAnsi=\"Webdings\" w:hint=\"default\"/>\n" + 
			"</w:rPr>\n" + 
			"</w:lvl>\n" + 
			"</w:abstractNum>\n" + 
			"<w:num w:numId=\"1\">\n" + 
			"<w:abstractNumId w:val=\"0\"/>\n" + 
			"</w:num>\n" + 
		"</w:numbering>"'''
	}
	
	def String styleMethod() {
		'''
		    private static BigInteger addListStyle(XWPFDocument doc, String style) {
		        try {
		            XWPFNumbering numbering = doc.createNumbering();
		            CTAbstractNum abstractNum = CTAbstractNum.Factory.parse(style);
		            XWPFAbstractNum abs = new XWPFAbstractNum(abstractNum, numbering);
		            // find available id in document
		            BigInteger id = BigInteger.valueOf(1);
		            boolean found = false;
		            while (!found) {
		                Object o = numbering.getAbstractNum(id);
		                found = (o == null);
		                if (!found)
		                    id = id.add(BigInteger.ONE);
		            }
		            // assign id
		            abs.getAbstractNum().setAbstractNumId(id);
		            // add to numbering, should get back same id
		            id = numbering.addAbstractNum(abs);
		            // add to num list, result is numid
		            return doc.getNumbering().addNum(id);
		        } catch (Exception e) {
		            e.printStackTrace();
		            return null;
		        }
		    }
    		'''
	}
	
	def compile(Text t, List<LanguageContext> contexts) {
		'''
			import java.io.FileOutputStream;
			import java.math.BigInteger;
			
			import org.apache.poi.xwpf.usermodel.XWPFAbstractNum;
			import org.apache.poi.xwpf.usermodel.XWPFDocument;
			import org.apache.poi.xwpf.usermodel.XWPFNumbering;
			import org.apache.poi.xwpf.usermodel.XWPFParagraph;
			import org.apache.poi.xwpf.usermodel.XWPFRun;
			import org.openxmlformats.schemas.wordprocessingml.x2006.main.CTAbstractNum;
			
			public class GenerateWordDocuments {
				
				«styleMethod»
			
				public static void main(String[] args) throws Exception {
					«FOR c: contexts»
					XWPFDocument doc_«c.name» = new XWPFDocument();
					
					BigInteger listStyle_«c.name» = addListStyle(doc_«c.name», «numId()»);
					
					XWPFParagraph para_«c.name» = doc_«c.name».createParagraph();
					//para_«c.name».setStyle("ListParagraph");
					para_«c.name».setNumID(listStyle_«c.name»);
					//para_«c.name».setNumID(BigInteger.valueOf(1));
					para_«c.name».getCTP().getPPr().getNumPr().addNewIlvl().setVal(BigInteger.valueOf(0));
					XWPFRun pararun_«c.name» = para_«c.name».createRun();
					pararun_«c.name».setText("teste1");					
					
					XWPFParagraph para2_«c.name» = doc_«c.name».createParagraph();
					//para2_«c.name».setStyle("ListParagraph");
					para2_«c.name».setNumID(listStyle_«c.name»);
					//para2_«c.name».setNumID(BigInteger.valueOf(1));
					para2_«c.name».getCTP().getPPr().getNumPr().addNewIlvl().setVal(BigInteger.valueOf(0));
					XWPFRun pararun2_«c.name» = para2_«c.name».createRun();
					pararun2_«c.name».setText("teste2");					

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

