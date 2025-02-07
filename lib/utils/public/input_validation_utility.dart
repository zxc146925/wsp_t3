class InputValidationUtility {
  static final RegExp _safeInputPattern = RegExp(r'^[a-zA-Z0-9\s\-_.,!?@#$%^&*()+=<>:;"`]+$');

  static String? validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return '請输入内容';
    }

    if (!_safeInputPattern.hasMatch(value)) {
      return '輸入包含不允許的字符';
    }

    // 检查特定的危险模式
    if (_containsSqlInjection(value) || _containsJsInjection(value) || _containsCommandInjection(value) || _containsFileInclusion(value) || _containsXmlInjection(value) || _containsFormatStringInjection(value) || _containsIpcInjection(value)) {
      return '輸入可能包含不安全的内容';
    }

    return null; // 输入有效
  }

  static bool _containsSqlInjection(String value) {
    final sqlPattern = RegExp(r'\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|FROM|WHERE)\b', caseSensitive: false);
    return sqlPattern.hasMatch(value);
  }

  static bool _containsJsInjection(String value) {
    final jsPattern = RegExp(r'<script|javascript:|on\w+\s*=', caseSensitive: false);
    return jsPattern.hasMatch(value);
  }

  static bool _containsCommandInjection(String value) {
    final commandPattern = RegExp(r'[;&|`]');
    return commandPattern.hasMatch(value);
  }

  static bool _containsFileInclusion(String value) {
    final filePattern = RegExp(r'\.\./|file:|https?:', caseSensitive: false);
    return filePattern.hasMatch(value);
  }

  static bool _containsXmlInjection(String value) {
    final xmlPattern = RegExp(r'<[^>]*>');
    return xmlPattern.hasMatch(value);
  }

  static bool _containsFormatStringInjection(String value) {
    final formatStringPattern = RegExp(r'%[scdioxXufFeEgGaAnp]');
    return formatStringPattern.hasMatch(value);
  }

  static bool _containsIpcInjection(String value) {
    final ipcPattern = RegExp(r'\bexec\s*\(|\beval\s*\(|\bsystem\s*\(', caseSensitive: false);
    return ipcPattern.hasMatch(value);
  }
}
