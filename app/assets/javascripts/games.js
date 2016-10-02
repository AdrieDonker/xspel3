// drag and drop handlers
// coffeescript doensn't work
var dragged;

/* events fired on the draggable target */
document.addEventListener("drag", function( event ) {
}, false);

document.addEventListener("dragstart", function( event ) {
  // store a ref. on the dragged elem
  dragged = $(event.target);
  dragged.css('opacity', .5)
}, false);

document.addEventListener("dragend", function( event ) {
  // reset the transparency
  hide_drop_elem($(event.target))
}, false);

/* events fired on the drop targets */
document.addEventListener("dragover", function( event ) {
  // prevent default to allow drop
  event.preventDefault();
}, false);

document.addEventListener("dragenter", function( event ) {
  // highlight potential drop target when the draggable element enters it
  // console.log("dragenter: " + $(event.target).hasClass('board_drop'));
  elem = $(event.target)
  if ( elem.hasClass('board_drop') ) {
    show_drop_elem (elem);
  } else if ( elem.hasClass('shelf_drop') ) {
    show_drop_elem (elem);
  }
}, false);

document.addEventListener("dragleave", function( event ) {
  // reset background of potential drop target when the draggable element leaves it
  elem = $(event.target)
  if ( elem.hasClass('board_drop') ) {
    hide_drop_elem (elem);
  } else if ( elem.hasClass('shelf_drop') ) {
    hide_drop_elem (elem);
  }
}, false);

document.addEventListener("drop", function( event ) {
  // prevent default action (open as link for some elements)
  event.preventDefault();
  elem = $(event.target)
  // move dragged elem to the selected drop target
  if ( elem.hasClass('board_drop') ) {
    letter_resize(dragged, elem);
    hide_drop_elem (elem);
    elem.append(dragged)
    set_buttons()
  } else   if ( event.target.className == "shelf_drop" ) {
    letter_resize(dragged, elem);
    hide_drop_elem (elem);
    elem.append(dragged)
    set_buttons()
  }
}, false);

function show_drop_elem(elem) { elem.css('opacity', .5); }
function hide_drop_elem(elem) { elem.css('opacity', ''); }

// resize letter after moving
function letter_resize(letter, to_elem) {
  var letter_size, points_size, tile_size, tile_width;
  td_width = to_elem.cssInt('width');
  tile_size = (td_width - 2).toString() + 'px';
  letter_size = (td_width * 0.7).toString() + 'px';
  letter.css({
    'height': tile_size,
    'width': tile_size, 
    'line-height': tile_size,
    'font-size': letter_size
  });
  points_size = (td_width * 0.3).toString() + 'px';
  letter.children().css('font-size', points_size);
};

// set play-button handlers
function init_buttons(){
  $('#controls').on('click', '.play_btn', function(){
    if ($(this).hasClass('play') == true) {
      console.log('play')
    } else if ($(this).hasClass('pass') == true){
      console.log('pass')
    } else if ($(this).hasClass('shuffle') == true){
      console.log('shuffle')
      
    } else if ($(this).hasClass('clear') == true){
      $('#board .play_letter').each(function(){
        empty = $('#controls .shelf td').filter(function(){ return this.children.length < 1}).first()
        empty.append($(this))
        letter_resize(empty.children(), empty)
      })
    } else if ($(this).hasClass('swap') == true){
      console.log('swap')
    }
  })
}

// set the play-buttons
function set_buttons(){
  // no play-letters on the board
  if ($('#board .play_letter').length == 0){
    $('.play_btn.play').parent().css('display', 'none')
    $('.play_btn.pass').parent().css('display', 'table-cell')
    $('.play_btn.shuffle').parent().css('display', 'table-cell')
    $('.play_btn.clear').parent().css('display', 'none')
  } else {
    $('.play_btn.play').parent().css('display', 'table-cell')
    $('.play_btn.pass').parent().css('display', 'none')
    $('.play_btn.shuffle').parent().css('display', 'none')
    $('.play_btn.clear').parent().css('display', 'table-cell')
  }
}