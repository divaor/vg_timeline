//// Browser detection
//
//var nAgt = navigator.userAgent;
//var browserName  = navigator.appName;
//var verOffset;
//
//if ((verOffset=nAgt.indexOf("Opera"))!=-1)
//   document.write('<link rel=”stylesheet” href=”/stylesopera.css” type=”text/css”>')
//else if ((verOffset=nAgt.indexOf("Chrome"))!=-1)
//   document.write('<link rel=”stylesheet” href=”/styleschrome.css” type=”text/css”>')
//else if ((verOffset=nAgt.indexOf("Firefox"))!=-1)
//   document.write('<link rel=”stylesheet” href=”/stylesff.css” type=”text/css”>')
//
//// end of browsing detection

Event.observe(window, 'load', function() {
  var gameDisp = $('game_display')
  if(gameDisp) {
    // Set width to game display on browsers that make it thinner
    if (gameDisp.clientWidth < 1196)
      gameDisp.setStyle({
        'width': '100%'
      });

    // Set height of right column in game info view
    var height = gameDisp.clientHeight
    $('right_column').setStyle({
      'height': (height - 24)+'px'
    })
  }
});

// Ajax request loading
document.observe("ajax:loading", function(event) {
  if(event.target.tagName.toLowerCase() != 'form') {
    var href = event.target.readAttribute('href');
    var lv = href.charAt(href.indexOf('lv=') + 3);
    $('lev'+lv).update("");
    $('lev'+lv).insert('<h4>Loading...</h4>');
    Effect.Appear('lev'+lv, {
      duration: 0.3
    });
    Effect.Appear('trans'+lv, {
      duration: 0.3,
      to: 0.3
    });
  }
});

// Ajax request complete
document.observe("ajax:complete", function(event) {
  if(event.target.tagName.toLowerCase() != 'form') {
    var focus = $$('.focus .fcs').first();
    if(focus) {
      focus.focus();
      focus.select();
    }

    // Close pop up window
    var close = $('window_close');
    if(close) {
      close.observe('click', function() {
        var lev = close.ancestors()[1];
        var trans = $('trans' + lev.readAttribute('id').charAt(3));
        new Effect.Fade(lev, {
          duration: 0.3
        });
        new Effect.Fade(trans, {
          duration: 0.3
        });
        lev.removeClassName('focus');
        lev.update('');
      });
    }
  }

  var char_pic = $('character_picture');
  if(char_pic) {
    char_pic.observe('change', function() {
      $('new_characters_game').setAttribute('data-remote', '');
    })
  }
});

// Ajax request failure
document.observe('ajax:failure', function(event) {
  alert('Whoops, something went wrong!!!');
  var href = event.target.readAttribute('href');
  var lv = href.charAt(href.indexOf('lv=') + 3);
  new Effect.Fade('lev'+lv, {
    duration: 0.3
  });
  new Effect.Fade('trans'+lv, {
    duration: 0.3
  });
});

function monthFilterPlatform(item, year, limit) {
  spinner(item.className, "Show");
  uncheckMonthFilterAll(item.className, true);
  updateMonth(item.className, year, limit);
}

function spinner(cls, type) {
  if (type == "Show") {
    Element.show('spinner'+cls);
  } else {
//Element.hide('spinner'+month);
}
}

function uncheckMonthFilterAll(month, unCheck) {
  if (unCheck == true) {
    var monthFilterAll = $('month_filter_all'+month);
    monthFilterAll.checked = false;
  }
}

function updateMonth(month, year, limit) {
  new Ajax.Request('/update_month',
  {
    method: "post",
    parameters: getCheckedMonth(month, year, limit)
  });
}

function getCheckedMonth(month, year, limit) {
  var desc = $$('.'+month);
  var check = false;
  var params = ""
  if (limit != 3)
    params = "y=" + year + "&w=" + month
  else
    params = "y=" + year + "&m=" + month
  var i = 1;
  desc.each(function(item) {
    if (item.checked == true) {
      params = params + "&" + i + "=" + item.id;
      i = i + 1;
      check = true;
    }
  })
  if (check == false) {
    params += getCheckedPlatformsYear(year)  + "&l=3";
  } else {
    params += "&l=" + limit
  }
  return params;
}

function monthFilterAll(item, year, limit) {
  if (item.checked == true) {
    spinner(item.className, "Show");
    uncheckFiltersPlatforms(item.className, true);
    item.checked = true;
    updateMonth(item.className, year, limit);
  } else {
    spinner(item.className, "Show");
    updateMonth(item.className, year, limit);
  }
}

