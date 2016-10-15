// drag and drop handlers
// coffeescript doensn't work
var dragged;

/* events fired on the draggable target */
document.addEventListener("drag", function( event ) {
  // console.log('drag')
}, false);

document.addEventListener("dragstart", function( event ) {
  // store a ref. on the dragged elem
  // console.log('dragstart')
  event.dataTransfer.setData('text/html', null); // for Firefox
  dragged = $(event.target);
  dragged.css('opacity', .5)
}, false);

document.addEventListener("dragend", function( event ) {
  // reset the transparency
  // console.log('dragend')
  hide_drop_elem($(event.target))
}, false);

/* events fired on the drop targets */
document.addEventListener("dragover", function( event ) {
  // console.log('dragover')
  // prevent default to allow drop
  event.preventDefault();
}, false);

document.addEventListener("dragenter", function( event ) {
  // console.log('dragenter')
  // highlight potential drop target when the draggable element enters it
  elem = $(event.target)
  if ( elem.hasClass('board_drop') ) {
    show_drop_elem (elem);
  } else if ( elem.hasClass('shelf_drop') ) {
    show_drop_elem (elem);
  }
}, false);

document.addEventListener("dragleave", function( event ) {
  // console.log('dragleave')
  // reset background of potential drop target when the draggable element leaves it
  elem = $(event.target)
  // if ( elem.hasClass('board_drop') ) {
    hide_drop_elem (elem);
  // } else if ( elem.hasClass('shelf_drop') ) {
  //   hide_drop_elem (elem);
  // }
}, false);

document.addEventListener("drop", function( event ) {
  // console.log('drop')
  // prevent default action (open as link for some elements)
  event.preventDefault();
  elem = $(event.target)
  hide_drop_elem (elem)
  
  // blank letter
  blank = (dragged.attr('data-points') == '0')
  if (blank == true) {
    $('#game_data').attr('data-blank_from', dragged.parent().attr('id'))
    clear_tile(dragged)
  }

  // move dragged elem to the selected drop target
  if ( elem.hasClass('board_drop') && elem.children().length == 0 ) {
    // console.log('board')
    letter_resize(dragged, elem);
    // hide_drop_elem (elem);
    elem.append(dragged)
    set_buttons()
    if (blank == true) {init_swap_blank(elem)}

  } else if ( elem.hasClass('shelf_drop') && elem.children().length == 0 ) {
    // console.log('shelf')
    letter_resize(dragged, elem);
    // hide_drop_elem (elem);
    elem.append(dragged)
    set_buttons()

  // dropped on a shelf letter
  } else if ( elem.parent().hasClass('shelf_drop') ) {
    // console.log('shelf-letter')
    end_pos = parseInt(elem.parent().attr('id').split('_').pop())
    // dragged comes from the board
    if (dragged.parent().hasClass('board_drop')) {
      start_pos = parseInt($('.shelf_drop:not(:has(*))').first().attr('id').split('_').pop())
    // or from the shelve
    } else {
      start_pos = parseInt(dragged.parent().attr('id').split('_').pop())
    }
    // move aside the other tiles to the left
    if (start_pos < end_pos) {
      for (i = start_pos+1 ; i <= end_pos ; i++){
        if ($('#play_letters_pos_' + i.toString()).children() != undefined){
          $('#play_letters_pos_' + (i-1).toString()).append($('#play_letters_pos_' + i.toString()).children())
        }
      }
    // to the right
    } else if (start_pos > end_pos) {
      for (i = start_pos-1 ; i >= end_pos ; i--){
        if ($('#play_letters_pos_' + i.toString()).children() != undefined){
          $('#play_letters_pos_' + (i+1).toString()).append($('#play_letters_pos_' + i.toString()).children())
        }
      }
    }
    $('#play_letters_pos_' + (end_pos).toString()).append(dragged)
    letter_resize(dragged, elem.parent())
    // hide_drop_elem (elem)
    set_buttons()
  }
}, false);

