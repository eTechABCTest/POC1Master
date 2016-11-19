/**
//http://pngimg.com/upload/grass_PNG401.png
<div class="zr_health" style="width: 54px; -webkit-user-select: none; visibility: visible; background-color: rgb(252, 209, 22);"></div>
**/

//add explanation to the top of the page
function loadExplanation() {
	jQuery("<div/>", {
		id: "easterEggText",
		style: "height: 50px; width: 100%; -webkit-user-select: none; visibility: visible; position: fixed; top: 35px; left: 15px;z-index: 100000;text-align: center; font-size: 34px; font-family: 'Comic Sans MS', 'Comic Sans', 'Marker Felt', serif;color: rgb(204, 0, 3);",
		class: "zrHealth",
		text: "The goats are hungry!"
	}).prependTo(jQuery("body"));
	
	jQuery("<div/>", {
		id: "escText",
		style: "width: 100%; -webkit-user-select: none; visibility: visible; position: fixed; top: 85px; left: 15px; height: 50px; font-size: 25px; z-index: 100000; text-align: center; font-family: 'Comic Sans MS', 'Comic Sans', 'Marker Felt', serif;color: rgb(204, 0, 3);",
		class: "zrHealth",
		text: "Press Esc to make them disappear"
	}).prependTo(jQuery("body"));
	//
}

//load grassy fields
/*function loadGrassyFields() {
	jQuery('.dataCol').each(function() {
		var _filename = "http://pngimg.com/upload/grass_PNG401.png";
		var img = jQuery(new Image()).attr('src', '' + _filename);
		
		jQuery(img)
		.css('height', jQuery(this).height())
		.css('width', jQuery(this).width())
		.css('opacity', 0.6)
		.css('position', 'absolute')
		.css('top', jQuery(this).position().top + 'px')
		.addClass('grassImg')
		.prependTo(jQuery(this))
	});
}*/

function loadCustomizations() {
	//load the grassy fields
	//loadGrassyFields();
  
	//load explanation
	loadExplanation();
}

