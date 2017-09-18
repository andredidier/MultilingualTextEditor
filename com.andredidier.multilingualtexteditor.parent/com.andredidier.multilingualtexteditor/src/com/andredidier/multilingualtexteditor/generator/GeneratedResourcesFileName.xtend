package com.andredidier.multilingualtexteditor.generator

import com.andredidier.multilingualtexteditor.multilingualTextEditor.Language
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Model
import com.andredidier.multilingualtexteditor.multilingualTextEditor.Text
import java.util.function.BiConsumer

class GeneratedResourcesFileName {
	def static generate(Text t, BiConsumer<Language, Model> a) {
		for (lc : t.languages) {
			t.generate(lc, a);
		}
	}

	def static suffix(Language lc, Model m) {
		var suffix = lc.code;
		if (lc.country.name !== null) {
			suffix += "_" + lc.country.name;
			if (lc.country.variantCode !== null) {
				suffix += "_" + lc.country.variantCode;
			}
		}
		return suffix + if (m === null) "" else "_" + m.name
	}

	def static generate(Text t, Language lc, BiConsumer<Language, Model> a) {
		if (t.models.empty) {
			a.accept(lc, null)
		} else {
			for (m : t.models) {
				a.accept(lc, m)
			}
		}
	}

}
