package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.BasicConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Element
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementHtmlConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementMdConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementPlainConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.ElementWordConfiguration
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.LocalizedText
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.TextualContent
import java.util.function.Function

class ConfigurationExtensions {
	

	def static <T, R> R nullSafe(T o, Function<T, R> f) {
		if (o === null) {
			return null
		} else {
			return f.apply(o)
		}
	}

	def static <T, R> R nullSafe(T o, Function<T, R> f, R defaultValue) {
		if (o === null) {
			return defaultValue
		} else {
			return f.apply(o)
		}
	}

	def static boolean hasContents(TextualContent c, BasicConfiguration bc) {
		return c.hasContents(bc.model)
	}
	
	def static boolean hasContents(TextualContent c, Model model) {
		return !c.hiddenContent && (c.models.isEmpty || c.models.map[it.name].contains(model.name))
	}
	
	def static (Language)=>boolean languageFilter(BasicConfiguration config) {
		return [l|config.language.name == l.name]
	}
	
	def static (LocalizedText)=>boolean localizedTextFilter(BasicConfiguration config) {
		return [l|config.languageFilter.apply(l.language)]
	}
	
	def static (ElementPlainConfiguration)=>boolean elementPlainConfigurationFilter(Element el) {
		return [epc|epc.element.equals(el)]
	}

	def static (ElementHtmlConfiguration)=>boolean elementHtmlConfigurationFilter(Element el) {
		return [epc|epc.element.equals(el)]
	}

	def static (ElementWordConfiguration)=>boolean elementWordConfigurationFilter(Element el) {
		return [epc|epc.element.equals(el)]
	}
	
	def static (ElementMdConfiguration)=>boolean elementMdConfigurationFilter(Element el) {
		return [emc|emc.element.equals(el)]
	}

	def static (Element)=>ElementPlainConfiguration elementFilter(Iterable<ElementPlainConfiguration> configs) {
		return [el|configs.findFirst[it.element.equals(el)]]
	}
	
	def static (TextualContent)=>boolean textualContentFilter(Iterable<ElementHtmlConfiguration> configs) {
		return [tc|configs.exists[it.element.equals(tc.element)]]
	}
	
}