function uncheckFiltersPlatforms(month) {
  var desc = $$('.'+month);
  desc.each(function(item) {
    if (item.checked == true) {
      item.checked = false;
    }
  });
}

function yearShowAll(item, limit) {
  if (item.checked == true) {
    monthSpinner(item.className, "Show");
    updateYear(item.className, limit);
  } else {
    monthSpinner(item.className, "Show");
    updateYear(item.className, 3);
  }
}

function yearFilter(item, cls, allId) {
  spinner(item.className, "Show");
  $(allId).checked = false;
  updateYear(cls);
}

function yearFilterAll(item, cls) {
  if (item.checked == true) {
    spinner(item.className, "Show");
    uncheckYearFilters(item);
    item.checked = true;
    updateYear(cls);
  } else {
    item.checked = true;
  }
}

function uncheckYearFilters(item) {
  var filters = $$('.'+item.className);
  filters.each(function(filter) {
    if (filter.checked == true && filter != item) {
      filter.checked = false;
    }
  });
}

function uncheckYearFilterAll(year, unCheck) {
  if (unCheck == true) {
    var yearFilterAll = $('year_filter_all'+year);
    yearFilterAll.checked = false;
  }
}

function updateYear(cls) {
  new Ajax.Request('/update_year',
  {
    method: "post",
    parameters: getCheckedYear(cls)
  });
}

function getCheckedYear(cls) {
  var filters = $$('.'+cls).concat($$('.p'+cls)).concat($$('.d'+cls));
  var params = "y=" + cls + "&l=3";
  var i = 1;
  filters.each(function(filter) {
    if (filter.checked == true) {
      params = params + "&" + i + "=" + filter.id;
      i = i + 1;
    }
  })
  params += getCheckedMonths();
  return params;
}

function getCheckedPlatformsYear(year) {
  var filters = $$('.'+year);
  var params = "";
  var i = 1;
  filters.each(function(filter) {
    if (filter.checked == true) {
      params += "&" + i + "=" + filter.id;
      i = i + 1;
    }
  })
  return params;
}

function getCheckedMonths() {
  var m = 0;
  var params = "";
  var check = false;
  var months = ["01","02","03","04","05","06","07","08","09","10","11","12"];
  while (m < 12) {
    var filters = $$('.'+months[m]);
    if (filters != "") {
      filters.each(function(filter) {
        if (filter.checked == true) {
          check = true;
          throw $break;
        }
      })
      if (check == true) {
        params += "&ig"+m+"="+months[m];
      }
      check = false;
    }
    m++;
  }
  return params;
}

function updateDay(sh, type, year, month, day) {
  if (month < 10) {
    month = "0"+month;
  }
  var params = getCheckedMonth(month, year, "3");
  params += "&type="+type+"&sh="+sh+"&date="+year+"-"+month+"-"+day;
  new Ajax.Request('/update_day',
  {
    method: "post",
    parameters: params
  });
}

function xCoord(event, gameId) {
  var x = event.clientX - 600;
  new Ajax.Request('/show_game_info',
  {
    method: "post",
    parameters: "id="+gameId+"&xcoord="+x
  });
}

function tooltipAjax(e, element, id) {
  var middle = screen.availWidth / 2;
  var x = e.screenX;
  var pos = 'left';
  var toolTip = 'topRight';
  var toolXOff = 11;
  var width = 'auto';
  if (element.name.length > 40)
    width = 335;
  if (x < middle) {
    pos = 'right';
    toolTip = 'topLeft';
    toolXOff = -11;
  }
  new Tip(element, {
    title: element.name,
    style: 'custom',
    fixed: true,
    showOn: 'click',
    closeButton: true,
    width: width,
    hideOn: {
      element: element,
      event: 'click'
    },
    hideOthers: true,
    hideAfter: false,
    hook: {
      target: toolTip,
      tip: toolTip
    },
    offset: {
      x: toolXOff,
      y: -37
    },
    ajax: {
      url: '/show_game_tooltip',
      options: {
        method: 'get',
        parameters: "id="+id+"&pos="+pos
      }
    }
  });
}

function setTooltipPosition(element, e, id) {
  var middle = screen.availWidth / 2;
  var x = e.screenX;
  var pos = 'left';
  if (x < middle) {
    pos = 'right';
  }
  var tooltipInfo = $('tooltip_info'+id)
  tooltipInfo.firstDescendant().addClassName(pos)
  tooltipInfo.firstDescendant().childElements().each( function(elem) {
    elem.addClassName(pos)
  })
  element.onmouseover = null;
}