/*** zerg functionality ***/
(function() {
  
  
  window.Zergling = Zergling;
  window.ZergRush = ZergRush;
  var ZERG_WIDTH = 45;
  var ZERG_HEIGHT = 45;

  var doc = document,
      body = doc.body,
      atan2 = Math.atan2,
      cos = Math.cos,
      sin = Math.sin,
      sqrt = Math.sqrt,
      PI = Math.PI,
      random = Math.random,
      max = Math.max;

  function Zergling(x, y, rush) {

    this.rush = rush; // ZergRush instance
    this.speed = 3;
    this.x = x;
    this.y = y;

    this.width = ZERG_WIDTH;
    this.height = ZERG_HEIGHT;

    this.isKilling = false;
    this.isFinished = false;

    this.dPulsate = 0;

    this.dom = jQuery('<zergling>').css({
      width: this.width,
      height: this.height,
      position: 'absolute',
	  'background-image': "url('http://img3.wikia.nocookie.net/__cb20100429202109/farmville/images/9/9e/Boer-Goat.gif')",
	  'background-repeat': 'no-repeat',
	  'background-size': '100%',
      display: 'block',
      //background: 'red',
      left: x,
      top: y,
      borderRadius: '5px',
      zIndex: 9999
    }).appendTo(body);

  }

  Zergling.DATA_KEY = 'zergTargetData';
  Zergling.MAX_TARGET_AREA = 50000;
  Zergling.VISION = 1000; // 1000 pixels in any direction
  Zergling.LIFE = 50;

  Zergling.isSuitableTarget = function isSuitableTarget(candidate) {

    var targetData;

    if (!candidate) {
      return false;
    }

    // Make sure none of its ancestors are currently targets:
    for (var parent = candidate; parent = parent.parentNode;) {
      if (jQuery.data(parent, Zergling.DATA_KEY) || /antiZerg/i.test(parent.className)) {
        return false;
      }
    }

    targetData = jQuery.data(candidate, Zergling.DATA_KEY);

    candidate = jQuery(candidate);
	
	var retVal = !/zergling/i.test(candidate[0].nodeName) &&
      !/antiZerg/i.test(candidate[0].className) && 
      // Make sure it's either yet-to-be-a-target or still alive:
      (!targetData || targetData.life > 0) &&
      // Make sure it's not too big
      candidate.width() * candidate.height() < Zergling.MAX_TARGET_AREA
	
	/*** VH ADDED - BEGINNING OF HEALTH BAR
	if (jQuery(candidate).children('zr_health').length == 0 
		&& retVal) {
		jQuery('<div/>', {
			id: 'zr_health',
			style: 'height: 5px; width: 54px; -webkit-user-select: none; visibility: visible; background-color: rgb(252, 209, 22)'
		}).prependTo(candidate);
	}
	/*** VH ADDED END **/

    return retVal;

  };

  Zergling.prototype = {

    calcMovement: function() {

      var target = this.target,
          // Move towards random position within the target element:
          xDiff = (target.position.left + random() * target.width) - this.x,
          yDiff = (target.position.top + random() * target.height) - this.y,
          angle = atan2(yDiff, xDiff);
		
      this.dx = this.speed * cos(angle);
      this.dy = this.speed * sin(angle);

    },

    draw: function() {

      if (this.isFinished) {
        return;
      }

      var target = this.target;

      if (this.isKilling) {
		
		/***VH TEST - didn't work -- overloaded with health bars
		if (jQuery(target.dom).children('zr_health').length == 0) {
			jQuery('<div/>', {
				id: 'zr_health',
				style: 'height: 5px; width: 54px; -webkit-user-select: none; visibility: visible; background-color: rgb(252, 209, 22)'
			}).prependTo(jQuery(target.dom));
			console.log('@@prepending...'+jQuery(target.dom));
		}
		 **/
	  
        if (target.life > 0) {
		
          // It's still alive! Pulsate and continue to kill:
          target.life--;
		  
		  var health = target.life / Zergling.LIFE;
		  /** update the health bar **/
		  setHealth(target, health*100);
		  
          this.pulsate();
          target.dom.css('opacity', health);
        } else {
          // It's DEAD! 
          target.dom.css('visibility', 'hidden');
          this.pulsate(0);
          this.isKilling = false;
          this.target = null;
        }
        return;
      }

      // If we have no target or if current target is dead:
      if (!this.target || this.target.life <= 0) {

        if (this.findTarget()) {
          target = this.target;
          this.calcMovement();
        } else {
          this.isFinished = true;
          this.dom.fadeOut(100, function() {
            jQuery(this).remove();
          });
          return;
        }

      }

      if (this.hasReachedTarget()) {
        this.isKilling = true;
        return;
      }

      this.x += this.dx;
      this.y += this.dy;
      this.dom.css({
        left: this.x,
        top: this.y
      });

    },

    hasReachedTarget: function() {

      var target = this.target,
          pos = target.position;

      return  this.x >= pos.left &&
              this.y >= pos.top &&
              this.x <= pos.left + target.width &&
              this.y <= pos.top + target.height
    },

    findTarget: function() {

      // Try to locate nearby elements, going further afield (increasing radius)
      // until we've found a viable target:

      var targetData, radius, degree, x, y, el,
          halfWidth = this.width / 2,
          halfHeight = this.height / 2,
          scrollTop = max(body.scrollTop, doc.documentElement.scrollTop),
          scrollLeft = max(body.scrollLeft, doc.documentElement.scrollLeft);

      for (radius = 10; radius < Zergling.VISION; radius += 50) {
        for (degree = 0; degree < 360; degree += 45) {

          x = this.x + halfWidth + radius * cos(PI/180 * degree) - scrollLeft;
          y = this.y + halfHeight + radius * sin(PI/180 * degree) - scrollTop;

          if (Zergling.isSuitableTarget(el = doc.elementFromPoint(x, y))) {

            el = jQuery(el);

            targetData = this.target = el.data(Zergling.DATA_KEY);

            if (!targetData) {
              el.data(
                Zergling.DATA_KEY,
                this.target = {
                  dom: el,
                  position: el.offset(),
                  width: el.width(),
                  height: el.height(),
                  life: Zergling.LIFE,
                  initialCSS: {
                    visibility: '',
                    opacity: el.css('opacity') || ''
                  }
                }
              );
              this.rush.registerTarget(this.target);
            }

            return true;

          }
        }
      }

    },

    pulsate: function() {
      if (this.dPulsate = !this.dPulsate) {
        this.dom.css({
          left: this.x - 2,
          top: this.y - 2,
          width: ZERG_WIDTH + 4,
          height: ZERG_HEIGHT + 4
        });
      } else {
        this.dom.css({
          left: this.x,
          top: this.y,
          width: ZERG_WIDTH,
          height: ZERG_HEIGHT
        });
      }
    }

  };


  function ZergRush(nZerglings) {
	
	//load customizations
	loadCustomizations();
	
    var me = this,
        zerglings = this.zerglings = [],
        targets = this.targets = [];

    for (var i = 0; i < nZerglings; ++i) {
      zerglings.push(
        new Zergling(
          random() * 100,
          random() * 100,
          this
        )
      );
    }

    this.intervalID = setInterval(function() {
      me.step()
    }, 30);

  }

  ZergRush.prototype = {
    step: function() {

      var areFinished = true;
      
      for (var i = 0; i < this.zerglings.length; ++i) {
        this.zerglings[i].draw();
        areFinished = areFinished && this.zerglings[i].isFinished;
      }

      if (areFinished) {
        clearInterval(this.intervalID);
      }

    },
    destroy: function() {
      clearInterval(this.intervalID);
      for (var i = 0; i < this.zerglings.length; ++i) {
        this.zerglings[i].dom.remove();
      }
      for (var i = 0; i < this.targets.length; ++i) {
        this.targets[i].dom.css(this.targets[i].initialCSS);
        this.targets[i].dom.removeData(Zergling.DATA_KEY);
      }
	  
	  //clear all health bars
	  
    },
    registerTarget: function(target) {
		if (jQuery(target.dom).children('#zr_health').length == 0) {
			jQuery('<div/>', {
				id: 'zr_health',
				style: 'height: 5px; width: 0px; -webkit-user-select: none; visibility: visible; background-color: white;',
				class: 'zrHealth'
			}).prependTo(jQuery(target.dom));
			//console.log('@@prepending...'+jQuery(target.dom));
		}
      this.targets.push(target);
    }
  }

}());

function setHealth(target, healthValue) {
	var healthBar = jQuery(target.dom).children('#zr_health');
	var healthColor = getHealthColor(healthValue);
	//getHealthColor
	jQuery(healthBar).css('width', healthValue).css('background-color', getHealthColor(healthValue));
	
	//remove the health indicator once it's been destroyed
	if (healthValue <= 0) jQuery(healthBar).remove();
}

function getHealthColor(healthValue) {
	if (healthValue >= 70) return 'green';
	if (healthValue >= 40) return 'yellow';
	else return 'red';
}

/*** set the page back to normal and end the rush if the user clicks ESC ***/
jQuery(document).keyup(function(e) {
  if (e.keyCode == 27) { 
    z.destroy();
    //remove any images or health bars that were added
	jQuery('.grassImg').remove();
	jQuery('.zrHealth').remove();
  }   // esc
});


///EXECUTE RUSH
//var z = new ZergRush(20);