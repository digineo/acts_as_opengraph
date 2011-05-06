
( function($) {
	
	var app_id = $('meta[property="fb:app_id"]').attr("content");
	var locale = $('meta[property="fb:locale"]').attr("content");
	
	if(!app_id){
		// inclusion not necessary
		return;
	}
	
	// fb callback
	window.fbAsyncInit = function() {
		FB.init({
			appId: app_id,
			status: true,
			cookie: true,
			xfbml: true
		});
	};
	
	// create <script> tag
	var e = document.createElement('script');
	e.type = 'text/javascript';
	e.async = true;
	e.src = document.location.protocol + '//connect.facebook.net/' + locale + '/all.js';
	
	// create <div id="fb-root"></div>
	var root = document.createElement('div');
	root.id = 'fb-root'
	
	// insert tags
	var s = document.getElementsByTagName('script')[0];
	s.parentNode.insertBefore(root, s);
	s.parentNode.insertBefore(e, s);
}(jQuery));
