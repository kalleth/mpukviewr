var window_focus = true;
var since_defocused = 0;

function alertUser(evt) {
  var klass = evt.etype + '_enabled';
  if([window.Settings.klass.toLowerCase()] === true) {
    if(!window_focus) {
      since_defocused++;
      document.title = "("+since_defocused+") Viewr";
    }
    if(window.Settings.sounds_enabled === true) {
      $("audio")[0].play();
    }
    if(window.webkitNotifications && window.Settings.notifications_enabled === true) {
      dtopNotify(evt);
    }
  }
}

function textFromHTML(data) {
  var div = document.createElement('div');
  div.innerHTML = data;
  var body = div.textContent || div.innerText || data;
  return body;
}

function dtopNotify(evt) {
  if (window.webkitNotifications.checkPermission() < 1) {
    var title = evt.etype + ": " + evt.title;
    title = textFromHTML(title);
    var icon = "http://viewr.multiplay.co.uk/images/icons/" + evt.etype.toLowerCase() + ".png";
    var body = textFromHTML(evt.description);
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

function showEvent(evt) {
  var icon = '<div class="icon" title="'+evt.etype+'"></div>';
  if(evt.etype == "NEWS") {
    var title = '<p class="news_title"><a href="'+evt.uid+'" target="_blank">'+evt.title+'</a></p>'
  } else {
    var title = '<p class="news_title">' + evt.title + '</p>';
  }
  var thedate = new Date(evt.happened_at);
  var tmfield = '<time class="timeago" data-title="' + thedate.strftime("%d/%m/%y %H:%M") + '" datetime="' + evt.happened_at + '">Now</time>';
  var time = '<p class="time">'+tmfield+'</p>';
  var body = '<p class="news_body">' + evt.description + '</p>';
  var li = '<li id="added_event" class="news_item hidden unseen ' + evt.etype.toLowerCase() + '">' + icon + title + time + body + '</li>';
  $('#news_container ul').prepend($(li));
  var klass = evt.etype + '_enabled';
  if(window.Settings[klass.toLowerCase()] === true) {
    $('#added_event').fadeIn(800, function() {
      $('#added_event').attr('style', '');
    });
  }
  $('#added_event time').tooltip({
    placement: 'left'
  });
  $('#added_event time').timeago();
  $('#added_event').attr('id','');
  //remove the last child as well
  $('#news_container ul li:last-child').fadeOut(800, function() {
    $('#news_container ul li:last-child').remove();
  });
  alertUser(evt);
}

$(document).ready(function() {
  $("#notifications_enabled").bind('click', function() {
    if($(this).prop("checked")) {
      window.webkitNotifications.requestPermission();
    }
  });
  $("time.timeago").timeago();
  $("time").tooltip({placement: 'left'});
  var faye_url = "http://" + window.location.hostname + ":9292/faye";
  var client = new Faye.Client(faye_url);
  var s = client.subscribe('/messages', function(evt) {
    showEvent(evt);
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
