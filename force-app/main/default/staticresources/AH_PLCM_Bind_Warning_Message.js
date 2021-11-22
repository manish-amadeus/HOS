//CS7 - Pop-Up warning when navigating away from Transformer.
function addNavigationWarning(listOfElements) {
	if(typeof(listOfElements) != 'undefined' && listOfElements != null && listOfElements.length > 0) {
		listOfElements.forEach(function(obj, index) {
			if(!obj.classList.contains('trigger-link') && !obj.classList.contains('warning-bound')
				&& obj.style.display != 'none') { //Ignore profile menu drop down
				var strHref = obj.getAttribute("href");
				var new_element = obj.cloneNode(true);
				new_element.classList.add("warning-bound");
				
				if(!obj.classList.contains('search-field')) {
					new_element.setAttribute("href", "javascript: void(0);");
					new_element.onclick = function(e) {
						if(e.target.classList.contains('search-button')) { //Search button clicked
							var searchBox = window.parent.document.body.getElementsByClassName('search-field');
							if(searchBox != null && searchBox.length > 0) {
								var searchText = searchBox[0].value.trim();
								if(searchText == '') {
									e.stopImmediatePropagation();
								}
								else {
									navigationClicked(e);
								}
							}
						}
						else {
							navigationClicked(e);
						}
					}
				}

				obj.style.display = "none";
				obj.parentNode.insertBefore(new_element, obj);
				obj.classList.add("warning-bound");
			}
		});
	}
}

//Remove warning message
function removeNavigationWarning(listOfElements) {
	if(typeof(listOfElements) != 'undefined' && listOfElements != null && listOfElements.length > 0) {
		listOfElements.forEach(function(obj, index) {
			if(obj.style.display == 'none') {
				obj.style.display = '';
				obj.classList.remove("warning-bound");
			}
			else if(obj.classList.contains('warning-bound')) {
				obj.parentNode.removeChild(obj);
			}
		});
	}
}

//On click of link display warning message
function navigationClicked(e) {
	if(confirm("Changes you made may not be saved. Do you want leave the site?")) {
		if(e.target.classList.contains('search-button') || e.target.classList.contains('option-text') 
			|| e.target.classList.contains('searchOption')) { //Search button clicked
			var searchBox = window.parent.document.body.getElementsByClassName('search-field');
			if(searchBox != null && searchBox.length > 0) {
				var strBaseURL = window.parent.location.origin;
				var strFullURL = window.parent.location.href;
				strFullURL = strFullURL.replace(strBaseURL + '/', '');
				var arr = strFullURL.split('/');
				var strCommunityName = arr[0] + '/' + arr[1];
				window.parent.location.href = strBaseURL + '/' + strCommunityName + '/global-search/' + searchBox[0].value.trim();
			}
		}
		else {
			if(e.target.tagName == 'A') {
				if(typeof(e.target.text) != 'undefined' && e.target.text != null && e.target.text.toString().toLowerCase() == 'logout') {
					var baseUrl = window.location.protocol + window.location.port + "//" + window.location.host;
					window.parent.location.href = baseUrl + '/customers/secur/logout.jsp';
				}
				else {
					e.target.nextElementSibling.click();
					window.parent.location.reload();
				}
			}
			else {
				e.target.parentNode.nextElementSibling.click();
				window.parent.location.reload();
			}
		}
	}
	else {
		if(typeof(e) != 'undefined' && e != null) {
			e.stopImmediatePropagation();
		}
		else {
			return false;
		}
	}
}