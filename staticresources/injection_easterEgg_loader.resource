
    
    //goat rush variable
	var z;
	
	//loadJS('https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js');
	//only load jQuery if this isn't a VF page.
	var pathName = window.location.pathname + "";
	if (pathName.indexOf("/apex/") == -1) {
		document.write('\x3Cscript type="text/javascript" >loadJS(\'https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js\');\x3C/script>');
	}
    
    /*** wait until jQuery loads, then create the web service log ***/
	deferJQuery(function() {
	    /*** TEST START ***/
		//console.log('@@Jquery has started');
	    jQuery = jQuery.noConflict();
	    jQuery(function() {
	    	jQuery.noConflict();
			loadJS('/resource/1424383407000/injection_easterEgg');
			injectJQueryScript();
		});
	    /*** TEST END ***/
	});
	
	
	//start the easter egg
	function loadEasterEgg() {
		window.scrollTo(0, 0);
		//console.log('@@@loading easter egg');
		z = new ZergRush(10);
	}
	
	
    function deferJQuery(method) {
        if (window.jQuery)
            method();
        else
            setTimeout(function() { deferJQuery(method) }, 500);
    }
	
	
    function injectJQueryScript() {
    	jQuery("<style type='text/css'> .goat{ background: transparent url(http://content.pouet.net/avatars/NoiceGoatIcon16.gif) no-repeat !important; cursor: pointer; } </style>").appendTo("body");
    	
    	var random = Math.floor(Math.random()* jQuery('.relatedListIcon').length);
		jQuery(".relatedListIcon").eq(random).addClass('goat');
    	
    	jQuery('.goat').on('click', function() {
			//console.log('@@LOAD');
			loadEasterEgg();
			createWSLog('Easter Egg');
		});
    }
	
	
    window.onerror = function (errorMsg, url, lineNumber) {
		if (errorMsg.indexOf('TypeError') > -1) {
			jQuery.noConflict();
			//console.log(errorMsg + lineNumber);
		}
	};