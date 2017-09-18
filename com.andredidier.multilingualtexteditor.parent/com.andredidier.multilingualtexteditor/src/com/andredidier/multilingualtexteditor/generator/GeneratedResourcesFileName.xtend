package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.LanguageCode
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import java.util.function.BiConsumer

class GeneratedResourcesFileName {
	def static generate(Text t, BiConsumer<LanguageCode, Model> a) {
		for (lc : t.languageCodes) {
			t.generate(lc, a);
		}
	}
	
	def static suffix(LanguageCode lc, Model m) {
		var suffix = lc.value;
		if (lc.countryCode !== null) {
			suffix += "_" + lc.countryCode.value;
			if (lc.countryCode.variantCode !== null) {
				suffix += "_" + lc.countryCode.variantCode;
			}
		}
		return suffix + "_" + m.value
	}
	
	def static generate(Text t, LanguageCode lc, BiConsumer<LanguageCode, Model> a) {
		for (m : t.models) {
			a.accept(lc, m)
		}
	}
	
}
