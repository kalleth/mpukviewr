function showPopup() {
  window.open("/popup", "popup_window","status=0,toolbar=0,menubar=0,location=0,height=700,width=400");
}

$(document).ready(function() {
  $('#show_popup').bind('click', function() {
    showPopup(); 
  });
});
