package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.BasicConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementWordConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Sentence
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import org.eclipse.emf.common.util.EList

import static extension com.andredidier.multilingualtexteditor.generator.ConfigurationExtensions.*

class JavaWordGenerator {

	def compile(EList<TextualContent> tcs, EList<ElementWordConfiguration> configs, BasicConfiguration bc) {
		var index = 1;
		'''«FOR tc : tcs»«tc.compile(index++, "p", configs, bc)»«ENDFOR»'''
	}

	def String compile(TextualContent tc, int index, String prefix, EList<ElementWordConfiguration> configs,
		BasicConfiguration bc) {
		if (tc.hasContents(bc)) {
			val pName = String.format("%s%d", prefix, index)
			if (tc.children.isEmpty) {
				'''
					XWPFParagraph «pName» = doc.createParagraph();
					«pName».setStyle("«configs.findFirst(tc.element.elementWordConfigurationFilter).styleName»");
					«tc.values.compile(pName, configs, bc)»
				'''
			} else {
				tc.children.compileChildren(pName, configs, bc)
			}
		}
	}

	def String compileChildren(EList<TextualContent> children, String prefix, EList<ElementWordConfiguration> configs, BasicConfiguration bc) {
		var childIndex = 0
		'''
			«FOR child : children»
				«child.compile(childIndex++, prefix, configs, bc)»
			«ENDFOR»
		'''
	}

	def compile(EList<LocalizedText> lts, String pName, EList<ElementWordConfiguration> configs, BasicConfiguration bc) {
		var ltIndex = 0;
		// val varName = String.format("%s_r%d", pName, index)
		'''
			«FOR lt : lts»
				«IF bc.localizedTextFilter.apply(lt)»
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

	def String compile(Text t, EList<ElementWordConfiguration> configs, BasicConfiguration bc) {
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
					XWPFDocument doc = new XWPFDocument();
					
					BigInteger listStyle = addListStyle(doc, «numId()»);
					
					XWPFParagraph para = doc.createParagraph();
					//para.setStyle("ListParagraph");
					para.setNumID(listStyle);
					//para.setNumID(BigInteger.valueOf(1));
					para.getCTP().getPPr().getNumPr().addNewIlvl().setVal(BigInteger.valueOf(0));
					XWPFRun pararun = para.createRun();
					pararun.setText("teste1");					
					
					XWPFParagraph para2 = doc.createParagraph();
					//para2.setStyle("ListParagraph");
					para2.setNumID(listStyle);
					//para2.setNumID(BigInteger.valueOf(1));
					para2.getCTP().getPPr().getNumPr().addNewIlvl().setVal(BigInteger.valueOf(0));
					XWPFRun pararun2 = para2.createRun();
					pararun2.setText("teste2");					
			
					«t.textualContents.compile(configs, bc)»
			
					FileOutputStream out = new FileOutputStream("src-gen/word/simple.docx");
					doc.write(out);
					out.close();
					doc.close();
				}
			}
		'''
	}

}
