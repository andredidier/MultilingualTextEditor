package com.andredidier.multilingualtexteditor

import java.util.function.Function

/**
 * @author andre
 */
class MultilingualTextEditorExtensions {

	def static <T, R> nullSafe(T t, Function<T,R> f) {
		if (t === null) {
			return null
		}
		return f.apply(t)
	}
	def static <T, R> nullSafe(T t, Function<T,R> f, R ifNull) {
		if (t === null) {
			return ifNull
		}
		return f.apply(t)
	}
}
