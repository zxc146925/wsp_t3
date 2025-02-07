(function () {
    var baseUri = (function () {
        if (document.currentScript) {
            return document.currentScript.src.replace(/flutter\.js$/, '');
        }
        var scripts = document.scripts;
        for (var i = 0; i < scripts.length; ++i) {
            var script = scripts[i];
            if (script.src.endsWith('flutter.js')) {
                return script.src.replace(/flutter\.js$/, '');
            }
        }
        return '';
    })();

    var script = document.createElement('script');
    script.src = baseUri + 'main.dart.js';
    script.type = 'application/javascript';
    document.head.appendChild(script);
})();
