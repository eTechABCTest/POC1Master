    
    //hide the injection container
    try {
		document.getElementsByClassName("linksModule")[2].style.display="none"; 
	}
	catch(err) { }
    
    loadJS('../../soap/ajax/26.0/connection.js');
    
    /*** wait until the connection.js loads, then create the web service log ***/
	try {

    	//load the connection.js first
    	deferC(function() {
					
			loadJS('../../soap/ajax/29.0/apex.js');

    		//then load apex.js
		    deferA(function () {
		        
		        createWSLog(null);
		        
		    });
	    });
    } catch(err) {
    	console.log('@@ERROR:' + err);
    }
    
    /***** load javascript ******/
    function loadJS(url) {
        var newScript = document.createElement('script');
        newScript.type = 'text/javascript';
        newScript.src = url;
        document.getElementsByTagName('body')[0].appendChild(newScript);
    }
    
    /***** create the web service log ******/
    function createWSLog(activityType) {
        
        try {
        
	        var aurl = getURL();
	        
	        
			sforce.apex.execute("WebServiceLogTriggerHelper","createWebServiceLog",
		                       {url:aurl,
		                        aType:activityType},
								{onSuccess : success,
						      	onFailure : failure});
			 
			  
	                          
        } catch(err) {
        	console.log('@@ERROR:' + err);
        }
        
    }
    
    function success(result) {
		//console.log('@@Success');
	}
	 
	function failure(error) {
		//console.log('@@Error' + error);
	}
    
    function getURL() {
        var fLoc = window.location + ""; //ie: https://c.cs8.visual.force.com/apex/Account_US_Provider_Strategic?id=001L000000M2LKnIAN
        var fPath = window.location.pathname + ""; //ie: /a4ZL00000000FNg
        var u;
        
        if (fLoc.indexOf("/apex/") != -1) {
            u = "/apex/" + fLoc.split("/apex/")[1];
        }
        else {
            u = window.location.pathname;
        }
        return u;
    }
    
    
    
    
    //////////
    function deferC(method) {
        if (window.sforce)
            method();
        else
            setTimeout(function() { deferC(method) }, 50);
    }
    
    function deferA(method) {
        if (window.sforce.apex)
            method();
        else
            setTimeout(function() { deferA(method) }, 50);
    }
    