function fullTooltipGameInfo(e, element, id) {
  var middle = screen.availWidth / 2;
  var x = e.screenX;
  var toolTip = 'topRight';
  var toolXOff = 15;
  var pos = 'right';
  var width = 'auto';
  if (element.id.length > 40)
    width = 355;
  if (x < middle) {
    pos = 'left';
    toolTip = 'topLeft';
    toolXOff = -15;
  }
  var tooltipInfo = $('tooltip_info'+id)
  tooltipInfo.firstDescendant().addClassName(pos)
  tooltipInfo.firstDescendant().firstDescendant().setStyle({
    'float': pos
  })
  new Tip(element, tooltipInfo, {
    title: element.id,
    style: 'protogrey',
    fixed: true,
    showOn: 'click',
    closeButton: true,
    width: width,
    hideOn: 'click',
    hideOthers: true,
    hideAfter: false,
    hook: {
      target: toolTip,
      tip: toolTip
    },
    offset: {
      x: toolXOff,
      y: -40
    }
  });
  element.onmouseover = null;
}

function tooltipGameInfo(element, content) {
  new Tip(element, content, {
    style: 'protogrey',
    fixed: true,
    border: 1,
    radius: 1,
    hideAfter: 2,
    hideOn: false,
    hideOthers: true,
    showOn: 'mousemove',
    width: 'auto',
    hook: {
      target: 'bottomLeft',
      tip: 'topLeft'
    }
  })
}

function tabselect1(tab) {
  var tablist = $('tabcontrol1').getElementsByTagName('li');
  var nodes = $A(tablist);

  nodes.each(function(node){
    if (node.id == tab.id) {
      tab.className='current_show_filter';
    } else {
      node.className='nc_show_filter';
    }
  });
}

function showImageLinks(id) {
  var hover = $('boxart_links'+id)
  Effect.Appear(hover, {
    duration: 0.5
  })
  $$('.boxart_links').each(function(element){
    if (element != hover)
      element.hide()
  })
  setTimeout(function(){
    Effect.Fade(hover)
  }, 5000)
}

function paneselect1(div) {
  var hidden_div;
  var nh_div1;
  var nh_div2;
  var nh_div3;
  var nh_div4;
  if(div == 'platforms_general_filters') {
    nh_div1 = $('developers_general_filters');
    nh_div2 = $('publishers_general_filters');
    nh_div3 = $('genres_general_filters');
    nh_div4 = $('ratings_general_filters');
  } else if(div == 'publishers_general_filters') {
    nh_div1 = $('developers_general_filters');
    nh_div2 = $('platforms_general_filters');
    nh_div3 = $('genres_general_filters');
    nh_div4 = $('ratings_general_filters');
  } else if(div == 'developers_general_filters') {
    nh_div1 = $('publishers_general_filters');
    nh_div2 = $('platforms_general_filters');
    nh_div3 = $('genres_general_filters');
    nh_div4 = $('ratings_general_filters');
  } else if(div == 'genres_general_filters') {
    nh_div1 = $('publishers_general_filters');
    nh_div2 = $('platforms_general_filters');
    nh_div3 = $('developers_general_filters');
    nh_div4 = $('ratings_general_filters');
  } else if(div == 'ratings_general_filters') {
    nh_div1 = $('publishers_general_filters');
    nh_div2 = $('platforms_general_filters');
    nh_div3 = $('developers_general_filters');
    nh_div4 = $('genres_general_filters');
  }
  hidden_div = $(div);
  nh_div1.style.display = "none";
  nh_div2.style.display = "none";
  nh_div3.style.display = "none";
  nh_div4.style.display = "none";
  hidden_div.style.display = "block";
}

function showHide(element) {
  if(element.innerHTML=='More') {
    element.update('Hide')
  } else {
    element.update('More')
  }
}

function showStats(elem, content) {
  new Tip(elem, content, {
    style: 'custom',
    fixed: true,
    showOn: 'click',
    hideOn: 'click',
    hook: {
      tip: 'topLeft'
    },
    stem: 'topLeft',
    offset: {
      x: 30,
      y: 10
    }
  });
  elem.onmouseover=null;
}

function showMorePlatforms(elem, content) {
  new Tip(elem, content, {
    style: 'custom',
    fixed: true,
    showOn: 'click',
    hideOn: 'click',
    hook: {
      tip: 'bottomRight'
    },
    stem: 'bottomRight',
    offset: {
      x: 20,
      y: 0
    }
  });
  elem.onmouseover=null;
}
