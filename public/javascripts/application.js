var popId;




// Global variables for slideContainer

// Holds the position of the left edge of the list
var leftEdge;
// Holds the position of the right edge of the list
var rightEdge;

function slideContainer(direction, elemWidth, event) {
  // The distance to move in pixels
  var moveDistance = 500;

  // Check the position of the list to see if it's on the edge
  if(((rightEdge >= elemWidth) && (direction == "right")) || ((leftEdge <= 0) && (direction == "left"))) {
    // It's on the edge and trying to move, stop the event
    event.stop();
  } else {
    // Difference between the container and what is hidden of the list
    var difference = direction == "right" ? elemWidth - rightEdge : leftEdge;
    // Distance to move if difference is less than move distance
    var move = (difference < moveDistance) ? difference : moveDistance;
    // Set edges values
    leftEdge = direction == "right" ? leftEdge + move : leftEdge - move;
    rightEdge = direction == "right" ? rightEdge + move : rightEdge - move;
    // Move effect
    new Effect.Move($$("#year_nav_slider ul").first(), {
      x: direction == "right" ? -move : move,
      y: 0
    });
  }
}

// Runs when DOM is loaded
document.observe('dom:loaded', function() {
  // Application layout


  // Years navigation list

  // Holds the width of the years navigation bar
  var yearsListWidth = 0;
  // Calculates the width of the years list
  $$('#year_nav_slider li').each(function(year) {
    yearsListWidth += year.getWidth();
  });
  // Holds the width of the years navigation container
  var yearsNavContWidth = $('year_nav_slider').getWidth();
  // Observe when sliding right
  $$(".year_text .previous_year").first().observe('click', function(click) {
    slideContainer("right", yearsListWidth, click);
  });

  leftEdge = 0;
  rightEdge = yearsNavContWidth;

  // Observe when sliding left
  $$(".year_text .next_year").first().observe('click', function(click) {
    slideContainer("left", yearsListWidth, click);
  });





  // Year view
  if($('year_display')) {
    // TODO javascripts for year display
  }

  // Game Info View
  var gameDisp = $('game_display')
  if(gameDisp) {
    // Set height of right column in game info view
    var height = gameDisp.clientHeight
    $('right_column_content').setStyle({
      'height': (height - 24)+'px'
    });

    var exclusive = $$('#diff_platforms_cont .exclusive_on_platform').first();
    if(exclusive) {
      exclusive.observe('click', function(click) {
        // TODO get game id
        var id = $('diff_platforms_cont').readAttribute('data-gameid');
        var link = this;
        new Ajax.Request('/games/' + id + '/exclusive', {
          method: 'get',
          onSuccess: function() {
            $$('#info_also_on .game_info_table .platform').first().insert({
              top: "Exclusively on "
            });
            link.hide();
          }
        });
        click.stop();
      });
    }
  }

  // Search box
  var resultText = $('result_text');
  if(resultText) {
    var clearTextMain = $('clear_text_main_search');
    var legend = 'Game, Publisher, Developer, Character';

    resultText.observe('blur', function() {
      // Legend to be displayed when no text is entered
      searchText(this, 1, legend);
    });

    resultText.observe('keyup', function() {
      showClear(clearTextMain, this);
    });

    resultText.observe('focus', function() {
      searchText(this, 0, legend);
    });

    // Observe click on clear text image
    clearTextMain.observe('click', function(click) {
      clearText(resultText, this); // TODO finish
      click.stop();
    });
  }

  var viewStats = $('view_stats');
  if(viewStats) {
    viewStats.observe('click', function(click) {
      click.stop();
    });

    viewStats.observe('mouseover', function() {
      showStats(this, $('year_stats'));
    });
  }

  // Observe form submits to check for remote calls
  observeFormSubmits();
});

// Observe form submits
function observeFormSubmits() {
  $$('form').each(function(form) {
    form.stopObserving();
    form.observe('submit', function() {
      checkForFiles(this);
    });
  });
}



// Ajax request

