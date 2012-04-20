var window_focus = true;
var since_defocused = 0;

var Settings = new Object({
  notifications_enabled: false,
  sounds_enabled: true,
  tweet_enabled: true,
  forum_enabled: true,
  tourney_enabled: true,
  facebook_enabled: true,
  news_enabled: true
});


function alertUser(evt) {
  var klass = evt.etype + '_enabled';
  if(Settings[klass.toLowerCase()] === true) {
    if(!window_focus) {
      since_defocused++;
      document.title = "("+since_defocused+") Viewr";
    }
    if(Settings.sounds_enabled === true) {
      console.log("Playing sounds");
      $("audio")[0].play();
    }
    if(window.webkitNotifications && Settings.notifications_enabled === true) {
      dtopNotify(evt);
    }
  }
}

function dtopNotify(evt) {
  if (window.webkitNotifications.checkPermission() < 1) {
    var title = evt.etype + ": " + evt.title;
    var html = evt.description;
    var div = document.createElement('div');
    div.innerHTML = html;
    var icon = "http://viewr.multiplay.co.uk/images/icons/" + evt.etype.toLowerCase() + ".png";
    var body = div.textContent ||  div.innerText || "Error!";
    var popup = window.webkitNotifications.createNotification(icon, title, body);
    popup.show();
    setTimeout(function() {
      popup.cancel();
    }, '15000');
  }
}

function fadeUnseen() {
  if(window_focus) {
    setTimeout(function() {
      $("li.unseen").each(function() {
        $(this).animate({backgroundColor:"#f8f8f8"}, 2000, function() {
          $(this).removeClass('unseen');
        });
      });
    }, 1000);
  }
}

function storeSettingsInCookie() {
  $.cookie('settings', JSON.stringify(Settings), { expires: 7 });
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
    //var id = this.id.substr(9);
    var new_value = ($("#" + this.id + ":checked").length > 0);
    Settings[this.id] = new_value;
    var klass = this.id.substr(0, (this.id.length - 8));
    respectFilters(klass, new_value);
    db_storeSettingsInCookie();
}

function onWindowFocus() {
  window_focus = true;
  since_defocused = 0;
  document.title = "Viewr";
  fadeUnseen();
}

dbOnWindowFocus = onWindowFocus.debounce(250, true);

function onWindowLoseFocus() {
  window_focus = false;
}
dbOnWindowLoseFocus = onWindowLoseFocus.debounce(250, true);

$(document).ready(function() {
  //reflect cookie settings if exists
  if ($.cookie('settings') != null) {
    Settings = JSON.parse($.cookie('settings'));
  }
  $(":checkbox[id*='enabled']").each(function(cb){
    $(this).click(checkListener);
    //reflect settings
    var klass = this.id.substr(0, (this.id.length - 8));
    if (Settings[this.id]) {
      $(this).prop("checked", true);
      respectFilters(klass, true);
    } else {
      $(this).prop("checked", false);
      respectFilters(klass, false);
    }
  });
  $("#notifications_enabled").bind('click', function() {
    if($(this).prop("checked")) {
      window.webkitNotifications.requestPermission();
    }
  });
  $("time.timeago").timeago();
  var faye_url = "http://" + window.location.hostname + ":9292/faye";
  var client = new Faye.Client(faye_url);
  var s = client.subscribe('/messages', function(evt) {
    var icon = '<div class="icon" title="'+evt.etype+'"></div>';
    if(evt.etype == "NEWS") {
      var title = '<p class="news_title"><a href="'+evt.uid+'">'+evt.title+'</a></p>'
    } else {
      var title = '<p class="news_title">' + evt.title + '</p>';
    }
    var tmfield = '<time class="timeago" data-tooltip="' + evt.happened_at + '" datetime="' + evt.happened_at + '">Now</time>';
    var time = '<p class="time">'+tmfield+'</p>';
    var body = '<p class="news_body">' + evt.description + '</p>';
    var li = '<li id="added_event" class="news_item hidden unseen ' + evt.etype.toLowerCase() + '">' + icon + title + time + body + '</li>';
    $('#news_container ul').prepend($(li));
    var klass = evt.etype + '_enabled';
    if(Settings[klass.toLowerCase()] === true) {
    $('#added_event').fadeIn(800);
    }
    $('#added_event time').timeago();
    $('#added_event').attr('id','');
    //remove the last child as well
    $('#news_container ul li:last-child').fadeOut(800, function() {
      $('#news_container ul li:last-child').remove();
    });
    alertUser(evt);
  });
  $("#toggle_settings").bind('click', function() {
    $("#settings_container").fadeToggle('slow', 'linear');
  });
  $(window).focus(function() {
    dbOnWindowFocus();
  });
  $(window).blur(function() {
    dbOnWindowLoseFocus();
  });
  s.errback(function(err) {
    console.log(err);
  });
});