function show_drop_elem(elem) { elem.css('opacity', .5); };
function hide_drop_elem(elem) { elem.css('opacity', ''); };

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
var game_id, game_state, turn_id, allow_swap;
function init_buttons(){
  game_id = $('#game_data').attr('data-game_id');
  game_state = $('#game_data').attr('data-game_state');
  turn_id = $('#game_data').attr('data-turn_id');
  turn_state = $('#game_data').attr('data-turn_state');
  allow_swap = $('#game_data').attr('data-allow_swap');
  
  $('#controls').on('click', '.play_btn', function(){

    // Play: 
    if ($(this).hasClass('play') == true && $(this).hasClass('disable') == false) {
      $.get('turns/' + turn_id + '/play', {laid_letters: laid_letters()}, null, 'script');

    // Pass: confirm in modal
    } else if ($(this).hasClass('pass') == true && $(this).hasClass('disable') == false){
      $.get('turns/' + turn_id + '/pass', '', null, 'script');

    // Shuffle: the letters
    } else if ($(this).hasClass('shuffle') == true){
      play_letters = $('#controls div.play_letter');
      letter_count = play_letters.length;
      for (x = 0; x < letter_count; x++){
        $('#controls #play_letters_pos_' + x.toString()).append(play_letters.splice(Math.floor(Math.random() * play_letters.length), 1)[0]);
      }

    // Clear: put play-letters back on the shelf
    } else if ($(this).hasClass('clear') == true){
      clear_board();

    //Swap: select in modal
    } else if ($(this).hasClass('swap') == true ){
      clear_board();
      $.get('turns/' + turn_id + '/swap', null, 'script');
    }
  })
  // display available buttons
  set_buttons();
};

// Clear: put play-letters back on the shelf
function clear_board(){
  $('#board .play_letter').each(function(){
    to_shelf($(this))
  })
}

// play-letter back to shelf
function to_shelf(elem){
  empty = $('#controls .shelf td').filter(function(){ return this.children.length < 1}).first();
  // Clear blank tile
  if (elem.attr('data-points') == '0'){ clear_tile(elem) }
  empty.append(elem);
  letter_resize(empty.children(), empty);
  set_buttons();
}

// set the play-buttons
function set_buttons(){
  // no play-letters on the board
  if ($('#board .play_letter').length == 0){
    $('.play_btn.play').parent().css('display', 'none');
    $('.play_btn.pass').parent().css('display', 'table-cell');
    $('.play_btn.shuffle').parent().css('display', 'table-cell');
    $('.play_btn.clear').parent().css('display', 'none');
  } else {
    $('.play_btn.play').parent().css('display', 'table-cell');
    $('.play_btn.pass').parent().css('display', 'none');
    $('.play_btn.shuffle').parent().css('display', 'none');
    $('.play_btn.clear').parent().css('display', 'table-cell');
  }
  // dis- or enable
  $('play_btn').removeClass('disable');
  // gamer not in turn
  if (turn_state != 'play'){
    $('.play_btn.play').addClass('disable');
    $('.play_btn.pass').addClass('disable');
    $('.play_btn.swap').addClass('disable');
  // not enough stockletters to swap
  } else if (allow_swap == 'false'){
    $('.play_btn.swap').addClass('disable');
  }
};

// collect the laid letters as one string: <row1>_<col1>_<letter1>_<points1>_<row2....
function laid_letters(){
    col = [];
    $('#board div.play_letter').each(function(){
        parts = $(this).parent().attr('id').split('_'); // 2=row, 3=column
        col.push(parts[2], parts[3], $(this).attr('data-letter'), $(this).attr('data-points'));
    })
    return col.join('_');
};

// Clear tile from 
function clear_tile(tile){
  tile.contents().filter(function(){
    return (this.nodeType == 3);
  }).remove();
}