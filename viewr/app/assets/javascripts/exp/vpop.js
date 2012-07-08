function fadeUnseen() {
  if(window.viewr.window_focus) {
    setTimeout(function() {
      $("li.unseen").each(function() {
        $(this).animate({backgroundColor:"#f8f8f8"}, 2000, function() {
          $(this).removeClass('unseen');
          $(this).removeClass('hidden');
          $(this).attr('style', '');
        });
      });
    }, 1000);
  }
}

function storeSettingsInCookie() {
  $.cookie('settings', JSON.stringify(window.Settings, { expires: 7 }));
}

function respectFilters(klass, new_value) {
  if(klass != "sounds" && klass != "notifications") {
    if(new_value === false) {
      $(".news_item."+klass).fadeOut('fast', function() {
        addCSSRule(".news_item."+klass, "display", "none");
      });
    } else {
      $(".news_item."+klass).fadeIn('fast', function() {
        addCSSRule(".news_item."+klass, "display", "block");
      });
    }
  }
}

//avoid storing too frequently.
db_storeSettingsInCookie = storeSettingsInCookie.debounce(500, false);

function checkListener (evt) {
    console.log("Checklistener called.");
    //var id = this.id.substr(9);
    var new_value = ($("#" + this.id + ":checked").length > 0);
    window.Settings[this.id] = new_value;
    var klass = this.id.substr(0, (this.id.length - 8));
    respectFilters(klass, new_value);
    db_storeSettingsInCookie();
}

$(document).ready(function() {
  $("time.timeago").timeago();
  $("time").tooltip({placement: 'left'});
  $("#toggle_settings").bind('click', function() {
    $("#settings_container").fadeToggle('slow', 'linear');
  });
});
