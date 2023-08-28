(function (Drupal, drupalSettings) {
	Drupal.behaviors.pdf_store = {
		attach: function(context, settings) {
			jQuery(once('.qr-code', context))
		  
		  	jQuery('.qr-code').once().click(function() {
				let getClass = this.className;
				let id = jQuery(this).attr('data-id');
				let uri = jQuery(this).attr('data-uri');

				const qrcode = new QRCode(id, {
					text: uri,
					// text: window.location.origin + uri, - If no views_base_uri present
					width: 350,
					height: 350,
					colorDark : '#000',
					colorLight : '#fff',
					correctLevel : QRCode.CorrectLevel.H
				});

				jQuery('.page-wrapper').addClass('pdf-list-pop');
				jQuery("body").append('<div class="qrcode-pop"></div>')
			  	// jQuery("body").append('<div class="qrcode-pop-close"><a class="qr-code-close"><img src="image/close-qr.png" alt="Close QR Pop" width="50" height="50"></a></div>');
			  	jQuery("body").append('<div class="qrcode-pop-close"><a class="button button--small qr-code-close">X</a></div>');
			  	jQuery(".qrcode-pop").append(jQuery('#'+id)).html();
			});
		  	jQuery(document).on('click','.qrcode-pop-close',function() {
				location.reload();
			});
		}
  	};
})(Drupal, drupalSettings);