// Ajax request loading
document.observe("ajax:loading", function(event) {
  if(event.target.tagName.toLowerCase() != 'form') {
    var href = event.target.readAttribute('href');
    var lv = href.charAt(href.indexOf('lv=') + 3);
    $('lev'+lv).update('<img src="/images/loadingfaster.gif" alt="Loading" />');
    Effect.Appear('lev'+lv, {
      duration: 0.3
    });
    Effect.Appear('trans'+lv, {
      duration: 0.3,
      to: 0.3
    });
  } else {
    $('lev1').update('<img src="/images/loadingfaster.gif" alt="Loading" />');
  }

  // Stop observing all close
  if(popId && parseInt(event.target.id) == popId) {
    var close = $('window_close'+popId);
    if(close) {
      close.stopObserving();
    }
  }
});

// Ajax request complete
document.observe("ajax:complete", function(event) {

  // Target is not a form
  if(event.target.tagName.toLowerCase() != 'form') {

    // Observe press list change
    var pressName = $('prs_name');
    if(pressName) {
      pressName.observe('keyup', function() {
        new Ajax.Request('/press', {
          method: 'get',
          parameters: 'search_list=' + pressName.value,

          onSuccess: function(response) {
            $('press_list').update(response.responseText);
          }
        });
      });
    }

    // games/_new.html.erb
    // Observe tentative date checked
    var tentative = $('game_tentative_date');
    if(tentative) {
      tentative.observe('change', function() {
        if(tentative.checked) {
          $('tentative_release_date').show();
          $('release_date').hide();
        } else {
          $('tentative_release_date').hide();
          $('release_date').show();
        }
      });

      var tentativeDetail = $$('#tentative_release_date span').first();
      $('date_tentative_year').observe('change', function() {
        tentativeDetail.show();
      });

      var tentativeMonth = $('date_tentative_month');
      var tentativeValue = $('date_tentative_value');

      tentativeMonth.observe('change', function() {
        if(tentativeMonth.selectedIndex > 0) {
          tentativeValue.selectedIndex = 0;
        }
      });

      tentativeValue.observe('change', function() {
        if(tentativeValue.selectedIndex > 0) {
          tentativeMonth.selectedIndex = 0;
        }
      });
    }
  }

  // Focus first element of form
  popId = parseInt(event.target.id);
  var popForm = $$('#lev'+popId+' form').first();

  if(popForm) {
    popForm.focusFirstElement();
  }

  // Observe close button in pop up window
  var close = $('window_close'+popId);
  if(close) {
    close.stopObserving();
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

  observeFormSubmits();
});

// Check if form has files
function checkForFiles(form) {
  var hasFiles = false;
  form.getElements().each(function(element) {
    if(element.type == 'file') {
      if($F(element).length > 0)
        hasFiles = true;
    }
  });
  if(hasFiles) {
    if(formIsRemote(form))
      removeRemoteCall(form);
    return true;
  } else
    return false;
}

// Check if form is remote
function formIsRemote(form) {
  if(form.readAttribute('data-remote') == 'true')
    return true;
  else
    return false;
}

// Make element (form, a) non-remote
function removeRemoteCall(element) {
  element.setAttribute('data-remote', 'false');
}

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

// Insert li.id into input after selecting item from auto_complete in search input
function insertResultId(element, value) {
  var resultId = $('result_id');
  if(resultId)
    resultId.setAttribute('value', value.id);
}

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
  });
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
  var filters = $$('.'+cls).concat($$('.p'+cls)).concat($$('.d'+cls)).concat($$('.r'+cls)).concat($$('.n'+cls));
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
  var middle = window.screen.availWidth / 2;
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
  var middle = window.screen.availWidth / 2;
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

function clearText(textField, element) {
  $(textField).value = '';
  $(textField).focus();
  $(element).hide();
}

// Change font to black and style to normal when writing in search box
// DOM Element element - text field element
// int type - 1 to change to gray and italic, 0 for black and normal
// string text - text to display when not selected
function searchText(element, type, text) {
  if (type == 0) {
    if (element.value == text) {
      element.value = "";
      element.setStyle({
        'color': 'black',
        'fontStyle': 'normal'
      });
    }
  } else {
    if (element.value == "") {
      element.setStyle({
        'color': 'gray',
        'fontStyle': 'italic'
      });
      element.value = text;
    }
  }
}

function showClear(clear, element) {
  if ($F(element) != '') {
    $(clear).show();
  }
  else {
    $(clear).hide();
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
