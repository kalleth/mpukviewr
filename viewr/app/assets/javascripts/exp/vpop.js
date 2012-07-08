window.window_focus = true;
var since_defocused = 0;

function fadeUnseen() {
  if(window.window_focus) {
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

function onWindowFocus() {
  window.window_focus = true;
  document.title = "Viewr";
  fadeUnseen();
}

dbOnWindowFocus = onWindowFocus.debounce(250, true);

function onWindowLoseFocus() {
  window.window_focus = false;
}
dbOnWindowLoseFocus = onWindowLoseFocus.debounce(250, true);

$(document).ready(function() {
  $("#notifications_enabled").bind('click', function() {
    if($(this).prop("checked")) {
      window.webkitNotifications.requestPermission();
    }
  });
  $("time.timeago").timeago();
  $("time").tooltip({placement: 'left'});
  $("#toggle_settings").bind('click', function() {
    $("#settings_container").fadeToggle('slow', 'linear');
  });
  $(window).focus(function() {
    dbOnWindowFocus();
  });
  $(window).blur(function() {
    dbOnWindowLoseFocus();
  });
});
